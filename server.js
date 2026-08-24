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
const JWT_SECRET = process.env.JWT_SECRET || "DEV_ONLY_CHANGE_ME";

const DATA_DIR = path.join(__dirname, "data");
const UPLOAD_DIR = path.join(__dirname, "uploads");
const PUBLIC_DIR = path.join(__dirname, "public");

fs.mkdirSync(DATA_DIR, { recursive: true });
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const db = new Database(path.join(DATA_DIR, "cars.db"));

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
  fuel TEXT,
  transmission TEXT,
  description TEXT,
  plan INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  image TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
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
  FOREIGN KEY(car_id) REFERENCES cars(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
`);

try {
  db.prepare("ALTER TABLE payments ADD COLUMN receipt TEXT").run();
} catch {}

function seedAdmin() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) return;

  const existing = db
    .prepare("SELECT id FROM users WHERE email = ?")
    .get(email);

  if (!existing) {
    const hash = bcrypt.hashSync(password, 12);

    db.prepare(`
      INSERT INTO users
      (name, phone, email, password_hash, role)
      VALUES (?, ?, ?, ?, ?)
    `).run(
      "مدير بنت الموصل",
      "00000000000",
      email,
      hash,
      "admin"
    );

    console.log("Admin created:", email);
  }
}

seedAdmin();

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

app.use(express.json({ limit: "100kb" }));

app.use(
  express.urlencoded({
    extended: false,
    limit: "100kb"
  })
);

app.use(
  "/uploads",
  express.static(UPLOAD_DIR)
);

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

app.use("/api/", apiLimiter);

const upload = multer({
  storage: multer.diskStorage({
    destination: (_, __, cb) => {
      cb(null, UPLOAD_DIR);
    },

    filename: (_, file, cb) => {
      const ext = path.extname(file.originalname).toLowerCase();

      cb(
        null,
        Date.now() +
          "-" +
          Math.random().toString(36).slice(2) +
          ext
      );
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

    cb(null, allowed.includes(file.mimetype));
  }
});

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

function auth(req, res, next) {
  const header = req.headers.authorization || "";

  if (!header.startsWith("Bearer ")) {
    return res.status(401).json({
      error: "تسجيل الدخول مطلوب"
    });
  }

  try {
    req.user = jwt.verify(
      header.slice(7),
      JWT_SECRET
    );

    next();
  } catch {
    return res.status(401).json({
      error: "جلسة غير صالحة"
    });
  }
}

function admin(req, res, next) {
  if (req.user.role !== "admin") {
    return res.status(403).json({
      error: "صلاحية الإدارة مطلوبة"
    });
  }

  next();
}

const registerSchema = z.object({
  name: z
    .string()
    .trim()
    .min(2)
    .max(80),

  phone: z
    .string()
    .trim()
    .regex(/^07\d{9}$/),

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
    .max(new Date().getFullYear() + 1),

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
    .refine((v) =>
      [10000, 20000, 30000].includes(v)
    )
});

app.post(
  "/api/register",
  authLimiter,
  async (req, res) => {
    const result =
      registerSchema.safeParse(req.body);

    if (!result.success) {
      return res.status(400).json({
        error: "بيانات التسجيل غير صحيحة"
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
        await bcrypt.hash(password, 12);

      const r = db
        .prepare(`
          INSERT INTO users
          (name, phone, email, password_hash)
          VALUES (?, ?, ?, ?)
        `)
        .run(
          name,
          phone,
          email || null,
          hash
        );

      const user = {
        id: Number(r.lastInsertRowid),
        name,
        phone,
        email: email || null,
        role: "user"
      };

      res.json({
        token: sign(user),
        user
      });

    } catch (error) {
      console.error(error);

      res.status(409).json({
        error:
          "رقم الهاتف أو البريد مستخدم مسبقاً"
      });
    }
  }
);

app.post(
  "/api/login",
  authLimiter,
  async (req, res) => {
    const phone =
      String(req.body.phone || "").trim();

    const password =
      String(req.body.password || "");

    const user = db
      .prepare(
        "SELECT * FROM users WHERE phone = ?"
      )
      .get(phone);

    if (
      !user ||
      !(await bcrypt.compare(
        password,
        user.password_hash
      ))
    ) {
      return res.status(401).json({
        error: "بيانات الدخول غير صحيحة"
      });
    }

    res.json({
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

app.get("/api/cars", (req, res) => {
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
      JOIN users u ON u.id = c.user_id
      WHERE c.status = 'approved'
      ORDER BY c.plan DESC, c.created_at DESC
    `)
    .all();

  res.json(cars);
});

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
      carSchema.safeParse(req.body);

    if (!result.success) {
      return res.status(400).json({
        error: "بيانات السيارة غير صحيحة"
      });
    }

    const data = result.data;

    const imageFile =
      req.files?.image?.[0] || null;

    const receiptFile =
      req.files?.receipt?.[0] || null;

    const image = imageFile
      ? `/uploads/${imageFile.filename}`
      : null;

    const receipt = receiptFile
      ? `/uploads/${receiptFile.filename}`
      : null;

    try {
      const transaction =
        db.transaction(() => {
          const car = db
            .prepare(`
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
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            `)
            .run(
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
            Number(car.lastInsertRowid);

          db.prepare(`
            INSERT INTO payments
            (
              car_id,
              user_id,
              amount,
              status,
              receipt
            )
            VALUES (?, ?, ?, 'pending', ?)
          `).run(
            carId,
            req.user.sub,
            data.plan,
            receipt
          );

          return carId;
        });

      const carId = transaction();

      res.json({
        ok: true,
        message:
          "تم إرسال الإعلان للمراجعة",
        carId
      });

    } catch (error) {
      console.error(error);

      res.status(500).json({
        error: "تعذر حفظ الإعلان"
      });
    }
  }
);

app.get(
  "/api/my-cars",
  auth,
  (req, res) => {
    const cars = db
      .prepare(`
        SELECT *
        FROM cars
        WHERE user_id = ?
        ORDER BY id DESC
      `)
      .all(req.user.sub);

    res.json(c
