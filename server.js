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
const ORIGIN = process.env.CORS_ORIGIN || `http://localhost:${PORT}`;
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
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(car_id) REFERENCES cars(id) ON DELETE CASCADE,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
`);

function seedAdmin() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  if (!email || !password) return;
  const existing = db.prepare("SELECT id FROM users WHERE email=?").get(email);
  if (!existing) {
    const hash = bcrypt.hashSync(password, 12);
    db.prepare("INSERT INTO users(name,phone,email,password_hash,role) VALUES(?,?,?,?,?)")
      .run("مدير بنت الموصل", "00000000000", email, hash, "admin");
    console.log("Admin created:", email);
  }
}
seedAdmin();

app.disable("x-powered-by");
app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
app.use(cors({ origin: ORIGIN, credentials: true }));
app.use(compression());
app.use(express.json({ limit: "100kb" }));
app.use(express.urlencoded({ extended: false, limit: "100kb" }));
app.use("/uploads", express.static(UPLOAD_DIR, { maxAge: "7d" }));

const apiLimiter = rateLimit({ windowMs: 15*60*1000, limit: 200, standardHeaders: true, legacyHeaders: false });
const authLimiter = rateLimit({ windowMs: 15*60*1000, limit: 20, standardHeaders: true, legacyHeaders: false });
app.use("/api/", apiLimiter);

const upload = multer({
  storage: multer.diskStorage({
    destination: (_,__,cb)=>cb(null, UPLOAD_DIR),
    filename: (_,file,cb)=>cb(null, `${Date.now()}-${Math.random().toString(36).slice(2)}${path.extname(file.originalname).toLowerCase()}`)
  }),
  limits: { fileSize: 5*1024*1024, files: 1 },
  fileFilter: (_, file, cb) => cb(null, ["image/jpeg","image/png","image/webp"].includes(file.mimetype))
});

function sign(user) {
  return jwt.sign({ sub:user.id, role:user.role }, JWT_SECRET, { expiresIn:"7d" });
}
function auth(req,res,next) {
  const h=req.headers.authorization||"";
  if(!h.startsWith("Bearer ")) return res.status(401).json({error:"تسجيل الدخول مطلوب"});
  try { req.user=jwt.verify(h.slice(7), JWT_SECRET); next(); }
  catch { return res.status(401).json({error:"جلسة غير صالحة"}); }
}
function admin(req,res,next) {
  if(req.user.role!=="admin") return res.status(403).json({error:"صلاحية الإدارة مطلوبة"});
  next();
}

const registerSchema = z.object({
  name:z.string().trim().min(2).max(80),
  phone:z.string().trim().regex(/^07\d{9}$/),
  email:z.string().trim().email().max(120).optional().or(z.literal("")),
  password:z.string().min(8).max(100)
});
const carSchema = z.object({
  brand:z.string().trim().min(2).max(40),
  model:z.string().trim().min(1).max(60),
  year:z.coerce.number().int().min(1980).max(new Date().getFullYear()+1),
  price:z.coerce.number().int().min(100000).max(1000000000),
  km:z.coerce.number().int().min(0).max(2000000),
  city:z.string().trim().min(2).max(40),
  fuel:z.string().trim().max(30).optional(),
  transmission:z.string().trim().max(30).optional(),
  description:z.string().trim().max(1000).optional(),
  plan:z.coerce.number().refine(v=>[10000,20000,30000].includes(v))
});

app.post("/api/register", authLimiter, async (req,res)=>{
  const p=registerSchema.safeParse(req.body);
  if(!p.success) return res.status(400).json({error:"بيانات التسجيل غير صحيحة"});
  const {name,phone,email,password}=p.data;
  try {
    const hash=await bcrypt.hash(password,12);
    const r=db.prepare("INSERT INTO users(name,phone,email,password_hash) VALUES(?,?,?,?)")
      .run(name,phone,email||null,hash);
    const user={id:r.lastInsertRowid,role:"user"};
    res.json({token:sign(user),user:{id:user.id,name,phone,email:email||null}});
  } catch { res.status(409).json({error:"رقم الهاتف أو البريد مستخدم مسبقاً"}); }
});

app.post("/api/login", authLimiter, async (req,res)=>{
  const phone=String(req.body.phone||"").trim(), password=String(req.body.password||"");
  const u=db.prepare("SELECT * FROM users WHERE phone=?").get(phone);
  if(!u || !(await bcrypt.compare(password,u.password_hash))) return res.status(401).json({error:"بيانات الدخول غير صحيحة"});
  res.json({token:sign(u),user:{id:u.id,name:u.name,phone:u.phone,email:u.email,role:u.role}});
});

app.get("/api/cars", (req,res)=>{
  const rows=db.prepare(`
    SELECT c.id,c.brand,c.model,c.year,c.price,c.km,c.city,c.fuel,c.transmission,c.description,
           c.plan,c.image,c.created_at,u.name AS seller_name,u.phone AS seller_phone
    FROM cars c JOIN users u ON u.id=c.user_id
    WHERE c.status='approved'
    ORDER BY c.plan DESC,c.created_at DESC`).all();
  res.json(rows);
});

app.post("/api/cars", auth, upload.single("image"), (req,res)=>{
  const p=carSchema.safeParse(req.body);
  if(!p.success) { if(req.file) fs.unlinkSync(req.file.path); return res.status(400).json({error:"بيانات السيارة غير صحيحة"}); }
  const d=p.data;
  const image=req.file ? `/uploads/${req.file.filename}` : null;
  const tx=db.transaction(()=>{
    const r=db.prepare(`INSERT INTO cars(user_id,brand,model,year,price,km,city,fuel,transmission,description,plan,status,image)
      VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)`).run(req.user.sub,d.brand,d.model,d.year,d.price,d.km,d.city,d.fuel||"",d.transmission||"",d.description||"",d.plan,"pending",image);
    db.prepare("INSERT INTO payments(car_id,user_id,amount,status) VALUES(?,?,?,'pending')").run(r.lastInsertRowid,req.user.sub,d.plan);
    return r.lastInsertRowid;
  });
  res.json({message:"تم إرسال الإعلان للمراجعة وإنشاء طلب الدفع",carId:tx()});
});

app.get("/api/my-cars", auth, (req,res)=>{
  res.json(db.prepare("SELECT * FROM cars WHERE user_id=? ORDER BY id DESC").all(req.user.sub));
});

app.get("/api/admin/cars", auth, admin, (req,res)=>{
  res.json(db.prepare(`SELECT c.*,u.name AS seller_name,u.phone AS seller_phone
    FROM cars c JOIN users u ON u.id=c.user_id ORDER BY c.id DESC`).all());
});

app.post("/api/admin/cars/:id/approve", auth, admin, (req,res)=>{
  db.prepare("UPDATE cars SET status='approved' WHERE id=?").run(Number(req.params.id));
  db.prepare("UPDATE payments SET status='paid' WHERE car_id=?").run(Number(req.params.id));
  res.json({ok:true});
});

app.delete("/api/admin/cars/:id", auth, admin, (req,res)=>{
  const c=db.prepare("SELECT image FROM cars WHERE id=?").get(Number(req.params.id));
  if(c?.image) { const f=path.join(__dirname,c.image.replace(/^\/+/,"")); if(fs.existsSync(f)) fs.unlinkSync(f); }
  db.prepare("DELETE FROM cars WHERE id=?").run(Number(req.params.id));
  res.json({ok:true});
});

app.get("/api/health",(req,res)=>res.json({ok:true,service:"bent-al-mosul-cars"}));

app.use(express.static(path.join(__dirname,"public")));
app.get("*",(req,res)=>res.sendFile(path.join(__dirname,"public","index.html")));

app.listen(PORT,()=>console.log(`بنت الموصل للسيارات تعمل على http://localhost:${PORT}`));
