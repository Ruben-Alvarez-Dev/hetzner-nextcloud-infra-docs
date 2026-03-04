# Server Technical Specifications

> Detailed hardware and software specifications of the Hetzner Cloud server

---

## 🖥️ Hardware Specifications

### Physical Server

| Component | Specification | Notes |
|-----------|---------------|-------|
| **Provider** | Hetzner Cloud | German cloud provider |
| **Server Type** | CX22 | Entry-level cloud server |
| **CPU** | Intel Xeon Processor (Skylake, IBRS) | 2 vCPUs |
| **Architecture** | x86_64 | 64-bit |
| **RAM** | 4 GB DDR4 | 3.7 GB usable |
| **Storage** | 40 GB SSD NVMe | 38 GB available |
| **Network** | 1 Gbps | Unmetered traffic |
| **Location** | Falkenstein, Germany | Data center DC Falkenstein 1 |

### Network Configuration

| Interface | IP Address | Type | Purpose |
|-----------|------------|------|---------|
| **eth0 (Public)** | 46.224.204.126 | IPv4 | Public internet access |
| **eth0 (Public)** | 2a01:4f8:1c19:1cb3::1 | IPv6 | Public IPv6 |
| **tailscale0** | 100.77.1.30 | IPv4 | VPN private network |
| **tailscale0** | fd7a:115c:a1e0::2 | IPv6 | VPN IPv6 |

### Storage Layout

```
Filesystem                    Size  Used Avail Use% Mounted on
/dev/sda1                     38G   7.0G  29G  20% /          (System)
/dev/sda15                   253M   6.2M 246M   3% /boot/efi  (Boot)
//u556648-sub3.../sub3       5.0T   1.1G 5.0T   1% /mnt/storage-manuel
//u556648-sub4.../sub4       5.0T   1.1G 5.0T   1% /mnt/storage-ruben
```

---

## 🐧 Operating System

### Base System

| Component | Version | Status |
|-----------|---------|--------|
| **Distribution** | Ubuntu | 24.04.4 LTS (Noble Numbat) |
| **Kernel** | 6.8.0-101-generic | PREEMPT_DYNAMIC |
| **Architecture** | x86_64 | 64-bit |
| **Init System** | systemd | v255.4-1ubuntu8 |

### System Resources

| Metric | Value | Status |
|--------|-------|--------|
| **Uptime** | 10+ hours | ✅ Stable |
| **Load Average** | 0.04, 0.07, 0.11 | ✅ Low |
| **Processes** | 169 | ✅ Normal |
| **Users Logged In** | 4 | ✅ Active |

---

## 🌐 Network Services

### Public Services (Internet-facing)

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| **SSH** | 22 | TCP | Secure remote access |
| **HTTP** | 80 | TCP | Redirect to HTTPS |
| **HTTPS** | 443 | TCP | Secure web traffic |
| **SMTP** | 25 | TCP | Email sending |

### Internal Services (Localhost)

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| **Apache** | 8080 | HTTP | Nextcloud application server |
| **Authelia** | 9091 | HTTP | SSO/MFA authentication |
| **Grafana** | 3000 | HTTP | Monitoring dashboards |
| **Vault** | 8200 | HTTP | Secrets management |
| **MySQL** | 3306 | TCP | Database server |
| **Redis** | 6379 | TCP | Cache server |
| **LDAP** | 389 | TCP | Directory service (if configured) |

### Tailscale VPN Network

| Node | IP | Hostname | Status |
|------|----|----|--------|
| **Server** | 100.77.1.30 | vpn-ruben-nextcloud-hetzner | ✅ Online |
| **Client 1** | 100.77.1.10 | vpn-ruben-mini | ✅ Online |
| **Client 2** | 100.77.1.21 | vpn-ruben-pixel | ⚪ Offline |
| **Client 3** | 100.77.1.22 | vpn-ruben-samsungs9fe | ⚪ Offline |
| **Client 4** | 100.77.1.23 | vpn-ruben-xiaomipad5 | ⚪ Offline |

---

## 🔐 SSL/TLS Certificates

### Let's Encrypt Certificates

