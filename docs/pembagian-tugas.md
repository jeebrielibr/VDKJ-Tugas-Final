# Pembagian Tugas & Rencana Kerja

## Anggota & Peran

| No | Nama | NIM | Peran |
|----|------|-----|-------|
| 1 | - | - | **Network Engineer** — MikroTik CHR, firewall, routing, NAT |
| 2 | - | - | **System Administrator** — VM Ubuntu, Nginx, Suricata |
| 3 | - | - | **DevOps / Developer** — Docker, Docker Compose, aplikasi web |
| 4 | - | - | **Database Administrator** — MySQL/MariaDB, skema DB, keamanan DB |
| 5 | - | - | **Documentation & QA** — Laporan, pengujian, slide presentasi |

> Setiap anggota wajib bisa menjelaskan seluruh bagian konfigurasi saat presentasi/demo.

---

## Daftar Task per Peran

### 1. Network Engineer

| # | Task | Milestone | Status |
|---|------|-----------|--------|
| 1.1 | Desain topologi jaringan & skema IP address | Minggu 1-2 | [ ] |
| 1.2 | Install & setup MikroTik CHR di hypervisor | Minggu 1-2 | [ ] |
| 1.3 | Konfigurasi interface: ether1 (WAN), ether2 (DMZ 7.7.7.x/30), ether3 (LAN 192.168.56.1/24) | Minggu 3-4 | [ ] |
| 1.4 | Konfigurasi IP address & DNS client pada router | Minggu 3-4 | [ ] |
| 1.5 | Konfigurasi routing default & static route | Minggu 3-4 | [ ] |
| 1.6 | Firewall INPUT: drop semua kecuali management, izinkan ICMP, SSH hanya dari LAN, drop port scan | Minggu 3-4 | [ ] |
| 1.7 | Firewall FORWARD DMZ→LAN: izinkan hanya port 3306 dari VM DMZ ke DB Server | Minggu 3-4 | [ ] |
| 1.8 | Firewall FORWARD External→DMZ: izinkan 80/443 ke Nginx, blokir port container langsung | Minggu 3-4 | [ ] |
| 1.9 | NAT masquerade pada interface external | Minggu 3-4 | [ ] |
| 1.10 | DNAT port forwarding 80/443 → IP VM DMZ | Minggu 3-4 | [ ] |
| 1.11 | Connection state tracking (accept established/related, drop invalid) | Minggu 3-4 | [ ] |
| 1.12 | Firewall address list untuk blokir IP mencurigakan | Minggu 8 | [ ] |
| 1.13 | Rate limiting untuk DDoS sederhana | Minggu 8 | [ ] |
| 1.14 | Export konfigurasi MikroTik (.rsc) | Minggu 9 | [ ] |
| 1.15 | Pengujian konektivitas & firewall (ping, akses port, SSH) | Minggu 9 | [ ] |

### 2. System Administrator

| # | Task | Milestone | Status |
|---|------|-----------|--------|
| 2.1 | Buat VM Ubuntu Server (20.04 LTS+) di segmen DMZ (7.7.7.x/30) | Minggu 1-2 | [ ] |
| 2.2 | Konfigurasi network interface VM (IP statis di subnet DMZ) | Minggu 1-2 | [ ] |
| 2.3 | Install & konfigurasi Nginx sebagai reverse proxy | Minggu 7 | [ ] |
| 2.4 | Buat virtual host (server block) untuk App 1 dan App 2 | Minggu 7 | [ ] |
| 2.5 | Konfigurasi upstream block & proxy_pass ke container Docker | Minggu 7 | [ ] |
| 2.6 | Tambahkan security headers (X-Frame-Options, X-Content-Type-Options, Referrer-Policy) | Minggu 7 | [ ] |
| 2.7 | Aktifkan access log & error log Nginx | Minggu 7 | [ ] |
| 2.8 | Install Suricata pada VM DMZ | Minggu 8 | [ ] |
| 2.9 | Konfigurasi Suricata mode IDS/IPS, EVE JSON logging | Minggu 8 | [ ] |
| 2.10 | Aktifkan rule set standar (Suricata built-in / Emerging Threats) | Minggu 8 | [ ] |
| 2.11 | Buat minimal 3 custom rules (SQLi, XSS, port scan detection) | Minggu 8 | [ ] |
| 2.12 | Verifikasi Suricata aktif & alert berfungsi | Minggu 9 | [ ] |
| 2.13 | Export file konfigurasi (nginx.conf, suricata.yaml, custom .rules) | Minggu 9 | [ ] |

