-- ============================================================
-- Database & user setup for VDKJ Tugas Final
-- Jalankan di MySQL/MariaDB server (LAN: 192.168.56.10)
-- ============================================================

-- App 1: Buku Tamu (Flask)
CREATE DATABASE IF NOT EXISTS app1_bukutamu
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'app1_user'@'%' IDENTIFIED BY 'app1_pass';
GRANT SELECT, INSERT, UPDATE, DELETE ON app1_bukutamu.* TO 'app1_user'@'%';

USE app1_bukutamu;

CREATE TABLE IF NOT EXISTS tamu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    pesan TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO tamu (nama, email, pesan) VALUES
    ('Budi Santoso', 'budi@example.com', 'Selamat atas proyek yang bagus!'),
    ('Siti Rahayu', 'siti@example.com', 'Sistem berjalan dengan lancar.'),
    ('Andi Wijaya', NULL, 'Sukses selalu untuk tim VDKJ.'),
    ('Dewi Lestari', 'dewi@example.com', 'Tertarik dengan arsitektur jaringannya.'),
    ('Rizky Pratama', 'rizky@example.com', 'Demo sangat informatif.');

-- App 2: Manajemen Produk (PHP)
CREATE DATABASE IF NOT EXISTS app2_produk
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'app2_user'@'%' IDENTIFIED BY 'app2_pass';
GRANT SELECT, INSERT, UPDATE, DELETE ON app2_produk.* TO 'app2_user'@'%';

USE app2_produk;

CREATE TABLE IF NOT EXISTS produk (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    harga DECIMAL(12,2) NOT NULL DEFAULT 0,
    stok INT NOT NULL DEFAULT 0,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO produk (nama, harga, stok, deskripsi) VALUES
    ('Router MikroTik hAP ac²', 850000, 25, 'Router Wi-Fi dual-band untuk jaringan kecil.'),
    ('Switch manageable 24-port', 2500000, 10, 'Switch L2 dengan VLAN dan SNMP.'),
    ('Kabel UTP Cat6 (100m)', 450000, 50, 'Kabel jaringan solid copper.'),
    ('Access Point UniFi', 1200000, 15, 'AP enterprise dengan controller.'),
    ('Server rack 12U', 3500000, 5, 'Rack cabinet dengan kipas pendingin.');

FLUSH PRIVILEGES;
