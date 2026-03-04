# Topología de Red

## 📋 Introducción

Este documento describe la **topología de red real** del servidor Nextcloud, explicando cómo fluyen los datos desde Internet hasta los servicios backend, y qué tecnologías hacen posible la comunicación segura.

---

## 🌐 Interfaces de Red

### Visión General

El servidor tiene **5 interfaces de red** activas:

```
┌─────────────────────────────────────────────────────────────────┐
│                        INTERFACES DE RED                         │
├──────────────┬───────────────────────┬──────────────────────────┤
│ Interfaz     │ IP Address            │ Propósito                │
├──────────────┼───────────────────────┼──────────────────────────┤
│ lo           │ 127.0.0.1             │ Loopback (local)         │
│ eth0         │ 46.224.204.126        │ Red pública (Hetzner)    │
│ eth0         │ 2a01:4f8:1c19:1cb3::1 │ IPv6 público             │
│ tailscale0   │ 100.77.1.30           │ VPN mesh (Tailscale)     │
│ tailscale0   │ fd7a:115c:a1e0::...   │ IPv6 VPN                 │
│ docker0      │ 172.17.0.1/16         │ Docker bridge (unused)   │
│ br-0c3ba...  │ 172.18.0.1/16         │ Docker bridge (unused)   │
└──────────────┴───────────────────────┴──────────────────────────┘
```

---

## 🔌 Interface 1: eth0 - Red Pública

### ¿Qué es una IP pública?

Una **IP pública** es una dirección única en Internet que permite:
- Que cualquier dispositivo en Internet pueda conectarse
- Ser accesible desde cualquier lugar del mundo
- Recibir tráfico sin restricciones de NAT

### Configuración Real

```
Interface: eth0
IPv4: 46.224.204.126/32
IPv6: 2a01:4f8:1c19:1cb3::1/64
Gateway: 172.31.1.1 (Hetzner cloud router)
Provider: Hetzner Online GmbH
Location: Falkenstein (FSN1), Germany
```

### ¿Por qué /32 en IPv4?

La máscara `/32` indica que el servidor tiene **una sola IP** asignada, no un rango. Hetzner Cloud usa **enrutamiento point-to-point**:
- No hay subred local
- El gateway se alcanza via proxy ARP
- Más eficiente en entornos cloud

### ¿Por qué IPv6?

| Ventaja | Descripción |
|---------|-------------|
| **Espacio ilimitado** | 340 undecillones de direcciones |
| **Sin NAT** | Conexión directa, sin traducción |
| **Mejor seguridad** | IPs únicas facilitan filtrado |
| **Futuro** | IPv4 se agotó en 2019 |

---

## 🔒 Interface 2: tailscale0 - VPN Mesh

### ¿Qué es una VPN Mesh?

Una **VPN mesh** conecta dispositivos como si estuvieran en la misma red local, sin importar su ubicación física:

