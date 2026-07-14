# LAPORAN TUGAS PROYEK KELOMPOK
Virtualisasi dan Keamanan Jaringan:
Implementasi Arsitektur Jaringan Tersegmentasi

## Anggota Kelompok
1. Muhammad Jibril Ibrahim - 0110224002
2. Muhammad Hisyam Alfaris - 0110224006
3. Anis Adriyani - 0110224013
4. Zainab Aznur - 0110224009
5. Arya Nuryawan - 0110224012
6. Eshi Aulia - 0110224007

## Deskripsi Proyek
Proyek ini merupakan tugas akhir mata kuliah Virtualisasi dan Keamanan Jaringan. Tujuan utamanya adalah merancang, membangun, mengonfigurasi, dan mendokumentasikan infrastruktur jaringan virtual dengan arsitektur tersegmentasi yang mencerminkan praktik industri nyata.

## Arsitektur Sistem

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
Nginx +      MySQL
Suricata
Docker:
  App1, App2
```

### Komponen Utama

| Komponen | Segmen | Teknologi | Keterangan |
|----------|--------|-----------|------------|
| Router Virtual | External/DMZ/LAN | MikroTik CHR | Gateway utama, firewall, NAT |
| VM Aplikasi (DMZ) | 7.7.7.0/30 | Ubuntu Server | Web server & IDS/IPS |
| Container Web App 1 | Docker Network (DMZ) | Docker | Aplikasi web 1 |
| Container Web App 2 | Docker Network (DMZ) | Docker | Aplikasi web 2 |
| Reverse Proxy | VM DMZ | Nginx | Routing traffic ke container |
| IDS/IPS | VM DMZ | Suricata | Monitoring & blocking |
| Database Server | 192.168.56.0/24 | MySQL/MariaDB | Backend database LAN |

## Spesifikasi Implementasi

### 1. Router MikroTik CHR
- 3 interface virtual: ether1 (External/WAN), ether2 (DMZ), ether3 (LAN)
- IP Address: External (DHCP/static), DMZ: 7.7.7.x/30, LAN: 192.168.56.1/24
- Firewall rules (INPUT, FORWARD, NAT, Port Forwarding, Connection Tracking, Address List)

### 2. VM Ubuntu (DMZ)
- Nginx sebagai reverse proxy dengan virtual host untuk masing-masing app
- Docker Compose dengan 2 container web app (berbeda stack)
- Suricata IDS/IPS dengan minimal 3 custom rules

### 3. Database Server (LAN)
- MySQL/MariaDB dengan user terpisah untuk App1 dan App2
- Firewall OS: hanya izinkan port 3306 dari IP VM DMZ
- Skema database dengan data dummy

## Struktur Repository

```
.
├── docs/                          # Dokumen panduan & referensi
├── laporan/                       # File laporan (.docx)
├── config/
│   ├── mikrotik/                  # Export konfigurasi MikroTik (.rsc)
│   ├── nginx/                     # Konfigurasi Nginx (.conf)
│   ├── suricata/                  # Konfigurasi Suricata & custom rules
│   ├── docker/                    # Dockerfile & docker-compose.yml
│   └── mysql/                     # Script SQL skema & data dummy
├── apps/
│   ├── app1/                      # Source code aplikasi web 1
│   └── app2/                      # Source code aplikasi web 2
├── screenshots/                   # Screenshot hasil implementasi & pengujian
├── slides/                        # Presentasi
├── Panduan-Tugas-Proyek-Virtualisasi-Keamanan-Jaringan.docx
└── readme.md
```

## Cara Menjalankan / Replikasi

> Bagian ini akan diisi setelah implementasi selesai.

### Prerequisites
- Hypervisor (VirtualBox / VMware / Proxmox)
- MikroTik CHR image
- Ubuntu Server 20.04+ ISO
- Docker & Docker Compose

### Langkah Setup
1. Import / deploy MikroTik CHR pada hypervisor
2. Buat VM Ubuntu pada segmen DMZ
3. Buat VM / host untuk Database Server pada segmen LAN
4. Konfigurasi router, firewall, dan routing (lihat `config/mikrotik/`)
5. Deploy container aplikasi web (lihat `config/docker/`)
6. Konfigurasi Nginx reverse proxy (lihat `config/nginx/`)
7. Setup database MySQL (lihat `config/mysql/`)
8. Install dan konfigurasi Suricata (lihat `config/suricata/`)
9. Jalankan pengujian sesuai skenario di laporan

## Status Implementasi

- [x] Perencanaan & desain arsitektur
- [x] Konfigurasi MikroTik CHR (interface, IP, routing, firewall, NAT)
- [x] Setup VM Ubuntu di DMZ
- [x] Deploy Docker container (2 web app)
- [x] Konfigurasi Nginx reverse proxy
- [x] Setup MySQL di LAN
- [x] Integrasi app ↔ database
- [x] Install & konfigurasi Suricata IDS/IPS
- [x] Pengujian konektivitas & keamanan
- [~] Penyusunan laporan — draft selesai, dalam tahap review
- [ ] Presentasi & demo — belum dikerjakan
