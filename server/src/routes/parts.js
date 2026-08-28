const express = require('express');

const { pool } = require('../db');
const { auth, admin } = require('../middleware/auth');

const router = express.Router();

// جلب محلات قطع الغيار
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
      WHERE role = 'parts'
      ORDER BY id DESC
    `);

    res.json(rows);
  } catch (error) {
    console.error('PARTS ERROR:', error);

    res.status(500).json({
      message: 'تعذر تحميل محلات قطع الغيار',
    });
  }
});

// بيانات محل قطع الغيار
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        message: 'رقم المحل غير صحيح',
      });
    }

    const [rows] = await pool.execute(
      `
      SELECT
        id,
        name,
        phone,
        city,
        created_at
      FROM users
      WHERE id = ?
        AND role = 'parts'
      LIMIT 1
      `,
      [id],
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'محل قطع الغيار غير موجود',
      });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error(
      'PARTS DETAILS ERROR:',
      error,
    );

    res.status(500).json({
      message:
        'تعذر تحميل بيانات محل قطع الغيار',
    });
  }
});

// طلب التسجيل كصاحب قطع غيار
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
          message:
            'أكمل بيانات محل قطع الغيار',
        });
      }

      res.status(201).json({
        message:
          'تم إرسال طلب التسجيل للإدارة',
        status: 'pending',
      });
    } catch (error) {
      console.error(
        'PARTS REQUEST ERROR:',
        error,
      );

      res.status(500).json({
        message:
          'تعذر إرسال الطلب',
      });
    }
  },
);

// اعتماد صاحب قطع الغيار
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
        SET role = 'parts'
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
          'تم اعتماد صاحب قطع الغيار',
      });
    } catch (error) {
      console.error(
        'APPROVE PARTS ERROR:',
        error,
      );

      res.status(500).json({
        message:
          'تعذر اعتماد الطلب',
      });
    }
  },
);

module.exports = router;