```
┌─────────────────────────────────────────────────────────────────┐
│                    TAILSCALE MESH NETWORK                        │
│                    tail6c9810.ts.net                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────┐       ┌─────────────────┐                │
│   │ hetzner-server  │◄─────►│   mini-macOS    │                │
│   │ 100.77.1.30     │       │  100.77.1.10    │                │
│   │ ONLINE          │       │ ONLINE          │                │
│   └─────────────────┘       └─────────────────┘                │
│           ▲                                                    │
│           │                                                    │
│   ┌───────┴───────┬───────────────┬───────────────┐           │
│   │               │               │               │           │
│   ▼               ▼               ▼               ▼           │
│ ┌─────────┐ ┌─────────────┐ ┌───────────┐ ┌──────────────┐   │
│ │ Pixel   │ │ Samsung S9  │ │ XiaomiPad │ │ (otros)      │   │
│ │100.77.  │ │ 100.77.     │ │ 100.77.   │ │              │   │
│ │ 1.21    │ │ 1.22        │ │ 1.23      │ │              │   │
│ │ OFFLINE │ │ OFFLINE     │ │ OFFLINE   │ │              │   │
│ └─────────┘ └─────────────┘ └───────────┘ └──────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### ¿Cómo funciona Tailscale?

1. **Control Plane**: Servidores de Tailscale coordinan la red
2. **DERP Servers**: Relay servers para atravesar NAT
3. **WireGuard**: Protocolo de cifrado en el data plane
4. **Direct Connect**: Intenta conexión peer-to-peer directa

### ¿Por qué WireGuard?

| Protocolo | Velocidad | Latencia | Handshake |
|-----------|-----------|----------|-----------|
| OpenVPN | Lento | 50-100ms | 2-3 segundos |
| IPsec | Medio | 30-50ms | 1-2 segundos |
| **WireGuard** | **Rápido** | **<10ms** | **<0.5 segundos** |

### Beneficios del Mesh VPN

```
┌────────────────────────────────────────────────────────────────┐
│                    SIN VPN MESH                                 │
├────────────────────────────────────────────────────────────────┤
│ Servidor: 46.224.204.126:22 → Expuesto a ataques SSH           │
│ Acceso: Requiere IP en allowlist o VPN tradicional             │
│ Seguridad: Puerto SSH público visible en escaneos              │
└────────────────────────────────────────────────────────────────┘
                              vs
