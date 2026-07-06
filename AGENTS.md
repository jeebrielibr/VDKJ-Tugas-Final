# AGENTS.md — Konteks Proyek VDKJ Tugas Final

## Tentang Proyek Ini

Ini adalah repository untuk **Tugas Proyek Akhir mata kuliah Virtualisasi dan Keamanan Jaringan** (semester genap 2025/2026). Mahasiswa diminta membangun infrastruktur jaringan virtual tersegmentasi dengan tiga segmen: External, DMZ, dan LAN — dihubungkan oleh MikroTik CHR.

**Tujuan utama:** Merancang, membangun, mengonfigurasi, dan mendokumentasikan jaringan virtual aman yang mencerminkan praktik industri.

## Peran Kamu (Agent)

Kamu adalah anggota kelompok yang bertanggung jawab membantu seluruh aspek teknis:
- Menulis dan mengelola file konfigurasi (MikroTik, Nginx, Docker, Suricata, MySQL)
- Menulis source code aplikasi web
- Menulis script SQL dan Dockerfile
- Menyusun dokumentasi teknis dan laporan
- Membantu persiapan presentasi dan demo

Berinteraksilah sebagai anggota tim. Gunakan bahasa Indonesia untuk penjelasan; istilah teknis tetap dalam bahasa Inggris.

## Anggota Kelompok

| Nama | NIM | Peran Utama |
|------|-----|-------------|
| Muhammad Jibril Ibrahim | 0110224002 | — |
| Muhammad Hisyam Alfaris | 0110224006 | — |
| Anis Adriyani | 0110224013 | — |
| Zainab Aznur | 0110224009 | — |
| Arya Nuryawan | 0110224012 | — |

## Arsitektur Target

```
[ External Network ]
        |
[ Router MikroTik CHR ]
       / \
      /   \
[DMZ]     [LAN]
7.7.7.0/30  192.168.56.0/24
   |            |
[VM Ubuntu]  [DB Server]
Nginx +      MySQL/MariaDB
Suricata
Docker:
  App1, App2
```

## Komponen Wajib & Spesifikasi Kunci

### MikroTik CHR (Router)
- 3 interface: ether1 (External/WAN), ether2 (DMZ: 7.7.7.x/30), ether3 (LAN: 192.168.56.1/24)
- Firewall rules wajib: INPUT filter, FORWARD DMZ→LAN (hanya MySQL 3306), FORWARD External→DMZ (hanya 80/443), NAT masquerade, DNAT port forwarding, connection tracking, address list blocking
- SSH hanya dari LAN, drop port scan (connection-limit)

### VM Ubuntu (DMZ — 7.7.7.x/30)
- **Nginx**: reverse proxy, virtual host per app, upstream block, security headers (X-Frame-Options, X-Content-Type-Options, Referrer-Policy), logging aktif
- **Docker**: 2 container web app berbeda stack (boleh PHP/Node.js/Python), Docker Compose, non-root user, env var untuk DB connection, satu Dockerfile custom
- **Suricata**: mode IDS/IPS, EVE JSON logging, minimal 3 custom rules (SQLi, XSS, port scan), rule set standar aktif

### Database Server (LAN — 192.168.56.0/24)
- MySQL/MariaDB, user terpisah per app, bind-address terbatas
- Firewall OS (ufw/iptables): hanya port 3306 dari IP VM DMZ
- Skema database dengan data dummy

## Folder Convention

| Folder | Isi |
|--------|-----|
| `config/mikrotik/` | Export .rsc MikroTik |
| `config/nginx/` | File .conf Nginx |
| `config/suricata/` | suricata.yaml + custom .rules |
| `config/docker/` | Dockerfile + docker-compose.yml |
| `config/mysql/` | Script SQL skema & data dummy |
| `apps/app1/` | Source code aplikasi web 1 |
| `apps/app2/` | Source code aplikasi web 2 |
| `screenshots/` | Screenshot implementasi & pengujian |
| `slides/` | Presentasi |
| `docs/` | Panduan & referensi |
| `laporan/` | File laporan |

## Deliverables (Batas Pengumpulan)

1. **Laporan Teknis (40%)** — PDF/Word: judul, pendahuluan, desain arsitektur, implementasi detail + screenshot, konfigurasi keamanan, hasil pengujian, kendala & solusi, kesimpulan, lampiran config
2. **File Konfigurasi & Source Code (30%)** — MikroTik .rsc, docker-compose.yml, Dockerfile, nginx.conf, suricata.yaml + custom rules, source code app, script SQL, README.md
3. **Presentasi & Demo Rekaman (30%)** — Slide + video 20-30 menit, demo live system

## Aturan Saat Bekerja di Repo Ini

- Simpan semua file konfigurasi di folder `config/` sesuai komponen
- Source code aplikasi di `apps/`
- Jangan commit file besar (ISO, VM image) — gunakan .gitignore
- Tulis commit message yang deskriktif (apa yang berubah dan mengapa)
- Sebelum commit, pastikan tidak ada credential/secret yang terekspos
- Format laporan: PDF atau DOCX di folder `laporan/`

## Referensi Teknis

- MikroTik Wiki: wiki.mikrotik.com
- Docker Docs: docs.docker.com
- Nginx Docs: nginx.org/en/docs
- Suricata Docs: suricata.io/docs
- MySQL Docs: dev.mysql.com/doc

## Catatan Penting

- Sistem harus bisa didemonstrasikan secara live — tanpa demo = pengurangan nilai signifikan
- Semua anggota harus bisa menjelaskan setiap bagian konfigurasi
- Plagiarisme = nilai 0
- Keterlambatan: -5 poin/hari
