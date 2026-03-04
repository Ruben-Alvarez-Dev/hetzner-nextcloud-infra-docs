#!/bin/bash
#=============================================================================
# Script: Base Infrastructure Installation
# Description: Installs core components (Caddy, Apache, MySQL, Redis)
# Author: Ruben Alvarez
# License: MIT
#=============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DOMAIN="${DOMAIN:-nextcloud.alvarezconsult.es}"
DB_NAME="${DB_NAME:-nextcloud}"
DB_USER="${DB_USER:-nextcloud}"
DB_PASS="${DB_PASS:-$(openssl rand -base64 32)}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"

# Print colored message
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# Update system
update_system() {
    log_info "Updating system packages..."
    apt-get update -y
    apt-get upgrade -y
    apt-get autoremove -y
    apt-get clean
    apt-get autoclean
    log_success "System updated"
}

# Install dependencies
install_dependencies() {
    log_info "Installing required packages..."
    
    apt-get install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
    
    log_success "Dependencies installed"
}

# Install Caddy
install_caddy() {
    log_info "Installing Caddy web server..."
    
    # Add Caddy repository
    apt-get install -y debian-keyring bzip2
    
    curl -1 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt-get update
    apt-get install -y caddy
    
    log_success "Caddy installed"
}

# Install Apache and PHP
install_apache_php() {
    log_info "Installing Apache and PHP..."
    
    apt-get install -y \
        apache2 \
        libapache2-mod-php8.3 \
        php8.3-fpm \
        php8.3-mysql \
        php8.3-xml \
        php8.3-mbstring \
        php8.3-curl \
        php8.3-zip \
        php8.3-intl \
        php8.3-gd \
        php8.3-bcmath \
        php8.3-imagick \
        php8.3-redis \
        php8.3-apcu \
        php8.3-opcache
    
    # Enable required PHP modules
    phpenmod mysqlnd mysqli pdo_mysql
    phpenmod opcache redis apcu
    
    # Enable Apache modules
    a2enmod rewrite headers env dir mime unique_id
    a2enmod ssl http2
    a2enmod proxy proxy_fcgi proxy_http
    
    log_success "Apache and PHP installed"
}

# Install MySQL
install_mysql() {
    log_info "Installing MySQL database..."
    
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y mysql-server
    
    # Secure MySQL installation
    mysql_secure_installation
    
    log_success "MySQL installed"
}

# Install Redis
install_redis() {
    log_info "Installing Redis cache..."
    
    apt-get install -y redis-server
    
    # Configure Redis
    sed -i 's/^# maxmemory.*/maxmemory 256mb/' /etc/redis/redis.conf
    sed -i 's/^# maxmemory-policy.*/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf
    
    systemctl restart redis-server
    
    log_success "Redis installed"
}

# Install Fail2ban
install_fail2ban() {
    log_info "Installing Fail2ban intrusion prevention..."
    
    apt-get install -y fail2ban
    
    # Create custom jail configuration
    cat > /etc/fail2ban/jail.d/nextcloud.local << 'EOF'
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600

[nextcloud]
enabled = true
port = http,https
filter = nextcloud
logpath = /var/log/nextcloud.log
maxretry = 5
bantime = 3600
findtime = 600
EOF
    
    systemctl enable fail2ban
    systemctl start fail2ban
    
    log_success "Fail2ban installed"
}

# Configure firewall
configure_firewall() {
    log_info "Configuring firewall..."
    
    # Allow essential ports
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    
    # Enable firewall
    ufw --force enable
    
    log_success "Firewall configured"
}

# Create necessary directories
create_directories() {
    log_info "Creating directory structure..."
    
    mkdir -p /var/www/nextcloud
    mkdir -p /var/log/nextcloud
    mkdir -p /etc/caddy
    mkdir -p /etc/authelia
    mkdir -p /opt/vault
    
    log_success "Directories created"
}

# Main execution
main() {
    echo "=========================================="
    echo "  Hetzner Nextcloud - Base Installation"
    echo "=========================================="
    echo ""
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    update_system
    install_dependencies
    install_caddy
    install_apache_php
    install_mysql
    install_redis
    install_fail2ban
    configure_firewall
    create_directories
    
    echo ""
    echo "=========================================="
    echo "  Base installation completed!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Configure MySQL: mysql_secure_installation"
    echo "  2. Create database: ./03-configure-database.sh"
    echo "  3. Install Nextcloud: ./04-install-nextcloud.sh"
}

main "$@"
