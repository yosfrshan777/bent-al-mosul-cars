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

async function safeAlter(connection, sql) {
  try { await connection.execute(sql); }
  catch (error) {
    if (!['ER_DUP_FIELDNAME', 'ER_DUP_KEYNAME'].includes(error.code)) throw error;
  }
}

async function testDatabase() {
  const connection = await pool.getConnection();
  try {
    await connection.ping();
    await connection.execute(`CREATE TABLE IF NOT EXISTS users (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(150) NOT NULL, phone VARCHAR(50) NOT NULL UNIQUE, password VARCHAR(255) NOT NULL, role VARCHAR(30) NOT NULL DEFAULT 'user', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id))`);
    await connection.execute(`CREATE TABLE IF NOT EXISTS cars (id INT NOT NULL AUTO_INCREMENT, user_id INT NOT NULL, brand VARCHAR(100) NOT NULL, model VARCHAR(100) NOT NULL, year INT NOT NULL, price INT NOT NULL, km INT DEFAULT 0, city VARCHAR(100) NOT NULL, body_type VARCHAR(50) NULL, category VARCHAR(50) NULL, fuel VARCHAR(50) DEFAULT 'بنزين', transmission VARCHAR(50) DEFAULT 'أوتوماتيك', description TEXT, plan VARCHAR(30) DEFAULT 'عادي', status VARCHAR(30) DEFAULT 'pending', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), INDEX idx_cars_user_id (user_id), INDEX idx_cars_status (status), CONSTRAINT fk_cars_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)`);
    await connection.execute(`CREATE TABLE IF NOT EXISTS car_images (id INT NOT NULL AUTO_INCREMENT, car_id INT NOT NULL, image TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), INDEX idx_car_images_car_id (car_id), CONSTRAINT fk_car_images_car FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE)`);
    await connection.execute(`CREATE TABLE IF NOT EXISTS payments (id INT NOT NULL AUTO_INCREMENT, user_id INT NOT NULL, amount INT NOT NULL, method VARCHAR(50) NOT NULL, status VARCHAR(30) DEFAULT 'pending', phone VARCHAR(50) NULL, card_number VARCHAR(100) NULL, account_name VARCHAR(150) NULL, reference VARCHAR(150) NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), INDEX idx_payments_user_id (user_id), INDEX idx_payments_status (status), CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)`);
    await connection.execute(`CREATE TABLE IF NOT EXISTS payment_settings (id INT NOT NULL AUTO_INCREMENT, phone VARCHAR(50) NULL, card_number VARCHAR(100) NULL, account_name VARCHAR(150) NULL, method VARCHAR(50) NOT NULL DEFAULT 'card', barcode_data TEXT NULL, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (id))`);
    await connection.execute(`CREATE TABLE IF NOT EXISTS showroom_requests (id INT NOT NULL AUTO_INCREMENT, user_id INT NOT NULL, name VARCHAR(150) NOT NULL, phone VARCHAR(50) NOT NULL, city VARCHAR(100) NOT NULL, amount INT NOT NULL DEFAULT 100000, status VARCHAR(30) NOT NULL DEFAULT 'pending', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), INDEX idx_showroom_requests_status (status), CONSTRAINT fk_showroom_requests_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)`);
    await connection.execute(`CREATE TABLE IF NOT EXISTS discounts (id INT NOT NULL AUTO_INCREMENT, target VARCHAR(30) NOT NULL, percentage DECIMAL(5,2) NOT NULL DEFAULT 0, active TINYINT(1) NOT NULL DEFAULT 1, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), INDEX idx_discounts_target_active (target, active))`);
    await connection.execute(`CREATE TABLE IF NOT EXISTS reels (id INT NOT NULL AUTO_INCREMENT, user_id INT NOT NULL, car_id INT NULL, video_url TEXT NOT NULL, caption VARCHAR(500) NULL, city VARCHAR(100) NULL, price INT NULL, status VARCHAR(30) NOT NULL DEFAULT 'pending', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), INDEX idx_reels_status (status), INDEX idx_reels_user_id (user_id), CONSTRAINT fk_reels_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, CONSTRAINT fk_reels_car FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE SET NULL)`);

    await safeAlter(connection, `ALTER TABLE users ADD COLUMN city VARCHAR(100) NULL`);
    await safeAlter(connection, `ALTER TABLE cars ADD COLUMN body_type VARCHAR(50) NULL`);
    await safeAlter(connection, `ALTER TABLE cars ADD COLUMN category VARCHAR(50) NULL`);
    await safeAlter(connection, `ALTER TABLE payment_settings ADD COLUMN barcode_data TEXT NULL`);
    await safeAlter(connection, `ALTER TABLE discounts ADD COLUMN code VARCHAR(40) NULL`);
    await safeAlter(connection, `ALTER TABLE discounts ADD COLUMN max_uses INT NULL`);
    await safeAlter(connection, `ALTER TABLE discounts ADD COLUMN used_count INT NOT NULL DEFAULT 0`);
    await safeAlter(connection, `ALTER TABLE discounts ADD COLUMN expires_at DATETIME NULL`);
    await safeAlter(connection, `ALTER TABLE discounts ADD UNIQUE KEY uq_discounts_code (code)`);

    await connection.execute(`INSERT INTO payment_settings (method) SELECT 'card' WHERE NOT EXISTS (SELECT 1 FROM payment_settings)`);
    const seedCodes = [['ZYO8K2',20],['ZYO4M7',15],['ZYO9P3',20],['ZYO2R8',15],['ZYO6T4',20],['ZYO1V9',15],['ZYO7X5',20],['ZYO3B6',15],['ZYO5D1',20],['ZYO9F8',15],['ZYO2H4',20],['ZYO6J7',15],['ZYO1L5',20],['ZYO8N3',15],['ZYO4Q9',20],['ZYO7S2',15],['ZYO3U6',20],['ZYO5W8',15],['ZYO9Y1',20],['ZYO2A7',15],['ZYO6C4',20],['ZYO1E9',15],['ZYO8G5',20],['ZYO4I2',15],['ZYO7K6',20]];
    for (const [code, percentage] of seedCodes) await connection.execute(`INSERT INTO discounts (code,target,percentage,active,max_uses,used_count) VALUES (?, 'all', ?, 1, NULL, 0) ON DUPLICATE KEY UPDATE code=VALUES(code)`, [code, percentage]);
    console.log('ZYOCAR database connected');
    console.log('ZYOCAR tables ready');
  } finally { connection.release(); }
}

module.exports = { pool, testDatabase };
