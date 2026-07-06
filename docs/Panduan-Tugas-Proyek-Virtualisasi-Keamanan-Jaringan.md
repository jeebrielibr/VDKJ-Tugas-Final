

| PANDUAN TUGAS PROYEK Virtualisasi dan Keamanan Jaringan *Implementasi Arsitektur Jaringan Tersegmentasi* |
| :---: |

| Mata Kuliah | Virtualisasi dan Keamanan Jaringan |
| :---- | :---- |
| Jenis Tugas | Proyek Kelompok |
| Sifat | Implementasi & Dokumentasi |
| Periode | Semester Genap  2025/2026 |
| Revisi Dokumen | v1.0 — 2026 |

# **1\. Deskripsi Umum Proyek**

Tugas proyek ini merupakan komponen utama penilaian mata kuliah Virtualisasi dan Keamanan Jaringan. Mahasiswa secara berkelompok akan merancang, membangun, mengonfigurasi, dan mendokumentasikan sebuah infrastruktur jaringan virtual yang mencerminkan praktik industri nyata dalam membangun lingkungan jaringan yang aman dan terkelola.

Proyek ini mengintegrasikan konsep virtualisasi mesin, containerisasi aplikasi, keamanan jaringan berlapis, serta monitoring intrusi. Arsitektur yang dibangun terdiri dari tiga segmen jaringan yang terpisah: External Network, DMZ (Demilitarized Zone), dan LAN internal, yang dihubungkan dan diproteksi melalui router virtual berbasis MikroTik CHR.

| Tujuan Pembelajaran (Learning Outcomes) |
| :---- |
| LO1 — Mahasiswa mampu mengimplementasikan virtualisasi mesin menggunakan hypervisor dan teknologi container. |
| LO2 — Mahasiswa mampu merancang dan mengonfigurasi segmentasi jaringan yang aman (DMZ, LAN, External). |
| LO3 — Mahasiswa mampu menerapkan kebijakan firewall dan routing pada perangkat jaringan virtual MikroTik. |
| LO4 — Mahasiswa mampu men-deploy aplikasi web dalam container Docker dan mengintegrasikannya dengan database. |
| LO5 — Mahasiswa mampu menginstalasi dan mengonfigurasi sistem IDS/IPS berbasis Suricata. |
| LO6 — Mahasiswa mampu mendokumentasikan infrastruktur jaringan secara teknis dan profesional. |

# **2\. Arsitektur Sistem Target**

## **2.1 Gambaran Umum**

Arsitektur sistem yang harus diimplementasikan oleh setiap kelompok adalah sebagai berikut:

| Diagram Topologi Sistem |
| :---: |
| **\[ External Network \]**           |     **\[ Router MikroTik CHR \]**      /              \\ 7.7.7.7/30 (DMZ)    192.168.56.0/24 (LAN) |                    | **\[ VM Ubuntu \]        \[ DB Server \]**   Nginx \+ Suricata    MySQL Database   Docker: App1, App2   ![][image1] |

## **2.2 Spesifikasi Komponen Jaringan**

| Komponen | Segmen/Subnet | Teknologi | Keterangan |
| :---- | :---- | :---- | :---- |
| Router Virtual | External / DMZ / LAN | MikroTik CHR | Gateway utama |
| VM Aplikasi (DMZ) | 7.7.7.7/30 | Ubuntu Linux | Web server & IDS |
| Container Web App 1 | Docker Network (DMZ) | Docker \+ App Stack | Aplikasi web 1 |
| Container Web App 2 | Docker Network (DMZ) | Docker \+ App Stack | Aplikasi web 2 |
| Reverse Proxy | VM DMZ | Nginx | Routing traffic ke container |
| IDS/IPS | VM DMZ | Suricata | Monitoring & blocking |
| Database Server | 192.168.56.0/24 | Ubuntu \+ MySQL | Backend database LAN |

# **3\. Spesifikasi Teknis dan Tugas Implementasi**

## **3.1 Router Virtual MikroTik CHR**

Router MikroTik CHR (Cloud Hosted Router) menjadi inti infrastruktur jaringan. Berikut konfigurasi yang wajib diimplementasikan:

### **3.1.1 Konfigurasi Interface dan IP Address**

