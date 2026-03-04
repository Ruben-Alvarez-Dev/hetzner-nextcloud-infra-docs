#!/bin/bash
#=============================================================================
# Script: System Health Check
# Description: Monitors all services and sends alerts if issues detected
# Author: Ruben Alvarez
# License: MIT
#=============================================================================

set -e

# Configuration
ALERT_WEBHOOK="${ALERT_WEBHOOK:-}"
LOG_FILE="/var/log/health-check.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check service status
check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}✓${NC} $service is running"
        return 0
    else
        echo -e "${RED}✗${NC} $service is NOT running"
        return 1
    fi
}

# Check port
check_port() {
    local port=$1
    local service=$2
    if ss -tln | grep -q ":$port "; then
        echo -e "${GREEN}✓${NC} $service (port $port) is listening"
        return 0
    else
        echo -e "${RED}✗${NC} $service (port $port) is NOT listening"
        return 1
    fi
}

# Check disk space
check_disk_space() {
    local threshold=90
    local usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [[ $usage -gt $threshold ]]; then
        echo -e "${RED}✗${NC} Disk usage is above ${threshold}%: ${usage}%"
        return 1
    else
        echo -e "${GREEN}✓${NC} Disk usage: ${usage}%"
        return 0
    fi
}

# Check memory
check_memory() {
    local total=$(free -m | awk '/^Mem:/ {print $2}')
    local used=$(free -m | awk '/^Mem:/ {print $3}')
    local usage=$((used * 100 / total))
    
    if [[ $usage -gt 90 ]]; then
        echo -e "${RED}✗${NC} Memory usage is above 90%: ${usage}%"
        return 1
    else
        echo -e "${GREEN}✓${NC} Memory usage: ${usage}% (${used}MB/${total}MB)"
        return 0
    fi
}

# Check SSL certificate expiry
check_ssl_certs() {
    local days_threshold=30
    local certs_failed=0
    
    for cert in /etc/letsencrypt/live/*/*.pem 2>/dev/null; do
        if [[ -f "$cert" ]]; then
            local expiry=$(openssl x509 -enddate -noout -in "$cert" 2>/dev/null | cut -d= -f2)
            echo -e "${GREEN}✓${NC} Certificate expires: $expiry"
        fi
    done
    
    return 0
}

# Check website accessibility
check_website() {
    local url=$1
    local name=$2
    
    if curl -sf -o /dev/null "$url"; then
        echo -e "${GREEN}✓${NC} $name is accessible"
        return 0
    else
        echo -e "${RED}✗${NC} $name is NOT accessible"
        return 1
    fi
}

# Send alert
send_alert() {
    local message=$1
    log "ALERT: $message"
    
    if [[ -n "$ALERT_WEBHOOK" ]]; then
        curl -s -X POST "$ALERT_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"text\":\"$message\"}" &>/dev/null
    fi
}

# Main health check
main() {
    local errors=0
    
    log "Starting health check..."
    echo "========================================"
    echo "  Hetzner Nextcloud Health Check"
    echo "========================================"
    echo ""
    
    # Check services
    echo "=== Services ==="
    check_service caddy || ((errors++))
    check_service apache2 || ((errors++))
    check_service mysql || ((errors++))
    check_service redis-server || ((errors++))
    check_service grafana-server || ((errors++))
    check_service fail2ban || ((errors++))
    echo ""
    
    # Check ports
    echo "=== Network Ports ==="
    check_port 443 "Caddy HTTPS"
    check_port 8080 "Apache"
    check_port 3306 "MySQL"
    check_port 6379 "Redis"
    check_port 3000 "Grafana"
    echo ""
    
    # Check resources
    echo "=== System Resources ==="
    check_disk_space || ((errors++))
    check_memory || ((errors++))
    echo ""
    
    # Check SSL certificates
    echo "=== SSL Certificates ==="
    check_ssl_certs || ((errors++))
    echo ""
    
    # Check websites
    echo "=== Website Accessibility ==="
    check_website "https://nextcloud.alvarezconsult.es" "Nextcloud"
    check_website "https://nextcloud-grafana.alvarezconsult.es" "Grafana"
    echo ""
    
    # Summary
    echo "========================================"
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}All checks passed!${NC}"
        log "All health checks passed"
    else
        echo -e "${RED}$errors check(s) failed!${NC}"
        log "Health check completed with $errors errors"
        send_alert "$errors health check(s) failed on nextcloud server"
    fi
    echo "========================================"
    
    return $errors
}

main
