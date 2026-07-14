# Tahapan Demo — VDKJ Tugas Final

**Durasi demo: 10 menit** (8:30 – 18:30 dalam timeline presentasi)

> **Sebelum rekaman:** Pastikan semua VM (MikroTik, Ubuntu DMZ, Ubuntu DB) sudah running, Docker container sudah up, Suricata sudah aktif.

---

## Demo 1 — MikroTik CHR: Interface, IP & Routing (8:30 – 10:30)

**Tujuan:** Tunjukkan konfigurasi dasar router dan segmentasi jaringan.

### Login ke MikroTik (via Winbox atau SSH dari LAN)

```
ssh admin@192.168.56.1
```

### 1.1 Tampilkan Interface List

```
/interface print
/interface list member print
```

**Ekspektasi:** 3 interface — `ether1-wan`, `ether2-dmz`, `ether3-lan`

### 1.2 Tampilkan IP Address

```
/ip address print
```

**Ekspektasi:**
- ether2-dmz: 7.7.7.1/30
- ether3-lan: 192.168.56.2/24
- ether1-wan: DHCP (10.0.2.x)

### 1.3 Tampilkan Route Table

```
/ip route print
```

**Ekspektasi:** Default route via ether1-wan

### 1.4 Tampilkan Firewall Filter Rules

```
/ip firewall filter print
```

**Ekspektasi:** Jelaskan secara singkat:
- Rules 0-3: Connection tracking (established/related accept, invalid drop)
- Rules 4-5: ICMP & SSH dari LAN only
- Rules 6-7: FORWARD Ext→DMZ (80/443 only)
- Rules 8-9: FORWARD DMZ→LAN (3306 only)
- Rule 10: Drop External→LAN

### 1.5 Tampilkan NAT Rules

```
/ip firewall nat print
```

**Ekspektasi:**
- Masquerade untuk outbound
- DNAT port 80/443 → 7.7.7.2 (Nginx)

---

## Demo 2 — Docker & Aplikasi Web (10:30 – 12:00)

**Tujuan:** Tunjukkan 2 container berjalan dan aplikasi bisa diakses.

### SSH ke VM DMZ

```
ssh user@7.7.7.2
```

### 2.1 Cek Docker Container

```bash
docker ps
```

**Ekspektasi:** 2 container running — `web-app1` (port 3000) dan `web-app2` (port 8080)

### 2.2 Tampilkan Docker Compose

```bash
cat /path/to/docker-compose.yml
```

**Ekspektasi:** Jelaskan:
- 2 service (app1 Flask, app2 PHP)
- Port mapping: 3000:5000, 8080:5000
- Environment variable DB_HOST=192.168.56.10
- Non-root user: `1000:1000`
- Network: bridge `dmz_network`

### 2.3 Tes Akses App Langsung (tanpa Nginx)

```bash
curl http://127.0.0.1:3000
curl http://127.0.0.1:8080
```

**Ekspektasi:** HTML response dari masing-masing app

---

## Demo 3 — Nginx Reverse Proxy & Security Headers (12:00 – 13:30)

**Tujuan:** Tunjukkan Nginx sebagai entry point dan security headers.

### 3.1 Cek Status Nginx

```bash
sudo systemctl status nginx
```

**Ekspektasi:** `active (running)`

### 3.2 Tes Validasi Konfigurasi

```bash
sudo nginx -t
```

**Ekspektasi:** `syntax is ok`, `test is successful`

### 3.3 Tampilkan Konfigurasi Nginx

```bash
cat /etc/nginx/sites-available/vdkj-apps.conf
```

**Ekspektasi:** Jelaskan upstream block, virtual host, security headers, logging

### 3.4 Tes Akses via Nginx + Cek Security Headers

```bash
curl -I http://127.0.0.1 -H "Host: app1.vdkj.local"
curl -I http://127.0.0.1 -H "Host: app2.vdkj.local"
```

**Ekspektasi:** Response headers memuat:
```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
```

### 3.5 Tes Default Server Block (request tidak dikenal)

```bash
curl -I http://127.0.0.1 -H "Host: unknown.local"
```

**Ekspektasi:** Connection ditutup (return 444)

---

## Demo 4 — Database Server & Konektivitas (13:30 – 15:00)

**Tujuan:** Tunjukkan isolasi database — hanya bisa diakses dari DMZ.

### 4.1 Dari VM DMZ — Koneksi MySQL Berhasil

```bash
mysql -h 192.168.56.10 -u app1_user -papp1_pass -e "USE app1_bukutamu; SELECT * FROM tamu;"
```

**Ekspektasi:** Tampilkan 5 baris data dummy buku tamu

```bash
mysql -h 192.168.56.10 -u app2_user -papp2_pass -e "USE app2_produk; SELECT * FROM produk;"
```

**Ekspektasi:** Tampilkan 5 baris data dummy produk

### 4.2 Tampilkan User & Database Terpisah

