# Nginx Reverse Proxy

## What Is Nginx?

Nginx is a high-performance web server and reverse proxy.

Used for:

- reverse proxy
- HTTPS/SSL
- load balancing
- serving static files
- routing traffic
- multiple app hosting

---

# What Is A Reverse Proxy?

A reverse proxy sits between users and backend applications.

Example:

```txt
User → Nginx → Node.js App
```

Benefits:

- hides backend services
- SSL support
- multiple apps on one VPS
- better security
- easier routing

---

# Install Nginx

## Install Nginx

```bash
sudo apt install nginx -y
```

Installs Nginx.

---

# Verify Nginx Installation

## Check Nginx Status

```bash
sudo systemctl status nginx
```

Checks if Nginx is running.

---

## Enable Nginx On Boot

```bash
sudo systemctl enable nginx
```

Starts Nginx automatically on reboot.

---

# Start / Stop Nginx

## Start Nginx

```bash
sudo systemctl start nginx
```

Starts Nginx service.

---

## Restart Nginx

```bash
sudo systemctl restart nginx
```

Restarts Nginx.

---

## Reload Nginx

```bash
sudo systemctl reload nginx
```

Reloads config without full restart.

---

## Stop Nginx

```bash
sudo systemctl stop nginx
```

Stops Nginx.

---

# Allow HTTP & HTTPS

## Allow Nginx Firewall Rules

```bash
sudo ufw allow 'Nginx Full'
```

Allows ports:

- 80 (HTTP)
- 443 (HTTPS)

---

# Nginx File Locations

## Main Config

```txt
/etc/nginx/nginx.conf
```

Main Nginx configuration file.

---

## Site Configurations

```txt
/etc/nginx/sites-available/
```

Stores site configs.

---

## Enabled Sites

```txt
/etc/nginx/sites-enabled/
```

Stores enabled site links.

---

## Nginx Logs

```txt
/var/log/nginx/
```

Stores access/error logs.

---

# Create Reverse Proxy Config

## Create Site Config

```bash
sudo nano /etc/nginx/sites-available/myapp
```

Creates site configuration.

---

# Basic Reverse Proxy Example

## Node.js App Reverse Proxy

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    location / {
        proxy_pass http://localhost:3000;

        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';

        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Routes domain traffic to Node.js app.

---

# Enable Site

## Create Symlink

```bash
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
```

Enables site configuration.

---

# Test Nginx Config

## Check Config Syntax

```bash
sudo nginx -t
```

Checks Nginx configuration syntax.

---

# Reload Nginx

## Apply Config

```bash
sudo systemctl reload nginx
```

Applies new configuration.

---

# Remove Default Nginx Site

## Delete Default Config

```bash
sudo rm /etc/nginx/sites-enabled/default
```

Removes default Nginx page.

---

# HTTPS / SSL

## Install Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

Installs Let's Encrypt SSL tools.

---

# Generate SSL Certificate

## Enable HTTPS

```bash
sudo certbot --nginx -d example.com -d www.example.com
```

Generates SSL certificate automatically.

---

# Test SSL Renewal

## Dry Run Renewal

```bash
sudo certbot renew --dry-run
```

Tests SSL auto-renewal.

---

# Force HTTPS Redirect

## Redirect HTTP → HTTPS

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    return 301 https://$host$request_uri;
}
```

Redirects HTTP traffic to HTTPS.

---

# Reverse Proxy Multiple Apps

## Example Multiple Apps

```txt
example.com → frontend
api.example.com → backend API
admin.example.com → admin panel
```

All hosted on same VPS.

---

# API Reverse Proxy Example

## API Subdomain

```nginx
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:5000;
    }
}
```

Routes API traffic.

---

# WebSocket Support

Required for:

- Socket.IO
- real-time apps
- chats
- live updates

---

## WebSocket Config

```nginx
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

Enables WebSocket support.

---

# Static File Hosting

## Static Website Root

```nginx
root /var/www/html;
index index.html;
```

Serves static frontend files.

---

# Nginx Security Headers

## Example Security Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header Referrer-Policy "strict-origin-when-cross-origin";
```

Improves security.

---

# Block Hidden Files

## Protect Sensitive Files

```nginx
location ~ /\. {
    deny all;
}
```

Blocks hidden/system files.

---

# Limit Upload Size

## Increase Upload Limit

```nginx
client_max_body_size 100M;
```

Allows larger uploads.

---

# Rate Limiting

Helps protect against abuse/spam.

---

## Basic Rate Limit

```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
```

Limits repeated requests.

---

# Nginx Logs

## Access Logs

```txt
/var/log/nginx/access.log
```

Stores request logs.

---

## Error Logs

```txt
/var/log/nginx/error.log
```

Stores error logs.

---

# Monitor Nginx Logs

## Live Access Logs

```bash
sudo tail -f /var/log/nginx/access.log
```

Streams access logs.

---

## Live Error Logs

```bash
sudo tail -f /var/log/nginx/error.log
```

Streams error logs.

---

# Nginx Performance Tips

- Use HTTPS
- Enable compression
- Cache static assets
- Remove unused configs
- Use Cloudflare CDN
- Monitor server resources
- Use HTTP/2

---

# Enable Gzip Compression

## Gzip Example

```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

Compresses responses for better performance.

---

# Common Nginx Issues

## Nginx Config Error

Check:

```bash
sudo nginx -t
```

---

## Port 80 Already In Use

Check:

```bash
sudo ss -tulpn
```

---

## 502 Bad Gateway

Possible reasons:

- backend app stopped
- wrong port
- app crash

---

## SSL Certificate Failed

Check:

- DNS records
- domain propagation
- port 80 open
- Cloudflare proxy settings

---

# Docker + Nginx

## Reverse Proxy Docker Container

```bash
docker run -d \
--name nginx \
-p 80:80 \
-p 443:443 \
nginx
```

Runs Nginx container.

---

# Recommended Security Practices

- Use HTTPS everywhere
- Hide backend services
- Use Cloudflare proxy
- Monitor logs regularly
- Remove unused configs
- Keep Nginx updated
- Restrict unnecessary ports
- Use security headers
- Backup configs regularly

---

# Recommended Production Workflow

1. Install Nginx
2. Configure firewall
3. Create reverse proxy config
4. Connect application
5. Test Nginx config
6. Configure domain DNS
7. Enable HTTPS
8. Configure security headers
9. Monitor logs/resources
10. Keep configs updated