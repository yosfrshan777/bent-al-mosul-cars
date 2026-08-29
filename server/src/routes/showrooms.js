const express = require('express');
const { pool } = require('../db');
const { auth, admin } = require('../middleware/auth');
const router = express.Router();

router.get('/', async (_, res) => {
  try {
    const [rows] = await pool.execute(`SELECT id,name,phone,city FROM users WHERE role = 'showroom' ORDER BY id DESC`);
    res.json({ showrooms: rows });
  } catch (error) {
    console.error('SHOWROOMS ERROR:', error);
    res.status(500).json({ message: 'تعذر تحميل المعارض' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ message: 'رقم المعرض غير صحيح' });
    const [users] = await pool.execute(`SELECT id,name,phone,city FROM users WHERE id = ? AND role = 'showroom' LIMIT 1`, [id]);
    if (!users.length) return res.status(404).json({ message: 'المعرض غير موجود' });
    const [cars] = await pool.execute(`SELECT c.id,c.brand,c.model,c.year,c.price,c.city,c.body_type,c.fuel,c.transmission,c.description,c.plan,c.status,(SELECT ci.image FROM car_images ci WHERE ci.car_id=c.id ORDER BY ci.id ASC LIMIT 1) AS image FROM cars c WHERE c.user_id=? AND c.status='approved' ORDER BY c.id DESC`, [id]);
    res.json({ showroom: users[0], cars });
  } catch (error) {
    console.error('SHOWROOM DETAILS ERROR:', error);
    res.status(500).json({ message: 'تعذر تحميل بيانات المعرض' });
  }
});

router.post('/request', auth, async (req, res) => {
  try {
    const name = String(req.body.name || '').trim();
    const phone = String(req.body.phone || '').trim();
    const city = String(req.body.city || '').trim();
    if (!name || !phone || !city) return res.status(400).json({ message: 'أكمل بيانات المعرض' });
    const [existing] = await pool.execute(`SELECT id,status FROM showroom_requests WHERE user_id=? AND status='pending' LIMIT 1`, [req.user.id]);
    if (existing.length) return res.status(409).json({ message: 'لديك طلب معرض قيد المراجعة' });
    await pool.execute(`INSERT INTO showroom_requests (user_id,name,phone,city,amount,status) VALUES (?,?,?,?,100000,'pending')`, [req.user.id,name,phone,city]);
    await pool.execute(`UPDATE users SET phone=?,city=? WHERE id=?`, [phone,city,req.user.id]);
    res.status(201).json({ message: 'تم إرسال طلب اشتراك المعرض للإدارة', status: 'pending', amount: 100000, currency: 'IQD' });
  } catch (error) {
    console.error('SHOWROOM REQUEST ERROR:', error);
    res.status(500).json({ message: 'تعذر إرسال طلب المعرض' });
  }
});

router.put('/:id/approve', auth, admin, async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ message: 'رقم المستخدم غير صحيح' });
    const [result] = await pool.execute(`UPDATE users SET role='showroom' WHERE id=? AND role!='owner'`, [id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'المستخدم غير موجود أو لا يمكن تعديله' });
    await pool.execute(`UPDATE showroom_requests SET status='approved' WHERE user_id=? AND status='pending'`, [id]);
    res.json({ message: 'تم اعتماد المعرض' });
  } catch (error) {
    console.error('APPROVE SHOWROOM ERROR:', error);
    res.status(500).json({ message: 'تعذر اعتماد المعرض' });
  }
});

module.exports = router;