| Domain | Issuer | Status | Auto-renewal |
|--------|--------|--------|--------------|
| nextcloud.alvarezconsult.es | Let's Encrypt | ✅ Valid | ✅ Enabled |
| nextcloud-authelia.alvarezconsult.es | Let's Encrypt | ✅ Valid | ✅ Enabled |
| nextcloud-grafana.alvarezconsult.es | Let's Encrypt | ✅ Valid | ✅ Enabled |
| nextcloud-vault.alvarezconsult.es | Let's Encrypt | 🔄 Pending | ✅ Enabled |

### Certificate Management

- **Provider**: Let's Encrypt (ACME v2)
- **Challenge Type**: HTTP-01
- **Renewal**: Automatic via Caddy
- **Storage**: `/var/lib/caddy/.local/share/caddy/certificates/`

---

## 📦 Installed Packages

### Web Stack

```
apache2                        2.4.58-1ubuntu8.10
php8.3                        8.3.6-0ubuntu0.24.04.6
php8.3-fpm                    8.3.6-0ubuntu0.24.04.6
libapache2-mod-php8.3         8.3.6-0ubuntu0.24.04.6
mysql-server-8.0              8.0.45-0ubuntu0.24.04.1
redis-server                  5:6.0.16-1ubuntu1
```

### Security Stack

```
fail2ban                      1.0.2-3ubuntu0.1
authelia                      4.38.17 (latest)
vault                         1.18.2 (latest)
tailscale                     1.72.0 (latest)
```

### Infrastructure Stack

```
docker.io                     28.2.2-0ubuntu1~24.04.1
docker-compose                1.29.2-6ubuntu1
caddy                         2.11.1
grafana                       11.4.0
postfix                       3.8.6-1build1
```

### PHP Extensions

```
php8.3-bcmath                 Mathematical operations
php8.3-curl                   HTTP client
php8.3-gd                     Image processing
php8.3-gmp                    Arbitrary precision math
php8.3-imagick                Advanced image processing
php8.3-intl                   Internationalization
php8.3-mbstring               Multibyte string support
php8.3-mysql                  MySQL driver
php8.3-xml                    XML processing
php8.3-zip                    ZIP compression
```

---

## 📊 Resource Utilization

### Current Usage (as of 2026-03-04)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| **CPU** | ~2% | 100% | ✅ Low |
| **Memory** | 1.3 GB | 3.7 GB | ✅ 35% |
| **Disk (System)** | 7.0 GB | 29 GB | ✅ 20% |
| **Disk (Storage 1)** | 1.1 GB | 5.0 TB | ✅ <1% |
| **Disk (Storage 2)** | 1.1 GB | 5.0 TB | ✅ <1% |

### Performance Metrics

```
System load (1m):   0.04  ✅
System load (5m):   0.07  ✅
System load (15m):  0.11  ✅
Memory pressure:    Low   ✅
I/O wait:           <1%   ✅
```

---

## 🔄 Backup & Storage

### Hetzner Storage Boxes

| Storage Box | ID | Mount Point | Size | Used | Purpose |
|-------------|----|-------------| -----|------|---------|
| **Manuel** | u556648-sub3 | /mnt/storage-manuel | 5.0 TB | 1.1 GB | Personal backup |
| **Ruben** | u556648-sub4 | /mnt/storage-ruben | 5.0 TB | 1.1 GB | Personal backup |

### Backup Configuration

- **Protocol**: SMB/CIFS
- **Mount**: Auto-mount via `/etc/fstab`
- **Encryption**: In transit (SMB3)
- **Location**: Germany (Hetzner data center)

---

## 🔧 System Configuration Files

### Key Configuration Locations

```
/etc/caddy/Caddyfile                           # Reverse proxy config
/etc/apache2/sites-enabled/nextcloud.conf      # Apache vhost
/etc/authelia/configuration.yml               # Authelia SSO config
/etc/vault.d/config.hcl                       # Vault server config
/etc/grafana/grafana.ini                       # Grafana config
/etc/mysql/mysql.conf.d/                       # MySQL config
/etc/redis/redis.conf                          # Redis config
/etc/fail2ban/jail.d/                          # Fail2ban jails
/var/www/html/config/config.php               # Nextcloud config
/etc/letsencrypt/                             # SSL certificates
/etc/tailscale/                               # Tailscale config
```

---

## 📝 Systemd Services

### Active Services