* Buat minimal 3 (tiga) interface virtual: ether1 (External/WAN), ether2 (DMZ), ether3 (LAN)

* Konfigurasi IP Address sesuai skema: External (DHCP/static dari hypervisor), DMZ: 7.7.7.x/30, LAN: 192.168.56.1/24

* Aktifkan DNS client pada router

* Konfigurasi routing default dan static route yang diperlukan

### **3.1.2 Firewall Rules MikroTik**

Mahasiswa WAJIB mengimplementasikan firewall rules berikut pada MikroTik:

1. Filter Chain INPUT: Drop semua koneksi masuk ke router kecuali dari IP management yang diizinkan; Izinkan ICMP (ping) dari dalam untuk troubleshooting; Izinkan SSH hanya dari subnet LAN; Drop port scanning dengan connection-limit.

2. Filter Chain FORWARD — DMZ ke LAN: Izinkan HANYA traffic port MySQL (3306) dari IP VM DMZ menuju IP Database Server di LAN; Blokir semua traffic lain dari DMZ ke LAN secara eksplisit.

3. Filter Chain FORWARD — External ke DMZ: Izinkan traffic ke port 80 (HTTP) dan 443 (HTTPS) menuju IP Nginx di DMZ; Blokir direct access ke port aplikasi container (misal port 3000, 8080\) dari external; Implementasikan rate limiting untuk mencegah DDoS sederhana.

4. NAT Masquerade: Aktifkan NAT srcnat masquerade pada interface external untuk traffic dari LAN dan DMZ.

5. Port Forwarding (DNAT): Forward traffic dari IP external port 80/443 ke IP VM Ubuntu di DMZ.

6. Connection Tracking: Aktifkan connection state tracking; Drop packet dengan state invalid; Accept packet established dan related.

7. Firewall Address List: Buat address list untuk blokir IP mencurigakan dan implementasikan drop rule-nya.

## **3.2 VM Ubuntu di DMZ**

Satu buah Virtual Machine berbasis Ubuntu Server (versi 20.04 LTS atau lebih baru) harus dibuat dan dikonfigurasi di segmen DMZ dengan IP dalam subnet 7.7.7.0/30.

### **3.2.1 Nginx sebagai Reverse Proxy**

* Install dan konfigurasi Nginx

* Buat konfigurasi virtual host (server block) untuk masing-masing aplikasi web

* Nginx harus mem-forward request dari external ke container yang berjalan di Docker

* Konfigurasi upstream block untuk load balancing sederhana (opsional: tambahkan health check)

* Aktifkan access log dan error log dengan format yang informatif

* Tambahkan security headers: X-Frame-Options, X-Content-Type-Options, Referrer-Policy

### **3.2.2 Docker Container — Dua Aplikasi Web**

Dua container Docker harus dijalankan di dalam VM Ubuntu:

* Container App 1 dan Container App 2 harus berupa aplikasi web yang berbeda (boleh menggunakan stack: PHP/Laravel, Node.js/Express, Python/Flask — pilih sesuai kemampuan kelompok)

* Kedua aplikasi HARUS terhubung ke database MySQL yang ada di server LAN (192.168.56.0/24)

* Gunakan Docker Compose untuk mendefinisikan dan menjalankan kedua container

* Setiap container harus memiliki environment variable untuk konfigurasi koneksi database

* Pastikan container tidak berjalan sebagai root user (gunakan non-root user di dalam container)

* Buat Dockerfile custom untuk setidaknya satu dari kedua aplikasi

### **3.2.3 Suricata IDS/IPS**

* Install Suricata pada VM Ubuntu

* Konfigurasi Suricata untuk memonitor interface network yang mengarah ke traffic DMZ

* Aktifkan rule set standar (Emerging Threats atau Suricata rules bawaan)

* Tambahkan minimal 3 (tiga) custom rule yang relevan untuk mendeteksi serangan pada aplikasi web (contoh: SQL Injection, XSS detection, port scan detection)

* Konfigurasi Suricata dalam mode IPS (inline) menggunakan NFQueue ATAU mode IDS (passive) dengan EVE JSON logging

* Pastikan log Suricata tersimpan dan dapat dianalisis

## **3.3 Database Server (LAN)**

