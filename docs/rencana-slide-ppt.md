# Rencana Slide Presentasi — VDKJ Tugas Final

**Durasi total: 20 menit** (presentasi 8 menit + demo 10 menit + Q&A 2 menit)

---

## Slide 1 — Judul (0:00 – 0:30)

- Judul: **Implementasi Arsitektur Jaringan Tersegmentasi**
- Subjudul: Virtualisasi dan Keamanan Jaringan
- Anggota kelompok (6 nama + NIM)
- Dosen pengampu: Henry Saptono, S.Si., M.Kom.
- STT Terpadu Nurul Fikri — Semester Genap 2025/2026

---

## Slide 2 — Latar Belakang & Tujuan (0:30 – 1:30)

**Latar Belakang:**
- Kebutuhan infrastruktur jaringan aman & tersegmentasi
- Pendekatan *defense in depth* — pertahanan berlapis
- Teknologi virtualisasi & containerisasi

**Tujuan (poin utama):**
1. Implementasi segmentasi jaringan 3 zona (External, DMZ, LAN)
2. Konfigurasi MikroTik CHR sebagai router & firewall
3. Deploy 2 web app dengan Docker + Nginx reverse proxy
4. Setup MySQL di LAN dengan akses terbatas
5. Implementasi Suricata IDS untuk deteksi serangan

---

## Slide 3 — Desain Arsitektur (1:30 – 3:00)

**Diagram topologi:**
```
[ External Network ]
        |
[ Router MikroTik CHR ]  ← ether1: WAN, ether2: DMZ, ether3: LAN
       / \
      /   \
[DMZ]     [LAN]
7.7.7.0/30  192.168.56.0/24
   |            |
[VM Ubuntu]  [DB Server]
Nginx +      MySQL/MariaDB
Suricata
Docker:
  App1 (Flask)
  App2 (PHP)
```

**Tabel IP Addressing:**

| Komponen | Interface | IP Address |
|----------|-----------|------------|
| MikroTik | ether1 (WAN) | DHCP (10.0.2.3) |
| MikroTik | ether2 (DMZ) | 7.7.7.1/30 |
| MikroTik | ether3 (LAN) | 192.168.56.2/24 |
| Ubuntu DMZ | enp0s3 | 7.7.7.2/30 |
| Ubuntu DB | enp0s3 | 192.168.56.10/24 |

---

## Slide 4 — Konfigurasi MikroTik CHR (3:00 – 4:30)

- 3 interface: WAN, DMZ, LAN
- DNS: 8.8.8.8, 8.8.4.4
- Routing default via ether1-wan

**Firewall rules (highlight):**

| Chain | Fungsi |
|-------|--------|
| INPUT | Drop semua kecuali ICMP, SSH dari LAN, DNS |
| FORWARD Ext→DMZ | Hanya port 80/443 ke Nginx |
| FORWARD DMZ→LAN | Hanya port 3306 dari 7.7.7.2 ke DB |
| FORWARD Ext→LAN | Drop semua |
| NAT | Masquerade + DNAT 80/443 → 7.7.7.2 |
| Address List | blocked_ips untuk IP mencurigakan |

*Catatan: live demo di slide ini (lihat tahapan-demo.md)*

---

## Slide 5 — VM Ubuntu & Docker (4:30 – 6:00)

**VM DMZ (7.7.7.2/30):**
- Hostname: ubuntu-dmz
- Layanan: Docker, Nginx, Suricata

**Docker Compose — 2 Container:**

| App | Stack | Port Container | Port Mapping |
|-----|-------|----------------|--------------|
| App1 | Python/Flask (Buku Tamu) | 5000 | 3000:5000 |
| App2 | PHP (Manajemen Produk) | 5000 | 8080:5000 |

- Non-root user (`1000:1000`)
- Environment variable untuk koneksi DB
- Dockerfile custom untuk kedua app

---

## Slide 6 — Nginx Reverse Proxy (6:00 – 7:00)

**Konfigurasi:**
- Upstream: `app1_backend` (127.0.0.1:5000), `app2_backend` (127.0.0.1:8080)
- Virtual host: `app1.vdkj.local`, `app2.vdkj.local`
- Default server block: return 444 (tolak request tidak dikenal)

