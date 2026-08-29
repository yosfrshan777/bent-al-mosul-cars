const express = require('express');

const { pool } = require('../db');
const { auth, admin } = require('../middleware/auth');

const router = express.Router();
router.use(auth, admin);

router.get('/dashboard', async (_, res) => {
  try {
    const [[cars]] = await pool.query(`SELECT COUNT(*) AS count FROM cars`);
    const [[users]] = await pool.query(`SELECT COUNT(*) AS count FROM users`);
    const [[requests]] = await pool.query(`SELECT COUNT(*) AS count FROM cars WHERE status = 'pending'`);
    const [[payments]] = await pool.query(`SELECT COUNT(*) AS count FROM payments WHERE status = 'pending'`);
    res.json({ cars_count: Number(cars.count), users_count: Number(users.count), requests_count: Number(requests.count), pending_payments: Number(payments.count) });
  } catch (error) {
    console.error('ADMIN DASHBOARD:', error);
    res.status(500).json({ message: 'تعذر تحميل لوحة الإدارة' });
  }
});

router.get('/users', async (_, res) => {
  try {
    const [rows] = await pool.execute(`SELECT id,name,phone,role,created_at FROM users ORDER BY id DESC`);
    res.json(rows);
  } catch (error) {
    console.error('ADMIN USERS:', error);
    res.status(500).json({ message: 'تعذر تحميل المستخدمين' });
  }
});

// تعيين أدمن بالرقم مسموح للمالك فقط.
router.put('/users/role-by-phone', async (req, res) => {
  try {
    if (req.user?.role !== 'owner') return res.status(403).json({ message: 'هذه العملية للمالك فقط' });
    const phone = String(req.body.phone || '').trim();
    if (!phone) return res.status(400).json({ message: 'أدخل رقم الهاتف' });
    const [users] = await pool.execute(`SELECT id,name,phone,role FROM users WHERE phone = ? LIMIT 1`, [phone]);
    if (!users.length) return res.status(404).json({ message: 'لا يوجد حساب بهذا الرقم' });
    await pool.execute(`UPDATE users SET role = 'admin' WHERE id = ? AND role <> 'owner'`, [users[0].id]);
    res.json({ message: 'تم تعيين المستخدم كأدمن', user: { ...users[0], role: 'admin' } });
  } catch (error) {
    console.error('ROLE BY PHONE:', error);
    res.status(500).json({ message: 'تعذر تحديث الصلاحية' });
  }
});

router.delete('/users/admin-by-phone', async (req, res) => {
  try {
    if (req.user?.role !== 'owner') return res.status(403).json({ message: 'هذه العملية للمالك فقط' });
    const phone = String(req.body.phone || '').trim();
    const [result] = await pool.execute(`UPDATE users SET role = 'user' WHERE phone = ? AND role = 'admin'`, [phone]);
    if (!result.affectedRows) return res.status(404).json({ message: 'الأدمن غير موجود' });
    res.json({ message: 'تم إلغاء صلاحية الأدمن' });
  } catch (error) {
    console.error('REMOVE ADMIN:', error);
    res.status(500).json({ message: 'تعذر إلغاء الصلاحية' });
  }
});

module.exports = router;
