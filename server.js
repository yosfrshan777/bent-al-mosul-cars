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

/* =========================
   SETTINGS
========================= */

const PORT = Number(process.env.PORT || 3000);

const JWT_SECRET =
  process.env.JWT_SECRET || "DEV_ONLY_CHANGE_ME";

/* =========================
   DIRECTORIES
========================= */

const DATA_DIR = path.join(__dirname, "data");
const UPLOAD_DIR = path.join(__dirname, "uploads");
const PUBLIC_DIR = path.join(__dirname, "public");

fs.mkdirSync(DATA_DIR, { recursive: true });
fs.mkdirSync(UPLOAD_DIR, { recursive: true });
fs.mkdirSync(PUBLIC_DIR, { recursive: true });

/* =========================
   DATABASE
========================= */

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
  plan INTEGER NOT NULL,
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

/* =========================
   SAFE DATABASE MIGRATION
========================= */

try {
  db.prepare(
    "ALTER TABLE payments ADD COLUMN receipt TEXT"
  ).run();
} catch (_) {
  // العمود موجود مسبقاً
}

/* =========================
   ADMIN
========================= */

function seedAdmin() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    console.log(
      "ADMIN_EMAIL / ADMIN_PASSWORD غير موجودين"
    );
    return;
  }

  const existing = db
    .prepare(
      "SELECT id FROM users WHERE email = ?"
    )
    .get(email);

  if (existing) {
    return;
  }

  const hash = bcrypt.hashSync(password, 12);

  db.prepare(`
    INSERT INTO users
    (
      name,
      phone,
      email,
      password_hash,
      role
    )
    VALUES (?, ?, ?, ?, ?)
  `).run(
    "مدير بنت الموصل",
    "00000000000",
    email,
    hash,
    "admin"
  );

  console.log(
    "Admin account created successfully"
  );
}

seedAdmin();

/* =========================
   SECURITY
========================= */

app.disable("x-powered-by");

app.use(
  helmet({
    crossOriginResourcePolicy: {
      policy: "cross-origin"
    }
  })
);

app.use(cors());

app.use(compression());

app.use(
  express.json({
    limit: "100kb"
  })
);

app.use(
  express.urlencoded({
    extended: false,
    limit: "100kb"
  })
);

/* =========================
   UPLOADS
========================= */

app.use(
  "/uploads",
  express.static(UPLOAD_DIR)
);

/* =========================
   RATE LIMIT
========================= */

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 200,
  standardHeaders: true,
  legacyHeaders: false
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false
});

app.use(
  "/api/",
  apiLimiter
);

/* =========================
   MULTER
========================= */

const upload = multer({
  storage: multer.diskStorage({
    destination: (_, __, cb) => {
      cb(null, UPLOAD_DIR);
    },

    filename: (_, file, cb) => {
      const ext = path
        .extname(file.originalname)
        .toLowerCase();

      const filename =
        Date.now() +
        "-" +
        Math.random()
          .toString(36)
          .slice(2) +
        ext;

      cb(null, filename);
    }
  }),

  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 2
  },

  fileFilter: (_, file, cb) => {
    const allowed = [
      "image/jpeg",
      "image/png",
      "image/webp"
    ];

    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(
        new Error(
          "يسمح فقط بصور JPG و PNG و WEBP"
        )
      );
    }
  }
});

/* =========================
   JWT
========================= */

function sign(user) {
  return jwt.sign(
    {
      sub: user.id,
      role: user.role
    },
    JWT_SECRET,
    {
      expiresIn: "7d"
    }
  );
}

/* =========================
   AUTH
========================= */

function auth(req, res, next) {
  const header =
    req.headers.authorization || "";

  if (!header.startsWith("Bearer ")) {
    return res.status(401).json({
      error: "تسجيل الدخول مطلوب"
    });
  }

  const token = header.slice(7);

  try {
    req.user = jwt.verify(
      token,
      JWT_SECRET
    );

    next();
  } catch (_) {
    return res.status(401).json({
      error: "جلسة غير صالحة"
    });
  }
}

/* =========================
   ADMIN AUTH
========================= */

