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

/* =====================================================
   DATABASE
===================================================== */

const db = new Database(
  path.join(DATA_DIR, "bent-al-mosul.db")
);

db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  father_or_nickname TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  email TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cars (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  price INTEGER NOT NULL,
  km INTEGER DEFAULT 0,
  city TEXT NOT NULL,
  fuel TEXT DEFAULT '',
  transmission TEXT DEFAULT '',
  description TEXT DEFAULT '',
  phone TEXT NOT NULL,
  image TEXT,
  plan TEXT DEFAULT 'normal',
  plan_amount INTEGER DEFAULT 10000,
  status TEXT DEFAULT 'pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS parts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  price INTEGER NOT NULL,
  city TEXT NOT NULL,
  description TEXT DEFAULT '',
  phone TEXT NOT NULL,
  image TEXT,
  status TEXT DEFAULT 'pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  shop_name TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  city TEXT NOT NULL,
  logo TEXT,
  plan TEXT DEFAULT 'vip',
  amount INTEGER DEFAULT 50000,
  expires_at TEXT,
  status TEXT DEFAULT 'pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  car_id INTEGER,
  part_id INTEGER,
  shop_id INTEGER,
  kind TEXT NOT NULL,
  amount INTEGER NOT NULL,
  receipt TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sender_id INTEGER NOT NULL,
  receiver_id INTEGER NOT NULL,
  car_id INTEGER,
  part_id INTEGER,
  body TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(sender_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(receiver_id) REFERENCES users(id) ON DELETE CASCADE
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

/* =====================================================
   ADMIN
===================================================== */

const admin = db
  .prepare("SELECT id FROM users WHERE email = ?")
  .get(ADMIN_EMAIL);

if (!admin) {
  const hash = bcrypt.hashSync(ADMIN_PASSWORD, 12);

  db.prepare(`
    INSERT INTO users
    (
      first_name,
      father_or_nickname,
      phone,
      email,
      password_hash,
      role
    )
    VALUES (?, ?, ?, ?, ?, ?)
  `).run(
    "مالك",
    "بنت الموصل",
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

/* =====================================================
   APP
===================================================== */

app.use(
  helmet({
    contentSecurityPolicy: false
  })
);

app.use(cors());
app.use(compression());

app.use(
  express.json({
    limit: "5mb"
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: "5mb"
  })
);

app.use(express.static(__dirname));

app.use(
  "/uploads",
  express.static(UPLOAD_DIR)
);

app.use(
  "/api/",
  rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 300,
    standardHeaders: true,
    legacyHeaders: false
  })
);

/* =====================================================
   UPLOAD
===================================================== */

const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, UPLOAD_DIR);
  },

  filename(req, file, cb) {
    const ext =
      path.extname(file.originalname);

    const filename =
      Date.now() +
      "-" +
      Math.random()
        .toString(36)
        .slice(2) +
      ext;

    cb(null, filename);
  }
});

const upload = multer({
  storage,

  limits: {
    fileSize: 7 * 1024 * 1024
  },

  fileFilter(req, file, cb) {
    const allowed = [
      "image/jpeg",
      "image/png",
      "image/webp"
    ];

    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("نوع الملف غير مسموح"));
    }
  }
});

/* =====================================================
   HELPERS
===================================================== */

