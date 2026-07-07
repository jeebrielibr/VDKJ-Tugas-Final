# LAPORAN TUGAS PROYEK KELOMPOK
## Virtualisasi dan Keamanan Jaringan
### Implementasi Arsitektur Jaringan Tersegmentasi

---

**Mata Kuliah:** Virtualisasi dan Keamanan Jaringan
**Program Studi:** Teknik Informatika
**Semester:** Genap 2025/2026

**Anggota Kelompok:**

| No | Nama | NIM |
|----|------|-----|
| 1 | Muhammad Jibril Ibrahim | 0110224002 |
| 2 | Muhammad Hisyam Alfaris | 0110224006 |
| 3 | Anis Adriyani | 0110224013 |
| 4 | Zainab Aznur | 0110224009 |
| 5 | Arya Nuryawan | 0110224012 |
| 6 | Eshi Aulia | 0110224007 |

---

# BAB I — PENDAHULUAN

## 1.1 Latar Belakang

Perkembangan teknologi informasi yang semakin pesat membawa dampak signifikan terhadap kebutuhan infrastruktur jaringan yang andal dan aman. Setiap organisasi, baik institusi pendidikan, perusahaan swasta, maupun lembaga pemerintah, sangat bergantung pada ketersediaan dan keamanan jaringan komputer untuk mendukung operasional sehari-hari. Seiring dengan meningkatnya volume dan kompleksitas ancaman siber — mulai dari serangan *Denial of Service* (DoS), injeksi SQL, *Cross-Site Scripting* (XSS), hingga upaya pemindaian port secara ilegal — diperlukan pendekatan arsitektur jaringan yang menerapkan prinsip pertahanan berlapis (*defense in depth*).

Salah satu strategi yang telah terbukti efektif dalam praktik industri adalah **segmentasi jaringan**, yaitu pembagian infrastruktur jaringan menjadi beberapa segmen logis yang saling terisolasi. Dengan memisahkan jaringan menjadi zona-zona seperti *External Network*, *Demilitarized Zone* (DMZ), dan *Local Area Network* (LAN) internal, lalu mengatur lalu lintas data antar zona tersebut melalui kebijakan firewall yang ketat, risiko penyebaran serangan dari satu segmen ke segmen lainnya dapat diminimalisir secara signifikan.

Di sisi lain, teknologi **virtualisasi** dan **containerisasi** telah menjadi standar dalam pengelolaan infrastruktur modern. *Virtual Machine* (VM) memungkinkan beberapa sistem operasi berjalan secara terisolasi pada satu host fisik, sementara teknologi container seperti Docker memungkinkan pengemasan aplikasi beserta seluruh dependensinya dalam satu unit yang portabel dan konsisten. Kombinasi antara virtualisasi, containerisasi, dan konfigurasi keamanan jaringan berlapis merupakan fondasi dari infrastruktur TI yang aman dan terkelola.

Proyek ini dirancang sebagai tugas akhir mata kuliah Virtualisasi dan Keamanan Jaringan untuk memberikan pengalaman praktis kepada mahasiswa dalam merancang, membangun, mengonfigurasi, dan mendokumentasikan infrastruktur jaringan virtual yang mencerminkan praktik industri nyata. Infrastruktur yang dibangun terdiri dari tiga segmen jaringan yang tersegmentasi — External, DMZ, dan LAN — yang dihubungkan dan diproteksi oleh router virtual berbasis MikroTik CHR (*Cloud Hosted Router*), dilengkapi dengan sistem deteksi intrusi berbasis Suricata, serta dua aplikasi web yang dijalankan dalam container Docker dan diintegrasikan dengan server database MySQL/MariaDB di segmen LAN.

## 1.2 Tujuan

Tujuan pelaksanaan proyek ini adalah sebagai berikut:

1. Mengimplementasikan virtualisasi mesin menggunakan hypervisor dan teknologi container Docker.
2. Merancang dan mengonfigurasi segmentasi jaringan yang aman dengan tiga segmen: External, DMZ (7.7.7.0/30), dan LAN (192.168.56.0/24).
3. Menerapkan kebijakan firewall dan routing pada perangkat jaringan virtual MikroTik CHR, termasuk *stateful packet filtering*, NAT, dan *port forwarding*.
4. Men-*deploy* dua aplikasi web dalam container Docker yang berbeda *stack* teknologi (Python/Flask dan PHP/Apache) serta mengintegrasikannya dengan database MySQL/MariaDB di segmen LAN.
5. Menginstalasi dan mengonfigurasi sistem *Intrusion Detection/Prevention System* (IDS/IPS) berbasis Suricata dengan *custom rules* untuk deteksi serangan terhadap aplikasi web.
6. Mendokumentasikan seluruh proses implementasi secara teknis dan profesional, beserta hasil pengujian dan analisis.

