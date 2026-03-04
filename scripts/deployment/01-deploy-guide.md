# Deployment Guide

## Overview

This guide explains how to deploy the Hetzner Nextcloud infrastructure from scratch.

## Prerequisites

### Server Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| CPU | 1 vCPU | 2+ vCPU |
| RAM | 2GB | 4GB+ |
| Disk | 20GB SSD | 40GB+ SSD |
| OS | Ubuntu 22.04 | Ubuntu 24.04 LTS |

### Network Requirements

- Public IPv4 address
- IPv6 connectivity (optional but recommended)
- Domain name with DNS control
- Ports 80 and 443 accessible

## Deployment Steps

### 1. Server Provisioning

```bash
# Via Hetzner Cloud Console or CLI
hcloud server create \
    --name nextcloud-server \
    --type cx22 \
    --image ubuntu-24.04 \
    --location fsn1
```

### 2. Initial Server Setup

```bash
# Run as root
./scripts/setup/01-prerequisites.sh
./scripts/setup/02-install-base.sh
```

### 3. Configure DNS

Create the following DNS records:

| Type | Name | Value |
|------|------|-------|
| A | nextcloud | 46.224.204.126 |
| A | nextcloud-authelia | 46.224.204.126 |
| A | nextcloud-grafana | 46.224.204.126 |
| AAAA | nextcloud | 2a01:4f8:1c19:1cb3::1 |

### 4. Install Services

```bash
# Install core services
./scripts/setup/03-install-services.sh

# Configure security
./scripts/setup/04-configure-security.sh
```

### 5. Verify Deployment

```bash
# Run health check
./scripts/monitoring/01-health-check.sh

# Test all services
curl -I https://nextcloud.alvarezconsult.es
curl -I https://nextcloud-authelia.alvarezconsult.es
```

## Post-Deployment Checklist

- [ ] All services running (`systemctl status`)
- [ ] SSL certificates issued (check Caddy logs)
- [ ] DNS propagation complete
- [ ] Authelia login works
- [ ] Nextcloud accessible
- [ ] Grafana shows metrics
- [ ] Backup script tested

## Troubleshooting

### Common Issues

**SSL Certificate Issues**
```bash
# Check Caddy logs
journalctl -u caddy -f

# Force certificate renewal
systemctl restart caddy
```

**Authelia Not Working**
```bash
# Check Authelia logs
journalctl -u authelia -f

# Verify configuration
cat /etc/authelia/configuration.yml
```

**Nextcloud Errors**
```bash
# Enable debug mode
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
sudo -u www-data php /var/www/nextcloud/occ log:manage --level debug
```