function tokenFor(user) {
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
      error: "يجب تسجيل الدخول أولاً"
    });
  }

  try {
    req.user = jwt.verify(
      header.substring(7),
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

function ownerOnly(req, res, next) {
  if (req.user.role !== "owner") {
    return res.status(403).json({
      error: "هذه العملية للمالك فقط"
    });
  }

  next();
}

function validPhone(phone) {
  return /^07\d{9}$/.test(
    String(phone || "").trim()
  );
}

/* =====================================================
   CONFIG
===================================================== */

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

/* =====================================================
   HEALTH
===================================================== */

app.get("/api/health", (req, res) => {
  res.json({
    ok: true,
    app: "بنت الموصل للسيارات"
  });
});

/* =====================================================
   CONFIG
===================================================== */

app.get("/api/config", (req, res) => {
  res.json({
    provinces,
    brands,

    carPlans: [
      {
        id: "normal",
        name: "عادي",
        amount: 10000
      },
      {
        id: "premium",
        name: "مميز",
        amount: 20000
      },
      {
        id: "vip",
        name: "VIP",
        amount: 30000
      }
    ],

    partsNormal: {
      amount: 15000,
      days: 15
    },

    shopVIP: {
      amount: 50000,
      days: 30
    },

    phoneLogin: true,
    guestBrowsing: false
  });
});

/* =====================================================
   REGISTER
===================================================== */

app.post(
  "/api/register",
  async (req, res) => {
    try {
      const {
        first_name,
        father_or_nickname,
        phone,
        email,
        password
      } = req.body;

      if (
        !first_name ||
        !father_or_nickname ||
        !phone ||
        !password
      ) {
        return res.status(400).json({
          error:
            "الاسم الأول واسم الأب أو اللقب ورقم الهاتف وكلمة المرور مطلوبة"
        });
      }

      if (!validPhone(phone)) {
        return res.status(400).json({
          error:
            "رقم الهاتف يجب أن يبدأ بـ07 ويتكون من 11 رقم"
        });
      }

      if (
        String(password).length < 6
      ) {
        return res.status(400).json({
          error:
            "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
        });
      }

      const existing =
        db.prepare(`
          SELECT id
          FROM users
          WHERE phone = ?
             OR (
               email IS NOT NULL
               AND email <> ''
               AND email = ?
             )
        `).get(
          phone.trim(),
          email
            ? email.trim()
            : ""
        );

      if (existing) {
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
          (
            first_name,
            father_or_nickname,
            phone,
            email,
            password_hash
          )
          VALUES (?, ?, ?, ?, ?)
        `).run(
          first_name.trim(),
          father_or_nickname.trim(),
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
            first_name,
            father_or_nickname,
            phone,
            email,
            role
          FROM users
          WHERE id = ?
        `).get(
          result.lastInsertRowid
        );

      res.status(201).json({
        token: tokenFor(user),
        user
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        error:
          "تعذر إنشاء الحساب"
      });
    }
  }
);

/* =====================================================
   LOGIN - EMAIL OR PHONE
===================================================== */

app.post(
  "/api/login",
  async (req, res) => {
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

      if (!user) {
        return res.status(401).json({
          error:
            "بيانات الدخول غير صحيحة"
        });
      }

      const ok =
        await bcrypt.compare(
          password,
          user.password_hash
        );

      if (!ok) {
        return res.status(401).json({
          error:
            "بيانات الدخول غير صحيحة"
        });
      }

      res.json({
        token: tokenFor(user),

        user: {
          id: user.id,
          first_name: user.first_name,
          father_or_nickname:
            user.father_or_nickname,
          phone: user.phone,
          email: user.email,
          role: user.role
        }
      });
    } catch {
      res.status(500).json({
        error:
          "تعذر تسجيل الدخول"
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
          first_name,
          father_or_nickname,
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
        error: "المستخدم غير موجود"
      });
    }

    res.json({
      user
    });
  }
);

/* =====================================================
   CARS LIST
===================================================== */

app.get(
  "/api/cars",
  (req, res) => {
    let sql = `
      SELECT
        c.*,
        u.first_name,
        u.father_or_nickname,
        u.phone AS account_phone
      FROM cars c
      JOIN users u
        ON u.id = c.user_id
      WHERE c.status = 'published'
    `;

    const params = [];

    if (req.query.brand) {
      sql +=
        " AND c.brand = ?";
      params.push(
        req.query.brand
      );
    }

    if (req.query.city) {
      sql +=
        " AND c.city = ?";
      params.push(
        req.query.city
      );
    }

    if (req.query.search) {
      const q =
        "%" +
        req.query.search +
        "%";

      sql += `
        AND (
          c.brand LIKE ?
          OR c.model LIKE ?
          OR c.description LIKE ?
        )
      `;

      params.push(
        q,
        q,
        q
      );
    }

    sql += `
      ORDER BY
        CASE
          WHEN c.plan = 'vip'
          THEN 3
          WHEN c.plan = 'premium'
          THEN 2
          ELSE 1
        END DESC,
        c.id DESC
    `;

    res.json({
      cars:
        db
          .prepare(sql)
          .all(...params)
    });
  }
);

/* =====================================================
   SINGLE CAR
===================================================== */

app.get(
  "/api/cars/:id",
  (req, res) => {
    const car =
      db.prepare(`
        SELECT
          c.*,
          u.first_name,
          u.father_or_nickname,
          u.phone AS account_phone
        FROM cars c
        JOIN users u
          ON u.id = c.user_id
        WHERE c.id = ?
          AND c.status = 'published'
      `).get(
        req.params.id
      );

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

/* =====================================================
   ADD CAR
===================================================== */

app.post(
  "/api/cars",
  auth,
  upload.single("image"),
  (req, res) => {
    try {
      const {
        brand,
        model,
        year,
        price,
        km,
        city,
        fuel,
        transmission,
        description,
        phone,
        plan
      } = req.body;

      if (
        !brand ||
        !model ||
        !year ||
        !price ||
        !city ||
        !phone
      ) {
        return res.status(400).json({
          error:
            "أكمل جميع المعلومات ورقم التواصل إجباري"
        });
      }

      if (!validPhone(phone)) {
        return res.status(400).json({
          error:
            "رقم التواصل غير صحيح"
        });
      }

      const selectedPlan =
        ["normal", "premium", "vip"]
          .includes(plan)
          ? plan
          : "normal";

      const amounts = {
        normal: 10000,
        premium: 20000,
        vip: 30000
      };

      const isAdmin =
        ["owner", "admin"].includes(
          req.user.role
        );

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
            phone,
            image,
            plan,
            plan_amount,
            status
          )
          VALUES
          (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          req.user.sub,
          brand.trim(),
          model.trim(),
          Number(year),
          Number(price),
          Number(km || 0),
          city.trim(),
          fuel || "",
          transmission || "",
          description || "",
          phone.trim(),

          req.file
            ? "/uploads/" +
              req.file.filename
            : null,

          selectedPlan,
          amounts[selectedPlan],

          isAdmin
            ? "published"
            : "pending"
        );

      res.status(201).json({
        id:
          result.lastInsertRowid,

        status:
          isAdmin
            ? "published"
            : "pending",

        message:
          isAdmin
            ? "تم نشر السيارة"
            : "تم إرسال السيارة للمراجعة"
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        error:
          "تعذر نشر السيارة"
      });
    }
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
      cars
    });
  }
);