┌────────────────────────────────────────────────────────────────┐
│                    CON TAILSCALE MESH                           │
├────────────────────────────────────────────────────────────────┤
│ Servidor: 100.77.1.30:22 → Solo accesible desde red Tailscale  │
│ Acceso: Cualquier dispositivo autorizado en la red             │
│ Seguridad: Puerto SSH cerrado al público, solo VPN             │
└────────────────────────────────────────────────────────────────┘
```

---

## 🐳 Interfaces 3-4: docker0 y br-*

### ¿Qué es Docker Bridge?

**Docker bridge** es una red virtual creada por Docker para contenedores:
- Cada contenedor obtiene una IP privada
- Los contenedores se comunican entre sí
- El host actúa como router

### Estado Real

```
docker0: 172.17.0.1/16 (created by Docker daemon)
br-0c3ba39aebe7: 172.18.0.1/16 (created by Docker Compose)
Status: No containers running
```

### ¿Por qué están vacíos?

Los servicios actuales están instalados **nativamente** (systemd), no en Docker:
- Caddy: `apt install caddy`
- Apache: `apt install apache2`
- MySQL: `apt install mysql-server`
- Redis: `apt install redis-server`

---

## 🔄 Reverse Proxy Pattern

### ¿Qué es un Reverse Proxy?

Un **reverse proxy** es un servidor que actúa como intermediario:
- Recibe peticiones del cliente
- Las reenvía a servidores backend apropiados
- Devuelve la respuesta al cliente

```
┌─────────────────────────────────────────────────────────────────┐
│                    SIN REVERSE PROXY                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Usuario ──────────► Puerto 8080 ─────► Apache/Nextcloud      │
│              (expuesto)           (sin HTTPS)                   │
│                                                                 │
│   Problemas:                                                    │
│   • Puerto 8080 expuesto a Internet                            │
│   • Sin HTTPS automático                                        │
│   • Sin autenticación centralizada                             │
│   • Cada servicio en su propio puerto                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              vs
┌─────────────────────────────────────────────────────────────────┐
│                    CON REVERSE PROXY (CADDY)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Usuario ──► Caddy:443 ──┬──► localhost:8080 (Nextcloud)      │
│              (HTTPS)       ├──► localhost:9091 (Authelia)       │
│                            ├──► localhost:3000 (Grafana)        │
│                            └──► localhost:8200 (Vault)          │
│                                                                 │
│   Ventajas:                                                     │
│   ✓ Solo puerto 443 expuesto                                   │
│   ✓ HTTPS automático (Let's Encrypt)                           │
│   ✓ Autenticación centralizada (forward_auth)                  │
│   ✓ Nombres de host virtuales                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Configuración Real de Rutas

| Host | Backend | Autenticación |
|------|---------|---------------|
| `nextcloud.alvarezconsult.es` | `localhost:8080` | Authelia SSO |
| `nextcloud-authelia.alvarezconsult.es` | `localhost:9091` | Directo (login) |
| `nextcloud-grafana.alvarezconsult.es` | `localhost:3000` | Authelia SSO |
| `nextcloud-vault.alvarezconsult.es` | `localhost:8200` | Authelia SSO |

---

## 🔀 Forward Auth: Autenticación Delegada

### ¿Qué es forward_auth?

`forward_auth` es un patrón donde el reverse proxy **delega autenticación** a un servicio externo:

```
┌─────────────────────────────────────────────────────────────────┐
│                  FLUJO DE AUTENTICACIÓN                          │
└─────────────────────────────────────────────────────────────────┘

1. Usuario solicita https://nextcloud.alvarezconsult.es
   │
   ▼
2. Caddy recibe la petición en puerto 443
   │
   ▼
3. forward_auth: Caddy envía verificación a Authelia
   │
   ├───► GET http://localhost:9091/api/verify?rd=...
   │
   ▼
4. Authelia verifica sesión
   │
   ├───► Si NO autenticado: 302 Redirect → https://nextcloud-authelia.alvarezconsult.es/
   │
   └───► Si autenticado: 200 OK + headers de usuario
   │
   ▼
5. Caddy continúa con la petición original
   │
   ▼
6. Request llega a Nextcloud (localhost:8080)
   │
   ▼
7. Usuario ve su dashboard de Nextcloud
```

### Headers Inyectados por Authelia

```http
Remote-User: rubenalvarezdev
Remote-Name: Ruben Alvarez
Remote-Email: ruben@alvarezconsult.es
Remote-Groups: admins,users
```

---

## 📡 Flujo de Red Completo

### Escenario: Usuario accede a Nextcloud

```
┌─────────────────────────────────────────────────────────────────┐
│ INTERNET                                                         │
│ Usuario en Barcelona, España                                    │
│ IP: 83.45.xxx.xxx                                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTPS (TLS 1.3)
                           │ GET /apps/dashboard/
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ DNS (Cloudflare)                                                 │
│ nextcloud.alvarezconsult.es → 46.224.204.126                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ HETZNER FSN1 DATACENTER (Falkenstein, Germany)                  │
│ Server: vpn-ruben-nextcloud-hetzner                             │
│ Public IP: 46.224.204.126                                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ CADDY (Reverse Proxy)                                           │
│ Puerto: 443                                                      │
│ - TLS termination (Let's Encrypt cert)                          │
│ - forward_auth check                                            │
└──────┬──────────────────────────────────────────────────────────┘
       │ forward_auth check
       ▼
┌─────────────────────────────────────────────────────────────────┐
│ AUTHELIA (SSO/MFA)                                               │
│ Puerto: 9091 (localhost only)                                   │
│ - Verifica sesión JWT                                           │
│ - Retorna 200 OK + headers de usuario                           │
└─────────────────────────────────────────────────────────────────┘
       │
       ▼ proxy_pass
┌─────────────────────────────────────────────────────────────────┐
│ APACHE + PHP-FPM (Application Server)                           │
│ Puerto: 8080 (localhost only)                                   │
│ - Procesa PHP                                                   │
│ - Conecta a MySQL y Redis                                      │
└──────┬───────────────────┬──────────────────────────────────────┘
       │                   │
       ▼                   ▼
┌─────────────┐    ┌─────────────┐
│   MYSQL     │    │   REDIS     │
│   :3306     │    │   :6379     │
└─────────────┘    └─────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│ HETZNER STORAGE BOX (External)                                  │
│ Mount: /mnt/storage-ruben + /mnt/storage-manuel                │
│ Protocol: CIFS/SMB 3.1.1                                        │
│ Total: 10TB (2x 5TB)                                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛡️ Acceso Administrativo (Tailscale)

### Flujo: Administrador accede por SSH

```
┌─────────────────────────────────────────────────────────────────┐
│ MacBook Pro (Madrid, España)                                    │
│ Tailscale IP: 100.77.1.10                                       │
│ Usuario: ruben                                                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ ssh ruben@100.77.1.30
                           │ (WireGuard encrypted tunnel)
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ TAILSCALE COORDINATION SERVER (control plane)                   │
│ - Authentica el usuario                                         │
│ - Facilita WireGuard handshake                                  │
│ - No ve el tráfico (E2E encrypted)                             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼ Direct P2P or via DERP relay
┌─────────────────────────────────────────────────────────────────┐
│ HETZNER SERVER                                                   │
│ Tailscale IP: 100.77.1.30                                       │
│ sshd listening on: 100.77.1.30:22 (NOT on public IP)           │
└─────────────────────────────────────────────────────────────────┘
```

### Ventajas de este enfoque

```
┌────────────────────────────────────────────────────────────────┐
│ SSH Tradicional (Puerto 22 público)                            │
├────────────────────────────────────────────────────────────────┤
│ Exposición: IP pública accesible desde cualquier lugar         │
│ Ataques: Miles de intentos de fuerza bruta diarios             │
│ Log spam: auth.log lleno de intentos fallidos                  │
│ Riesgo: Si contraseña débil → comprometido                     │
└────────────────────────────────────────────────────────────────┘
                              vs
┌────────────────────────────────────────────────────────────────┐
│ SSH via Tailscale (Puerto 22 solo en VPN)                      │
├────────────────────────────────────────────────────────────────┤
│ Exposición: Solo accesible desde red Tailscale autorizada      │
│ Ataques: 0 (puerto cerrado al público)                         │
│ Logs: Solo accesos legítimos                                   │
│ Seguridad: Requiere autenticación Tailscale + SSH key          │
└────────────────────────────────────────────────────────────────┘
```

---

## 📊 Puertos Abiertos

### Desde Internet

```
┌─────────────────────────────────────────────────────────────────┐
│ PUERTOS EXPUESTOS A INTERNET                                    │
├─────────┬───────────┬───────────────────────────────────────────┤
│ Puerto  │ Servicio  │ Propósito                                │
├─────────┼───────────┼───────────────────────────────────────────┤
│ 22      │ sshd      │ SSH (recomendado cerrar si solo Tailscale)│
│ 80      │ Caddy     │ HTTP → redirect a HTTPS                  │
│ 443     │ Caddy     │ HTTPS (reverse proxy principal)          │
└─────────┴───────────┴───────────────────────────────────────────┘
```

### Localhost Only (no accesibles desde Internet)

```
┌─────────────────────────────────────────────────────────────────┐
│ PUERTOS SOLO LOCALHOST                                          │
├─────────┬───────────┬───────────────────────────────────────────┤
│ Puerto  │ Servicio  │ Propósito                                │
├─────────┼───────────┼───────────────────────────────────────────┤
│ 8080    │ Apache    │ Nextcloud web server                     │
│ 3000    │ Grafana   │ Dashboard de monitoreo                   │
│ 3306    │ MySQL     │ Base de datos                            │
│ 6379    │ Redis     │ Cache en memoria                        │
│ 8200    │ Vault     │ Gestión de secretos                     │
│ 9091    │ Authelia  │ SSO/MFA server                          │
│ 9090    │ Prometheus│ Métricas (si está activo)                │
└─────────┴───────────┴───────────────────────────────────────────┘
```

---

## 🔗 Conclusión

La topología de red implementada sigue el principio de **defensa en profundidad**:

1. **Capa de Perímetro**: Solo puertos 80/443 expuestos
2. **Capa de Transporte**: TLS 1.3 obligatorio
3. **Capa de Aplicación**: Reverse proxy + autenticación SSO
4. **Capa de Red Interna**: Servicios backend en localhost
5. **Capa de Acceso Admin**: VPN mesh para gestión

### Próximos Pasos Recomendados

- [ ] Cerrar puerto 22 público (solo acceso via Tailscale)
- [ ] Implementar firewall con UFW
- [ ] Configurar IPv6 en todos los servicios
- [ ] Añadir WireGuard directo como backup de Tailscale
