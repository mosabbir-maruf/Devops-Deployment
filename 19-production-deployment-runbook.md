# Production Deployment Runbook

## Table Of Contents

- [Phase 1: Server Validation](#phase-1-server-validation)
- [Phase 2: Create Shared Network](#phase-2-create-shared-network)
- [Phase 3: Create Reverse Proxy Folder Structure](#phase-3-create-reverse-proxy-folder-structure)
- [Phase 4: Create nginx.conf](#phase-4-create-nginxconf)
- [Phase 5: Create Reverse Proxy docker-compose.yml](#phase-5-create-reverse-proxy-docker-composeyml)
- [Phase 6: Create First Domain Config](#phase-6-create-first-domain-config)
- [Phase 7: Start Reverse Proxy](#phase-7-start-reverse-proxy)
- [Phase 8: Cloudflare DNS Setup](#phase-8-cloudflare-dns-setup)
- [Phase 9: Generate SSL Certificate](#phase-9-generate-ssl-certificate)
- [Phase 10: Enable HTTPS](#phase-10-enable-https)
- [Phase 11: Deploy AI Gateway](#phase-11-deploy-ai-gateway)
- [Phase 12: Connect AI Gateway To Shared Network](#phase-12-connect-ai-gateway-to-shared-network)
- [Phase 13: Update Reverse Proxy With proxy_pass](#phase-13-update-reverse-proxy-with-proxypass)
- [Phase 14: Production Validation](#phase-14-production-validation)
- [Phase 15: SSL Renewal Setup](#phase-15-ssl-renewal-setup)
- [Phase 16: Routine Maintenance](#phase-16-routine-maintenance)
- [Phase 17: Disaster Recovery](#phase-17-disaster-recovery)
- [Appendix: Emergency Commands](#appendix-emergency-commands)

---

> **Note:** All domains, email addresses, usernames, registry paths, and IP addresses in this document are examples only and should be replaced with your own production values.

# Phase 1: Server Validation

## Goal

Confirm that Docker, Docker Compose, networking, and the firewall are working on a fresh Ubuntu VPS.

## Commands

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Check Docker is running
sudo systemctl status docker --no-pager

# Check public IP
curl -s ifconfig.me

# Check firewall status
sudo ufw status verbose

# Check current listening ports
sudo ss -tulpn
```

## Expected Output

```txt
docker --version
Docker version 27.5.1, build ...

docker compose version
Docker Compose version 2.32.0

sudo systemctl status docker --no-pager
● docker.service - Docker Application Container Engine
     Loaded: loaded
     Active: active (running)

curl -s ifconfig.me
198.51.100.100

sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing)
New profiles: skip

To                         Action      From
--                         ------      ----
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
22/tcp                     ALLOW IN    Anywhere
```

## Troubleshooting

```txt
Error: "docker: command not found"
Fix: Install Docker:
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  Log out and back in.

Error: "docker compose: command not found"
Fix: Install Docker Compose plugin:
  sudo apt install docker-compose-plugin -y

Error: "UFW is inactive"
Fix: Enable UFW:
  sudo ufw --force enable

Error: "80/tcp and 443/tcp not in UFW rules"
Fix: Open ports:
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  sudo ufw reload
```

## Next Step

Proceed to Phase 2.

---

# Phase 2: Create Shared Network

## Goal

Create the Docker bridge network that all containers will share.

## Commands

```bash
docker network create --driver bridge --attachable shared-network
```

## Verification

```bash
docker network ls
```

## Expected Output

```txt
NETWORK ID     NAME              DRIVER    SCOPE
abc12345       shared-network    bridge    local
def67890       bridge            bridge    local
```

## Detailed Inspection

```bash
docker network inspect shared-network
```

## Expected Output

```json
[
    {
        "Name": "shared-network",
        "Driver": "bridge",
        "Scope": "local",
        "Attachable": true,
        "Containers": {}
    }
]
```

## Troubleshooting

```txt
Error: "network with name shared-network already exists"
Fix: This is fine. The network already exists. Run the verification command to confirm.

Error: "Pool overlaps with other one on this address space"
Fix: Prune unused networks and retry:
  docker network prune -f
  docker network create --driver bridge --attachable shared-network
```

## Next Step

Proceed to Phase 3.

---

# Phase 3: Create Reverse Proxy Folder Structure

## Goal

Create the directory structure for the reverse proxy stack at `~/reverse-proxy`.

## Commands

```bash
mkdir -p ~/reverse-proxy/{nginx/{sites,includes,ssl/default},certbot/{conf,www},scripts}
cd ~/reverse-proxy
```

## Verification

```bash
find ~/reverse-proxy -type d | sort
```

## Expected Output

```txt
reverse-proxy/
├── certbot/
│   ├── conf/
│   └── www/
├── nginx/
│   ├── includes/
│   ├── sites/
│   └── ssl/
│       └── default/
└── scripts/
```

## Verify Ownership

```bash
ls -la ~/reverse-proxy
```

## Expected Output

```txt
total 20
drwxrwxr-x 5 mosabbir mosabbir 4096 Jun 11 18:52 .
drwxr-x--- 5 mosabbir mosabbir 4096 Jun 11 18:52 ..
drwxrwxr-x 4 mosabbir mosabbir 4096 Jun 11 18:52 certbot
drwxrwxr-x 5 mosabbir mosabbir 4096 Jun 11 18:52 nginx
drwxrwxr-x 2 mosabbir mosabbir 4096 Jun 11 18:52 scripts
```

## Next Step

Proceed to Phase 4.

---

# Final Folder Structure

Expected production directory layout after all phases:

```txt
~/reverse-proxy
├── docker-compose.yml
├── nginx
│   ├── nginx.conf
│   ├── sites
│   │   ├── default.conf
│   │   ├── gateway.example.com.conf
│   │   └── api.example.com.conf
│   ├── includes
│   └── ssl
│       └── default
│           ├── fullchain.pem
│           └── privkey.pem
├── certbot
│   ├── conf
│   └── www
└── scripts
    └── daily-check.sh

~/ai-gateway
├── docker-compose.yml
└── .env

~/api
├── docker-compose.yml
└── .env
```

- `reverse-proxy` contains all nginx, SSL, and certbot resources.
- Each application has its own isolated directory.
- All projects connect through the `shared-network` Docker network.
- Only `reverse-proxy` exposes ports 80 and 443 to the internet.

---

# Phase 4: Create nginx.conf

## Goal

Create the main Nginx configuration file.

## File Path

`~/reverse-proxy/nginx/nginx.conf`

## Commands

```bash
nano ~/reverse-proxy/nginx/nginx.conf
```

## Exact File Content

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

## Save The File

1. Press `Ctrl+O` to write the file
2. Press `Enter` to confirm the filename
3. Press `Ctrl+X` to exit

## Verification

```bash
cat ~/reverse-proxy/nginx/nginx.conf | head -5
```

## Expected Output

```txt
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
pid /var/run/nginx.pid;
```

## Next Step

Proceed to Phase 5.

---

# Phase 5: Create Reverse Proxy docker-compose.yml

## Goal

Create the Docker Compose file that runs Nginx and Certbot.

## File Path

`~/reverse-proxy/docker-compose.yml`

## Command

```bash
nano ~/reverse-proxy/docker-compose.yml
```

## Exact File Content

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

The `restart: unless-stopped` directive means:
- Container crash → Docker automatically restarts it.
- VPS reboot → Container automatically starts.
- Docker service restart → Container automatically starts.
- Manual `docker stop` → Container remains stopped until manually started.

## Verification

```bash
cat ~/reverse-proxy/docker-compose.yml | head -10
```

## Expected Output

```txt
services:
  nginx:
    image: nginx:1.27-alpine
    container_name: reverse-proxy-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
```

## Next Step

Proceed to Phase 6.

---

# Phase 6: Create First Domain Config

## Goal

Create the Nginx site configuration for gateway.example.com.

## File Path

`~/reverse-proxy/nginx/sites/gateway.example.com.conf`

## Commands

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

## Exact File Content

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

This creates a temporary HTTP-only endpoint used to verify that Nginx is working before SSL is configured.

## Verification

```bash
cat ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

## Expected Output

```txt
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

## Default Catch-All Block

Create a default server block to catch unmatched requests:

```bash
nano ~/reverse-proxy/nginx/sites/default.conf
```

Exact content:

```nginx
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

server {
    listen 443 ssl default_server;
    server_name _;

    ssl_certificate /etc/nginx/ssl/default/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/default/privkey.pem;

    return 444;
}
```

## Troubleshooting

```txt
Error: "File name must end with .conf"
Fix: Nginx only includes *.conf files from the sites directory.
     Make sure the filename ends with .conf

Error: "Typo in server_name"
Fix: Must match your domain exactly. Copy-paste: gateway.example.com
```

## Next Step

Proceed to Phase 7.

---

# Phase 7: Start Reverse Proxy

## Goal

Start the Nginx and Certbot containers.

## Generate Self-Signed Fallback Certificate

The default SSL block requires a certificate file. Generate a placeholder:

```bash
docker run --rm \
  -v ~/reverse-proxy/nginx/ssl/default:/certs alpine sh -c \
  "apk add openssl && openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /certs/privkey.pem -out /certs/fullchain.pem \
  -subj '/CN=localhost'"
```

## Start The Stack

```bash
cd ~/reverse-proxy
docker compose up -d
```

## Verification

```bash
docker compose ps
```

## Expected Output

```txt
NAME                    IMAGE                 COMMAND                  SERVICE    CREATED         STATUS         PORTS
reverse-proxy-nginx     nginx:1.27-alpine     "/docker-entrypoint.…"   nginx      5 seconds ago   Up 5 seconds   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
reverse-proxy-certbot   certbot/certbot:v2.9.0 "sleep infinity"        certbot    5 seconds ago   Up 5 seconds
```

## Verify Nginx Config Is Valid

```bash
docker exec reverse-proxy-nginx nginx -t
```

## Expected Output

```txt
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

## Verify Nginx Responds

```bash
curl -H "Host: gateway.example.com" http://localhost
```

This sends a request with the specific virtual host header, verifying Nginx routes to the correct server block instead of hitting the default catch-all block.

## Expected Output

```txt
Nginx OK
```

Nginx returns the configured response from the gateway.example.com server block.

## Verify Stack Is On Shared Network

```bash
docker network inspect shared-network
```

## Expected Output (Containers Section)

```json
"Containers": {
    "abc...": {
        "Name": "reverse-proxy-nginx",
    },
    "def...": {
        "Name": "reverse-proxy-certbot",
    }
}
```

## Troubleshooting

```txt
Error: "port is already allocated"
Fix: Something else is using port 80 or 443:
  sudo ss -tulpn | grep -E ":80 |:443 "
  Stop the conflicting service, e.g.:
  sudo systemctl stop nginx
  sudo systemctl disable nginx

Error: "cannot load certificate"
Fix: The self-signed fallback certificate is missing:
  ls -la ~/reverse-proxy/nginx/ssl/default/
  Regenerate using the docker run command above.

Error: "Network shared-network not found"
Fix: Create the network:
  docker network create --driver bridge --attachable shared-network
```

## Next Step

Proceed to Phase 8.

---

# Phase 8: Cloudflare DNS Setup

## Goal

Configure Cloudflare DNS for gateway.example.com with DNS Only mode (gray cloud).

## Steps

1. Log in to your Cloudflare dashboard at `https://dash.cloudflare.com`.
2. Select your domain zone in Cloudflare (for example: **animewarp.app**).
3. Go to **DNS** → **Records**.
4. Add a new A record:

```txt
Type:   A
Name:   gateway
IPv4:   <YOUR_VPS_IP>
Proxy Status: DNS Only (gray cloud)
TTL:    Auto
```

5. Click **Save**.

## Verification

Wait 1-2 minutes, then run:

```bash
dig gateway.example.com +short
```

## Expected Output

```txt
198.51.100.100
```

The output must be your VPS IP address (not a Cloudflare IP).

## If Proxy Is Enabled (Wrong)

```txt
dig gateway.example.com +short
104.16.x.x
172.64.x.x
```

If you see Cloudflare IPs (104.x.x.x or 172.x.x.x), the record is set to Proxied (orange cloud). Change it to **DNS Only** (gray cloud) before proceeding.

## Confirm Reachability

```bash
curl -I http://gateway.example.com
```

## Expected Output

```txt
HTTP/1.1 200 OK
```

The 200 OK response is correct because the Phase 6 config returns a simple health check before SSL is configured.

## Troubleshooting

```txt
Error: "curl: (6) Could not resolve host"
Fix: DNS has not propagated yet. Wait a few minutes and retry:
  dig gateway.example.com +short

Error: "curl: (7) Failed to connect"
Fix: Port 80 is blocked by UFW or Nginx is not running:
  sudo ufw status | grep 80
  docker compose ps | grep nginx

Error: "curl: (52) Empty reply from server"
Fix: This is Nginx's default server block (444) responding.
     The server_name is not matching yet because DNS just propagated.
     This is expected and will resolve when the server_name matches.
```

## Next Step

Proceed to Phase 9.

---

# Phase 9: Generate SSL Certificate

## Goal

Issue a Let's Encrypt SSL certificate for gateway.example.com.

## Pre-Flight Checks

Before running certbot, confirm:

```bash
# DNS is resolving to VPS IP (not Cloudflare)
dig gateway.example.com +short
# Expected: your VPS IP

# Port 80 is reachable from the internet
curl -sI http://gateway.example.com | head -1
# Expected: HTTP/1.1 200 OK

# ACME challenge path is served
curl -sI http://gateway.example.com/.well-known/acme-challenge/test
# Expected: 404 (the file doesn't exist, but the route is valid)
```

## Generate Certificate

```bash
docker exec reverse-proxy-certbot certbot certonly --webroot --webroot-path /var/www/certbot -d gateway.example.com --email your-email@example.com --agree-tos --non-interactive
```

## Expected Success Output

```txt
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for gateway.example.com

Successfully received certificate.
Certificate is saved at:
  /etc/letsencrypt/live/gateway.example.com/fullchain.pem
Key is saved at:
  /etc/letsencrypt/live/gateway.example.com/privkey.pem
This certificate expires on 2026-09-09.
These files will be updated when the certificate renews.
```

## Where Certificates Are Stored

```txt
Host path:
  ~/reverse-proxy/certbot/conf/live/gateway.example.com/
    ├── cert.pem       → server certificate only
    ├── chain.pem      → intermediate CA certificates
    ├── fullchain.pem  → cert.pem + chain.pem
    └── privkey.pem    → private key (keep secret)

Container path (mapped from host):
  /etc/letsencrypt/live/gateway.example.com/
```

## Verification

## List all certificates
```bash
docker exec reverse-proxy-certbot certbot certificates
```

## Expected Output

```txt
Found the following certs:
  Certificate Name: gateway.example.com
    Domains: gateway.example.com
    Expiry Date: 2026-09-09 12:00:00+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/gateway.example.com/fullchain.pem
```
## Verify certificate files exist on the host
```bash
sudo ls -la ~/reverse-proxy/certbot/conf/live/gateway.example.com/
```

## Expected Output

```txt
total ...
lrwxrwxrwx ... cert.pem -> ../../archive/gateway.example.com/cert1.pem
lrwxrwxrwx ... chain.pem -> ...
lrwxrwxrwx ... fullchain.pem -> ...
lrwxrwxrwx ... privkey.pem -> ...
-rw-r--r-- ... README
```

## Troubleshooting

```txt
Error: "Could not connect to server"
  Problem: Port 80 is blocked or Nginx is not running.
  Fix:
    sudo ufw status | grep 80/tcp
    docker compose ps | grep nginx
    dig gateway.example.com +short

Error: "The server could not connect to the client to verify the domain"
  Problem: Cloudflare is proxying the request (orange cloud).
  Fix: Change the DNS record to DNS Only (gray cloud) and wait 2 minutes.

Error: "too many certificates already issued"
  Problem: Let's Encrypt rate limit (50 certs/week per domain).
  Fix: Wait a week or use the staging environment:
    --server https://acme-staging-v02.api.letsencrypt.org/directory
```

## Next Step

Proceed to Phase 10.

---

# Phase 10: Enable HTTPS

## Goal

Add the HTTPS server block to the Nginx site config and turn on SSL.

## File Path

`~/reverse-proxy/nginx/sites/gateway.example.com.conf`

## Command

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

## Exact File Content (Replace The Entire File)

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
        return 200 "Service Available\n\nThis domain is configured correctly and is responding successfully.\n\nThe application content has not been published yet.\n\nPlease check back later.";
    }
}
```

## Validate And Reload

### Test configuration
```bash
docker exec reverse-proxy-nginx nginx -t
```

### If syntax is ok, reload
```bash
docker exec reverse-proxy-nginx nginx -s reload
```

## Verification Test HTTPS

```bash
curl -I https://gateway.example.com
```

## Expected Output

```txt
HTTP/2 200
server: nginx
content-type: text/plain
strict-transport-security: max-age=31536000; includeSubDomains
```

## Verify SSL Certificate

```bash
echo | openssl s_client -servername gateway.example.com \
  -connect gateway.example.com:443 2>/dev/null \
  | openssl x509 -noout -issuer -subject -dates
```

## Expected Output

```txt
issuer= /C=US/O=Let's Encrypt/CN=R11
subject= CN=gateway.example.com
notBefore=Jun 11 00:00:00 2026 GMT
notAfter=Sep  9 00:00:00 2026 GMT
```

## Update Cloudflare DNS

1. Go back to Cloudflare dashboard.
2. Change the A record from **DNS Only** (gray) to **Proxied** (orange).
3. Set **SSL/TLS** → **Full (strict)**.
4. Enable **Always Use HTTPS**.

```txt
Cloudflare settings after SSL:
  Proxy Status: Proxied (orange cloud)
  SSL/TLS Mode: Full (strict)
  Always Use HTTPS: On
```

## Verify Via Cloudflare

```bash
curl -I https://gateway.example.com
```

The connection now goes through Cloudflare.

## Troubleshooting

```txt
Error: "nginx: [emerg] cannot load certificate"
  Problem: The certificate file path is wrong.
  Fix: Verify the path:
    docker exec reverse-proxy-nginx ls -la /etc/letsencrypt/live/gateway.example.com/
  The path in the container must match what certbot created.

Error: "525 SSL handshake failed"
  Problem: Cloudflare Full (strict) is set but the origin certificate
           is missing or invalid.
  Fix: Temporarily set Cloudflare SSL to Full (not strict).
       Then verify the certificate:
         docker exec reverse-proxy-certbot certbot certificates
       Fix the certificate issue, then set back to Full (strict).

Error: "curl: (35) SSL routines error"
  Problem: Nginx SSL configuration issue.
  Fix: Check Nginx error logs:
    docker exec reverse-proxy-nginx tail -20 /var/log/nginx/error.log
```

## Next Step

Proceed to Phase 11.

---

# Phase 11: Deploy AI Gateway

## Goal

Deploy the AI Gateway application using an image from GHCR.

## Create Project Directory

```bash
mkdir -p ~/ai-gateway
cd ~/ai-gateway
```

## Create Project docker-compose.yml

```bash
nano ~/ai-gateway/docker-compose.yml
```

Exact content (without connecting to shared-network yet):

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
```

> **Note:** If your application exposes a different health endpoint, update the path in `healthcheck.test` above.

> **Note:** This healthcheck requires `wget` inside the application container. If `wget` is unavailable, replace `wget` with `curl` in the healthcheck command.

## Create .env File

```bash
nano ~/ai-gateway/.env
```

Exact content (replace with your actual secrets):

```env
NODE_ENV=production
PORT=8900
```

Add any other environment variables your AI Gateway needs (API keys, database URLs, etc.).

Secure the file:

```bash
chmod 600 ~/ai-gateway/.env
```

## Authenticate With GHCR

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u your-github-username --password-stdin
```

If you don't have a token, create one at GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens. Grant permission to read packages (GHCR).

## Pull The Image

```bash
docker compose pull
```

## Expected Output

```txt
Pulling app ... pulling from ghcr.io/your-github-username/ai-gateway
latest: Pulling from your-github-username/ai-gateway
Digest: sha256:abc123def456...
Status: Downloaded newer image for ghcr.io/your-github-username/ai-gateway:latest
```

## Run The Container

```bash
docker compose up -d
```

## Verification

```bash
docker compose ps
```

## Expected Output

```txt
NAME                IMAGE                                      STATUS
ai-gateway-server   ghcr.io/your-github-username/ai-gateway:latest   Up 10 seconds (healthy)
```

## Check Logs

```bash
docker compose logs app --tail 20
```

## Expected Output

```txt
app    | Server started on port 8900
app    | Health check passed
```

## Troubleshooting

```txt
Error: "unauthorized: authentication required"
  Fix: Log in to GHCR:
    echo $GITHUB_TOKEN | docker login ghcr.io -u your-github-username --password-stdin

Error: "manifest not found"
  Fix: The image tag doesn't exist. Check the tag on GHCR:
    Check your repository's Packages page in GitHub.

Error: "container exits immediately"
  Fix: Check logs:
    docker compose logs app
  Common cause: missing .env variables or the app requires port 8900.

Error: ".env file not found"
  Fix: Create the .env file:
    nano ~/ai-gateway/.env
```

## Next Step

Proceed to Phase 12.

---

# Phase 12: Connect AI Gateway To Shared Network

## Goal

Connect the AI Gateway container to the shared-network so the reverse proxy can reach it.

## Edit docker-compose.yml

```bash
nano ~/ai-gateway/docker-compose.yml
```

Replace the entire file with:

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

> **Note:** Edit the `healthcheck.test` path to match your application's actual health endpoint. The examples throughout this guide use `HEALTH_ENDPOINT="/health"`.

Changes from the previous version:

```txt
Added:
  networks:
    - shared-network

Added at bottom:
networks:
  shared-network:
    external: true
    name: shared-network
```

## Recreate The Container

```bash
cd ~/ai-gateway
docker compose down
docker compose up -d
```

## Verify Network Connection

```bash
docker network inspect shared-network
```

## Expected Output (Containers Section)

```json
"Containers": {
    "abc...": {
        "Name": "reverse-proxy-nginx",
    },
    "def...": {
        "Name": "reverse-proxy-certbot",
    },
    "ghi...": {
        "Name": "ai-gateway-server",
    }
}
```

## Test Connectivity From Nginx

```bash
docker exec reverse-proxy-nginx getent hosts ai-gateway-server
```

## Expected Output

```txt
172.19.0.4    ai-gateway-server
```

## Test The Health Endpoint Through The Network

```bash
HEALTH_ENDPOINT="/health"
docker exec reverse-proxy-nginx wget -qO- http://ai-gateway-server:8900${HEALTH_ENDPOINT}
```

## Expected Output

```json
{"status":"healthy","uptime":123.45}
```

## Troubleshooting

```txt
Error: "host not found"
  Problem: The container is not on the shared-network.
  Fix:
    docker network inspect shared-network
    If ai-gateway-server is not listed, the network change was not applied.
    Run: docker compose down && docker compose up -d

Error: "wget: can't connect to remote host: Connection refused"
  Problem: The app is not listening on port 8900.
  Fix: Check the app logs:
    docker compose logs app --tail 20

Error: "network shared-network not found"
  Problem: The network was not created (Phase 2).
  Fix: Create it:
    docker network create --driver bridge --attachable shared-network
```

## Next Step

Proceed to Phase 13.

---

# Phase 13: Update Reverse Proxy With proxy_pass

## Goal

Replace the placeholder response in the Nginx config with an actual proxy_pass to the AI Gateway.

## File Path

`~/reverse-proxy/nginx/sites/gateway.example.com.conf`

## Command

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

## Exact File Content (Replace The Entire File)

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

The key change:

```txt
Old:  return 200 "Service Available...";
New:  proxy_pass http://ai-gateway-server:8900;
```

## Validate And Reload

```bash
docker exec reverse-proxy-nginx nginx -t
docker exec reverse-proxy-nginx nginx -s reload
```

## Verification

```bash
HEALTH_ENDPOINT="/health"
curl -I https://gateway.example.com${HEALTH_ENDPOINT}
curl -s https://gateway.example.com${HEALTH_ENDPOINT}
```

## Expected Output

```txt
HTTP/2 200
content-type: application/json
```

## Full Health Check

```bash
HEALTH_ENDPOINT="/health"
curl -s https://gateway.example.com${HEALTH_ENDPOINT} | python3 -m json.tool
```

## Expected Output

```json
{
    "status": "healthy",
    "uptime": 1234.56
}
```

## Check Nginx Access Logs

```bash
docker exec reverse-proxy-nginx tail -10 /var/log/nginx/gateway-access.log
```

## Expected Output

```json
{"time":"2026-06-11T10:30:00+00:00","remote_addr":"198.51.100.10","request":"GET /health HTTP/2","status":200,"upstream_addr":"172.19.0.4:8900"}
```

## Troubleshooting

```txt
Error: "502 Bad Gateway"
  Problem: Nginx cannot reach ai-gateway-server:8900.
  Fix:
    HEALTH_ENDPOINT="/health"
    docker exec reverse-proxy-nginx getent hosts ai-gateway-server
    docker exec reverse-proxy-nginx wget -qO- http://ai-gateway-server:8900${HEALTH_ENDPOINT}
    docker network inspect shared-network

Error: "host not found in upstream ai-gateway-server"
  Problem: The container name does not match.
  Fix:
    docker ps | grep ai-gateway
    Check the container_name in ~/ai-gateway/docker-compose.yml
    Must match: container_name: ai-gateway-server

Error: "nginx: [emerg] invalid port in upstream"
  Problem: Typo in proxy_pass (missing colon or port).
  Fix: Check the line:
    proxy_pass http://ai-gateway-server:8900;
  Must be exactly this format.

Error: "504 Gateway Timeout"
  Problem: The AI Gateway is not responding in time.
  Fix: Check if the container is healthy:
    docker inspect ai-gateway-server --format='{{.State.Health.Status}}'
  Add timeout settings to proxy_pass:
    proxy_connect_timeout 60s;
    proxy_read_timeout 60s;
```

## Next Step

Proceed to Phase 14.

---

# Phase 14: Production Validation

## Goal

Run the complete production validation checklist.

## 1. HTTPS Works

```bash
curl -sI https://gateway.example.com | head -1
```

Expected: `HTTP/2 200`

## 2. HTTP Redirects To HTTPS

```bash
curl -sI http://gateway.example.com | head -1
```

Expected: `HTTP/1.1 301 Moved Permanently`

## 3. SSL Certificate Valid

```bash
echo | openssl s_client -servername gateway.example.com \
  -connect gateway.example.com:443 2>/dev/null \
  | openssl x509 -noout -dates
```

Expected: Not Before and Not After dates are current.

## 4. HSTS Header Present

```bash
curl -sI https://gateway.example.com | grep -i strict-transport
```

Expected: `strict-transport-security: max-age=31536000; includeSubDomains`

## 5. Container Healthy

```bash
docker inspect ai-gateway-server --format='{{.State.Health.Status}}'
```

Expected: `healthy`

## 6. Health Endpoint Returns 200

```bash
HEALTH_ENDPOINT="/health"
curl -sf https://gateway.example.com${HEALTH_ENDPOINT} && echo "OK"
```

Expected: `OK`

## 7. Logs Clean

```bash
docker compose -f ~/ai-gateway/docker-compose.yml logs app --tail 20
```

Expected: No error stack traces. No connection refused messages. No crash loops.

## 8. No Exposed App Ports

```bash
sudo ss -tulpn | grep ":8900"
```

Expected: No output. Port 8900 must not be listening on the host.

## 9. Only Expected Ports Open

```bash
sudo ss -tulpn | grep LISTEN
```

Expected:

```txt
tcp  LISTEN 0  ... :80     ...
tcp  LISTEN 0  ... :443    ...
tcp  LISTEN 0  ... :22     ...
```

## 10. Direct IP Access Blocked

```bash
curl -sI http://$(curl -s ifconfig.me) | head -1
```

Expected: Empty response or `curl: (52) Empty reply from server` (444).

## 11. Cloudflare Proxying

```bash
dig gateway.example.com +short
```

Expected: Cloudflare IPs (104.x.x.x, 172.x.x.x). If your VPS IP appears, the record is set to DNS Only.

## 12. Certificate Renewal Dry-Run Works

```bash
docker exec reverse-proxy-certbot certbot renew --dry-run
```

Expected:

```txt
Cert not due for renewal at least 30 days before expiry, but dry run executed.
** DRY RUN: simulating 'certbot renew' close to cert expiry
**          (The test certificates below have not been saved.)
...
** DRY RUN: finishing
```

## Production Validation Checklist

```txt
✓ HTTPS works (200 OK)
✓ HTTP redirects to HTTPS (301)
✓ SSL certificate valid (dates current)
✓ HSTS header present
✓ Container healthy
✓ Health endpoint returns 200
✓ Logs clean (no errors)
✓ No exposed app ports (8900)
✓ Only 80, 443, SSH listening externally
✓ Direct IP access returns 444
✓ Cloudflare proxying (orange cloud)
✓ Certbot dry-run passes
```

## Next Step

Proceed to Phase 15.

---

# Phase 15: SSL Renewal Setup

## Goal

Set up automated SSL certificate renewal and verify it works.

> **Important:** SSL renewal depends on the host cron jobs configured in this phase. The certbot container does not automatically renew certificates by itself.

## Step 15.1 — Manual Renewal Test

```bash
docker exec reverse-proxy-certbot certbot renew --dry-run
```

## Expected Output

```txt
Cert not due for renewal, but dry run executed.
** DRY RUN: simulating 'certbot renew' close to cert expiry
...
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/gateway.example.com/fullchain.pem (success)
```

## Step 15.2 — Set Up Cron For Automatic Renewal

```bash
crontab -e
```

If prompted, select `nano` as the editor. Add the following line at the end of the file:

```cron
0 3 * * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --quiet && /usr/bin/docker exec reverse-proxy-nginx nginx -s reload
```

Save and exit (Ctrl+O, Enter, Ctrl+X).

## Step 15.3 — Verify Cron Job

```bash
crontab -l
```

## Expected Output

```txt
0 3 * * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --quiet && /usr/bin/docker exec reverse-proxy-nginx nginx -s reload
```

## Step 15.4 — Add Monthly Dry-Run

Add a second cron line to verify the renewal pipeline monthly:

```bash
crontab -e
```

Add:

```cron
0 5 1 * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --dry-run --quiet
```

Final crontab should look like:

```txt
0 3 * * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --quiet && /usr/bin/docker exec reverse-proxy-nginx nginx -s reload
0 5 1 * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --dry-run --quiet
```

## Step 15.5 — Verify Cron Syntax

```bash
crontab -l | grep -v "^#" | wc -l
```

Expected: `2` (two active cron jobs).

## Step 15.6 — Verify Crontab Will Work

```bash
which docker
```

Expected: `/usr/bin/docker`

If `which docker` returns a different path, update the crontab entries with the correct path.

## Step 15.7 — View Certbot Logs

```bash
docker exec reverse-proxy-certbot ls -la /var/log/letsencrypt/
```

Expected:

```txt
-rw-r--r--  ... letsencrypt.log
-rw-r--r--  ... letsencrypt.log.1
```

## Troubleshooting

```txt
Error: "crontab: command not found"
  Fix: Install cron:
    sudo apt install cron -y
    sudo systemctl enable cron
    sudo systemctl start cron

Error: "docker: command not found in cron"
  Fix: Use absolute path to docker:
    /usr/bin/docker exec ...
  Verify the docker path: which docker

Error: "Renewal failed: The server could not connect"
  Fix: Check that port 80 is open:
    sudo ufw status | grep 80
  Certbot needs port 80 for the ACME challenge during renewal.
```

## Next Step

Proceed to Phase 16.

---

# Phase 16: Routine Maintenance

## Goal

Define daily, weekly, and monthly maintenance tasks.

## Daily Checks

Run these every morning:

```bash
# 1. Check all containers are running
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected: All containers show `Up` or `Up (healthy)`.

```bash
HEALTH_ENDPOINT="/health"
curl -sf https://gateway.example.com${HEALTH_ENDPOINT} && echo "gateway OK"
```

Expected: Returns `OK`.

```bash
# 3. Check disk space
df -h /
```

Alert if usage > 85%.

```bash
# 4. Check memory
free -h
```

Alert if available memory < 500 MB.

```bash
# 5. Check Nginx errors
docker exec reverse-proxy-nginx tail -5 /var/log/nginx/error.log
```

Expected: No recent error messages.

## Weekly Checks

Run these once per week:

```bash
# 1. Full certificate status
docker exec reverse-proxy-certbot certbot certificates
```

Expected: All domains show VALID with > 30 days remaining.

```bash
# 2. Docker system disk usage
docker system df
```

Check that image and container sizes are not growing unexpectedly.

```bash
# 3. Prune unused Docker images
docker image prune -f
```

```bash
# 4. Check failed SSH login attempts
sudo fail2ban-client status sshd
```

Expected: Status shows jail is active (if fail2ban is installed).

## Monthly Checks

Run these once per month:

```bash
# 1. Full SSL renewal dry run
docker exec reverse-proxy-certbot certbot renew --dry-run
```

Expected: All simulated renewals succeed.

```bash
# 2. Clean up old images
docker image prune -a -f
```

```bash
# 3. Review Nginx access logs for anomalies
docker exec reverse-proxy-nginx sh -c \
  "tail -10000 /var/log/nginx/access.log | grep -o '\"status\":[0-9]*' | sort | uniq -c | sort -rn"
```

Expected: Mostly 200 and 301 status codes. No unusual spike in 4xx or 5xx.

```bash
# 4. Update AI Gateway image
docker compose -f ~/ai-gateway/docker-compose.yml pull
docker compose -f ~/ai-gateway/docker-compose.yml up -d
```

## Quick Daily Script

Create `~/reverse-proxy/scripts/daily-check.sh`:

```bash
#!/bin/bash
echo "=== Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "=== Health Endpoints ==="
HEALTH_ENDPOINT="/health"
for url in https://gateway.example.com${HEALTH_ENDPOINT}; do
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

Make it executable:

```bash
chmod +x ~/reverse-proxy/scripts/daily-check.sh
```

Run it:

```bash
bash ~/reverse-proxy/scripts/daily-check.sh
```

## Next Step

Proceed to Phase 17.

---

# Phase 17: Disaster Recovery

## Goal

Restore the entire production environment on a new VPS after a catastrophic failure.

## Assumptions

```txt
- Old VPS is completely unrecoverable
- You have a new VPS with Ubuntu and Docker installed
- You have SSH access to the new VPS
- You have access to Cloudflare account
- The AI Gateway image is in GHCR at ghcr.io/your-github-username/ai-gateway:latest
- All configuration files are backed up or can be recreated from this runbook
```

## Step 17.1 — Provision New VPS

```bash
# Run on your local machine
ssh root@NEW_VPS_IP

# Basic setup
apt update && apt upgrade -y

# Install Docker if not present
curl -fsSL https://get.docker.com | sh

# Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw --force enable
```

## Step 17.2 — Create Shared Network

```bash
docker network create --driver bridge --attachable shared-network
```

## Step 17.3 — Create Reverse Proxy Folder Structure

```bash
mkdir -p ~/reverse-proxy/{nginx/{sites,includes,ssl/default},certbot/{conf,www},scripts}
```

## Step 17.4 — Create nginx.conf

```bash
nano ~/reverse-proxy/nginx/nginx.conf
```

Paste the content from Phase 4. Save and exit.

## Step 17.5 — Create docker-compose.yml For Reverse Proxy

```bash
nano ~/reverse-proxy/docker-compose.yml
```

Paste the content from Phase 5. Save and exit.

## Step 17.6 — Generate Self-Signed Fallback Certificate

```bash
docker run --rm \
  -v ~/reverse-proxy/nginx/ssl/default:/certs alpine sh -c \
  "apk add openssl && openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /certs/privkey.pem -out /certs/fullchain.pem \
  -subj '/CN=localhost'"
```

## Step 17.7 — Create HTTP-Only Nginx Config

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

Paste the HTTP-only config from Phase 6. Save and exit.

## Step 17.8 — Create default.conf

```bash
nano ~/reverse-proxy/nginx/sites/default.conf
```

Paste the default catch-all block from Phase 6. Save and exit.

## Step 17.9 — Start Reverse Proxy

```bash
cd ~/reverse-proxy
docker compose up -d
```

## Step 17.10 — Validate nginx config and reload

```bash
docker exec reverse-proxy-nginx nginx -t
docker exec reverse-proxy-nginx nginx -s reload
```

## Step 17.11 — Set Cloudflare DNS To DNS Only

Log in to Cloudflare dashboard, set the A record for gateway.example.com to DNS Only (gray cloud).

## Step 17.12 — Re-Issue SSL Certificate

```bash
docker exec reverse-proxy-certbot certbot certonly \
  --webroot --webroot-path /var/www/certbot \
  -d gateway.example.com \
  --email your-email@example.com \
  --agree-tos --non-interactive
```

Expected: `Successfully received certificate.`

## Step 17.13 — Create HTTPS Nginx Config

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

Paste the full SSL config from Phase 10. Save and exit.

## Step 17.14 — Reload Nginx

```bash
docker exec reverse-proxy-nginx nginx -t
docker exec reverse-proxy-nginx nginx -s reload
```

## Step 17.15 — Set Cloudflare Back To Proxied

Log in to Cloudflare dashboard:
1. Change A record to **Proxied** (orange cloud)
2. Set **SSL/TLS** → **Full (strict)**
3. Enable **Always Use HTTPS**

## Step 17.16 — Deploy AI Gateway

```bash
mkdir -p ~/ai-gateway
cd ~/ai-gateway
```

Create `~/ai-gateway/docker-compose.yml` with the content from Phase 12 (with shared-network).

Create `~/ai-gateway/.env` with your environment variables.

```bash
chmod 600 ~/ai-gateway/.env

# Log in to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u your-github-username --password-stdin

# Pull and start
docker compose pull
docker compose up -d
```

## Step 17.17 — Add proxy_pass

```bash
nano ~/reverse-proxy/nginx/sites/gateway.example.com.conf
```

Replace with the full config from Phase 13 (with proxy_pass). Save and exit.

```bash
docker exec reverse-proxy-nginx nginx -t
docker exec reverse-proxy-nginx nginx -s reload
```

## Step 17.18 — Restore Cron Jobs

```bash
crontab -e
```

Add:

```cron
0 3 * * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --quiet && /usr/bin/docker exec reverse-proxy-nginx nginx -s reload
0 5 1 * * /usr/bin/docker exec reverse-proxy-certbot certbot renew --dry-run --quiet
```

## Step 17.19 — Update DNS If IP Changed

If the new VPS has a different IP, update the A record in Cloudflare:
- gateway.example.com A → NEW_VPS_IP (Proxied)

## Step 17.20 — Run Production Validation

Execute the full checklist from Phase 14.

## Recovery Checklist

```txt
Phase 1: Infrastructure
  ✓ New VPS provisioned and accessible
  ✓ Docker installed and running
  ✓ UFW configured (80, 443, SSH)
  ✓ shared-network created

Phase 2: Reverse Proxy
  ✓ Reverse proxy folder structure created
  ✓ nginx.conf created
  ✓ docker-compose.yml created
  ✓ Self-signed fallback cert generated
  ✓ Nginx and Certbot containers running
  ✓ Nginx config validated

Phase 3: SSL
  ✓ Cloudflare set to DNS Only
  ✓ Certificate re-issued for gateway.example.com
  ✓ Site config updated with SSL block
  ✓ Cloudflare set back to Proxied + Full (strict)

Phase 4: AI Gateway
  ✓ AI Gateway container running
  ✓ Container on shared-network
  ✓ proxy_pass configured in Nginx
  ✓ Health checks passing

Phase 5: Automation
  ✓ Cron jobs restored (SSL renewal + dry-run)
  ✓ Daily health check script deployed

Phase 6: DNS
  ✓ A record points to new VPS IP
  ✓ DNS propagation confirmed
  ✓ gateway.example.com accessible via HTTPS
```

## Next Step

No further steps. Deployment is complete.

---

# Appendix: Emergency Commands

## Container Management

```bash
# Reload Nginx (no downtime)
docker exec reverse-proxy-nginx nginx -s reload

# Restart Nginx container (brief downtime)
docker compose -f ~/reverse-proxy/docker-compose.yml restart nginx

# Restart AI Gateway
docker compose -f ~/ai-gateway/docker-compose.yml restart app

# View Nginx logs (live)
docker compose -f ~/reverse-proxy/docker-compose.yml logs -f nginx

# View AI Gateway logs (live)
docker compose -f ~/ai-gateway/docker-compose.yml logs -f app

# View Certbot logs
docker exec reverse-proxy-certbot tail -30 /var/log/letsencrypt/letsencrypt.log
```

## Network Debugging

```bash
# Check shared-network membership
docker network inspect shared-network --format '{{range .Containers}}{{.Name}} {{end}}'

# Resolve AI Gateway hostname from Nginx
docker exec reverse-proxy-nginx getent hosts ai-gateway-server

# Curl AI Gateway from Nginx
HEALTH_ENDPOINT="/health"
docker exec reverse-proxy-nginx wget -qO- http://ai-gateway-server:8900${HEALTH_ENDPOINT}

# Check what containers are on the network
docker network inspect shared-network | grep -E '"Name"|"IPv4Address"'
```

## SSL Emergency

```bash
# Force immediate renewal
docker exec reverse-proxy-certbot certbot renew --force-renewal
docker exec reverse-proxy-nginx nginx -s reload

# Check all certificates
docker exec reverse-proxy-certbot certbot certificates

# Delete a certificate and re-issue
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

## Rollback AI Gateway

```bash
# Rollback to previous image version
cd ~/ai-gateway
# Edit docker-compose.yml to pin a specific tag, then:
docker compose pull app
docker compose up -d --no-deps app
```

## Rollback Nginx Config

```bash
# If you have a backup copy
cp ~/reverse-proxy/nginx/sites/gateway.example.com.conf.bak \
   ~/reverse-proxy/nginx/sites/gateway.example.com.conf
docker exec reverse-proxy-nginx nginx -s reload
```

## Complete Shutdown

```bash
# Stop everything (preserves volumes)
docker compose -f ~/reverse-proxy/docker-compose.yml down
docker compose -f ~/ai-gateway/docker-compose.yml down
```

## Complete Startup

```bash
# Start everything
docker compose -f ~/reverse-proxy/docker-compose.yml up -d
docker compose -f ~/ai-gateway/docker-compose.yml up -d
```

## Quick Health Status

> **Note:** Replace `gateway.example.com` with your actual domain. Change `HEALTH_ENDPOINT` below if your application uses a different health endpoint.

```bash
echo "=== Containers ===" && docker ps --format "table {{.Names}}\t{{.Status}}" && echo "" && echo "=== Health Endpoint ===" && HEALTH_ENDPOINT="/health" && curl -sf https://gateway.example.com${HEALTH_ENDPOINT} && echo "" && echo "" && echo "=== SSL Expiry ===" && echo | openssl s_client -servername gateway.example.com -connect gateway.example.com:443 2>/dev/null | openssl x509 -noout -enddate
```