/* =====================================================
   PARTS LIST
===================================================== */

app.get(
  "/api/parts",
  (req, res) => {
    let sql = `
      SELECT
        p.*,
        u.first_name,
        u.father_or_nickname
      FROM parts p
      JOIN users u
        ON u.id = p.user_id
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

    if (req.query.search) {
      const q =
        "%" +
        req.query.search +
        "%";

      sql += `
        AND (
          p.name LIKE ?
          OR p.description LIKE ?
        )
      `;

      params.push(
        q,
        q
      );
    }

    sql +=
      " ORDER BY p.id DESC";

    res.json({
      parts:
        db
          .prepare(sql)
          .all(...params)
    });
  }
);

/* =====================================================
   ADD PART
   NORMAL = 15,000 / 15 DAYS
===================================================== */

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
        description,
        phone
      } = req.body;

      if (
        !name ||
        !price ||
        !city ||
        !phone
      ) {
        return res.status(400).json({
          error:
            "أكمل بيانات قطعة الغيار ورقم التواصل"
        });
      }

      if (!validPhone(phone)) {
        return res.status(400).json({
          error:
            "رقم التواصل غير صحيح"
        });
      }

      const result =
        db.prepare(`
          INSERT INTO parts
          (
            user_id,
            name,
            price,
            city,
            description,
            phone,
            image,
            status
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          req.user.sub,
          name.trim(),
          Number(price),
          city.trim(),
          description || "",
          phone.trim(),

          req.file
            ? "/uploads/" +
              req.file.filename
            : null,

          "pending"
        );

      res.status(201).json({
        id:
          result.lastInsertRowid,

        amount: 15000,
        days: 15,

        message:
          "تم إنشاء إعلان قطع الغيار، أرسل إثبات دفع 15,000 دينار"
      });
    } catch {
      res.status(500).json({
        error:
          "تعذر إنشاء إعلان قطع الغيار"
      });
    }
  }
);