### 3. DevOps / Developer

| # | Task | Milestone | Status |
|---|------|-----------|--------|
| 3.1 | Pilih tech stack untuk kedua aplikasi web (misal: Python/Flask & Node.js/Express) | Minggu 1-2 | [ ] |
| 3.2 | Buat source code App 1 (web app fungsional dengan CRUD) | Minggu 5-6 | [ ] |
| 3.3 | Buat source code App 2 (web app fungsional dengan CRUD) | Minggu 5-6 | [ ] |
| 3.4 | Buat Dockerfile custom untuk minimal satu aplikasi | Minggu 5-6 | [ ] |
| 3.5 | Pastikan container tidak berjalan sebagai root (non-root user) | Minggu 5-6 | [ ] |
| 3.6 | Buat docker-compose.yml untuk kedua container | Minggu 5-6 | [ ] |
| 3.7 | Konfigurasi environment variable untuk koneksi DB (host, port, user, password, dbname) | Minggu 5-6 | [ ] |
| 3.8 | Pastikan aplikasi bisa koneksi ke MySQL di LAN (192.168.56.x) | Minggu 7 | [ ] |
| 3.9 | Integrasi & testing end-to-end (app → Nginx → DB) | Minggu 9 | [ ] |
| 3.10 | Buat README.md cara menjalankan/replikasi setup | Minggu 10 | [ ] |

### 4. Database Administrator

| # | Task | Milestone | Status |
|---|------|-----------|--------|
| 4.1 | Buat VM/server di segmen LAN (192.168.56.x/24) | Minggu 1-2 | [ ] |
| 4.2 | Install MySQL Server / MariaDB | Minggu 5-6 | [ ] |
| 4.3 | Konfigurasi bind-address agar hanya terima koneksi dari subnet yang diizinkan | Minggu 5-6 | [ ] |
| 4.4 | Buat database & user terpisah untuk App 1 dan App 2 | Minggu 5-6 | [ ] |
| 4.5 | Buat skema database (tabel-tabel) sesuai kebutuhan aplikasi | Minggu 5-6 | [ ] |
| 4.6 | Isi data dummy untuk pengujian | Minggu 5-6 | [ ] |
| 4.7 | Konfigurasi firewall OS (ufw/iptables): hanya izinkan port 3306 dari IP VM DMZ | Minggu 7 | [ ] |
| 4.8 | Buat script SQL (CREATE DATABASE, CREATE TABLE, INSERT data dummy) | Minggu 7 | [ ] |
| 4.9 | Testing koneksi dari VM DMZ ke DB Server | Minggu 9 | [ ] |
| 4.10 | Verifikasi akses dari external langsung ditolak | Minggu 9 | [ ] |

### 5. Documentation & QA

