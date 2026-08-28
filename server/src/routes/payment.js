const express = require('express');

const { pool } = require('../db');
const { auth, admin } = require('../middleware/auth');

const router = express.Router();

router.get('/settings', async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        phone,
        card_number,
        account_name,
        method
      FROM payment_settings
      ORDER BY id ASC
      LIMIT 1
    `);

    res.json(
      rows[0] || {
        phone: null,
        card_number: null,
        account_name: null,
        method: 'card',
      },
    );
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'تعذر تحميل بيانات الدفع',
    });
  }
});

router.post('/', auth, async (req, res) => {
  try {
    const {
      amount,
      method,
      phone,
      card_number,
      account_name,
      reference,
    } = req.body;

    const value = Number(amount);

    if (!Number.isFinite(value) || value <= 0) {
      return res.status(400).json({
        message: 'مبلغ الدفع غير صحيح',
      });
    }

    const methods = [
      'card',
      'qi',
      'bank',
      'cash',
    ];

    const selectedMethod =
      methods.includes(method) ? method : 'card';

    const [result] = await pool.execute(
      `
      INSERT INTO payments
      (
        user_id,
        amount,
        method,
        status,
        phone,
        card_number,
        account_name,
        reference
      )
      VALUES (?, ?, ?, 'pending', ?, ?, ?, ?)
      `,
      [
        req.user.id,
        Math.round(value),
        selectedMethod,
        phone || null,
        card_number || null,
        account_name || null,
        reference || null,
      ],
    );

    res.status(201).json({
      message: 'تم إرسال طلب الدفع للمراجعة',
      id: result.insertId,
      status: 'pending',
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'تعذر إنشاء طلب الدفع',
    });
  }
});

router.get('/mine', auth, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `
      SELECT
        id,
        amount,
        method,
        status,
        phone,
        card_number,
        account_name,
        reference,
        created_at
      FROM payments
      WHERE user_id = ?
      ORDER BY id DESC
      `,
      [req.user.id],
    );

    res.json(rows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'تعذر تحميل المدفوعات',
    });
  }
});

router.get(
  '/admin',
  auth,
  admin,
  async (_, res) => {
    try {
      const [rows] = await pool.execute(`
        SELECT
          p.id,
          p.user_id,
          p.amount,
          p.method,
          p.status,
          p.phone,
          p.card_number,
          p.account_name,
          p.reference,
          p.created_at,
          u.name AS user_name,
          u.phone AS user_phone
        FROM payments p
        LEFT JOIN users u
          ON u.id = p.user_id
        ORDER BY p.id DESC
      `);

      res.json(rows);
    } catch (error) {
      console.error(error);

      res.status(500).json({
        message: 'تعذر تحميل المدفوعات',
      });
    }
  },
);

router.post(
  '/admin/:id/approve',
  auth,
  admin,
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      const [result] = await pool.execute(
        `
        UPDATE payments
        SET status = 'approved'
        WHERE id = ?
          AND status = 'pending'
        `,
        [id],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message:
            'عملية الدفع غير موجودة أو تمت معالجتها',
        });
      }

      res.json({
        message: 'تمت الموافقة على الدفع',
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        message: 'تعذر الموافقة على الدفع',
      });
    }
  },
);

router.post(
  '/admin/:id/reject',
  auth,
  admin,
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      const [result] = await pool.execute(
        `
        UPDATE payments
        SET status = 'rejected'
        WHERE id = ?
          AND status = 'pending'
        `,
        [id],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message:
            'عملية الدفع غير موجودة أو تمت معالجتها',
        });
      }

      res.json({
        message: 'تم رفض عملية الدفع',
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        message: 'تعذر رفض عملية الدفع',
      });
    }
  },
);

module.exports = router;