| Service | Status | Autostart | Description |
|---------|--------|-----------|-------------|
| caddy.service | ✅ running | ✅ enabled | Reverse proxy (HTTPS) |
| apache2.service | ✅ running | ⚪ disabled | Web server (Nextcloud) |
| mysql.service | ✅ running | ✅ enabled | Database server |
| redis-server.service | ✅ running | ✅ enabled | Cache server |
| authelia.service | ✅ running | ✅ enabled | SSO/MFA server |
| grafana-server.service | ✅ running | ✅ enabled | Monitoring dashboard |
| vault.service | ⚪ inactive | ✅ enabled | Secrets management |
| docker.service | ✅ running | ✅ enabled | Container runtime |
| tailscaled.service | ✅ running | ✅ enabled | VPN agent |
| postfix@-.service | ✅ running | ✅ enabled | Mail server |
| fail2ban.service | ✅ running | ✅ enabled | Intrusion prevention |

---

## 🎯 Nextcloud Configuration

### Version & Installation

| Component | Value |
|-----------|-------|
| **Version** | 30.0.5 |
| **Installation Method** | Traditional (non-Docker) |
| **Location** | /var/www/html/ |
| **Web Server** | Apache 2.4 (port 8080) |
| **PHP Version** | 8.3.6 |
| **Database** | MySQL 8.0.45 |
| **Cache** | Redis 6.0.16 |

### Nextcloud Apps (Security-related)

| App | Status | Purpose |
|-----|--------|---------|
| Brute-force Settings | ✅ Enabled | Rate limiting login attempts |
| Suspicious Login | ✅ Enabled | ML-based login anomaly detection |
| Two-Factor TOTP | ✅ Enabled | Time-based OTP authentication |
| Two-Factor Backup Codes | ✅ Enabled | Recovery codes for 2FA |
| Two-Factor Notifications | ✅ Enabled | Push notifications for 2FA |

---

## 📈 Monitoring & Logging

### Log Locations

```
/var/log/apache2/nextcloud-access.log    # Nextcloud access logs
/var/log/apache2/nextcloud-error.log     # Nextcloud error logs
/var/log/authelia/authelia.log           # Authelia authentication logs
/var/log/grafana/grafana.log              # Grafana logs
/var/log/mysql/error.log                  # MySQL error logs
/var/log/fail2ban.log                     # Fail2ban logs
/var/log/syslog                           # System logs
```

### Monitoring Stack

- **Grafana**: Dashboard visualization (https://nextcloud-grafana.alvarezconsult.es)
- **Prometheus**: Metrics collection (if configured)
- **Loki**: Log aggregation (if configured)

---

## 🔒 Security Hardening

### Implemented Measures

| Category | Implementation | Status |
|----------|----------------|--------|
| **Firewall** | iptables + Fail2ban | ✅ Active |
| **IDS/IPS** | Fail2ban | ✅ Active |
| **Authentication** | Authelia (SSO/MFA) | ✅ Active |
| **Secrets Management** | HashiCorp Vault | ✅ Installed |
| **SSL/TLS** | Let's Encrypt (auto-renewal) | ✅ Active |
| **VPN** | Tailscale Mesh VPN | ✅ Active |
| **SSH** | Key-based + password fallback | ✅ Active |

### Fail2ban Configuration

```ini
[sshd]
enabled = true
banaction = iptables-multiport
backend = auto
```

---

## 🌍 DNS Configuration

### Domain Records

| Subdomain | IP | Purpose |
|-----------|----|----|
| nextcloud.alvarezconsult.es | 46.224.204.126 | Main Nextcloud instance |
| nextcloud-authelia.alvarezconsult.es | 46.224.204.126 | Authentication portal |
| nextcloud-grafana.alvarezconsult.es | 46.224.204.126 | Monitoring dashboards |
| nextcloud-vault.alvarezconsult.es | 46.224.204.126 | Secrets management |

---

## 📚 References

- [Hetzner Cloud Documentation](https://docs.hetzner.com/)
- [Nextcloud Administration Manual](https://docs.nextcloud.com/)
- [Authelia Documentation](https://www.authelia.com/)
- [Caddy Server Docs](https://caddyserver.com/docs/)
- [HashiCorp Vault Docs](https://www.vaultproject.io/docs)
- [Tailscale Knowledge Base](https://tailscale.com/kb/)

---

**Last Updated**: 2026-03-04
**Maintainer**: Ruben Alvarez
**Review Frequency**: Monthly
