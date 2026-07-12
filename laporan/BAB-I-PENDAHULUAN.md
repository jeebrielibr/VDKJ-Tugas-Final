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