Server database MySQL/MariaDB harus berada di segmen LAN (192.168.56.0/24) dan TIDAK boleh diakses langsung dari External Network.

* Install MySQL Server atau MariaDB pada VM/host di segmen LAN

* Buat database dan user khusus untuk masing-masing aplikasi web (App1 dan App2 sebaiknya memiliki user DB yang berbeda)

* Konfigurasi bind-address MySQL agar hanya menerima koneksi dari subnet yang diizinkan

* Buat skema database minimal dengan beberapa tabel dan isi dengan data dummy untuk pengujian

* Aktifkan firewall di level OS (ufw/iptables) pada server database: hanya izinkan port 3306 dari IP VM DMZ

# **4\. Pengujian dan Verifikasi Sistem**

Setelah implementasi selesai, setiap kelompok wajib melakukan pengujian menyeluruh dan mendokumentasikan hasilnya dalam laporan. Berikut skenario pengujian minimal yang harus dilakukan:

| 4.1 Pengujian Konektivitas Dasar |
| :---- |
| \[ \] Ping dari External ke Router (harus berhasil sesuai rule firewall) |
| \[ \] Ping dari DMZ ke LAN (harus berhasil) |
| \[ \] Ping dari External ke LAN langsung (harus GAGAL — diblokir firewall) |
| \[ \] Akses HTTP/HTTPS ke Nginx dari external (harus berhasil) |
| \[ \] Akses langsung ke port container dari external (harus GAGAL) |
| \[ \] Koneksi MySQL dari VM DMZ ke Database Server (harus berhasil) |
| \[ \] Koneksi MySQL dari external langsung (harus GAGAL) |

| 4.2 Pengujian Aplikasi Web |
| :---- |
| \[ \] Aplikasi Web 1 dapat diakses melalui Nginx reverse proxy |
| \[ \] Aplikasi Web 2 dapat diakses melalui Nginx reverse proxy |
| \[ \] Kedua aplikasi berhasil membaca/menulis data ke database MySQL di LAN |
| \[ \] Nginx access log mencatat request dengan benar |
| \[ \] Response header keamanan (security headers) ada di response HTTP |

| 4.3 Pengujian Firewall MikroTik |
| :---- |
| \[ \] Rule DROP untuk koneksi dari External ke LAN langsung berfungsi |
| \[ \] Rate limiting aktif dan membatasi traffic berlebihan |
| \[ \] Address list blocking berfungsi untuk IP yang ditambahkan manual |
| \[ \] Connection state tracking: packet INVALID di-drop |
| \[ \] Hanya port 80/443 yang dapat diakses dari External ke DMZ |
| \[ \] SSH ke router hanya bisa dari LAN, tidak dari External |

| 4.4 Pengujian Suricata IDS/IPS |
| :---- |
| \[ \] Suricata berjalan aktif dan memproses traffic |
| \[ \] Alert muncul di log saat dilakukan simulasi serangan (misal: Nmap scan) |
| \[ \] Custom rule yang dibuat kelompok memicu alert saat ada traffic yang cocok |
| \[ \] Log Suricata (EVE JSON) dapat dibaca dan dianalisis |

# **5\. Deliverables (Luaran yang Dikumpulkan)**

Setiap kelompok wajib mengumpulkan seluruh item berikut sebelum batas waktu yang telah ditentukan:

## **5.1 Laporan Teknis (Bobot: 40%)**

Laporan tertulis dalam format PDF/Word dengan struktur minimal sebagai berikut:

8. Halaman Judul: Nama proyek, nama anggota kelompok, nomor kelompok, tanggal pengumpulan

9. Pendahuluan: Latar belakang, tujuan, dan ruang lingkup implementasi

10. Desain Arsitektur: Diagram jaringan lengkap dengan IP address, penjelasan setiap komponen dan alasan pemilihan teknologi

11. Implementasi: Langkah-langkah konfigurasi detail untuk setiap komponen (Router, VM, Docker, Nginx, Suricata, Database), disertai screenshot setiap langkah penting

12. Konfigurasi Keamanan: Penjelasan semua firewall rule MikroTik beserta justifikasi keamanan, konfigurasi Suricata dan custom rules yang dibuat

13. Hasil Pengujian: Screenshot dan analisis hasil semua pengujian yang tercantum di Bagian 4

