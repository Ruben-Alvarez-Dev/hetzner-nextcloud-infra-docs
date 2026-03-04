# Seguridad - Defensa en Profundidad

## 📋 Introducción

Este documento explica la estrategia de seguridad implementada, basada en el modelo de **Defense in Depth** (Defensa en Profundidad): múltiples capas de seguridad que protegen el sistema incluso si una capa falla.

---

## 🛡️ Modelo Defense in Depth

```
┌─────────────────────────────────────────────────────────────────┐
│ CAPA 7: DATOS                                                    │
│ Cifrado en reposo, backups cifrados                             │
├─────────────────────────────────────────────────────────────────┤
│ CAPA 6: APLICACIÓN                                               │
│ Hardening PHP, validación de entrada, CSP headers               │
├─────────────────────────────────────────────────────────────────┤
│ CAPA 5: AUTENTICACIÓN                                            │
│ Authelia SSO + MFA (TOTP/WebAuthn)                               │
├─────────────────────────────────────────────────────────────────┤
│ CAPA 4: TRANSPORTE                                               │
│ TLS 1.3, HSTS, cipher suites modernos                           │
├─────────────────────────────────────────────────────────────────┤
│ CAPA 3: RED                                                      │
│ Firewall, VPN, segmentación                                     │
├─────────────────────────────────────────────────────────────────┤
│ CAPA 2: PERÍMETRO                                                │
│ Reverse proxy, rate limiting, WAF básico                        │
├─────────────────────────────────────────────────────────────────┤
│ CAPA 1: POLÍTICAS                                                │
│ Auditoría, logs, procedimientos de respuesta a incidentes       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Capa 5: Authelia - SSO y MFA

### ¿Qué es SSO (Single Sign-On)?

**Single Sign-On** permite:
- **Un login** para acceder a todos los servicios
- **Sesión unificada** que persiste entre aplicaciones
- **Logout centralizado** que cierra todas las sesiones

### ¿Qué es MFA (Multi-Factor Authentication)?

**Autenticación multifactor** requiere:
- **Algo que SABES**: Contraseña
- **Algo que TIENES**: App TOTP (Google Authenticator, Authy)
- **O algo que ERES**: Huella, FaceID (biometría)

### Métodos Soportados por Authelia

| Método | Tipo | Seguridad | Facilidad |
|--------|------|-----------|-----------|
| **Password** | 1FA | Baja | Alta |
| **TOTP** | 2FA | Alta | Alta |
| **WebAuthn** | 2FA | Muy Alta | Media |
| **Duo Push** | 2FA | Alta | Alta |

### Configuración Real

Authelia está configurado en `/etc/authelia/configuration.yml` y expuesto en:
- `https://nextcloud-authelia.alvarezconsult.es`

### Flujo de Autenticación Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUJO DE AUTENTICACIÓN                        │
└─────────────────────────────────────────────────────────────────┘

1. Usuario intenta acceder a nextcloud.alvarezconsult.es
   │
   ▼
2. Caddy forward_auth envía petición a Authelia
   │
   ▼
3. Authelia verifica sesión
   │
   ├───► SIN SESIÓN VÁLIDA:
   │    ┌─────────────────────────────────────┐
   │    │ Redirigir a Portal de Login         │
   │    │ nextcloud-authelia.alvarezconsult.es│
   │    └──────────────────┬──────────────────┘
   │                       │
   │                       ▼
   │    ┌─────────────────────────────────────┐
   │    │ 1. Usuario introduce username       │
   │    │ 2. Usuario introduce contraseña     │
   │    │ 3. Authelia valida (1FA)            │
   │    │ 4. Si 2FA habilitado:               │
   │    │    - Pedir código TOTP o WebAuthn   │
   │    │ 5. Autenticación exitosa            │
   │    │ 6. Crear sesión JWT                 │
   │    │ 7. Redirect al servicio original    │
   │    └─────────────────────────────────────┘
   │
   └───► CON SESIÓN VÁLIDA:
        ┌─────────────────────────────────────┐
        │ Authelia retorna:                    │
        │ HTTP 200 OK + Headers de usuario     │
        │                                      │
        │ Caddy continúa:                      │
        │ proxy_pass → localhost:8080          │
        └─────────────────────────────────────┘
```

### JWT (JSON Web Tokens)

Authelia usa **JWT** para sesiones:
- Token firmado criptográficamente
- Contiene: user ID, expiración, claims
- Firmado con secreto del servidor
- No modificable por el cliente

---

## 🔑 HashiCorp Vault - Gestión de Secretos

### ¿Qué es un Secret Manager?

Un **secret manager** es un sistema para:
- Almacenar contraseñas, API keys, certificados de forma CIFRADA
- Controlar quién puede acceder a cada secreto
- Auditar todos los accesos
- Rotar secretos automáticamente

### ¿Por qué no guardar secretos en archivos de configuración?

```
┌────────────────────────────────────────────────────────────────┐
│ MALA PRÁCTICA: Secretos en código/config                        │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ // config.php                                                  │
│ $db_password = "Malaga_2026!!"; // ← EXPUESTO en git, backups │
│                                                                │
│ Problemas:                                                     │
│ • Visible en repositorios git                                  │
│ • Visible en backups                                           │
│ • No hay auditoría de quién lo ve                              │
│ • Difícil rotar                                                │
└────────────────────────────────────────────────────────────────┘
                              vs
