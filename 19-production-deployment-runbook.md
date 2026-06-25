# Production Deployment Runbook

**Author:** Mosabbir Maruf
**Last Updated:** 2026-06-26
**Repo:** https://github.com/mosabbir-maruf/Devops-Deployment

> **Note:** All domains, email addresses, usernames, registry paths, and IP addresses are examples. Replace with your production values.

---

## Table of Contents

- [Phase 1: Infrastructure Foundation](#phase-1-infrastructure-foundation)
- [Phase 2: Reverse Proxy Stack](#phase-2-reverse-proxy-stack)
- [Phase 3: SSL & HTTPS](#phase-3-ssl--https)
- [Phase 4: Application Deployment](#phase-4-application-deployment)
- [Phase 5: Production Validation](#phase-5-production-validation)
- [Phase 6: Operations](#phase-6-operations)
- [Phase 7: Disaster Recovery](#phase-7-disaster-recovery)
- [Appendix: Emergency & Operational Commands](#appendix-emergency--operational-commands)

---

## Configuration Reference

Throughout this runbook, these values are used as placeholders:

| Placeholder | Example | Description |
|---|---|---|
| `gateway.example.com` | `gateway.animewarp.app` | Application domain |
| `your-email@example.com` | `admin@example.com` | Let's Encrypt email |
| `your-github-username` | `mosabbir-maruf` | GHCR username |
| `YOUR_VPS_IP` | `198.51.100.100` | Server public IP |
| `AI_GATEWAY_IMAGE` | `ghcr.io/mosabbir-maruf/ai-gateway:latest` | App container image |
| `HEALTH_ENDPOINT` | `/health` | App health check path |
| `APP_INTERNAL_PORT` | `8900` | Port the app listens on |

---

## Phase 1: Infrastructure Foundation

### 1.1 Server Validation

Verify Docker, networking, and firewall are operational:

```bash
docker --version
docker compose version
sudo systemctl status docker --no-pager
curl -s ifconfig.me
sudo ufw status verbose
sudo ss -tulpn
```

**Expected:**

```
Docker version 27.5.1, build ...
Docker Compose version 2.32.0
● docker.service - Docker Application Container Engine
     Active: active (running)
198.51.100.100
Status: active
80/tcp, 443/tcp, 22/tcp ALLOW IN
```

### 1.2 Shared Network

```bash
docker network create --driver bridge --attachable shared-network
docker network ls
```

**Verify:**

```bash
docker network inspect shared-network
```

**Expected:** Empty `"Containers": {}` (populated as services join).

### Troubleshooting

```
"docker: command not found"
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  Log out and back in.

"docker compose: command not found"
  sudo apt install docker-compose-plugin -y

"UFW is inactive"
  sudo ufw --force enable

"80/tcp and 443/tcp not in UFW rules"
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  sudo ufw reload

"network with name shared-network already exists"
  This is safe. Proceed.

"Pool overlaps with other one on this address space"
  docker network prune -f
  docker network create --driver bridge --attachable shared-network
```

---

## Phase 2: Reverse Proxy Stack

### 2.1 Directory Structure

```bash
mkdir -p ~/reverse-proxy/{nginx/{sites,includes,ssl/default},certbot/{conf,www},scripts}
cd ~/reverse-proxy
```

**Verify:**

```bash
find ~/reverse-proxy -type d | sort
ls -la ~/reverse-proxy
```

**Expected:**

```
reverse-proxy/
├── certbot/conf/
├── certbot/www/
├── nginx/includes/
├── nginx/sites/
├── nginx/ssl/default/
└── scripts/
```

### 2.2 Nginx Configuration

```bash
nano ~/reverse-proxy/nginx/nginx.conf
```

**Exact content:**

`~/reverse-proxy/nginx/nginx.conf`

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

    log_format json escape=json '{'
        '"time":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request":"$request",'
        '"status":$status,'
        '"body_bytes":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"http_referrer":"$http_referer",'
        '"http_user_agent":"$http_user_agent"'
    '}';
    access_log /var/log/nginx/access.log json buffer=32k flush=5s;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 5;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;

    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    client_max_body_size 100M;
    limit_req_zone $binary_remote_addr zone=general:10m rate=50r/s;
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    include /etc/nginx/sites/*.conf;
}
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

### 2.3 Docker Compose

```bash
nano ~/reverse-proxy/docker-compose.yml
```

**Exact content:**

`~/reverse-proxy/docker-compose.yml`

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
      - ./nginx/ssl:/etc/nginx/ssl:ro
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

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

### 2.4 Site Configuration

```bash
nano ~/reverse-proxy/nginx/sites/default.conf
```

**Default catch-all:**

`~/reverse-proxy/nginx/sites/default.conf`

```nginx
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

server {
    listen 443 ssl default_server;
    server_name _;

    ssl_certificate     /etc/nginx/ssl/default/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/default/privkey.pem;

    return 444;
}
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

**HTTP-only placeholder:**

`~/reverse-proxy/nginx/sites/gateway.example.com.conf`

```nginx
server {
    listen 80;
    server_name gateway.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 200 "Nginx OK";
    }
}
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

### 2.5 Generate Fallback Certificate & Start

The default SSL block requires a certificate. Generate a self-signed placeholder:

```bash
docker run --rm \
  -v ~/reverse-proxy/nginx/ssl/default:/certs alpine sh -c \
  "apk add openssl && openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /certs/privkey.pem -out /certs/fullchain.pem \
  -subj '/CN=localhost'"
```

Start the stack:

```bash
cd ~/reverse-proxy
docker compose up -d
```

**Verify:**

```bash
docker compose ps
curl -H "Host: gateway.example.com" http://localhost
```

**Expected:**

```
NAME                    IMAGE                 STATUS         PORTS
reverse-proxy-nginx     nginx:1.27-alpine     Up             0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
reverse-proxy-certbot   certbot/certbot:v2.9.0 Up

Nginx OK
```

### Troubleshooting

```
"port is already allocated"
  sudo ss -tulpn | grep -E ":80 |:443 "
  sudo systemctl stop nginx   # if host nginx is running
  sudo systemctl disable nginx

"cannot load certificate"
  ls -la ~/reverse-proxy/nginx/ssl/default/
  Regenerate using the docker run command in 2.5.

"Network shared-network not found"
  docker network create --driver bridge --attachable shared-network

"File name must end with .conf"
  Nginx only includes *.conf from sites/. Verify filenames.

"Typo in server_name"
  Must match your domain exactly.
```

---

## Phase 3: SSL & HTTPS

### 3.1 Cloudflare DNS — Temporary DNS Only

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com).
2. Select your domain zone.
3. **DNS → Records → Add Record:**

```
Type:   A
Name:   gateway
IPv4:   <YOUR_VPS_IP>
Proxy Status: DNS Only (gray cloud)
TTL:    Auto
```

**Verify DNS propagation:**

```bash
dig gateway.example.com +short
```

**Expected:** Your VPS IP (not a Cloudflare IP). Wait 1-2 minutes if needed.

**Verify reachability:**

```bash
curl -I http://gateway.example.com
```

**Expected:** `HTTP/1.1 200 OK`

### 3.2 Issue SSL Certificate

Pre-flight checks:

```bash
dig gateway.example.com +short
curl -sI http://gateway.example.com | head -1
curl -sI http://gateway.example.com/.well-known/acme-challenge/test
```

Generate certificate:

```bash
docker exec reverse-proxy-certbot certbot certonly \
  --webroot --webroot-path /var/www/certbot \
  -d gateway.example.com \
  --email your-email@example.com \
  --agree-tos --non-interactive
```

**Expected:**

```
Successfully received certificate.
Certificate is saved at:
  /etc/letsencrypt/live/gateway.example.com/fullchain.pem
Key is saved at:
  /etc/letsencrypt/live/gateway.example.com/privkey.pem
```

**Certificate storage:**

```
Host:  ~/reverse-proxy/certbot/conf/live/gateway.example.com/
        ├── cert.pem       (server certificate)
        ├── chain.pem      (intermediate CA)
        ├── fullchain.pem  (cert + chain)
        └── privkey.pem    (private key — keep secret)

Container: /etc/letsencrypt/live/gateway.example.com/
```

**Verify:**

```bash
docker exec reverse-proxy-certbot certbot certificates
sudo ls -la ~/reverse-proxy/certbot/conf/live/gateway.example.com/
```

### 3.3 Enable HTTPS

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

Replace the entire file with:

`~/reverse-proxy/nginx/sites/gateway.example.com.conf`

```nginx
server {
    listen 80;
    server_name gateway.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    http2 on;
    server_name gateway.example.com;

    ssl_certificate     /etc/letsencrypt/live/gateway.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gateway.example.com/privkey.pem;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    access_log /var/log/nginx/gateway-access.log json;
    error_log  /var/log/nginx/gateway-error.log warn;

    location / {
        default_type text/plain;
        return 200 "Service Available\n\nThis domain is configured correctly.\n\nThe application has not been deployed yet.\n";
    }
}
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

**Apply & verify:**

```bash
docker exec reverse-proxy-nginx nginx -t && docker exec reverse-proxy-nginx nginx -s reload
curl -I https://gateway.example.com
```

**Expected:** `HTTP/2 200` with `strict-transport-security` header.

**Verify SSL certificate details:**

```bash
echo | openssl s_client -servername gateway.example.com \
  -connect gateway.example.com:443 2>/dev/null \
  | openssl x509 -noout -issuer -subject -dates
```

### 3.4 Update Cloudflare to Proxied

1. Back in Cloudflare dashboard, change the A record to **Proxied** (orange cloud).
2. **SSL/TLS → Full (strict)**
3. Enable **Always Use HTTPS**

```
Cloudflare post-SSL settings:
  Proxy Status: Proxied (orange cloud)
  SSL/TLS Mode: Full (strict)
  Always Use HTTPS: On
```

**Verify via Cloudflare:**

```bash
curl -I https://gateway.example.com
```

### 3.5 Automated SSL Renewal

SSL renewal depends on host cron. The certbot container does not auto-renew by itself.

**Manual renewal test:**

```bash
docker exec reverse-proxy-certbot certbot renew --dry-run
```

**Expected:** All simulated renewals succeed.

**Set up automatic renewal:**

```bash
crontab -e
```

Add:

```cron
0 3 * * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --quiet && /usr/bin/docker exec reverse-proxy-nginx nginx -s reload
0 5 1 * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --dry-run --quiet
```

**Verify cron:**

```bash
crontab -l
which docker
```

**Expected:** Two active cron jobs. Docker path `/usr/bin/docker` (update crontab if different).

### Troubleshooting

```
"Could not connect to server" (certbot)
  Port 80 blocked or Nginx not running:
    sudo ufw status | grep 80/tcp
    docker compose ps | grep nginx
    dig gateway.example.com +short

"The server could not connect to verify domain"
  Cloudflare is proxying (orange cloud) — set to DNS Only (gray), wait 2 min.

"too many certificates already issued"
  Let's Encrypt rate limit — wait a week or use staging:
    --server https://acme-staging-v02.api.letsencrypt.org/directory

"nginx: [emerg] cannot load certificate"
  docker exec reverse-proxy-nginx ls -la /etc/letsencrypt/live/gateway.example.com/

"525 SSL handshake failed" (Cloudflare)
  Temporarily set Cloudflare SSL to Full (not strict), fix cert, then set back.

"curl: (35) SSL routines error"
  docker exec reverse-proxy-nginx tail -20 /var/log/nginx/error.log

"crontab: command not found"
  sudo apt install cron -y && sudo systemctl enable cron && sudo systemctl start cron

"docker: command not found in cron"
  Use absolute path: /usr/bin/docker exec ...

"Renewal failed: server could not connect"
  Port 80 required for ACME challenge. Check: sudo ufw status | grep 80
```

---

## Phase 4: Application Deployment

### 4.1 Deploy Application

**Create project directory and files:**

```bash
mkdir -p ~/ai-gateway
cd ~/ai-gateway
```

```bash
nano ~/ai-gateway/docker-compose.yml
```

**Exact content:**

`~/ai-gateway/docker-compose.yml`:

```yaml
services:
  app:
    image: ghcr.io/your-github-username/ai-gateway:latest
    container_name: ai-gateway-server
    restart: unless-stopped
    env_file:
      - .env
    expose:
      - "8900"
    networks:
      - shared-network
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:8900/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

networks:
  shared-network:
    external: true
    name: shared-network
```

> **Note:** Adjust `healthcheck.test` path and `APP_INTERNAL_PORT` to match your application's actual health endpoint and listening port.

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

```bash
nano ~/ai-gateway/.env
```

**Exact content:**

`~/ai-gateway/.env`:

```env
NODE_ENV=production
PORT=8900
# Add your secrets here
```

```bash
chmod 600 ~/ai-gateway/.env
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

**Authenticate with GHCR:**

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u your-github-username --password-stdin
```

If no token: GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens (read:packages).

**Pull and start:**

```bash
docker compose pull
docker compose up -d
```

**Verify:**

```bash
docker compose ps
docker compose logs app --tail 20
```

**Expected:**

```
NAME                IMAGE                                               STATUS
ai-gateway-server   ghcr.io/your-github-username/ai-gateway:latest     Up (healthy)

app | Server started on port 8900
```

**Verify connectivity through shared network:**

```bash
docker exec reverse-proxy-nginx getent hosts ai-gateway-server
docker exec reverse-proxy-nginx wget -qO- http://ai-gateway-server:8900/health
```

### 4.2 Integrate with Reverse Proxy

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

Replace the entire file with:

`~/reverse-proxy/nginx/sites/gateway.example.com.conf`

```nginx
server {
    listen 80;
    server_name gateway.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    http2 on;
    server_name gateway.example.com;

    ssl_certificate     /etc/letsencrypt/live/gateway.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gateway.example.com/privkey.pem;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    access_log /var/log/nginx/gateway-access.log json;
    error_log  /var/log/nginx/gateway-error.log warn;

    location / {
        proxy_pass http://ai-gateway-server:8900;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

**Apply & verify:**

```bash
docker exec reverse-proxy-nginx nginx -t && docker exec reverse-proxy-nginx nginx -s reload
curl -sI https://gateway.example.com/health
curl -s https://gateway.example.com/health | python3 -m json.tool
docker exec reverse-proxy-nginx tail -10 /var/log/nginx/gateway-access.log
```

**Expected:**

```
HTTP/2 200
content-type: application/json

{"status": "healthy", "uptime": 1234.56}

{"time":"...","request":"GET /health HTTP/2","status":200,"upstream_addr":"172.19.0.4:8900"}
```

### 4.3 Application Update Procedure

```bash
cd ~/ai-gateway

# Pull new image
docker compose pull

# Recreate container with new image
docker compose up -d

# Verify
docker compose ps
docker compose logs app --tail 20
curl -sf https://gateway.example.com/health && echo "OK"
```

### 4.4 Rollback Procedure

```bash
cd ~/ai-gateway

# Pin previous tag in docker-compose.yml, then:
docker compose pull app
docker compose up -d --no-deps app

# Verify health
curl -sf https://gateway.example.com/health && echo "Rollback OK"
```

### Troubleshooting

```
"unauthorized: authentication required"
  echo $GITHUB_TOKEN | docker login ghcr.io -u your-github-username --password-stdin

"manifest not found"
  Check the image tag exists on GHCR Packages page.

"container exits immediately"
  docker compose logs app
  Common cause: missing .env variables or app port mismatch.

".env file not found"
  nano ~/ai-gateway/.env

"host not found" (from nginx)
  docker network inspect shared-network
  If ai-gateway-server missing: docker compose down && docker compose up -d

"wget: can't connect: Connection refused"
  docker compose logs app --tail 20

"502 Bad Gateway"
  docker exec reverse-proxy-nginx getent hosts ai-gateway-server
  docker exec reverse-proxy-nginx wget -qO- http://ai-gateway-server:8900/health

"host not found in upstream ai-gateway-server"
  docker ps | grep ai-gateway
  Check container_name in ~/ai-gateway/docker-compose.yml matches ai-gateway-server

"nginx: [emerg] invalid port in upstream"
  Check proxy_pass format: http://ai-gateway-server:8900;

"504 Gateway Timeout"
  docker inspect ai-gateway-server --format='{{.State.Health.Status}}'
  Add timeouts: proxy_connect_timeout 60s; proxy_read_timeout 60s;
```

---

## Phase 5: Production Validation

Run this complete checklist after any deployment, config change, or SSL renewal.

```bash
# 1. HTTPS returns 200
curl -sI https://gateway.example.com | head -1

# 2. HTTP redirects to HTTPS (301)
curl -sI http://gateway.example.com | head -1

# 3. SSL certificate is valid
echo | openssl s_client -servername gateway.example.com \
  -connect gateway.example.com:443 2>/dev/null \
  | openssl x509 -noout -dates

# 4. HSTS header present
curl -sI https://gateway.example.com | grep -i strict-transport

# 5. Container is healthy
docker inspect ai-gateway-server --format='{{.State.Health.Status}}'

# 6. Health endpoint returns 200
curl -sf https://gateway.example.com/health && echo "OK"

# 7. Application logs are clean
docker compose -f ~/ai-gateway/docker-compose.yml logs app --tail 20

# 8. No app ports exposed on host
sudo ss -tulpn | grep ":8900"

# 9. Only expected ports open (80, 443, SSH)
sudo ss -tulpn | grep LISTEN

# 10. Direct IP access returns 444 (blocked)
curl -sI http://$(curl -s ifconfig.me) | head -1

# 11. Cloudflare proxying active (should show Cloudflare IPs)
dig gateway.example.com +short

# 12. Certificate renewal dry-run passes
docker exec reverse-proxy-certbot certbot renew --dry-run
```

**Validation Checklist:**

```txt
HTTPS works (200 OK)
HTTP redirects to HTTPS (301)
SSL certificate valid (dates current)
HSTS header present
Container healthy
Health endpoint returns 200
Logs clean (no errors)
No exposed app ports
Only 80, 443, SSH listening
Direct IP returns 444 (blocked)
Cloudflare proxying (orange cloud)
Certbot dry-run passes
```

---

## Phase 6: Operations

### 6.1 Daily Health Check

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
curl -sf https://gateway.example.com/health && echo "gateway OK"
df -h /
free -h
docker exec reverse-proxy-nginx tail -5 /var/log/nginx/error.log
```

Alert thresholds: disk > 85%, available memory < 500 MB.

### 6.2 Weekly Checks

```bash
docker exec reverse-proxy-certbot certbot certificates
docker system df
docker image prune -f
sudo fail2ban-client status sshd   # if fail2ban installed
```

### 6.3 Monthly Checks

```bash
docker exec reverse-proxy-certbot certbot renew --dry-run
docker image prune -a -f
docker exec reverse-proxy-nginx sh -c \
  "tail -10000 /var/log/nginx/access.log | grep -o '\"status\":[0-9]*' | sort | uniq -c | sort -rn"
```

### 6.4 Automated Daily Script

`~/reverse-proxy/scripts/daily-check.sh`:

```bash
#!/bin/bash
echo "=== Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "=== Health Endpoints ==="
for url in https://gateway.example.com/health; do
  status=$(curl -so /dev/null -w "%{http_code}" "$url")
  echo "$url -> $status"
done

echo ""
echo "=== Disk ==="
df -h / | tail -1

echo ""
echo "=== Memory ==="
free -h | grep Mem

echo ""
echo "=== Nginx Errors ==="
docker exec reverse-proxy-nginx tail -3 /var/log/nginx/error.log 2>/dev/null || echo "None"

echo ""
echo "=== Certificates ==="
docker exec reverse-proxy-certbot certbot certificates 2>&1 | grep -E "Certificate Name|Expiry"
```

```bash
chmod +x ~/reverse-proxy/scripts/daily-check.sh
bash ~/reverse-proxy/scripts/daily-check.sh
```

### 6.5 Backup Procedure

**What to back up:**

| Asset | Path | Frequency |
|---|---|---|
| Nginx configs | `~/reverse-proxy/nginx/` | On every change |
| SSL certificates | `~/reverse-proxy/certbot/conf/` | Monthly |
| Environment files | `~/ai-gateway/.env` | On every change |
| Docker Compose files | `~/reverse-proxy/docker-compose.yml`, `~/ai-gateway/docker-compose.yml` | On every change |

**Backup command (manual):**

```bash
BACKUP_DIR=~/backups/$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR

cp -r ~/reverse-proxy/nginx $BACKUP_DIR/nginx
cp -r ~/reverse-proxy/certbot/conf $BACKUP_DIR/certbot-conf
cp ~/reverse-proxy/docker-compose.yml $BACKUP_DIR/reverse-proxy-compose.yml
cp ~/ai-gateway/.env $BACKUP_DIR/ai-gateway.env
cp ~/ai-gateway/docker-compose.yml $BACKUP_DIR/ai-gateway-compose.yml

tar -czf ${BACKUP_DIR}.tar.gz -C ~/backups $(basename $BACKUP_DIR)
rm -rf $BACKUP_DIR
echo "Backup created: ${BACKUP_DIR}.tar.gz"
```

**Restore procedure:**

```bash
# List available backups
ls -la ~/backups/*.tar.gz

# Restore from backup
RESTORE_FILE=~/backups/20260626-120000.tar.gz
tar -xzf $RESTORE_FILE -C /tmp/restore

# Restore files individually:
cp -r /tmp/restore/nginx/* ~/reverse-proxy/nginx/
cp -r /tmp/restore/certbot-conf/* ~/reverse-proxy/certbot/conf/
cp /tmp/restore/ai-gateway.env ~/ai-gateway/.env
chmod 600 ~/ai-gateway/.env
cp /tmp/restore/ai-gateway-compose.yml ~/ai-gateway/docker-compose.yml

# Reload nginx if configs changed
docker exec reverse-proxy-nginx nginx -t && docker exec reverse-proxy-nginx nginx -s reload

# Restart application if configs changed
docker compose -f ~/ai-gateway/docker-compose.yml up -d
```

**Recommendation:** Integrate with [15-backup-snapshots.md](../15-backup-snapshots.md) for automated offsite backups.

### 6.6 Maintenance — Update Reverse Proxy Images

```bash
cd ~/reverse-proxy
docker compose pull
docker compose up -d
```

---

## Phase 7: Disaster Recovery

### Scope

Complete restoration of the production environment on a new VPS after catastrophic failure.

### Assumptions

- Old VPS is unrecoverable.
- New VPS with Ubuntu and Docker installed.
- SSH access to new VPS.
- Cloudflare account access.
- Application image available in GHCR.
- Configuration files are backed up or can be recreated from this runbook.

### Recovery Procedure

Recovery follows the same phases as fresh deployment. Below are the steps with references to the authoritative Phase section. Only recovery-specific deviations are documented inline.

#### 7.1 Provision New VPS

```bash
ssh root@NEW_VPS_IP
apt update && apt upgrade -y
curl -fsSL https://get.docker.com | sh
ufw allow 80/tcp && ufw allow 443/tcp && ufw allow 22/tcp
ufw --force enable
```

#### 7.2 Deploy Shared Network

→ [Phase 1.2](#12-shared-network)

```bash
docker network create --driver bridge --attachable shared-network
```

#### 7.3 Deploy Reverse Proxy Stack

→ Follow [Phase 2](#phase-2-reverse-proxy-stack) end-to-end:
- Create directory structure (2.1)
- Create `nginx.conf` (2.2)
- Create `docker-compose.yml` (2.3)
- Create default catch-all and HTTP placeholder configs (2.4)
- Generate fallback certificate and start stack (2.5)

**If restoring from backup:**

```bash
# Restore nginx configs and certbot data before starting
cp -r /tmp/restore/nginx/* ~/reverse-proxy/nginx/
cp -r /tmp/restore/certbot-conf/* ~/reverse-proxy/certbot/conf/
```

#### 7.4 Issue SSL Certificate

→ Follow [Phase 3](#phase-3-ssl--https) sections 3.1–3.3:
- Set Cloudflare to DNS Only (3.1)
- Issue certificate (3.2)
- Enable HTTPS (3.3)

#### 7.5 Deploy Application

→ Follow [Phase 4](#phase-4-application-deployment) sections 4.1–4.2:
- Create project directory and files (4.1)
- Restore `.env` files from backup
- Authenticate with GHCR and start (4.1)
- Integrate with reverse proxy (4.2)

#### 7.6 Restore Automation

→ Follow [Phase 3.5](#35-automated-ssl-renewal):

```bash
crontab -e
```

Add:

```cron
0 3 * * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --quiet && /usr/bin/docker exec reverse-proxy-nginx nginx -s reload
0 5 1 * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --dry-run --quiet
```

#### 7.7 Update DNS If IP Changed

If the new VPS has a different IP, update the Cloudflare A record:

```
gateway.example.com A → NEW_VPS_IP (Proxied, orange cloud)
```

#### 7.8 Run Production Validation

→ Execute [Phase 5](#phase-5-production-validation) checklist end-to-end.

### Recovery Checklist

```txt
Phase 1: Infrastructure
  ✓ New VPS provisioned and accessible
  ✓ Docker installed and running
  ✓ UFW configured (80, 443, SSH)
  ✓ shared-network created

Phase 2: Reverse Proxy
  ✓ Directory structure created
  ✓ nginx.conf created
  ✓ docker-compose.yml created
  ✓ Fallback certificate generated
  ✓ Containers running
  ✓ Config validated

Phase 3: SSL
  ✓ Cloudflare set to DNS Only
  ✓ Certificate re-issued
  ✓ HTTPS enabled
  ✓ Cloudflare set to Proxied + Full (strict)
  ✓ Cron jobs restored

Phase 4: Application
  ✓ Container running and healthy
  ✓ Container on shared-network
  ✓ proxy_pass configured
  ✓ Health checks passing

Phase 5: Validation
  ✓ All 12 validation checks pass
```

---

## Appendix: Emergency & Operational Commands

### Container Management

```bash
# Reload Nginx (zero-downtime config reload)
docker exec reverse-proxy-nginx nginx -s reload

# Restart Nginx container (brief downtime)
docker compose -f ~/reverse-proxy/docker-compose.yml restart nginx

# Restart application
docker compose -f ~/ai-gateway/docker-compose.yml restart app

# Follow Nginx logs
docker compose -f ~/reverse-proxy/docker-compose.yml logs -f nginx

# Follow application logs
docker compose -f ~/ai-gateway/docker-compose.yml logs -f app

# View certbot logs
docker exec reverse-proxy-certbot tail -30 /var/log/letsencrypt/letsencrypt.log

# Complete shutdown (preserves volumes)
docker compose -f ~/reverse-proxy/docker-compose.yml down
docker compose -f ~/ai-gateway/docker-compose.yml down

# Complete startup
docker compose -f ~/reverse-proxy/docker-compose.yml up -d
docker compose -f ~/ai-gateway/docker-compose.yml up -d
```

### Network Debugging

```bash
# List containers on shared network
docker network inspect shared-network --format '{{range .Containers}}{{.Name}} {{end}}'

# Resolve container hostname from nginx
docker exec reverse-proxy-nginx getent hosts ai-gateway-server

# Curl application from nginx container
docker exec reverse-proxy-nginx wget -qO- http://ai-gateway-server:8900/health

# Full network membership with IPs
docker network inspect shared-network | grep -E '"Name"|"IPv4Address"'
```

### SSL Emergency

```bash
# Force immediate renewal
docker exec reverse-proxy-certbot certbot renew --force-renewal
docker exec reverse-proxy-nginx nginx -s reload

# Check all certificates
docker exec reverse-proxy-certbot certbot certificates

# Delete and re-issue certificate
docker exec reverse-proxy-certbot certbot delete --cert-name gateway.example.com
docker exec reverse-proxy-certbot certbot certonly \
  --webroot --webroot-path /var/www/certbot \
  -d gateway.example.com \
  --email your-email@example.com \
  --agree-tos --non-interactive
docker exec reverse-proxy-nginx nginx -s reload

# Test renewal pipeline
docker exec reverse-proxy-certbot certbot renew --dry-run
```

### Nginx Config Rollback

```bash
cp ~/reverse-proxy/nginx/sites/gateway.example.com.conf.bak \
   ~/reverse-proxy/nginx/sites/gateway.example.com.conf
docker exec reverse-proxy-nginx nginx -t && docker exec reverse-proxy-nginx nginx -s reload
```

### Quick Health Status

```bash
echo "=== Containers ===" \
  && docker ps --format "table {{.Names}}\t{{.Status}}" \
  && echo "" \
  && echo "=== Health Endpoint ===" \
  && curl -sf https://gateway.example.com/health && echo "" \
  && echo "" \
  && echo "=== SSL Expiry ===" \
  && echo | openssl s_client -servername gateway.example.com \
       -connect gateway.example.com:443 2>/dev/null \
     | openssl x509 -noout -enddate
```

---

## Final Architecture

```
~/reverse-proxy
├── docker-compose.yml
├── nginx
│   ├── nginx.conf
│   ├── sites/
│   │   ├── default.conf
│   │   └── gateway.example.com.conf
│   ├── includes/
│   └── ssl/default/
│       ├── fullchain.pem
│       └── privkey.pem
├── certbot
│   ├── conf/
│   └── www/
└── scripts/
    └── daily-check.sh

~/ai-gateway
├── docker-compose.yml
└── .env
```

**Architecture Rules:**
- `reverse-proxy` owns all nginx, SSL, and certbot resources.
- Each application has its own isolated directory.
- All containers connect through `shared-network` Docker bridge.
- Only `reverse-proxy` exposes ports 80 and 443 to the internet.
- Applications expose ports internally only (`expose` in compose, not `ports`).