function admin(req, res, next) {
  if (
    !req.user ||
    req.user.role !== "admin"
  ) {
    return res.status(403).json({
      error: "صلاحية الإدارة مطلوبة"
    });
  }

  next();
}

/* =========================
   VALIDATION
========================= */

const registerSchema = z.object({
  name: z
    .string()
    .trim()
    .min(2)
    .max(80),

  phone: z
    .string()
    .trim()
    .regex(
      /^07\d{9}$/,
      "رقم الهاتف غير صحيح"
    ),

  email: z
    .string()
    .trim()
    .email()
    .max(120)
    .optional()
    .or(z.literal("")),

  password: z
    .string()
    .min(8)
    .max(100)
});

const carSchema = z.object({
  brand: z
    .string()
    .trim()
    .min(2)
    .max(40),

  model: z
    .string()
    .trim()
    .min(1)
    .max(60),

  year: z.coerce
    .number()
    .int()
    .min(1980)
    .max(
      new Date().getFullYear() + 1
    ),

  price: z.coerce
    .number()
    .int()
    .min(100000)
    .max(1000000000),

  km: z.coerce
    .number()
    .int()
    .min(0)
    .max(2000000),

  city: z
    .string()
    .trim()
    .min(2)
    .max(40),

  fuel: z
    .string()
    .trim()
    .max(30)
    .optional(),

  transmission: z
    .string()
    .trim()
    .max(30)
    .optional(),

  description: z
    .string()
    .trim()
    .max(1000)
    .optional(),

  plan: z.coerce
    .number()
    .refine(
      (value) =>
        [10000, 20000, 30000].includes(
          value
        ),
      {
        message: "الخطة غير صحيحة"
      }
    )
});

/* =========================
   REGISTER
========================= */

app.post(
  "/api/register",
  authLimiter,
  async (req, res) => {
    const result =
      registerSchema.safeParse(
        req.body
      );

    if (!result.success) {
      return res.status(400).json({
        error:
          "بيانات التسجيل غير صحيحة"
      });
    }

    const {
      name,
      phone,
      email,
      password
    } = result.data;

    try {
      const hash =
        await bcrypt.hash(
          password,
          12
        );

      const resultInsert =
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
          name,
          phone,
          email || null,
          hash
        );

      const user = {
        id: Number(
          resultInsert.lastInsertRowid
        ),
        name,
        phone,
        email: email || null,
        role: "user"
      };

      return res.json({
        ok: true,
        token: sign(user),
        user
      });

    } catch (error) {
      console.error(
        "REGISTER ERROR:",
        error
      );

      return res.status(409).json({
        error:
          "رقم الهاتف أو البريد مستخدم مسبقاً"
      });
    }
  }
);

/* =========================
   LOGIN
========================= */

app.post(
  "/api/login",
  authLimiter,
  async (req, res) => {
    const phone =
      String(
        req.body.phone || ""
      ).trim();

    const password =
      String(
        req.body.password || ""
      );

    if (!phone || !password) {
      return res.status(400).json({
        error:
          "أدخل رقم الهاتف وكلمة المرور"
      });
    }

    const user = db
      .prepare(`
        SELECT *
        FROM users
        WHERE phone = ?
      `)
      .get(phone);

    if (!user) {
      return res.status(401).json({
        error:
          "بيانات الدخول غير صحيحة"
      });
    }

    const valid =
      await bcrypt.compare(
        password,
        user.password_hash
      );

    if (!valid) {
      return res.status(401).json({
        error:
          "بيانات الدخول غير صحيحة"
      });
    }

    return res.json({
      ok: true,

      token: sign(user),

      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role
      }
    });
  }
);

/* =========================
   GET APPROVED CARS
========================= */

app.get(
  "/api/cars",
  (req, res) => {
    try {
      const cars = db
        .prepare(`
          SELECT
            c.id,
            c.brand,
            c.model,
            c.year,
            c.price,
            c.km,
            c.city,
            c.fuel,
            c.transmission,
            c.description,
            c.plan,
            c.image,
            c.created_at,
            u.name AS seller_name,
            u.phone AS seller_phone

          FROM cars c

          JOIN users u
          ON u.id = c.user_id

          WHERE c.status = 'approved'

          ORDER BY
            c.plan DESC,
            c.created_at DESC
        `)
        .all();

      return res.json(cars);

    } catch (error) {
      console.error(
        "GET CARS ERROR:",
        error
      );

      return res.status(500).json({
        error:
          "تعذر جلب السيارات"
      });
    }
  }
);

