# Arquitectura del Sistema - Visión General

## 📋 Introducción

Este documento describe la arquitectura técnica del servidor Nextcloud desplegado en Hetzner Cloud. Cada componente se explica en términos educativos, incluyendo **qué es**, **por qué se usa**, y **cómo está configurado** en este entorno real.

---

## 🖥️ Servidor Base (Hetzner CX22)

### ¿Qué es un VPS?

Un **Virtual Private Server (VPS)** es una máquina virtual que se ejecuta en un servidor físico compartido. Hetzner asigna recursos dedicados (CPU, RAM, disco) que están aislados de otros clientes mediante virtualización KVM.

### Especificaciones Reales

| Recurso | Valor | Explicación |
|---------|-------|-------------|
| **Proveedor** | Hetzner Cloud | Proveedor alemán de infraestructura, conocido por su relación calidad-precio |
| **Modelo** | CX22 | Plan básico de la serie CX, ideal para cargas de trabajo ligeras |
| **CPU** | Intel Xeon (Skylake), 1 vCPU | Un núcleo virtual de procesador server-grade |
| **RAM** | 3.7 GB DDR4 | Memoria suficiente para servicios web + base de datos + caché |
| **Disco** | 38 GB SSD NVMe | Almacenamiento local rápido para sistema operativo y aplicaciones |
| **OS** | Ubuntu 24.04.4 LTS | Versión LTS (Long Term Support) con soporte hasta 2029 |

### ¿Por qué Hetzner CX22?

- **Coste**: ~€4/mes vs €20-50/mes en otros proveedores
- **Redundancia**: Discos SSD en RAID, alimentación redundante
- **Ubicación**: Datacenter en Alemania (FSN1) - cumplimiento GDPR
- **IPv6 incluido**: Soporte nativo para direccionamiento IPv6

---

## 🔀 Caddy - Reverse Proxy y TLS Termination

### ¿Qué es un Reverse Proxy?

Un **reverse proxy** es un servidor intermedio que recibe solicitudes de clientes y las reenvía a servidores backend. Actúa como un "portero" que:

1. **Recibe** todas las conexiones HTTPS entrantes
2. **Termina** las conexiones TLS/SSL (descifra)
3. **Reenvía** las solicitudes HTTP simples a los servicios internos
4. **Devuelve** las respuestas cifradas al cliente

### ¿Por qué Caddy?

| Característica | Beneficio |
|----------------|-----------|
| **HTTPS automático** | Obtiene y renueva certificados Let's Encrypt automáticamente |
| **Configuración simple** | Archivo Caddyfile fácil de leer |
| **HTTP/2 nativo** | Mejor rendimiento en cargas múltiples |
| **Compresión automática** | Gzip/Brotli sin configuración extra |

### Configuración Real (/etc/caddy/Caddyfile)

```caddy
# Nextcloud - Servicio principal
nextcloud.alvarezconsult.es {
    reverse_proxy localhost:8080
    
    forward_auth localhost:9091 {
        uri /api/verify?rd=https://nextcloud-authelia.alvarezconsult.es/
    }
}

# Authelia - Portal de autenticación
nextcloud-authelia.alvarezconsult.es {
    reverse_proxy localhost:9091
}

# Grafana - Dashboards de monitoreo
nextcloud-grafana.alvarezconsult.es {
    reverse_proxy localhost:3000
    
    forward_auth localhost:9091 {
        uri /api/verify?rd=https://nextcloud-authelia.alvarezconsult.es/
    }
}

# Vault - Gestión de secretos
nextcloud-vault.alvarezconsult.es {
    reverse_proxy localhost:8200
    
    forward_auth localhost:9091 {
        uri /api/verify?rd=https://nextcloud-authelia.alvarezconsult.es/
    }
}
```

### Patrón forward_auth

La directiva `forward_auth` implementa **autenticación a nivel de proxy**:

1. Caddy recibe una petición
2. La reenvía a Authelia (`localhost:9091/api/verify`)
3. Authelia responde:
   - `200 OK` → Usuario autenticado, Caddy continúa
   - `302 Redirect` → Usuario no autenticado, redirigir al login

---

## 🐘 Apache + PHP-FPM - Servidor de Aplicaciones

### ¿Qué es Apache?

**Apache HTTP Server** es el servidor web más usado del mundo. Aquí funciona como:
- Servidor de aplicaciones PHP para Nextcloud
- Escucha en puerto 8080 (solo localhost)
- Procesa solicitudes PHP mediante PHP-FPM

### ¿Qué es PHP-FPM?

**PHP-FPM** (FastCGI Process Manager) es un gestor de procesos PHP que:
- Mantiene workers PHP pre-cargados en memoria
- Maneja conexiones persistentes
- Permite configurar pools de procesos separados

### ¿Por qué Apache + PHP-FPM y no Nginx?

