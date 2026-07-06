# DRAFT LAPORAN TEKNIS
## Tugas Proyek Virtualisasi dan Keamanan Jaringan
### Implementasi Arsitektur Jaringan Tersegmentasi

---

## Informasi Dokumen

| Field | Isi |
|-------|-----|
| Mata Kuliah | Virtualisasi dan Keamanan Jaringan |
| Jenis Tugas | Proyek Kelompok |
| Bobot Penilaian | 40% dari total nilai proyek |
| Format | PDF |
| Periode | Semester Genap 2025/2026 |

---

## Persyaratan Laporan

### Format Penulisan
- Format file: PDF
- Bahasa: Indonesia (istilah teknis dalam bahasa Inggris)
- Font: Times New Roman 12pt
- Spasi: 1.5
- Margin: 3-3-3-3 (kiri-atas-kanan-bawah)
- Penomoran halaman di bagian bawah tengah

### Isi Wajib
- Setiap langkah konfigurasi WAJIB disertai **screenshot**
- Screenshot harus jelas dan dapat dibaca
- Sertakan **analisis** pada setiap hasil pengujian
- Cantumkan **file konfigurasi lengkap** di lampiran
- Tulis dengan bahasa teknis yang profesional dan sistematis

### Anggota Kelompok

| No | Nama | NIM |
|----|------|-----|
| 1 | Muhammad Jibril Ibrahim | 0110224002 |
| 2 | Muhammad Hisyam Alfaris | 0110224006 |
| 3 | Anis Adriyani | 0110224013 |
| 4 | Zainab Aznur | 0110224009 |
| 5 | Arya Nuryawan | 0110224012 |

---

## Susunan Bab (Struktur Laporan)

### [HALAMAN JUDUL]
- Judul Proyek: "Implementasi Arsitektur Jaringan Tersegmentasi"
- Nama anggota kelompok dan NIM
- Nomor kelompok
- Logo universitas / fakultas (opsional)
- Tanggal pengumpulan

---

### BAB I — PENDAHULUAN

#### 1.1 Latar Belakang
<!-- Tuliskan mengapa proyek ini penting, konteks keamanan jaringan modern, dan relevansinya dengan praktik industri -->

#### 1.2 Tujuan
<!-- Daftar tujuan implementasi proyek ini -->
- Menerapkan konsep virtualisasi mesin dan containerisasi
- Membangun segmentasi jaringan (External, DMZ, LAN)
- Mengonfigurasi firewall dan routing pada MikroTik
- Men-deploy aplikasi web dalam Docker terintegrasi database
- Mengimplementasikan IDS/IPS berbasis Suricata

#### 1.3 Ruang Lingkup
<!-- Batasan proyek: apa yang dikerjakan dan apa yang tidak -->

#### 1.4 Sistematika Penulisan
<!-- Gambaran umum isi setiap bab -->

---

### BAB II — DESAIN ARSITEKTUR

#### 2.1 Gambaran Umum Arsitektur
<!-- Diagram jaringan lengkap dengan IP address dan penjelasan alur traffic -->

#### 2.2 Diagram Topologi
<!-- Gambar/diagram topologi jaringan (bisa pakai draw.io, Excalidraw, dll.) -->

#### 2.3 Skema IP Addressing

| Komponen | Interface | IP Address | Subnet | Gateway |
|----------|-----------|------------|--------|---------|
| MikroTik CHR | ether1 (WAN) | DHCP/static | — | — |
| MikroTik CHR | ether2 (DMZ) | 7.7.7.1 | /30 | — |
| MikroTik CHR | ether3 (LAN) | 192.168.56.1 | /24 | — |
| VM Ubuntu (DMZ) | eth0 | 7.7.7.2 | /30 | 7.7.7.1 |
| DB Server (LAN) | eth0 | 192.168.56.x | /24 | 192.168.56.1 |

#### 2.4 Penjelasan Komponen
<!-- Penjelasan per komponen beserta alasan pemilihan teknologi -->

