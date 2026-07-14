CREATE DATABASE IF NOT EXISTS app1_db;
CREATE DATABASE IF NOT EXISTS app2_db;

CREATE USER IF NOT EXISTS 'app1_user'@'7.7.7.2' IDENTIFIED BY 'password_app1';
GRANT ALL PRIVILEGES ON app1_db.* TO 'app1_user'@'7.7.7.2';

CREATE USER IF NOT EXISTS 'app2_user'@'7.7.7.2' IDENTIFIED BY 'password_app2';
GRANT ALL PRIVILEGES ON app2_db.* TO 'app2_user'@'7.7.7.2';

FLUSH PRIVILEGES;

USE app1_db;
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO notes (title, content) VALUES
('Catatan 1 dari App1', 'Ini adalah isi dari catatan pertama.'),
('Catatan 2 dari App1', 'Ini adalah isi dari catatan kedua.');

USE app2_db;
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tasks (task_name, description) VALUES
('Tugas 1 dari App2', 'Deskripsi untuk tugas pertama.'),
('Tugas 2 dari App2', 'Deskripsi untuk tugas kedua.');