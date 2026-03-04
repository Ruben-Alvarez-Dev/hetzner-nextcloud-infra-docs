# 🏗️ Architecture Overview

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'primaryColor': '#1971c2',
    'primaryTextColor': '#fff',
    'primaryBorderColor': '#0a58ca',
    'lineColor': '#495057',
    'secondaryColor': '#2f9e44',
    'tertiaryColor': '#f59f00',
    'background': '#ffffff',
    'mainBkg': '#f8f9fa',
    'nodeBorder': '#dee2e6',
    'clusterBkg': 'rgba(222, 226, 230, 0.1)',
    'clusterBorder': '#adb5bd',
    'titleColor': '#212529',
    'edgeLabelBackground': '#ffffff'
  }
}}%%

graph TB
    subgraph INTERNET["🌐 Internet Layer"]
        USER[👤 User Browser<br/>Chrome/Firefox/Safari]
        DNS[📡 DNS Resolution<br/>Cloudflare DNS]
        CDN[🛡️ CDN Layer<br/>Optional Cache]
    end

    subgraph PERIMETER["🛡️ Security Perimeter"]
        CADDY[🛡️ Caddy Reverse Proxy<br/>Port 443 - HTTPS<br/>TLS 1.3 Encryption<br/>Automatic Certificates]
        AUTH[🔐 Authelia SSO<br/>Port 9091<br/>MFA Gateway<br/>Session Management]
    end

    subgraph APPLICATION["☁️ Application Layer"]
        APACHE[🖥️ Apache 2.4<br/>Port 8080<br/>Virtual Host]
        PHP[🐘 PHP 8.3 FPM<br/>OPcache Enabled<br/>Memory: 512MB]
        NEXTCLOUD[☁️ Nextcloud 30.0.5<br/>Files, Photos, Calendar<br/>Security Apps Active]
    end

    subgraph DATA["💾 Data Layer"]
        MYSQL[(🗄️ MySQL 8.0<br/>Port 3306<br/>InnoDB Engine<br/>UTF8MB4 Charset)]
        REDIS[(⚡ Redis Cache<br/>Port 6379<br/>Maxmemory: 256MB<br/>LRU Eviction)]
        STORAGE[📦 Storage Box<br/>5TB Shared Storage<br/>SMB/CIFS Mount<br/>Automatic Backup]
    end

    subgraph MONITORING["📊 Observability Stack"]
        GRAFANA[📈 Grafana Dashboard<br/>Port 3000<br/>Real-time Metrics<br/>Alerting System]
        LOGS[📝 Centralized Logs<br/>Journalctl<br/>Log Rotation<br/>7-day Retention]
        METRICS[📊 System Metrics<br/>CPU, Memory, Disk<br/>Network I/O<br/>Custom Dashboards]
    end

    subgraph VPN["🔐 Private Network"]
        TAILSCALE[🔐 Tailscale VPN<br/>Mesh Network<br/>100.77.1.30<br/>WireGuard Encryption]
        VAULT[🗝️ HashiCorp Vault<br/>Port 8200<br/>Secrets Management<br/>Dynamic Credentials]
        FAIL2BAN[🛡️ Fail2ban IPS<br/>Brute Force Protection<br/>SSH Jail Active<br/>Auto-ban IPs]
    end

    %% User Flow
    USER -->|HTTPS Request| DNS
    DNS -->|A Record: 46.224.204.126| CADDY
    CADDY -->|TLS Handshake| CADDY
    CADDY -->|forward_auth check| AUTH
    
    %% Authentication Flow
    AUTH -->|Not Authenticated| AUTH_LOGIN[🔐 Login Portal<br/>MFA Required]
    AUTH_LOGIN -->|Credentials + TOTP| AUTH
    AUTH -->|Session Cookie| CADDY
    
    %% Application Flow
    CADDY -->|Authenticated Request| APACHE
    APACHE -->|PHP Processing| PHP
    PHP -->|Application Logic| NEXTCLOUD
    
    %% Data Access
    NEXTCLOUD -->|Cache Check| REDIS
    REDIS -.->|Cache Miss| MYSQL
    NEXTCLOUD -->|Data Query| MYSQL
    MYSQL -->|Result Set| NEXTCLOUD
    NEXTCLOUD -->|File Storage| STORAGE
    
    %% Monitoring Flow
    CADDY -.->|Access Logs| LOGS
    APACHE -.->|Error Logs| LOGS
    MYSQL -.->|Slow Query Log| LOGS
    NEXTCLOUD -.->|App Logs| LOGS
    LOGS -->|Visualization| GRAFANA
    METRICS -->|Time Series| GRAFANA
    
    %% Security Integration
    TAILSCALE -.->|Secure Access| CADDY
    AUTH -.->|API Tokens| VAULT
    NEXTCLOUD -.->|DB Credentials| VAULT
    FAIL2BAN -.->|Block IPs| CADDY
    
    %% Styling
    style CADDY fill:#1971c2,stroke:#0a58ca,color:#fff,stroke-width:3px
    style AUTH fill:#c92a2a,stroke:#a61e1e,color:#fff,stroke-width:3px
    style NEXTCLOUD fill:#2f9e44,stroke:#237032,color:#fff,stroke-width:3px
    style MYSQL fill:#f59f00,stroke:#d9480f,color:#fff,stroke-width:3px
    style REDIS fill:#862e9c,stroke:#5f3dc4,color:#fff,stroke-width:3px
    style VAULT fill:#862e9c,stroke:#5f3dc4,color:#fff,stroke-width:3px
    style TAILSCALE fill:#0c8599,stroke:#0a6e7b,color:#fff,stroke-width:3px
    style GRAFANA fill:#f76707,stroke:#d9480f,color:#fff,stroke-width:2px
    style FAIL2BAN fill:#c92a2a,stroke:#a61e1e,color:#fff,stroke-width:2px
    style STORAGE fill:#1971c2,stroke:#0a58ca,color:#fff,stroke-width:2px