14. Kendala dan Solusi: Permasalahan yang ditemui selama implementasi dan bagaimana cara mengatasinya

15. Kesimpulan dan Saran

16. Lampiran: File konfigurasi lengkap (router export, docker-compose.yml, nginx.conf, suricata.yaml, dll.)

## **5.2 File Konfigurasi dan Source Code (Bobot: 30%)**

* Export konfigurasi MikroTik lengkap (file .rsc dari perintah /export)

* docker-compose.yml untuk kedua container aplikasi web

* Dockerfile untuk aplikasi yang dibuat custom

* Konfigurasi Nginx (file .conf)

* File konfigurasi Suricata (suricata.yaml) dan custom rules (.rules)

* Source code aplikasi web (jika dibuat dari awal atau dimodifikasi)

* Script SQL untuk membuat database dan data dummy

* README.md yang menjelaskan cara menjalankan/mereplikasi setup

## **5.3 Presentasi dan Demonstrasi Rekaman (Bobot: 30%)**

Setiap kelompok akan mempresentasikan dan mendemonstrasikan sistem yang telah dibangun di dalam bentuk rekaman seolah dihadapan dosen dan/atau asisten

* Durasi presentasi: 20-30 menit per kelompok

* Demonstrasi sistem harus dilakukan secara langsung dalam rekaman video

* Setiap anggota kelompok harus siap menjawab pertanyaan teknis

* Dosen/asisten berhak meminta demonstrasi skenario tambahan di luar yang direncanakan

* Slide presentasi (PowerPoint/PDF) dikumpulkan sebagai bagian dari deliverables

# **6\. Rubrik dan Komponen Penilaian**

Penilaian proyek dilakukan berdasarkan komponen berikut:

| No | Komponen Penilaian | Sub-Komponen | Bobot (%) |
| ----- | :---- | :---- | :---: |
| 1 | Konfigurasi Router MikroTik CHR | Interface & IP Address benar | 5 |
|  |  | Routing antar segmen berfungsi | 5 |
|  |  | Firewall rules lengkap & tepat | 15 |
|  |  | NAT & Port Forwarding | 5 |
| 2 | VM Ubuntu & Docker | VM terkonfigurasi di DMZ | 5 |
|  |  | Docker Compose dengan 2 container | 10 |
|  |  | Aplikasi web fungsional & terkoneksi DB | 10 |
| 3 | Nginx Reverse Proxy | Konfigurasi upstream & proxy pass | 5 |
|  |  | Security headers | 3 |
|  |  | Logging aktif | 2 |
| 4 | Suricata IDS/IPS | Instalasi & konfigurasi dasar | 5 |
|  |  | Custom rules relevan (min. 3\) | 5 |
|  |  | Alert terdeteksi saat pengujian | 5 |
| 5 | Database Server (LAN) | MySQL terpasang & dikonfigurasi | 5 |
|  |  | Akses terbatas dari DMZ saja | 5 |
| 6 | Laporan & Dokumentasi | Kelengkapan & kejelasan laporan | 10 |
| 7 | Presentasi & Demo | Presentasi & demonstrasi | 15 |
|  |  | TOTAL | 100 |

| Catatan Penting Penilaian |
| :---- |
| Sistem yang tidak dapat didemonstrasikan secara live akan mendapat pengurangan nilai signifikan. |
| Plagiarisme atau copy-paste konfigurasi dari kelompok lain tanpa modifikasi akan mendapat nilai 0\. |
| Keterlambatan pengumpulan: \-5 poin per hari terlambat. |
| Semua anggota kelompok harus dapat menjelaskan setiap bagian konfigurasi yang dibuat. |

# **7\. Ketentuan Kelompok dan Pembagian Tugas**

## **7.1 Komposisi Kelompok**

* Setiap kelompok terdiri dari mahasiswa sesuai pembagian yang telah ditetapkan oleh dosen

* Tidak diperkenankan berpindah kelompok tanpa izin dari dosen pengampu

* Jika ada anggota yang tidak aktif berkontribusi, wajib dilaporkan kepada dosen dengan disertai bukti

## **7.2 Saran Pembagian Peran (Role)**

Berikut adalah saran pembagian peran dalam kelompok, disesuaikan dengan jumlah anggota:

| Peran | Tanggung Jawab Utama |
| :---- | :---- |
| Network Engineer | Konfigurasi MikroTik CHR, firewall rules, routing, NAT |
| System Administrator | Setup VM Ubuntu, instalasi Nginx, konfigurasi Suricata |
| DevOps / Developer | Pembuatan Dockerfile, Docker Compose, aplikasi web |
| Database Administrator | Instalasi MySQL, pembuatan skema database, security database |
| Documentation & QA | Laporan teknis, pengujian sistem, slide presentasi |

*Catatan: Pembagian peran bersifat fleksibel. Setiap anggota diperkenankan — bahkan dianjurkan — untuk saling membantu di luar peran utamanya. Kolaborasi aktif seluruh anggota mencerminkan semangat kerja tim yang profesional.*

# **8\. Jadwal dan Ketentuan Pengumpulan**

## **8.1 Tahapan Pengerjaan (Timeline)**

| Minggu ke- | Milestone | Target Aktivitas |
| :---- | :---- | :---- |
| 1 – 2 | Perencanaan & Setup | Desain arsitektur, pembagian tugas, instalasi hypervisor dan VM dasar |
| 3 – 4 | Infrastruktur Jaringan | Konfigurasi MikroTik CHR, interface, routing, firewall rules dasar |
| 5 – 6 | VM & Containerisasi | Setup VM Ubuntu DMZ, instalasi Docker, deploy kedua container web app |
| 7 | Nginx & Database | Konfigurasi Nginx reverse proxy, setup MySQL di LAN, integrasi app-DB |
| 8 | Keamanan & IDS | Instalasi Suricata, custom rules, hardening firewall MikroTik lanjutan |
| 9 | Pengujian & Debugging | Pengujian seluruh skenario, perbaikan bug dan konfigurasi |
| 10 | Laporan & Presentasi | Finalisasi laporan, slide presentasi, demo preparation |

## **8.2 Ketentuan Pengumpulan**

* Semua file dikumpulkan melalui platform yang telah ditentukan dosen (LMS/Google Classroom/email)

* Berkas dikumpulkan dalam satu folder/arsip ZIP dengan format nama: PROYEK\_KelompokXX\_NamaAnggota

* Laporan dikumpulkan dalam format PDF

* File konfigurasi dan source code dikumpulkan dalam format aslinya (bukan screenshot)

* Batas waktu pengumpulan: sesuai pengumuman dosen di pertemuan kelas

# **9\. Referensi dan Sumber Belajar**

Berikut referensi yang direkomendasikan untuk mendukung pengerjaan proyek:

## **Dokumentasi Resmi**

* MikroTik Wiki: wiki.mikrotik.com — dokumentasi lengkap CHR dan firewall

* Docker Docs: docs.docker.com — panduan Docker dan Docker Compose

* Nginx Docs: nginx.org/en/docs — konfigurasi Nginx dan reverse proxy

* Suricata Docs: suricata.io/docs — instalasi, konfigurasi, dan penulisan rules

* MySQL Docs: dev.mysql.com/doc — administrasi dan konfigurasi MySQL

## **Topik yang Disarankan untuk Dipelajari**

* Konsep DMZ dan segmentasi jaringan

* Firewall stateful vs stateless

* Prinsip Least Privilege pada konfigurasi jaringan dan database

* Dasar-dasar penulisan Suricata rules (rule syntax)

* Docker networking dan multi-container communication

* Nginx upstream dan load balancing

| Bantuan dan Konsultasi |
| :---- |
| Mahasiswa dapat melakukan konsultasi dengan dosen atau asisten praktikum pada jam yang telah ditentukan. |
| Pertanyaan teknis dapat diajukan melalui forum diskusi yang tersedia di LMS atau grup komunikasi resmi kelas. |
| Dosen TIDAK akan memberikan solusi langsung, namun akan memberikan arahan dan petunjuk. |
| Dokumentasikan setiap kendala yang ditemui — ini akan menjadi nilai tambah dalam laporan. |

*Selamat mengerjakan\! Keberhasilan proyek ini mencerminkan kemampuan Anda sebagai calon profesional di bidang jaringan dan keamanan sistem.*

[image1]: <data:image/png;base64,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>