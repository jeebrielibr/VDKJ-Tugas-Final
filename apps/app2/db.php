<?php
$host = getenv('DB_HOST') ?: '192.168.56.10';
$port = getenv('DB_PORT') ?: '3306';
$user = getenv('DB_USER') ?: 'app2_user';
$pass = getenv('DB_PASS') ?: 'app2_pass';
$dbname = getenv('DB_NAME') ?: 'app2_produk';

$conn = new mysqli($host, $user, $pass, $dbname, (int)$port);

if ($conn->connect_error) {
    die("Koneksi database gagal: " . $conn->connect_error);
}

$conn->set_charset("utf8mb4");