/* =========================
   GET SINGLE CAR
========================= */

app.get(
  "/api/cars/:id",
  (req, res) => {
    const id =
      Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        error:
          "رقم الإعلان غير صحيح"
      });
    }

    const car = db
      .prepare(`
        SELECT
          c.*,
          u.name AS seller_name,
          u.phone AS seller_phone

        FROM cars c

        JOIN users u
        ON u.id = c.user_id

        WHERE
          c.id = ?
          AND c.status = 'approved'
      `)
      .get(id);

    if (!car) {
      return res.status(404).json({
        error:
          "الإعلان غير موجود"
      });
    }

    return res.json(car);
  }
);

/* =========================
   ADD CAR
========================= */

app.post(
  "/api/cars",
  auth,

  upload.fields([
    {
      name: "image",
      maxCount: 1
    },

    {
      name: "receipt",
      maxCount: 1
    }
  ]),

  (req, res) => {
    const result =
      carSchema.safeParse(
        req.body
      );

    if (!result.success) {
      return res.status(400).json({
        error:
          "بيانات السيارة غير صحيحة"
      });
    }

    const data =
      result.data;

    const imageFile =
      req.files?.image?.[0] ||
      null;

    const receiptFile =
      req.files?.receipt?.[0] ||
      null;

    const image =
      imageFile
        ? `/uploads/${imageFile.filename}`
        : null;

    const receipt =
      receiptFile
        ? `/uploads/${receiptFile.filename}`
        : null;

    try {
      const transaction =
        db.transaction(() => {
          const car =
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
              (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
              "pending",
              image
            );

          const carId =
            Number(
              car.lastInsertRowid
            );

          db.prepare(`
            INSERT INTO payments
            (
              car_id,
              user_id,
              amount,
              status,
              receipt
            )

            VALUES
            (?, ?, ?, 'pending', ?)
          `).run(
            carId,
            req.user.sub,
            data.plan,
            receipt
          );

          return carId;
        });

      const carId =
        transaction();

      return res.json({
        ok: true,

        message:
          "تم إرسال الإعلان للمراجعة",

        carId
      });

    } catch (error) {
      console.error(
        "ADD CAR ERROR:",
        error
      );

      return res.status(500).json({
        error:
          "تعذر حفظ الإعلان"
      });
    }
  }
);

/* =========================
   MY CARS
========================= */

app.get(
  "/api/my-cars",
  auth,
  (req, res) => {
    try {
      const cars =
        db.prepare(`
          SELECT *
          FROM cars
          WHERE user_id = ?
          ORDER BY id DESC
        `).all(
          req.user.sub
        );

      return res.json(cars);

    } catch (error) {
      console.error(
        "MY CARS ERROR:",
        error
      );

      return res.status(500).json({
        error:
          "تعذر جلب إعلاناتك"
      });
    }
  }
);

/* =========================
   ADMIN CARS
========================= */

app.get(
  "/api/admin/cars",
  auth,
  admin,
  (req, res) => {
    try {
      const cars =
        db.prepare(`
          SELECT
            c.*,

            u.name AS seller_name,
            u.phone AS seller_phone,
            u.email AS seller_email,

            p.amount AS payment_amount,
            p.status AS payment_status,
            p.reference AS payment_reference,
            p.receipt AS payment_receipt

          FROM cars c

          JOIN users u
          ON u.id = c.user_id

          LEFT JOIN payments p
          ON p.car_id = c.id

          ORDER BY c.id DESC
        `).all();

      return res.json(cars);

    } catch (error) {
      console.error(
        "ADMIN CARS ERROR:",
        error
      );

      return res.status(500).json({
        error:
          "تعذر جلب إعلانات الإدارة"
      });
    }
  }
);

/* =========================
   APPROVE CAR
========================= */

