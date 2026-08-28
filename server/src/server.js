require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
});

function tokenFor(user) {
  return jwt.sign(
    {
      id: user.id,
      role: user.role,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: '30d',
    },
  );
}

function auth(req, res, next) {
  const header = req.headers.authorization || '';

  if (!header.startsWith('Bearer ')) {
    return res.status(401).json({
      message: 'يجب تسجيل الدخول',
    });
  }

  const token = header.substring(7);

  try {
    req.user = jwt.verify(
      token,
      process.env.JWT_SECRET,
    );

    next();
  } catch (_) {
    return res.status(401).json({
      message: 'جلسة الدخول غير صالحة',
    });
  }
}

function admin(req, res, next) {
  if (
    req.user.role !== 'admin' &&
    req.user.role !== 'owner'
  ) {
    return res.status(403).json({
      message: 'ليس لديك صلاحية الإدارة',
    });
  }

  next();
}

app.get('/', (_, res) => {
  res.json({
    name: 'ZYOCAR API',
    status: 'online',
  });
});

app.get('/api/health', (_, res) => {
  res.json({
    status: 'ok',
  });
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const {
      name,
      phone,
      password,
    } = req.body;

    if (!name || !phone || !password) {
      return res.status(400).json({
        message: 'أكمل جميع البيانات',
      });
    }

    const [existing] = await pool.execute(
      'SELECT id FROM users WHERE phone = ? LIMIT 1',
      [phone],
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: 'رقم الهاتف مستخدم مسبقاً',
      });
    }

    const hash = await bcrypt.hash(
      password,
      12,
    );

    const [result] = await pool.execute(
      `INSERT INTO users
       (name, phone, password, role)
       VALUES (?, ?, ?, 'user')`,
      [
        name,
        phone,
        hash,
      ],
    );

    const user = {
      id: result.insertId,
      name,
      phone,
      role: 'user',
    };

    res.status(201).json({
      token: tokenFor(user),
      user,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'حدث خطأ أثناء إنشاء الحساب',
    });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const {
      phone,
      password,
    } = req.body;

    const [rows] = await pool.execute(
      `SELECT id, name, phone, password, role
       FROM users
       WHERE phone = ?
       LIMIT 1`,
      [phone],
    );

    if (rows.length === 0) {
      return res.status(401).json({
        message: 'رقم الهاتف أو كلمة المرور غير صحيحة',
      });
    }

    const user = rows[0];

    const valid = await bcrypt.compare(
      password,
      user.password,
    );

    if (!valid) {
      return res.status(401).json({
        message: 'رقم الهاتف أو كلمة المرور غير صحيحة',
      });
    }

    delete user.password;

    res.json({
      token: tokenFor(user),
      user,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'حدث خطأ أثناء تسجيل الدخول',
    });
  }
});

app.get('/api/auth/me', auth, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT id, name, phone, role
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [req.user.id],
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'المستخدم غير موجود',
      });
    }

    res.json({
      user: rows[0],
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'تعذر تحميل الحساب',
    });
  }
});

app.post('/api/auth/logout', auth, (_, res) => {
  res.json({
    message: 'تم تسجيل الخروج',
  });
});

app.get('/api/cars', async (_, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT
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
          SELECT image
          FROM car_images
          WHERE car_id = c.id
          ORDER BY id ASC
          LIMIT 1
        ) AS image,
        u.name AS seller_name,
        u.phone AS seller_phone
       FROM cars c
       LEFT JOIN users u
         ON u.id = c.user_id
       WHERE c.status = 'approved'
       ORDER BY c.id DESC`,
    );

    res.json(rows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'تعذر تحميل السيارات',
    });
  }
});

app.post('/api/cars', auth, async (req, res) => {
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
    } = req.body;

    if (
      !brand ||
      !model ||
      !year ||
      !price ||
      !city
    ) {
      return res.status(400).json({
        message: 'أكمل بيانات السيارة',
      });
    }

    const [result] = await pool.execute(
      `INSERT INTO cars
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
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')`,
      [
        req.user.id,
        brand,
        model,
        Number(year),
        Number(price),
        Number(km || 0),
        city,
        fuel || 'بنزين',
        transmission || 'أوتوماتيك',
        description || '',
        plan || 'عادي',
      ],
    );

    res.status(201).json({
      message: 'تم إرسال السيارة للمراجعة',
      id: result.insertId,
      status: 'pending',
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'تعذر إنشاء إعلان السيارة',
    });
  }
});

app.get(
  '/api/admin/dashboard',
  auth,
  admin,
  async (_, res) => {
    try {
      const [[cars]] = await pool.query(
        `SELECT COUNT(*) AS count
         FROM cars`,
      );

      const [[users]] = await pool.query(
        `SELECT COUNT(*) AS count
         FROM users`,
      );

      const [[requests]] = await pool.query(
        `SELECT COUNT(*) AS count
         FROM cars
         WHERE status = 'pending'`,
      );

      res.json({
        cars_count: Number(cars.count),
        users_count: Number(users.count),
        requests_count: Number(requests.count),
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        message: 'تعذر تحميل لوحة الإدارة',
      });
    }
  },
);

const PORT = Number(
  process.env.PORT || 3000,
);

app.listen(PORT, '0.0.0.0', () => {
  console.log(
    `ZYOCAR server running on port ${PORT}`,
  );
});
