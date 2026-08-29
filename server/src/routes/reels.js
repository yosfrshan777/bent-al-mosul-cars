const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { pool } = require('../db');
const { auth } = require('../middleware/auth');

const router = express.Router();
const uploadDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });
const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, uploadDir),
  filename: (_, file, cb) => cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${path.extname(file.originalname).toLowerCase()}`),
});
const upload = multer({
  storage,
  limits: { fileSize: 80 * 1024 * 1024 },
  fileFilter: (_, file, cb) => cb(null, ['video/mp4', 'video/webm', 'video/quicktime'].includes(file.mimetype)),
});

router.get('/', async (_, res) => {
  try {
    const [rows] = await pool.execute(`SELECT r.id,r.video_url,r.caption,r.city,r.price,r.created_at,c.brand,c.model,c.year,u.name AS seller_name FROM reels r LEFT JOIN cars c ON c.id=r.car_id LEFT JOIN users u ON u.id=r.user_id WHERE r.status='approved' ORDER BY r.id DESC LIMIT 50`);
    res.json(rows);
  } catch (e) {
    console.error('REELS GET ERROR:', e);
    res.status(500).json({ message: 'تعذر تحميل الريلز' });
  }
});

router.post('/', auth, upload.single('video'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'أرسل فيديو MP4 أو WebM' });
    const carId = req.body.car_id ? Number(req.body.car_id) : null;
    const price = req.body.price ? Number(req.body.price) : null;
    const [result] = await pool.execute(`INSERT INTO reels (user_id,car_id,video_url,caption,city,price,status) VALUES (?,?,?,?,?,?,'pending')`, [req.user.id, Number.isInteger(carId) ? carId : null, `/uploads/${req.file.filename}`, String(req.body.caption || '').trim(), String(req.body.city || '').trim(), Number.isFinite(price) ? price : null]);
    res.status(201).json({ message: 'تم إرسال الريلز للمراجعة', id: result.insertId, status: 'pending', video_url: `/uploads/${req.file.filename}` });
  } catch (e) {
    console.error('REELS CREATE ERROR:', e);
    res.status(500).json({ message: 'تعذر رفع الريلز' });
  }
});

module.exports = router;