##### 2.4.1 MikroTik CHR sebagai Router
<!-- Alasan pemilihan, peran dalam arsitektur -->

##### 2.4.2 VM Ubuntu di DMZ
<!-- Alasan pemilihan OS, peran sebagai web server & IDS -->

##### 2.4.3 Docker Container
<!-- Alasan menggunakan Docker, stack aplikasi yang dipilih -->

##### 2.4.4 Nginx Reverse Proxy
<!-- Alasan pemilihan Nginx, peran dalam arsitektur -->

##### 2.4.5 Suricata IDS/IPS
<!-- Alasan pemilihan Suricata, mode yang digunakan -->

##### 2.4.6 MySQL Database Server
<!-- Alasan pemilihan MySQL/MariaDB, penempatan di LAN -->

---

### BAB III — IMPLEMENTASI

#### 3.1 Lingkungan Pengujian
<!-- Spesifikasi hardware/host, hypervisor yang digunakan, OS host -->

#### 3.2 Konfigurasi Router MikroTik CHR

##### 3.2.1 Instalasi dan Setup Awal
<!-- Screenshot: deploy CHR di hypervisor -->

##### 3.2.2 Konfigurasi Interface dan IP Address
<!-- Screenshot: perintah CLI/interface list -->
```
<!-- Sisipkan contoh perintah MikroTik di sini -->
```

##### 3.2.3 Konfigurasi DNS dan Routing
<!-- Screenshot: DNS client, static route -->

#### 3.3 Setup VM Ubuntu di DMZ

##### 3.3.1 Instalasi Ubuntu Server
<!-- Screenshot: proses instalasi -->

##### 3.3.2 Konfigurasi Network Interface
<!-- Screenshot: netplan / ifconfig -->

##### 3.3.3 Instalasi Docker dan Docker Compose
<!-- Screenshot: docker --version, docker-compose --version -->

#### 3.4 Deploy Aplikasi Web dalam Docker

##### 3.4.1 Aplikasi Web 1
<!-- Penjelasan stack, screenshot Dockerfile, source code -->
```
<!-- Sisipkan Dockerfile App1 -->
```

##### 3.4.2 Aplikasi Web 2
<!-- Penjelasan stack, screenshot Dockerfile, source code -->
```
<!-- Sisipkan Dockerfile App2 -->
```

##### 3.4.3 Docker Compose
<!-- Screenshot: docker-compose.yml, docker compose up -->
```
<!-- Sisipkan docker-compose.yml -->
```

##### 3.4.4 Environment Variable dan Koneksi Database
<!-- Screenshot: env var di container, tes koneksi ke MySQL -->

#### 3.5 Konfigurasi Nginx Reverse Proxy

##### 3.5.1 Instalasi Nginx
<!-- Screenshot: nginx -v -->

##### 3.5.2 Konfigurasi Virtual Host / Server Block
<!-- Screenshot: file konfigurasi, penjelasan upstream & proxy_pass -->
```
<!-- Sisipkan nginx.conf / site config -->
```

##### 3.5.3 Security Headers
<!-- Screenshot: response header di browser/curl -->

##### 3.5.4 Logging
<!-- Screenshot: access.log dan error.log -->

#### 3.6 Konfigurasi Database Server (LAN)

##### 3.6.1 Instalasi MySQL/MariaDB
<!-- Screenshot: mysql --version -->

##### 3.6.2 Pembuatan Database dan User
<!-- Screenshot: perintah SQL membuat DB, user, grant -->
```
<!-- Sisipkan script SQL -->
```

##### 3.6.3 Skema Database dan Data Dummy
<!-- Screenshot: tabel, isi data -->

##### 3.6.4 Konfigurasi Bind Address dan Firewall OS
<!-- Screenshot: my.cnf bind-address, ufw allow -->

#### 3.7 Instalasi dan Konfigurasi Suricata

##### 3.7.1 Instalasi Suricata
<!-- Screenshot: suricata --version -->

