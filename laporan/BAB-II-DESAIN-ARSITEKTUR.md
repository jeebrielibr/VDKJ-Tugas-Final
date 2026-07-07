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

**Keterangan Diagram:**

Diagram di atas menggambarkan arsitektur jaringan tersegmentasi dengan tiga zona utama. MikroTik CHR ditempatkan sebagai sentral yang menghubungkan ketiga zona dan menerapkan kebijakan keamanan pada setiap titik lalu lintas data. Setiap segmen jaringan beroperasi pada subnet yang berbeda dan diisolasi oleh firewall rules pada router.

**Alur Traffic (Flow):**

1. Permintaan dari *External Network* (port 80/443) diterima oleh MikroTik CHR pada `ether1-wan`.
2. Firewall MikroTik melakukan DNAT (*Destination NAT*) untuk meneruskan traffic ke VM Ubuntu DMZ (`7.7.7.2:80`).
3. Nginx pada VM DMZ menerima permintaan dan meneruskannya (*reverse proxy*) ke container Docker yang sesuai berdasarkan *virtual host* (`app1.vdkj.local` → Flask:5000, `app2.vdkj.local` → PHP:8080).
4. Aplikasi web dalam container memproses permintaan dan mengakses database MariaDB/MySQL di server LAN (`192.168.56.10:3306`) melalui firewall MikroTik yang hanya mengizinkan traffic MySQL dari IP VM DMZ.
5. Suricata pada VM DMZ secara pasif memonitor seluruh traffic yang melewati interface jaringan dan menghasilkan log alert jika terdeteksi pola serangan.

## 2.2 Skema IP Addressing

Berikut skema IP *addressing* yang digunakan dalam infrastruktur jaringan proyek ini:

| No | Komponen | Interface | IP Address | Subnet Mask | Gateway | Keterangan |
|----|----------|-----------|------------|-------------|---------|------------|
| 1 | MikroTik CHR | ether1-wan | DHCP / Static | — | dari hypervisor | Interface WAN (External) |
| 2 | MikroTik CHR | ether2-dmz | 7.7.7.1 | /30 (255.255.255.252) | — | Gateway segmen DMZ |
| 3 | MikroTik CHR | ether3-lan | 192.168.56.1 | /24 (255.255.255.0) | — | Gateway segmen LAN |
| 4 | VM Ubuntu DMZ | eth0 | 7.7.7.2 | /30 | 7.7.7.1 | Nginx + Docker + Suricata |
| 5 | DB Server LAN | eth0 | 192.168.56.10 | /24 | 192.168.56.1 | MariaDB/MySQL |

**Penjelasan Pemilihan Subnet:**

- **DMZ (7.7.7.0/30):** Menggunakan subnet /30 yang hanya menyediakan 2 *host address* (7.7.7.1 untuk router dan 7.7.7.2 untuk VM DMZ). Pemilihan /30 bersifat *intentional* — DMZ adalah zona semi-tepercaya yang seharusnya hanya diisi oleh komponen yang benar-benar diperlukan. Subnet kecil meminimalkan *attack surface* dan menyulitkan pergerakan lateral (*lateral movement*) jika terjadi kompromi pada salah satu host di zona tersebut.

- **LAN (192.168.56.0/24):** Menggunakan subnet /24 yang menyediakan hingga 254 *host address*. Subnet yang lebih besar ini memberikan fleksibilitas untuk penambahan server atau layanan internal di masa mendatang, sementara tetap dilindungi oleh firewall MikroTik dari akses *external*. Penggunaan range `192.168.56.x` dipilih agar tidak konflik dengan subnet *host-only* default pada hypervisor VirtualBox.

**Port Mapping Aplikasi:**

| Aplikasi | Container Port | Host Port | Akses via Nginx |
|----------|---------------|-----------|-----------------|
| App 1 (Flask — Buku Tamu) | 5000 | 5000 | `app1.vdkj.local` |
| App 2 (PHP/Apache — Manajemen Produk) | 80 | 8080 | `app2.vdkj.local` |

## 2.3 Penjelasan Komponen dan Alasan Pemilihan Teknologi

### 2.3.1 MikroTik CHR (Router Virtual)

MikroTik CHR (*Cloud Hosted Router*) dipilih sebagai router virtual karena beberapa alasan berikut:

