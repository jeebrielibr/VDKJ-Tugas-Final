# DRAFT LAPORAN TEKNIS
## Implementasi Arsitektur Jaringan Tersegmentasi

> **Format:** PDF | **Font:** Times New Roman 12pt | **Spasi:** 1.5 | **Margin:** 3cm semua sisi
> Setiap konfigurasi WAJIB disertai screenshot + analisis. Lampiran berisi file konfigurasi lengkap.

### Anggota Kelompok

| No | Nama | NIM |
|----|------|-----|
| 1 | Muhammad Jibril Ibrahim | 0110224002 |
| 2 | Muhammad Hisyam Alfaris | 0110224006 |
| 3 | Anis Adriyani | 0110224013 |
| 4 | Zainab Aznur | 0110224009 |
| 5 | Arya Nuryawan | 0110224012 |
| 6 | Eshi Aulia | 0110224007 |

---

### HALAMAN JUDUL
Judul, nama & NIM anggota, nomor kelompok, tanggal pengumpulan.

---

### BAB I — PENDAHULUAN

#### 1.1 Latar Belakang
<!-- Mengapa proyek ini penting, konteks keamanan jaringan modern -->

#### 1.2 Tujuan
- Virtualisasi mesin dan containerisasi
- Segmentasi jaringan (External, DMZ, LAN)
- Firewall dan routing pada MikroTik
- Deploy aplikasi web Docker terintegrasi database
- IDS/IPS berbasis Suricata

#### 1.3 Ruang Lingkup
<!-- Batasan proyek -->

#### 1.4 Sistematika Penulisan

---

### BAB II — DESAIN ARSITEKTUR

#### 2.1 Diagram Topologi
<!-- Diagram jaringan dengan IP address dan alur traffic -->

#### 2.2 Skema IP Addressing

| Komponen | Interface | IP Address | Subnet | Gateway |
|----------|-----------|------------|--------|---------|
| MikroTik CHR | ether1 (WAN) | DHCP/static | — | — |
| MikroTik CHR | ether2 (DMZ) | 7.7.7.1 | /30 | — |
| MikroTik CHR | ether3 (LAN) | 192.168.56.1 | /24 | — |
| VM Ubuntu (DMZ) | eth0 | 7.7.7.2 | /30 | 7.7.7.1 |
| DB Server (LAN) | eth0 | 192.168.56.x | /24 | 192.168.56.1 |

#### 2.3 Penjelasan Komponen & Alasan Pemilihan
<!-- Per komponen: MikroTik CHR, VM Ubuntu, Docker, Nginx, Suricata, MySQL — alasan teknologi dipilih -->

---

### BAB III — IMPLEMENTASI

#### 3.1 Lingkungan Pengujian
<!-- Spesifikasi hardware, hypervisor, OS host -->

#### 3.2 Konfigurasi Router MikroTik CHR
<!-- Screenshot tiap langkah: deploy, interface list, IP, DNS, routing -->
```
<!-- Perintah MikroTik -->
```

#### 3.3 Setup VM Ubuntu di DMZ
<!-- Screenshot: instalasi, netplan, docker --version -->

#### 3.4 Deploy Aplikasi Web dalam Docker
<!-- Screenshot: Dockerfile, docker-compose.yml, env var, tes koneksi DB -->
```
<!-- Dockerfile App1, Dockerfile App2, docker-compose.yml -->
```

#### 3.5 Konfigurasi Nginx Reverse Proxy
<!-- Screenshot: site config, security headers (curl -I), access.log & error.log -->
```
<!-- nginx.conf / site config -->
```

#### 3.6 Konfigurasi Database Server (LAN)
<!-- Screenshot: instalasi MySQL, pembuatan DB/user, skema, bind-address, ufw -->
```
<!-- Script SQL skema & data dummy -->
```

#### 3.7 Konfigurasi Suricata IDS/IPS
<!-- Screenshot: instalasi, suricata.yaml, custom rules, suricata running + log aktif -->
```
<!-- suricata.yaml (bagian penting), custom rules -->
```

---

### BAB IV — KONFIGURASI KEAMANAN

#### 4.1 Firewall MikroTik
<!-- Tiap rule: perintah + justifikasi keamanan -->