```

## 📊 Component Details

### Network Perimeter
| Component | Technology | Purpose | Port |
|-----------|-----------|---------|------|
| **Reverse Proxy** | Caddy 2.11 | HTTPS termination, routing | 443 |
| **SSO Gateway** | Authelia 4.38 | Authentication, MFA | 9091 |
| **Firewall** | iptables + Fail2ban | Intrusion prevention | All |

### Application Layer
| Component | Technology | Purpose | Port |
|-----------|-----------|---------|------|
| **Web Server** | Apache 2.4 | HTTP server | 8080 |
| **PHP Runtime** | PHP 8.3 FPM | Application processing | 9000 |
| **Application** | Nextcloud 30.0.5 | File sharing, collaboration | 8080 |

### Data Layer
| Component | Technology | Purpose | Port |
|-----------|-----------|---------|------|
| **Database** | MySQL 8.0 | Relational data storage | 3306 |
| **Cache** | Redis 7.x | Session & query cache | 6379 |
| **Backup Storage** | Hetzner Storage Box | External backup | SMB |

### Security Layer
| Component | Technology | Purpose | Port |
|-----------|-----------|---------|------|
| **VPN** | Tailscale | Encrypted mesh network | 41641 |
| **Secrets** | HashiCorp Vault | Credential management | 8200 |
| **IPS** | Fail2ban | Brute force protection | - |

### Monitoring Layer
| Component | Technology | Purpose | Port |
|-----------|-----------|---------|------|
| **Dashboard** | Grafana 11 | Metrics visualization | 3000 |
| **Logging** | Journalctl | Centralized logs | - |
| **Metrics** | Custom | System monitoring | - |

## 🔗 Related Diagrams

- [Network Flow Diagram](./02-network-flow.md) - Request/response flow
- [Security Layers](./03-security-layers.md) - Defense in depth
- [Performance Metrics](./04-performance-metrics.md) - Resource utilization

---

**Last Updated**: 2026-03-04