app.post(
  "/api/admin/cars/:id/approve",
  auth,
  admin,
  (req, res) => {
    const id =
      Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        error:
          "رقم الإعلان غير صحيح"
      });
    }

    const car =
      db.prepare(`
        SELECT id
        FROM cars
        WHERE id = ?
      `).get(id);

    if (!car) {
      return res.status(404).json({
        error:
          "الإعلان غير موجود"
      });
    }

    try {
      const transaction =
        db.transaction(() => {
          db.prepare(`
            UPDATE cars

            SET status = 'approved'

            WHERE id = ?
          `).run(id);

          db.prepare(`
            UPDATE payments

            SET status = 'paid'

            WHERE car_id = ?
          `).run(id);
        });

      transaction();

      return res.json({
        ok: true,
        message:
          "تم اعتماد الإعلان"
      });

    } catch (error) {
      console.error(
        "APPROVE ERROR:",
        error
      );

      return res.status(500).json({
        error:
          "تعذر اعتماد الإعلان"
      });
    }
  }
);

/* =========================
   REJECT CAR
========================= */

app.post(
  "/api/admin/cars/:id/reject",
  auth,
  admin,
  (req, res) => {
    const id =
      Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        error:
          "رقم الإعلان غير صحيح"
      });
    }

    const result =
      db.prepare(`
        UPDATE cars

        SET status = 'rejected'

        WHERE id = ?
      `).run(id);

    if (!result.changes) {
      return res.status(404).json({
        error:
          "الإعلان غير موجود"
      });
    }

    return res.json({
      ok: true,
      message:
        "تم رفض الإعلان"
    });
  }
);

/* =========================
   DELETE CAR
========================= */

app.delete(
  "/api/admin/cars/:id",
  auth,
  admin,
  (req, res) => {
    const id =
      Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        error:
          "رقم الإعلان غير صحيح"
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
          "الإعلان غير موجود"
      });
    }

    try {
      if (car.image) {
        const imagePath =
          path.join(
            __dirname,
            car.image.replace(
              /^\/+/,
              ""
            )
          );

        if (
          fs.existsSync(
            imagePath
          )
        ) {
          try {
            fs.unlinkSync(
              imagePath
            );
          } catch (_) {}
        }
      }

      db.prepare(`
        DELETE FROM cars
        WHERE id = ?
      `).run(id);

      return res.json({
        ok: true,
        message:
          "تم حذف الإعلان"
      });

    } catch (error) {
      console.error(
        "DELETE CAR ERROR:",
        error
      );

      return res.status(500).json({
        error:
          "تعذر حذف الإعلان"
      });
    }
  }
);

/* =========================
   HEALTH CHECK
========================= */

app.get(
  "/api/health",
  (req, res) => {
    return res.json({
      ok: true,
      service:
        "bent-al-mosul-cars",
      time:
        new Date().toISOString()
    });
  }
);

/* =========================
   FRONTEND
========================= */

app.use(
  express.static(
    PUBLIC_DIR
  )
);

app.get(
  "*",
  (req, res) => {
    const indexPath =
      path.join(
        PUBLIC_DIR,
        "index.html"
      );

    if (
      fs.existsSync(
        indexPath
      )
    ) {
      return res.sendFile(
        indexPath
      );
    }

    return res.status(404).send(
      "Frontend index.html غير موجود"
    );
  }
);

/* =========================
   ERROR HANDLER
========================= */

app.use(
  (err, req, res, next) => {
    console.error(
      "SERVER ERROR:",
      err
    );

    if (
      err instanceof
      multer.MulterError
    ) {
      return res.status(400).json({
        error:
          "حجم أو عدد الصور غير مسموح"
      });
    }

    if (
      err &&
      err.message &&
      err.message.includes(
        "يسمح فقط بصور"
      )
    ) {
      return res.status(400).json({
        error:
          "يسمح فقط بصور JPG و PNG و WEBP"
      });
    }

    return res.status(500).json({
      error:
        "حدث خطأ في الخادم"
    });
  }
);

/* =========================
   START SERVER
========================= */

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      `بنت الموصل للسيارات تعمل على المنفذ ${PORT}`
    );
  }
);
