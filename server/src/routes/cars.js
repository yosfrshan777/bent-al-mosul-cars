const express = require('express');

const { pool } = require('../db');
const { auth } = require('../middleware/auth');

const router = express.Router();

// جلب السيارات المنشورة
router.get('/', async (_, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT
        c.id,
        c.user_id,
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
        c.created_at,

        (
          SELECT ci.image
          FROM car_images ci
          WHERE ci.car_id = c.id
          ORDER BY ci.id ASC
          LIMIT 1
        ) AS image,

        u.name AS seller_name,
        u.phone AS seller_phone

      FROM cars c

      LEFT JOIN users u
        ON u.id = c.user_id

      WHERE c.status = 'approved'

      ORDER BY
        CASE
          WHEN c.plan = 'VIP' THEN 1
          WHEN c.plan = 'مميز' THEN 2
          ELSE 3
        END,
        c.id DESC
    `);

    res.json(rows);
  } catch (error) {
    console.error(
      'GET CARS ERROR:',
      error,
    );

    res.status(500).json({
      message:
          'تعذر تحميل السيارات',
    });
  }
});

// جلب سيارة واحدة
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        message:
            'رقم السيارة غير صحيح',
      });
    }

    const [cars] = await pool.execute(
      `
      SELECT
        c.id,
        c.user_id,
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
        c.created_at,
        u.name AS seller_name,
        u.phone AS seller_phone
      FROM cars c
      LEFT JOIN users u
        ON u.id = c.user_id
      WHERE c.id = ?
        AND c.status = 'approved'
      LIMIT 1
      `,
      [id],
    );

    if (cars.length === 0) {
      return res.status(404).json({
        message:
            'السيارة غير موجودة',
      });
    }

    const [images] = await pool.execute(
      `
      SELECT
        id,
        image
      FROM car_images
      WHERE car_id = ?
      ORDER BY id ASC
      `,
      [id],
    );

    res.json({
      ...cars[0],
      images,
    });
  } catch (error) {
    console.error(
      'GET CAR ERROR:',
      error,
    );

    res.status(500).json({
      message:
          'تعذر تحميل السيارة',
    });
  }
});

// سيارات المستخدم
router.get(
  '/mine/list',
  auth,
  async (req, res) => {
    try {
      const [rows] = await pool.execute(
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
          c.created_at,

          (
            SELECT ci.image
            FROM car_images ci
            WHERE ci.car_id = c.id
            ORDER BY ci.id ASC
            LIMIT 1
          ) AS image

        FROM cars c

        WHERE c.user_id = ?

        ORDER BY c.id DESC
        `,
        [req.user.id],
      );

      res.json(rows);
    } catch (error) {
      console.error(
        'MY CARS ERROR:',
        error,
      );

      res.status(500).json({
        message:
            'تعذر تحميل إعلاناتك',
      });
    }
  },
);

// إنشاء إعلان
router.post(
  '/',
  auth,
  async (req, res) => {
    const connection =
        await pool.getConnection();

    try {
      const {
        brand,
        model,
        year,
        price,
        km,
        city,
        fuel,
        transmission,
        description,
        plan,
        images,
      } = req.body;

      if (
        !brand ||
        !model ||
        !year ||
        !price ||
        !city
      ) {
        connection.release();

        return res.status(400).json({
          message:
              'أكمل بيانات السيارة',
        });
      }

      const validPlans = [
        'عادي',
        'مميز',
        'VIP',
      ];

      const selectedPlan =
          validPlans.includes(plan)
              ? plan
              : 'عادي';

      await connection.beginTransaction();

      const [result] =
          await connection.execute(
        `
        INSERT INTO cars
        (
          user_id,
          brand,
          model,
          year,
          price,
          km,
          city,
          fuel,
          transmission,
          description,
          plan,
          status
        )
        VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')
        `,
        [
          req.user.id,
          String(brand).trim(),
          String(model).trim(),
          Number(year),
          Number(price),
          Number(km || 0),
          String(city).trim(),
          fuel || 'بنزين',
          transmission || 'أوتوماتيك',
          description || '',
          selectedPlan,
        ],
      );

      const carId =
          result.insertId;

      if (Array.isArray(images)) {
        for (const image of images) {
          if (!image) continue;

          await connection.execute(
            `
            INSERT INTO car_images
            (car_id, image)
            VALUES (?, ?)
            `,
            [
              carId,
              String(image),
            ],
          );
        }
      }

      await connection.commit();

      connection.release();

      res.status(201).json({
        message:
            'تم إرسال السيارة للمراجعة',
        id: carId,
        status: 'pending',
      });
    } catch (error) {
      await connection.rollback();
      connection.release();

      console.error(
        'CREATE CAR ERROR:',
        error,
      );

      res.status(500).json({
        message:
            'تعذر إنشاء إعلان السيارة',
      });
    }
  },
);

// حذف إعلان المستخدم
router.delete(
  '/:id',
  auth,
  async (req, res) => {
    try {
      const id =
          Number(req.params.id);

      const [result] =
          await pool.execute(
        `
        DELETE FROM cars
        WHERE id = ?
          AND user_id = ?
        `,
        [
          id,
          req.user.id,
        ],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message:
              'الإعلان غير موجود',
        });
      }

      res.json({
        message:
            'تم حذف الإعلان',
      });
    } catch (error) {
      console.error(
        'DELETE CAR ERROR:',
        error,
      );

      res.status(500).json({
        message:
            'تعذر حذف الإعلان',
      });
    }
  },
);

module.exports = router;