##### 3.7.2 Konfigurasi Dasar (suricata.yaml)
<!-- Screenshot: konfigurasi interface, log output -->
```
<!-- Sisipkan suricata.yaml (bagian penting) -->
```

##### 3.7.3 Custom Rules (Minimal 3)
<!-- Screenshot: file .rules, penjelasan setiap rule -->
```
<!-- Sisipkan custom rules -->
```

##### 3.7.4 Menjalankan Suricata dan Verifikasi
<!-- Screenshot: suricata running, log aktif -->

---

### BAB IV — KONFIGURASI KEAMANAN

#### 4.1 Firewall Rules MikroTik

<!-- Penjelasan dan justifikasi SETIAP rule. Format per rule: -->

##### 4.1.1 Filter Chain INPUT
<!-- Drop koneksi masuk except management, allow ICMP, allow SSH dari LAN, drop port scan -->
```
<!-- Sisipkan perintah MikroTik -->
```
**Justifikasi:** <!-- Mengapa rule ini diperlukan -->

##### 4.1.2 Filter Chain FORWARD — DMZ ke LAN
<!-- Allow hanya MySQL 3306 dari DMZ ke LAN, block sisanya -->
```
<!-- Sisipkan perintah MikroTik -->
```
**Justifikasi:** <!-- Prinsip least privilege -->

##### 4.1.3 Filter Chain FORWARD — External ke DMZ
<!-- Allow 80/443 ke Nginx, block direct access ke port container, rate limiting -->
```
<!-- Sisipkan perintah MikroTik -->
```
**Justifikasi:** <!-- Proteksi DMZ dari external -->

##### 4.1.4 NAT Masquerade
<!-- srcnat masquerade pada interface external -->
```
<!-- Sisipkan perintah MikroTik -->
```

##### 4.1.5 Port Forwarding (DNAT)
<!-- Forward external 80/443 ke IP VM Ubuntu -->
```
<!-- Sisipkan perintah MikroTik -->
```

##### 4.1.6 Connection Tracking
<!-- Accept established/related, drop invalid -->
```
<!-- Sisipkan perintah MikroTik -->
```

##### 4.1.7 Firewall Address List
<!-- Block IP mencurigakan -->
```
<!-- Sisipkan perintah MikroTik -->
```

#### 4.2 Keamanan Suricata

##### 4.2.1 Penjelasan Mode IDS/IPS yang Dipilih
<!-- IDS (passive) atau IPS (inline NFQueue), alasan -->

##### 4.2.2 Analisis Custom Rules
<!-- Penjelasan mendalam tiap custom rule: apa yang dideteksi, cara kerja signature -->

#### 4.3 Keamanan Database
<!-- Non-root user MySQL, bind-address, firewall OS, user terpisah per app -->

#### 4.4 Keamanan Docker
<!-- Non-root user di container, network isolation, env var -->

---

### BAB V — HASIL PENGUJIAN

<!-- Setiap pengujian: screenshot + analisis -->

#### 5.1 Pengujian Konektivitas Dasar

| No | Skenario Pengujian | Hasil | Keterangan |
|----|---------------------|-------|------------|
| 1 | Ping dari External ke Router | ✅/❌ | |
| 2 | Ping dari DMZ ke LAN | ✅/❌ | |
| 3 | Ping dari External ke LAN langsung | ✅/❌ | Harus GAGAL |
| 4 | Akses HTTP/HTTPS ke Nginx dari external | ✅/❌ | |
| 5 | Akses langsung ke port container dari external | ✅/❌ | Harus GAGAL |
| 6 | Koneksi MySQL dari VM DMZ ke DB Server | ✅/❌ | |
| 7 | Koneksi MySQL dari external langsung | ✅/❌ | Harus GAGAL |

<!-- Screenshot setiap tes + analisis mengapa berhasil/gagal -->

#### 5.2 Pengujian Aplikasi Web