┌────────────────────────────────────────────────────────────────┐
│ BUENA PRÁCTICA: Secretos en Vault                              │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ // config.php                                                  │
│ $db_password = Vault::getSecret('database/nextcloud');         │
│                                                                │
│ Ventajas:                                                      │
│ • Secreto cifrado en memoria                                   │
│ • Auditoría de accesos                                         │
│ • Rotación automática posible                                  │
│ • Políticas de acceso granulares                               │
└────────────────────────────────────────────────────────────────┘
```

### Componentes de Vault

| Componente | Función |
|------------|---------|
| **Storage Backend** | Dónde se guardan los datos cifrados (file, consul, s3) |
| **Seal/Unseal** | Vault inicia sellado, requiere "unseal keys" para abrir |
| **Secret Engines** | Tipos de secretos: KV, Database, PKI, Transit |
| **Auth Methods** | Cómo se autentican clientes: Token, AppRole, Kubernetes |
| **Policies** | Permisos: quién puede acceder a qué |

### Estado Real

```
Service: vault.service
Status: inactive (dead) - Instalado pero no activado
Location: /opt/vault/
Config: /opt/vault/config.hcl
```

**Nota**: Vault está instalado pero actualmente inactivo. Para producción, se recomienda activarlo y migrar todos los secretos.

---

## 🚫 Fail2ban - Intrusion Prevention

### ¿Qué es Fail2ban?

**Fail2ban** es un sistema de prevención de intrusiones que:
1. **Monitorea** logs del sistema
2. **Detecta** patrones de ataque (múltiples fallos de login)
3. **Bloquea** IPs maliciosas usando iptables/nftables

### ¿Cómo funciona?

```
┌─────────────────────────────────────────────────────────────────┐
│                    SISTEMA FAIL2BAN                              │
│                                                                 │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
│  │   LOG FILES  │────►│    FILTER    │────►│    JAIL     │    │
│  │              │     │   (regex)    │     │  (action)   │    │
│  │ auth.log     │     │              │     │             │    │
│  │ apache.log   │     │ Pattern:     │     │ iptables    │    │
│  │ nextcloud.log│     │ "Failed      │     │ -A INPUT    │    │
│  └──────────────┘     │  password"   │     │ -s <IP>     │    │
│                       └──────────────┘     │ -j DROP     │    │
│                                            └──────────────┘    │
│                                                                 │
│  Ejemplo:                                                       │
│  • IP 192.168.1.100 falla SSH 3 veces en 10 min                │
│  • Fail2ban detecta patrón                                      │
│  • Fail2ban ejecuta iptables DROP para esa IP                  │
│  • IP bloqueada por 1 hora                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Configuración Real

```ini
# /etc/fail2ban/jail.d/nextcloud.local

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
```

### Parámetros Clave

| Parámetro | Valor | Significado |
|-----------|-------|-------------|
| `maxretry` | 3 | Intentos antes de bloqueo |
| `findtime` | 600s | Ventana de tiempo para contar intentos |
| `bantime` | 3600s | Duración del bloqueo |

---

## 🔒 TLS/HTTPS - Cifrado en Transporte

### ¿Qué es TLS?

**Transport Layer Security** cifra la comunicación entre cliente y servidor:

```
┌─────────────┐                              ┌─────────────┐
│   Cliente   │◄──── TRÁFICO CIFRADO ───────►│   Servidor  │
│  (Browser)  │      (TLS 1.3)               │   (Caddy)   │
└─────────────┘                              └─────────────┘
      │                                            │
      │ HTTP plano                                 │ HTTP plano
      ▼                                            ▼
┌─────────────┐                              ┌─────────────┐
│   App Web   │                              │  Backend    │
└─────────────┘                              └─────────────┘
```

### ¿Qué protege TLS?

| Ataque | Sin TLS | Con TLS |
|--------|---------|---------|
| **Eavesdropping** | Contraseñas visibles | Cifrado, ilegible |
| **Man-in-the-Middle** | Modificación posible | Detectado |
| **Replay Attack** | Posible | Prevenido |
| **Impersonation** | Cualquiera puede fingir | Certificado verifica identidad |

### Let's Encrypt

**Let's Encrypt** es una autoridad certificadora gratuita:
- Emite certificados X.509 gratuitos
- Validación automática via ACME protocol
- Renovación automática cada 90 días
- Caddy lo maneja automáticamente

### Configuración Real

