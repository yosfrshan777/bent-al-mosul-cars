const express = require('express');

const { pool } = require('../db');
const { auth, admin } = require('../middleware/auth');

const router = express.Router();

// جلب المعارض
router.get('/', async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        id,
        name,
        phone,
        city,
        created_at
      FROM users
      WHERE role = 'showroom'
      ORDER BY id DESC
    `);

    res.json(rows);
  } catch (error) {
    console.error('SHOWROOMS ERROR:', error);

    res.status(500).json({
      message: 'تعذر تحميل المعارض',
    });
  }
});

// بيانات معرض واحد وسياراته
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        message: 'رقم المعرض غير صحيح',
      });
    }

    const [users] = await pool.execute(
      `
      SELECT
        id,
        name,
        phone,
        city,
        created_at
      FROM users
      WHERE id = ?
        AND role = 'showroom'
      LIMIT 1
      `,
      [id],
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: 'المعرض غير موجود',
      });
    }

    const [cars] = await pool.execute(
      `
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
        c.status,
        (
          SELECT ci.image
          FROM car_images ci
          WHERE ci.car_id = c.id
          ORDER BY ci.id ASC
          LIMIT 1
        ) AS image
      FROM cars c
      WHERE c.user_id = ?
        AND c.status = 'approved'
      ORDER BY c.id DESC
      `,
      [id],
    );

    res.json({
      showroom: users[0],
      cars,
    });
  } catch (error) {
    console.error(
      'SHOWROOM DETAILS ERROR:',
      error,
    );

    res.status(500).json({
      message: 'تعذر تحميل بيانات المعرض',
    });
  }
});

// طلب التسجيل كمعرض
router.post(
  '/request',
  auth,
  async (req, res) => {
    try {
      const {
        name,
        phone,
        city,
      } = req.body;

      if (!name || !phone || !city) {
        return res.status(400).json({
          message: 'أكمل بيانات المعرض',
        });
      }

      res.status(201).json({
        message:
          'تم إرسال طلب تسجيل المعرض للإدارة',
        status: 'pending',
      });
    } catch (error) {
      console.error(
        'SHOWROOM REQUEST ERROR:',
        error,
      );

      res.status(500).json({
        message:
          'تعذر إرسال طلب المعرض',
      });
    }
  },
);

// تغيير دور المستخدم إلى معرض - للإدارة فقط
router.put(
  '/:id/approve',
  auth,
  admin,
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!Number.isInteger(id)) {
        return res.status(400).json({
          message:
            'رقم المستخدم غير صحيح',
        });
      }

      const [result] = await pool.execute(
        `
        UPDATE users
        SET role = 'showroom'
        WHERE id = ?
          AND role != 'owner'
        `,
        [id],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message:
            'المستخدم غير موجود أو لا يمكن تعديله',
        });
      }

      res.json({
        message:
          'تم اعتماد المعرض',
      });
    } catch (error) {
      console.error(
        'APPROVE SHOWROOM ERROR:',
        error,
      );

      res.status(500).json({
        message:
          'تعذر اعتماد المعرض',
      });
    }
  },
);

module.exports = router;
