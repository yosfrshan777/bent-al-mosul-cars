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

const app = express();

const PORT = process.env.PORT || 3000;

const JWT_SECRET =
  process.env.JWT_SECRET || "CHANGE_THIS_SECRET_IN_RENDER";

const ADMIN_EMAIL =
  process.env.ADMIN_EMAIL || "admin@example.com";

const ADMIN_PASSWORD =
  process.env.ADMIN_PASSWORD || "ChangeMe123!";

const DATA_DIR = path.join(__dirname, "data");
const UPLOAD_DIR = path.join(__dirname, "uploads");

fs.mkdirSync(DATA_DIR, { recursive: true });
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

/* =========================
   DATABASE
========================= */

const db = new Database(
  path.join(DATA_DIR, "bent-al-mosul.db")
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
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cars (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  public_no TEXT,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  price INTEGER NOT NULL,
  km INTEGER DEFAULT 0,
  city TEXT NOT NULL,
  fuel TEXT DEFAULT '',
  transmission TEXT DEFAULT '',
  description TEXT DEFAULT '',
  image TEXT,
  plan INTEGER DEFAULT 10000,
  status TEXT DEFAULT 'pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(user_id)
  REFERENCES users(id)
  ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  car_id INTEGER,
  kind TEXT NOT NULL,
  amount INTEGER NOT NULL,
  receipt TEXT,
  reference TEXT DEFAULT '',
  status TEXT DEFAULT 'pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(user_id)
  REFERENCES users(id)
  ON DELETE CASCADE,

  FOREIGN KEY(car_id)
  REFERENCES cars(id)
  ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  shop_name TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  city TEXT NOT NULL,
  logo TEXT,
  plan TEXT DEFAULT 'normal',
  amount INTEGER DEFAULT 15000,
  status TEXT DEFAULT 'pending',
  expires_at TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(user_id)
  REFERENCES users(id)
  ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS parts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  shop_id INTEGER,
  name TEXT NOT NULL,
  price INTEGER NOT NULL,
  city TEXT NOT NULL,
  description TEXT DEFAULT '',
  image TEXT,
  status TEXT DEFAULT 'pending',
  vip INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(user_id)
  REFERENCES users(id)
  ON DELETE CASCADE,

  FOREIGN KEY(shop_id)
  REFERENCES shops(id)
  ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  car_id INTEGER,
  sender_id INTEGER NOT NULL,
  receiver_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(car_id)
  REFERENCES cars(id)
  ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS offers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  target TEXT NOT NULL,
  discount INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  color TEXT DEFAULT 'pink',
  start_at TEXT NOT NULL,
  end_at TEXT NOT NULL,
  active INTEGER DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
`);

/* =========================
   ADMIN ACCOUNT
========================= */

const existingAdmin = db
  .prepare("SELECT id FROM users WHERE email = ?")
  .get(ADMIN_EMAIL);

if (!existingAdmin) {
  const hash = bcrypt.hashSync(ADMIN_PASSWORD, 12);

  db.prepare(`
    INSERT INTO users
    (name, phone, email, password_hash, role)
    VALUES (?, ?, ?, ?, ?)
  `).run(
    "مالك بنت الموصل",
    "07700000000",
    ADMIN_EMAIL,
    hash,
    "owner"
  );
} else {
  db.prepare(`
    UPDATE users
    SET role = 'owner'
    WHERE email = ?
  `).run(ADMIN_EMAIL);
}

/* =========================
   APP
========================= */

app.use(
  helmet({
    contentSecurityPolicy: false
  })
);

app.use(cors());
app.use(compression());

app.use(
  express.json({
    limit: "3mb"
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: "3mb"
  })
);

app.use(
  express.static(__dirname)
);

app.use(
  "/uploads",
  express.static(UPLOAD_DIR)
);

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 300,
  standardHeaders: true,
  legacyHeaders: false
});

app.use("/api/", limiter);

/* =========================
   UPLOAD
========================= */

const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, UPLOAD_DIR);
  },

  filename(req, file, cb) {
    const ext = path.extname(file.originalname);

    const name =
      Date.now() +
      "-" +
      Math.random()
        .toString(36)
        .substring(2) +
      ext;

    cb(null, name);
  }
});

const upload = multer({
  storage,

  limits: {
    fileSize: 7 * 1024 * 1024
  },

  fileFilter(req, file, cb) {
    if (
      [
        "image/jpeg",
        "image/png",
        "image/webp"
      ].includes(file.mimetype)
    ) {
      cb(null, true);
    } else {
      cb(new Error("نوع الصورة غير مسموح"));
    }
  }
});

/* =========================
   HELPERS
========================= */

function createToken(user) {
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

function auth(req, res, next) {
  const header =
    req.headers.authorization || "";

  if (!header.startsWith("Bearer ")) {
    return res.status(401).json({
      error: "يجب تسجيل الدخول"
    });
  }

  try {
    const token = header.substring(7);

    req.user = jwt.verify(
      token,
      JWT_SECRET
    );

    next();
  } catch {
    return res.status(401).json({
      error: "انتهت جلسة تسجيل الدخول"
    });
  }
}

function adminOnly(req, res, next) {
  if (
    !["owner", "admin"].includes(
      req.user.role
    )
  ) {
    return res.status(403).json({
      error: "هذه الصفحة للإدارة فقط"
    });
  }

  next();
}

/* =========================
   CONFIG
========================= */

const provinces = [
  "بغداد",
  "نينوى",
  "أربيل",
  "دهوك",
  "السليمانية",
  "كركوك",
  "الأنبار",
  "صلاح الدين",
  "ديالى",
  "واسط",
  "بابل",
  "كربلاء",
  "النجف",
  "القادسية",
  "المثنى",
  "ذي قار",
  "ميسان",
  "البصرة"
];

const brands = [
  "Toyota",
  "BMW",
  "Mercedes-Benz",
  "Lexus",
  "Hyundai",
  "Kia",
  "Nissan",
  "Chevrolet",
  "Ford",
  "Honda",
  "Audi",
  "Volkswagen",
  "MG",
  "Chery",
  "Geely",
  "Mitsubishi",
  "Dodge",
  "Jeep",
  "Porsche",
  "Land Rover"
];

/* =========================
   HEALTH
========================= */

app.get("/api/health", (req, res) => {
  res.json({
    ok: true,
    app: "بنت الموصل للسيارات"
  });
});

/* =========================
   CONFIG
========================= */

app.get("/api/config", (req, res) => {
  res.json({
    provinces,
    brands,

    carPlans: [
      {
        amount: 10000,
        name: "عادي"
      },
      {
        amount: 20000,
        name: "مميز"
      },
      {
        amount: 30000,
        name: "VIP"
      }
    ],

    partsNormal: 15000,

    partsVIP: 50000,

    dealerMonthlyUSD: 100,

    asiaCell: "07738308993"
  });
});

/* =========================
   REGISTER
========================= */

app.post("/api/register", async (req, res) => {
  try {
    const {
      name,
      phone,
      email,
      password
    } = req.body;

    if (!name || !phone || !password) {
      return res.status(400).json({
        error:
          "الاسم ورقم الهاتف وكلمة المرور مطلوبة"
      });
    }

    if (!/^07\d{9}$/.test(phone)) {
      return res.status(400).json({
        error:
          "رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ07"
      });
    }

    const old = db
      .prepare(`
        SELECT id
        FROM users
        WHERE phone = ?
        OR (
          email IS NOT NULL
          AND email <> ''
          AND email = ?
        )
      `)
      .get(
        phone,
        email || ""
      );

    if (old) {
      return res.status(409).json({
        error:
          "رقم الهاتف أو Gmail مستخدم مسبقاً"
      });
    }

    const hash =
      await bcrypt.hash(
        password,
        12
      );

    const result =
      db.prepare(`
        INSERT INTO users
        (name, phone, email, password_hash)
        VALUES (?, ?, ?, ?)
      `).run(
        name.trim(),
        phone.trim(),
        email
          ? email.trim()
          : null,
        hash
      );

    const user =
      db.prepare(`
        SELECT
          id,
          name,
          phone,
          email,
          role
        FROM users
        WHERE id = ?
      `).get(result.lastInsertRowid);

    res.status(201).json({
      token: createToken(user),
      user
    });
  } catch {
    res.status(400).json({
      error: "تعذر إنشاء الحساب"
    });
  }
});

/* =========================
   LOGIN
========================= */

app.post("/api/login", async (req, res) => {
  try {
    const {
      login,
      password
    } = req.body;

    if (!login || !password) {
      return res.status(400).json({
        error:
          "أدخل Gmail أو رقم الهاتف وكلمة المرور"
      });
    }

    const user =
      db.prepare(`
        SELECT *
        FROM users
        WHERE email = ?
        OR phone = ?
      `).get(
        login.trim(),
        login.trim()
      );

    if (
      !user ||
      !(await bcrypt.compare(
        password,
        user.password_hash
      ))
    ) {
      return res.status(401).json({
        error:
          "بيانات تسجيل الدخول غير صحيحة"
      });
    }

    res.json({
      token: createToken(user),

      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role
      }
    });
  } catch {
    res.status(400).json({
      error: "خطأ في تسجيل الدخول"
    });
  }
});

/* =========================
   ME
========================= */

app.get("/api/me", auth, (req, res) => {
  const user =
    db.prepare(`
      SELECT
        id,
        name,
        phone,
        email,
        role
      FROM users
      WHERE id = ?
    `).get(req.user.sub);

  res.json({
    user
  });
});

/* =========================
   CARS
========================= */

app.get("/api/cars", (req, res) => {
  let sql = `
    SELECT
      c.*,
      u.name AS seller_name,
      u.phone AS seller_phone
    FROM cars c
    JOIN users u
      ON u.id = c.user_id
    WHERE c.status = 'published'
  `;

  const params = [];

  if (req.query.brand) {
    sql += " AND c.brand = ?";
    params.push(req.query.brand);
  }

  if (req.query.city) {
    sql += " AND c.city = ?";
    params.push(req.query.city);
  }

  if (req.query.search) {
    sql += `
      AND (
        c.brand LIKE ?
        OR c.model LIKE ?
        OR c.description LIKE ?
      )
    `;

    const value =
      "%" +
      req.query.search +
      "%";

    params.push(
      value,
      value,
      value
    );
  }

  sql += `
    ORDER BY
      c.plan DESC,
      c.id DESC
  `;

  res.json({
    cars: db
      .prepare(sql)
      .all(...params)
  });
});

/* =========================
   RANDOM CARS
========================= */

app.get(
  "/api/cars/random",
  (req, res) => {
    const cars =
      db.prepare(`
        SELECT
          c.*,
          u.name AS seller_name,
          u.phone AS seller_phone
        FROM cars c
        JOIN users u
          ON u.id = c.user_id
        WHERE c.status = 'published'
        ORDER BY RANDOM()
        LIMIT 30
      `).all();

    res.json({
      cars
    });
  }
);

/* =========================
   SINGLE CAR
========================= */

app.get(
  "/api/cars/:id",
  (req, res) => {
    const car =
      db.prepare(`
        SELECT
          c.*,
          u.name AS seller_name,
          u.phone AS seller_phone
        FROM cars c
        JOIN users u
          ON u.id = c.user_id
        WHERE
          c.id = ?
          AND c.status = 'published'
      `).get(req.params.id);

    if (!car) {
      return res.status(404).json({
        error: "السيارة غير موجودة"
      });
    }

    res.json({
      car
    });
  }
);

/* =========================
   ADD CAR
========================= */

app.post(
  "/api/cars",
  auth,
  upload.single("image"),
  (req, res) => {
    try {
      const {
        public_no,
        brand,
        model,
        year,
        price,
        km,
        city,
        fuel,
        transmission,
        description,
        plan
      } = req.body;

      if (
        !brand ||
        !model ||
        !year ||
        !price ||
        !city
      ) {
        return res.status(400).json({
          error:
            "أكمل معلومات السيارة"
        });
      }

      const amount =
        Number(plan || 10000);

      if (
        ![
          10000,
          20000,
          30000
        ].includes(amount)
      ) {
        return res.status(400).json({
          error:
            "الباقة غير صحيحة"
        });
      }

      const isAdmin =
        ["owner", "admin"].includes(
          req.user.role
        );

      const result =
        db.prepare(`
          INSERT INTO cars
          (
            user_id,
            public_no,
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
          (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          req.user.sub,

          isAdmin
            ? public_no || null
            : null,

          brand,
          model,
          Number(year),
          Number(price),
          Number(km || 0),
          city,
          fuel || "",
          transmission || "",
          description || "",
          amount,

          isAdmin
            ? "published"
            : "pending",

          req.file
            ? "/uploads/" +
              req.file.filename
            : null
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
        car,
        ownerFree: isAdmin
      });
    } catch {
      res.status(400).json({
        error:
          "تعذر نشر السيارة"
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
    res.json({
      cars: db
        .prepare(`
          SELECT *
          FROM cars
          WHERE user_id = ?
          ORDER BY id DESC
        `)
        .all(req.user.sub)
    });
  }
);

/* =========================
   PAYMENTS
========================= */

app.post(
  "/api/payments",
  auth,
  upload.single("receipt"),
  (req, res) => {
    try {
      const amount =
        Number(req.body.amount);

      const kind =
        req.body.kind || "car";

      const carId =
        req.body.car_id
          ? Number(req.body.car_id)
          : null;

      if (
        ![
          10000,
          20000,
          30000,
          15000,
          50000
        ].includes(amount)
      ) {
        return res.status(400).json({
          error:
            "المبلغ غير صحيح"
        });
      }

      if (
        !req.file
      ) {
        return res.status(400).json({
          error:
            "صورة إثبات التحويل مطلوبة"
        });
      }

      if (
        kind === "car" &&
        !carId
      ) {
        return res.status(400).json({
          error:
            "السيارة مطلوبة"
        });
      }

      if (carId) {
        const car =
          db.prepare(`
            SELECT id
            FROM cars
            WHERE
              id = ?
              AND user_id = ?
          `).get(
            carId,
            req.user.sub
          );

        if (!car) {
          return res.status(403).json({
            error:
              "هذه السيارة ليست تابعة لحسابك"
          });
        }
      }

      const result =
        db.prepare(`
          INSERT INTO payments
          (
            user_id,
            car_id,
            kind,
            amount,
            receipt,
            reference
          )
          VALUES (?, ?, ?, ?, ?, ?)
        `).run(
          req.user.sub,
          carId,
          kind,
          amount,
          "/uploads/" +
            req.file.filename,
          req.body.reference || ""
        );

      res.status(201).json({
        payment_id:
          result.lastInsertRowid,

        message:
          "تم إرسال إثبات التحويل للإدارة"
      });
    } catch {
      res.status(400).json({
        error:
          "تعذر إرسال إثبات التحويل"
      });
    }
  }
);

/* =========================
   PARTS
========================= */

app.get(
  "/api/parts",
  (req, res) => {
    let sql = `
      SELECT
        p.*,
        s.shop_name,
        s.owner_name,
        s.plan AS shop_plan
      FROM parts p
      LEFT JOIN shops s
        ON s.id = p.shop_id
      WHERE p.status = 'published'
    `;

    const params = [];

    if (req.query.city) {
      sql +=
        " AND p.city = ?";
      params.push(
        req.query.city
      );
    }

    sql += `
      ORDER BY
        p.vip DESC,
        p.id DESC
    `;

    res.json({
      parts:
        db.prepare(sql)
          .all(...params)
    });
  }
);

/* =========================
   VIP SHOP
========================= */

app.post(
  "/api/shops/vip",
  auth,
  upload.single("logo"),
  (req, res) => {
    try {
      const {
        shop_name,
        owner_name,
        phone,
        email,
        city
      } = req.body;

      if (
        !shop_name ||
        !owner_name ||
        !phone ||
        !city
      ) {
        return res.status(400).json({
          error:
            "أكمل بيانات المحل"
        });
      }

      const result =
        db.prepare(`
          INSERT INTO shops
          (
            user_id,
            shop_name,
            owner_name,
            phone,
            email,
            city,
            logo,
            plan,
            amount,
            status
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          req.user.sub,
          shop_name,
          owner_name,
          phone,
          email || null,
          city,

          req.file
            ? "/uploads/" +
              req.file.filename
            : null,

          "vip",
          50000,
          "pending"
        );

      res.status(201).json({
        shop_id:
          result.lastInsertRowid,

        message:
          "تم إنشاء طلب حساب المحل VIP، أرسل إثبات الدفع"
      });
    } catch {
      res.status(400).json({
        error:
          "تعذر إنشاء حساب المحل"
      });
    }
  }
);

/* =========================
   ADD PART
========================= */

app.post(
  "/api/parts",
  auth,
  upload.single("image"),
  (req, res) => {
    try {
      const {
        name,
        price,
        city,
        description
      } = req.body;

      if (
        !name ||
        !price ||
        !city
      ) {
        return res.status(400).json({
          error:
            "أكمل معلومات القطعة"
        });
      }

      const normal =
        db.prepare(`
          SELECT id
          FROM payments
          WHERE
            user_id = ?
            AND kind = 'parts'
            AND amount = 15000
            AND status = 'approved'
            AND datetime(
              created_at,
              '+15 days'
            ) > datetime('now')
          ORDER BY id DESC
          LIMIT 1
        `).get(req.user.sub);

      const vip =
        db.prepare(`
          SELECT id
          FROM shops
          WHERE
            user_id = ?
            AND plan = 'vip'
            AND status = 'approved'
            AND datetime(expires_at)
              > datetime('now')
          ORDER BY id DESC
          LIMIT 1
        `).get(req.user.sub);

      if (!normal && !vip) {
        return res.status(403).json({
          error:
            "تحتاج اشتراك قطع الغيار 15,000 أو حساب محل VIP"
        });
      }

      const result =
        db.prepare(`
          INSERT INTO parts
          (
            user_id,
            shop_id,
            name,
            price,
            city,
            description,
            image,
            status,
            vip
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          req.user.sub,
          vip
            ? vip.id
            : null,
          name,
          Number(price),
          city,
          description || "",
          req.file
            ? "/uploads/" +
              req.file.filename
            : null,
          "pending",
          vip ? 1 : 0
        );

      res.status(201).json({
        part_id:
          result.lastInsertRowid,

        message:
          "تم إرسال القطعة للمراجعة"
      });
    } catch {
      res.status(400).json({
        error:
          "تعذر إضافة القطعة"
      });
    }
  }
);

/* =========================
   MESSAGES
========================= */

app.post(
  "/api/messages",
  auth,
  (req, res) => {
    const {
      car_id,
      receiver_id,
      body
    } = req.body;

    if (
      !receiver_id ||
      !body
    ) {
      return res.status(400).json({
        error:
          "اكتب الرسالة"
      });
    }

    const result =
      db.prepare(`
        INSERT INTO messages
        (
          car_id,
          sender_id,
          receiver_id,
          body
        )
        VALUES (?, ?, ?, ?)
      `).run(
        car_id || null,
        req.user.sub,
        Number(receiver_id),
        String(body).trim()
      );

    res.status(201).json({
      id:
        result.lastInsertRowid
    });
  }
);

/* =========================
   GET MESSAGES
========================= */

app.get(
  "/api/messages/:userId",
  auth,
  (req, res) => {
    const userId =
      Number(req.params.userId);

    const messages =
      db.prepare(`
        SELECT
          m.*,
          u.name AS sender_name
        FROM messages m
        JOIN users u
          ON u.id = m.sender_id
        WHERE
          (
            m.sender_id = ?
            AND m.receiver_id = ?
          )
          OR
          (
            m.sender_id = ?
            AND m.receiver_id = ?
          )
        ORDER BY m.id ASC
      `).all(
        req.user.sub,
        userId,
        userId,
        req.user.sub
      );

    res.json({
      messages
    });
  }
);

/* =========================
   ACTIVE OFFERS
========================= */

app.get(
  "/api/offers",
  (req, res) => {
    const offers =
      db.prepare(`
        SELECT *
        FROM offers
        WHERE
          active = 1
          AND datetime('now')
          BETWEEN datetime(start_at)
          AND datetime(end_at)
        ORDER BY id DESC
      `).all();

    res.json({
      offers
    });
  }
);

/* =========================
   ADMIN STATS
========================= */

app.get(
  "/api/admin/stats",
  auth,
  adminOnly,
  (req, res) => {
    const users =
      db.prepare(`
        SELECT COUNT(*) AS n
        FROM users
      `).get().n;

    const cars =
      db.prepare(`
        SELECT COUNT(*) AS n
        FROM cars
      `).get().n;

    const pendingCars =
      db.prepare(`
        SELECT COUNT(*) AS n
        FROM cars
        WHERE status = 'pending'
      `).get().n;

    const payments =
      db.prepare(`
        SELECT COUNT(*) AS n
        FROM payments
        WHERE status = 'pending'
      `).get().n;

    const shops =
      db.prepare(`
        SELECT COUNT(*) AS n
        FROM shops
      `).get().n;

    const parts =
      db.prepare(`
        SELECT COUNT(*) AS n
        FROM parts
      `).get().n;

    res.json({
      users,
      cars,
      pendingCars,
      payments,
      shops,
      parts
    });
  }
);

/* =========================
   ADMIN USERS
========================= */

app.get(
  "/api/admin/users",
  auth,
  adminOnly,
  (req, res) => {
    const users =
      db.prepare(`
        SELECT
          id,
          name,
          phone,
          email,
          role,
          created_at
        FROM users
        ORDER BY id DESC
      `).all();

    res.json({
      users
    });
  }
);

/* =========================
   ADMIN CARS
========================= */

app.get(
  "/api/admin/cars",
  auth,
  adminOnly,
  (req, res) => {
    const cars =
      db.prepare(`
        SELECT
          c.*,
          u.name AS seller_name,
          u.phone AS seller_phone,
          u.email AS seller_email
        FROM cars c
        JOIN users u
          ON u.id = c.user_id
        ORDER BY c.id DESC
      `).all();

    res.json({
      cars
    });
  }
);

/* =========================
   PUBLISH CAR
========================= */

app.post(
  "/api/admin/cars/:id/publish",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE cars
      SET status = 'published'
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   REJECT CAR
========================= */

app.post(
  "/api/admin/cars/:id/reject",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE cars
      SET status = 'rejected'
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   ADMIN PAYMENTS
========================= */

app.get(
  "/api/admin/payments",
  auth,
  adminOnly,
  (req, res) => {
    const payments =
      db.prepare(`
        SELECT
          p.*,
          c.brand,
          c.model,
          c.image,
          u.name,
          u.phone,
          u.email
        FROM payments p
        LEFT JOIN cars c
          ON c.id = p.car_id
        JOIN users u
          ON u.id = p.user_id
        ORDER BY p.id DESC
      `).all();

    res.json({
      payments
    });
  }
);

/* =========================
   APPROVE PAYMENT
========================= */

app.post(
  "/api/admin/payments/:id/approve",
  auth,
  adminOnly,
  (req, res) => {
    const payment =
      db.prepare(`
        SELECT *
        FROM payments
        WHERE id = ?
      `).get(req.params.id);

    if (!payment) {
      return res.status(404).json({
        error:
          "الدفعة غير موجودة"
      });
    }

    db.prepare(`
      UPDATE payments
      SET status = 'approved'
      WHERE id = ?
    `).run(payment.id);

    if (
      payment.kind === "car" &&
      payment.car_id
    ) {
      db.prepare(`
        UPDATE cars
        SET status = 'published'
        WHERE id = ?
      `).run(payment.car_id);
    }

    res.json({
      ok: true
    });
  }
);

/* =========================
   REJECT PAYMENT
========================= */

app.post(
  "/api/admin/payments/:id/reject",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE payments
      SET status = 'rejected'
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   ADMIN SHOPS
========================= */

app.get(
  "/api/admin/shops",
  auth,
  adminOnly,
  (req, res) => {
    const shops =
      db.prepare(`
        SELECT
          s.*,
          u.email AS account_email
        FROM shops s
        JOIN users u
          ON u.id = s.user_id
        ORDER BY s.id DESC
      `).all();

    res.json({
      shops
    });
  }
);

/* =========================
   APPROVE SHOP
========================= */

app.post(
  "/api/admin/shops/:id/approve",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE shops
      SET
        status = 'approved',
        expires_at =
          datetime('now', '+30 days')
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   REJECT SHOP
========================= */

app.post(
  "/api/admin/shops/:id/reject",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE shops
      SET status = 'rejected'
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   ADMIN PARTS
========================= */

app.get(
  "/api/admin/parts",
  auth,
  adminOnly,
  (req, res) => {
    const parts =
      db.prepare(`
        SELECT
          p.*,
          s.shop_name,
          u.name,
          u.phone,
          u.email
        FROM parts p
        LEFT JOIN shops s
          ON s.id = p.shop_id
        JOIN users u
          ON u.id = p.user_id
        ORDER BY p.id DESC
      `).all();

    res.json({
      parts
    });
  }
);

/* =========================
   PUBLISH PART
========================= */

app.post(
  "/api/admin/parts/:id/publish",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE parts
      SET status = 'published'
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   ADMIN OFFERS
========================= */

app.get(
  "/api/admin/offers",
  auth,
  adminOnly,
  (req, res) => {
    const offers =
      db.prepare(`
        SELECT *
        FROM offers
        ORDER BY id DESC
      `).all();

    res.json({
      offers
    });
  }
);

/* =========================
   CREATE OFFER
========================= */

app.post(
  "/api/admin/offers",
  auth,
  adminOnly,
  (req, res) => {
    const {
      target,
      discount,
      title,
      description,
      color,
      start_at,
      end_at
    } = req.body;

    if (
      !target ||
      !discount ||
      !title ||
      !start_at ||
      !end_at
    ) {
      return res.status(400).json({
        error:
          "أكمل معلومات العرض"
      });
    }

    const result =
      db.prepare(`
        INSERT INTO offers
        (
          target,
          discount,
          title,
          description,
          color,
          start_at,
          end_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `).run(
        target,
        Number(discount),
        title,
        description || "",
        color || "pink",
        start_at,
        end_at
      );

    res.status(201).json({
      id:
        result.lastInsertRowid
    });
  }
);

/* =========================
   DISABLE OFFER
========================= */

app.post(
  "/api/admin/offers/:id/disable",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE offers
      SET active = 0
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   ADD ADMIN
========================= */

app.post(
  "/api/admin/users/:id/admin",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE users
      SET role = 'admin'
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true,
      message:
        "تمت إضافة الأدمن"
    });
  }
);

/* =========================
   REMOVE ADMIN
========================= */

app.post(
  "/api/admin/users/:id/user",
  auth,
  adminOnly,
  (req, res) => {
    const user =
      db.prepare(`
        SELECT role
        FROM users
        WHERE id = ?
      `).get(req.params.id);

    if (
      user &&
      user.role === "owner"
    ) {
      return res.status(403).json({
        error:
          "لا يمكن إزالة المالك"
      });
    }

    db.prepare(`
      UPDATE users
      SET role = 'user'
      WHERE id = ?
    `).run(req.params.id);

    res.json({
      ok: true
    });
  }
);

/* =========================
   FRONTEND FALLBACK
========================= */

app.use(
  (req, res, next) => {
    if (
      req.path.startsWith("/api/")
    ) {
      return res.status(404).json({
        error:
          "المسار غير موجود"
      });
    }

    res.sendFile(
      path.join(
        __dirname,
        "index.html"
      )
    );
  }
);

/* =========================
   ERROR HANDLER
========================= */

app.use(
  (err, req, res, next) => {
    console.error(err);

    res.status(500).json({
      error:
        err.message ||
        "حدث خطأ في الخادم"
    });
  }
);

/* =========================
   START
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
