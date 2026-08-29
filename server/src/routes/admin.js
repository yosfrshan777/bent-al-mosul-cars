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

router.get('/requests/pending', async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT c.id,c.brand,c.model,c.year,c.price,c.city,c.plan,c.status,c.created_at,u.name AS seller_name,u.phone AS seller_phone
      FROM cars c LEFT JOIN users u ON u.id = c.user_id
      WHERE c.status = 'pending' ORDER BY c.id DESC
    `);
    res.json(rows);
  } catch (error) {
    console.error('PENDING REQUESTS:', error);
    res.status(500).json({ message: 'تعذر تحميل الطلبات' });
  }
});

router.post('/requests/:id/approve', async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ message: 'رقم الإعلان غير صحيح' });
    const [result] = await pool.execute(`UPDATE cars SET status = 'approved' WHERE id = ? AND status = 'pending'`, [id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'الإعلان غير موجود أو تمت معالجته مسبقاً' });
    res.json({ message: 'تمت الموافقة على الإعلان' });
  } catch (error) {
    console.error('APPROVE CAR:', error);
    res.status(500).json({ message: 'تعذر الموافقة على الإعلان' });
  }
});

router.post('/requests/:id/reject', async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ message: 'رقم الإعلان غير صحيح' });
    const [result] = await pool.execute(`UPDATE cars SET status = 'rejected' WHERE id = ? AND status = 'pending'`, [id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'الإعلان غير موجود أو تمت معالجته مسبقاً' });
    res.json({ message: 'تم رفض الإعلان' });
  } catch (error) {
    console.error('REJECT CAR:', error);
    res.status(500).json({ message: 'تعذر رفض الإعلان' });
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

// المالك/الأدمن يستطيع تعيين مستخدم كأدمن عن طريق رقم الهاتف.
router.put('/users/role-by-phone', async (req, res) => {
  try {
    const phone = String(req.body.phone || '').trim();
    const role = String(req.body.role || 'admin').trim();
    if (!phone) return res.status(400).json({ message: 'أدخل رقم الهاتف' });
    if (!['user', 'seller', 'showroom', 'parts', 'admin'].includes(role)) return res.status(400).json({ message: 'الصلاحية غير صحيحة' });

    const [users] = await pool.execute(`SELECT id,name,phone,role FROM users WHERE phone = ? LIMIT 1`, [phone]);
    if (!users.length) return res.status(404).json({ message: 'لا يوجد حساب بهذا الرقم' });

    await pool.execute(`UPDATE users SET role = ? WHERE id = ?`, [role, users[0].id]);
    res.json({ message: role === 'admin' ? 'تم تعيين المستخدم كأدمن' : 'تم تحديث الصلاحية', user: { ...users[0], role } });
  } catch (error) {
    console.error('ROLE BY PHONE:', error);
    res.status(500).json({ message: 'تعذر تحديث الصلاحية' });
  }
});

router.put('/users/:id/role', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { role } = req.body;
    const allowedRoles = ['user', 'seller', 'showroom', 'parts', 'admin'];
    if (!allowedRoles.includes(role)) return res.status(400).json({ message: 'الصلاحية غير صحيحة' });
    if (id === req.user.id && role !== 'admin') return res.status(400).json({ message: 'لا يمكنك إزالة صلاحية الإدارة من حسابك الحالي' });
    const [result] = await pool.execute(`UPDATE users SET role = ? WHERE id = ? AND role <> 'owner'`, [role, id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'المستخدم غير موجود أو هو المالك' });
    res.json({ message: 'تم تحديث صلاحية المستخدم' });
  } catch (error) {
    console.error('UPDATE ROLE:', error);
    res.status(500).json({ message: 'تعذر تحديث صلاحية المستخدم' });
  }
});

// خصومات المستخدمين والمعارض. النسبة تحفظ في جدول discounts.
router.get('/discounts', async (_, res) => {
  try {
    const [rows] = await pool.execute(`SELECT id,target,percentage,active,created_at FROM discounts ORDER BY id DESC`);
    res.json(rows);
  } catch (error) {
    console.error('DISCOUNTS:', error);
    res.status(500).json({ message: 'تعذر تحميل الخصومات' });
  }
});

router.post('/discounts', async (req, res) => {
  try {
    const target = String(req.body.target || 'users');
    const percentage = Number(req.body.percentage);
    const active = req.body.active === false ? 0 : 1;
    if (!['users', 'showrooms'].includes(target) || !Number.isFinite(percentage) || percentage < 0 || percentage > 100) return res.status(400).json({ message: 'بيانات الخصم غير صحيحة' });
    const [result] = await pool.execute(`INSERT INTO discounts (target,percentage,active) VALUES (?,?,?)`, [target, percentage, active]);
    res.status(201).json({ id: result.insertId, target, percentage, active: Boolean(active) });
  } catch (error) {
    console.error('CREATE DISCOUNT:', error);
    res.status(500).json({ message: 'تعذر حفظ الخصم' });
  }
});

router.put('/discounts/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const percentage = Number(req.body.percentage);
    const active = req.body.active === false ? 0 : 1;
    if (!Number.isInteger(id) || !Number.isFinite(percentage) || percentage < 0 || percentage > 100) return res.status(400).json({ message: 'بيانات الخصم غير صحيحة' });
    const [result] = await pool.execute(`UPDATE discounts SET percentage = ?, active = ? WHERE id = ?`, [percentage, active, id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'الخصم غير موجود' });
    res.json({ message: 'تم تحديث الخصم' });
  } catch (error) {
    console.error('UPDATE DISCOUNT:', error);
    res.status(500).json({ message: 'تعذر تحديث الخصم' });
  }
});

router.get('/payment-settings', async (_, res) => {
  try {
    const [rows] = await pool.execute(`SELECT id,phone,card_number,account_name,method,updated_at FROM payment_settings ORDER BY id ASC LIMIT 1`);
    res.json(rows[0] ?? { phone: null, card_number: null, account_name: null, method: 'card' });
  } catch (error) {
    console.error('PAYMENT SETTINGS:', error);
    res.status(500).json({ message: 'تعذر تحميل إعدادات الدفع' });
  }
});

router.put('/payment-settings', async (req, res) => {
  try {
    const { phone, card_number, account_name, method } = req.body;
    const [rows] = await pool.execute(`SELECT id FROM payment_settings ORDER BY id ASC LIMIT 1`);
    if (!rows.length) {
      await pool.execute(`INSERT INTO payment_settings (phone,card_number,account_name,method) VALUES (?,?,?,?)`, [phone || null, card_number || null, account_name || null, method || 'card']);
    } else {
      await pool.execute(`UPDATE payment_settings SET phone=?,card_number=?,account_name=?,method=? WHERE id=?`, [phone || null, card_number || null, account_name || null, method || 'card', rows[0].id]);
    }
    res.json({ message: 'تم تحديث بيانات الاستلام' });
  } catch (error) {
    console.error('UPDATE PAYMENT SETTINGS:', error);
    res.status(500).json({ message: 'تعذر تحديث بيانات الاستلام' });
  }
});

module.exports = router;