- **Kompatibilitas Hypervisor:** CHR tersedia dalam berbagai format *image* (VMDK, VDI, QCOW2) yang kompatibel dengan hypervisor utama seperti VirtualBox dan VMware, sehingga mudah di-*deploy* dalam lingkungan virtual tanpa memerlukan perangkat keras fisik.
- **Fitur Lengkap:** CHR menyediakan seluruh fitur routing dan firewall RouterOS, termasuk *stateful packet filtering*, NAT, *port forwarding* (DNAT), *connection tracking*, *address list*, dan *rate limiting* — seluruh kebutuhan proyek ini tercakup dalam satu perangkat virtual.
- **Digunakan di Industri:** MikroTik adalah salah satu vendor perangkat jaringan yang banyak digunakan oleh ISP dan enterprise di Indonesia, sehingga pengalaman konfigurasinya relevan dengan praktik profesional.
- **Resource Ringan:** CHR hanya membutuhkan 128–256 MB RAM dan 1 vCPU, sangat efisien untuk lingkungan virtual yang memiliki keterbatasan resource.

### 2.3.2 Ubuntu Server (VM DMZ)

Ubuntu Server 22.04 LTS dipilih sebagai sistem operasi untuk VM di segmen DMZ karena:

- **Stabilitas dan Dukungan Jangka Panjang:** Sebagai distribusi LTS (*Long Term Support*), Ubuntu Server 22.04 mendapat dukungan pembaruan keamanan selama 5 tahun (hingga April 2027), sehingga cocok untuk lingkungan produksi.
- **Ekosistem Paket Lengkap:** Ubuntu memiliki repositori paket yang sangat luas dan terkini, memudahkan instalasi Docker, Nginx, dan Suricata melalui *package manager* tanpa kompilasi manual.
- **Dokumentasi Melimpah:** Ubuntu adalah distribusi Linux yang paling banyak didokumentasikan di komunitas global, sehingga memudahkan proses *troubleshooting* dan pencarian solusi permasalahan.
- **Kompatibilitas Docker:** Docker secara resmi mendukung Ubuntu sebagai *first-class platform*, dengan dokumentasi dan *best practices* yang spesifik untuk distribusi ini.

### 2.3.3 Docker dan Docker Compose

Docker digunakan sebagai platform containerisasi untuk menjalankan kedua aplikasi web karena:

- **Isolasi Aplikasi:** Setiap aplikasi berjalan dalam container terisolasi dengan *filesystem*, *network namespace*, dan proses tersendiri, sehingga tidak saling mempengaruhi meskipun menggunakan *stack* teknologi yang berbeda.
- **Portabilitas:** Docker *image* yang dibangun dapat dijalankan di lingkungan mana pun yang mendukung Docker tanpa perubahan konfigurasi, menjadikannya ideal untuk replikasi dan *demo*.
- **Reproduktibilitas:** Dockerfile mendefinisikan secara eksplisit bagaimana *image* dibangun dari base *image* hingga konfigurasi akhir, sehingga proses *deployment* dapat direproduksi dengan hasil yang konsisten.
- **Docker Compose:** Memungkinkan definisi dan pengelolaan multi-container dalam satu file YAML, termasuk *environment variable* untuk konfigurasi koneksi database, *port mapping*, dan konfigurasi *network*.
- **Keamanan:** Docker mendukung pembatasan hak akses container agar tidak berjalan sebagai *root user* (prinsip *least privilege*), mengurangi risiko eskalasi privilege jika container mengalami kompromi.

### 2.3.4 Python/Flask (App 1 — Buku Tamu)

Python dengan *framework* Flask dipilih untuk aplikasi pertama (Buku Tamu) karena:

- **Ringkas dan Minimalis:** Flask adalah *micro-framework* yang tidak memaksakan struktur proyek tertentu, cocok untuk aplikasi web sederhana berbasis CRUD (*Create, Read, Update, Delete*) seperti buku tamu.
- **Fleksibilitas:** Flask memberikan kebebasan dalam memilih komponen tambahan (*database driver*, *template engine*, dll.) sesuai kebutuhan, tanpa membawa dependensi yang tidak diperlukan.
- **Cepat Dikembangkan:** Dengan Flask, aplikasi web CRUD lengkap dapat dibangun dalam satu file Python utama (`app.py`) dengan *template* HTML terpisah.
- **Gunicorn sebagai WSGI Server:** Untuk lingkungan produksi dalam container, Gunicorn digunakan sebagai *application server* yang lebih *robust* dibanding *development server* bawaan Flask, dengan dukungan *worker process* dan *graceful restart*.

### 2.3.5 PHP/Apache (App 2 — Manajemen Produk)

PHP dengan Apache dipilih untuk aplikasi kedua (Manajemen Produk) karena:

- **Stack Berbeda (Persyaratan Proyek):** Panduan proyek mensyaratkan kedua aplikasi menggunakan *stack* teknologi yang berbeda untuk mendemonstrasikan fleksibilitas containerisasi dan kemampuan menjalankan berbagai platform dalam satu infrastruktur.
- **Prevalensi di Industri:** PHP masih menjadi salah satu bahasa *server-side* yang paling banyak digunakan di web (meng-*power* sekitar 77% website yang menggunakan server-side language), sehingga pengalaman mengonfigurasinya bersifat praktis dan relevan.
- **Docker Image Resmi:** Image `php:8.3-apache` dari Docker Hub menyediakan *base image* yang sudah dilengkapi Apache web server dan PHP 8.3, mempercepat proses *deployment*.
- **Kesederhanaan Deployment:** PHP tidak memerlukan proses *build* terpisah — file `.php` langsung dieksekusi oleh Apache tanpa langkah kompilasi, menyederhanakan siklus *development-to-production*.

### 2.3.6 Nginx (Reverse Proxy)

Nginx dipilih sebagai *reverse proxy* karena:

- **Performa Tinggi:** Nginx menggunakan arsitektur *event-driven* dan *non-blocking I/O* yang mampu menangani ribuan koneksi simultan dengan penggunaan resource (CPU dan memori) yang minimal.
- **Virtual Host:** Nginx mendukung konfigurasi *server block* untuk mengarahkan request ke *backend* yang berbeda berdasarkan *hostname*, memungkinkan kedua aplikasi diakses melalui satu IP dan port yang sama tanpa konflik.
- **Security Headers:** Nginx memudahkan penambahan *header* keamanan HTTP seperti `X-Frame-Options` (mencegah *clickjacking*), `X-Content-Type-Options` (mencegah *MIME-type sniffing*), dan `Referrer-Policy` (mengontrol informasi *referrer*) melalui direktif `add_header`.
- **Logging Terstruktur:** Nginx menyediakan mekanisme *access log* dan *error log* yang terpisah per *virtual host*, memudahkan monitoring, audit, dan analisis traffic.
- **Standar Industri:** Nginx adalah web server dan *reverse proxy* yang paling banyak digunakan di dunia, melayani sekitar 34% dari seluruh website global.

### 2.3.7 Suricata (IDS/IPS)

Suricata dipilih sebagai sistem deteksi intrusi karena:

- **Multi-Threaded:** Suricata mendukung *multi-threaded processing*, memungkinkan pemrosesan *traffic* berkecepatan tinggi tanpa menjadi *bottleneck* pada jaringan.
- **EVE JSON Logging:** Suricata menghasilkan log dalam format JSON terstruktur (disebut *EVE — Extensible Event Format*), yang mudah diintegrasikan dengan工具 analisis log seperti ELK Stack, Splunk, atau alat analisis sederhana berbasis *command-line*.
- **Kompatibilitas Rule:** Suricata kompatibel dengan format rule Snort, sehingga dapat menggunakan *rule set* standar seperti Emerging Threats di samping *custom rules* yang dibuat khusus untuk mendeteksi serangan terhadap aplikasi web proyek ini.
- **Mode IDS dan IPS:** Suricata dapat berjalan dalam mode IDS pasif (*monitoring* — tidak memblokir traffic) maupun mode IPS aktif (*inline blocking*), memberikan fleksibilitas dalam desain keamanan. Proyek ini menggunakan mode IDS pasif dengan EVE JSON *logging*.
- **Open Source:** Suricata adalah proyek *open source* yang didukung oleh komunitas dan OISF (*Open Information Security Foundation*), sehingga tidak memerlukan biaya lisensi.

### 2.3.8 MariaDB/MySQL (Database Server)

MariaDB dipilih sebagai server database karena:

- **Kompatibilitas MySQL:** MariaDB adalah *drop-in replacement* untuk MySQL, mendukung seluruh fitur, syntax SQL, dan *connector* yang sama, sehingga aplikasi yang ditulis untuk MySQL dapat berjalan tanpa modifikasi pada MariaDB.
- **User Terpisah per Aplikasi:** MariaDB memungkinkan pembuatan *database user* yang terpisah untuk setiap aplikasi (`app1_user` untuk Buku Tamu dan `app2_user` untuk Manajemen Produk), mendukung prinsip *least privilege* di level database.
- **Bind Address:** Konfigurasi `bind-address` pada MariaDB dapat diatur untuk menerima koneksi dari *interface* dan IP tertentu saja, menambah lapisan keamanan jaringan di level database.
- **Firewall Lapisan Tambahan:** Dikombinasikan dengan UFW (*Uncomplicated Firewall*) di level sistem operasi, akses ke port 3306 dapat dibatasi hanya dari IP VM DMZ (`7.7.7.2`), menciptakan pertahanan berlapis (*defense in depth*).
- **Stabilitas dan Performa:** MariaDB telah terbukti stabil dan memiliki performa tinggi untuk beban kerja OLTP (*Online Transaction Processing*) skala kecil hingga menengah.
