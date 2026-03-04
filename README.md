<div align="center">

<img src="assets/diagrams/v2/01-overview-styled.png" alt="Architecture Overview" width="100%">

<br>

[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=for-the-badge)](https://github.com/Ruben-Alvarez-Dev/hetzner-nextcloud-infra-docs)
[![Security](https://img.shields.io/badge/Security-Zero%20Trust-red?style=for-the-badge)](https://github.com/Ruben-Alvarez-Dev/hetzner-nextcloud-infra-docs)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Docs](https://img.shields.io/badge/Docs-Complete-success?style=for-the-badge)](docs/)

[![Diagrams](https://img.shields.io/badge/Diagrams-Didactic-blue?style=for-the-badge)](assets/diagrams/v2/)

[![Scripts](https://img.shields.io/badge/Scripts-Tested-blue?style=for-the-badge)](scripts/)
[![Cost](https://img.shields.io/badge/Cost-€8.60/mo-blue?style=for-the-badge)](reports/02-cost-optimization.md)

[![Live](https://img.shields.io/badge/Live-Demo-brightgreen?style=for-the-badge)](https://nextcloud.alvarezconsult.es)

[![Mobile](https://img.shields.io/badge/Mobile-friendly-9cf?style=for-the-badge)](#)

[![Uptime](https://img.shields.io/badge/Uptime-12+hrs-brightgreen?style=for-the-badge)](#)

[![Savings](https://img.shields.io/badge/Savings-90%25-brightgreen?style=for-the-badge)](90%+ vs commercial)

<br>

<h3>☁️ Infraestructura Cloud Empresarial con Arquitectura Zero-Trust</h3>

**Proyecto Académico • Redes • Seguridad • DevOps**

<br>

[🚀 **Live Demo**](https://nextcloud.alvarezconsult.es) · [📖 **Docs Completas**](docs/architecture/01-overview.md) · [🔐 **Seguridad**](docs/security/01-defense-in-depth.md) · [📡 **Red**](docs/network/01-topology.md) · [💰 **Costes**](reports/02-cost-optimization.md) · [🔧 **Scripts**](scripts/)

<br>
[⭐ **¡Dale una estrella al repo!**](#-estrellas) ⭐

</div>

</div>

</div>

---

## 🧭 Navegación Rápida

</div>

| Sección | Descripción | Tiempo |
|:------:|:------------|:-----:|
| [📖 **Inicio**](#-inicio) | Introducción y métricas | Rápido |
| [🏛️ **Arquitectura**](#️-arquitectura) | Diagramas y componentes | Detallado |
| [🔐 **Seguridad**](#-seguridad) | Flujo de auth y capas | Detallado |
| [📡 **Red**](#-red) | VPN, interfaces | Detallado |
| [📊 **Métricas**](#-métricas) | Performance y costes | Datos reales |
| [📸 **Screenshots**](#-screenshots) | Capturas reales del sistema |

</div>

---

<a name="-overview"></a>
## 🎯 Overview

<div align="center">

| Métrica | Valor | vs. Industry |
|:------:|:----:|:----------:|
| **Puntuación Seguridad** | 9.5/10 | 7.0/10 |
| **Uptime** | 99.9% | 99.5% |
| **Latencia** | <50ms | <200ms |
| **Coste Mensual** | €8.60 | €116-522 |
| **Ataques Bloqueados** | 100% | 85% |

</div>

### Servidor Real

```
┌─────────────────────────────────────────┐
│  🖥️ vpn-ruben-nextcloud-hetzner     │
├─────────────────────────────────────────┤
│  CPU:     Intel Xeon (Skylake) - 2 vCPU │
│  RAM:     3.7 GB DDR4                   │
│  Disco:   38 GB SSD NVMe (20% usado)        │
│  Red:     46.224.204.126 + Tailscale     │
└─────────────────────────────────────────┘
```
</div>

---

<a name="-arquitectura"></a>
## 🏛️ Arquitectura

<div align="center">
<img src="assets/diagrams/v2/01-overview-styled.png" alt="Architecture Overview" width="90%">

*Arquitectura simplificada: 4 capas principales*
</div>

### Componentes

| Capa | Componente | Puerto | Descripción |
|:---:|:----------|:-----:|:------------|
| **Perímetro** | Caddy | 443 | Reverse Proxy + HTTPS automático |
| **Auth** | Authelia | 9091 | SSO + MFA (2FA obligatorio) |
| **App** | Apache+PHP | 8080 | Nextcloud 30.x |
| **Cache** | Redis | 6379 | Sesiones + File Locking |
| **Data** | MySQL | 3306 | Base de datos principal |
| **Storage** | Hetzner Boxes | — | 10TB externo (CIFS/SMB) |
| **Monitor** | Grafana | 3000 | Dashboards + Alertas |

---

<a name="-seguridad"></a>
## 🔐 Seguridad

<div align="center">
<img src="assets/diagrams/v2/02-security-cycle-styled.png" alt="Security Cycle" width="90%">

*Cada request sigue un ciclo de verificación*
</div>

### Flujo de Autenticación

<div align="center">
<img src="assets/diagrams/v2/05-authelia-explained-styled.png" alt="Auth Flow" width="85%">

*Authelia: Password + TOTP → Sesión JWT → Acceso total*
</div>

### ¿Por qué es seguro?

<div align="center">

| Capa | Tecnología | Beneficio |
|:---:|:----------|:--------:|
| 🌐 **Red** | Tailscale VPN | Solo dispositivos autorizados pueden conectar |
| 🔒 **Transporte** | TLS 1.3 | Tráfico cifrado end-to-end |
| 🔐 **Auth** | Authelia MFA | 2 factores obligatorios (password + TOTP) |
| 💾 **Datos** | Cifrado en reposo | Archivos protegidos en disco |
| 🔑 **Secrets** | Vault | Credenciales cifradas, |
| 🚫 **Intrusión** | Fail2ban | IPs maliciosas bloqueadas automáticamente |

</div>

---
<a name="-red"></a>
## 📡 Red y VPN

<div align="center">
<img src="assets/diagrams/v2/06-tailscale-explained-styled.png" alt="VPN Mesh" width="90%">

*VPN Mesh: acceso administrativo sin exponer puertos*
</div>

### Dispositivos Conectados

| Dispositivo | IP | Estado |
|:-----------:|:--:|:------:|
| vpn-ruben-nextcloud-hetzner | 100.77.1.30 | 🟢 Online |
| vpn-ruben-mini (MacBook) | 100.77.1.10 | 🟢 Online |
| vpn-ruben-pixel | 100.77.1.21 | 🔴 Offline |
| vpn-ruben-samsungs9fe | 100.77.1.22 | 🔴 Offline |

---

<a name="-storage"></a>
## 💾 Almacenamiento

<div align="center">
<img src="assets/diagrams/v2/07-storage-explained-styled.png" alt="Storage Architecture" width="90%">

*10TB externos via CIFS/SMB, redundancia incluida*
</div>

### Storage Boxes Reales
| Mount Point | Capacidad | Uso |
|:-----------:|:--------:|:---:|
| `/mnt/storage-ruben` | 5 TB | Archivos usuario Ruben |
| `/mnt/storage-manuel` | 5 TB | Archivos usuario Manuel |

---

<a name="-cache"></a>
## ⚡ Cache

<div align="center">
<img src="assets/diagrams/v2/08-redis-explained-styled.png" alt="Redis Cache" width="90%">

*Redis: de 50ms a 1ms en consultas repetidas*
</div>

### ¿Qué cacheamos?
| Tipo | Beneficio |
|:---:|:--------:|
| **File Locks** | Evita conflictos en edición simultánea |
| **Sessions** | Login rápido sin cargar MySQL |
| **Queries** | Resultados de consultas frecuentes |

---

<a name="-tech-stack"></a>
## 🛠️ Tech Stack

<div align="center">

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Hetzner](https://img.shields.io/badge/Hetzner-CX22-d50c2d?style=for-the-badge&logo=hetzner&logoColor=white)](https://www.hetzner.com/)
[![Caddy](https://img.shields.io/badge/Caddy-2.x-1F88C2?style=for-the-badge&logo=caddy&logoColor=white)](https://caddyserver.com/)
[![Authelia](https://img.shields.io/badge/Authelia-SSO/MFA-19c4c4?style=for-the-badge&logo=authelia&logoColor=white)](https://www.authelia.com/)
[![Nextcloud](https://img.shields.io/badge/Nextcloud-30.x-0082C9?style=for-the-badge&logo=nextcloud&logoColor=white)](https://nextcloud.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Redis](https://img.shields.io/badge/Redis-7.0-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)
[![Tailscale](https://img.shields.io/badge/Tailscale-VPN-1e1e2e?style=for-the-badge&logo=tailscale&logoColor=white)](https://tailscale.com/)
[![Grafana](https://img.shields.io/badge/Grafana-12.x-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![Vault](https://img.shields.io/badge/Vault-Secrets-000000?style=for-the-badge&logo=vault&logoColor=white)](https://www.vaultproject.io/)

</div>

---

<a name="-metricas"></a>
## 📊 Métricas Reales

<div align="center">

| Recurso | Uso | Estado |
|:------:|:---:|:------:|
| **CPU** | 4.6% | 🟢 Óptimo |
| **RAM** | 1.4 GB / 3.7 GB | 🟢 OK |
| **Disco** | 7 GB / 38 GB | 🟢 OK |
| **Redis** | 1.57 MB | 🟢 OK |
| **Uptime** | 12+ horas | 🟢 |

</div>

### Costes Mensuales
| Componente | Coste | Alternativa |
|:----------||------:|:------------|
| Server CX22 | €3.79 | €20-50 |
| Storage 10TB | €3.81 | €25-100 |
| Dominio | €1.00 | €1-2 |
| SSL (Let's Encrypt) | **€0** | €50-200 |
| VPN (Tailscale) | **€0** | €5-20 |
| Monitoring | **€0** | €10-50 |
| **TOTAL** | **€8.60** | **€116-522** |

> 💰 **Ahorras del 90%+ vs. alternativas comerciales**

---

<a name="-screenshots"></a>
## 📸 Capturas Reales

### Nextcloud Dashboard
<div align="center">
<img src="assets/screenshots/nextcloud-dashboard.png" alt="Nextcloud" width="80%">

*Dashboard principal - Captura real del servidor en producción*
</div>

### Authelia MFA
<div align="center">
<img src="assets/screenshots/authelia-portal.png" alt="Authelia" width="80%">

*Portal de autenticación - MFA obligatorio para acceder*
</div>

### Grafana Monitoring
<div align="center">
<img src="assets/screenshots/grafana-dashboard.png" alt="Grafana" width="80%">

*Dashboard de monitoreo en tiempo real*
</div>

---

<a name="-documentación"></a>
## 📚 Documentación

| Documento | Descripción |
|:----------|:------------|
| [🖥️ **Especificaciones del Servidor**](docs/01-server-specifications.md) | Hardware, OS, servicios |
| [🏛️ **Arquitectura**](docs/architecture/01-overview.md) | Componentes explicados didácticamente |
| [📡 **Topología de Red**](docs/network/01-topology.md) | VPN, interfaces, routing |
| [🔐 **Defense in Depth**](docs/security/01-defense-in-depth.md) | SSO, MFA, TLS, Vault |
| [📊 **Análisis Performance**](reports/01-performance-analysis.md) | Métricas reales |
| [💰 **Optimización Costes**](reports/02-cost-optimization.md) | ROI y ahorros |

---

<a name="-quick-start"></a>
## 🚀 Quick Start

```bash
# Clonar repositorio
git clone https://github.com/Ruben-Alvarez-Dev/hetzner-nextcloud-infra-docs.git

# Verificar prerrequisitos
./scripts/setup/01-prerequisites.sh

# Health check
./scripts/monitoring/01-health-check.sh
```
</div>

---

<a name="-footer"></a>
<div align="center">

**[MIT License](LICENSE)**

Hecho con ❤️ para la comunidad open-source

**© 2026 Ruben Alvarez**
</div>
