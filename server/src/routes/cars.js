const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const { pool } = require('../db');
const { auth } = require('../middleware/auth');

const router = express.Router();

const uploadDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_, __, callback) => callback(null, uploadDir),
  filename: (_, file, callback) => {
    const extension = path.extname(file.originalname).toLowerCase();
    const name = `${Date.now()}-${Math.round(Math.random() * 1000000000)}${extension}`;
    callback(null, name);
  },
});

const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];
const upload = multer({
  storage,
  limits: { files: 8, fileSize: 10 * 1024 * 1024 },
  fileFilter: (_, file, callback) => {
    if (allowedTypes.includes(file.mimetype)) {
      callback(null, true);
    } else {
      callback(new Error('يسمح فقط بصور JPG و PNG و WEBP'));
    }
  },
});

// جلب السيارات المنشورة
router.get('/', async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        c.id, c.user_id, c.brand, c.model, c.year, c.price, c.km,
        c.city, c.fuel, c.transmission, c.description, c.plan,
        c.status, c.created_at,
        (
          SELECT ci.image FROM car_images ci
          WHERE ci.car_id = c.id
          ORDER BY ci.id ASC LIMIT 1
        ) AS image,
        u.name AS seller_name,
        u.phone AS seller_phone
      FROM cars c
      LEFT JOIN users u ON u.id = c.user_id
      WHERE c.status = 'approved'
      ORDER BY
        CASE
          WHEN c.plan = 'VIP' THEN 1
          WHEN c.plan = 'مميز' THEN 2
          ELSE 3
        END,
        c.id DESC
    `);
    res.json(rows);
  } catch (error) {
    console.error('GET CARS ERROR:', error);
    res.status(500).json({ message: 'تعذر تحميل السيارات' });
  }
});

// جلب سيارة واحدة
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) {
      return res.status(400).json({ message: 'رقم السيارة غير صحيح' });
    }

    const [cars] = await pool.execute(`
      SELECT
        c.id, c.user_id, c.brand, c.model, c.year, c.price, c.km,
        c.city, c.fuel, c.transmission, c.description, c.plan,
        c.status, c.created_at,
        u.name AS seller_name,
        u.phone AS seller_phone
      FROM cars c
      LEFT JOIN users u ON u.id = c.user_id
      WHERE c.id = ? AND c.status = 'approved'
      LIMIT 1
    `, [id]);

    if (cars.length === 0) {
      return res.status(404).json({ message: 'السيارة غير موجودة' });
    }

    const [images] = await pool.execute(`
      SELECT id, image
      FROM car_images
      WHERE car_id = ?
      ORDER BY id ASC
    `, [id]);

    res.json({ ...cars[0], images });
  } catch (error) {
    console.error('GET CAR ERROR:', error);
    res.status(500).json({ message: 'تعذر تحميل السيارة' });
  }
});

// سيارات المستخدم
router.get('/mine/list', auth, async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        c.id, c.brand, c.model, c.year, c.price, c.km, c.city,
        c.fuel, c.transmission, c.description, c.plan, c.status,
        c.created_at,
        (
          SELECT ci.image FROM car_images ci
          WHERE ci.car_id = c.id
          ORDER BY ci.id ASC LIMIT 1
        ) AS image
      FROM cars c
      WHERE c.user_id = ?
      ORDER BY c.id DESC
    `, [req.user.id]);
    res.json(rows);
  } catch (error) {
    console.error('MY CARS ERROR:', error);
    res.status(500).json({ message: 'تعذر تحميل إعلاناتك' });
  }
});

// إنشاء إعلان مع رفع الصور
router.post('/', auth, upload.array('images', 8), async (req, res) => {
  const connection = await pool.getConnection();

  try {
    const {
      brand, model, year, price, km, city,
      fuel, transmission, description, plan,
    } = req.body;

    if (!brand || !model || !year || !price || !city) {
      connection.release();
      return res.status(400).json({ message: 'أكمل بيانات السيارة' });
    }

    if (!req.files || req.files.length === 0) {
      connection.release();
      return res.status(400).json({ message: 'أضف صورة واحدة على الأقل' });
    }

    const validPlans = ['عادي', 'مميز', 'VIP'];
    const selectedPlan = validPlans.includes(plan) ? plan : 'عادي';

    await connection.beginTransaction();

    const [result] = await connection.execute(`
      INSERT INTO cars
      (user_id, brand, model, year, price, km, city, fuel,
       transmission, description, plan, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')
    `, [
      req.user.id,
      String(brand).trim(),
      String(model).trim(),
      Number(year),
      Number(price),
      Number(km || 0),
      String(city).trim(),
      fuel || 'بنزين',
      transmission || 'أوتوماتيك',
      description || '',
      selectedPlan,
    ]);

    const carId = result.insertId;

    for (const file of req.files) {
      await connection.execute(`
        INSERT INTO car_images (car_id, image)
        VALUES (?, ?)
      `, [carId, `/uploads/${file.filename}`]);
    }

    await connection.commit();
    connection.release();

    res.status(201).json({
      message: 'تم إرسال السيارة للمراجعة',
      id: carId,
      status: 'pending',
      images: req.files.map((file) => `/uploads/${file.filename}`),
    });
  } catch (error) {
    try { await connection.rollback(); } catch (_) {}
    connection.release();

    if (Array.isArray(req.files)) {
      for (const file of req.files) {
        try {
          if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
        } catch (_) {}
      }
    }

    console.error('CREATE CAR ERROR:', error);
    res.status(500).json({ message: 'تعذر إنشاء إعلان السيارة' });
  }
});

// حذف إعلان المستخدم
router.delete('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const [result] = await pool.execute(`
      DELETE FROM cars
      WHERE id = ? AND user_id = ?
    `, [id, req.user.id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'الإعلان غير موجود' });
    }

    res.json({ message: 'تم حذف الإعلان' });
  } catch (error) {
    console.error('DELETE CAR ERROR:', error);
    res.status(500).json({ message: 'تعذر حذف الإعلان' });
  }
});

module.exports = router;