```bash
mysql -h 192.168.56.10 -u app1_user -papp1_pass -e "SHOW GRANTS;"
```

**Ekspektasi:** Hanya hak akses ke `app1_bukutamu`

### 4.3 Cek Firewall UFW di DB Server

*(SSH ke DB server atau buka terminal terpisah)*

```bash
ssh user@192.168.56.10
sudo ufw status
```

**Ekspektasi:**
```
3306/tcp    ALLOW    7.7.7.2
```

### 4.4 Tes: Koneksi MySQL dari External (DITOLAK)

*(Dari host/luar jaringan, atau dari MikroTik)*

```
# Di MikroTik:
/tool fetch url="http://192.168.56.10:3306"
```

**Ekspektasi:** Gagal / timeout — diblokir firewall MikroTik + UFW

---

## Demo 5 — Firewall MikroTik: Blocking Test (15:00 – 16:30)

**Tujuan:** Buktikan firewall memblokir akses yang tidak diizinkan.

### 5.1 Ping dari External ke LAN (DITOLAK)

```
# Di MikroTik (simulasi dari external):
/ping 192.168.56.10 src-address=10.0.2.3
```

**Ekspektasi:** `timeout` — diblokir rule "Drop all External to LAN"

### 5.2 Akses Port Container dari External (DITOLAK)

*(Dari komputer host/luar)*

```bash
curl http://10.0.2.3:3000
curl http://10.0.2.3:8080
```

**Ekspektasi:** Connection refused / timeout — port container tidak di-forward

### 5.3 Tampilkan Connection Tracking

```
/ip firewall connection print
```

**Ekspektasi:** Hanya koneksi established/related yang aktif

### 5.4 Tampilkan Address List

```
/ip firewall address-list print
```

**Ekspektasi:** List `blocked_ips` (kosong atau berisi IP yang sudah ditambahkan manual)

---

## Demo 6 — Suricata IDS: Deteksi Serangan (16:30 – 18:30)

**Tujuan:** Tunjukkan Suricata mendeteksi aktivitas mencurigakan.

### 6.1 Cek Status Suricata

```bash
sudo systemctl status suricata
```

**Ekspektasi:** `active (running)`

### 6.2 Tampilkan Custom Rules

```bash
cat /var/lib/suricata/rules/custom-vdkj.rules
```

**Ekspektasi:** 3 rules — SQL Injection (SID 1000001), XSS (SID 1000002), Port Scan (SID 1000003)

### 6.3 Simulasi SQL Injection

```bash
curl "http://127.0.0.1:3000/search?id=1' UNION SELECT * FROM users--"
```

**Ekspektasi:** Request tetap diproses (mode IDS, bukan blokir)

### 6.4 Simulasi XSS

```bash
curl -X POST http://127.0.0.1:3000/comment -d "input=<script>alert('xss')</script>"
```

### 6.5 Simulasi Port Scan (dari luar atau localhost)

```bash
nmap -sS -p 1-100 7.7.7.2
```

### 6.6 Cek Alert di fast.log

```bash
sudo tail -20 /var/log/suricata/fast.log
```

**Ekspektasi:** Alert muncul:
```
[**] [1:1000001:1] VDKJ - Possible SQL Injection Detected [**]
[**] [1:1000002:1] VDKJ - Possible XSS Attack Detected [**]
[**] [1:1000003:1] VDKJ - Possible Port Scan Detected [**]
```

### 6.7 Cek EVE JSON Log

```bash
sudo tail -5 /var/log/suricata/eve.json | python3 -m json.tool
```

**Ekspektasi:** JSON terstruktur dengan field `event_type: alert`, `signature_id`, `src_ip`, `dst_ip`

### 6.8 Cek Total Alert

```bash
sudo grep -c "alert" /var/log/suricata/fast.log
```

**Ekspektasi:** Total alert (≈102 sesuai laporan)

---

## Checklist Sebelum Rekaman

- [ ] MikroTik CHR running, bisa SSH dari LAN
- [ ] VM DMZ (7.7.7.2) running, Docker container up
- [ ] VM DB (192.168.56.10) running, MySQL aktif, UFW aktif
- [ ] Nginx aktif, config test OK
- [ ] Suricata aktif, custom rules ter-load
- [ ] Semua command sudah di-test sebelum rekaman
- [ ] Terminal/siap dengan 3 tab: MikroTik SSH, VM DMZ SSH, VM DB SSH
- [ ] Browser siap untuk tes akses app (jika perlu)

---

## Urutan Terminal yang Disiapkan

| Tab | Koneksi | Untuk |
|-----|---------|-------|
| 1 | MikroTik SSH (192.168.56.1) | Demo 1, Demo 5 |
| 2 | VM DMZ SSH (7.7.7.2) | Demo 2, 3, 4.1, 6 |
| 3 | VM DB SSH (192.168.56.10) | Demo 4.3 |
| 4 | Host/Lokal | Demo 5.2 (curl ke external IP) |
