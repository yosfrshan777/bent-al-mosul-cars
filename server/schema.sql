CREATE DATABASE IF NOT EXISTS zyocar CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE zyocar;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, name VARCHAR(120) NOT NULL, phone VARCHAR(30) NOT NULL,
  password VARCHAR(255) NOT NULL, role ENUM('user','seller','showroom','parts','admin','owner') NOT NULL DEFAULT 'user',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), UNIQUE KEY uq_users_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cars (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, user_id INT UNSIGNED NOT NULL, brand VARCHAR(100) NOT NULL, model VARCHAR(100) NOT NULL,
  year SMALLINT UNSIGNED NOT NULL, price INT UNSIGNED NOT NULL, km INT UNSIGNED NOT NULL DEFAULT 0, city VARCHAR(100) NOT NULL,
  fuel VARCHAR(50) NOT NULL DEFAULT 'بنزين', transmission VARCHAR(50) NOT NULL DEFAULT 'أوتوماتيك', description TEXT NULL,
  plan VARCHAR(30) NOT NULL DEFAULT 'عادي', status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), KEY idx_cars_user_id (user_id), KEY idx_cars_status (status),
  KEY idx_cars_created_at (created_at), CONSTRAINT fk_cars_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS car_images (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, car_id INT UNSIGNED NOT NULL, image VARCHAR(500) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), KEY idx_car_images_car_id (car_id),
  CONSTRAINT fk_car_images_car FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, user_id INT UNSIGNED NOT NULL, amount INT UNSIGNED NOT NULL,
  method VARCHAR(50) NOT NULL, status ENUM('pending','approved','rejected','completed') NOT NULL DEFAULT 'pending',
  phone VARCHAR(30) NULL, card_number VARCHAR(100) NULL, account_name VARCHAR(150) NULL, reference VARCHAR(150) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), KEY idx_payments_user_id (user_id), KEY idx_payments_status (status),
  CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, sender_id INT UNSIGNED NOT NULL, receiver_id INT UNSIGNED NOT NULL,
  text TEXT NOT NULL, is_read TINYINT(1) NOT NULL DEFAULT 0, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), KEY idx_messages_sender (sender_id), KEY idx_messages_receiver (receiver_id),
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payment_settings (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, phone VARCHAR(30) NULL, card_number VARCHAR(100) NULL,
  account_name VARCHAR(150) NULL, method VARCHAR(50) NOT NULL DEFAULT 'card',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS discounts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, code VARCHAR(40) NULL, target VARCHAR(30) NOT NULL DEFAULT 'all',
  percentage DECIMAL(5,2) NOT NULL DEFAULT 0, active TINYINT(1) NOT NULL DEFAULT 1, max_uses INT NULL,
  used_count INT NOT NULL DEFAULT 0, expires_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uq_discounts_code (code), KEY idx_discounts_target_active (target, active)
) ENGINE=InnoDB;

INSERT INTO payment_settings (phone,card_number,account_name,method)
SELECT NULL,NULL,NULL,'card' WHERE NOT EXISTS (SELECT 1 FROM payment_settings);
