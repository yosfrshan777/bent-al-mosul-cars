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
    .prepare("SELECT id FROM users WHERE email=?")
    .get(email);

  if (!existing) {
    const hash = bcrypt.hashSync(password, 12);

    db.prepare(`
      INSERT INTO users(name,phone,email,password_hash,role)
      VALUES(?,?,?,?,?)
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

seed