/* =====================================================
   CREATE VIP SHOP ACCOUNT
   SHOP MUST HAVE SEPARATE EMAIL
===================================================== */

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
        !email ||
        !city
      ) {
        return res.status(400).json({
          error:
            "حساب المحل يحتاج اسم المحل واسم صاحب المحل ورقم الهاتف وGmail جديد"
        });
      }

      if (!validPhone(phone)) {
        return res.status(400).json({
          error:
            "رقم الهاتف غير صحيح"
        });
      }

      const emailUsed =
        db.prepare(`
          SELECT id
          FROM shops
          WHERE email = ?
        `).get(
          email.trim()
        );

      if (emailUsed) {
        return res.status(409).json({
          error:
            "Gmail المحل مستخدم مسبقاً"
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
          shop_name.trim(),
          owner_name.trim(),
          phone.trim(),
          email.trim(),
          city.trim(),

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

        amount: 50000,
        days: 30,

        message:
          "تم إرسال طلب حساب المحل VIP للإدارة"
      });
    } catch {
      res.status(500).json({
        error:
          "تعذر إنشاء حساب المحل"
      });
    }
  }
);

/* =====================================================
   PAYMENT
===================================================== */

app.post(
  "/api/payments",
  auth,
  upload.single("receipt"),
  (req, res) => {
    try {
      const {
        kind,
        amount,
        car_id,
        part_id,
        shop_id
      } = req.body;

      const validAmounts = [
        10000,
        20000,
        30000,
        15000,
        50000
      ];

      const numericAmount =
        Number(amount);

      if (
        !validAmounts.includes(
          numericAmount
        )
      ) {
        return res.status(400).json({
          error:
            "قيمة الدفع غير صحيحة"
        });
      }

      if (!req.file) {
        return res.status(400).json({
          error:
            "صورة الوصل مطلوبة"
        });
      }

      const result =
        db.prepare(`
          INSERT INTO payments
          (
            user_id,
            car_id,
            part_id,
            shop_id,
            kind,
            amount,
            receipt
          )
          VALUES (?, ?, ?, ?, ?, ?, ?)
        `).run(
          req.user.sub,

          car_id
            ? Number(car_id)
            : null,

          part_id
            ? Number(part_id)
            : null,

          shop_id
            ? Number(shop_id)
            : null,

          kind || "unknown",
          numericAmount,

          "/uploads/" +
            req.file.filename
        );

      res.status(201).json({
        payment_id:
          result.lastInsertRowid,

        message:
          "تم إرسال الوصل للإدارة للمراجعة"
      });
    } catch {
      res.status(500).json({
        error:
          "تعذر إرسال الدفع"
      });
    }
  }
);

/* =====================================================
   SEND MESSAGE
===================================================== */

