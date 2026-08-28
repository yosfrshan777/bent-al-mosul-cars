const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { pool } = require('../db');
const { auth } = require('../middleware/auth');

const router = express.Router();

function createToken(user) {
  return jwt.sign(
    {
      id: user.id,
      role: user.role,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: '30d',
    },
  );
}

// تسجيل حساب جديد
router.post('/register', async (req, res) => {
  try {
    const {
      name,
      phone,
      password,
    } = req.body;

    if (
      !name ||
      !phone ||
      !password
    ) {
      return res.status(400).json({
        message: 'أكمل جميع البيانات',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        message:
            'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      });
    }

    const [existing] = await pool.execute(
      `SELECT id
       FROM users
       WHERE phone = ?
       LIMIT 1`,
      [phone],
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message:
            'رقم الهاتف مستخدم مسبقاً',
      });
    }

    const hashedPassword =
        await bcrypt.hash(password, 12);

    const [result] = await pool.execute(
      `INSERT INTO users
       (name, phone, password, role)
       VALUES (?, ?, ?, 'user')`,
      [
        name.trim(),
        phone.trim(),
        hashedPassword,
      ],
    );

    const user = {
      id: result.insertId,
      name: name.trim(),
      phone: phone.trim(),
      role: 'user',
    };

    res.status(201).json({
      message:
          'تم إنشاء الحساب بنجاح',
      token: createToken(user),
      user,
    });
  } catch (error) {
    console.error(
      'REGISTER ERROR:',
      error,
    );

    res.status(500).json({
      message:
          'حدث خطأ أثناء إنشاء الحساب',
    });
  }
});

// تسجيل الدخول
router.post('/login', async (req, res) => {
  try {
    const {
      phone,
      password,
    } = req.body;

    if (!phone || !password) {
      return res.status(400).json({
        message:
            'أدخل رقم الهاتف وكلمة المرور',
      });
    }

    const [rows] = await pool.execute(
      `SELECT
        id,
        name,
        phone,
        password,
        role
       FROM users
       WHERE phone = ?
       LIMIT 1`,
      [phone.trim()],
    );

    if (rows.length === 0) {
      return res.status(401).json({
        message:
            'رقم الهاتف أو كلمة المرور غير صحيحة',
      });
    }

    const user = rows[0];

    const valid =
        await bcrypt.compare(
      password,
      user.password,
    );

    if (!valid) {
      return res.status(401).json({
        message:
            'رقم الهاتف أو كلمة المرور غير صحيحة',
      });
    }

    const safeUser = {
      id: user.id,
      name: user.name,
      phone: user.phone,
      role: user.role,
    };

    res.json({
      message:
          'تم تسجيل الدخول بنجاح',
      token: createToken(safeUser),
      user: safeUser,
    });
  } catch (error) {
    console.error(
      'LOGIN ERROR:',
      error,
    );

    res.status(500).json({
      message:
          'حدث خطأ أثناء تسجيل الدخول',
    });
  }
});

// بيانات المستخدم الحالي
router.get('/me', auth, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT
        id,
        name,
        phone,
        role,
        created_at
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [req.user.id],
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message:
            'المستخدم غير موجود',
      });
    }

    res.json({
      user: rows[0],
    });
  } catch (error) {
    console.error(
      'ME ERROR:',
      error,
    );

    res.status(500).json({
      message:
          'تعذر تحميل بيانات الحساب',
    });
  }
});

// تسجيل الخروج
router.post(
  '/logout',
  auth,
  (_, res) => {
    res.json({
      message:
          'تم تسجيل الخروج',
    });
  },
);

module.exports = router;
