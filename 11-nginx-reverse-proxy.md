# Nginx Reverse Proxy

## Table Of Contents

* [1. What Is Nginx](#1-what-is-nginx)
* [2. What Is A Reverse Proxy](#2-what-is-a-reverse-proxy)

### Installation

* [3. Install Nginx On Linux](#3-install-nginx-on-linux)
* [4. Install Nginx On Mac](#4-install-nginx-on-mac)
* [5. Run Nginx With Docker](#5-run-nginx-with-docker)

### Management

* [6. Start Stop Restart Reload](#6-start-stop-restart-reload)
* [7. Verify Installation](#7-verify-installation)
* [8. Nginx File Locations](#8-nginx-file-locations)

### Reverse Proxy

* [9. Create Reverse Proxy](#9-create-reverse-proxy)
* [10. Enable Site](#10-enable-site)
* [11. Multiple Apps](#11-multiple-apps)
* [12. API Reverse Proxy](#12-api-reverse-proxy)
* [13. WebSocket Support](#13-websocket-support)

### SSL

* [14. SSL With Certbot](#14-ssl-with-certbot)
* [15. Cloudflare Origin SSL](#15-cloudflare-origin-ssl)
* [16. Force HTTPS](#16-force-https)

### Security

* [17. Security Headers](#17-security-headers)
* [18. Block Direct IP Access](#18-block-direct-ip-access)
* [19. Hide Backend Ports](#19-hide-backend-ports)
* [20. Rate Limiting](#20-rate-limiting)
* [21. Upload Limits](#21-upload-limits)

### Performance

* [22. HTTP2](#22-http2)
* [23. Gzip Compression](#23-gzip-compression)

### Monitoring

* [24. Logs](#24-logs)
* [25. Monitor Logs](#25-monitor-logs)
* [26. Docker Logs](#26-docker-logs)

### Troubleshooting

* [27. Common Issues](#27-common-issues)

### Cleanup

* [28. Uninstall Nginx On Linux](#28-uninstall-nginx-on-linux)
* [29. Uninstall Nginx On Mac](#29-uninstall-nginx-on-mac)
* [30. Remove Docker Nginx](#30-remove-docker-nginx)

### Production

* [31. Recommended Production Workflow](#31-recommended-production-workflow)
* [32. Production Hardening Checklist](#32-production-hardening-checklist)

# 1. What Is Nginx

Nginx is a high-performance:

* Web Server
* Reverse Proxy
* Load Balancer
* HTTP Cache
* SSL/TLS Termination Server

Used for:

* hosting websites
* reverse proxying applications
* SSL/HTTPS
* API routing
* multiple app hosting
* WebSocket proxying
* serving static files

---

# 2. What Is A Reverse Proxy

A reverse proxy sits between users and backend applications.

Instead of exposing backend services directly to the internet, traffic first reaches Nginx.

Example:

```txt
User
↓
Nginx
↓
Node.js App
```

Production Example:

```txt
User
↓
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
Database
```

Benefits:

* hides backend services
* adds HTTPS
* improves security
* central routing point
* easier scaling
* supports multiple applications

---

# 3. Install Nginx On Linux

## Update System

```bash
sudo apt update
sudo apt upgrade -y
```

---

## Install Nginx

```bash
sudo apt install nginx -y
```

Installs Nginx.

---

## Verify Installation

```bash
nginx -v
```

Example:

```txt
nginx version: nginx/1.26.0
```

---

## Start Nginx

```bash
sudo systemctl start nginx
```

---

## Enable On Boot

```bash
sudo systemctl enable nginx
```

Starts automatically after server reboot.

---

## Verify Service

```bash
sudo systemctl status nginx
```

---

## Allow HTTP & HTTPS

```bash
sudo ufw allow 'Nginx Full'
```

Opens:

```txt
80/tcp
443/tcp
```

---

## Verify Firewall

```bash
sudo ufw status
```

---

# 4. Install Nginx On Mac

## Install Homebrew

Check:

```bash
brew --version
```

---

## Install Nginx

```bash
brew install nginx
```

---

## Verify Installation

```bash
nginx -v
```

---

## Start Nginx

```bash
brew services start nginx
```

---

## Stop Nginx

```bash
brew services stop nginx
```

---

## Restart Nginx

```bash
brew services restart nginx
```

---

## Verify Service

```bash
brew services list
```

Expected:

```txt
nginx started
```

---

# 5. Run Nginx With Docker

## Pull Official Image

```bash
docker pull nginx:alpine
```

Uses lightweight official image.

---

## Run Nginx Container

```bash
docker run -d \
--name nginx \
-p 80:80 \
-p 443:443 \
nginx:alpine
```

---

## Verify Container

```bash
docker ps
```

---

## Check Image

```bash
docker images
```

---

## Stop Container

```bash
docker stop nginx
```

---

## Start Container

```bash
docker start nginx
```

---

## Restart Container

```bash
docker restart nginx
```

---

# 6. Verify Installation

## Linux

```bash
sudo systemctl status nginx
```

---

## Mac

```bash
brew services list
```

---

## Docker

```bash
docker ps
```

---

## Check Listening Ports

Linux / Mac:

```bash
sudo ss -tulpn
```

or

```bash
lsof -i :80
```

---

Docker:

```bash
docker ps
```

Verify:

```txt
0.0.0.0:80->80/tcp
0.0.0.0:443->443/tcp
```

---

## Test Local Response

```bash
curl localhost
```

---

## Check Version

```bash
nginx -v
```

---

# 7. Start Stop Restart Reload

## Linux

### Start

```bash
sudo systemctl start nginx
```

### Stop

```bash
sudo systemctl stop nginx
```

### Restart

```bash
sudo systemctl restart nginx
```

### Reload

```bash
sudo systemctl reload nginx
```

Reload applies configuration changes without restarting workers.

---

## Mac

### Start

```bash
brew services start nginx
```

### Stop

```bash
brew services stop nginx
```

### Restart

```bash
brew services restart nginx
```

---

## Docker

### Start

```bash
docker start nginx
```

### Stop

```bash
docker stop nginx
```

### Restart

```bash
docker restart nginx
```

### Reload Config

```bash
docker exec nginx nginx -s reload
```

---

# 8. Nginx File Locations

## Linux

### Main Config

```txt
/etc/nginx/nginx.conf
```

---

### Site Configurations

```txt
/etc/nginx/sites-available/
```

---

### Enabled Sites

```txt
/etc/nginx/sites-enabled/
```

---

### Logs

```txt
/var/log/nginx/
```

---

### SSL Certificates

```txt
/etc/ssl/
```

or

```txt
/etc/letsencrypt/
```

---

## Mac

### Main Config

```txt
/opt/homebrew/etc/nginx/nginx.conf
```

---

### Logs

```txt
/opt/homebrew/var/log/nginx/
```

---

## Docker

### Main Config

```txt
/etc/nginx/nginx.conf
```

---

### Site Config

```txt
/etc/nginx/conf.d/
```

---

### SSL Folder

```txt
/etc/nginx/ssl/
```

---

### Container Logs

```bash
docker logs nginx
```
# 9. Create Reverse Proxy

## Create Site Configuration

### Linux

```bash
sudo nano /etc/nginx/sites-available/myapp
```

---

### Docker

```bash
mkdir -p nginx

nano nginx/default.conf
```

---

# 10. Basic Reverse Proxy

## Node.js Application

```nginx
server {
    listen 80;

    server_name example.com www.example.com;

    location / {
        proxy_pass http://localhost:3000;

        proxy_http_version 1.1;

        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Routes traffic to a Node.js application.

---

# 11. Enable Site

## Linux

### Create Symlink

```bash
sudo ln -s \
/etc/nginx/sites-available/myapp \
/etc/nginx/sites-enabled/
```

---

### Verify Enabled Site

```bash
ls -la /etc/nginx/sites-enabled/
```

---

## Remove Default Site

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

---

## Test Configuration

```bash
sudo nginx -t
```

---

## Reload Configuration

```bash
sudo systemctl reload nginx
```

---

# 12. Reverse Proxy Multiple Apps

## Example Architecture

```txt
example.com       → Frontend
api.example.com   → Backend API
admin.example.com → Admin Panel
```

Single VPS.

Multiple applications.

Single Nginx instance.

---

## Frontend

```nginx
server {
    listen 80;

    server_name example.com;

    location / {
        proxy_pass http://localhost:3000;
    }
}
```

---

## Backend API

```nginx
server {
    listen 80;

    server_name api.example.com;

    location / {
        proxy_pass http://localhost:5000;
    }
}
```

---

## Admin Panel

```nginx
server {
    listen 80;

    server_name admin.example.com;

    location / {
        proxy_pass http://localhost:4000;
    }
}
```

---

# 13. API Reverse Proxy

## API Example

```nginx
server {
    listen 80;

    server_name api.example.com;

    location / {
        proxy_pass http://localhost:5000;

        proxy_http_version 1.1;

        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

# 14. WebSocket Support

Required for:

* Socket.IO
* Real-Time Apps
* Chat Applications
* Notifications
* Live Dashboards

---

## WebSocket Configuration

```nginx
location / {
    proxy_pass http://localhost:3000;

    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;

    proxy_set_header Connection "upgrade";

    proxy_set_header Host $host;
}
```

---

# 15. Docker Compose Reverse Proxy

## Example Project Structure

```txt
project/
├── docker-compose.yml
├── nginx/
│   └── default.conf
└── app/
```

---

## Example Compose

```yaml
services:
  app:
    image: my-app

    expose:
      - "3000"

  nginx:
    image: nginx:alpine

    container_name: nginx

    restart: unless-stopped

    depends_on:
      - app

    ports:
      - "80:80"

    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
```

---

## Docker Nginx Configuration

```nginx
server {
    listen 80;

    server_name example.com;

    location / {
        proxy_pass http://app:3000;

        proxy_http_version 1.1;

        proxy_set_header Host $host;
    }
}
```

Notice:

```txt
app:3000
```

Docker service name is used instead of localhost.

---

# 16. SSL / HTTPS

## Install Certbot (Linux)

```bash
sudo apt update

sudo apt install certbot python3-certbot-nginx -y
```

---

## Generate SSL Certificate

```bash
sudo certbot --nginx \
-d example.com \
-d www.example.com
```

Automatically:

* generates certificate
* configures Nginx
* enables HTTPS

---

## Verify SSL

```bash
sudo certbot certificates
```

---

## Test Auto Renewal

```bash
sudo certbot renew --dry-run
```

---

## SSL Certificate Location

```txt
/etc/letsencrypt/live/
```

---

# 17. Force HTTPS Redirect

## HTTP → HTTPS

```nginx
server {
    listen 80;

    server_name example.com www.example.com;

    return 301 https://$host$request_uri;
}
```

Redirects all HTTP traffic to HTTPS.

---

# 18. Cloudflare Origin SSL

## Recommended Architecture

```txt
User
↓
Cloudflare
↓
Nginx
↓
Application
```

---

## Create SSL Directory

```bash
mkdir -p nginx/ssl
```

---

## SSL Structure

```txt
nginx/
├── default.conf
└── ssl/
    ├── cert.pem
    └── key.pem
```

---

## Docker Compose Mount

```yaml
volumes:
  - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
  - ./nginx/ssl:/etc/nginx/ssl:ro
```

---

## SSL Configuration

```nginx
ssl_certificate /etc/nginx/ssl/cert.pem;

ssl_certificate_key /etc/nginx/ssl/key.pem;
```

---

## Important

Never commit:

```txt
cert.pem
key.pem
.env
```

to Git repositories.

---

## Git Ignore

```gitignore
.env

nginx/ssl/
```
# 19. Security Headers

## Recommended Security Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;

add_header X-Content-Type-Options "nosniff" always;

add_header Referrer-Policy "strict-origin-when-cross-origin" always;

add_header X-XSS-Protection "1; mode=block" always;
```

Improves browser-side security.

---

## Production Example

```nginx
server {

    add_header X-Frame-Options "SAMEORIGIN" always;

    add_header X-Content-Type-Options "nosniff" always;

    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    add_header X-XSS-Protection "1; mode=block" always;

}
```

---

# 20. Block Direct IP Access

Recommended when using domains.

---

## HTTP Default Server

```nginx
server {
    listen 80 default_server;

    server_name _;

    return 444;
}
```

Blocks:

```txt
http://SERVER_IP
```

---

## HTTPS Default Server

```nginx
server {
    listen 443 ssl default_server;

    server_name _;

    ssl_certificate /etc/nginx/ssl/cert.pem;

    ssl_certificate_key /etc/nginx/ssl/key.pem;

    return 444;
}
```

Blocks unknown hostnames.

---

## Why Use This?

Prevents:

* direct IP access
* random hostname requests
* scanner traffic
* bot traffic

---

# 21. Hide Backend Ports

## Production Architecture

```txt
User
↓
Cloudflare
↓
Nginx
↓
Application
```

---

## Public Ports

Expose:

```txt
80
443
```

only.

---

## Do Not Expose

```txt
3000
4000
5000
8000
8080
9000
```

directly to the internet.

---

## Bad Example

```yaml
ports:
  - "3000:3000"
```

---

## Good Example

```yaml
expose:
  - "3000"
```

Application remains internal.

---

# 22. Rate Limiting

Protects against:

* abuse
* spam
* brute force attacks

---

## Create Zone

```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
```

---

## Apply Rate Limit

```nginx
location / {

    limit_req zone=api burst=20 nodelay;

    proxy_pass http://localhost:3000;
}
```

---

## Example

```txt
10 requests/second
20 request burst
```

---

# 23. Upload Limits

Default upload size may be too small.

---

## Increase Upload Size

```nginx
client_max_body_size 100M;
```

Allows:

```txt
100 MB
```

uploads.

---

## Example

```nginx
server {

    client_max_body_size 100M;

}
```

---

# 24. Static File Hosting

## Static Website Root

```nginx
root /var/www/html;

index index.html;
```

---

## Example

```nginx
server {

    listen 80;

    server_name example.com;

    root /var/www/html;

    index index.html;

}
```

---

# 25. Protect Hidden Files

Blocks access to:

```txt
.env
.git
.htaccess
```

and other hidden files.

---

## Hidden File Protection

```nginx
location ~ /\. {

    deny all;

    access_log off;

    log_not_found off;
}
```

---

# 26. HTTP/2

Improves HTTPS performance.

---

## Enable HTTP/2

```nginx
server {

    listen 443 ssl;

    http2 on;

}
```

---

## Verify

```bash
curl -I https://example.com
```

Look for:

```txt
HTTP/2
```

---

# 27. Gzip Compression

Reduces bandwidth usage.

Improves loading speed.

---

## Enable Gzip

```nginx
gzip on;
```

---

## Recommended Configuration

```nginx
gzip on;

gzip_vary on;

gzip_min_length 1024;

gzip_proxied any;

gzip_comp_level 5;

gzip_types
text/plain
text/css
application/json
application/javascript
application/xml
text/javascript;
```

---

# 28. Hide Nginx Version

Prevents version disclosure.

---

## Disable Version Header

```nginx
server_tokens off;
```

---

## Example

```nginx
http {

    server_tokens off;

}
```

---

# 29. Production Security Example

```nginx
server {

    listen 443 ssl;

    http2 on;

    server_tokens off;

    ssl_certificate /etc/nginx/ssl/cert.pem;

    ssl_certificate_key /etc/nginx/ssl/key.pem;

    add_header X-Frame-Options "SAMEORIGIN" always;

    add_header X-Content-Type-Options "nosniff" always;

    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    add_header X-XSS-Protection "1; mode=block" always;

    client_max_body_size 100M;

    location / {

        proxy_pass http://localhost:3000;

    }

}
```

---

# 30. Security Checklist

Before Production Deployment:

```txt
✓ HTTPS enabled

✓ Cloudflare enabled

✓ HTTP → HTTPS redirect enabled

✓ Security headers enabled

✓ Hidden files blocked

✓ Backend ports hidden

✓ Direct IP access blocked

✓ Rate limiting enabled

✓ HTTP/2 enabled

✓ Gzip enabled

✓ Nginx version hidden

✓ SSL certificates secured

✓ Logs monitored
```
# 31. Nginx Logs

Logs are essential for:

* troubleshooting
* debugging
* monitoring
* security auditing

---

## Linux Access Logs

```txt
/var/log/nginx/access.log
```

Stores incoming requests.

---

## Linux Error Logs

```txt
/var/log/nginx/error.log
```

Stores Nginx errors.

---

## Mac Access Logs

```txt
/opt/homebrew/var/log/nginx/access.log
```

---

## Mac Error Logs

```txt
/opt/homebrew/var/log/nginx/error.log
```

---

# 32. Monitor Logs

## Linux Access Log

```bash
sudo tail -f /var/log/nginx/access.log
```

Live request monitoring.

---

## Linux Error Log

```bash
sudo tail -f /var/log/nginx/error.log
```

Live error monitoring.

---

## Mac Access Log

```bash
tail -f /opt/homebrew/var/log/nginx/access.log
```

---

## Mac Error Log

```bash
tail -f /opt/homebrew/var/log/nginx/error.log
```

---

# 33. Docker Logs

## View Logs

```bash
docker logs nginx
```

Shows container logs.

---

## Follow Logs

```bash
docker logs -f nginx
```

Streams logs in real-time.

---

## Last 100 Logs

```bash
docker logs --tail 100 nginx
```

---

## Docker Compose Logs

```bash
docker compose logs nginx
```

---

## Follow Compose Logs

```bash
docker compose logs -f nginx
```

---

## Last 100 Compose Logs

```bash
docker compose logs --tail=100 nginx
```

---

# 34. Nginx Debugging

## Validate Configuration

Linux:

```bash
sudo nginx -t
```

---

Mac:

```bash
nginx -t
```

---

Docker:

```bash
docker exec nginx nginx -t
```

---

## Show Loaded Configuration

Linux:

```bash
sudo nginx -T
```

---

Docker:

```bash
docker exec nginx nginx -T
```

---

## Check Listening Ports

Linux:

```bash
sudo ss -tulpn
```

---

Mac:

```bash
lsof -i -P -n
```

---

Docker:

```bash
docker ps
```

---

## Check Open Port

```bash
curl localhost
```

---

## Check HTTPS

```bash
curl -I https://example.com
```

---

# 35. Common Nginx Issues

## Configuration Error

Check:

```bash
sudo nginx -t
```

---

## Port Already In Use

Check:

```bash
sudo ss -tulpn
```

or

```bash
lsof -i :80
```

---

## 502 Bad Gateway

Possible Causes:

* application stopped
* wrong port
* crashed backend
* firewall issues

Verify:

```bash
curl localhost:3000
```

---

## 504 Gateway Timeout

Possible Causes:

* slow backend
* application hangs
* network issues

---

## SSL Certificate Failed

Verify:

* DNS records
* domain propagation
* port 80 open
* port 443 open
* Cloudflare SSL mode

---

## 521 Cloudflare Error

Meaning:

```txt
Cloudflare
↓
Cannot Reach Origin Server
```

Check:

* Nginx running
* firewall
* ports 80 and 443
* DNS records

---

## 522 Cloudflare Error

Meaning:

```txt
Cloudflare
↓
Connection Timeout
↓
Origin Server
```

Check:

* firewall
* VPS network rules
* server load
* ports 80 and 443

---

## Mixed Content Error

Cause:

```txt
HTTPS Page
↓
HTTP Resource
```

Fix:

Use:

```txt
https://
```

everywhere.

---

# 36. Uninstall Nginx On Linux

## Stop Service

```bash
sudo systemctl stop nginx
```

---

## Disable On Boot

```bash
sudo systemctl disable nginx
```

---

## Remove Packages

Ubuntu / Debian:

```bash
sudo apt purge nginx nginx-common nginx-full -y
```

---

## Remove Unused Packages

```bash
sudo apt autoremove -y
```

---

## Remove Package Cache

```bash
sudo apt autoclean
```

---

## Remove Configuration Files

```bash
sudo rm -rf /etc/nginx
```

---

## Remove Logs

```bash
sudo rm -rf /var/log/nginx
```

---

## Verify Removal

```bash
which nginx
```

Expected:

```txt
No output
```

---

# 37. Uninstall Nginx On Mac

## Stop Service

```bash
brew services stop nginx
```

---

## Uninstall

```bash
brew uninstall nginx
```

---

## Remove Homebrew Cache

```bash
brew cleanup
```

---

## Remove Configuration Files

```bash
rm -rf /opt/homebrew/etc/nginx
```

---

## Remove Logs

```bash
rm -rf /opt/homebrew/var/log/nginx
```

---

## Remove Homebrew Cache Files

```bash
rm -rf ~/Library/Caches/Homebrew/nginx*
```

---

## Verify Removal

```bash
which nginx
```

Expected:

```txt
No output
```

---

# 38. Remove Docker Nginx

## Stop Container

```bash
docker stop nginx
```

---

## Remove Container

```bash
docker rm nginx
```

---

## Remove Image

```bash
docker rmi nginx:alpine
```

---

## Verify Removal

```bash
docker ps -a
```

---

## Check Images

```bash
docker images
```

---

# 39. Docker Cleanup

## Remove Unused Containers

```bash
docker container prune
```

---

## Remove Unused Images

```bash
docker image prune -a
```

---

## Remove Unused Volumes

```bash
docker volume prune
```

---

## Remove Unused Networks

```bash
docker network prune
```

---

## Remove Everything Unused

```bash
docker system prune -a --volumes
```

Removes:

* unused containers
* unused images
* unused volumes
* unused networks
* build cache

---

# 40. Full Cleanup Verification

## Linux

```bash
which nginx
```

---

```bash
sudo systemctl status nginx
```

Should show:

```txt
Unit nginx.service could not be found
```

---

## Mac

```bash
which nginx
```

---

```bash
brew services list
```

Nginx should not appear.

---

## Docker

```bash
docker ps -a
```

---

```bash
docker images
```

No Nginx container or image should exist.

---

# 41. Recommended Production Workflow

## Standard Architecture

```txt
User
↓
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
Database
```

---

## Deployment Workflow

1. Configure DNS
2. Install Nginx
3. Configure Reverse Proxy
4. Configure SSL
5. Test Configuration
6. Enable Security Headers
7. Enable Rate Limiting
8. Enable HTTP/2
9. Enable Gzip
10. Monitor Logs
11. Configure Backups

---

# 42. Production Deployment Checklist

Before Going Live:

```txt
✓ Domain configured

✓ DNS records verified

✓ Cloudflare configured

✓ SSL working

✓ HTTP redirects to HTTPS

✓ Reverse proxy tested

✓ Backend hidden

✓ Security headers enabled

✓ Rate limiting enabled

✓ Upload limits configured

✓ Direct IP access blocked

✓ Hidden files blocked

✓ HTTP/2 enabled

✓ Gzip enabled

✓ Nginx version hidden

✓ Logs monitored

✓ Firewall configured

✓ Ports 80 and 443 open

✓ Unnecessary ports closed

✓ Backup strategy configured

✓ Configuration backed up
```
# 43. Nginx Backup & Restore

## Backup Configuration

### Linux

```bash
sudo tar -czf nginx-backup.tar.gz \
/etc/nginx \
/etc/letsencrypt
```

Backs up:

* Nginx configuration
* SSL certificates

---

### Docker

```bash
tar -czf nginx-backup.tar.gz nginx/
```

Backs up:

* nginx configs
* SSL files
* reverse proxy configuration

---

## Restore Backup

### Linux

```bash
sudo tar -xzf nginx-backup.tar.gz -C /
```

---

### Docker

```bash
tar -xzf nginx-backup.tar.gz
```

---

# 44. Nginx Migration

Useful when moving to a new VPS.

---

## Backup Existing Config

```bash
sudo tar -czf nginx-migration.tar.gz \
/etc/nginx \
/etc/letsencrypt
```

---

## Copy To New Server

```bash
scp nginx-migration.tar.gz user@server-ip:~
```

---

## Restore

```bash
sudo tar -xzf nginx-migration.tar.gz -C /
```

---

## Verify

```bash
sudo nginx -t
```

---

## Reload

```bash
sudo systemctl reload nginx
```

---

# 45. Nginx Quick Commands Cheat Sheet

## Service

### Start

```bash
sudo systemctl start nginx
```

### Stop

```bash
sudo systemctl stop nginx
```

### Restart

```bash
sudo systemctl restart nginx
```

### Reload

```bash
sudo systemctl reload nginx
```

### Status

```bash
sudo systemctl status nginx
```

---

## Validation

```bash
sudo nginx -t
```

---

## Full Config

```bash
sudo nginx -T
```

---

## Logs

```bash
sudo tail -f /var/log/nginx/access.log
```

```bash
sudo tail -f /var/log/nginx/error.log
```

---

## Docker

```bash
docker compose logs -f nginx
```

```bash
docker exec nginx nginx -t
```

```bash
docker exec nginx nginx -s reload
```

---

## Firewall

```bash
sudo ufw allow 'Nginx Full'
```

---

## Ports

```bash
sudo ss -tulpn
```

---

## Test Local Response

```bash
curl localhost
```

---

## Test HTTPS

```bash
curl -I https://example.com
```