app.post(
  "/api/messages",
  auth,
  (req, res) => {
    try {
      const {
        receiver_id,
        car_id,
        part_id,
        body
      } = req.body;

      if (
        !receiver_id ||
        !body
      ) {
        return res.status(400).json({
          error:
            "الرسالة والمستلم مطلوبة"
        });
      }

      const receiver =
        db.prepare(`
          SELECT id
          FROM users
          WHERE id = ?
        `).get(
          Number(receiver_id)
        );

      if (!receiver) {
        return res.status(404).json({
          error:
            "البائع غير موجود"
        });
      }

      const result =
        db.prepare(`
          INSERT INTO messages
          (
            sender_id,
            receiver_id,
            car_id,
            part_id,
            body
          )
          VALUES (?, ?, ?, ?, ?)
        `).run(
          req.user.sub,
          Number(receiver_id),

          car_id
            ? Number(car_id)
            : null,

          part_id
            ? Number(part_id)
            : null,

          String(body).trim()
        );

      res.status(201).json({
        id:
          result.lastInsertRowid,

        message:
          "تم إرسال الرسالة"
      });
    } catch {
      res.status(500).json({
        error:
          "تعذر إرسال الرسالة"
      });
    }
  }
);

/* =====================================================
   MY MESSAGES
===================================================== */

app.get(
  "/api/messages",
  auth,
  (req, res) => {
    const messages =
      db.prepare(`
        SELECT
          m.*,

          s.first_name AS sender_first_name,
          s.father_or_nickname AS sender_family,

          r.first_name AS receiver_first_name,
          r.father_or_nickname AS receiver_family

        FROM messages m

        JOIN users s
          ON s.id = m.sender_id

        JOIN users r
          ON r.id = m.receiver_id

        WHERE
          m.sender_id = ?
          OR m.receiver_id = ?

        ORDER BY m.id ASC
      `).all(
        req.user.sub,
        req.user.sub
      );

    res.json({
      messages
    });
  }
);

/* =====================================================
   ADMIN STATISTICS
===================================================== */

app.get(
  "/api/admin/stats",
  auth,
  adminOnly,
  (req, res) => {
    const users =
      db.prepare(`
        SELECT COUNT(*) AS count
        FROM users
        WHERE role IN ('user','admin')
      `).get().count;

    const cars =
      db.prepare(`
        SELECT COUNT(*) AS count
        FROM cars
      `).get().count;

    const publishedCars =
      db.prepare(`
        SELECT COUNT(*) AS count
        FROM cars
        WHERE status = 'published'
      `).get().count;

    const pendingCars =
      db.prepare(`
        SELECT COUNT(*) AS count
        FROM cars
        WHERE status = 'pending'
      `).get().count;

    const parts =
      db.prepare(`
        SELECT COUNT(*) AS count
        FROM parts
      `).get().count;

    const shops =
      db.prepare(`
        SELECT COUNT(*) AS count
        FROM shops
      `).get().count;

    const payments =
      db.prepare(`
        SELECT COUNT(*) AS count
        FROM payments
        WHERE status = 'pending'
      `).get().count;

    res.json({
      users,
      cars,
      publishedCars,
      pendingCars,
      parts,
      shops,
      pendingPayments: payments
    });
  }
);

/* =====================================================
   ADMIN USERS
===================================================== */

