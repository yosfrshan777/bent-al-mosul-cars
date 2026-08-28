require('dotenv').config();

const express = require('express');
const cors = require('cors');

const { testDatabase } = require('./db');

const authRoutes = require('./routes/auth');
const carRoutes = require('./routes/cars');
const adminRoutes = require('./routes/admin');
const paymentRoutes = require('./routes/payment');

const app = express();

app.use(cors());

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use(
  '/uploads',
  express.static('uploads'),
);

app.get('/', (_, res) => {
  res.json({
    name: 'ZYOCAR',
    message: 'ZYOCAR API is running',
    status: 'online',
  });
});

app.get('/api/health', async (_, res) => {
  try {
    await testDatabase();

    res.json({
      status: 'ok',
      database: 'connected',
    });
  } catch (error) {
    console.error(
      'DATABASE HEALTH ERROR:',
      error,
    );

    res.status(500).json({
      status: 'error',
      database: 'disconnected',
    });
  }
});

app.use(
  '/api/auth',
  authRoutes,
);

app.use(
  '/api/cars',
  carRoutes,
);

app.use(
  '/api/admin',
  adminRoutes,
);

app.use(
  '/api/payment',
  paymentRoutes,
);

app.use((req, res) => {
  res.status(404).json({
    message: 'الرابط غير موجود',
  });
});

app.use(
  (error, req, res, next) => {
    console.error(
      'SERVER ERROR:',
      error,
    );

    if (res.headersSent) {
      return next(error);
    }

    res.status(500).json({
      message:
        'حدث خطأ داخلي في السيرفر',
    });
  },
);

const PORT = Number(
  process.env.PORT || 3000,
);

async function startServer() {
  try {
    await testDatabase();

    app.listen(
      PORT,
      '0.0.0.0',
      () => {
        console.log(
          `ZYOCAR server running on port ${PORT}`,
        );
      },
    );
  } catch (error) {
    console.error(
      'FAILED TO START SERVER:',
      error,
    );

    process.exit(1);
  }
}

startServer();

module.exports = app;