## 1.3 Ruang Lingkup

Proyek ini mencakup implementasi dan dokumentasi komponen-komponen berikut:

**Yang termasuk dalam ruang lingkup:**

- Deploy MikroTik CHR sebagai router virtual dengan konfigurasi 3 interface (WAN, DMZ, LAN).
- Konfigurasi firewall MikroTik: filter rules (INPUT, FORWARD), NAT masquerade, DNAT *port forwarding*, *connection tracking*, dan *address list blocking*.
- Setup Virtual Machine Ubuntu Server di segmen DMZ sebagai host untuk Docker, Nginx, dan Suricata.
- Deploy dua container web aplikasi menggunakan Docker Compose: App 1 (Python/Flask — Buku Tamu) dan App 2 (PHP/Apache — Manajemen Produk).
- Konfigurasi Nginx sebagai *reverse proxy* dengan *virtual host*, *security headers*, dan *logging*.
- Instalasi dan konfigurasi MariaDB/MySQL di segmen LAN dengan skema database, *user* terpisah per aplikasi, dan data dummy.
- Konfigurasi firewall OS (UFW) pada server database untuk membatasi akses hanya dari IP VM DMZ.
- Instalasi Suricata dalam mode IDS dengan EVE JSON *logging* dan minimal 3 *custom rules* (SQLi, XSS, *port scan*).
- Pengujian menyeluruh terhadap seluruh skenario konektivitas, aplikasi, firewall, dan IDS.

**Yang tidak termasuk dalam ruang lingkup:**

- Konfigurasi *load balancing* atau *clustering* untuk ketersediaan tinggi (*high availability*).
- Implementasi TLS/HTTPS dengan sertifikat digital (hanya HTTP).
- Monitoring jangka panjang dan *alerting* ke sistem notifikasi eksternal.
- Konfigurasi *Intrusion Prevention System* (IPS) aktif dalam mode *inline* (proyek ini menggunakan Suricata dalam mode IDS pasif).

## 1.4 Sistematika Penulisan

Laporan ini disusun dengan sistematika sebagai berikut:

**BAB I — Pendahuluan.** Berisi latar belakang pelaksanaan proyek, tujuan yang ingin dicapai, ruang lingkup pembahasan, dan sistematika penulisan laporan.

**BAB II — Desain Arsitektur.** Berisi diagram topologi jaringan yang diimplementasikan, skema IP *addressing* untuk setiap komponen, serta penjelasan masing-masing komponen beserta alasan pemilihan teknologi yang digunakan.

**BAB III — Implementasi.** Berisi langkah-langkah konfigurasi detail untuk setiap komponen infrastruktur — MikroTik CHR, VM Ubuntu, Docker, Nginx, Suricata, dan Database Server — dilengkapi dengan screenshot setiap langkah penting dan cuplikan konfigurasi.

**BAB IV — Konfigurasi Keamanan.** Berisi penjelasan dan justifikasi seluruh kebijakan keamanan yang diterapkan, meliputi firewall rules MikroTik, konfigurasi Suricata beserta *custom rules*, serta keamanan database dan Docker.

**BAB V — Hasil Pengujian.** Berisi dokumentasi hasil pengujian seluruh skenario yang telah ditetapkan — konektivitas dasar, fungsionalitas aplikasi, efektivitas firewall, dan deteksi Suricata — dilengkapi dengan screenshot dan analisis.

**BAB VI — Kendala dan Solusi.** Berisi permasalahan teknis yang ditemui selama proses implementasi beserta solusi yang diterapkan.

**BAB VII — Kesimpulan dan Saran.** Berisi kesimpulan dari keseluruhan proyek dan saran pengembangan lebih lanjut.

**Lampiran.** Berisi file konfigurasi lengkap (export MikroTik .rsc, docker-compose.yml, Dockerfile, nginx.conf, suricata.yaml, custom rules, script SQL) dan source code aplikasi web.

---

# BAB II — DESAIN ARSITEKTUR

## 2.1 Diagram Topologi Jaringan

Arsitektur jaringan yang diimplementasikan dalam proyek ini mengadopsi model segmentasi tiga zona yang merupakan standar dalam praktik keamanan jaringan industri. Ketiga zona tersebut — *External Network*, DMZ (*Demilitarized Zone*), dan LAN internal — dihubungkan melalui sebuah router virtual MikroTik CHR yang bertindak sebagai *gateway* utama sekaligus titik penerapan kebijakan keamanan (*security policy enforcement point*).

