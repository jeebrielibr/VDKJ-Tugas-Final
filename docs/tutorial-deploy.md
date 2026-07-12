# Tutorial Deploy — VDKJ Tugas Final
## Implementasi Arsitektur Jaringan Tersegmentasi

> **Tujuan dokumen ini:** Panduan langkah-demi-langkah untuk membangun seluruh infrastruktur dari nol. Ikuti urutannya. Setiap langkah memiliki **📋 Checklist Dokumentasi** — jangan lupa screenshot untuk laporan.

---

## Daftar Isi

1. [Prasyarat & Persiapan](#1-prasyarat--persiapan)
2. [Deploy MikroTik CHR](#2-deploy-mikro-tik-chr)
3. [Konfigurasi Interface & IP MikroTik](#3-konfigurasi-interface--ip-mikrotik)
4. [Firewall MikroTik](#4-firewall-mikrotik)
5. [NAT & Port Forwarding](#5-nat--port-forwarding)
6. [Buat VM Ubuntu di DMZ](#6-buat-vm-ubuntu-di-dmz)
7. [Install Docker & Deploy App](#7-install-docker--deploy-app)
8. [Konfigurasi Nginx Reverse Proxy](#8-konfigurasi-nginx-reverse-proxy)
9. [Setup Database Server (LAN)](#9-setup-database-server-lan)
10. [Install & Konfigurasi Suricata](#10-install--konfigurasi-suricata)
11. [Pengujian End-to-End](#11-pengujian-end-to-end)
12. [Tips Screenshot & Laporan](#12-tips-screenshot--laporan)

---

## 1. Prasyarat & Persiapan

### 1.1 Software yang Dibutuhkan

| Software | Versi Minimum | Keterangan |
|----------|--------------|------------|
| VirtualBox / VMware | 7.0+ / 17+ | Hypervisor untuk VM |
| MikroTik CHR | 7.x | Image `.img` atau `.vmdk` |
| Ubuntu Server | 22.04 LTS | ISO untuk VM DMZ & DB Server |
| PuTTY / Terminal | — | Akses SSH ke semua VM |

### 1.2 Skema IP Address (Patokan Seluruh Tutorial)

```
┌─────────────────────────────────────────────────────┐
│                  NETWORK TOPOLOGY                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [External Network]                                 │
│       │                                             │
│  [MikroTik CHR]                                     │
│   ether1-external : DHCP (dari hypervisor)          │
│   ether2-dmz : 7.7.7.1/30                           │
│   ether3-lan : 192.168.56.1/24                      │
│       │           │                                 │
│  ┌────┴────┐  ┌───┴──────────┐                      │
│  │  DMZ    │  │    LAN       │                      │
│  │7.7.7.0  │  │192.168.56.0  │                      │
│  │  /30    │  │    /24       │                      │
│  └────┬────┘  └───┬──────────┘                      │
│       │           │                                 │
│  VM Ubuntu    DB Server                             │
│  7.7.7.2     192.168.56.10                          │
│  Nginx       MySQL                                  │
│  Docker      MariaDB                                │
│  Suricata                                           │
│  ┌────────┐                                         │
│  │App1    │  Flask (port 5000)                      │
│  │App2    │  PHP   (port 8080→80)                   │
│  └────────┘                                         │
└─────────────────────────────────────────────────────┘
```

### 1.3 Struktur File di Repo

```
config/
├── mikrotik/vdkj-mikrotik.rsc    ← load ke MikroTik
├── docker/docker-compose.yml      ← jalankan di VM DMZ
├── nginx/vdkj-apps.conf           ← copy ke /etc/nginx/sites-available/
├── suricata/
│   ├── suricata.yaml              ← copy ke /etc/suricata/
│   └── custom-vdkj.rules          ← copy ke /var/lib/suricata/rules/
└── mysql/init.sql                 ← jalankan di DB Server

apps/
├── app1/  (Flask — Buku Tamu)
└── app2/  (PHP — Manajemen Produk)
```

> **📋 Dokumentasi:** Screenshot folder structure repo, screenshot skema IP di atas (atau buat diagram jaringan sendiri di draw.io/Lucidchart). Ini masuk **BAB II — Desain Arsitektur**.

---

## 2. Deploy MikroTik CHR

### 2.1 Download & Import Image

1. Download MikroTik CHR image dari https://mikrotik.com/download
   - Pilih format **VDI** (VirtualBox) atau **VMDK** (VMware)
   - Versi: **Stable 7.x**

2. Buat VM baru di hypervisor:
   ```
   Nama        : MikroTik-CHR
   Type        : Linux
   Version     : Other Linux (64-bit)
   RAM         : 256 MB (cukup)
   Disk        : Import image CHR yang sudah didownload
   ```

3. **PENTING — Network Adapter Configuration:**

   | Adapter | Type | Connected To | Keterangan |
   |---------|------|-------------|------------|
   | NIC 1   | Bridged / Host-only | Network external | → ether1-external |
   | NIC 2   | Internal / Host-only | `dmz-network` | → ether2-dmz |
   | NIC 3   | Internal / Host-only | `lan-network` | → ether3-lan |

   > **Catatan VirtualBox:** Buat **Internal Network** bernama `dmz-network` dan `lan-network` di Settings > Network > Internal Network.
   >
   > **Catatan VMware:** Buat custom Virtual Network (VMnet) untuk DMZ dan LAN.

4. Start VM. Login default:
   ```
   Username: admin
   Password: (kosong, langsung Enter)
   ```

### 2.2 Aktivasi License

```shell
# Cek status license
/system license print

# Jika CHR Free, jalankan:
/system license renew
```

> **📋 Dokumentasi:**
> - Screenshot pengaturan Network Adapter (3 NIC) di hypervisor
> - Screenshot MikroTik CHR berhasil boot (terminal login)
> - Screenshot `/system license print`
> - **Masuk ke: BAB III §3.2 — Konfigurasi Router MikroTik CHR**

---

## 3. Konfigurasi Interface & IP MikroTik

### 3.1 Rename Interface

```routeros
/interface ethernet
set [ find default-name=ether1 ] name=ether1-external
set [ find default-name=ether2 ] name=ether2-dmz
set [ find default-name=ether3 ] name=ether3-lan
```

### 3.2 Buat Interface List

```routeros
/interface list
add name=external
add name=DMZ
add name=LAN

/interface list member
add interface=ether1-external list=external
add interface=ether2-dmz list=DMZ
add interface=ether3-lan list=LAN
```

### 3.3 Konfigurasi IP Address

```routeros
# DMZ interface
/ip address
add address=7.7.7.1/30 interface=ether2-dmz network=7.7.7.0

# LAN interface
add address=192.168.56.1/24 interface=ether3-lan network=192.168.56.0
```

### 3.4 external (DHCP Client)

Jika external network punya DHCP server:

```routeros
/ip dhcp-client
add interface=ether1-external disabled=no
```

Jika static IP (sesuaikan):

```routeros
/ip address
add address=192.168.1.100/24 interface=ether1-external network=192.168.1.0
/ip route
add distance=1 gateway=192.168.1.1
```

### 3.5 DNS

```routeros
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4
```

### 3.6 Verifikasi

```routeros
/ip address print
/interface print
/ip route print
```

> **📋 Dokumentasi:**
> - Screenshot `/interface print` (3 interface dengan nama baru)
> - Screenshot `/ip address print` (IP assignment)
> - Screenshot `/ip route print`
> - **Masuk ke: BAB III §3.2**

---

## 4. Firewall MikroTik

### 4.1 Connection Tracking (TARUH PALING ATAS)

```routeros
/ip firewall filter

# Accept established & related — INPUT
add action=accept chain=input \
    connection-state=established,related \
    comment="01-accept-established-input"

# Accept established & related — FORWARD
add action=accept chain=forward \
    connection-state=established,related \
    comment="02-accept-established-forward"

# Drop invalid — INPUT
add action=drop chain=input \
    connection-state=invalid \
    comment="03-drop-invalid-input"

# Drop invalid — FORWARD
add action=drop chain=forward \
    connection-state=invalid \
    comment="04-drop-invalid-forward"
```

### 4.2 INPUT Chain (Keamanan Router)

```routeros
# Allow ICMP (ping) — untuk troubleshooting
add action=accept chain=input protocol=icmp \
    comment="05-allow-icmp"

# Allow SSH hanya dari LAN
add action=accept chain=input \
    dst-port=22 protocol=tcp \
    src-address=192.168.56.0/24 \
    comment="06-allow-ssh-from-lan"

# Drop SSH dari mana saja selain LAN
add action=drop chain=input \
    dst-port=22 protocol=tcp \
    comment="07-drop-ssh-non-lan"

# Allow DNS (router sebagai DNS server)
add action=accept chain=input dst-port=53 protocol=udp \
    comment="08-allow-dns-udp"
add action=accept chain=input dst-port=53 protocol=tcp \
    comment="09-allow-dns-tcp"

# Allow Winbox & WebFig dari LAN saja
add action=accept chain=input \
    dst-port=8291 protocol=tcp \
    src-address=192.168.56.0/24 \
    comment="10-allow-winbox-lan"
add action=accept chain=input \
    dst-port=80 protocol=tcp \
    src-address=192.168.56.0/24 \
    comment="11-allow-webfig-lan"

# Drop port scan (connection limit)
add action=drop chain=input \
    connection-limit=3,32 protocol=tcp \
    comment="12-drop-port-scan"

# Drop semua INPUT lainnya
add action=drop chain=input \
    comment="13-drop-all-input"
```

### 4.3 FORWARD Chain — External → DMZ

```routeros
# Izinkan HTTP/HTTPS dari external ke Nginx di DMZ
add action=accept chain=forward \
    dst-address=7.7.7.2 dst-port=80,443 protocol=tcp \
    in-interface=ether1-external \
    comment="14-allow-http-https-to-dmz"

# Drop semua traffic lain dari external ke DMZ
add action=drop chain=forward \
    dst-address=7.7.7.0/30 \
    in-interface=ether1-external \
    comment="15-drop-other-external-to-dmz"
```

### 4.4 FORWARD Chain — DMZ → LAN

```routeros
# Izinkan MySQL dari VM DMZ ke DB Server
add action=accept chain=forward \
    dst-address=192.168.56.10 dst-port=3306 protocol=tcp \
    src-address=7.7.7.2 \
    comment="16-allow-mysql-dmz-to-lan"

# Drop semua traffic lain dari DMZ ke LAN
add action=drop chain=forward \
    src-address=7.7.7.0/30 \
    dst-address=192.168.56.0/24 \
    comment="17-drop-other-dmz-to-lan"
```

### 4.5 FORWARD Chain — External → LAN (BLOKIR TOTAL)

```routeros
add action=drop chain=forward \
    dst-address=192.168.56.0/24 \
    in-interface=ether1-external \
    comment="18-drop-external-to-lan"
```

### 4.6 FORWARD Chain — Allow Outbound

```routeros
# LAN → Internet
add action=accept chain=forward \
    in-interface=ether3-lan out-interface=ether1-external \
    comment="19-allow-lan-to-internet"

# DMZ → Internet (untuk apt update, pip install, dll)
add action=accept chain=forward \
    in-interface=ether2-dmz out-interface=ether1-external \
    comment="20-allow-dmz-to-internet"

# Drop semua FORWARD lainnya
add action=drop chain=forward \
    comment="21-drop-all-forward"
```

### 4.7 Verifikasi Firewall

```routeros
/ip firewall filter print
```

Pastikan urutan rule benar:
```
#  Chain    Action    Dst-Port    Src-Address       Comment
0  input    accept    —           —                 01-accept-established-input
1  forward  accept    —           —                 02-accept-established-forward
2  input    drop      —           —                 03-drop-invalid-input
3  forward  drop      —           —                 04-drop-invalid-forward
...
21 forward  drop      —           —                 21-drop-all-forward
```

> **📋 Dokumentasi:**
> - Screenshot `/ip firewall filter print detail` (semua rule terlihat)
> - Penjelasan tiap rule dalam tabel untuk **BAB IV §4.1 — Konfigurasi Keamanan**
> - **WAJIB:** Tulis justifikasi keamanan untuk setiap rule (kenapa rule ini diperlukan)

---

## 5. NAT & Port Forwarding

### 5.1 Masquerade (Outbound NAT)

```routeros
/ip firewall nat
add action=masquerade chain=srcnat \
    out-interface=ether1-external \
    comment="nat-masquerade"
```

### 5.2 DNAT — Forward HTTP ke Nginx

```routeros
# Port 80 → VM DMZ (Nginx)
add action=dst-nat chain=dstnat \
    dst-port=80 in-interface=ether1-external protocol=tcp \
    to-addresses=7.7.7.2 to-ports=80 \
    comment="dnat-http-to-nginx"

# Port 443 → VM DMZ (Nginx)
add action=dst-nat chain=dstnat \
    dst-port=443 in-interface=ether1-external protocol=tcp \
    to-addresses=7.7.7.2 to-ports=443 \
    comment="dnat-https-to-nginx"
```

### 5.3 Verifikasi NAT

```routeros
/ip firewall nat print
```

> **📋 Dokumentasi:**
> - Screenshot `/ip firewall nat print`
> - Penjelasan flow: packet masuk → DNAT → FORWARD → Nginx → proxy_pass → container
> - **Masuk ke: BAB IV §4.1.2 — NAT, Port Forwarding & Connection Tracking**

---

## 6. Buat VM Ubuntu di DMZ

### 6.1 Buat VM

```
Nama        : Ubuntu-DMZ
Type        : Linux
Version     : Ubuntu (64-bit)
RAM         : 2 GB minimum (4 GB disarankan)
Disk        : 20 GB
Network     : Internal Network "dmz-network" (sama dengan ether2 MikroTik)
```

### 6.2 Install Ubuntu Server

1. Mount ISO Ubuntu Server 22.04
2. Boot dan ikuti installer
3. Saat network configuration:
   ```
   Interface : ens33 (atau nama interface yang terdeteksi)
   IPv4      : Manual
   Address   : 7.7.7.2/30
   Gateway   : 7.7.7.1
   DNS       : 7.7.7.1
   ```
4. Install OpenSSH server: **Ya**
5. User: `vdkj` (atau sesuai keinginan)

### 6.3 Konfigurasi Network (Setelah Install)

Edit netplan:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Isi:

```yaml
network:
  version: 2
  ethernets:
    ens33:
      addresses:
        - 7.7.7.2/30
      routes:
        - to: default
          via: 7.7.7.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Terapkan:

```bash
sudo netplan apply
```

### 6.4 Verifikasi Konektivitas

```bash
# Cek IP
ip addr show

# Ping gateway (MikroTik)
ping 7.7.7.1

# Ping internet (jika NAT sudah aktif)
ping 8.8.8.8

# Ping LAN (akan di-drop oleh firewall — ini yang diharapkan)
ping 192.168.56.10
```

> **📋 Dokumentasi:**
> - Screenshot pengaturan VM di hypervisor (Network: Internal "dmz-network")
> - Screenshot `ip addr show`
> - Screenshot `ping 7.7.7.1` (berhasil)
> - Screenshot `ping 8.8.8.8` (berhasil — NAT jalan)
> - **Masuk ke: BAB III §3.3 — Setup VM Ubuntu di DMZ**

---

## 7. Install Docker & Deploy App

### 7.1 Install Docker di VM DMZ

```bash
# Update package
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y ca-certificates curl gnupg

# Tambah Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Tambah Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

# Tambah user ke docker group (agar tidak perlu sudo)
sudo usermod -aG docker $USER

# Apply group baru (atau logout-login)
newgrp docker

# Verifikasi
docker --version
docker compose version
```

### 7.2 Copy File Aplikasi ke VM DMZ

Dari mesin host/laptop, gunakan SCP atau copy manual:

```bash
# Dari laptop/host, copy seluruh folder apps dan config
scp -r apps/ vdkj@7.7.7.2:~/vdkj/
scp -r config/docker/ vdkj@7.7.7.2:~/vdkj/config/
scp config/mysql/init.sql vdkj@7.7.7.2:~/vdkj/config/mysql/
```

Atau clone dari Git:

```bash
ssh vdkj@7.7.7.2
cd ~
git clone https://github.com/<repo-kelompok>.git vdkj
```

### 7.3 Jalankan Docker Compose

```bash
cd ~/vdkj/config/docker

# Edit docker-compose.yml — sesuaikan DB_HOST jika perlu
nano docker-compose.yml

# Build & jalankan
docker compose up -d --build

# Cek status
docker compose ps
docker compose logs
```

### 7.4 Verifikasi Container

```bash
# Cek container berjalan
docker ps

# Cek container bukan root
docker exec app1-flask whoami
# Output: appuser

docker exec app2-php whoami
# Output: appuser

# Test App1 (Flask) dari dalam VM
curl http://localhost:5000

# Test App2 (PHP) dari dalam VM
curl http://localhost:8080
```

> **📋 Dokumentasi:**
> - Screenshot `docker --version` dan `docker compose version`
> - Screenshot `docker compose up -d --build` (sukses)
> - Screenshot `docker ps` (2 container running)
> - Screenshot `docker exec app1-flask whoami` → `appuser` (non-root)
> - Screenshot `curl http://localhost:5000` (HTML response)
> - **Masuk ke: BAB III §3.4 — Deploy Aplikasi Web dalam Docker**

---

## 8. Konfigurasi Nginx Reverse Proxy

### 8.1 Install Nginx

```bash
sudo apt install -y nginx

# Cek status
sudo systemctl status nginx
```

### 8.2 Copy Konfigurasi

```bash
# Copy file config dari repo
sudo cp ~/vdkj/config/nginx/vdkj-apps.conf /etc/nginx/sites-available/

# Buat symlink ke sites-enabled
sudo ln -s /etc/nginx/sites-available/vdkj-apps.conf /etc/nginx/sites-enabled/

# Hapus default site (opsional, agar tidak konflik)
sudo rm /etc/nginx/sites-enabled/default

# Test konfigurasi
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### 8.3 Edit /etc/hosts (untuk testing virtual host)

Di VM DMZ:

```bash
echo "127.0.0.1 app1.vdkj.local app2.vdkj.local" | sudo tee -a /etc/hosts
```

### 8.4 Verifikasi Nginx

```bash
# Test virtual host App1
curl -H "Host: app1.vdkj.local" http://127.0.0.1

# Test virtual host App2
curl -H "Host: app2.vdkj.local" http://127.0.0.1

# Cek security headers
curl -I -H "Host: app1.vdkj.local" http://127.0.0.1

# Output harus ada:
# X-Frame-Options: SAMEORIGIN
# X-Content-Type-Options: nosniff
# Referrer-Policy: strict-origin-when-cross-origin
```

### 8.5 Cek Log

```bash
# Access log
sudo tail -f /var/log/nginx/app1_access.log

# Error log
sudo tail -f /var/log/nginx/app1_error.log
```

> **📋 Dokumentasi:**
> - Screenshot `nginx -t` (syntax is ok)
> - Screenshot `curl -I` menunjukkan security headers
> - Screenshot `tail /var/log/nginx/app1_access.log` (ada request tercatat)
> - Isi file `vdkj-apps.conf` sebagai lampiran
> - **Masuk ke: BAB III §3.5 — Konfigurasi Nginx Reverse Proxy**

---

## 9. Setup Database Server (LAN)

### 9.1 Buat VM Database Server

```
Nama        : Ubuntu-DB
Type        : Linux
RAM         : 1 GB
Disk        : 10 GB
Network     : Internal Network "lan-network" (sama dengan ether3 MikroTik)
```

Saat install Ubuntu:

```
IPv4    : Manual
Address : 192.168.56.10/24
Gateway : 192.168.56.1
DNS     : 192.168.56.1
```

### 9.2 Install MySQL/MariaDB

```bash
sudo apt update
sudo apt install -y mariadb-server

# Secure installation
sudo mysql_secure_installation
# Enter current password: (kosong)
# Set root password? Ya (catat passwordnya!)
# Remove anonymous users? Ya
# Disallow root login remotely? Ya
# Remove test database? Ya
# Reload privilege tables? Ya
```

### 9.3 Konfigurasi bind-address

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Cari baris `bind-address` dan ubah:

```ini
# Ganti dari 127.0.0.1 ke:
bind-address = 0.0.0.0
```

Restart MariaDB:

```bash
sudo systemctl restart mariadb
```

### 9.4 Jalankan Script SQL

```bash
# Copy script SQL dari repo
# (dari VM DMZ atau host, scp ke DB server)
scp ~/vdkj/config/mysql/init.sql vdkj@192.168.56.10:~/

# Di DB Server:
sudo mysql -u root -p < ~/init.sql
```

### 9.5 Verifikasi Database

```bash
# Login ke MySQL
mysql -u root -p

# Di dalam MySQL:
SHOW DATABASES;
USE app1_bukutamu;
SELECT * FROM tamu;

USE app2_produk;
SELECT * FROM produk;

# Cek user
SELECT user, host FROM mysql.user;
EXIT;
```

### 9.6 Konfigurasi Firewall OS (DB Server)

```bash
# Install ufw jika belum ada
sudo apt install -y ufw

# Default: deny incoming
sudo ufw default deny incoming

# Default: allow outgoing
sudo ufw default allow outgoing

# Allow SSH dari LAN
sudo ufw allow from 192.168.56.0/24 to any port 22

# Allow MySQL HANYA dari VM DMZ
sudo ufw allow from 7.7.7.2 to any port 3306

# Aktifkan ufw
sudo ufw enable

# Cek status
sudo ufw status verbose
```

### 9.7 Verifikasi Konektivitas dari DMZ

Dari VM DMZ (7.7.7.2):

```bash
# Test koneksi MySQL
mysql -h 192.168.56.10 -u app1_user -p app1_bukutamu

# Di dalam MySQL:
SELECT * FROM tamu;
EXIT;
```

> **📋 Dokumentasi:**
> - Screenshot VM settings (Network: Internal "lan-network")
> - Screenshot `SHOW DATABASES;` (2 database ada)
> - Screenshot `SELECT * FROM tamu;` (5 data dummy)
> - Screenshot `SELECT * FROM produk;` (5 data dummy)
> - Screenshot `sudo ufw status verbose` (rule 3306 dari 7.7.7.2)
> - Screenshot koneksi MySQL dari VM DMZ (berhasil)
> - Isi file `init.sql` sebagai lampiran
> - **Masuk ke: BAB III §3.6 — Konfigurasi Database Server (LAN)**

---

## 10. Install & Konfigurasi Suricata

### 10.1 Install Suricata

```bash
# Tambah PPA Suricata (opsional, untuk versi terbaru)
sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt update

# Install
sudo apt install -y suricata

# Cek versi
suricata --build-info | head -5
```

### 10.2 Download Rule Set

```bash
# Update Suricata rules
sudo suricata-update

# Cek rules yang tersedia
sudo suricata-update list-sources
```

### 10.3 Copy Konfigurasi Custom

```bash
# Copy suricata.yaml dari repo
sudo cp ~/vdkj/config/suricata/suricata.yaml /etc/suricata/suricata.yaml

# Copy custom rules
sudo cp ~/vdkj/config/suricata/custom-vdkj.rules /var/lib/suricata/rules/
```

### 10.4 Edit suricata.yaml

```bash
sudo nano /etc/suricata/suricata.yaml
```

Pastikan bagian ini benar:

```yaml
# Interface yang dimonitor
af-packet:
  - interface: eth0    # sesuaikan dengan nama interface DMZ
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes

# EVE JSON output aktif
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: /var/log/suricata/eve.json
      types:
        - alert:
            payload: yes
            packet: yes

# Tambahkan custom rules
rule-files:
  - suricata.rules
  - custom-vdkj.rules
```

### 10.5 Cek Nama Interface

```bash
# Cek interface yang tersedia
ip link show

# Pastikan interface di suricata.yaml cocok
# Biasanya: ens33, eth0, atau enp0s3
```

### 10.6 Jalankan Suricata

```bash
# Test konfigurasi
sudo suricata -T -c /etc/suricata/suricata.yaml

# Jalankan Suricata (mode IDS, background)
sudo systemctl enable suricata
sudo systemctl start suricata

# Cek status
sudo systemctl status suricata
```

### 10.7 Verifikasi Suricata

```bash
# Cek log Suricata
sudo tail -f /var/log/suricata/eve.json

# Cek alert (harusnya kosong jika belum ada serangan)
sudo tail -f /var/log/suricata/fast.log
```

### 10.8 Simulasi Serangan (untuk Pengujian)

**Dari mesin lain di network (atau dari VM DMZ sendiri):**

```bash
# Simulasi port scan (dari luar)
nmap -sS 7.7.7.2

# Simulasi SQLi via curl
curl "http://7.7.7.2/?id=1%20OR%201=1"
curl "http://7.7.7.2/?id=1%20UNION%20SELECT%20*%20FROM%20users"

# Cek apakah Suricata mendeteksi
sudo cat /var/log/suricata/fast.log
# Harusnya muncul alert:
# [VDKJ - Possible Port Scan Detected]
# [VDKJ - Possible SQL Injection Detected]
```

> **📋 Dokumentasi:**
> - Screenshot `suricata --build-info`
> - Screenshot `sudo systemctl status suricata` (active/running)
> - Screenshot isi `custom-vdkj.rules` (3 rules terlihat)
> - Screenshot `sudo cat /var/log/suricata/fast.log` setelah simulasi — **PENTING! Ini bukti Suricata mendeteksi serangan**
> - Screenshot isi `eve.json` (alert entries)
> - **Masuk ke: BAB III §3.7 — Konfigurasi Suricata IDS/IPS & BAB IV §4.2**

---

## 11. Pengujian End-to-End

### 11.1 Persiapan Testing

Dari mesin host/laptop (berperan sebagai "External"):

```bash
# Pastikan bisa ping MikroTik external IP
ping <IP-external-MikroTik>
```

Tambahkan di `/etc/hosts` laptop:

```
<IP-external-MikroTik>  app1.vdkj.local
<IP-external-MikroTik>  app2.vdkj.local
```

### 11.2 Konektivitas Dasar

| # | Test | Command (dari External) | Hasil Harap | 📸 |
|---|------|------------------------|-------------|-----|
| 1 | Ping → Router | `ping <IP-external>` | ✅ Berhasil | Ya |
| 2 | Ping DMZ → LAN | `ssh vdkj@7.7.7.2` lalu `ping 192.168.56.10` | ✅ Berhasil | Ya |
| 3 | Ping External → LAN | `ping 192.168.56.10` | ❌ Gagal | Ya |
| 4 | HTTP ke Nginx | `curl http://<IP-external>:80` | ✅ Berhasil | Ya |
| 5 | Direct port container | `curl http://<IP-external>:5000` | ❌ Gagal | Ya |
| 6 | MySQL DMZ → DB | `mysql -h 192.168.56.10 -u app1_user -p` | ✅ Berhasil | Ya |
| 7 | MySQL External → DB | `mysql -h 192.168.56.10 -u app1_user -p` | ❌ Gagal | Ya |

### 11.3 Aplikasi Web

| # | Test | Command | 📸 |
|---|------|---------|-----|
| 1 | App1 via Nginx | Buka browser: `http://<IP-external>` (Host: app1.vdkj.local) | Ya |
| 2 | App2 via Nginx | Buka browser: `http://<IP-external>` (Host: app2.vdkj.local) | Ya |
| 3 | CRUD App1 | Tambah/Edit/Hapus pesan di Buku Tamu | Ya |
| 4 | CRUD App2 | Tambah/Edit/Hapus produk | Ya |
| 5 | Security headers | `curl -I http://<IP-external>` — cek X-Frame-Options, dll | Ya |
| 6 | Nginx access log | `sudo tail /var/log/nginx/app1_access.log` | Ya |

### 11.4 Firewall MikroTik

| # | Test | Command | 📸 |
|---|------|---------|-----|
| 1 | Drop External→LAN | `ping 192.168.56.10` dari external → timeout | Ya |
| 2 | SSH hanya LAN | `ssh admin@<IP-external>` dari external → ditolak | Ya |
| 3 | Port scan detect | `nmap -sS <IP-external>` dari external | Ya |
| 4 | Connection tracking | `/ip firewall connection print` di MikroTik | Ya |
| 5 | Address list block | Tambah IP ke address list, coba akses → ditolak | Ya |

**Tambah IP ke address list (di MikroTik):**
```routeros
/ip firewall address-list
add list=blocked_ips address=<IP-YANG-DIBLOKIR> comment="test-block"

# Buat rule untuk drop (tambahkan sebelum rule accept FORWARD)
/ip firewall filter
add action=drop chain=forward src-address-list=blocked_ips \
    comment="drop-blocked-ips"
```

### 11.5 Suricata

| # | Test | Command | 📸 |
|---|------|---------|-----|
| 1 | Suricata running | `sudo systemctl status suricata` | Ya |
| 2 | Port scan alert | `nmap -sS 7.7.7.2` → cek `/var/log/suricata/fast.log` | Ya |
| 3 | SQLi alert | `curl "http://7.7.7.2/?id=1 OR 1=1"` → cek fast.log | Ya |
| 4 | EVE JSON | `sudo tail /var/log/suricata/eve.json` — ada alert entries | Ya |

### 11.6 Verifikasi dari MikroTik (Bonus)

```routeros
# Cek firewall connection tracking
/ip firewall connection print

# Cek firewall counter (berapa packet match tiap rule)
/ip firewall filter print stats

# Cek traffic di interface
/interface monitor-traffic interface=ether2-dmz
```

> **📋 Dokumentasi:**
> - **SEMUA test di atas WAJIB di-screenshot** — ini masuk **BAB V — Hasil Pengujian**
> - Tiap test tulis: apa yang dilakukan, apa yang terjadi, mengapa (analisis)
> - Untuk test yang "harus gagal", pastikan screenshot menunjukkan error/timeout

---

## 12. Tips Screenshot & Laporan

### 12.1 Screenshot yang Wajib Ada

**BAB II — Desain Arsitektur:**
- [ ] Diagram topologi jaringan (draw.io / hand-drawn / Lucidchart)
- [ ] Tabel skema IP address

**BAB III — Implementasi:**
- [ ] Setting 3 NIC di hypervisor
- [ ] MikroTik: `/interface print`, `/ip address print`
- [ ] Ubuntu DMZ: `ip addr show`, `ping 7.7.7.1`
- [ ] Docker: `docker ps`, `docker compose up`
- [ ] Nginx: `nginx -t`, `curl -I` (security headers)
- [ ] MySQL: `SHOW DATABASES`, `SELECT * FROM tamu`, `SELECT * FROM produk`
- [ ] Suricata: `systemctl status suricata`, `fast.log` setelah simulasi

**BAB IV — Konfigurasi Keamanan:**
- [ ] MikroTik: `/ip firewall filter print detail`
- [ ] MikroTik: `/ip firewall nat print`
- [ ] MikroTik: `/ip firewall address-list print`
- [ ] MySQL: `sudo ufw status verbose`
- [ ] Suricata: isi `custom-vdkj.rules`
- [ ] Nginx: security headers di response

**BAB V — Hasil Pengujian:**
- [ ] Semua tabel pengujian (11.2 – 11.5) terisi dengan screenshot

**Lampiran:**
- [ ] File `.rsc` MikroTik (export: `/export`)
- [ ] File `docker-compose.yml`
- [ ] File `Dockerfile` (kedua app)
- [ ] File `vdkj-apps.conf` (Nginx)
- [ ] File `suricata.yaml`
- [ ] File `custom-vdkj.rules`
- [ ] File `init.sql`
- [ ] Source code app (ringkasan atau attach file)

### 12.2 Format Screenshot

- Beri **nomor** dan **judul** pada setiap screenshot (misal: "Gambar 3.1 — Konfigurasi Interface MikroTik")
- Screenshot harus **terbaca** — zoom in jika perlu
- Gunakan **kotak/border merah** untuk menyorot bagian penting
- Setelah screenshot, tulis **paragraf penjelasan** (apa yang dilakukan dan hasilnya)

### 12.3 Perintah Export MikroTik (untuk Lampiran)

```routeros
/export file=vdkj-mikrotik
```

File akan tersimpan di MikroTik. Download via:
- Winbox: Files → download `vdkj-mikrotik.rsc`
- SCP: `scp admin@<IP-MikroTik>:vdkj-mikrotik.rsc ./`

### 12.4 Perintah Export Suricata Rules (untuk Lampiran)

```bash
# Cek custom rules
cat /var/lib/suricata/rules/custom-vdkj.rules

# Cek active rules count
sudo suricata --list-keywords | wc -l
```

---

## Checklist Akhir Sebelum Kumpul

- [ ] MikroTik: 3 interface aktif, IP terkonfigurasi, firewall lengkap
- [ ] VM DMZ: Docker running (2 container), Nginx reverse proxy aktif
- [ ] DB Server: MySQL running, 2 database + data dummy, firewall OS aktif
- [ ] Suricata: running, custom rules aktif, alert terdeteksi
- [ ] Semua pengujian berhasil sesuai skenario
- [ ] Screenshot lengkap untuk semua BAB
- [ ] Lampiran file konfigurasi lengkap (bukan screenshot)
- [ ] Export MikroTik .rsc sudah didownload
- [ ] Laporan dalam format PDF
- [ ] Slide presentasi siap
- [ ] Video demo direkam (20-30 menit)
- [ ] Tidak ada credential/secret yang terekspos di file yang dikumpulkan
