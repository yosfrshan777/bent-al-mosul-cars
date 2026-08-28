const express = require('express');

const { pool } = require('../db');
const { auth, admin } = require('../middleware/auth');

const router = express.Router();

router.use(auth, admin);

// لوحة الإدارة
router.get('/dashboard', async (_, res) => {
  try {
    const [[cars]] = await pool.query(
      `SELECT COUNT(*) AS count FROM cars`,
    );

    const [[users]] = await pool.query(
      `SELECT COUNT(*) AS count FROM users`,
    );

    const [[requests]] = await pool.query(
      `SELECT COUNT(*) AS count
       FROM cars
       WHERE status = 'pending'`,
    );

    const [[payments]] = await pool.query(
      `SELECT COUNT(*) AS count
       FROM payments
       WHERE status = 'pending'`,
    );

    res.json({
      cars_count: Number(cars.count),
      users_count: Number(users.count),
      requests_count: Number(requests.count),
      pending_payments: Number(payments.count),
    });
  } catch (error) {
    console.error('ADMIN DASHBOARD:', error);

    res.status(500).json({
      message: 'تعذر تحميل لوحة الإدارة',
    });
  }
});

// الطلبات المعلقة
router.get('/requests/pending', async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        c.id,
        c.brand,
        c.model,
        c.year,
        c.price,
        c.city,
        c.plan,
        c.status,
        c.created_at,
        u.name AS seller_name,
        u.phone AS seller_phone
      FROM cars c
      LEFT JOIN users u
        ON u.id = c.user_id
      WHERE c.status = 'pending'
      ORDER BY c.id DESC
    `);

    res.json(rows);
  } catch (error) {
    console.error('PENDING REQUESTS:', error);

    res.status(500).json({
      message: 'تعذر تحميل الطلبات',
    });
  }
});

// الموافقة على إعلان
router.post(
  '/requests/:id/approve',
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!Number.isInteger(id)) {
        return res.status(400).json({
          message: 'رقم الإعلان غير صحيح',
        });
      }

      const [result] = await pool.execute(
        `
        UPDATE cars
        SET status = 'approved'
        WHERE id = ?
          AND status = 'pending'
        `,
        [id],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message:
              'الإعلان غير موجود أو تمت معالجته مسبقاً',
        });
      }

      res.json({
        message: 'تمت الموافقة على الإعلان',
      });
    } catch (error) {
      console.error('APPROVE CAR:', error);

      res.status(500).json({
        message: 'تعذر الموافقة على الإعلان',
      });
    }
  },
);

// رفض إعلان
router.post(
  '/requests/:id/reject',
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!Number.isInteger(id)) {
        return res.status(400).json({
          message: 'رقم الإعلان غير صحيح',
        });
      }

      const [result] = await pool.execute(
        `
        UPDATE cars
        SET status = 'rejected'
        WHERE id = ?
          AND status = 'pending'
        `,
        [id],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message:
              'الإعلان غير موجود أو تمت معالجته مسبقاً',
        });
      }

      res.json({
        message: 'تم رفض الإعلان',
      });
    } catch (error) {
      console.error('REJECT CAR:', error);

      res.status(500).json({
        message: 'تعذر رفض الإعلان',
      });
    }
  },
);

// جميع المستخدمين
router.get('/users', async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        id,
        name,
        phone,
        role,
        created_at
      FROM users
      ORDER BY id DESC
    `);

    res.json(rows);
  } catch (error) {
    console.error('ADMIN USERS:', error);

    res.status(500).json({
      message: 'تعذر تحميل المستخدمين',
    });
  }
});

// تغيير صلاحية المستخدم
router.put(
  '/users/:id/role',
  async (req, res) => {
    try {
      const id = Number(req.params.id);
      const { role } = req.body;

      const allowedRoles = [
        'user',
        'seller',
        'showroom',
        'parts',
        'admin',
      ];

      if (!allowedRoles.includes(role)) {
        return res.status(400).json({
          message: 'الصلاحية غير صحيحة',
        });
      }

      if (
        id === req.user.id &&
        role !== 'owner'
      ) {
        return res.status(400).json({
          message:
              'لا يمكنك إزالة صلاحية حسابك الحالي',
        });
      }

      const [result] = await pool.execute(
        `
        UPDATE users
        SET role = ?
        WHERE id = ?
        `,
        [role, id],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message: 'المستخدم غير موجود',
        });
      }

      res.json({
        message: 'تم تحديث صلاحية المستخدم',
      });
    } catch (error) {
      console.error('UPDATE ROLE:', error);

      res.status(500).json({
        message:
            'تعذر تحديث صلاحية المستخدم',
      });
    }
  },
);

// إعدادات الدفع
router.get(
  '/payment-settings',
  async (_, res) => {
    try {
      const [rows] = await pool.execute(
        `
        SELECT
          id,
          phone,
          card_number,
          account_name,
          method,
          updated_at
        FROM payment_settings
        ORDER BY id ASC
        LIMIT 1
        `,
      );

      res.json(
        rows[0] ?? {
          phone: null,
          card_number: null,
          account_name: null,
          method: 'card',
        },
      );
    } catch (error) {
      console.error(
        'PAYMENT SETTINGS:',
        error,
      );

      res.status(500).json({
        message:
            'تعذر تحميل إعدادات الدفع',
      });
    }
  },
);

// تعديل إعدادات الدفع
router.put(
  '/payment-settings',
  async (req, res) => {
    try {
      const {
        phone,
        card_number,
        account_name,
        method,
      } = req.body;

      const [rows] = await pool.execute(
        `
        SELECT id
        FROM payment_settings
        ORDER BY id ASC
        LIMIT 1
        `,
      );

      if (rows.length === 0) {
        await pool.execute(
          `
          INSERT INTO payment_settings
          (
            phone,
            card_number,
            account_name,
            method
          )
          VALUES (?, ?, ?, ?)
          `,
          [
            phone || null,
            card_number || null,
            account_name || null,
            method || 'card',
          ],
        );
      } else {
        await pool.execute(
          `
          UPDATE payment_settings
          SET
            phone = ?,
            card_number = ?,
            account_name = ?,
            method = ?
          WHERE id = ?
          `,
          [
            phone || null,
            card_number || null,
            account_name || null,
            method || 'card',
            rows[0].id,
          ],
        );
      }

      res.json({
        message:
            'تم تحديث بيانات الاستلام',
      });
    } catch (error) {
      console.error(
        'UPDATE PAYMENT SETTINGS:',
        error,
      );

      res.status(500).json({
        message:
            'تعذر تحديث بيانات الاستلام',
      });
    }
  },
);

module.exports = router;
