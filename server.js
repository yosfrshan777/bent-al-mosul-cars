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
  process.env.JWT_SECRET || "CHANGE_THIS_SECRET_IN_RENDER";

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
   ADMIN
========================= */

function seedAdmin() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    console.log(
      "ADMIN_EMAIL / ADMIN_PASSWORD غير موجودة"
    );
    return;
  }

  const existing = db
    .prepare(
      "SELECT id FROM users WHERE email = ?"
    )
    .get(email);

  if (!existing) {
    const hash = bcrypt.hashSync(password, 12);

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
    limit: "200kb"
  })
);

app.use(
  express.urlencoded({
    extended: false,
    limit: "200kb"
  })
);

/* =========================
   STATIC FILES
========================= */

app.use(
  "/uploads",
  express.static(UPLOAD_DIR)
);

app.use(
  express.static(PUBLIC_DIR)
);

/* =========================
   RATE LIMIT
========================= */

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 300,
  standardHeaders: true,
  legacyHeaders: false
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 30,
  standardHeaders: true,
  legacyHeaders: false
});

app.use("/api/", apiLimiter);

/* =========================
   FILE UPLOAD
========================= */

const storage =
  multer.diskStorage({

    destination: (req, file, cb) => {
      cb(null, UPLOAD_DIR);
    },

    filename: (req, file, cb) => {
      const ext =
        path.extname(
          file.originalname
        ).toLowerCase();

      const safeExt = [
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
      ].includes(ext)
        ? ext
        : ".jpg";

      const filename =
        Date.now() +
        "-" +
        Math.random()
          .toString(36)
          .slice(2) +
        safeExt;

      cb(null, filename);
    }
  });

const upload = multer({

  storage,

  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 2
  },

  fileFilter: (req, file, cb) => {

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
      sub: Number(user.id),
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

  if (
    !header.startsWith("Bearer ")
  ) {
    return res.status(401).json({
      error:
        "تسجيل الدخول مطلوب"
    });
  }

  const token =
    header.slice(7).trim();

  try {

    const decoded =
      jwt.verify(
        token,
        JWT_SECRET
      );

    req.user = decoded;

    next();

  } catch (error) {

    return res.status(401).json({
      error:
        "جلسة غير صالحة أو منتهية"
    });
  }
}

function admin(req, res, next) {

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

/* =========================
   VALIDATION
========================= */

const registerSchema =
  z.object({

    name:
      z.string()
        .trim()
