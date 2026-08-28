const express = require('express');

const { pool } = require('../db');
const { auth } = require('../middleware/auth');

const router = express.Router();

// جلب محادثات المستخدم
router.get('/conversations', auth, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `
      SELECT
        m.id,
        m.sender_id,
        m.receiver_id,
        m.text,
        m.is_read,
        m.created_at,
        u.name AS other_name,
        u.phone AS other_phone
      FROM messages m
      JOIN users u
        ON u.id = CASE
          WHEN m.sender_id = ?
          THEN m.receiver_id
          ELSE m.sender_id
        END
      WHERE m.sender_id = ?
         OR m.receiver_id = ?
      ORDER BY m.id DESC
      `,
      [
        req.user.id,
        req.user.id,
        req.user.id,
      ],
    );

    res.json(rows);
  } catch (error) {
    console.error(
      'CONVERSATIONS ERROR:',
      error,
    );

    res.status(500).json({
      message: 'تعذر تحميل المحادثات',
    });
  }
});

// جلب رسائل مستخدم معين
router.get('/:userId', auth, async (req, res) => {
  try {
    const otherUserId =
      Number(req.params.userId);

    if (!Number.isInteger(otherUserId)) {
      return res.status(400).json({
        message: 'رقم المستخدم غير صحيح',
      });
    }

    const [rows] = await pool.execute(
      `
      SELECT
        id,
        sender_id,
        receiver_id,
        text,
        is_read,
        created_at
      FROM messages
      WHERE
        (sender_id = ? AND receiver_id = ?)
        OR
        (sender_id = ? AND receiver_id = ?)
      ORDER BY id ASC
      `,
      [
        req.user.id,
        otherUserId,
        otherUserId,
        req.user.id,
      ],
    );

    await pool.execute(
      `
      UPDATE messages
      SET is_read = 1
      WHERE sender_id = ?
        AND receiver_id = ?
      `,
      [
        otherUserId,
        req.user.id,
      ],
    );

    res.json(rows);
  } catch (error) {
    console.error(
      'MESSAGES ERROR:',
      error,
    );

    res.status(500).json({
      message: 'تعذر تحميل الرسائل',
    });
  }
});

// إرسال رسالة
router.post('/', auth, async (req, res) => {
  try {
    const {
      receiver_id,
      text,
    } = req.body;

    const receiverId =
      Number(receiver_id);

    if (
      !Number.isInteger(receiverId) ||
      receiverId <= 0
    ) {
      return res.status(400).json({
        message:
          'المستخدم المستلم غير صحيح',
      });
    }

    if (
      !text ||
      text.trim().isEmpty
    ) {
      return res.status(400).json({
        message: 'اكتب الرسالة',
      });
    }

    if (receiverId === req.user.id) {
      return res.status(400).json({
        message:
          'لا يمكنك إرسال رسالة لنفسك',
      });
    }

    const [users] = await pool.execute(
      `
      SELECT id
      FROM users
      WHERE id = ?
      LIMIT 1
      `,
      [receiverId],
    );

    if (users.length === 0) {
      return res.status(404).json({
        message:
          'المستخدم المستلم غير موجود',
      });
    }

    const [result] = await pool.execute(
      `
      INSERT INTO messages
      (
        sender_id,
        receiver_id,
        text,
        is_read
      )
      VALUES (?, ?, ?, 0)
      `,
      [
        req.user.id,
        receiverId,
        text.trim(),
      ],
    );

    res.status(201).json({
      message: 'تم إرسال الرسالة',
      id: result.insertId,
    });
  } catch (error) {
    console.error(
      'SEND MESSAGE ERROR:',
      error,
    );

    res.status(500).json({
      message:
        'تعذر إرسال الرسالة',
    });
  }
});

module.exports = router;