```
                         ┌─────────────────────┐
                         │   External Network   │
                         │  (Internet / Host)   │
                         └──────────┬───────────┘
                                    │
                            ether1-wan
                         ┌──────────┴───────────┐
                         │                      │
                         │   MikroTik CHR       │
                         │   (Router & Firewall)│
                         │                      │
                         │  ether1 : DHCP/WAN   │
                         │  ether2 : 7.7.7.1/30 │
                         │  ether3 : 192.168.56.1│
                         │                      │
                         └───┬─────────────┬────┘
                   ether2-dmz│             │ether3-lan
                             │             │
              ┌──────────────┴──┐    ┌─────┴───────────────┐
              │    DMZ Network  │    │    LAN Network       │
              │   7.7.7.0/30    │    │  192.168.56.0/24     │
              └────────┬────────┘    └──────────┬───────────┘
                       │                        │
              ┌────────┴────────────┐  ┌────────┴──────────┐
              │    VM Ubuntu DMZ    │  │  DB Server (LAN)   │
              │    IP: 7.7.7.2     │  │  IP: 192.168.56.10 │
              │                    │  │                    │
              │  ┌──────────────┐  │  │  MariaDB/MySQL     │
              │  │ Nginx        │  │  │  - app1_bukutamu   │
              │  │ (Reverse     │  │  │  - app2_produk     │
              │  │  Proxy)      │  │  │                    │
              │  └──────┬───────┘  │  │  UFW Firewall      │
              │         │          │  │  (3306 dari 7.7.7.2│
              │  ┌──────┴───────┐  │  │   saja)            │
              │  │ Docker       │  │  │                    │
              │  │ ┌──────────┐ │  │  └────────────────────┘
              │  │ │ App 1    │ │  │
              │  │ │ Flask    │ │  │
              │  │ │ :5000    │ │  │
              │  │ └──────────┘ │  │
              │  │ ┌──────────┐ │  │
              │  │ │ App 2    │ │  │
              │  │ │ PHP/Apache│ │  │
              │  │ │ :80→8080 │ │  │
              │  │ └──────────┘ │  │
              │  └──────────────┘  │
              │                    │
              │  ┌──────────────┐  │
              │  │ Suricata     │  │
              │  │ IDS (monitor │  │
              │  │  eth0)       │  │
              │  └──────────────┘  │
              └────────────────────┘
```

**Alur Traffic (Flow):**

1. Permintaan dari *External Network* (port 80/443) diterima oleh MikroTik CHR pada `ether1-wan`.
2. Firewall MikroTik melakukan DNAT (*Destination NAT*) untuk meneruskan traffic ke VM Ubuntu DMZ (`7.7.7.2:80`).
3. Nginx pada VM DMZ menerima permintaan dan meneruskannya (*reverse proxy*) ke container Docker yang sesuai berdasarkan *virtual host* (`app1.vdkj.local` → Flask:5000, `app2.vdkj.local` → PHP:8080).
4. Aplikasi web dalam container memproses permintaan dan mengakses database MySQL/MariaDB di server LAN (`192.168.56.10:3306`) melalui firewall MikroTik yang hanya mengizinkan traffic MySQL dari IP VM DMZ.
5. Suricata pada VM DMZ secara pasif memonitor seluruh traffic yang melewati interface jaringan dan menghasilkan log alert jika terdeteksi pola serangan.

## 2.2 Skema IP Addressing

Berikut skema IP *addressing* yang digunakan dalam infrastruktur jaringan proyek ini:

| No | Komponen | Interface | IP Address | Subnet Mask | Gateway | Keterangan |
|----|----------|-----------|------------|-------------|---------|------------|
| 1 | MikroTik CHR | ether1-wan | DHCP / Static | - | dari hypervisor | Interface WAN (External) |
| 2 | MikroTik CHR | ether2-dmz | 7.7.7.1 | /30 (255.255.255.252) | - | Gateway segmen DMZ |
| 3 | MikroTik CHR | ether3-lan | 192.168.56.1 | /24 (255.255.255.0) | - | Gateway segmen LAN |
| 4 | VM Ubuntu DMZ | eth0 | 7.7.7.2 | /30 | 7.7.7.1 | Nginx + Docker + Suricata |
| 5 | DB Server LAN | eth0 | 192.168.56.10 | /24 | 192.168.56.1 | MariaDB/MySQL |

**Penjelasan Pemilihan Subnet:**

