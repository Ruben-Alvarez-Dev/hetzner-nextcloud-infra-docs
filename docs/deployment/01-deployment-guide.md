# Deployment Guide

> Step-by-step deployment and replication instructions

---

## 🚀 Pre-Deployment Checklist

Before deploying any changes to production, verify:

- [ ] All services tested in staging environment
- [ ] SSL certificates valid and not expired
- [ ] Database backups completed
- [ ] Configuration files reviewed
- [ ] Security headers configured
- [ ] Firewall rules tested
- [ ] Fail2ban jails active
- [ ] Authelia MFA working
- [ ] Monitoring dashboards accessible
- [ ] Log rotation configured

---

## 📦 Initial Server Setup

### 1. Operating System Installation

```bash
# Download Ubuntu 24.04 LTS
# https://hetzner.com/cloud

# Boot from ISO
# Follow Hetzner's installation wizard

# Create user 'manuel' with sudo privileges
adduser manuel
usermod -aG sudo manuel
```

### 2. System Updates

```bash
# Update system packages
apt update && apt upgrade -y

# Install essential tools
apt install -y \
  curl \
  wget \
  git \
  vim \
  htop \
  iotop \
  net-tools \
  dnsutils \
  tree
```

### 3. Timezone Configuration

```bash
# Set timezone to UTC (recommended for servers)
timedatectl set-timezone UTC
```

---

## 🐧 Network Configuration

### 1. Hostname Setup

```bash
# Set permanent hostname
hostnamectl set-hostname vpn-ruben-nextcloud-hetzner

# Verify
hostname
```

### 2. DNS Configuration

```bash
# Configure DNS resolvers
cat > /etc/systemd/resolved.conf << EOF
[Resolve]
DNS=1.1.1.1 8.8.8.8
Domains=~alvarezconsult.es
EOF

# Restart systemd-resolved
systemctl restart systemd-resolved
```

### 3. Firewall (UFW)

```bash
# Install UFW
apt install -y ufw

# Configure default policies
ufw default deny incoming
ufw default allow outgoing

# Allow essential services
ufw allow ssh
ufw allow http
ufw allow https

# Enable firewall (be careful with SSH!)
ufw enable

# Check status
ufw status verbose
```

---

## 🔐 SSL/TLS Setup

### 1. Let's Encrypt with Caddy

Caddy automatically manages Let's Encrypt certificates. No manual configuration needed.

```bash
# Verify Caddy is running
systemctl status caddy

# Check certificate status
caddy list-certificates
```

### 2. Manual Certificate Management (if needed)

```bash
# Install certbot
apt install -y certbot

# Obtain certificate
certbot certonly --standalone -d nextcloud.alvarezconsult.es

# Renewal dry-run
certbot renew --dry-run
```

---

## 🗄️ VPN Setup (Tailscale)

### 1. Installation

```bash
# Add Tailscale repository
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /usr/share/keyrings/tailscale-keyring.list

# Install Tailscale
apt update
apt install -y tailscale

# Enable and start
systemctl enable --now tailscaled
```

### 2. Authentication

```bash
# Connect to Tailscale network
tailscale up

# Verify connection
tailscale status
```

### 3. ACL Configuration (optional)

```bash
# Configure ACL for access control
tailscale acl

# Example: Allow only specific users
# tailscale acl --allow ruben@alvarezconsult.es
```

---

## 🗄️ Database Setup

### 1. MySQL Installation

```bash
# Install MySQL Server
apt install -y mysql-server

# Run security script
mysql_secure_installation

# Create Nextcloud database
mysql -u root -p
```

```sql
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

### 2. MySQL Hardening

```bash
# Edit configuration
vim /etc/mysql/mysql.conf.d/mysqld.cnf

# Add/modify these lines:
[mysqld]
bind-address = 127.0.0.1
max_connections = 100
innodb_buffer_pool_size = 1G
```

### 3. Redis Installation

```bash
# Install Redis
apt install -y redis-server

# Configure for Nextcloud
vim /etc/redis/redis.conf

# Set these values:
maxmemory-policy allkeys-lru
maxmemory-samples 5
save 60 1
```

---

## 🌐 Web Server Setup

### 1. Apache Installation

```bash
# Install Apache
apt install -y apache2

