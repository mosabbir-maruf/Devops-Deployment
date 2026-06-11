# Production Reverse Proxy With Docker Shared Network

## Table Of Contents

### Architecture

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Why A Dedicated Reverse Proxy Layer](#3-why-a-dedicated-reverse-proxy-layer)
4. [How Port Sharing Works](#4-how-port-sharing-works)

### Shared Network

5. [Shared Docker Network](#5-shared-docker-network)
6. [How Containers Communicate](#6-how-containers-communicate)

### Setup

7. [Folder Structure](#7-folder-structure)
8. [Reverse Proxy Docker Compose](#8-reverse-proxy-docker-compose)
9. [Nginx Configuration](#9-nginx-configuration)
10. [Certbot Setup And SSL](#10-certbot-setup-and-ssl)

### Cloudflare Integration

11. [Cloudflare Integration](#11-cloudflare-integration)
12. [Certificate Generation Workflow](#12-certificate-generation-workflow)

### Multi Project Deployment

13. [Multi Project Architecture](#13-multi-project-architecture)
14. [Adding New Projects](#14-adding-new-projects)
15. [Project Docker Compose Example](#15-project-docker-compose-example)

### Security

16. [Security Best Practices](#16-security-best-practices)

### Operations

17. [Common Mistakes](#17-common-mistakes)
18. [Troubleshooting Checklist](#18-troubleshooting-checklist)
19. [Useful Commands](#19-useful-commands)
20. [Production Deployment Checklist](#20-production-deployment-checklist)

### CI/CD And Registry

21. [GitHub Actions To GHCR To VPS Deployment Flow](#21-github-actions-to-ghcr-to-vps-deployment-flow)
22. [Container Registry Retention Policy](#22-container-registry-retention-policy)

### Backup And Availability

23. [Persistent Volume Backup Strategy](#23-persistent-volume-backup-strategy)
24. [Zero-Downtime Deployment Strategy](#24-zero-downtime-deployment-strategy)
25. [Production Health Check Standards](#25-production-health-check-standards)

### Architecture Summary

26. [Final Production Architecture](#26-final-production-architecture)
27. [Reverse Proxy Rules](#27-reverse-proxy-rules)

### Monitoring And Alerting

28. [Monitoring And Alerting](#28-monitoring-and-alerting)

### Disaster Recovery

29. [Disaster Recovery](#29-disaster-recovery)

### Production Recommendations

30. [Recommended Production Stack](#30-recommended-production-stack)

---

# 1. Overview

This document covers a **production-grade Docker-based Reverse Proxy Architecture** for hosting multiple projects on a single VPS.

It differs from `11-nginx-reverse-proxy.md` by treating the reverse proxy as a **centralized infrastructure layer** — separate from individual project stacks — using a shared Docker network.

```txt
┌─────────────────────────────────────────────────────┐
│                   Internet                           │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│                   Cloudflare                         │
│              (DNS + DDoS + SSL edge)                 │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│              Nginx Reverse Proxy                     │
│              (ports 80 / 443 only)                   │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│              Shared Docker Network                   │
│              (shared-network)                        │
└──┬───────────────┬───────────────┬───────────────────┘
   │               │               │
   ▼               ▼               ▼
┌────────┐   ┌──────────┐   ┌──────────┐
│Project │   │ Project  │   │ Project  │
│   A    │   │    B     │   │    C     │
│        │   │          │   │          │
│ app    │   │ app      │   │ app      │
│ backend│   │ backend  │   │ backend  │
│ db     │   │ db       │   │ db       │
└────────┘   └──────────┘   └──────────┘
```

Key principle:

```txt
One Nginx instance
One shared network
Multiple independent projects
No port conflicts
```

---

# 2. Architecture

## High Level Flow

```txt
User Browser
     │
     │ https://gateway.animewarp.app
     ▼
Cloudflare (proxy: proxied)
     │
     │ Full (strict) SSL
     ▼
VPS :443
     │
     ▼
Nginx Reverse Proxy Container
     │
     │ matches server_name
     │ resolves upstream via Docker DNS
     ▼
Shared Docker Network (shared-network)
     │
     ├──→ gateway.animewarp.app  →  gateway-app:3000
     │
     ├──→ api.animewarp.app      →  api-app:5000
     │
     └──→ admin.animewarp.app    →  admin-app:4000
```

## Port Allocation

```txt
Public (UFW open):
  80/tcp   → Nginx reverse proxy (HTTP → HTTPS redirect)
  443/tcp  → Nginx reverse proxy (HTTPS)
  SSH      → custom port (e.g. 1182)

NOT publicly exposed:
  3000     → project frontends
  5000     → project backends
  5432     → PostgreSQL
  6379     → Redis
  27017    → MongoDB
```

## DNS Mapping

```txt
gateway.animewarp.app  A → VPS_IP (proxied by Cloudflare)
api.animewarp.app      A → VPS_IP (proxied by Cloudflare)
admin.animewarp.app    A → VPS_IP (proxied by Cloudflare)
```

---

# 3. Why A Dedicated Reverse Proxy Layer

## Without A Dedicated Proxy

```txt
Project A:  nginx on :80, app on :3000
Project B:  nginx on :8080, app on :4000
Project C:  nginx on :8081, app on :5000

Problems:
- port conflicts between projects
- multiple SSL certs managed independently
- fragmented configuration across project folders
- hard to add new projects without disrupting existing ones
```

## With A Dedicated Proxy

```txt
Reverse Proxy Nginx:  :80, :443
  ├── Project A  →  internal port (no public exposure)
  ├── Project B  →  internal port (no public exposure)
  └── Project C  →  internal port (no public exposure)

Benefits:
- single entry point for all traffic
- one SSL termination point
- no port conflicts between projects
- centralized logging and monitoring
- easier security audits (one config to review)
- new projects: add one config file, no port management
```

## Comparison

| | Without Dedicated Proxy | With Dedicated Proxy |
|--|------------------------|---------------------|
| Port management | complex, conflicts likely | clean, single :80/:443 |
| SSL | per-project certbot | centralized certbot |
| Config | scattered across projects | one reverse-proxy/ folder |
| Adding projects | modify existing stack | add config + network attach |
| Security | inconsistent, easy to miss | enforced at proxy layer |

---

# 4. How Port Sharing Works

Multiple applications share ports **80** and **443** through the reverse proxy.

## Without Reverse Proxy

```txt
Can't do:
  gateway.animewarp.app  → :80 → container A :80
  api.animewarp.app      → :80 → container B :80

Only one container can bind :80 on the host.
```

## With Reverse Proxy

```txt
Nginx binds :80 and :443 on the host.

All other containers expose NO public ports.

Nginx uses server_name to route:
  server_name gateway.animewarp.app  → proxy_pass http://gateway-app:3000
  server_name api.animewarp.app      → proxy_pass http://api-app:5000
  server_name admin.animewarp.app    → proxy_pass http://admin-app:4000
```

## server_name Matching

Nginx inspects the `Host` header in the incoming HTTP request and routes to the matching `server_name` block. This mechanism is called **virtual hosting** and is how a single Nginx instance serves hundreds of domains from one IP address.

---

# 5. Shared Docker Network

A shared Docker network is the key to linking the reverse proxy with all projects.

## Why A Shared Network

Each Docker Compose stack creates its own default network. Containers on different networks cannot communicate with each other.

A pre-created shared network allows:

```txt
Reverse Proxy Container
     │
     ▼
shared-network
     │
     ├── Project A containers
     ├── Project B containers
     └── Project C containers
```

## Create The Network

```bash
docker network create \
  --driver bridge \
  --attachable \
  shared-network
```

`--attachable` allows standalone containers (not just Compose services) to join the network.

## Verify

```bash
docker network ls
```

Expected:

```txt
NETWORK ID     NAME              DRIVER    SCOPE
abc12345       shared-network    bridge    local
```

## Important

The network must be created **before** any container that uses it. Run this command once during initial VPS setup.

---

# 6. How Containers Communicate

## Docker DNS Resolution

Containers on the same Docker network resolve each other by **service name** (when using Compose) or **container name** (when using `docker run` with `--name`).

```txt
Nginx container
     │
     │ ping gateway-app
     │ ping api-app
     ▼
Docker DNS (built-in resolver at 127.0.0.11)
     │
     │ resolves gateway-app → 172.19.0.5
     │ resolves api-app     → 172.19.0.8
     ▼
Target container
```

## Nginx Upstream

In the Nginx config, use the **container name** of the target project (not localhost, not IP):

```nginx
server {
    server_name gateway.animewarp.app;

    location / {
        proxy_pass http://gateway-app:3000;
    }
}
```

Here `gateway-app` must be the `container_name` set in the project's `docker-compose.yml`. Docker DNS resolves container names on the same network.

### Production Best Practice: Service Names

For production deployments, **Docker Compose service names** are preferred over explicit `container_name`:

```yaml
services:
  app:           # ← service name
    # no container_name needed
```

Then in Nginx:

```nginx
proxy_pass http://app:3000;   # ← service name, not container name
```

Benefits of using service names:

```txt
✓ Docker DNS resolves service names automatically on a Compose network
✓ Easier horizontal scaling (multiple replicas behind the same service name)
✓ Better Compose portability (no hardcoded names across environments)
✓ Avoids unnecessary coupling between Compose files and Nginx config
```

However, for **simple single-instance deployments**, explicit `container_name` (as used in this document's examples) is perfectly acceptable and may be easier for beginners to understand. The key requirement is that whatever name is used in `proxy_pass` must match what Docker DNS resolves — whether that is a service name or a `container_name`.

## Why Not localhost

```txt
localhost inside the Nginx container → the Nginx container itself
localhost inside the app container   → the app container itself

They are different containers.
They need to communicate over the Docker network.
Use the container_name of the target container.
```

## Network Connectivity Test

```bash
docker exec reverse-proxy-nginx ping gateway-app
```

If ping succeeds, network communication works.

---

# 7. Folder Structure

## On The VPS

```txt
/var/www/reverse-proxy/
├── docker-compose.yml
├── nginx/
│   ├── nginx.conf
│   ├── sites/
│   │   ├── gateway.animewarp.app.conf
│   │   ├── api.animewarp.app.conf
│   │   ├── admin.animewarp.app.conf
│   │   └── default.conf
│   └── includes/
│       ├── cloudflare-real-ip.conf
│       ├── security-headers.conf
│       └── ssl-params.conf
├── certbot/
│   ├── conf/
│   │   └── live/
│   │       └── (Let's Encrypt certificates)
│   └── www/
│       └── (ACME challenge files)
├── monitoring/
│   ├── uptime-kuma/
│   │   └── docker-compose.yml
│   └── prometheus/
│       └── prometheus.yml
└── scripts/
    ├── renew-certs.sh
    └── check-proxy.sh
```

## Folder Descriptions

### docker-compose.yml

The Docker Compose file for the reverse proxy stack. Contains nginx and certbot services.

### nginx/nginx.conf

The main Nginx configuration file. Sets global settings (SSL, gzip, security, logging) and includes site files from `sites/`.

### nginx/sites/

One configuration file per project domain. Each file contains `server` blocks with `server_name`, SSL certificate paths, and `proxy_pass` upstream.

### nginx/includes/

Reusable config fragments included by site configs. Keeps site files clean and consistent.

### certbot/conf/

Persistent Let's Encrypt certificate data. Bound to certbot container and mounted read-only by Nginx.

### certbot/www/

ACME challenge files served on port 80 during certificate issuance and renewal.

### monitoring/

Optional monitoring stack (Uptime Kuma, Prometheus) for production observability.

### scripts/

Helper shell scripts for certificate renewal and diagnostics.

---

# 8. Reverse Proxy Docker Compose

## Full docker-compose.yml

```yaml
services:
  nginx:
    image: nginx:1.27-alpine
    container_name: reverse-proxy-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/sites:/etc/nginx/sites:ro
      - ./nginx/includes:/etc/nginx/includes:ro
      - ./certbot/conf:/etc/letsencrypt:ro
      - ./certbot/www:/var/www/certbot:ro
    networks:
      - shared-network
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  certbot:
    image: certbot/certbot:v2.9.0
    container_name: reverse-proxy-certbot
    restart: unless-stopped
    entrypoint: ["sleep", "infinity"]
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    networks:
      - shared-network

networks:
  shared-network:
    external: true
    name: shared-network
```

## Changes From Earlier Patterns

```txt
✓ nginx:1.27-alpine (pinned minor version, not :alpine latest)
✓ certbot/certbot:v2.9.0 (pinned, not :latest)
✓ nginx/includes/ added for modular config includes
✓ logging block added with rotation limits
✓ --attachable used on network creation
✓ network named shared-network (consistent across all projects)
```

## Service Breakdown

### nginx

| Setting | Value | Why |
|---------|-------|-----|
| image | nginx:1.27-alpine | Pinned minor version, production-hardened |
| ports | 80:80, 443:443 | Only public entry points on the VPS |
| volumes | configs + includes + certs | All read-only for immutability |
| network | shared-network | Must match pre-created shared network |
| logging | json-file, max 3 files x 10 MB | Prevents log disk exhaustion |

### certbot (Long-Running Approach)

| Setting | Value | Why |
|---------|-------|-----|
| image | certbot/certbot:v2.9.0 | Pinned version, official Let's Encrypt client |
| entrypoint | sleep infinity | Container stays alive for manual cert operations |
| volumes | conf + www | Persists certificates and serves ACME challenges |

## Start The Stack

```bash
cd /var/www/reverse-proxy
docker compose up -d
```

## Verify

```bash
docker compose ps
```

Expected:

```txt
NAME                    IMAGE                 STATUS
reverse-proxy-nginx     nginx:1.27-alpine     Up (healthy)
reverse-proxy-certbot   certbot/certbot       Up
```

---

# 9. Nginx Configuration

## nginx.conf (Main Config)

```nginx
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
pid /var/run/nginx.pid;

error_log /var/log/nginx/error.log warn;

events {
    multi_accept on;
    worker_connections 4096;
    use epoll;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server_tokens off;

    # Log format
    log_format json escape=json '{'
        '"time":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"remote_user":"$remote_user",'
        '"request":"$request",'
        '"status":$status,'
        '"body_bytes":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_status":"$upstream_status",'
        '"http_referrer":"$http_referer",'
        '"http_user_agent":"$http_user_agent",'
        '"http_x_forwarded_for":"$http_x_forwarded_for"'
    '}';

    access_log /var/log/nginx/access.log json buffer=32k flush=5s;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 5;
    gzip_proxied any;
    gzip_disable "msie6";
    gzip_types
        text/plain
        text/css
        text/javascript
        text/xml
        application/json
        application/javascript
        application/xml
        application/rss+xml
        image/svg+xml;

    # SSL global settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;

    # Upstream defaults
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
    proxy_request_buffering off;

    # Buffers
    client_body_buffer_size 128k;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;

    # Upload size
    client_max_body_size 100M;

    # Timeouts
    proxy_connect_timeout 30s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=general:10m rate=50r/s;
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    # Include site configurations
    include /etc/nginx/sites/*.conf;
}
```

## Security Headers Include (nginx/includes/security-headers.conf)

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
```

## Cloudflare Real IP Include (nginx/includes/cloudflare-real-ip.conf)

```nginx
# Cloudflare IPv4
# Fetch current list: curl -s https://www.cloudflare.com/ips-v4
# Update this file when Cloudflare publishes new ranges.
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 104.16.0.0/13;
set_real_ip_from 104.24.0.0/14;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 131.0.72.0/22;

real_ip_header CF-Connecting-IP;
real_ip_recursive on;
```

## SSL Params Include (nginx/includes/ssl-params.conf)

```nginx
ssl_certificate     /etc/letsencrypt/live/SITE_DOMAIN/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/SITE_DOMAIN/privkey.pem;

ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;

ssl_session_cache shared:SSL_SITE:10m;
ssl_session_timeout 1h;

ssl_stapling on;
ssl_stapling_verify on;
resolver 1.1.1.1 8.8.8.8 valid=300s;
resolver_timeout 5s;
```

## Site Configuration (gateway.animewarp.app)

```nginx
server {
    listen 80;
    server_name gateway.animewarp.app;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name gateway.animewarp.app;

    ssl_certificate     /etc/letsencrypt/live/gateway.animewarp.app/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gateway.animewarp.app/privkey.pem;

    include /etc/nginx/includes/security-headers.conf;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    access_log /var/log/nginx/gateway-access.log json;
    error_log  /var/log/nginx/gateway-error.log warn;

    location / {
        proxy_pass http://gateway-app:3000;
    }
}
```

## Site Configuration (api.animewarp.app)

```nginx
server {
    listen 80;
    server_name api.animewarp.app;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name api.animewarp.app;

    ssl_certificate     /etc/letsencrypt/live/api.animewarp.app/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.animewarp.app/privkey.pem;

    include /etc/nginx/includes/security-headers.conf;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    access_log /var/log/nginx/api-access.log json;
    error_log  /var/log/nginx/api-error.log warn;

    limit_req zone=api burst=20 nodelay;

    location / {
        proxy_pass http://api-app:5000;
    }

    location /ws {
        proxy_pass http://api-app:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Default Server Block (Catch-All)

For the default server block, Nginx requires valid SSL certificates even for the `default_server` listening on port 443. A self-signed fallback certificate must be generated before deploying.

```nginx
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

server {
    listen 443 ssl http2 default_server;
    server_name _;

    ssl_certificate     /etc/nginx/ssl/default/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/default/privkey.pem;

    return 444;
}
```

### Generate Self-Signed Fallback Certificate

```bash
mkdir -p /var/www/reverse-proxy/nginx/ssl/default
docker run --rm -v /var/www/reverse-proxy/nginx/ssl/default:/certs alpine sh -c \
  "apk add openssl && openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /certs/privkey.pem -out /certs/fullchain.pem \
  -subj '/CN=localhost'"
```

This certificate is never served to real users (they get `444`), but it allows Nginx to start with a valid SSL default block.

## Modular Structure Explained

```txt
reverse-proxy/nginx/sites/
├── gateway.animewarp.app.conf
├── api.animewarp.app.conf
├── admin.animewarp.app.conf
├── default.conf
└── (future project configs)

reverse-proxy/nginx/includes/
├── cloudflare-real-ip.conf
├── security-headers.conf
└── ssl-params.conf
```

Each domain gets its own file. Adding a new project = adding one file and running `nginx -s reload`.

Nginx's `include /etc/nginx/sites/*.conf` loads all files alphabetically.

## Validate Config

```bash
docker exec reverse-proxy-nginx nginx -t
```

On success:

```txt
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

## Reload Config

```bash
docker exec reverse-proxy-nginx nginx -s reload
```

Reload does not restart the container. New worker processes are spawned with the new config; old workers are drained gracefully.

---

# 10. Certbot Setup And SSL

## Why Let's Encrypt

```txt
✓ Free certificates, no cost barrier
✓ Automated renewal via cron
✓ Trusted by all major browsers
✓ Widely supported across all platforms
✓ 90-day validity forces automation (good practice)
```

## Why Not Manual Certificates

```txt
✗ Manual certs expire silently
✗ No one remembers to renew until the site is down
✗ Not scalable across 3+ projects
✗ No automated rotation possible
```

## Certbot Architecture: Two Valid Approaches

There are two production approaches for running Certbot with the reverse proxy.

### Approach A: Long-Running Certbot Container (Recommended For Simplicity)

```txt
Container stays alive: sleep infinity
Certificates persist in certbot/conf/ volume
Commands executed via docker exec

Pros:
  + Always available for manual certificate operations
  + No container startup delay
  + Simple to understand and operate
  + Certificate volume is always mounted
Cons:
  - One extra always-running container
  - Slightly more resource usage

Implementation:
  entrypoint: ["sleep", "infinity"]
```

### Approach B: On-Demand Certbot Execution (Leaner)

```txt
No long-running certbot container.
Certbot runs only when needed:
  - Certificate issuance
  - Certificate renewal (via cron or systemd timer)

Pros:
  + No always-running container
  + Lower resource footprint
  + Ephemeral execution (no state to manage)
Cons:
  - Each run requires container startup time
  - Docker socket or compose must be available to cron
  - Manual operations require docker run commands

Implementation (cron example):
  0 3 * * * docker run --rm \
    -v /var/www/reverse-proxy/certbot/conf:/etc/letsencrypt \
    -v /var/www/reverse-proxy/certbot/www:/var/www/certbot \
    certbot/certbot:v2.9.0 renew --quiet \
  && docker exec reverse-proxy-nginx nginx -s reload
```

### Recommendation

```txt
Use Approach A (long-running container) for:
  - Teams new to Docker and certbot
  - Environments with frequent certificate operations
  - Manual debugging and troubleshooting

Use Approach B (on-demand) for:
  - Lean production environments
  - Automated-only certificate management
  - Minimal container footprint requirements

This document uses Approach A as the primary reference.
```

## How Certbot Works

```txt
1. Certbot sends a certificate request to Let's Encrypt CA
2. Let's Encrypt challenges domain ownership via HTTP-01
3. Certbot writes the challenge token to certbot/www/
4. Nginx serves the challenge file on port 80
5. Let's Encrypt verifies the token by fetching http://domain/.well-known/acme-challenge/TOKEN
6. Certificate is issued and stored in certbot/conf/
```

## Generate Certificate For A Domain

```bash
docker exec reverse-proxy-certbot certbot certonly \
  --webroot \
  --webroot-path /var/www/certbot \
  -d gateway.animewarp.app \
  -d www.gateway.animewarp.app \
  --email your-email@example.com \
  --agree-tos \
  --non-interactive
```

## Certificate Location

```txt
/var/www/reverse-proxy/certbot/conf/live/gateway.animewarp.app/
├── cert.pem       → server certificate only
├── chain.pem      → intermediate CA certificates
├── fullchain.pem  → cert.pem + chain.pem (use this in Nginx)
├── privkey.pem    → private key (keep secret, chmod 600)
└── README
```

## Certificate Lifecycle

```txt
Issued
  │
  ├── Day 1   → certificate valid
  ├── Day 30  → still valid
  ├── Day 60  → automated renewal attempt via cron
  ├── Day 85  → renewal failed, retry
  └── Day 90  → EXPIRED if renewal unsuccessful

Automatic renewal starting at day 60 provides a 30-day safety margin.
```

## Renew All Certificates Manually

```bash
docker exec reverse-proxy-certbot certbot renew
```

## Automated Renewal (Cron)

```bash
crontab -e
```

Add:

```cron
0 3 * * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --quiet && /usr/bin/docker exec reverse-proxy-nginx nginx -s reload
```

Using absolute paths (`/usr/bin/docker`) ensures cron can find the binary regardless of the shell environment.

This runs daily at 3 AM. Certbot only renews certificates within 30 days of expiry. Nginx reloads only when renewal actually occurs (due to `&&`).

## Verify Certificates

```bash
docker exec reverse-proxy-certbot certbot certificates
```

Expected:

```txt
Found the following certs:
  Certificate Name: gateway.animewarp.app
    Domains: gateway.animewarp.app www.gateway.animewarp.app
    Expiry Date: 2026-09-09 12:00:00+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/gateway.animewarp.app/fullchain.pem
```

## Dry Run Renewal

Test the full renewal process without modifying certificates:

```bash
docker exec reverse-proxy-certbot certbot renew --dry-run
```

### Monthly Verification Recommendation

Add a monthly dry-run to your cron schedule to confirm the renewal pipeline is fully operational:

```cron
0 5 1 * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --dry-run --quiet
```

Purpose:

```txt
✓ Verify the renewal pipeline still works end-to-end
✓ Detect DNS or firewall issues before the real renewal deadline
✓ Confirm Let's Encrypt HTTP-01 validation remains functional
✓ Provides a 30-day early warning window before certificates actually need renewal
```

A failed dry-run will appear in system logs and cron output, allowing you to investigate well before any certificate expires.

---

# 11. Cloudflare Integration

## Architecture With Cloudflare

```txt
User
 │
 │ HTTPS
 ▼
Cloudflare (proxy: proxied)
 │
 │ Full (strict) SSL
 │ Only Cloudflare IPs reach origin
 ▼
Nginx Reverse Proxy (VPS)
 │
 ▼
Application Container
```

## DNS Setup

```txt
Type: A    Name: gateway   Content: VPS_IP   Proxy: Proxied (orange cloud)
Type: A    Name: api       Content: VPS_IP   Proxy: Proxied (orange cloud)
Type: A    Name: admin     Content: VPS_IP   Proxy: Proxied (orange cloud)
```

## Cloudflare SSL/TLS Mode

### During Certificate Generation

```txt
Proxy Status: DNS Only (gray cloud)
Reason: Let's Encrypt needs to reach port 80 directly from the internet.
        Cloudflare proxy would hide the origin IP.
```

**Clarification:** "DNS Only" and "Proxied" are **Proxy Status** settings (the orange/gray cloud toggle in the Cloudflare DNS panel). "Off / Flexible / Full / Full (strict)" are **SSL/TLS Mode** settings (found under Cloudflare → SSL/TLS). These are two separate settings. During certificate generation, set Proxy Status to **DNS Only** (gray cloud). The SSL/TLS Mode setting does not matter at this stage because Cloudflare is not proxying traffic. After the certificate is issued, set Proxy Status back to **Proxied** (orange cloud) and set SSL/TLS Mode to **Full (strict)**.

### After Certificate Generation

```txt
SSL/TLS mode: Full (strict)
Reason: Encrypts traffic between Cloudflare and origin.
        Validates origin certificate matches Let's Encrypt.
```

## Why Full (Strict)

```txt
Off           → HTTP only, no encryption at all
Flexible      → encrypted user↔Cloudflare, HTTP Cloudflare↔Nginx
Full          → encrypted end-to-end, but no origin cert validation
Full (strict) → encrypted end-to-end, origin cert MUST be valid ← RECOMMENDED
```

## Real Certificate Flow

```txt
User
  │ https://gateway.animewarp.app
  ▼
Cloudflare SSL (user → Cloudflare)
  │ Cloudflare presents its own public certificate
  │
  │ Cloudflare → Nginx (Cloudflare → origin)
  │ Full (strict): Cloudflare validates origin certificate
  │ against Let's Encrypt before forwarding
  ▼
Nginx terminates SSL with Let's Encrypt certificate
  │
  ▼
Application (plain HTTP internal)
```

## Real IP Behind Cloudflare

Nginx must see the real visitor IP instead of Cloudflare proxy IPs. Include the Cloudflare IP ranges:

```nginx
include /etc/nginx/includes/cloudflare-real-ip.conf;
```

### Updating Cloudflare IPs

Cloudflare's IP ranges change periodically. Update them periodically:

```bash
curl -s https://www.cloudflare.com/ips-v4
curl -s https://www.cloudflare.com/ips-v6
```

---

# 12. Certificate Generation Workflow

## Step-by-Step

```txt
Step 1:  Set Cloudflare to DNS Only (gray cloud) for the domain
Step 2:  Wait for DNS propagation (dig +short returns VPS IP)
Step 3:  Create the Nginx site config with :80 block only
Step 4:  Validate and reload Nginx (nginx -t && nginx -s reload)
Step 5:  Run certbot certonly --webroot
Step 6:  Verify certificate was issued (certbot certificates)
Step 7:  Add :443 block with SSL to the site config
Step 8:  Validate and reload Nginx
Step 9:  Set Cloudflare back to Proxied (orange cloud)
Step 10: Set Cloudflare SSL to Full (strict)
```

## Quick Commands

```bash
# Steps 3-4
docker exec reverse-proxy-nginx nginx -t
docker exec reverse-proxy-nginx nginx -s reload

# Step 5
docker exec reverse-proxy-certbot certbot certonly \
  --webroot --webroot-path /var/www/certbot \
  -d gateway.animewarp.app --email you@example.com \
  --agree-tos --non-interactive

# Step 8
docker exec reverse-proxy-nginx nginx -s reload
```

## Important

Do not skip the DNS Only step. If Cloudflare proxies traffic during certificate issuance, Let's Encrypt sees Cloudflare's IP address, cannot reach the origin, and the ACME challenge fails with a connection timeout.

---

# 13. Multi Project Architecture

## Three Projects Example

```txt
shared-network
     │
     ├── gateway.animewarp.app
     │   (maps to gateway-app:3000)
     │
     ├── api.animewarp.app
     │   (maps to api-app:5000)
     │
     └── admin.animewarp.app
         (maps to admin-app:4000)
```

## Each Project Is Independent

```txt
/var/www/
├── reverse-proxy/      (central proxy — shared infrastructure)
├── gateway/            (Project A — independent stack)
├── api/                (Project B — independent stack)
└── admin/              (Project C — independent stack)
```

Each project has its own:

```txt
✓ docker-compose.yml
✓ .env (chmod 600)
✓ Dockerfile
✓ GitHub repository
✓ CI/CD pipeline
✓ Persistent volumes
```

## What The Shared Proxy Provides

```txt
✓ Port 80/443 for all projects (single entry point)
✓ SSL termination (centralized certbot)
✓ Centralized Nginx configuration
✓ Consistent security headers and HSTS
✓ Rate limiting for all upstream services
✓ Structured access logs
```

---

# 14. Adding New Projects

## Step-by-Step Workflow

### 1. Deploy The Project

```bash
ssh vps-prod
cd /var/www/my-new-project
docker compose up -d
```

Ensure the project containers are on the shared network:

```yaml
services:
  app:
    image: ghcr.io/yourorg/my-app:${TAG:-latest}
    container_name: my-app
    restart: unless-stopped
    networks:
      - shared-network

networks:
  shared-network:
    external: true
    name: shared-network
```

### 2. Create Nginx Site Config

```bash
nano /var/www/reverse-proxy/nginx/sites/my-new-project.domain.com.conf
```

Write the config with :80 ACME challenge block and :443 SSL proxy block.

### 3. Set Cloudflare DNS Only

Temporarily set the DNS A record to DNS Only (gray cloud).

### 4. Validate And Reload Nginx

```bash
docker exec reverse-proxy-nginx nginx -t
docker exec reverse-proxy-nginx nginx -s reload
```

### 5. Generate Certificate

```bash
docker exec reverse-proxy-certbot certbot certonly \
  --webroot --webroot-path /var/www/certbot \
  -d my-new-project.domain.com \
  --email you@example.com \
  --agree-tos --non-interactive
```

### 6. Add SSL Block

Edit the site config to add the :443 server block with SSL certificate paths and proxy pass.

### 7. Update Cloudflare

```txt
✓ Set DNS back to Proxied (orange cloud)
✓ Set SSL to Full (strict)
```

### 8. Final Validation

```bash
docker exec reverse-proxy-nginx nginx -t
docker exec reverse-proxy-nginx nginx -s reload
curl -I https://my-new-project.domain.com
```

## Checklist For Adding A Project

```txt
✓ Project containers running on shared-network
✓ Nginx site config created in reverse-proxy/nginx/sites/
✓ DNS set to DNS Only temporarily
✓ nginx -t passes
✓ SSL certificate issued via certbot
✓ SSL block added to config
✓ DNS set back to Proxied
✓ Cloudflare SSL set to Full (strict)
✓ nginx -s reload
✓ curl -I https://... returns 200 or 301
✓ Container logs show no errors
```

---

# 15. Project Docker Compose Example

## Project docker-compose.yml

```yaml
services:
  gateway-app:
    image: ghcr.io/yourorg/gateway-app:${TAG:-latest}
    container_name: gateway-app
    restart: unless-stopped
    env_file:
      - .env
    expose:
      - "3000"
    networks:
      - shared-network
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:3000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  postgres:
    image: postgres:17-alpine
    container_name: gateway-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - shared-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  redis:
    image: redis:7-alpine
    container_name: gateway-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - shared-network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 5s
      retries: 3

volumes:
  postgres_data:
  redis_data:

networks:
  shared-network:
    external: true
    name: shared-network
```

## Key Points

```txt
✓ image: ghcr.io/yourorg/... (GHCR, not Docker Hub)
✓ container_name: gateway-app (explicit, used in Nginx proxy_pass)
✓ expose: "3000" (not ports: "3000:3000")
✓ networks includes shared-network (external)
✓ healthcheck on all services with start_period
✓ logging with rotation limits
✓ .env file contains secrets (chmod 600 on VPS)
```

## What NOT To Do In The Project Compose

```yaml
# WRONG — do not bind port 80 or 443 in any project
ports:
  - "80:80"

# WRONG — do not create nginx in project stack
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"

# WRONG — do not use ports instead of expose for app
ports:
  - "3000:3000"

# WRONG — do not create a separate network per project
networks:
  app-network:
    driver: bridge
```

The reverse proxy is the only service that binds ports 80 and 443. Projects must not include their own Nginx or bind public ports.

---

# 16. Security Best Practices

## No Direct App Port Exposure

```txt
✗ Never expose app ports (3000, 5000, 4000) to the internet
✓ Use expose: "PORT" instead of ports: "PORT:PORT"
✓ Only reverse-proxy-nginx binds 80 and 443
```

## HTTPS Only

```txt
✓ All :80 requests redirect to :443
✓ No HTTP-only services behind the proxy
✓ HSTS headers on all domains (max-age=31536000)
✓ Cloudflare Full (strict) SSL
```

## Cloudflare

```txt
✓ All DNS records proxied (orange cloud) in production
✓ WAF enabled (free tier provides SQLi/XSS protection)
✓ DDoS protection active
✓ Only Cloudflare IPs reach origin (block direct IP access)
```

## Firewall

```txt
UFW rules:
  allow 80/tcp
  allow 443/tcp
  allow SSH_PORT/tcp (e.g. 1182)
  deny all other incoming

Verify:
  sudo ufw status verbose
  nmap -p- VPS_IP  → should show only 80, 443, SSH
```

## Container Isolation

```txt
✓ Each project in its own Docker Compose stack
✓ No project depends on another project's service
✓ Shared network provides communication, not coupling
✓ Containers restart automatically (restart: unless-stopped)
✓ Containers run as non-root user where possible
```

## SSL Certificate Security

```txt
✓ Private keys never committed to Git
✓ certbot/conf/ mounted read-only by Nginx
✓ Auto-renewal via cron ensures certs never expire
✓ certbot container has no other exposed services
```

## Rate Limiting

```txt
✓ Global rate limiting in nginx.conf (50 req/s default)
✓ Per-API rate limiting (10 req/s for api.app)
✓ Protects backend from abuse and brute force
```

## Docker Security

```txt
✓ Docker daemon not exposed on TCP (only Unix socket)
✓ No containers run with --privileged
✓ No containers share the host network (network_mode: host)
✓ Image pulls from GHCR are authenticated
```

---

# 17. Common Mistakes

## host not found in upstream

```txt
Error:
  nginx: [emerg] host not found in upstream "gateway-app"

Cause:
  The upstream hostname (gateway-app) is not resolvable on
  the Docker network.

Fix:
  docker compose -f /var/www/gateway/docker-compose.yml ps
    → Is the container running?

  docker network inspect shared-network
    → Is the container listed under Containers?

  Check container_name in project docker-compose.yml
    → Must match the name used in Nginx proxy_pass

  docker exec reverse-proxy-nginx ping gateway-app
    → Does DNS resolve?
```

## nginx Restart Loop

```txt
Error:
  Container reverse-proxy-nginx keeps restarting

Cause:
  Invalid Nginx configuration at startup.

Fix:
  docker logs reverse-proxy-nginx

  Common causes:
  - Missing ssl_certificate file (default block or site block)
  - Syntax error in nginx.conf or site config
  - Port 80 or 443 already in use on the host

  Generate self-signed fallback cert for default block first:
  See section 9 for the openssl command.

  Always run nginx -t before reload:
  docker exec reverse-proxy-nginx nginx -t
```

## Connection Refused During Certbot

```txt
Error:
  Connection refused / Could not connect to server

Cause:
  Port 80 is blocked by firewall or Nginx is not running.

Fix:
  sudo ufw status           → ensure 80/tcp allowed
  docker compose ps         → ensure Nginx is Up
  dig gateway.animewarp.app +short
    → ensure DNS resolves to VPS IP (not Cloudflare IP)
  Set Cloudflare to DNS Only (gray cloud) during issuance
```

## Missing Shared Network

```txt
Error:
  Containers cannot communicate across project stacks

Cause:
  Containers are not on the same Docker network.

Fix:
  docker network ls → confirm shared-network exists
  docker network inspect shared-network
    → list attached containers

  In project docker-compose.yml:
    networks:
      shared-network:
        external: true
        name: shared-network

  docker compose down && docker compose up -d
```

## Wrong DNS Records

```txt
Error:
  Domain resolves to wrong IP or does not resolve

Cause:
  DNS A record points to old server IP or is missing.

Fix:
  dig gateway.animewarp.app +short → check resolved IP
  Update Cloudflare DNS A record to current VPS IP
  Wait for propagation (usually < 5 minutes with Cloudflare)

  Verify:
  curl -I http://gateway.animewarp.app
```

## Cloudflare Full (strict) Without Origin Certificate

```txt
Error:
  525 SSL handshake failed
  526 invalid SSL certificate

Cause:
  Cloudflare Full (strict) requires a valid origin certificate,
  but Nginx has no Let's Encrypt certificate installed.

Fix:
  Set Cloudflare to Full (not strict) temporarily
  Generate Let's Encrypt certificate via certbot
  Set back to Full (strict) after verification
```

## Forgetting To Attach New Containers To Shared Network

```txt
Error:
  Nginx returns 502 Bad Gateway

Cause:
  The project containers were deployed without joining
  shared-network.

Fix:
  Add network configuration to docker-compose.yml
  docker compose down && docker compose up -d
  docker network inspect shared-network
    → verify container appears in the list
```

## Certificates Not Renewing

```txt
Error:
  Browser shows NET::ERR_CERT_DATE_INVALID

Cause:
  Cron job not running or certbot renewal failing silently.

Fix:
  crontab -l → check renewal job exists
  docker exec reverse-proxy-certbot certbot renew --dry-run
    → test renewal process
  Check certbot logs:
    docker exec reverse-proxy-certbot ls -la /var/log/letsencrypt/

  Ensure cron job reloads Nginx after renewal:
  /usr/bin/docker exec reverse-proxy-nginx nginx -s reload

  Use absolute path to docker binary in cron.
```

## Using Wrong Container Name

```txt
Error:
  502 Bad Gateway from Nginx
  nginx: host not found in upstream

Cause:
  Nginx proxy_pass uses service name, not container_name.
  Docker DNS resolves container_name, not Compose service name
  (unless containers are on the same Compose network).

Fix:
  In project docker-compose.yml, set container_name explicitly:
    services:
      app:
        container_name: gateway-app

  In Nginx config, use the container_name:
    proxy_pass http://gateway-app:3000;
```

---

# 18. Troubleshooting Checklist

## Production Troubleshooting Flow

```txt
1.  Is the domain resolving?
    dig gateway.animewarp.app +short

2.  Is the VPS reachable?
    ping VPS_IP

3.  Is port 80 open?
    curl -I http://gateway.animewarp.app

4.  Is port 443 open?
    curl -I https://gateway.animewarp.app

5.  Is Nginx running?
    docker compose -f /var/www/reverse-proxy/docker-compose.yml ps

6.  Is Nginx config valid?
    docker exec reverse-proxy-nginx nginx -t

7.  Are certs valid?
    docker exec reverse-proxy-certbot certbot certificates

8.  Is the target container running?
    docker compose -f /var/www/gateway/docker-compose.yml ps

9.  Is the target container on the shared network?
    docker network inspect shared-network

10. Can Nginx reach the target container?
    docker exec reverse-proxy-nginx ping gateway-app

11. Is the target app listening on the expected port?
    docker exec reverse-proxy-nginx wget -qO- http://gateway-app:3000/health

12. Is Cloudflare proxying correctly?
    dig gateway.animewarp.app +short
    → Cloudflare IPs = proxied (orange cloud)
    → VPS IP = DNS only (gray cloud)

13. Are there recent errors?
    docker logs reverse-proxy-nginx --tail 50
    docker logs reverse-proxy-certbot --tail 50

14. Is the firewall blocking traffic?
    sudo ufw status verbose

15. Is disk space exhausted?
    df -h
    docker system df
```

## Quick Diagnostic Script

Save as `/var/www/reverse-proxy/scripts/check-proxy.sh`:

```bash
#!/bin/bash
DOMAIN=${1:-gateway.animewarp.app}
UPSTREAM=${2:-gateway-app}

echo "=== DNS Resolution ==="
dig $DOMAIN +short

echo "=== HTTP Check ==="
curl -sI http://$DOMAIN | head -1

echo "=== HTTPS Check ==="
curl -sI https://$DOMAIN | head -1

echo "=== Nginx Running ==="
docker compose -f /var/www/reverse-proxy/docker-compose.yml ps

echo "=== Nginx Config ==="
docker exec reverse-proxy-nginx nginx -t 2>&1

echo "=== Target Container ==="
docker exec reverse-proxy-nginx ping -c 1 $UPSTREAM 2>&1 || echo "Ping failed"

echo "=== Certificates ==="
docker exec reverse-proxy-certbot certbot certificates 2>&1 | grep -E "Certificate Name|Expiry"
```

Usage:

```bash
bash /var/www/reverse-proxy/scripts/check-proxy.sh api.animewarp.app api-app
```

---

# 19. Useful Commands

## Network Management

```bash
# Create shared network
docker network create --driver bridge --attachable shared-network

# List networks
docker network ls

# Inspect network (list connected containers)
docker network inspect shared-network

# Remove network (only if no containers attached)
docker network rm shared-network
```

## Reverse Proxy Stack Management

```bash
# Start
docker compose -f /var/www/reverse-proxy/docker-compose.yml up -d

# Stop (preserves containers)
docker compose -f /var/www/reverse-proxy/docker-compose.yml stop

# Stop and remove containers
docker compose -f /var/www/reverse-proxy/docker-compose.yml down

# View logs
docker compose -f /var/www/reverse-proxy/docker-compose.yml logs nginx
docker compose -f /var/www/reverse-proxy/docker-compose.yml logs -f certbot

# Restart Nginx
docker compose -f /var/www/reverse-proxy/docker-compose.yml restart nginx
```

## Nginx Management

```bash
# Validate config
docker exec reverse-proxy-nginx nginx -t

# Reload config (graceful, no downtime)
docker exec reverse-proxy-nginx nginx -s reload

# View full compiled config
docker exec reverse-proxy-nginx nginx -T

# Test connectivity to upstream
docker exec reverse-proxy-nginx ping gateway-app
docker exec reverse-proxy-nginx wget -qO- http://gateway-app:3000/health
docker exec reverse-proxy-nginx getent hosts gateway-app
```

## Certificate Management

```bash
# Generate new certificate
docker exec reverse-proxy-certbot certbot certonly \
  --webroot --webroot-path /var/www/certbot \
  -d gateway.animewarp.app --email you@example.com \
  --agree-tos --non-interactive

# List all certificates
docker exec reverse-proxy-certbot certbot certificates

# Renew all certificates
docker exec reverse-proxy-certbot certbot renew

# Test renewal (dry run)
docker exec reverse-proxy-certbot certbot renew --dry-run

# Delete a certificate
docker exec reverse-proxy-certbot certbot delete \
  --cert-name gateway.animewarp.app
```

## Nginx Logs

```bash
# Follow access logs
docker exec reverse-proxy-nginx tail -f /var/log/nginx/access.log

# Follow error logs
docker exec reverse-proxy-nginx tail -f /var/log/nginx/error.log

# View last 50 error lines
docker exec reverse-proxy-nginx tail -50 /var/log/nginx/error.log

# Container logs with rotation-safe output
docker logs reverse-proxy-nginx --tail 50
docker logs reverse-proxy-nginx -f
```

## DNS

```bash
# Check domain resolution
dig gateway.animewarp.app +short

# Trace DNS path
dig gateway.animewarp.app +trace

# Check if Cloudflare proxy is active
dig gateway.animewarp.app +short
# Cloudflare IP (104.x.x.x, 172.x.x.x) → proxied
# VPS IP → DNS only
```

## UFW Firewall

```bash
# Check firewall status
sudo ufw status verbose

# Allow required ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 1182/tcp

# Deny everything else
sudo ufw default deny incoming
```

## Image And Container Cleanup

```bash
# Remove unused images
docker image prune -a -f

# Remove unused containers, networks, and dangling images
docker system prune -f

# Remove all unused data (including build cache)
docker system prune -a -f

# Check disk usage
docker system df
```

---

# 20. Production Deployment Checklist

## Before Going Live

```txt
✓ Shared Docker network created: shared-network
✓ Reverse proxy Docker Compose deployed and running
✓ nginx.conf configured with:
  - SSL protocols and ciphers
  - Gzip compression
  - Security headers (via include)
  - Rate limiting zones
  - JSON log format with rotation
✓ Default catch-all server block configured with fallback cert
✓ Self-signed fallback SSL certificate generated
✓ UFW allows 80, 443, and SSH port only
✓ All other ports blocked by UFW
✓ docker compose ps shows both services Up
```

## For Each Project

```txt
✓ Project containers running on shared-network
✓ Project docker-compose.yml uses external network
✓ Project containers use expose: (not ports:)
✓ container_name set explicitly in project compose
✓ Nginx site config created for domain
✓ Site config uses correct container_name in proxy_pass
✓ SSL certificate issued via certbot
✓ HTTP → HTTPS redirect configured
✓ Cloudflare DNS set to Proxied (orange cloud)
✓ Cloudflare SSL set to Full (strict)
✓ Cloudflare real IP include configured in Nginx
```

## SSL Verification

```txt
✓ certbot certificates shows valid dates (90 days)
✓ certbot renew --dry-run passes
✓ Cron job set for daily auto-renewal (absolute docker path)
✓ Renewal command includes nginx -s reload
✓ Self-signed fallback exists for default server block
```

## Security Verification

```txt
✓ curl -I http://domain → 301 redirect to HTTPS
✓ curl -I https://domain → 200 OK with HSTS header
✓ curl -I https://VPS_IP → 444 (connection closed)
✓ Nginx version hidden (server_tokens off)
✓ Security headers present (X-Frame-Options, X-Content-Type-Options, etc.)
✓ No app ports leaked (ss -tulpn shows only 80, 443, SSH)
✓ .env files are chmod 600
```

## Monitoring

```txt
✓ docker compose ps shows all containers Up (healthy)
✓ Nginx access logs accessible and structured (JSON)
✓ Certbot logs accessible for debugging
✓ Quick diagnostic script available
✓ Docker image pruning scheduled or monitored
```

## Final Verification

```bash
# Test all domains
for domain in gateway.animewarp.app api.animewarp.app admin.animewarp.app; do
  echo "=== $domain ==="
  dig +short $domain
  curl -sI https://$domain | grep -E "HTTP|strict-transport"
  echo ""
done

# Test certificate renewal
docker exec reverse-proxy-certbot certbot renew --dry-run

# Test Nginx config
docker exec reverse-proxy-nginx nginx -t

# Test connectivity to all upstreams
docker exec reverse-proxy-nginx wget -qO- http://gateway-app:3000/health
docker exec reverse-proxy-nginx wget -qO- http://api-app:5000/health
docker exec reverse-proxy-nginx wget -qO- http://admin-app:4000/health

# Verify no port leaks
sudo ss -tulpn | grep -E ":(3000|5000|4000|5432|6379)" || echo "No leaks detected"
```

---

# 21. GitHub Actions To GHCR To VPS Deployment Flow

## End-To-End Architecture

```txt
Developer pushes code to GitHub
         │
         ▼
GitHub Actions triggered (push to main)
         │
         ├── 1. Checkout code
         ├── 2. Run tests
         ├── 3. Build Docker image
         ├── 4. Tag image (git-sha + latest)
         ├── 5. Push to GHCR (ghcr.io/yourorg/my-app)
         │
         ▼
GitHub Container Registry (GHCR)
         │
         │ Image stored with tags:
         │   ghcr.io/yourorg/my-app:abc123def
         │   ghcr.io/yourorg/my-app:latest
         │
         ▼
SSH into VPS (via GitHub Actions SSH action)
         │
         ├── 1. cd /var/www/my-app
         ├── 2. export TAG=abc123def
         ├── 3. docker compose pull
         ├── 4. docker compose up -d
         ├── 5. docker image prune -f
         │
         ▼
Application updated (zero-downtime if health checks configured)
```

## CI/CD Best Practice: Build On CI, Not On The VPS

### Recommended: Build On GitHub Actions

```txt
GitHub Actions
    │
    ├── Build Docker image
    ├── Push to GHCR
    └── VPS pulls and deploys
```

### Not Recommended: Build On The VPS

```txt
VPS
    │
    ├── git pull source code
    ├── docker build on the server
    └── docker compose up

Issues:
  ✗ Build dependencies installed on production server
  ✗ Build consumes CPU/RAM on the VPS during production hours
  ✗ Build results are not reproducible on a different server
  ✗ No immutable image tag (each build is unique per server)
  ✗ Harder to rollback (no image registry to revert to)
  ✗ VPS disk fills up with build layers and dependencies
```

### Why The CI Build Approach Wins

```txt
✓ Source code never touches the VPS
✓ Build dependencies stay on the CI runner
✓ Production server only runs containers (immutable)
✓ Image is tagged and stored in GHCR
✓ Rollback is a single command: export TAG=previous-sha
✓ VPS disk only stores the final image layers
✓ CI can run tests before building
✓ Same image can be deployed to staging and production
```

## GitHub Actions Workflow (.github/workflows/deploy.yml)

```yaml
name: Build and Deploy

on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:
    inputs:
      tag:
        description: "Override image tag"
        required: false
        default: ""

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
          cache-dependency-path: package-lock.json

      - run: npm ci
      - run: npm test
      - run: npm run build

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=
            type=ref,event=branch
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest

    steps:
      - name: Deploy to VPS
        uses: appleboy/ssh-action@v1.1.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          port: ${{ secrets.VPS_SSH_PORT }}
          script: |
            set -e

            PROJECT_DIR="/var/www/your-project"
            TAG="${{ github.sha }}"

            cd $PROJECT_DIR

            echo "Pulling image: ghcr.io/${{ github.repository }}:$TAG"
            docker compose pull app

            echo "Replacing container..."
            docker compose up -d --no-deps app

            echo "Waiting for health check..."
            sleep 15

            CONTAINER_NAME=$(docker compose ps -q app)
            HEALTH=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME)

            if [ "$HEALTH" = "healthy" ]; then
              echo "Deployment successful. Container is healthy."
              docker image prune -f
            else
              echo "Health check failed. Rolling back..."
              docker compose stop app
              docker compose up -d --no-deps app
              exit 1
            fi
```

## GitHub Secrets Required

```txt
VPS_HOST       → VPS IP address
VPS_USER       → SSH username (e.g. mosabbir)
VPS_SSH_KEY    → SSH private key content (not file path)
VPS_SSH_PORT   → SSH port (e.g. 1182)
```

## VPS Deployment Directory

```txt
/var/www/your-project/
├── docker-compose.yml
├── .env                    # chmod 600
└── nginx/                  # only if project needs extra config
    └── default.conf
```

## docker-compose.yml For GHCR Deployment

```yaml
services:
  app:
    image: ghcr.io/yourorg/your-project:${TAG:-latest}
    container_name: your-project
    restart: unless-stopped
    env_file:
      - .env
    expose:
      - "3000"
    networks:
      - shared-network
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:3000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  shared-network:
    external: true
    name: shared-network
```

## Rollback Strategy

```bash
# Rollback to previous known-good image
export TAG=previous-git-sha
docker compose pull app
docker compose up -d --no-deps app
docker compose ps
```

### Rollback Commands

```txt
To rollback:
  1. Find the previous working git SHA from GitHub
  2. export TAG=<previous-sha>
  3. docker compose pull
  4. docker compose up -d
  5. Verify health endpoint
```

### Automated Rollback In CI/CD

The deploy script above includes automatic rollback: if the health check fails within 15 seconds, it restores the previous container.

## Deployment Verification

```bash
# Run after every deployment
docker compose ps
curl -sf https://your-project.domain.com/health
docker compose logs app --tail 30
```

---

# 22. Container Registry Retention Policy

## Why Clean Up Old Images

```txt
Without cleanup:
  - GHCR storage fills up (billed per GB)
  - VPS disk fills up with old images
  - docker image prune is ineffective if tags exist
  - Unused images clutter the registry and local storage
```

## Retention Policy

```txt
Keep in GHCR:
  - Latest stable image  (tag: latest)
  - Current production   (tag: git-sha)
  - Previous rollback    (tag: previous-git-sha)
  - Keep last 5 releases

Remove from GHCR:
  - All images older than 30 days
  - Untagged orphan images
  - Stale branch builds (merged/deleted branches)

Keep on VPS:
  - Currently running images
  - Previous rollback image (tagged with rollback)

Remove from VPS:
  - All dangling images (no tag)
  - All unused images not referenced by running containers
```

## GHCR Cleanup Strategy

### Using GitHub Actions (Scheduled)

```yaml
name: Clean up GHCR

on:
  schedule:
    - cron: "0 6 * * 0"  # Every Sunday at 6 AM
  workflow_dispatch:       # Manual trigger

jobs:
  cleanup:
    runs-on: ubuntu-latest
    permissions:
      packages: write
      contents: read

    steps:
      - uses: actions/delete-package-versions@v5
        with:
          package-name: "your-project"
          package-type: "container"
          min-versions-to-keep: 5
          delete-only-untagged-versions: true
```

### Manual GHCR Cleanup

```bash
# List all versions of a package
gh api /user/packages/container/your-project/versions

# Delete a specific version
gh api -X DELETE /user/packages/container/your-project/versions/VERSION_ID
```

## VPS Image Cleanup Strategy

### Safe Pruning (Preserves In-Use Images)

```bash
# Remove dangling images only (safe)
docker image prune -f

# Remove all unused images (not used by any container)
docker image prune -a -f
```

### Aggressive Cleanup

```bash
# Remove all unused data (containers, networks, images, build cache)
docker system prune -a -f

# Remove specific old image by tag
docker rmi ghcr.io/yourorg/your-project:old-tag

# Remove images older than 24 hours
docker image prune -a -f --filter "until=24h"
```

## Risks And Best Practices

```txt
Risks:
  - docker image prune -a may remove the rollback image
  - docker system prune -a removes build cache (slows rebuilds)
  - Deleting from GHCR removes the ability to rollback to that version

Best Practices:
  ✓ Keep at least 2 tagged images on VPS (current + previous)
  ✓ Always tag rollback images explicitly:
    docker tag ghcr.io/yourorg/your-app:latest ghcr.io/yourorg/your-app:rollback

  ✓ Run prune only after successful deployment
  ✓ Never prune without checking running containers:
    docker container ls --format '{{.Image}}'

  ✓ In CI/CD, prune after deploy, not before:
    docker compose up -d && docker image prune -f

  ✓ Keep GHCR retention at minimum 5 versions
  ✓ Schedule cleanup weekly (off-peak hours)
```

---

# 23. Persistent Volume Backup Strategy

## Backup Architecture

```txt
Each project has its own persistent volumes:
  /var/lib/docker/volumes/PROJECT_postgres_data/_data
  /var/lib/docker/volumes/PROJECT_redis_data/_data
  /var/lib/docker/volumes/PROJECT_uploads/_data

Backup destinations:
  /var/backups/PROJECT/     (local VPS)
  rsync to offsite          (optional)
  Cloudflare R2 / S3        (optional)
```

## PostgreSQL Backups

### Manual Backup

```bash
# Backup with pg_dump (restorable to any PostgreSQL version)
docker exec gateway-postgres pg_dump \
  -U ${POSTGRES_USER} \
  -d ${POSTGRES_DB} \
  --clean \
  --if-exists \
  --no-owner \
  | gzip > /var/backups/gateway/postgres-$(date +%F-%H%M%S).sql.gz
```

### Automated Backup (Cron)

```cron
0 2 * * * /usr/bin/docker exec gateway-postgres pg_dump -U admin -d gateway --clean --if-exists --no-owner | gzip > /var/backups/gateway/postgres-$(date +\%F).sql.gz && find /var/backups/gateway -name "postgres-*.sql.gz" -mtime +30 -delete
```

Key:

```txt
0 2 * * *              → Daily at 2 AM
-U admin               → PostgreSQL user
gateway                → Database name
--clean --if-exists    → Include DROP statements for clean restore
--no-owner             → Avoid owner mismatch on restore
find ... -mtime +30    → Delete backups older than 30 days
```

### PostgreSQL Restore

```bash
# Restore from backup
gunzip -c /var/backups/gateway/postgres-2026-06-10.sql.gz \
  | docker exec -i gateway-postgres psql -U admin gateway

# Or restore to a clean database:
docker exec -i gateway-postgres dropdb -U admin gateway
docker exec -i gateway-postgres createdb -U admin gateway
gunzip -c /var/backups/gateway/postgres-2026-06-10.sql.gz \
  | docker exec -i gateway-postgres psql -U admin gateway
```

## Redis Backups

Redis persistence writes an AOF (Append Only File) or RDB snapshot to `/data/` inside the container.

### Manual Backup

```bash
# Trigger a background save and copy the dump
docker exec gateway-redis redis-cli BGSAVE
sleep 2
docker cp gateway-redis:/data/dump.rdb \
  /var/backups/gateway/redis-$(date +%F-%H%M%S).rdb
```

### Automated Backup (Cron)

```cron
30 3 * * * /usr/bin/docker exec gateway-redis redis-cli BGSAVE && sleep 5 && cp /var/lib/docker/volumes/gateway_redis_data/_data/dump.rdb /var/backups/gateway/redis-$(date +\%F).rdb && find /var/backups/gateway -name "redis-*.rdb" -mtime +14 -delete
```

### Redis Restore

```bash
# Stop the container, replace data, restart
docker compose stop redis
cp /var/backups/gateway/redis-2026-06-10.rdb \
  /var/lib/docker/volumes/gateway_redis_data/_data/dump.rdb
docker compose up -d redis
```

## MongoDB Backups (If Used)

### Manual Backup

```bash
docker exec gateway-mongo mongodump \
  --username ${MONGO_USER} \
  --password ${MONGO_PASS} \
  --authenticationDatabase admin \
  --out /tmp/mongodump-$(date +%F)

docker cp gateway-mongo:/tmp/mongodump-$(date +%F) \
  /var/backups/gateway/mongodump-$(date +%F)

docker exec gateway-mongo rm -rf /tmp/mongodump-$(date +%F)
```

### MongoDB Restore

```bash
docker cp /var/backups/gateway/mongodump-2026-06-10 gateway-mongo:/tmp/mongodump
docker exec gateway-mongo mongorestore \
  --username ${MONGO_USER} \
  --password ${MONGO_PASS} \
  --authenticationDatabase admin \
  --drop /tmp/mongodump
```

## Upload Storage Backups

### Manual Backup

```bash
docker run --rm \
  -v gateway_uploads:/data \
  -v /var/backups/gateway:/backup \
  alpine tar -czf /backup/uploads-$(date +%F).tar.gz /data
```

### Automated Backup (Cron)

```cron
0 4 * * 0 /usr/bin/docker run --rm -v gateway_uploads:/data -v /var/backups/gateway:/backup alpine tar -czf /backup/uploads-$(date +\%F).tar.gz /data && find /var/backups/gateway -name "uploads-*.tar.gz" -mtime +60 -delete
```

Weekly backup (Sundays at 4 AM), keep 60 days.

### Upload Restore

```bash
docker run --rm \
  -v gateway_uploads:/data \
  -v /var/backups/gateway:/backup \
  alpine tar -xzf /backup/uploads-2026-06-10.tar.gz -C /
```

## SSL Certificate Backups

```txt
Location:
  /var/www/reverse-proxy/certbot/conf/

Why backup:
  Certificate expiration emails go to the registrant email.
  If you lose access to that email, you lose renewal reminders.
  Full backup of certbot/conf/ allows full restoration.

Backup command:
  tar -czf /var/backups/reverse-proxy/certs-$(date +%F).tar.gz \
    -C /var/www/reverse-proxy certbot/conf/

Restore:
  tar -xzf /var/backups/reverse-proxy/certs-YYYY-MM-DD.tar.gz \
    -C /var/www/reverse-proxy
  docker exec reverse-proxy-nginx nginx -s reload
```

### Automated SSL Backup (Cron)

```cron
0 5 1 * * tar -czf /var/backups/reverse-proxy/certs-$(date +\%F).tar.gz -C /var/www/reverse-proxy certbot/conf/ && find /var/backups/reverse-proxy -name "certs-*.tar.gz" -mtime +90 -delete
```

Monthly backup, keep 90 days.

## Backup Retention Policy

```txt
Backup Type     Frequency   Retention    Location
─────────────── ──────────  ───────────  ─────────────────────
PostgreSQL      Daily       30 days      /var/backups/PROJECT/
Redis           Daily       14 days      /var/backups/PROJECT/
MongoDB         Daily       30 days      /var/backups/PROJECT/
Uploads         Weekly      60 days      /var/backups/PROJECT/
SSL Certs       Monthly     90 days      /var/backups/reverse-proxy/
```

## Backup Directory Structure

```txt
/var/backups/
├── gateway/
│   ├── postgres-2026-06-10.sql.gz
│   ├── postgres-2026-06-11.sql.gz
│   ├── redis-2026-06-10.rdb
│   └── uploads-2026-W24.tar.gz
├── api/
│   ├── postgres-2026-06-10.sql.gz
│   └── postgres-2026-06-11.sql.gz
└── reverse-proxy/
    └── certs-2026-06-01.tar.gz
```

---

# 24. Zero-Downtime Deployment Strategy

## Why docker compose down Is Bad In Production

```txt
docker compose down
  → Stops ALL containers
  → Removes the network
  → Application is DOWN

docker compose up -d
  → Starts containers from scratch
  → No overlap → downtime window

Total downtime: 10-60 seconds depending on startup time.
```

## Correct Zero-Downtime Flow

```bash
# Pull new image (download in background, no impact on running containers)
docker compose pull app

# Replace only the app container (others stay running)
docker compose up -d --no-deps app

# New container starts, old one is stopped only after new one is healthy
```

## Proper Deployment Workflow

```txt
Step 1: docker compose pull app
         │
         │ Downloads new image in background
         │ Running container is unaffected
         ▼
Step 2: docker compose up -d --no-deps app
         │
         │ Docker Compose creates a new container from the new image
         │ Old container continues serving traffic during startup
         ▼
Step 3: New container starts
         │
         │ New container attaches to shared-network
         │ New container runs health checks
         ▼
Step 4: Old container is stopped
         │
         │ Docker stops the old container only after:
         │   - New container is running
         │   - Health check passes (if configured)
         ▼
Step 5: Traffic flows to new container
         │
         │ Nginx has already resolved the new container's IP
         │ (Docker DNS is updated immediately)
```

## Why This Works

```txt
docker compose up -d does:
  1. Create a new container (new image)
  2. Start the new container
  3. Wait for it to become healthy
  4. Remove the old container

There is NO point where no container is running.
Requests in flight to the old container complete normally.
New requests are routed to the new container.
```

## With Health Checks

```yaml
services:
  app:
    image: ghcr.io/yourorg/your-project:${TAG:-latest}
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:3000/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
```

When `start_period: 30s` is set, Docker waits 30 seconds before marking a health check as failed. This gives the application time to initialize before Docker decides to restart it.

## Rolling Updates For Multi-Service Stacks

```txt
For stacks with multiple services (app + worker + cron):

  docker compose pull               # Pull all images
  docker compose up -d --no-deps app    # Update app
  docker compose up -d --no-deps worker # Update worker
  docker compose up -d --no-deps cron   # Update cron

Each service is updated independently.
No downtime for the overall system.
```

## Rollback Procedure

```bash
# If deployment fails health checks:
export TAG=previous-git-sha
docker compose pull app
docker compose up -d --no-deps app
```

## Automated Rollback In CI/CD

The deploy script should:

```txt
1. Pull new image
2. Start new container (--no-deps)
3. Wait for health check (max 60 seconds)
4. If healthy: prune old images
5. If unhealthy: stop new container, restart old container
```

---

# 25. Production Health Check Standards

## Why Health Checks Matter

```txt
✓ Docker knows when a container is truly ready
✓ Docker Compose waits for dependencies (depends_on + condition)
✓ Load balancers (Nginx) can route away from unhealthy instances
✓ Zero-downtime deployments rely on health checks
✓ Automatic restart on failure
```

## Health Check Requirements

```txt
Endpoint:  GET /health
Response:  200 OK (status: ok)
Timeout:   < 3 seconds
No auth:   Health check must be unauthenticated
No side effects: Must not modify database or state
```

## Node.js (Express)

```javascript
const express = require("express");
const app = express();

app.get("/health", async (req, res) => {
  const dbHealthy = await checkDatabase();
  const redisHealthy = await checkRedis();

  const status = dbHealthy && redisHealthy ? "healthy" : "degraded";
  const statusCode = dbHealthy && redisHealthy ? 200 : 503;

  res.status(statusCode).json({
    status,
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    database: dbHealthy ? "connected" : "disconnected",
    redis: redisHealthy ? "connected" : "disconnected",
  });
});
```

### Docker Health Check

```yaml
healthcheck:
  test: ["CMD-SHELL", "wget -qO- http://localhost:3000/health || exit 1"]
  interval: 15s
  timeout: 5s
  retries: 3
  start_period: 40s
```

## Next.js

```javascript
// pages/api/health.js
export default async function handler(req, res) {
  try {
    const dbResponse = await fetch(process.env.DATABASE_URL);
    const dbHealthy = dbResponse.ok;

    res.status(dbHealthy ? 200 : 503).json({
      status: dbHealthy ? "healthy" : "degraded",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    });
  } catch (error) {
    res.status(503).json({ status: "unhealthy", error: error.message });
  }
}
```

### Docker Health Check

```yaml
healthcheck:
  test: ["CMD-SHELL", "wget -qO- http://localhost:3000/api/health || exit 1"]
  interval: 15s
  timeout: 5s
  retries: 3
  start_period: 40s
```

## NestJS

```typescript
import { Controller, Get } from "@nestjs/common";
import { HealthCheckService, HealthCheck } from "@nestjs/terminus";

@Controller("health")
export class HealthController {
  constructor(private health: HealthCheckService) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([]);
  }
}
```

### Docker Health Check

```yaml
healthcheck:
  test: ["CMD-SHELL", "wget -qO- http://localhost:5000/health || exit 1"]
  interval: 15s
  timeout: 5s
  retries: 3
  start_period: 40s
```

## PostgreSQL

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 30s
```

pg_isready returns 0 (healthy) or 1 (unhealthy).

## Redis

```yaml
healthcheck:
  test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
  interval: 10s
  timeout: 5s
  retries: 5
```

If Redis is down, `incr ping` fails and the health check fails.

## Health Check Comparison

| Service | Test Command | Port | Interval |
|---------|-------------|------|----------|
| Node.js | `wget -qO- http://localhost:3000/health` | 3000 | 15s |
| Next.js | `wget -qO- http://localhost:3000/api/health` | 3000 | 15s |
| NestJS | `wget -qO- http://localhost:5000/health` | 5000 | 15s |
| PostgreSQL | `pg_isready -U admin -d mydb` | 5432 | 10s |
| Redis | `redis-cli incr ping` | 6379 | 10s |

## Docker Compose With depends_on And Health Checks

```yaml
services:
  app:
    image: ghcr.io/yourorg/your-app:${TAG:-latest}
    container_name: your-app
    restart: unless-stopped
    env_file:
      - .env
    expose:
      - "3000"
    networks:
      - shared-network
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:3000/health || exit 1"]
      interval: 15s
      timeout: 5s
      retries: 3
      start_period: 40s
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  postgres:
    image: postgres:17-alpine
    container_name: your-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - shared-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  redis:
    image: redis:7-alpine
    container_name: your-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - shared-network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  shared-network:
    external: true
    name: shared-network

volumes:
  postgres_data:
  redis_data:
```

---

# 26. Final Production Architecture

## Complete Production Architecture

```txt
                                    INTERNET
                                        │
                                        ▼
                                ┌─────────────────┐
                                │   Cloudflare     │
                                │  (DNS + WAF +   │
                                │   DDoS + SSL)   │
                                └────────┬────────┘
                                         │
                                         │ Full (strict) SSL
                                         ▼
                                ┌─────────────────┐
                                │     UFW         │
                                │  Ports: 80,443  │
                                └────────┬────────┘
                                         │
                                         ▼
                          ┌──────────────────────────┐
                          │  Nginx Reverse Proxy     │
                          │  (reverse-proxy-nginx)   │
                          │  Ports 80 / 443          │
                          │  SSL Termination         │
                          │  Rate Limiting           │
                          │  Security Headers        │
                          │  JSON Access Logs        │
                          └────────┬─────────────────┘
                                   │
                                   │ shared-network
                                   ▼
     ┌───────────────────────────────────────────────────────────┐
     │                  SHARED DOCKER NETWORK                    │
     │               (shared-network)                            │
     └──────┬──────────────────┬──────────────────┬──────────────┘
            │                  │                  │
            ▼                  ▼                  ▼
   ┌────────────────┐ ┌────────────────┐ ┌────────────────┐
   │  AI Gateway    │ │  Backend API   │ │  Admin Panel   │
   │                │ │                │ │                │
   │ gateway-app    │ │ api-app        │ │ admin-app      │
   │ :3000          │ │ :5000          │ │ :4000          │
   │                │ │                │ │                │
   │ gateway-       │ │ api-postgres   │ │ admin-postgres │
   │ postgres:5432  │ │ :5432          │ │ :5432          │
   │                │ │                │ │                │
   │ gateway-redis  │ │ api-redis      │ │ admin-redis    │
   │ :6379          │ │ :6379          │ │ :6379          │
   └────────────────┘ └────────────────┘ └────────────────┘
            │                  │                  │
            │                  │                  │
            ▼                  ▼                  ▼
   ┌────────────────┐ ┌────────────────┐ ┌────────────────┐
   │  Gateway       │ │  API           │ │  Admin         │
   │  Volumes:      │ │  Volumes:      │ │  Volumes:      │
   │  postgres_data │ │  postgres_data │ │  postgres_data │
   │  redis_data    │ │  redis_data    │ │  redis_data    │
   │  uploads       │ │  uploads       │ │  uploads       │
   └────────────────┘ └────────────────┘ └────────────────┘
            │                  │                  │
            │                  │                  │
            ▼                  ▼                  ▼
   ┌───────────────────────────────────────────────────────────┐
   │                    BACKUPS                                 │
   │    /var/backups/gateway/   /var/backups/api/             │
   │    /var/backups/admin/    /var/backups/reverse-proxy/    │
   │    Daily DB + Weekly Uploads + Monthly SSL Certs          │
   └───────────────────────────────────────────────────────────┘
            │                  │                  │
            │                  │                  │
            ▼                  ▼                  ▼
   ┌───────────────────────────────────────────────────────────┐
   │               CI/CD PIPELINE                              │
   │    GitHub Actions → GHCR → docker compose pull && up -d   │
   └───────────────────────────────────────────────────────────┘
```

## Service Details

```txt
AI Gateway (gateway.animewarp.app)
  Container:     gateway-app:3000
  Database:      gateway-postgres:5432
  Cache:         gateway-redis:6379
  Purpose:       LLM proxy, rate limiting, key management

Backend API (api.animewarp.app)
  Container:     api-app:5000
  Database:      api-postgres:5432
  Cache:         api-redis:6379
  Purpose:       REST API for application logic

Admin Panel (admin.animewarp.app)
  Container:     admin-app:4000
  Database:      admin-postgres:5432
  Purpose:       Admin dashboard, user management
```

## Network Communication

```txt
All internal traffic goes through shared-network:

  Browser → Cloudflare → Nginx :443
    → Nginx routes based on server_name
    → proxy_pass to container_name:PORT
    → Container communicates with its own DB/Redis
    → All DB and Redis ports are internal only

Externally exposed:
  :80    → Nginx (redirects to HTTPS)
  :443   → Nginx (terminates SSL, proxies to apps)
  :1182   → SSH (custom port)

Never exposed externally:
  :3000, :5000, :4000  → Application ports
  :5432                 → PostgreSQL
  :6379                 → Redis
```

## Benefits Of This Architecture

```txt
✓ Single entry point (Nginx on 80/443)
✓ Centralized SSL management (one certbot)
✓ Independent projects (one stack does not affect another)
✓ Shared network (containers communicate seamlessly)
✓ No port conflicts (each project uses internal ports)
✓ Consistent security (headers, rate limiting, WAF)
✓ Scalable (add projects without touching existing ones)
✓ Backup-friendly (per-project backup paths)
✓ CI/CD ready (each project deploys independently)
```

---

# 27. Reverse Proxy Rules

## Mandatory Rules

These rules must be followed for every project deployed behind the shared reverse proxy.

### Rule 1: One Reverse Proxy Per VPS

```txt
There must be exactly ONE reverse proxy on the VPS.
It manages ports 80 and 443.

WRONG:
  /var/www/project-a/nginx/   ← Nginx in project
  /var/www/project-b/nginx/   ← Another Nginx in another project
  Multiple Nginx instances competing for port 80.

CORRECT:
  /var/www/reverse-proxy/nginx/  ← Single shared Nginx
  /var/www/project-a/           ← No Nginx, just app containers
  /var/www/project-b/           ← No Nginx, just app containers
```

### Rule 2: Reverse Proxy Owns Ports 80 And 443

```txt
Only reverse-proxy-nginx binds ports 80 and 443 on the host.

WRONG:
  services:
    app:
      ports:
        - "80:80"    ← Host port 80 bound by project

WRONG:
  services:
    nginx:
      ports:
        - "443:443"  ← Nginx inside project stack

CORRECT:
  services:
    app:
      expose:
        - "3000"     ← Internal only, no host port binding
```

### Rule 3: Project Containers Never Expose 80 Or 443

```txt
Project containers must use `expose:` not `ports:` for their
application ports.

WRONG:
  services:
    app:
      ports:
        - "3000:3000"    ← App port accessible from outside
        - "5000:5000"    ← Anyone can connect to port 5000

CORRECT:
  services:
    app:
      expose:
        - "3000"         ← Only accessible within Docker networks
```

### Rule 4: Projects Must Join The Shared Network

```txt
Every project container that needs to be reachable by the
reverse proxy must join shared-network.

WRONG:
  services:
    app:
      networks: []        ← Default network, not reachable by proxy
    # or
    networks:
      my-custom-network:  ← Different network than proxy

CORRECT:
  services:
    app:
      networks:
        - shared-network

networks:
  shared-network:
    external: true
    name: shared-network
```

### Rule 5: Nginx Must Not Exist Inside Project Stacks

```txt
Projects must not include an Nginx service. The shared reverse
proxy handles all HTTP/HTTPS concerns.

WRONG:
  services:
    nginx:
      image: nginx:alpine    ← Extra Nginx inside project
      ports:
        - "80:80"

CORRECT:
  services:
    app:
      image: your-app:latest
      expose:
        - "3000"
```

### Rule 6: SSL Is Managed Centrally

```txt
All SSL certificates are generated, renewed, and stored by
the reverse-proxy's certbot container.

Projects must not:
  - Run their own certbot
  - Manage their own SSL certificates
  - Bind port 80 for ACME challenges
  - Reference SSL certificates outside the certbot/conf/ directory

The only SSL configuration in a site config file is:
  ssl_certificate     /etc/letsencrypt/live/DOMAIN/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/DOMAIN/privkey.pem;
```

### Rule 7: All Projects Remain Independent

```txt
No project may depend on another project's containers.

WRONG:
  # api/docker-compose.yml
  services:
    app:
      depends_on:
        - gateway-postgres    ← Cross-project dependency

CORRECT:
  # Each project has its own database and cache.
  # Projects do not reference each other's containers.

  /var/www/gateway/    → gateway-postgres:5432
  /var/www/api/        → api-postgres:5432
  /var/www/admin/      → admin-postgres:5432

Shared infrastructure is limited to:
  - shared-network (communication layer)
  - reverse-proxy-nginx (HTTP/HTTPS entry point)
```

## Quick Rules Reference

```txt
┌──────────────────────────────────────────────────────────────────┐
│                    REVERSE PROXY RULES                            │
├──────────────────────────────────────────────────────────────────┤
│  1. One reverse proxy per VPS                                    │
│  2. Reverse proxy owns ports 80 and 443                          │
│  3. Project containers never expose 80/443                       │
│  4. Projects join shared-network                                 │
│  5. No Nginx inside project stacks                               │
│  6. SSL managed centrally by certbot                             │
│  7. All projects remain independent                              │
└──────────────────────────────────────────────────────────────────┘
```

## Rule Compliance Verification

```bash
# Rule 2: Check port ownership
sudo ss -tulpn | grep -E ":80 |:443 "

# Expected: only reverse-proxy-nginx process

# Rule 3: Check for exposed ports
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Expected: only reverse-proxy-nginx shows 80, 443
# All other containers show no host ports or internal ports only

# Rule 4: Verify shared network
docker network inspect shared-network \
  --format '{{range .Containers}}{{.Name}} {{end}}'

# Expected: reverse-proxy-nginx + all project containers

# Rule 5: Check no extra nginx containers
docker ps --filter "ancestor=nginx" --format "table {{.Names}}\t{{.Image}}"

# Expected: only reverse-proxy-nginx

# Rule 7: Check cross-project dependencies
grep -r "depends_on" /var/www/*/docker-compose.yml
# Expected: no cross-project references
```

---

# 28. Monitoring And Alerting

## Monitoring Architecture

```txt
┌───────────────────────────────────────────────────────┐
│                   Monitoring Stack                      │
│                                                         │
│  ┌─────────────┐  ┌───────────┐  ┌───────────────────┐ │
│  │ Uptime Kuma │  │ Prometheus│  │  Loki             │ │
│  │ (uptime +   │  │ (metrics) │  │  (log aggregation)│ │
│  │  alerts)    │  │           │  │                   │ │
│  └──────┬──────┘  └─────┬─────┘  └────────┬──────────┘ │
│         │               │                  │            │
│         ▼               ▼                  ▼            │
│  ┌────────────────────────────────────────────┐        │
│  │              Grafana Dashboard             │        │
│  │  (visualize metrics + logs + alerts)       │        │
│  └────────────────────────────────────────────┘        │
└───────────────────────────────────────────────────────┘
         │               │                  │
         │               │                  │
         ▼               ▼                  ▼
   ┌──────────┐   ┌──────────┐   ┌──────────────────┐
   │Nginx     │   │Docker    │   │Application       │
   │Logs      │   │Metrics   │   │Health Endpoints  │
   │Metrics   │   │Stats     │   │/health           │
   └──────────┘   └──────────┘   └──────────────────┘
```

## Monitoring Components

| Component | Purpose | Deployment |
|-----------|---------|------------|
| Uptime Kuma | Uptime monitoring, SSL expiry, HTTP status alerts | Docker container |
| Prometheus | Metrics collection (CPU, RAM, disk, request rates) | Docker container |
| Grafana | Dashboard visualization for all metrics and logs | Docker container |
| Loki | Log aggregation from Nginx, Docker, and applications | Docker container |
| Docker logs | Raw container logs via `docker logs` | Built-in |
| Nginx access logs | Structured JSON request logs | Configured in nginx.conf |
| Health checks | Application-level health verification | Per-service in docker-compose.yml |

## Uptime Kuma

### What It Monitors

```txt
✓ HTTP/HTTPS uptime (200 OK check)
✓ SSL certificate expiry (alerts before 30, 14, 7, 1 days)
✓ Ping latency
✓ Port availability
✓ Configurable notification channels:
  - Email
  - Discord
  - Slack
  - Telegram
  - Webhook
```

### Deployment

Create `/var/www/reverse-proxy/monitoring/uptime-kuma/docker-compose.yml`:

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - uptime_kuma_data:/app/data
    networks:
      - shared-network

volumes:
  uptime_kuma_data:

networks:
  shared-network:
    external: true
    name: shared-network
```

Important: Uptime Kuma binds port 3001. This should only be accessible via a reverse proxy rule, not directly exposed through the firewall. Add an Nginx config to serve it at `status.yourdomain.com`:

```nginx
server {
    listen 443 ssl http2;
    server_name status.animewarp.app;

    ssl_certificate     /etc/letsencrypt/live/status.animewarp.app/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/status.animewarp.app/privkey.pem;

    include /etc/nginx/includes/security-headers.conf;

    location / {
        proxy_pass http://uptime-kuma:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Monitors To Configure

```txt
For each project:
  - https://gateway.animewarp.app/health
  - https://api.animewarp.app/health
  - https://admin.animewarp.app/health

For infrastructure:
  - https://status.animewarp.app (Uptime Kuma itself)
  - SSL certificate check for each domain
  - Ping to VPS IP
  - Port check for 80 and 443
```

## Prometheus

Prometheus collects metrics from exporters running alongside your services.

### Basic Deployment

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - shared-network
```

### prometheus.yml

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "docker"
    static_configs:
      - targets: ["cadvisor:8080"]
```

## Grafana

Grafana visualizes Prometheus metrics and Loki logs.

```yaml
services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3002:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - shared-network
```

## Docker Logs

### Accessing Logs

```bash
# All Nginx logs
docker compose -f /var/www/reverse-proxy/docker-compose.yml logs nginx

# Live tail
docker compose -f /var/www/reverse-proxy/docker-compose.yml logs -f nginx

# Last 100 lines
docker compose -f /var/www/reverse-proxy/docker-compose.yml logs --tail 100 nginx

# Project container logs
docker compose -f /var/www/gateway/docker-compose.yml logs app --tail 50

# All containers
docker ps -q | xargs -I {} docker logs --tail 10 {}
```

## Nginx Logs

### Structured JSON Logging

Nginx is configured with JSON-formatted access logs (see section 9). This makes log parsing and analysis straightforward.

### Monitoring Nginx Metrics

```bash
# Request rate
docker exec reverse-proxy-nginx sh -c \
  "tail -1000 /var/log/nginx/access.log | wc -l"

# HTTP status distribution
docker exec reverse-proxy-nginx sh -c \
  "tail -10000 /var/log/nginx/access.log | grep -o '\"status\":[0-9]*' | sort | uniq -c | sort -rn"

# 5xx errors in last 5 minutes
docker exec reverse-proxy-nginx sh -c \
  "tail -5000 /var/log/nginx/access.log | grep '\"status\":5' | wc -l"

# Top 10 requesting IPs
docker exec reverse-proxy-nginx sh -c \
  "tail -10000 /var/log/nginx/access.log | grep -o '\"remote_addr\":\"[^\"]*\"' | sort | uniq -c | sort -rn | head -10"
```

## Health Checks

### Automated Health Check Script

Save as `/var/www/reverse-proxy/scripts/health-check.sh`:

```bash
#!/bin/bash
# Production health check: alerts if any endpoint fails

ENDPOINTS=(
  "https://gateway.animewarp.app/health"
  "https://api.animewarp.app/health"
  "https://admin.animewarp.app/health"
)

for endpoint in "${ENDPOINTS[@]}"; do
  STATUS=$(curl -so /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null)

  if [ "$STATUS" != "200" ]; then
    echo "ALERT: $endpoint returned HTTP $STATUS"
    # Add notification command here (email, webhook, etc.)
  else
    echo "OK: $endpoint → $STATUS"
  fi
done

# Certificate expiry check
docker exec reverse-proxy-certbot certbot certificates 2>&1 \
  | grep -E "Expiry Date" | while read line; do
  EXPIRY=$(echo "$line" | grep -oP '\d{4}-\d{2}-\d{2}')
  DAYS_LEFT=$(( ($(date -d "$EXPIRY" +%s) - $(date +%s)) / 86400 ))

  if [ "$DAYS_LEFT" -lt 14 ]; then
    echo "ALERT: Certificate expires in $DAYS_LEFT days"
  fi
done
```

Run via cron:

```cron
*/5 * * * * /var/www/reverse-proxy/scripts/health-check.sh >> /var/log/health-check.log 2>&1
```

## SSL Expiry Monitoring

### Manual Check

```bash
# Check all certificates expiry
docker exec reverse-proxy-certbot certbot certificates

# Check specific domain
echo | openssl s_client -servername gateway.animewarp.app \
  -connect gateway.animewarp.app:443 2>/dev/null \
  | openssl x509 -noout -enddate
```

### Automated SSL Expiry Check

Add to the health check script or run separately:

```bash
#!/bin/bash
# SSL expiry check

DOMAINS=("gateway.animewarp.app" "api.animewarp.app" "admin.animewarp.app")

for domain in "${DOMAINS[@]}"; do
  EXPIRY=$(echo | openssl s_client -servername "$domain" \
    -connect "$domain:443" 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | cut -d= -f2)

  if [ -n "$EXPIRY" ]; then
    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

    if [ "$DAYS_LEFT" -lt 14 ]; then
      echo "ALERT: $domain SSL expires in $DAYS_LEFT days ($EXPIRY)"
    else
      echo "OK: $domain SSL expires in $DAYS_LEFT days"
    fi
  fi
done
```

## Resource Monitoring

### CPU, RAM, Disk

```bash
# Quick check
df -h
free -h
uptime

# Docker stats
docker stats --no-stream

# Per-container CPU/MEM
docker stats --no-stream --format \
  "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Disk by Docker volumes
docker system df

# Largest files in /var/backups
du -sh /var/backups/* | sort -rh | head -10
```

### Alert Thresholds

```txt
Disk  > 85%   →  alert: prune images, expand volume
RAM   > 90%   →  alert: investigate memory leak, upgrade VPS
CPU   > 80% ( sustained) →  alert: investigate load
Inodes > 80%  →  alert: too many small files
Docker daemon not responding → critical alert
Certificate expiry < 14 days → warning
Certificate expiry < 7 days  → critical alert
```

## Recommended Monitoring Stack Deployment

### Minimal Setup

```txt
✓ Uptime Kuma (uptime + SSL alerts)
✓ Cron health check script (custom)
✓ Docker logs (manual inspection)
```

### Full Production Setup

```txt
✓ Uptime Kuma (uptime + SSL alerts + notifications)
✓ Prometheus + Node Exporter (system metrics)
✓ cAdvisor (container metrics)
✓ Grafana (dashboard)
✓ Loki + Promtail (log aggregation)
✓ Cron health check script (automated verification)
```

---

# 29. Disaster Recovery

## Disaster Scenarios

```txt
Scenario 1: VPS hard failure (unrecoverable)
  - VPS provider terminates the instance
  - No SSH access
  - All data on volumes is lost

Scenario 2: VPS soft failure (recoverable)
  - OS corruption
  - Docker daemon failure
  - Accidental container/volume deletion

Scenario 3: DNS / Cloudflare misconfiguration
  - Domain pointing to wrong IP
  - Cloudflare SSL mode changed
  - A records deleted
```

## Recovery Prerequisites

```txt
Before a disaster occurs, ensure you have:

✓ All docker-compose.yml files backed up (GitHub)
✓ All .env files backed up (encrypted)
✓ All nginx configs backed up (GitHub)
✓ Project images in GHCR (not just locally)
✓ Database backups in /var/backups/ (or offsite)
✓ SSL certificate backup
✓ VPS provider console access
✓ Cloudflare account access
  - DNS records documented
  - API token for automation
✓ SSH keys backed up
```

## Disaster Recovery Workflow

### Step 1: Provision A New VPS

```bash
# Create a new VPS with the same provider or a different one
# Use the same OS version (Ubuntu 24.04 LTS)
# Note the new IP address

# Initial setup (see 01-initial-vps-security-setup.md)
ssh root@NEW_VPS_IP
adduser mosabbir
usermod -aG sudo mosabbir

# Harden SSH (see 02-ssh-guide.md)
# Install Docker (see 04-docker.md)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker mosabbir
```

### Step 2: Restore The Shared Network

```bash
docker network create --driver bridge --attachable shared-network
```

### Step 3: Restore The Reverse Proxy

```bash
# Clone configuration from backup or GitHub
git clone https://github.com/yourorg/reverse-proxy-config.git \
  /var/www/reverse-proxy

# Generate fallback SSL certificate
mkdir -p /var/www/reverse-proxy/nginx/ssl/default
docker run --rm \
  -v /var/www/reverse-proxy/nginx/ssl/default:/certs alpine sh -c \
  "apk add openssl && openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /certs/privkey.pem -out /certs/fullchain.pem \
  -subj '/CN=localhost'"

# Start the reverse proxy
cd /var/www/reverse-proxy
docker compose up -d
```

### Step 4: Restore SSL Certificates

```bash
# Option A: Restore from backup
tar -xzf /var/backups/reverse-proxy/certs-2026-06-01.tar.gz \
  -C /var/www/reverse-proxy

docker exec reverse-proxy-nginx nginx -s reload

# Option B: Re-issue certificates (if no backup)
for domain in gateway.animewarp.app api.animewarp.app admin.animewarp.app; do
  # First, set Cloudflare to DNS Only for this domain
  # Then issue the certificate
  docker exec reverse-proxy-certbot certbot certonly \
    --webroot --webroot-path /var/www/certbot \
    -d "$domain" --email you@example.com \
    --agree-tos --non-interactive

  # Set Cloudflare back to Proxied
done

docker exec reverse-proxy-nginx nginx -s reload
```

### Step 5: Restore Projects

```bash
# For each project:
cd /var/www

# Clone project config from GitHub
git clone https://github.com/yourorg/gateway.git

# Copy .env from backup
cp /var/backups/gateway/.env gateway/.env
chmod 600 gateway/.env

# Pull and start containers
cd gateway
export TAG=latest
docker compose pull
docker compose up -d

# Verify health
curl -sf http://localhost:3000/health
```

### Step 6: Restore Persistent Volumes

```bash
# Option A: Docker named volumes
# Docker volumes are tied to the old VPS and cannot be moved directly.
# Use database-level restore instead.

# PostgreSQL restore
gunzip -c /var/backups/gateway/postgres-2026-06-10.sql.gz \
  | docker exec -i gateway-postgres psql -U admin gateway

# Redis restore
docker compose stop redis
cp /var/backups/gateway/redis-2026-06-10.rdb \
  /var/lib/docker/volumes/gateway_redis_data/_data/dump.rdb
docker compose up -d redis

# Uploads restore
docker run --rm \
  -v gateway_uploads:/data \
  -v /var/backups/gateway:/backup \
  alpine tar -xzf /backup/uploads-2026-06-10.tar.gz -C /
```

### Step 7: Update DNS

```bash
# In Cloudflare dashboard:
# 1. Update A records to point to NEW_VPS_IP
# 2. Ensure proxy is set to Proxied (orange cloud)
# 3. SSL/TLS mode: Full (strict)

# Verify propagation
dig gateway.animewarp.app +short
# Should return NEW_VPS_IP (or Cloudflare IPs if proxied)
```

### Step 8: Verify Everything

```bash
# Run the verification checklist from section 20
bash /var/www/reverse-proxy/scripts/check-proxy.sh gateway.animewarp.app gateway-app

# Test all endpoints
for domain in gateway.animewarp.app api.animewarp.app admin.animewarp.app; do
  echo "=== $domain ==="
  curl -sI "https://$domain/health" | head -1
done

# Verify backups are running
crontab -l
```

## Recovery Checklist

```txt
Phase 1: Infrastructure
  ✓ New VPS provisioned
  ✓ SSH access configured
  ✓ Docker installed
  ✓ UFW configured (80, 443, SSH)
  ✓ Docker network created (shared-network)

Phase 2: Reverse Proxy
  ✓ Reverse proxy config restored (GitHub)
  ✓ Self-signed fallback cert generated
  ✓ docker compose up -d
  ✓ Nginx config validated (nginx -t)
  ✓ SSL certificates restored or re-issued

Phase 3: Projects
  ✓ Project configs restored (GitHub)
  ✓ .env files restored (backup)
  ✓ docker compose pull
  ✓ docker compose up -d
  ✓ Health checks passing

Phase 4: Data
  ✓ PostgreSQL restored from backup
  ✓ Redis restored from backup
  ✓ Uploads restored from backup

Phase 5: DNS
  ✓ Cloudflare A records updated
  ✓ DNS propagation verified
  ✓ Cloudflare SSL set to Full (strict)

Phase 6: Verification
  ✓ All domains reachable via HTTPS
  ✓ All health endpoints return 200
  ✓ Certbot renewal works (--dry-run)
  ✓ Backup cron jobs running
  ✓ Monitoring re-enabled (Uptime Kuma)
```

## Recovery Time Objectives

```txt
Infrastructure provisioning:    10-15 minutes
Reverse proxy restoration:       5-10 minutes
SSL restoration:                  5-15 minutes (per domain)
Project restoration:              3-5 minutes (per project)
Data restoration:                 5-30 minutes (per database)
DNS propagation:                  1-5 minutes (Cloudflare)
Total:                           30-90 minutes
```

---

# 30. Recommended Production Stack

## Complete Stack Overview

```txt
┌────────────────────────────────────────────────────────────┐
│                   RECOMMENDED PRODUCTION STACK               │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Layer 1: Edge                                       │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────────┐ │  │
│  │  │ Cloudflare │  │  DNS       │  │  DDoS Protection│ │  │
│  │  │ (CDN+WAF)  │  │  (Proxied) │  │  (Always On)   │ │  │
│  │  └────────────┘  └────────────┘  └────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Layer 2: Reverse Proxy                              │  │
│  │  ┌────────────────┐  ┌────────────────────────────┐  │  │
│  │  │ Nginx (Docker) │  │ Let's Encrypt (certbot)    │  │  │
│  │  │ Ports 80/443   │  │ Automated SSL renewal     │  │  │
│  │  │ Rate Limiting  │  │ Centralized certificates  │  │  │
│  │  │ JSON Logs      │  │ ACME via webroot          │  │  │
│  │  └────────────────┘  └────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Layer 3: Shared Network                             │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │           shared-network                       │  │  │
│  │  │     (Docker bridge, attachable)                │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Layer 4: Projects                                   │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │  │
│  │  │ Gateway  │ │ API      │ │ Admin    │ │ Future │  │  │
│  │  │ App      │ │ App      │ │ App      │ │ Projects│  │  │
│  │  │ Postgres │ │ Postgres │ │ Postgres │ │ ...    │  │  │
│  │  │ Redis    │ │ Redis    │ │ Redis    │ │        │  │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Layer 5: CI/CD & Registry                           │  │
│  │  ┌────────────────┐  ┌────────────────────────────┐  │  │
│  │  │ GitHub Actions │  │ GHCR (Container Registry)  │  │  │
│  │  │ Test → Build   │  │ ghcr.io/yourorg/project   │  │  │
│  │  │ Push → Deploy  │  │ Tags: sha, latest, branch │  │  │
│  │  └────────────────┘  └────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Layer 6: Monitoring                                 │  │
│  │  ┌────────────┐  ┌───────────┐  ┌─────────────────┐  │  │
│  │  │Uptime Kuma │  │ Grafana   │  │ Health Check    │  │  │
│  │  │Uptime + SSL│  │ Dashboard │  │ Script (cron)   │  │  │
│  │  │Alerts      │  │ Metrics   │  │ 5-minute checks │  │  │
│  │  └────────────┘  └───────────┘  └─────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Layer 7: Backups                                    │  │
│  │  ┌────────────┐  ┌───────────┐  ┌─────────────────┐  │  │
│  │  │ PostgreSQL │  │ Redis     │  │ Uploads + Certs │  │  │
│  │  │ Daily      │  │ Daily     │  │ Weekly / Monthly│  │  │
│  │  │ 30-day     │  │ 14-day    │  │ 60-day / 90-day │  │  │
│  │  └────────────┘  └───────────┘  └─────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Component Summary

| Layer | Component | Purpose |
|-------|-----------|---------|
| Edge | Cloudflare | DNS, CDN, DDoS protection, WAF, SSL termination |
| Reverse Proxy | Nginx (Docker) | HTTP/HTTPS entry point, routing, rate limiting |
| SSL | Certbot / Let's Encrypt | Automated certificate issuance and renewal |
| Network | shared-network (Docker) | Container communication across projects |
| Container Runtime | Docker + Docker Compose | Application isolation and orchestration |
| Registry | GHCR (GitHub Container Registry) | Immutable image storage |
| CI/CD | GitHub Actions | Test, build, push, and deploy automation |
| Monitoring | Uptime Kuma | Uptime monitoring and SSL expiry alerts |
| Monitoring | Health check script | Automated endpoint verification |
| Backups | pg_dump + tar + cron | Database, config, and data backup |

## Why Each Component

```txt
Cloudflare:
  ✓ Free tier covers DNS + DDoS + WAF + CDN
  ✓ Proxy mode hides origin IP
  ✓ Full (strict) SSL ensures end-to-end encryption

Nginx:
  ✓ Industry-standard reverse proxy
  ✓ Lightweight (alpine image ~5 MB)
  ✓ Highly configurable

Let's Encrypt:
  ✓ Free, automated, trusted
  ✓ 90-day certificates enforce regular renewal

Docker + Compose:
  ✓ Industry standard for container orchestration
  ✓ Built-in DNS resolution on shared networks
  ✓ Health checks and restart policies

GHCR:
  ✓ Integrated with GitHub
  ✓ No separate registry to manage
  ✓ Free for public images

GitHub Actions:
  ✓ Integrated with GitHub repos
  ✓ No separate CI server needed
  ✓ 2000 free minutes/month

Uptime Kuma:
  ✓ Self-hosted, lightweight
  ✓ Free, open-source
  ✓ SSL expiry monitoring built in

Automated Backups:
  ✓ Essential for data recovery
  ✓ Low cost (cron + shell scripts)
  ✓ No external service dependency
```

## Stack Deployment Order

```txt
Step 1: VPS provisioning (Ubuntu + Docker + UFW)
Step 2: Docker shared network creation
Step 3: Nginx reverse proxy deployment
Step 4: Let's Encrypt SSL setup
Step 5: Cloudflare DNS + SSL configuration
Step 6: Project deployments (gateway, api, admin)
Step 7: CI/CD pipeline (GitHub Actions → GHCR)
Step 8: Monitoring (Uptime Kuma + health checks)
Step 9: Automated backups (cron)
Step 10: Verify everything with the production checklist
```

---

## Document Reference

| Section | Description |
|---------|-------------|
| 1-4 | Architecture overview and port sharing concepts |
| 5-6 | Shared Docker network and container communication |
| 7-9 | Folder structure, Docker Compose, Nginx configuration |
| 10-12 | SSL with Let's Encrypt, Cloudflare integration |
| 13-15 | Multi-project deployment and adding new projects |
| 16 | Security best practices |
| 17-18 | Common mistakes and troubleshooting |
| 19-20 | Useful commands and deployment checklist |
| 21-22 | CI/CD with GHCR and registry retention policy |
| 23 | Volume backup strategy for all persistent data |
| 24 | Zero-downtime deployment strategy |
| 25 | Standardized health check configuration |
| 26 | Complete production architecture diagram |
| 27 | Mandatory reverse proxy rules |
| 28 | Monitoring and alerting setup |
| 29 | Disaster recovery workflow |
| 30 | Recommended production stack summary |