app.get(
  "/api/admin/users",
  auth,
  adminOnly,
  (req, res) => {
    const users =
      db.prepare(`
        SELECT
          id,
          first_name,
          father_or_nickname,
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

/* =====================================================
   OWNER ADD ADMIN
===================================================== */

app.post(
  "/api/admin/admins",
  auth,
  ownerOnly,
  async (req, res) => {
    try {
      const {
        first_name,
        father_or_nickname,
        phone,
        email,
        password
      } = req.body;

      if (
        !first_name ||
        !father_or_nickname ||
        !phone ||
        !email ||
        !password
      ) {
        return res.status(400).json({
          error:
            "أكمل بيانات الأدمن"
        });
      }

      if (!validPhone(phone)) {
        return res.status(400).json({
          error:
            "رقم الهاتف غير صحيح"
        });
      }

      const existing =
        db.prepare(`
          SELECT id
          FROM users
          WHERE phone = ?
             OR email = ?
        `).get(
          phone.trim(),
          email.trim()
        );

      if (existing) {
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
          (
            first_name,
            father_or_nickname,
            phone,
            email,
            password_hash,
            role
          )
          VALUES (?, ?, ?, ?, ?, ?)
        `).run(
          first_name.trim(),
          father_or_nickname.trim(),
          phone.trim(),
          email.trim(),
          hash,
          "admin"
        );

      res.status(201).json({
        id:
          result.lastInsertRowid,

        message:
          "تمت إضافة الأدمن"
      });
    } catch {
      res.status(500).json({
        error:
          "تعذر إضافة الأدمن"
      });
    }
  }
);

/* =====================================================
   ADMIN CAR MODERATION
===================================================== */

app.get(
  "/api/admin/cars",
  auth,
  adminOnly,
  (req, res) => {
    const cars =
      db.prepare(`
        SELECT
          c.*,
          u.first_name,
          u.father_or_nickname,
          u.phone AS account_phone
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

app.post(
  "/api/admin/cars/:id/publish",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE cars
      SET status = 'published'
      WHERE id = ?
    `).run(
      Number(req.params.id)
    );

    res.json({
      message:
        "تم نشر السيارة"
    });
  }
);

app.post(
  "/api/admin/cars/:id/reject",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE cars
      SET status = 'rejected'
      WHERE id = ?
    `).run(
      Number(req.params.id)
    );

    res.json({
      message:
        "تم رفض السيارة"
    });
  }
);

/* =====================================================
   ADMIN PARTS
===================================================== */

app.get(
  "/api/admin/parts",
  auth,
  adminOnly,
  (req, res) => {
    const parts =
      db.prepare(`
        SELECT
          p.*,
          u.first_name,
          u.father_or_nickname
        FROM parts p
        JOIN users u
          ON u.id = p.user_id
        ORDER BY p.id DESC
      `).all();

    res.json({
      parts
    });
  }
);

app.post(
  "/api/admin/parts/:id/publish",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE parts
      SET status = 'published'
      WHERE id = ?
    `).run(
      Number(req.params.id)
    );

    res.json({
      message:
        "تم نشر قطعة الغيار"
    });
  }
);

app.post(
  "/api/admin/parts/:id/reject",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      UPDATE parts
      SET status = 'rejected'
      WHERE id = ?
    `).run(
      Number(req.params.id)
    );

    res.json({
      message:
        "تم رفض قطعة الغيار"
    });
  }
);

/* =====================================================
   ADMIN PAYMENTS
===================================================== */

app.get(
  "/api/admin/payments",
  auth,
  adminOnly,
  (req, res) => {
    const payments =
      db.prepare(`
        SELECT
          p.*,
          u.first_name,
          u.father_or_nickname,
          u.phone
        FROM payments p
        JOIN users u
          ON u.id = p.user_id
        ORDER BY p.id DESC
      `).all();

    res.json({
      payments
    });
  }
);

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
      `).get(
        Number(req.params.id)
      );

    if (!payment) {
      return res.status(404).json({
        error:
          "الدفع غير موجود"
      });
    }

    db.prepare(`
      UPDATE payments
      SET status = 'approved'
      WHERE id = ?
    `).run(
      payment.id
    );

    if (
      payment.kind === "car" &&
      payment.car_id
    ) {
      db.prepare(`
        UPDATE cars
        SET status = 'published'
        WHERE id = ?
      `).run(
        payment.car_id
      );
    }

    if (
      payment.kind === "part" &&
      payment.part_id
    ) {
      db.prepare(`
        UPDATE parts
        SET status = 'published'
        WHERE id = ?
      `).run(
        payment.part_id
      );
    }

    if (
      payment.kind === "shop" &&
      payment.shop_id
    ) {
      const expires =
        new Date();

      expires.setDate(
        expires.getDate() + 30
      );

      db.prepare(`
        UPDATE shops
        SET
          status = 'approved',
          expires_at = ?
        WHERE id = ?
      `).run(
        expires.toISOString(),
        payment.shop_id
      );
    }

    res.json({
      message:
        "تمت الموافقة على الدفع"
    });
  }
);