# Install PHP modules
apt install -y \
  libapache2-mod-php8.3 \
  php8.3-fpm \
  php8.3-mysql \
  php8.3-curl \
  php8.3-gd \
  php8.3-mbstring \
  php8.3-xml \
  php8.3-zip \
  php8.3-intl \
  php8.3-bcmath \
  php8.3-gmp \
  php8.3-imagick

# Enable required modules
a2enmod rewrite headers env
a2dismod mpm_event mpm_worker
a2enmod mpm_event

# Configure Apache to listen on port 8080
vim /etc/apache2/ports.conf
# Change "Listen 80" to "Listen 8080"
```

### 2. PHP Configuration

```bash
# Edit PHP configuration
vim /etc/php/8.3/fpm/php.ini

# Recommended settings:
memory_limit = 512M
upload_max_filesize = 10G
post_max_size = 10G
max_execution_time = 300
max_input_vars = 3000
opcache.enable = 1
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
```

---

## ☁️ Nextcloud Installation

### 1. Download and Install

```bash
# Download Nextcloud
cd /tmp
wget https://download.nextcloud.com/server/releases/latest-30.tar.bz2

# Extract
tar -xjf latest-30.tar.bz2

# Move to web directory
mv nextcloud /var/www/html/

# Set permissions
chown -R www-data:www-data /var/www/html/nextcloud
chmod -R 755 /var/www/html/nextcloud
```

### 2. Apache Virtual Host

```bash
# Create Apache configuration
cat > /etc/apache2/sites-available/nextcloud.conf << 'EOF'
<VirtualHost *:8080>
    ServerName nextcloud.alvarezconsult.es
    
    DocumentRoot /var/www/html/nextcloud
    
    <Directory /var/www/html/nextcloud/>
        Options FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
        
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>
    
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Host "nextcloud.alvarezconsult.es"
    
    ErrorLog ${APACHE_LOG_DIR}/nextcloud-error.log
    CustomLog ${APACHE_LOG_DIR}/nextcloud-access.log combined
</VirtualHost>
EOF

# Enable site
a2ensite nextcloud

# Disable default site
a2dissite 000-default

# Restart Apache
systemctl restart apache2
```

### 3. Nextcloud Configuration

```bash
# Run installer via CLI
cd /var/www/html/nextcloud
sudo -u www-data php occ installation:install \
  --database "mysql" \
  --database-name "nextcloud" \
  --database-user "nextcloud" \
  --database-pass "STRONG_PASSWORD_HERE" \
  --admin-user "admin" \
  --admin-pass "ADMIN_PASSWORD_HERE"
```

---

## 🔒 Security Setup

### 1. Fail2ban Installation

```bash
# Install Fail2ban
apt install -y fail2ban

# Create local configuration
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
banaction = iptables-multiport

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nextcloud]
enabled = true
port = http,https
filter = nextcloud
logpath = /var/www/html/nextcloud/data/nextcloud.log
maxretry = 5
findtime = 600
bantime = 3600

[authelia]
enabled = true
port = http,https
filter = authelia
logpath = /var/log/authelia/authelia.log
maxretry = 3
EOF

# Create Nextcloud filter
cat > /etc/fail2ban/filter.d/nextcloud.conf << 'EOF'
[Definition]
failregex = ^.*Login failed: .*Remote IP:.*<HOST>.*$
            ^.*Login failed: .*User:.*Remote IP:.*<HOST>.*$
ignoreregex =
EOF

# Restart Fail2ban
systemctl restart fail2ban
```

### 2. Authelia Installation

```bash
# Download Authelia
wget https://github.com/authelia/authelia/releases/download/v4.38.17/authelia-linux-am64.tar.gz

# Extract
tar -xzf authelia-linux-am64.tar.gz
mv authelia-linux-am64 /usr/local/bin/authelia
chmod +x /usr/local/bin/authelia

# Create configuration directory
mkdir -p /etc/authelia
mkdir -p /var/lib/authelia

# Generate secrets
docker run --rm authelia/authelia:latest authelia crypto rand --charset alphanumeric --length 128 > /etc/authelia/jwt.secret
docker run --rm authelia/authelia:latest authelia crypto rand --charset alphanumeric --length 128 > /etc/authelia/storage.encryption.key

# Create configuration (see security documentation)
vim /etc/authelia/configuration.yml