| Factor | Apache + PHP-FPM | Nginx + PHP-FPM |
|--------|------------------|-----------------|
| Configuración Nextcloud | .htaccess soportado | Requiere configuración manual |
| Compatibilidad | 100% Nextcloud | Algunos plugins pueden fallar |
| Documentación | Amplia para Nextcloud | Menos específica |

---

## 🗄️ MySQL - Base de Datos Relacional

### ¿Qué es MySQL?

**MySQL** es un sistema de gestión de bases de datos relacional (RDBMS):
- Almacena datos estructurados en tablas
- Usa SQL (Structured Query Language) para consultas
- Ofrece transacciones ACID (Atomicity, Consistency, Isolation, Durability)

### ¿Por qué MySQL para Nextcloud?

Nextcloud requiere una base de datos para almacenar:
- Metadatos de archivos
- Usuarios y permisos
- Configuración de apps
- Tokens de sesión
- Registros de actividad

### Datos Reales

```
Database: nextcloud
Tables: 200+ tablas (usuarios, archivos, compartidos, activity, etc.)
Engine: InnoDB (soporta transacciones y foreign keys)
```

---

## ⚡ Redis - Caché en Memoria

### ¿Qué es Redis?

**REmote DIctionary Server** es un almacén de estructuras de datos en memoria:
- Base de datos clave-valor ultra-rápida
- Opera completamente en RAM
- Soporta strings, hashes, lists, sets, sorted sets

### ¿Por qué Redis para Nextcloud?

| Uso | Beneficio |
|-----|-----------|
| **File Locking** | Evita conflictos en edición simultánea |
| **Session Storage** | Sesiones rápidas sin cargar MySQL |
| **Query Cache** | Resultados de consultas frecuentes |
| **DNS Cache** | Resolución de dominios acelerada |

### Datos Reales del Servidor

```
Redis Version: 7.0.15
Connected Clients: 11
Used Memory: 1.57M
Uptime: 0 days (reiniciado recientemente)
```

---

## 📊 Grafana - Observabilidad

### ¿Qué es Grafana?

**Grafana** es una plataforma de visualización y monitoreo:
- Conecta a múltiples fuentes de datos (Prometheus, InfluxDB, etc.)
- Crea dashboards interactivos
- Configura alertas basadas en métricas

### ¿Por qué Grafana?

- **Visibilidad**: Ver el estado del servidor en tiempo real
- **Alertas**: Notificaciones cuando algo falla
- **Histórico**: Tendencias de uso a lo largo del tiempo

### Dashboard Real

```
Dashboard: Hetzner Nextcloud Production Overview
URL: https://nextcloud-grafana.alvarezconsult.es
Panels:
  - CPU Usage (4.6%)
  - Memory Used (38.4%)
  - Root Disk Used (22.9%)
  - Server Uptime (12 hours)
  - HTTPS Probe Duration
  - Certificate Days Left (12.8 weeks)
```

---

## 🔐 Authelia - SSO y MFA

### ¿Qué es Authelia?

**Authelia** es un servidor de autenticación y autorización:
- **SSO** (Single Sign-On): Un login para todos los servicios
- **MFA** (Multi-Factor Authentication): Segundo factor obligatorio
- **2FA methods**: TOTP (Google Authenticator), WebAuthn (YubiKey)

### ¿Por qué Authelia?

| Factor | Sin Authelia | Con Authelia |
|--------|--------------|--------------|
| Seguridad | Usuario/contraseña | Usuario + contraseña + código 2FA |
| Acceso | Cada servicio tiene su login | Un login para todos |
| Gestión | Múltiples contraseñas | Una contraseña + segundo factor |

### Flujo de Autenticación

```
1. Usuario accede a nextcloud.alvarezconsult.es
2. Caddy (reverse proxy) intercepta la petición
3. forward_auth envía verificación a Authelia
4. Authelia verifica sesión:
   - Si NO autenticado → Redirect al portal de login
   - Si autenticado → Caddy continúa con la petición
5. Usuario ve Nextcloud
```

---

## 🔑 HashiCorp Vault - Gestión de Secretos

### ¿Qué es Vault?

**HashiCorp Vault** es un sistema de gestión de secretos:
- Almacena contraseñas, API keys, certificados de forma cifrada
- Controla acceso mediante políticas
- Audita quién accede a qué secreto
- Rota secretos automáticamente

### ¿Por qué Vault?

- **Centralización**: Todos los secretos en un lugar
- **Auditoría**: Registro de quién accedió a qué
- **Rotación**: Cambio automático de credenciales
- **Cifrado**: Secretos nunca en texto plano

### Estado Real

```
Service: vault.service
Status: inactive (dead)
Instalado pero no activo actualmente
```

---

## 💾 Hetzner Storage Box - Almacenamiento Externo

### ¿Qué es Storage Box?