| No | Skenario Pengujian | Hasil | Keterangan |
|----|---------------------|-------|------------|
| 1 | App 1 dapat diakses via Nginx | ✅/❌ | |
| 2 | App 2 dapat diakses via Nginx | ✅/❌ | |
| 3 | App baca/tulis ke MySQL di LAN | ✅/❌ | |
| 4 | Nginx access log mencatat request | ✅/❌ | |
| 5 | Security headers ada di response | ✅/❌ | |

<!-- Screenshot: browser, curl -I, log -->

#### 5.3 Pengujian Firewall MikroTik

| No | Skenario Pengujian | Hasil | Keterangan |
|----|---------------------|-------|------------|
| 1 | DROP External → LAN langsung | ✅/❌ | |
| 2 | Rate limiting aktif | ✅/❌ | |
| 3 | Address list blocking berfungsi | ✅/❌ | |
| 4 | Connection state tracking (INVALID drop) | ✅/❌ | |
| 5 | Hanya port 80/443 accessible dari External | ✅/❌ | |
| 6 | SSH hanya dari LAN | ✅/❌ | |

<!-- Screenshot: torch, log firewall, netcat/curl tests -->

#### 5.4 Pengujian Suricata IDS/IPS

| No | Skenario Pengujian | Hasil | Keterangan |
|----|---------------------|-------|------------|
| 1 | Suricata aktif memproses traffic | ✅/❌ | |
| 2 | Alert muncul saat simulasi serangan (Nmap) | ✅/❌ | |
| 3 | Custom rule trigger alert | ✅/❌ | |
| 4 | Log EVE JSON dapat dibaca | ✅/❌ | |

<!-- Screenshot: eve.json, fast.log, suricata status -->

---

### BAB VI — KENDALA DAN SOLUSI

<!-- Format tabel -->

| No | Kendala | Solusi | Komponen Terkait |
|----|---------|--------|-------------------|
| 1 | | | |
| 2 | | | |
| 3 | | | |

---

### BAB VII — KESIMPULAN DAN SARAN

#### 7.1 Kesimpulan
<!-- Ringkasan pencapaian terhadap learning outcomes (LO1-LO6) -->

#### 7.2 Saran
<!-- Saran untuk pengembangan lebih lanjut -->

---

### LAMPIRAN

#### Lampiran A — Export Konfigurasi MikroTik Lengkap (.rsc)
```
<!-- Tempelkan output /export di sini -->
```

#### Lampiran B — docker-compose.yml
```yaml
<!-- Tempelkan docker-compose.yml -->
```

#### Lampiran C — Dockerfile
```dockerfile
<!-- Tempelkan Dockerfile custom -->
```

#### Lampiran D — Konfigurasi Nginx (.conf)
```nginx
<!-- Tempelkan nginx site config -->
```

#### Lampiran E — Konfigurasi Suricata (suricata.yaml)
```yaml
<!-- Tempelkan bagian penting suricata.yaml -->
```

#### Lampiran F — Custom Rules Suricata (.rules)
```
<!-- Tempelkan custom rules -->
```

#### Lampiran G — Script SQL (Skema & Data Dummy)
```sql
<!-- Tempelkan SQL script -->
```

#### Lampiran H — Source Code Aplikasi Web
<!-- Referensi ke folder apps/ atau tempelkan kode utama -->

---

## Checklist Sebelum Pengumpulan

- [ ] Semua screenshot jelas dan terbaca
- [ ] Setiap firewall rule ada justifikasi keamanan
- [ ] Hasil pengujian lengkap dengan analisis
- [ ] Lampiran berisi file konfigurasi lengkap (bukan screenshot)
- [ ] Halaman judul lengkap (nama, NIM, nomor kelompok, tanggal)
- [ ] Daftar isi dan penomoran halaman
- [ ] Format PDF, penomoran bab konsisten
- [ ] File dikumpulkan dalam format: `PROYEK_KelompokXX_NamaAnggota.zip`