# Create systemd service
cat > /etc/systemd/system/authelia.service << 'EOF'
[Unit]
Description=Authelia Authentication Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/authelia --config /etc/authelia/configuration.yml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
systemctl enable --now authelia
```

---

## 🚦 Caddy Setup

### 1. Installation

```bash
# Install Caddy
apt install -y debian-keyring
mkdir -p /etc/apt/keyrings
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /etc/apt/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install -y caddy
```

### 2. Configuration

```bash
# Create Caddyfile
cat > /etc/caddy/Caddyfile << 'EOF'
# Nextcloud
nextcloud.alvarezconsult.es {
    reverse_proxy localhost:8080
    
    forward_auth localhost:9091 {
        uri /api/verify?rd=https://nextcloud-authelia.alvarezconsult.es/
    }
}

# Authelia
nextcloud-authelia.alvarezconsult.es {
    reverse_proxy localhost:9091
}
EOF

# Set permissions
chown caddy:caddy /etc/caddy/Caddyfile
chmod 644 /etc/caddy/Caddyfile

# Enable and start
systemctl enable --now caddy
```

---

## 📊 Monitoring Setup

### 1. Grafana Installation

```bash
# Add Grafana repository
apt install -y apt-transport-https
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key

echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

apt update
apt install -y grafana

# Enable and start
systemctl enable --now grafana-server
```

### 2. Configure Dashboards

Access Grafana at `https://nextcloud-grafana.alvarezconsult.es` and:
1. Configure data sources (Prometheus, InfluxDB, etc.)
2. Import monitoring dashboards
3. Set up alerting rules

---

## 🔄 Post-Deployment Verification

### 1. Service Health Checks

```bash
# Check all services
systemctl status caddy apache2 mysql redis-server authelia grafana-server

# Check ports
ss -tlnp | grep -E ':(80|443|8080|9091|3000|3306|6379)'

# Check logs
journalctl -u caddy -u apache2 -u mysql -u authelia --since "10 minutes ago"
```

### 2. Functional Tests

```bash
# Test Nextcloud
curl -I https://nextcloud.alvarezconsult.es

# Test Authelia
curl -I https://nextcloud-authelia.alvarezconsult.es

# Test Grafana
curl -I https://nextcloud-grafana.alvarezconsult.es

# Test database
mysql -u nextcloud -p -e "SELECT 1;"

# Test Redis
redis-cli ping
```

### 3. Security Verification

```bash
# Check SSL
openssl s_client -connect nextcloud.alvarezconsult.es:443 -servername nextcloud.alvarezconsult.es

# Check Fail2ban
fail2ban-client status

# Check firewall
ufw status numbered

# Check security headers
curl -I https://nextcloud.alvarezconsult.es | grep -E 'X-Frame-Options|X-Content-Type|Strict-Transport-Security'
```

---

## 🔧 Troubleshooting

### Common Issues

#### Issue: Too Many Redirects

**Symptom**: `ERR_TOO_MANY_REDIRECTS`

**Solution**:
```bash
# Check Caddy configuration
cat /etc/caddy/Caddyfile

# Verify Apache is on correct port
cat /etc/apache2/ports.conf | grep Listen

# Ensure Apache is on 8080, not 80
sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
systemctl restart apache2
systemctl restart caddy
```

#### Issue: Certificate Errors

**Symptom**: `permission denied` for SSL certificates

**Solution**:
```bash
# Fix permissions
chown -R caddy:caddy /etc/letsencrypt/
chmod -R 755 /etc/letsencrypt/
systemctl restart caddy
```

#### Issue: Authelia Not Working

**Symptom**: 500 error on Authelia

**Solution**:
```bash
# Check logs
journalctl -u authelia -n 50

# Verify configuration
authelia validate-config /etc/authelia/configuration.yml

# Restart service
systemctl restart authelia
```

---

## 📝 Maintenance Tasks

### Daily

- Check system logs: `journalctl -p err`
- Verify backup completion
- Monitor disk space: `df -h`

### Weekly

- Update packages: `apt update && apt list --upgradable`
- Review Fail2ban logs: `fail2ban-client status`
- Check SSL expiration: `certbot certificates`

### Monthly

- Full system update: `apt update && apt upgrade -y`
- Review security logs
- Test backup restoration
- Update documentation

---

## 📚 Additional Resources

- [Nextcloud Administration Manual](https://docs.nextcloud.com/server/latest/admin_manual/)
- [Authelia Documentation](https://www.authelia.com/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Fail2ban Wiki](https://github.com/fail2ban/fail2ban/wiki)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

---

**Last Updated**: 2026-03-04
**Maintainer**: Ruben Alvarez
