# ============================================================
# MikroTik CHR — Konfigurasi VDKJ Tugas Final
# Export dari: /export compact
# Sesuaikan IP ether1 (WAN) sesuai environment hypervisor
# ============================================================

# --- Interface ---
/interface ethernet
set [ find default-name=ether1 ] name=ether1-wan
set [ find default-name=ether2 ] name=ether2-dmz
set [ find default-name=ether3 ] name=ether3-lan

/interface list
add name=WAN
add name=LAN
add name=DMZ

/interface list member
add interface=ether1-wan list=WAN
add interface=ether2-dmz list=DMZ
add interface=ether3-lan list=LAN

# --- IP Address ---
# Sesuaikan ether1 sesuai environment (DHCP atau static)
/ip address
add address=7.7.7.1/30 interface=ether2-dmz network=7.7.7.0
add address=192.168.56.1/24 interface=ether3-lan network=192.168.56.0

# --- DHCP Client (WAN) ---
/ip dhcp-client
add interface=ether1-wan disabled=no

# --- DNS ---
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4

# --- Routing ---
/ip route
add distance=1 gateway=ether1-wan

# ============================================================
# FIREWALL — Filter Rules
# ============================================================

# --- Connection Tracking ---
/ip firewall filter

# Accept established & related connections
add action=accept chain=input connection-state=established,related comment="Accept established/related INPUT"
add action=accept chain=forward connection-state=established,related comment="Accept established/related FORWARD"

# Drop invalid connections
add action=drop chain=input connection-state=invalid comment="Drop invalid INPUT"
add action=drop chain=forward connection-state=invalid comment="Drop invalid FORWARD"

# --- INPUT Chain ---

# Allow ICMP (ping)
add action=accept chain=input protocol=icmp comment="Allow ICMP INPUT"

# Allow SSH hanya dari LAN
add action=accept chain=input dst-port=22 protocol=tcp src-address=192.168.56.0/24 comment="Allow SSH from LAN only"
add action=drop chain=input dst-port=22 protocol=tcp comment="Drop SSH from non-LAN"

# Allow DNS (untuk router sendiri)
add action=accept chain=input dst-port=53 protocol=udp comment="Allow DNS UDP"
add action=accept chain=input dst-port=53 protocol=tcp comment="Allow DNS TCP"

# Allow Winbox/WebFig dari LAN
add action=accept chain=input dst-port=8291 protocol=tcp src-address=192.168.56.0/24 comment="Allow Winbox from LAN"
add action=accept chain=input dst-port=80 protocol=tcp src-address=192.168.56.0/24 comment="Allow WebFig from LAN"

# Drop port scan (connection-limit)
add action=drop chain=input connection-limit=3,32 protocol=tcp comment="Drop port scan connection-limit"

# Drop semua INPUT lainnya
add action=drop chain=input comment="Drop all other INPUT"

# --- FORWARD Chain ---

# External → DMZ: hanya port 80 dan 443 ke Nginx
add action=accept chain=forward dst-address=7.7.7.2 dst-port=80,443 protocol=tcp src-address-list=!blocked_ips comment="Allow HTTP/HTTPS External to DMZ"
add action=drop chain=forward dst-address=7.7.7.0/30 src-address=0.0.0.0/0 comment="Drop all other External to DMZ"

# DMZ → LAN: hanya port 3306 (MySQL) dari VM DMZ ke DB Server
add action=accept chain=forward dst-address=192.168.56.10 dst-port=3306 protocol=tcp src-address=7.7.7.2 comment="Allow MySQL from DMZ to LAN DB"
add action=drop chain=forward src-address=7.7.7.0/30 dst-address=192.168.56.0/24 comment="Drop all other DMZ to LAN"

# External → LAN: drop semua
add action=drop chain=forward dst-address=192.168.56.0/24 in-interface=ether1-wan comment="Drop all External to LAN"

# LAN → Internet: izinkan (via masquerade)
add action=accept chain=forward in-interface=ether3-lan out-interface=ether1-wan comment="Allow LAN to Internet"

# DMZ → Internet: izinkan (untuk update package)
add action=accept chain=forward in-interface=ether2-dmz out-interface=ether1-wan comment="Allow DMZ to Internet for updates"

# Drop semua FORWARD lainnya
add action=drop chain=forward comment="Drop all other FORWARD"

# ============================================================
# NAT
# ============================================================

/ip firewall nat

# Masquerade untuk outbound traffic
add action=masquerade chain=srcnat out-interface=ether1-wan comment="Masquerade WAN"

# DNAT port forwarding: External:80 → DMZ Nginx:80
add action=dst-nat chain=dstnat dst-port=80 in-interface=ether1-wan protocol=tcp to-addresses=7.7.7.2 to-ports=80 comment="DNAT HTTP to Nginx"

# DNAT port forwarding: External:443 → DMZ Nginx:443
add action=dst-nat chain=dstnat dst-port=443 in-interface=ether1-wan protocol=tcp to-addresses=7.7.7.2 to-ports=443 comment="DNAT HTTPS to Nginx"

# ============================================================
# Address List (blokir IP mencurigakan)
# ============================================================

/ip firewall address-list
# Tambahkan IP yang diblokir secara manual atau via script
# Contoh:
# add list=blocked_ips address=103.152.220.1 comment="Known malicious IP"

# ============================================================
# Services — matikan yang tidak perlu
# ============================================================

/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set www port=80
set ssh port=22
set winbox port=8291