/* =====================================================
   OFFERS
===================================================== */

app.get(
  "/api/offers",
  (req, res) => {
    const now =
      new Date().toISOString();

    const offers =
      db.prepare(`
        SELECT *
        FROM offers
        WHERE active = 1
          AND start_at <= ?
          AND end_at >= ?
        ORDER BY id DESC
      `).all(
        now,
        now
      );

    res.json({
      offers
    });
  }
);

/* =====================================================
   CREATE OFFER
===================================================== */

app.post(
  "/api/admin/offers",
  auth,
  adminOnly,
  (req, res) => {
    try {
      const {
        target,
        discount,
        title,
        description,
        color,
        start_at,
        end_at
      } = req.body;

      const targets = [
        "cars",
        "dealers",
        "parts",
        "vip"
      ];

      if (
        !targets.includes(target)
      ) {
        return res.status(400).json({
          error:
            "نوع العرض غير صحيح"
        });
      }

      if (
        !title ||
        !start_at ||
        !end_at
      ) {
        return res.status(400).json({
          error:
            "العنوان ووقت البداية والنهاية مطلوبة"
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
          Number(discount || 0),
          title.trim(),
          description || "",
          color || "pink",
          start_at,
          end_at
        );

      res.status(201).json({
        id:
          result.lastInsertRowid,

        message:
          "تم إنشاء العرض"
      });
    } catch {
      res.status(500).json({
        error:
          "تعذر إنشاء العرض"
      });
    }
  }
);

/* =====================================================
   ADMIN OFFERS
===================================================== */

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

app.delete(
  "/api/admin/offers/:id",
  auth,
  adminOnly,
  (req, res) => {
    db.prepare(`
      DELETE FROM offers
      WHERE id = ?
    `).run(
      Number(req.params.id)
    );

    res.json({
      message:
        "تم حذف العرض"
    });
  }
);

/* =====================================================
   ADMIN SHOPS
===================================================== */

app.get(
  "/api/admin/shops",
  auth,
  adminOnly,
  (req, res) => {
    const shops =
      db.prepare(`
        SELECT
          s.*,
          u.first_name,
          u.father_or_nickname
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

/* =====================================================
   ADMIN DELETE USER
===================================================== */

app.delete(
  "/api/admin/users/:id",
  auth,
  ownerOnly,
  (req, res) => {
    const id =
      Number(req.params.id);

    const user =
      db.prepare(`
        SELECT role
        FROM users
        WHERE id = ?
      `).get(id);

    if (!user) {
      return res.status(404).json({
        error:
          "المستخدم غير موجود"
      });
    }

    if (user.role === "owner") {
      return res.status(403).json({
        error:
          "لا يمكن حذف المالك"
      });
    }

    db.prepare(`
      DELETE FROM users
      WHERE id = ?
    `).run(id);

    res.json({
      message:
        "تم حذف المستخدم"
    });
  }
);

/* =====================================================
   404
===================================================== */

app.use(
  "/api",
  (req, res) => {
    res.status(404).json({
      error:
        "API غير موجود"
    });
  }
);

/* =====================================================
   ERROR
===================================================== */

app.use(
  (err, req, res, next) => {
    console.error(err);

    res.status(500).json({
      error:
        err.message ||
        "حدث خطأ في السيرفر"
    });
  }
);

/* =====================================================
   START
===================================================== */

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      `بنت الموصل للسيارات تعمل على المنفذ ${PORT}`
    );
  }
);