**Hetzner Storage Box** es un servicio de almacenamiento externo:
- Espacio de almacenamiento accesible via red
- Protocolos: CIFS/SMB, SFTP, rsync, BorgBackup
- Redundancia integrada (RAID en backend)
- Backup automático por Hetzner

### Configuración Real

```bash
# Storage Box 1 (Ruben)
Mount point: /mnt/storage-ruben
Protocol: CIFS (SMB 3.1.1)
Server: u556648-sub4.your-storagebox.de
Size: 5 TB
Used: 1.1 GB

# Storage Box 2 (Manuel)  
Mount point: /mnt/storage-manuel
Protocol: CIFS (SMB 3.1.1)
Server: u556648-sub3.your-storagebox.de
Size: 5 TB
Used: 1.1 GB
```

### ¿Por qué Storage Box y no disco local?

| Factor | Disco Local | Storage Box |
|--------|-------------|-------------|
| Capacidad | 38 GB | 10 TB total |
| Redundancia | SSD único | RAID en backend |
| Backup | Manual | Automático por Hetzner |
| Coste | Incluido | ~€4/mes extra |

### Montaje CIFS Real

```bash
//u556648-sub4.your-storagebox.de/u556648-sub4 on /mnt/storage-ruben
  type cifs
  options: rw,vers=3.1.1,cache=strict
  file_mode=0660,dir_mode=0770
  uid=33,www-data
```

---

## 🛡️ Fail2ban - Intrusion Prevention

### ¿Qué es Fail2ban?

**Fail2ban** es un sistema de prevención de intrusiones:
- Monitorea logs del sistema
- Detecta patrones de ataque (fuerza bruta, escaneos)
- Bloquea IPs maliciosas temporalmente

### ¿Por qué Fail2ban?

| Ataque | Sin protección | Con Fail2ban |
|--------|----------------|--------------|
| 100 intentos SSH | Todos procesados | Bloqueado tras 3 fallos |
| Fuerza bruta HTTP | Servidor responde | IP bloqueada |
| Escaneo de puertos | Logs crecen | IP bloqueada proactivamente |

---

## 🌐 Tailscale - VPN Mesh

### ¿Qué es Tailscale?

**Tailscale** es una red VPN mesh:
- Conecta dispositivos como si estuvieran en la misma red local
- Usa WireGuard en el backend (protocolo moderno y rápido)
- No requiere abrir puertos
- Configuración automática

### Red Real

```
Servidor: vpn-ruben-nextcloud-hetzner (100.77.1.30)
Clientes:
  - vpn-ruben-mini (100.77.1.10) - macOS
  - vpn-ruben-pixel (100.77.1.21) - Android
  - vpn-ruben-samsungs9fe (100.77.1.22) - Android
  - vpn-ruben-xiaomipad5 (100.77.1.23) - Android
```

### ¿Por qué Tailscale?

- **Acceso seguro**: SSH sin exponer al público
- **Sin configuración**: Funciona out-of-the-box
- **Multiplataforma**: Linux, macOS, Windows, Android, iOS
- **Gratuito**: Para uso personal/small team

---

## 📊 Resumen de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     INTERNET (IPv4 + IPv6)                   │
│                    46.224.204.126                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     CADDY (Reverse Proxy)                    │
│                     Puerto 443 (HTTPS)                       │
│         Terminación TLS + forward_auth → Authelia            │
└──────┬──────────────┬──────────────┬──────────────┬─────────┘
       │              │              │              │
       ▼              ▼              ▼              ▼
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ Apache   │   │ Authelia │   │ Grafana  │   │  Vault   │
│ :8080    │   │  :9091   │   │  :3000   │   │  :8200   │
│ Nextcloud│   │  SSO/MFA │   │Monitoring│   │ Secrets  │
└────┬─────┘   └──────────┘   └──────────┘   └──────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│                     PHP-FPM (Workers)                        │
│              Procesamiento de código PHP                     │
└──────┬──────────────────────────────────────────────────────┘
       │
       ├──────────────────┬───────────────────┐
       ▼                  ▼                   ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────────────┐
│   MySQL     │   │   Redis     │   │  Storage Boxes      │
│   :3306     │   │   :6379     │   │  /mnt/storage-*     │
│  Database   │   │   Cache     │   │  10TB (CIFS/SMB)    │
└─────────────┘   └─────────────┘   └─────────────────────┘

                   ┌─────────────────────────────────┐
                   │       Tailscale VPN Mesh        │
                   │        100.77.1.30              │
                   │   (Acceso administrativo SSH)   │
                   └─────────────────────────────────┘
```

---

## 🔗 Próximos Pasos

1. **Alta Disponibilidad**: Configurar réplica de base de datos
2. **Backups Automatizados**: Script de backup a Storage Box
3. **Monitoreo Avanzado**: Añadir Prometheus + alertas
4. **Containerización**: Migrar servicios a Docker Compose
5. **CDN**: Cloudflare para mejorar latencia global