**Security Headers:**
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`

**Logging:** access log + error log per app di `/var/log/nginx/`

---

## Slide 7 — Database Server & Suricata IDS (7:00 – 8:00)

**MySQL/MariaDB (LAN — 192.168.56.10):**
- 2 database: `app1_bukutamu`, `app2_produk`
- 2 user terpisah: `app1_user`, `app2_user`
- Firewall UFW: hanya port 3306 dari 7.7.7.2
- Skema + data dummy siap pengujian

**Suricata IDS:**
- Mode: IDS (passive monitoring)
- EVE JSON logging aktif
- 3 custom rules:
  1. SQL Injection detection (SID 1000001)
  2. XSS detection (SID 1000002)
  3. Port Scan detection (SID 1000003)

---

## Slide 8 — Konfigurasi Keamanan (Ringkasan) (8:00 – 8:30)

**Tabel lapisan keamanan:**

| Lapisan | Teknologi | Mekanisme |
|---------|-----------|-----------|
| Perimeter | MikroTik Firewall | Filter, NAT, rate limit, address list |
| Network | Segmentasi 3 zona | DMZ terisolasi dari LAN |
| Transport | Nginx Reverse Proxy | Sembunyikan port container, security headers |
| Application | Docker non-root | Isolasi container, env var |
| Database | MySQL + UFW | User terpisah, bind-address, firewall OS |
| Detection | Suricata IDS | Custom rules SQLi, XSS, port scan |

*→ Lanjut ke demo (lihat tahapan-demo.md)*

---

## Slide 9 — Hasil Pengujian (18:00 – 19:00)

**Tabel verifikasi (15 skenario):**

| No | Skenario | Hasil |
|----|----------|-------|
| 1 | Ping External → Router | ✅ |
| 2 | Ping DMZ → LAN | ✅ |
| 3 | Ping External → LAN langsung | ❌ Diblokir |
| 4 | HTTP/HTTPS ke Nginx | ✅ |
| 5 | Akses port container langsung | ❌ Diblokir |
| 6 | MySQL DMZ → DB | ✅ |
| 7 | MySQL External → DB | ❌ Diblokir |
| 8 | App via Nginx | ✅ |
| 9 | App baca/tulis MySQL | ✅ |
| 10 | Security headers ada | ✅ |
| 11 | Firewall DROP & rate limit | ✅ |
| 12 | SSH hanya dari LAN | ✅ |
| 13 | Suricata running | ✅ |
| 14 | Custom rules alert | ✅ (102 alert) |
| 15 | EVE JSON logging | ✅ |

---

## Slide 10 — Kendala & Solusi (19:00 – 19:30)

| Kendala | Solusi |
|---------|--------|
| Konflik port container | Port mapping berbeda (3000, 8080) + Nginx upstream |
| Container tidak konek MySQL | Bridge network + routing via gateway MikroTik |
| MySQL bind-address default 127.0.0.1 | Ubah ke 0.0.0.0 + UFW restrict |
| Suricata tidak detect traffic | Ganti interface eth0 → enp0s3 |
| Firewall blokir semua termasuk ICMP | Tambah rule accept ICMP + address list |
| Nginx config test gagal | Hapus default site, validasi `nginx -t` |

---

## Slide 11 — Kesimpulan & Saran (19:30 – 20:00)

**Kesimpulan:**
1. Arsitektur tersegmentasi 3 zona berhasil diimplementasikan
2. Firewall MikroTik efektif blokir akses tidak sah
3. 2 web app (Flask + PHP) terdeploy & terintegrasi MySQL
4. Nginx reverse proxy + security headers berfungsi baik
5. Suricata mendeteksi 102 alert (SQLi, XSS, port scan)
6. Database terisolasi di LAN dengan user terpisah + UFW

**Saran pengembangan:**
- TLS/HTTPS (Let's Encrypt)
- Suricata mode IPS (inline)
- Centralized logging (ELK Stack)
- Monitoring (Prometheus + Grafana)
- WAF (ModSecurity)
- Load balancing + automated backup

---

## Slide 12 — Terima Kasih & Q&A

- "Terima Kasih"
- Link video presentasi & file konfigurasi
- Siap untuk pertanyaan dari dosen