| # | Task | Milestone | Status |
|---|------|-----------|--------|
| 5.1 | Buat template laporan (judul, struktur sesuai panduan) | Minggu 1-2 | [ ] |
| 5.2 | Dokumentasikan desain arsitektur & diagram jaringan | Minggu 1-2 | [ ] |
| 5.3 | Kumpulkan & susun screenshot setiap langkah konfigurasi | Minggu 3-8 | [ ] |
| 5.4 | Tulis bagian Pendahuluan (latar belakang, tujuan, ruang lingkup) | Minggu 5-6 | [ ] |
| 5.5 | Tulis bagian Implementasi (langkah konfigurasi tiap komponen + screenshot) | Minggu 7-8 | [ ] |
| 5.6 | Tulis bagian Konfigurasi Keamanan (firewall rules + justifikasi, Suricata rules) | Minggu 8 | [ ] |
| 5.7 | Koordinasi & jalankan seluruh skenario pengujian (Section 4 panduan) | Minggu 9 | [ ] |
| 5.8 | Dokumentasikan hasil pengujian (screenshot & analisis) | Minggu 9 | [ ] |
| 5.9 | Tulis bagian Kendala & Solusi, Kesimpulan dan Saran | Minggu 10 | [ ] |
| 5.10 | Susun lampiran (file konfigurasi lengkap) | Minggu 10 | [ ] |
| 5.11 | Buat slide presentasi (PowerPoint/PDF) | Minggu 10 | [ ] |
| 5.12 | Rekam demo presentasi (20-30 menit) | Minggu 10 | [ ] |
| 5.13 | Review & finalisasi laporan (PDF) | Minggu 10 | [ ] |

---

## Timeline & Milestone

| Minggu | Fase | Aktivitas Utama |
|--------|------|-----------------|
| 1-2 | Perencanaan & Setup | Desain arsitektur, pembagian tugas, instalasi hypervisor, buat VM dasar |
| 3-4 | Infrastruktur Jaringan | Konfigurasi MikroTik CHR: interface, IP, routing, firewall rules dasar |
| 5-6 | VM & Containerisasi | Setup VM Ubuntu DMZ, install Docker, buat & deploy kedua container web app, setup MySQL di LAN |
| 7 | Nginx & Database | Konfigurasi Nginx reverse proxy, integrasi app ↔ DB, firewall DB |
| 8 | Keamanan & IDS | Install Suricata, custom rules, hardening firewall MikroTik lanjutan |
| 9 | Pengujian & Debugging | Jalankan semua skenario pengujian, perbaiki bug, screenshot hasil |
| 10 | Laporan & Presentasi | Finalisasi laporan, slide, rekaman demo |

---

## Skenario Pengujian (QA Checklist)

### Konektivitas Dasar
- [ ] Ping dari External ke Router — berhasil
- [ ] Ping dari DMZ ke LAN — berhasil
- [ ] Ping dari External ke LAN langsung — **gagal** (diblokir firewall)
- [ ] Akses HTTP/HTTPS ke Nginx dari external — berhasil
- [ ] Akses langsung ke port container dari external — **gagal**
- [ ] Koneksi MySQL dari VM DMZ ke DB Server — berhasil
- [ ] Koneksi MySQL dari external langsung — **gagal**

### Aplikasi Web
- [ ] App 1 dapat diakses via Nginx reverse proxy
- [ ] App 2 dapat diakses via Nginx reverse proxy
- [ ] Kedua app berhasil baca/tulis data ke MySQL di LAN
- [ ] Nginx access log mencatat request
- [ ] Security headers ada di response HTTP

### Firewall MikroTik
- [ ] Rule DROP External→LAN berfungsi
- [ ] Rate limiting aktif
- [ ] Address list blocking berfungsi
- [ ] Connection state tracking: packet INVALID di-drop
- [ ] Hanya port 80/443 bisa diakses dari External ke DMZ
- [ ] SSH ke router hanya dari LAN

### Suricata IDS/IPS
- [ ] Suricata berjalan aktif & memproses traffic
- [ ] Alert muncul saat simulasi serangan (Nmap scan)
- [ ] Custom rules memicu alert saat traffic cocok
- [ ] Log EVE JSON dapat dibaca & dianalisis

---

## Catatan

- Semua file konfigurasi disimpan di folder `config/` sesuai komponen
- Source code aplikasi di `apps/`
- Screenshot pengujian di `screenshots/`
- File laporan di `laporan/`
- Jangan commit file besar (ISO, VM image) — gunakan `.gitignore`
- Pastikan tidak ada credential/secret yang terekspos sebelum commit
