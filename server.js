const express = require("express");
const helmet = require("helmet");
const cors = require("cors");
const compression = require("compression");
const rateLimit = require("express-rate-limit");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Database = require("better-sqlite3");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { z } = require("zod");

const app = express();

const PORT = Number(process.env.PORT || 3000);

const JWT_SECRET =
  process.env.JWT_SECRET ||
  "CHANGE_THIS_SECRET_IN_RENDER";

const DATA_DIR =
  path.join(__dirname, "data");

const UPLOAD_DIR =
  path.join(__dirname, "uploads");

const PUBLIC_DIR =
  path.join(__dirname, "public");

fs.mkdirSync(DATA_DIR, { recursive: true });
fs.mkdirSync(UPLOAD_DIR, { recursive: true });
fs.mkdirSync(PUBLIC_DIR, { recursive: true });

/* =====================================================
   DATABASE
===================================================== */

const db = new Database(
  path.join(DATA_DIR, "cars.db")
);

db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  email TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cars (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  price INTEGER NOT NULL,
  km INTEGER NOT NULL DEFAULT 0,
  city TEXT NOT NULL,
  fuel TEXT DEFAULT '',
  transmission TEXT DEFAULT '',
  description TEXT DEFAULT '',
  plan INTEGER NOT NULL DEFAULT 10000,
  status TEXT NOT NULL DEFAULT 'pending',
  image TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(user_id)
  REFERENCES users(id)
  ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  car_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  reference TEXT,
  receipt TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(car_id)
  REFERENCES cars(id)
  ON DELETE CASCADE,

  FOREIGN KEY(user_id)
  REFERENCES users(id)
  ON DELETE CASCADE
);
`);

/* =====================================================
   ADMIN
===================================================== */

function seedAdmin() {

  const email =
    process.env.ADMIN_EMAIL;

  const password =
    process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    console.log(
      "ADMIN_EMAIL / ADMIN_PASSWORD غير موجودة"
    );
    return;
  }

  const existing =
    db.prepare(
      "SELECT id FROM users WHERE email = ?"
    ).get(email);

  if (!existing) {

    const hash =
      bcrypt.hashSync(
        password,
        12
      );

    db.prepare(`
      INSERT INTO users
      (name, phone, email, password_hash, role)
      VALUES (?, ?, ?, ?, 'admin')
    `).run(
      "مدير بنت الموصل",
      "07000000000",
      email,
      hash
    );

    console.log(
      "Admin account created:",
      email
    );
  }
}

seedAdmin();

/* =====================================================
   SECURITY
===================================================== */

app.disable("x-powered-by");

app.use(
  helmet({
    contentSecurityPolicy: false
  })
);
app.use(cors());

app.use(compression());

app.use(
  express.json({
    limit: "200kb"
  })
);

app.use(
  express.urlencoded({
    extended: false,
    limit: "200kb"
  })
);

/* =====================================================
   STATIC
===================================================== */

app.use(
  "/uploads",
  express.static(UPLOAD_DIR)
);

app.use(
  express.static(PUBLIC_DIR)
);

/* =====================================================
   RATE LIMIT
===================================================== */

const apiLimiter =
  rateLimit({
    windowMs:
      15 * 60 * 1000,

    limit: 300,

    standardHeaders: true,

    legacyHeaders: false
  });

const authLimiter =
  rateLimit({
    windowMs:
      15 * 60 * 1000,

    limit: 30,

    standardHeaders: true,

    legacyHeaders: false
  });

app.use(
  "/api/",
  apiLimiter
);

/* =====================================================
   UPLOAD
===================================================== */

const storage =
  multer.diskStorage({

    destination:
      (req, file, cb) => {
        cb(
          null,
          UPLOAD_DIR
        );
      },

    filename:
      (req, file, cb) => {

        const ext =
          path.extname(
            file.originalname
          ).toLowerCase();

        const allowed = [
          ".jpg",
          ".jpeg",
          ".png",
          ".webp"
        ];

        const safeExt =
          allowed.includes(ext)
            ? ext
            : ".jpg";

        const filename =
          Date.now() +
          "-" +
          Math.random()
            .toString(36)
            .slice(2) +
          safeExt;

        cb(
          null,
          filename
        );
      }
  });

const upload =
  multer({

    storage,

    limits: {
      fileSize:
        5 * 1024 * 1024,

      files: 5
    },

    fileFilter:
      (req, file, cb) => {

        const allowed = [
          "image/jpeg",
          "image/png",
          "image/webp"
        ];

        if (
          allowed.includes(
            file.mimetype
          )
        ) {

          cb(
            null,
            true
          );

        } else {

          cb(
            new Error(
              "يسمح فقط بصور JPG و PNG و WEBP"
            )
          );

        }
      }
  });

/* =====================================================
   JWT
===================================================== */

function sign(user) {

  return jwt.sign(
    {
      sub:
        Number(user.id),

      role:
        user.role
    },

    JWT_SECRET,

    {
      expiresIn: "7d"
    }
  );
}

/* =====================================================
   AUTH
===================================================== */

function auth(
  req,
  res,
  next
) {

  const header =
    req.headers.authorization ||
    "";

  if (
    !header.startsWith(
      "Bearer "
    )
  ) {

    return res.status(401).json({
      error:
        "تسجيل الدخول مطلوب"
    });

  }

  const token =
    header
      .slice(7)
      .trim();

  try {

    const decoded =
      jwt.verify(
        token,
        JWT_SECRET
      );

    req.user =
      decoded;

    next();

  } catch (error) {

    return res.status(401).json({
      error:
        "جلسة غير صالحة أو منتهية"
    });

  }
}

function admin(
  req,
  res,
  next
) {

  if (
    !req.user ||
    req.user.role !== "admin"
  ) {

    return res.status(403).json({
      error:
        "صلاحية الإدارة مطلوبة"
    });

  }

  next();
}

/* =====================================================
   VALIDATION
===================================================== */

const registerSchema =
  z.object({

    name:
      z.string()
      .trim()
      .min(2)
      .max(100),

    phone:
      z.string()
      .trim()
      .min(6)
      .max(30),

    email:
      z.string()
      .trim()
      .email()
      .optional()
      .or(
        z.literal("")
      ),

    password:
      z.string()
      .min(6)
      .max(100)
  });

const loginSchema =
  z.object({

    phone:
      z.string()
      .trim()
      .min(6),

    password:
      z.string()
      .min(1)
  });

const carSchema =
  z.object({

    brand:
      z.string()
      .trim()
      .min(1)
      .max(50),

    model:
      z.string()
      .trim()
      .min(1)
      .max(100),

    year:
      z.coerce
      .number()
      .int()
      .min(1950)
      .max(2100),

    price:
      z.coerce
      .number()
      .int()
      .min(0),

    km:
      z.coerce
      .number()
      .int()
      .min(0)
      .max(10000000),

    city:
      z.string()
      .trim()
      .min(1)
      .max(100),

    fuel:
      z.string()
      .trim()
      .max(50)
      .optional()
      .default(""),

    transmission:
      z.string()
      .trim()
      .max(50)
      .optional()
      .default(""),

    description:
      z.string()
      .trim()
      .max(5000)
      .optional()
      .default(""),

    plan:
      z.coerce
      .number()
      .int()
      .refine(
        value =>
          [
            10000,
            20000,
            30000
          ].includes(value),

        {
          message:
            "الخطة غير صحيحة"
        }
      )
  });

/* =====================================================
   HEALTH
===================================================== */

app.get(
  "/api/health",
  (req, res) => {

    res.json({
      ok: true,

      message:
        "Bent Al-Mosul Cars API تعمل بنجاح",

      time:
        new Date().toISOString()
    });

  }
);

/* =====================================================
   REGISTER
===================================================== */

app.post(
  "/api/register",
  authLimiter,

  async (
    req,
    res
  ) => {

    try {

      const data =
        registerSchema.parse(
          req.body
        );

      const email =
        data.email ||
        null;

      const existingPhone =
        db.prepare(
          "SELECT id FROM users WHERE phone = ?"
        ).get(
          data.phone
        );

      if (existingPhone) {

        return res.status(409).json({
          error:
            "رقم الهاتف مستخدم مسبقاً"
        });

      }

      if (email) {

        const existingEmail =
          db.prepare(
            "SELECT id FROM users WHERE email = ?"
          ).get(
            email
          );

        if (existingEmail) {

          return res.status(409).json({
            error:
              "البريد الإلكتروني مستخدم مسبقاً"
          });

        }
      }

      const hash =
        await bcrypt.hash(
          data.password,
          12
        );

      const result =
        db.prepare(`
          INSERT INTO users
          (
            name,
            phone,
            email,
            password_hash
          )
          VALUES (?, ?, ?, ?)
        `).run(
          data.name,
          data.phone,
          email,
          hash
        );

      const user =
        db.prepare(`
          SELECT
            id,
            name,
            phone,
            email,
            role,
            created_at
          FROM users
          WHERE id = ?
        `).get(
          result.lastInsertRowid
        );

      const token =
        sign(user);

      res.status(201).json({
        success: true,
        token,
        user
      });

    } catch (error) {

      if (
        error instanceof
        z.ZodError
      ) {

        return res.status(400).json({
          error:
            "بيانات التسجيل غير صحيحة"
        });

      }

      console.error(
        "REGISTER ERROR:",
        error
      );

      res.status(500).json({
        error:
          "حدث خطأ أثناء إنشاء الحساب"
      });

    }
  }
);

/* =====================================================
   LOGIN
===================================================== */

app.post(
  "/api/login",
  authLimiter,

  async (
    req,
    res
  ) => {

    try {

      const data =
        loginSchema.parse(
          req.body
        );

      const user =
        db.prepare(`
          SELECT *
          FROM users
          WHERE phone = ?
        `).get(
          data.phone
        );

      if (!user) {

        return res.status(401).json({
          error:
            "رقم الهاتف أو كلمة المرور غير صحيحة"
        });

      }

      const valid =
        await bcrypt.compare(
          data.password,
          user.password_hash
        );

      if (!valid) {

        return res.status(401).json({
          error:
            "رقم الهاتف أو كلمة المرور غير صحيحة"
        });

      }

      const token =
        sign(user);

      res.json({
        success: true,

        token,

        user: {
          id:
            user.id,

          name:
            user.name,

          phone:
            user.phone,

          email:
            user.email,

          role:
            user.role
        }
      });

    } catch (error) {

      if (
        error instanceof
        z.ZodError
      ) {

        return res.status(400).json({
          error:
            "بيانات الدخول غير صحيحة"
        });

      }

      console.error(
        "LOGIN ERROR:",
        error
      );

      res.status(500).json({
        error:
          "حدث خطأ أثناء تسجيل الدخول"
      });

    }
  }
);

/* =====================================================
   ME
===================================================== */

app.get(
  "/api/me",
  auth,

  (req, res) => {

    const user =
      db.prepare(`
        SELECT
          id,
          name,
          phone,
          email,
          role,
          created_at
        FROM users
        WHERE id = ?
      `).get(
        req.user.sub
      );

    if (!user) {

      return res.status(404).json({
        error:
          "المستخدم غير موجود"
      });

    }

    res.json({
      user
    });

  }
);

/* =====================================================
   PUBLIC CARS
===================================================== */

app.get(
  "/api/cars",

  (req, res) => {

    try {

      const {
        search = "",
        city = "",
        minPrice,
        maxPrice,
        brand = ""
      } = req.query;

      let sql = `
        SELECT
          cars.id,
          cars.brand,
          cars.model,
          cars.year,
          cars.price,
          cars.km,
          cars.city,
          cars.fuel,
          cars.transmission,
          cars.description,
          cars.plan,
          cars.image,
          cars.status,
          cars.created_at,
          users.name AS seller_name,
          users.phone AS seller_phone
        FROM cars
        JOIN users
          ON users.id = cars.user_id
        WHERE cars.status = 'published'
      `;

      const params = [];

      if (search) {

        sql += `
          AND (
            cars.brand LIKE ?
            OR cars.model LIKE ?
            OR cars.city LIKE ?
          )
        `;

        const value =
          `%${search}%`;

        params.push(
          value,
          value,
          value
        );
      }

      if (city) {

        sql += `
          AND cars.city LIKE ?
        `;

        params.push(
          `%${city}%`
        );
      }

      if (brand) {

        sql += `
          AND cars.brand LIKE ?
        `;

        params.push(
          `%${brand}%`
        );
      }

      if (
        minPrice !== undefined &&
        minPrice !== ""
      ) {

        sql += `
          AND cars.price >= ?
        `;

        params.push(
          Number(minPrice)
        );
      }

      if (
        maxPrice !== undefined &&
        maxPrice !== ""
      ) {

        sql += `
          AND cars.price <= ?
        `;

        params.push(
          Number(maxPrice)
        );
      }

      sql += `
        ORDER BY
          cars.plan DESC,
          cars.id DESC
      `;

      const cars =
        db.prepare(
          sql
        ).all(
          ...params
        );

      res.json({
        success: true,
        cars
      });

    } catch (error) {

      console.error(
        "GET CARS ERROR:",
        error
      );

      res.status(500).json({
        error:
          "تعذر جلب السيارات"
      });

    }

  }
);

/* =====================================================
   SINGLE CAR
===================================================== */

app.get(
  "/api/cars/:id",

  (req, res) => {

    const id =
      Number(
        req.params.id
      );

    if (
      !Number.isInteger(id)
    ) {

      return res.status(400).json({
        error:
          "رقم السيارة غير صحيح"
      });

    }

    const car =
      db.prepare(`
        SELECT
          cars.*,
          users.name AS seller_name,
          users.phone AS seller_phone
        FROM cars
        JOIN users
          ON users.id = cars.user_id
        WHERE cars.id = ?
          AND cars.status = 'published'
      `).get(id);

    if (!car) {

      return res.status(404).json({
        error:
          "السيارة غير موجودة"
      });

    }

    res.json({
      success: true,
      car
    });

  }
);

/* =====================================================
   MY CARS
===================================================== */

app.get(
  "/api/my-cars",
  auth,

  (req, res) => {

    const cars =
      db.prepare(`
        SELECT *
        FROM cars
        WHERE user_id = ?
        ORDER BY id DESC
      `).all(
        req.user.sub
      );

    res.json({
      success: true,
      cars
    });

  }
);

/* Alias */
app.get(
  "/api/my/cars",
  auth,

  (req, res) => {

    const cars =
      db.prepare(`
        SELECT *
        FROM cars
        WHERE user_id = ?
        ORDER BY id DESC
      `).all(
        req.user.sub
      );

    res.json({
      success: true,
      cars
    });

  }
);

/* =====================================================
   ADD CAR
===================================================== */

app.post(
  "/api/cars",
  auth,

  upload.array(
    "images",
    5
  ),

  (req, res) => {

    try {

      const data =
        carSchema.parse(
          req.body
        );

      const files =
        req.files || [];

      const image =
        files.length
          ? `/uploads/${files[0].filename}`
          : null;

      const result =
        db.prepare(`
          INSERT INTO cars
          (
            user_id,
            brand,
            model,
            year,
            price,
            km,
            city,
            fuel,
            transmission,
            description,
            plan,
            status,
            image
          )
          VALUES
          (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?)
        `).run(
          req.user.sub,
          data.brand,
          data.model,
          data.year,
          data.price,
          data.km,
          data.city,
          data.fuel || "",
          data.transmission || "",
          data.description || "",
          data.plan,
          image
        );

      const car =
        db.prepare(`
          SELECT *
          FROM cars
          WHERE id = ?
        `).get(
          result.lastInsertRowid
        );

      res.status(201).json({
        success: true,

        message:
          "تم إرسال السيارة للمراجعة",

        car
      });

    } catch (error) {

      if (
        error instanceof
        z.ZodError
      ) {

        return res.status(400).json({
          error:
            "بيانات السيارة غير صحيحة",

          details:
            error.issues
        });

      }

      console.error(
        "ADD CAR ERROR:",
        error
      );

      res.status(500).json({
        error:
          "تعذر إضافة السيارة"
      });

    }

  }
);

/* =====================================================
   PAYMENTS
===================================================== */

app.post(
  "/api/payments",
  auth,

  upload.single(
    "receipt"
  ),

  (req, res) => {

    try {

      const carId =
        Number(
          req.body.car_id ||
          req.body.carId
        );

      const amount =
        Number(
          req.body.amount
        );

      const reference =
        String(
          req.body.reference || ""
        ).trim();

      if (
        !Number.isInteger(carId) ||
        carId <= 0
      ) {

        return res.status(400).json({
          error:
            "رقم السيارة غير صحيح"
        });

      }

      if (
        ![
          10000,
          20000,
          30000
        ].includes(amount)
      ) {

        return res.status(400).json({
          error:
            "مبلغ الدفع غير صحيح"
        });

      }

      const car =
        db.prepare(`
          SELECT *
          FROM cars
          WHERE id = ?
            AND user_id = ?
        `).get(
          carId,
          req.user.sub
        );

      if (!car) {

        return res.status(404).json({
          error:
            "السيارة غير موجودة أو ليست ملكك"
        });

      }

      const receipt =
        req.file
          ? `/uploads/${req.file.filename}`
          : null;

      const result =
        db.prepare(`
          INSERT INTO payments
          (
            car_id,
            user_id,
            amount,
            status,
            reference,
            receipt
          )
          VALUES
          (?, ?, ?, 'pending', ?, ?)
        `).run(
          carId,
          req.user.sub,
          amount,
          reference,
          receipt
        );

      res.status(201).json({
        success: true,

        message:
          "تم إرسال إثبات الدفع للمراجعة",

        payment_id:
          result.lastInsertRowid
      });

    } catch (error) {

      console.error(
        "PAYMENT ERROR:",
        error
      );

      res.status(500).json({
        error:
          "تعذر إرسال الدفع"
      });

    }

  }
);

/* =====================================================
   MY PAYMENTS
===================================================== */

app.get(
  "/api/my-payments",
  auth,

  (req, res) => {

    const payments =
      db.prepare(`
        SELECT
          payments.*,
          cars.brand,
          cars.model
        FROM payments
        JOIN cars
          ON cars.id = payments.car_id
        WHERE payments.user_id = ?
        ORDER BY payments.id DESC
      `).all(
        req.user.sub
      );

    res.json({
      success: true,
      payments
    });

  }
);

/* Alias */
app.get(
  "/api/my/payments",
  auth,

  (req, res) => {

    const payments =
      db.prepare(`
        SELECT
          payments.*,
          cars.brand,
          cars.model
        FROM payments
        JOIN cars
          ON cars.id = payments.car_id
        WHERE payments.user_id = ?
        ORDER BY payments.id DESC
      `).all(
        req.user.sub
      );

    res.json({
      success: true,
      payments
    });

  }
);

/* =====================================================
   ADMIN CARS
===================================================== */

app.get(
  "/api/admin/cars",
  auth,
  admin,

  (req, res) => {

    const cars =
      db.prepare(`
        SELECT
          cars.*,
          users.name AS seller_name,
          users.phone AS seller_phone
        FROM cars
        JOIN users
          ON users.id = cars.user_id
        ORDER BY cars.id DESC
      `).all();

    res.json({
      success: true,
      cars
    });

  }
);

/* =====================================================
   PUBLISH CAR
   PATCH + POST SUPPORT
===================================================== */

function publishCarHandler(
  req,
  res
) {

  const id =
    Number(
      req.params.id
    );

  if (
    !Number.isInteger(id)
  ) {

    return res.status(400).json({
      error:
        "رقم السيارة غير صحيح"
    });

  }

  const result =
    db.prepare(`
      UPDATE cars
      SET status = 'published'
      WHERE id = ?
    `).run(id);

  if (
    result.changes === 0
  ) {

    return res.status(404).json({
      error:
        "السيارة غير موجودة"
    });

  }

  res.json({
    success: true,

    message:
      "تم نشر السيارة"
  });

}

app.patch(
  "/api/admin/cars/:id/publish",
  auth,
  admin,
  publishCarHandler
);

app.post(
  "/api/admin/cars/:id/publish",
  auth,
  admin,
  publishCarHandler
);

/* =====================================================
   REJECT CAR
===================================================== */

function rejectCarHandler(
  req,
  res
) {

  const id =
    Number(
      req.params.id
    );

  if (
    !Number.isInteger(id)
  ) {

    return res.status(400).json({
      error:
        "رقم السيارة غير صحيح"
    });

  }

  const result =
    db.prepare(`
      UPDATE cars
      SET status = 'rejected'
      WHERE id = ?
    `).run(id);

  if (
    result.changes === 0
  ) {

    return res.status(404).json({
      error:
        "السيارة غير موجودة"
    });

  }

  res.json({
    success: true,

    message:
      "تم رفض الإعلان"
  });

}

app.patch(
  "/api/admin/cars/:id/reject",
  auth,
  admin,
  rejectCarHandler
);

app.post(
  "/api/admin/cars/:id/reject",
  auth,
  admin,
  rejectCarHandler
);

/* =====================================================
   DELETE ADMIN CAR
===================================================== */

app.delete(
  "/api/admin/cars/:id",
  auth,
  admin,

  (req, res) => {

    const id =
      Number(
        req.params.id
      );

    if (
      !Number.isInteger(id)
    ) {

      return res.status(400).json({
        error:
          "رقم السيارة غير صحيح"
      });

    }

    const car =
      db.prepare(`
        SELECT image
        FROM cars
        WHERE id = ?
      `).get(id);

    if (!car) {

      return res.status(404).json({
        error:
          "السيارة غير موجودة"
      });

    }

    db.prepare(
      "DELETE FROM cars WHERE id = ?"
    ).run(id);

    removeImage(
      car.image
    );

    res.json({
      success: true,

      message:
        "تم حذف السيارة"
    });

  }
);

/* =====================================================
   ADMIN PAYMENTS
===================================================== */

app.get(
  "/api/admin/payments",
  auth,
  admin,

  (req, res) => {

    const payments =
      db.prepare(`
        SELECT
          payments.*,
          cars.brand,
          cars.model,
          users.name AS user_name,
          users.phone AS user_phone
        FROM payments
        JOIN cars
          ON cars.id = payments.car_id
        JOIN users
          ON users.id = payments.user_id
        ORDER BY payments.id DESC
      `).all();

    res.json({
      success: true,
      payments
    });

  }
);

/* =====================================================
   APPROVE PAYMENT
===================================================== */

function approvePaymentHandler(
  req,
  res
) {

  const id =
    Number(
      req.params.id
    );

  if (
    !Number.isInteger(id)
  ) {

    return res.status(400).json({
      error:
        "رقم الدفع غير صحيح"
    });

  }

  const payment =
    db.prepare(`
      SELECT *
      FROM payments
      WHERE id = ?
    `).get(id);

  if (!payment) {

    return res.status(404).json({
      error:
        "عملية الدفع غير موجودة"
    });

  }

  db.prepare(`
    UPDATE payments
    SET status = 'approved'
    WHERE id = ?
  `).run(id);

  db.prepare(`
    UPDATE cars
    SET status = 'published'
    WHERE id = ?
  `).run(
    payment.car_id
  );

  res.json({
    success: true,

    message:
      "تم قبول الدفع ونشر الإعلان"
  });

}

app.patch(
  "/api/admin/payments/:id/approve",
  auth,
  admin,
  approvePaymentHandler
);

app.post(
  "/api/admin/payments/:id/approve",
  auth,
  admin,
  approvePaymentHandler
);

/* =====================================================
   REJECT PAYMENT
===================================================== */

function rejectPaymentHandler(
  req,
  res
) {

  const id =
    Number(
      req.params.id
    );

  if (
    !Number.isInteger(id)
  ) {

    return res.status(400).json({
      error:
        "رقم الدفع غير صحيح"
    });

  }

  const result =
    db.prepare(`
      UPDATE payments
      SET status = 'rejected'
     
