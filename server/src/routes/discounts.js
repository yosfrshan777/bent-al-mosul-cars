const express = require('express');
const { pool } = require('../db');
const { auth, admin } = require('../middleware/auth');

const router = express.Router();

router.post('/validate', auth, async (req, res) => {
  try {
    const code = String(req.body.code || '').trim().toUpperCase();
    if (!code) return res.status(400).json({ message: 'أدخل كود الخصم' });

    const [rows] = await pool.execute(`
      SELECT id, percentage, max_uses, used_count, expires_at
      FROM discounts
      WHERE code = ? AND active = 1
      LIMIT 1
    `, [code]);

    if (!rows.length) return res.status(404).json({ message: 'كود الخصم غير صحيح' });
    const discount = rows[0];
    if (discount.expires_at && new Date(discount.expires_at) < new Date()) {
      return res.status(400).json({ message: 'انتهت صلاحية كود الخصم' });
    }
    if (discount.max_uses !== null && Number(discount.used_count) >= Number(discount.max_uses)) {
      return res.status(400).json({ message: 'تم استنفاد كود الخصم' });
    }

    res.json({ valid: true, code });
  } catch (error) {
    console.error('VALIDATE DISCOUNT:', error);
    res.status(500).json({ message: 'تعذر التحقق من كود الخصم' });
  }
});

router.get('/', auth, admin, async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT id, code, percentage, active, max_uses, used_count, expires_at, created_at
      FROM discounts ORDER BY id DESC
    `);
    res.json(rows);
  } catch (error) {
    console.error('DISCOUNTS:', error);
    res.status(500).json({ message: 'تعذر تحميل أكواد الخصم' });
  }
});

router.post('/', auth, admin, async (req, res) => {
  try {
    const code = String(req.body.code || '').trim().toUpperCase();
    const percentage = Number(req.body.percentage);
    const maxUses = req.body.max_uses == null || req.body.max_uses === '' ? null : Number(req.body.max_uses);
    const expiresAt = req.body.expires_at || null;

    if (!/^[A-Z0-9_-]{4,40}$/.test(code)) return res.status(400).json({ message: 'صيغة الكود غير صحيحة' });
    if (!Number.isFinite(percentage) || percentage <= 0 || percentage > 100) return res.status(400).json({ message: 'نسبة الخصم يجب أن تكون بين 1 و100' });
    if (maxUses !== null && (!Number.isInteger(maxUses) || maxUses < 1)) return res.status(400).json({ message: 'عدد الاستخدامات غير صحيح' });

    await pool.execute(`
      INSERT INTO discounts (code, target, percentage, active, max_uses, used_count, expires_at)
      VALUES (?, 'all', ?, 1, ?, 0, ?)
    `, [code, percentage, maxUses, expiresAt]);

    res.status(201).json({ message: 'تم إنشاء كود الخصم', code });
  } catch (error) {
    if (error && error.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'كود الخصم موجود مسبقاً' });
    console.error('CREATE DISCOUNT:', error);
    res.status(500).json({ message: 'تعذر إنشاء كود الخصم' });
  }
});

router.put('/:id/toggle', auth, admin, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const active = req.body.active ? 1 : 0;
    const [result] = await pool.execute('UPDATE discounts SET active = ? WHERE id = ?', [active, id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'كود الخصم غير موجود' });
    res.json({ message: active ? 'تم تفعيل الكود' : 'تم تعطيل الكود' });
  } catch (error) {
    console.error('TOGGLE DISCOUNT:', error);
    res.status(500).json({ message: 'تعذر تعديل كود الخصم' });
  }
});

module.exports = router;