##### 4.1.1 Filter Rules (INPUT & FORWARD)
<!-- INPUT: drop masuk except management, ICMP, SSH dari LAN, drop port scan -->
<!-- FORWARD: DMZ→LAN hanya 3306; External→DMZ hanya 80/443 + rate limit -->
```
<!-- Perintah MikroTik -->
```

##### 4.1.2 NAT, Port Forwarding & Connection Tracking
<!-- Masquerade, DNAT 80/443→DMZ, accept established/related, drop invalid -->
```
<!-- Perintah MikroTik -->
```

##### 4.1.3 Address List Blocking
<!-- Block IP mencurigakan -->
```
<!-- Perintah MikroTik -->
```

#### 4.2 Keamanan Suricata
<!-- Mode IDS/IPS yang dipilih + penjelasan tiap custom rule -->

#### 4.3 Keamanan Database & Docker
<!-- DB: non-root user, bind-address, firewall OS, user per app -->
<!-- Docker: non-root user, network isolation, env var -->

---

### BAB V — HASIL PENGUJIAN

> Tiap pengujian: **screenshot + analisis** mengapa berhasil/gagal.

#### 5.1 Konektivitas Dasar

| No | Skenario | Hasil | Keterangan |
|----|----------|-------|------------|
| 1 | Ping External → Router | ✅/❌ | |
| 2 | Ping DMZ → LAN | ✅/❌ | |
| 3 | Ping External → LAN langsung | ✅/❌ | Harus GAGAL |
| 4 | HTTP/HTTPS ke Nginx dari external | ✅/❌ | |
| 5 | Direct access port container dari external | ✅/❌ | Harus GAGAL |
| 6 | MySQL dari VM DMZ → DB Server | ✅/❌ | |
| 7 | MySQL dari external langsung | ✅/❌ | Harus GAGAL |

#### 5.2 Aplikasi Web

| No | Skenario | Hasil | Keterangan |
|----|----------|-------|------------|
| 1 | App 1 via Nginx | ✅/❌ | |
| 2 | App 2 via Nginx | ✅/❌ | |
| 3 | App baca/tulis MySQL | ✅/❌ | |
| 4 | Nginx access log mencatat request | ✅/❌ | |
| 5 | Security headers di response | ✅/❌ | |

#### 5.3 Firewall MikroTik

| No | Skenario | Hasil | Keterangan |
|----|----------|-------|------------|
| 1 | DROP External → LAN | ✅/❌ | |
| 2 | Rate limiting aktif | ✅/❌ | |
| 3 | Address list blocking | ✅/❌ | |
| 4 | Connection state tracking (INVALID drop) | ✅/❌ | |
| 5 | Hanya port 80/443 dari External | ✅/❌ | |
| 6 | SSH hanya dari LAN | ✅/❌ | |

#### 5.4 Suricata IDS/IPS

| No | Skenario | Hasil | Keterangan |
|----|----------|-------|------------|
| 1 | Suricata aktif memproses traffic | ✅/❌ | |
| 2 | Alert saat simulasi serangan (Nmap) | ✅/❌ | |
| 3 | Custom rule trigger alert | ✅/❌ | |
| 4 | EVE JSON log dapat dibaca | ✅/❌ | |

---

### BAB VI — KENDALA DAN SOLUSI

| No | Kendala | Solusi | Komponen |
|----|---------|--------|----------|
| 1 | | | |
| 2 | | | |

---

### BAB VII — KESIMPULAN DAN SARAN

#### 7.1 Kesimpulan
<!-- Pencapaian terhadap LO1–LO6 -->

#### 7.2 Saran
<!-- Pengembangan lebih lanjut -->

---

### LAMPIRAN

#### A — Export MikroTik (.rsc)
```
<!-- /export -->
```

#### B — docker-compose.yml
```yaml
```

#### C — Dockerfile
```dockerfile
```

#### D — Konfigurasi Nginx (.conf)
```nginx
```

#### E — suricata.yaml
```yaml
```

#### F — Custom Rules (.rules)
```
```

#### G — Script SQL
```sql
```

#### H — Source Code Aplikasi Web
<!-- Referensi ke folder apps/ -->

---

### CHECKLIST

- [ ] Screenshot jelas & terbaca
- [ ] Firewall rule ada justifikasi
- [ ] Pengujian lengkap + analisis
- [ ] Lampiran: file konfigurasi lengkap (bukan screenshot)
- [ ] Halaman judul, daftar isi, penomoran halaman
- [ ] Format PDF, penomoran bab konsisten
