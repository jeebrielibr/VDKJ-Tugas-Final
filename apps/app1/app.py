import os
from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "change-me-in-production")

DB_CONFIG = {
    "host": os.environ.get("DB_HOST", "192.168.56.10"),
    "port": int(os.environ.get("DB_PORT", 3306)),
    "user": os.environ.get("DB_USER", "app1_user"),
    "password": os.environ.get("DB_PASS", "app1_pass"),
    "database": os.environ.get("DB_NAME", "app1_bukutamu"),
}


def get_db():
    return mysql.connector.connect(**DB_CONFIG)


def init_db():
    """Auto-create table if not exists (fallback when SQL script not yet run)."""
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS tamu (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nama VARCHAR(100) NOT NULL,
                email VARCHAR(150),
                pesan TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """
        )
        conn.commit()
        cursor.close()
        conn.close()
    except Error:
        pass  # DB might not be reachable yet; table created via SQL script


@app.route("/")
def index():
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM tamu ORDER BY created_at DESC")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return render_template("index.html", tamu_list=rows)
    except Error as e:
        return render_template("index.html", tamu_list=[], error=str(e))


@app.route("/tambah", methods=["GET", "POST"])
def tambah():
    if request.method == "POST":
        nama = request.form["nama"]
        email = request.form.get("email", "")
        pesan = request.form["pesan"]
        try:
            conn = get_db()
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO tamu (nama, email, pesan) VALUES (%s, %s, %s)",
                (nama, email, pesan),
            )
            conn.commit()
            cursor.close()
            conn.close()
            flash("Pesan berhasil ditambahkan!", "success")
            return redirect(url_for("index"))
        except Error as e:
            flash(f"Gagal menyimpan: {e}", "danger")
    return render_template("form.html", action="Tambah", tamu=None)


@app.route("/edit/<int:id>", methods=["GET", "POST"])
def edit(id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    if request.method == "POST":
        nama = request.form["nama"]
        email = request.form.get("email", "")
        pesan = request.form["pesan"]
        try:
            cursor.execute(
                "UPDATE tamu SET nama=%s, email=%s, pesan=%s WHERE id=%s",
                (nama, email, pesan, id),
            )
            conn.commit()
            flash("Pesan berhasil diperbarui!", "success")
            return redirect(url_for("index"))
        except Error as e:
            flash(f"Gagal memperbarui: {e}", "danger")
    cursor.execute("SELECT * FROM tamu WHERE id = %s", (id,))
    tamu = cursor.fetchone()
    cursor.close()
    conn.close()
    return render_template("form.html", action="Edit", tamu=tamu)


@app.route("/hapus/<int:id>", methods=["POST"])
def hapus(id):
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM tamu WHERE id = %s", (id,))
        conn.commit()
        cursor.close()
        conn.close()
        flash("Pesan berhasil dihapus!", "success")
    except Error as e:
        flash(f"Gagal menghapus: {e}", "danger")
    return redirect(url_for("index"))


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=os.environ.get("FLASK_DEBUG", "0") == "1")