- **DMZ (7.7.7.0/30):** Menggunakan subnet /30 yang hanya menyediakan 2 host address (7.7.7.1 untuk router dan 7.7.7.2 untuk VM DMZ). Pemilihan /30 bersifat intentional — DMZ adalah zona semi-tepercaya yang seharusnya hanya diisi oleh komponen yang benar-benar diperlukan. Subnet kecil meminimalkan *attack surface* dan menyulitkan pergerakan lateral (*lateral movement*) jika terjadi kompromi.

- **LAN (192.168.56.0/24):** Menggunakan subnet /24 yang menyediakan hingga 254 host address. Subnet yang lebih besar ini memberikan fleksibilitas untuk penambahan server atau layanan internal di masa mendatang, sementara tetap dilindungi oleh firewall MikroTik dari akses external.

**Port Mapping Aplikasi:**

| Aplikasi | Container Port | Host Port | Akses via Nginx |
|----------|---------------|-----------|-----------------|
| App 1 (Flask) | 5000 | 5000 | `app1.vdkj.local` |
| App 2 (PHP/Apache) | 80 | 8080 | `app2.vdkj.local` |

## 2.3 Penjelasan Komponen dan Alasan Pemilihan Teknologi

### 2.3.1 MikroTik CHR (Router Virtual)

MikroTik CHR (*Cloud Hosted Router*) dipilih sebagai router virtual karena beberapa alasan berikut:

- **Kompatibilitas Hypervisor:** CHR tersedia dalam berbagai format image (VMDK, VDI, QCOW2) yang kompatibel dengan hypervisor utama seperti VirtualBox dan VMware, sehingga mudah di-*deploy* dalam lingkungan virtual.
- **Fitur Lengkap:** CHR menyediakan seluruh fitur routing dan firewall RouterOS, termasuk *stateful packet filtering*, NAT, *port forwarding*, *connection tracking*, *address list*, dan *rate limiting* — semua kebutuhan proyek ini tercakup dalam satu perangkat.
- **Digunakan di Industri:** MikroTik adalah salah satu vendor perangkat jaringan yang banyak digunakan oleh ISP dan enterprise di Indonesia, sehingga pengalaman konfigurasinya relevan dengan praktik profesional.
- **Resource Ringan:** CHR hanya membutuhkan 128–256 MB RAM, sangat efisien untuk lingkungan virtual.

### 2.3.2 Ubuntu Server (VM DMZ)

Ubuntu Server 22.04 LTS dipilih sebagai sistem operasi untuk VM di segmen DMZ karena:

- **Stabilitas dan Dukungan Jangka Panjang:** Sebagai distribusi LTS (*Long Term Support*), Ubuntu Server 22.04 mendapat dukungan pembaruan keamanan selama 5 tahun.
- **Ekosistem Paket Lengkap:** Ubuntu memiliki repositori paket yang sangat luas, memudahkan instalasi Docker, Nginx, dan Suricata tanpa kompilasi manual.
- **Dokumentasi Melimpah:** Ubuntu adalah distribusi Linux yang paling banyak didokumentasikan, sehingga memudahkan proses troubleshooting.
- **Kompatibilitas Docker:** Docker secara resmi mendukung Ubuntu sebagai *first-class platform*.

### 2.3.3 Docker dan Docker Compose

Docker digunakan sebagai platform containerisasi untuk menjalankan kedua aplikasi web karena:

- **Isolasi Aplikasi:** Setiap aplikasi berjalan dalam container terisolasi dengan *filesystem*, *network namespace*, dan proses sendiri, sehingga tidak saling mempengaruhi.
- **Portabilitas:** Docker image yang dibangun dapat dijalankan di lingkungan mana pun yang mendukung Docker tanpa perubahan konfigurasi.
- **Reproduktibilitas:** Dockerfile mendefinisikan secara eksplisit bagaimana image dibangun, sehingga proses *deployment* dapat direproduksi dengan hasil yang konsisten.
- **Docker Compose:** Memungkinkan definisi dan pengelolaan multi-container dalam satu file YAML, termasuk *environment variable*, *port mapping*, dan *network configuration*.
- **Keamanan:** Docker mendukung pembatasan hak akses container agar tidak berjalan sebagai *root user*, mengurangi risiko eskalasi privilege.

### 2.3.4 Python/Flask (App 1 — Buku Tamu)

Python dengan framework Flask dipilih untuk aplikasi pertama (Buku Tamu) karena:

- **Ringkas dan Minimalis:** Flask adalah *micro-framework* yang tidak memaksakan struktur proyek tertentu, cocok untuk aplikasi web sederhana seperti buku tamu.
- **Fleksibilitas:** Flask memberikan kebebasan dalam memilih komponen tambahan (database driver, template engine, dll.) sesuai kebutuhan.
- **Cepat Dikembangkan:** Dengan Flask, aplikasi web CRUD (*Create, Read, Update, Delete*) lengkap dapat dibangun dalam satu file Python.
- **Gunicorn sebagai WSGI Server:** Untuk lingkungan produksi dalam container, Gunicorn digunakan sebagai *application server* yang lebih robust dibanding *development server* bawaan Flask.

### 2.3.5 PHP/Apache (App 2 — Manajemen Produk)

PHP dengan Apache dipilih untuk aplikasi kedua (Manajemen Produk) karena:

- **Stack Berbeda (Requirement):** Panduan proyek mensyaratkan kedua aplikasi menggunakan *stack* teknologi yang berbeda untuk mendemonstrasikan fleksibilitas containerisasi.
- **Prevalensi di Industri:** PHP masih menjadi salah satu bahasa *server-side* yang paling banyak digunakan di web, sehingga pengalaman mengonfigurasinya bersifat praktis.
- **Docker Image Resmi:** `php:8.3-apache` menyediakan image yang sudah dilengkapi Apache dan PHP, mempercepat proses *deployment*.
- **Kesederhanaan Deployment:** PHP tidak memerlukan proses build terpisah — file `.php` langsung dieksekusi oleh Apache tanpa langkah kompilasi.

### 2.3.6 Nginx (Reverse Proxy)

Nginx dipilih sebagai *reverse proxy* karena:

- **Performa Tinggi:** Nginx menggunakan arsitektur *event-driven* yang mampu menangani ribuan koneksi simultan dengan resource minimal.
- **Virtual Host:** Nginx mendukung konfigurasi *server block* untuk mengarahkan request ke backend yang berbeda berdasarkan *hostname*, memungkinkan kedua aplikasi diakses melalui satu IP dan port yang sama.
- **Security Headers:** Nginx memudahkan penambahan header keamanan HTTP seperti `X-Frame-Options`, `X-Content-Type-Options`, dan `Referrer-Policy`.
- **Logging:** Nginx menyediakan mekanisme *access log* dan *error log* yang terpisah per *virtual host*, memudahkan monitoring dan audit.
- **Standar Industri:** Nginx adalah web server dan *reverse proxy* yang paling banyak digunakan di dunia.

### 2.3.7 Suricata (IDS/IPS)

Suricata dipilih sebagai sistem deteksi intrusi karena:

- **Multi-Threaded:** Suricata mendukung *multi-threaded processing*, memungkinkan pemrosesan traffic berkecepatan tinggi.
- **EVE JSON Logging:** Suricata menghasilkan log dalam format JSON terstruktur (*EVE*), yang mudah diintegrasikan dengan工具 analisis log seperti ELK Stack atau Splunk.
- **Kompatibilitas Rule:** Suricata kompatibel dengan format rule Snort, sehingga dapat menggunakan *rule set* standar seperti Emerging Threats di samping *custom rules*.
- **Mode IDS dan IPS:** Suricata dapat berjalan dalam mode IDS pasif (*monitoring*) maupun mode IPS aktif (*inline blocking*), memberikan fleksibilitas dalam desain keamanan.
- **Open Source:** Suricata adalah proyek open source yang didukung oleh komunitas dan OISF (*Open Information Security Foundation*).

### 2.3.8 MariaDB/MySQL (Database Server)

MariaDB dipilih sebagai server database karena:

- **Kompatibilitas MySQL:** MariaDB adalah *drop-in replacement* untuk MySQL, mendukung seluruh fitur dan connector yang sama.
- **User Terpisah:** MariaDB memungkinkan pembuatan *database user* yang terpisah untuk setiap aplikasi, mendukung prinsip *least privilege*.
- **Bind Address:** Konfigurasi `bind-address` pada MariaDB dapat dibatasi untuk menerima koneksi hanya dari IP atau subnet tertentu.
- **Firewall Lapisan Tambahan:** Dikombinasikan dengan UFW (*Uncomplicated Firewall*) di level OS, akses ke port 3306 dapat dibatasi hanya dari IP VM DMZ (`7.7.7.2`), menciptakan pertahanan berlapis.
- **Stabilitas dan Performa:** MariaDB telah terbukti stabil dan performa tinggi untuk beban kerja OLTP (*Online Transaction Processing*) skala kecil hingga menengah.