```
Certificados emitidos por: Let's Encrypt
Dominios:
  - nextcloud.alvarezconsult.es
  - nextcloud-authelia.alvarezconsult.es
  - nextcloud-grafana.alvarezconsult.es
  - nextcloud-vault.alvarezconsult.es

Renovación: Automática via Caddy (cada 60 días)
Protocolo: TLS 1.3
Cipher Suite: TLS_AES_128_GCM_SHA256 (preferido)
HSTS: enabled (max-age=31536000)
```

---

## 🌐 Tailscale - VPN de Acceso Administrativo

### ¿Por qué VPN para administradores?

```
┌────────────────────────────────────────────────────────────────┐
│ ACCESO SSH PÚBLICO (NO RECOMENDADO)                            │
├────────────────────────────────────────────────────────────────┤
│ Puerto 22 abierto al mundo → Miles de intentos de brute force │
│ Necesita: fail2ban + contraseñas fuertes + 2FA opcional       │
│ Riesgo: Zero-day en OpenSSH → Compromiso posible              │
└────────────────────────────────────────────────────────────────┘
                              vs
┌────────────────────────────────────────────────────────────────┐
│ ACCESO SSH via VPN (RECOMENDADO)                               │
├────────────────────────────────────────────────────────────────┤
│ Puerto 22 solo accesible desde red VPN                        │
│ Necesita: Autenticación Tailscale + SSH key                   │
│ Riesgo: Atacante necesita acceso a red VPN primero            │
└────────────────────────────────────────────────────────────────┘
```

### Mesh VPN vs VPN Tradicional

| Característica | VPN Tradicional | Mesh VPN (Tailscale) |
|----------------|-----------------|---------------------|
| Topología | Hub-and-spoke | Peer-to-peer |
| Latencia | Client→Server→Destination | Direct Client→Destination |
| Escalabilidad | Limitada por servidor | Ilimitada |
| Single Point of Failure | Sí (VPN server) | No (coordinación distribuida) |

---

## 📊 Auditoría y Logs

### ¿Qué se registra?

| Servicio | Log | Información |
|----------|-----|-------------|
| Caddy | `/var/log/caddy/access.log` | Requests HTTP, IPs, user agents |
| Apache | `/var/log/apache2/access.log` | Accesos Nextcloud |
| Authelia | `/var/log/authelia/authelia.log` | Logins, MFA, sesiones |
| SSH | `/var/log/auth.log` | Conexiones SSH |
| Fail2ban | `/var/log/fail2ban.log` | Bloqueos |

### Retención

Los logs se rotan automáticamente:
- Logs actuales: `/var/log/*/`
- Logs comprimidos: `/var/log/*/*.gz`
- Retención: 7 días sin comprimir, 4 semanas comprimidos

---

## 🚨 Incident Response

### Checklist de Respuesta

```
┌─────────────────────────────────────────────────────────────────┐
│ CHECKLIST: Posible Compromiso                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 1. IDENTIFICAR                                                  │
│    □ Revisar logs: tail -f /var/log/auth.log                   │
│    □ Revisar conexiones: ss -tunlp                             │
│    □ Revisar procesos: htop                                    │
│                                                                 │
│ 2. CONTENER                                                     │
│    □ Bloquear IP sospechosa: fail2ban-client set sshd banip X  │
│    □ Desconectar sesión: pkill -u <usuario>                    │
│    □ Aislar red: ufw deny from <IP>                            │
│                                                                 │
│ 3. ERRADICAR                                                    │
│    □ Matar procesos maliciosos                                 │
│    □ Eliminar archivos sospechosos                             │
│    □ Rotar credenciales comprometidas                          │
│                                                                 │
│ 4. RECUPERAR                                                    │
│    □ Restaurar desde backup limpio                             │
│    □ Revisar configuraciones                                   │
│    □ Actualizar sistema                                        │
│                                                                 │
│ 5. DOCUMENTAR                                                   │
│    □ Guardar logs del incidente                                │
│    □ Documentar timeline                                       │
│    □ Implementar mejoras preventivas                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## ✅ Resumen de Seguridad

| Capa | Componente | Estado | Cobertura |
|------|------------|--------|-----------|
| Perímetro | Caddy reverse proxy | ✅ Activo | 100% |
| Transporte | TLS 1.3 | ✅ Activo | 100% |
| Autenticación | Authelia SSO+MFA | ✅ Activo | Todos los servicios |
| Red | Tailscale VPN | ✅ Activo | Acceso admin |
| Intrusión | Fail2ban | ✅ Activo | SSH, Nextcloud |
| Secrets | Vault | ⚠️ Inactivo | Pendiente activar |
| Logs | Centralizados | ✅ Activo | Todos los servicios |

---

## 🔮 Mejoras Futuras

1. **Activar Vault**: Migrar todos los secretos a Vault
2. **WAF**: ModSecurity para protección aplicación
3. **SIEM**: ELK Stack para correlación de logs
4. **Backups cifrados**: Cifrar backups con age/gpg
5. **Container security**: Scan de vulnerabilidades en imágenes
6. **Zero Trust Network Access**: Reemplazar VPN con ZTNA
