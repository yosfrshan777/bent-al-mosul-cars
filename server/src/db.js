const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

async function testDatabase() {
  const connection = await pool.getConnection();

  try {
    await connection.ping();

    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT NOT NULL AUTO_INCREMENT,
        name VARCHAR(150) NOT NULL,
        phone VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(30) NOT NULL DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
      )
    `);

    await connection.execute(`
      CREATE TABLE IF NOT EXISTS cars (
        id INT NOT NULL AUTO_INCREMENT,
        user_id INT NOT NULL,
        brand VARCHAR(100) NOT NULL,
        model VARCHAR(100) NOT NULL,
        year INT NOT NULL,
        price INT NOT NULL,
        km INT DEFAULT 0,
        city VARCHAR(100) NOT NULL,
        fuel VARCHAR(50) DEFAULT 'بنزين',
        transmission VARCHAR(50) DEFAULT 'أوتوماتيك',
        description TEXT,
        plan VARCHAR(30) DEFAULT 'عادي',
        status VARCHAR(30) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        INDEX idx_cars_user_id (user_id),
        INDEX idx_cars_status (status),
        CONSTRAINT fk_cars_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    await connection.execute(`
      CREATE TABLE IF NOT EXISTS car_images (
        id INT NOT NULL AUTO_INCREMENT,
        car_id INT NOT NULL,
        image TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        INDEX idx_car_images_car_id (car_id),
        CONSTRAINT fk_car_images_car FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE
      )
    `);

    await connection.execute(`
      CREATE TABLE IF NOT EXISTS discounts (
        id INT NOT NULL AUTO_INCREMENT,
        target VARCHAR(30) NOT NULL,
        percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
        active TINYINT(1) NOT NULL DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        INDEX idx_discounts_target_active (target, active)
      )
    `);

    console.log('ZYOCAR database connected');
    console.log('ZYOCAR tables ready');
  } finally {
    connection.release();
  }
}

module.exports = {
  pool,
  testDatabase,
};
