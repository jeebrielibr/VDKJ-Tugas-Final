<?php
require_once 'db.php';

$action = $_GET['action'] ?? 'list';
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

// Handle POST actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $post_action = $_POST['action'] ?? '';

    if ($post_action === 'create') {
        $nama = $conn->real_escape_string($_POST['nama']);
        $harga = (float)$_POST['harga'];
        $stok = (int)$_POST['stok'];
        $deskripsi = $conn->real_escape_string($_POST['deskripsi']);
        $conn->query("INSERT INTO produk (nama, harga, stok, deskripsi) VALUES ('$nama', $harga, $stok, '$deskripsi')");
        header('Location: index.php?msg=Produk berhasil ditambahkan');
        exit;
    }

    if ($post_action === 'update') {
        $id = (int)$_POST['id'];
        $nama = $conn->real_escape_string($_POST['nama']);
        $harga = (float)$_POST['harga'];
        $stok = (int)$_POST['stok'];
        $deskripsi = $conn->real_escape_string($_POST['deskripsi']);
        $conn->query("UPDATE produk SET nama='$nama', harga=$harga, stok=$stok, deskripsi='$deskripsi' WHERE id=$id");
        header('Location: index.php?msg=Produk berhasil diperbarui');
        exit;
    }

    if ($post_action === 'delete') {
        $id = (int)$_POST['id'];
        $conn->query("DELETE FROM produk WHERE id=$id");
        header('Location: index.php?msg=Produk berhasil dihapus');
        exit;
    }
}

// Fetch single product for edit
$produk = null;
if ($action === 'edit' && $id > 0) {
    $result = $conn->query("SELECT * FROM produk WHERE id=$id");
    $produk = $result->fetch_assoc();
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manajemen Produk</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 900px; margin: 2rem auto; padding: 0 1rem; background: #f5f5f5; }
        h1 { color: #333; }
        table { width: 100%; border-collapse: collapse; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,.1); }
        th, td { padding: .75rem 1rem; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #27ae60; color: #fff; }
        .btn { display: inline-block; padding: .4rem .8rem; border-radius: 4px; text-decoration: none; color: #fff; font-size: .85rem; border: none; cursor: pointer; }
        .btn-primary { background: #3498db; }
        .btn-success { background: #27ae60; }
        .btn-warning { background: #f39c12; }
        .btn-danger { background: #e74c3c; }
        .msg { padding: .75rem 1rem; margin-bottom: 1rem; background: #d4edda; color: #155724; border-radius: 4px; }
        .error { color: #e74c3c; padding: 1rem; background: #fff; border-radius: 4px; }
        form.inline { display: inline; }
        .form-box { background: #fff; padding: 1.5rem; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,.1); margin-bottom: 1rem; }
        label { display: block; margin-top: 1rem; font-weight: bold; color: #555; }
        input, textarea { width: 100%; padding: .5rem; margin-top: .3rem; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        textarea { height: 80px; resize: vertical; }
        a.back { display: inline-block; margin-top: 1rem; color: #3498db; }
    </style>
</head>
<body>
    <h1>&#128230; Manajemen Produk</h1>

    <?php if (isset($_GET['msg'])): ?>
        <div class="msg"><?= htmlspecialchars($_GET['msg']) ?></div>
    <?php endif; ?>

    <?php if ($action === 'list'): ?>
        <a href="index.php?action=create" class="btn btn-primary">+ Tambah Produk</a>
        <hr>
        <?php
        $result = $conn->query("SELECT * FROM produk ORDER BY created_at DESC");
        if ($result && $result->num_rows > 0):
        ?>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nama</th>
                    <th>Harga (Rp)</th>
                    <th>Stok</th>
                    <th>Deskripsi</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
            <?php while ($row = $result->fetch_assoc()): ?>
                <tr>
                    <td><?= $row['id'] ?></td>
                    <td><?= htmlspecialchars($row['nama']) ?></td>
                    <td><?= number_format($row['harga'], 0, ',', '.') ?></td>
                    <td><?= $row['stok'] ?></td>
                    <td><?= htmlspecialchars($row['deskripsi']) ?></td>
                    <td>
                        <a href="index.php?action=edit&id=<?= $row['id'] ?>" class="btn btn-warning">Edit</a>
                        <form class="inline" method="post" onsubmit="return confirm('Hapus produk ini?')">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<?= $row['id'] ?>">
                            <button type="submit" class="btn btn-danger">Hapus</button>
                        </form>
                    </td>
                </tr>
            <?php endwhile; ?>
            </tbody>
        </table>
        <?php else: ?>
            <p style="color:#999;text-align:center;">Belum ada produk.</p>
        <?php endif; ?>

    <?php elseif ($action === 'create' || $action === 'edit'): ?>
        <div class="form-box">
            <h2><?= $action === 'create' ? 'Tambah' : 'Edit' ?> Produk</h2>
            <form method="post">
                <input type="hidden" name="action" value="<?= $action === 'create' ? 'create' : 'update' ?>">
                <?php if ($produk): ?>
                    <input type="hidden" name="id" value="<?= $produk['id'] ?>">
                <?php endif; ?>

                <label>Nama Produk *</label>
                <input type="text" name="nama" value="<?= htmlspecialchars($produk['nama'] ?? '') ?>" required>

                <label>Harga (Rp) *</label>
                <input type="number" name="harga" step="1000" min="0" value="<?= $produk['harga'] ?? '' ?>" required>

                <label>Stok *</label>
                <input type="number" name="stok" min="0" value="<?= $produk['stok'] ?? '' ?>" required>

                <label>Deskripsi</label>
                <textarea name="deskripsi"><?= htmlspecialchars($produk['deskripsi'] ?? '') ?></textarea>

                <button type="submit" class="btn btn-success"><?= $action === 'create' ? 'Simpan' : 'Perbarui' ?></button>
            </form>
        </div>
        <a href="index.php" class="back">&larr; Kembali ke Daftar Produk</a>
    <?php endif; ?>
</body>
</html>
