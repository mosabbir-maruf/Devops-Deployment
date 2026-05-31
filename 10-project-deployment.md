# Project Deployment

## Table Of Contents

### Fundamentals

1. [What Is Deployment](#1-what-is-deployment)
2. [Recommended Production Stack](#2-recommended-production-stack)
3. [Production Architecture](#3-production-architecture)
4. [Production Folder Structure](#4-production-folder-structure)
5. [Docker-First Deployment Philosophy](#5-docker-first-deployment-philosophy)
6. [Development vs Production Deployment](#6-development-vs-production-deployment)

### Project Preparation

7. [Project Readiness Checklist](#7-project-readiness-checklist)
8. [Project Structure](#8-project-structure)
9. [GitHub Preparation](#9-github-preparation)
10. [Environment Variables](#10-environment-variables)
11. [Dockerfile And Compose Preparation](#11-dockerfile-and-compose-preparation)
12. [Domain Preparation](#12-domain-preparation)
13. [Project Preparation Checklist](#13-project-preparation-checklist)

### VPS Preparation

14. [VPS Requirements](#14-vps-requirements)
15. [Initial VPS Setup](#15-initial-vps-setup)
16. [VPS Security Checklist](#16-vps-security-checklist)
17. [Firewall Configuration](#17-firewall-configuration)
18. [Docker Installation Verification](#18-docker-installation-verification)
19. [VPS Readiness Checklist](#19-vps-readiness-checklist)

### Installation

20. [Install Docker On Linux VPS](#20-install-docker-on-linux-vps)
21. [Docker On Mac (Development)](#21-docker-on-mac-development)
22. [Verify Docker For Deployment](#22-verify-docker-for-deployment)
23. [Prepare Deployment Directory](#23-prepare-deployment-directory)

### Deployment Methods

24. [Docker Compose Deployment (Recommended)](#24-docker-compose-deployment-recommended)
25. [Docker Hub Deployment](#25-docker-hub-deployment)
26. [GitHub Actions CI/CD Deployment](#26-github-actions-cicd-deployment)
27. [Coolify Deployment (Alternative)](#27-coolify-deployment-alternative)
28. [Legacy Source Deployment (Avoid)](#28-legacy-source-deployment-avoid)
29. [Deployment Method Comparison](#29-deployment-method-comparison)

### Production Infrastructure

30. [Production Docker Compose Stack](#30-production-docker-compose-stack)
31. [Nginx Integration](#31-nginx-integration)
32. [Cloudflare Integration](#32-cloudflare-integration)
33. [DNS Configuration](#33-dns-configuration)
34. [SSL HTTPS Configuration](#34-ssl-https-configuration)
35. [Health Checks](#35-health-checks)
36. [Production Infrastructure Checklist](#36-production-infrastructure-checklist)

### Monitoring

37. [Deployment Monitoring](#37-deployment-monitoring)
38. [Docker Monitoring](#38-docker-monitoring)
39. [Server Monitoring](#39-server-monitoring)
40. [Log Monitoring](#40-log-monitoring)
41. [Monitoring Checklist](#41-monitoring-checklist)

### Updates And Rollbacks

42. [Deployment Updates Workflow](#42-deployment-updates-workflow)
43. [Docker Image Updates](#43-docker-image-updates)
44. [Rollback Workflow](#44-rollback-workflow)
45. [Database Rollback](#45-database-rollback)
46. [Update Checklist](#46-update-checklist)

### Security

47. [Deployment Security Rules](#47-deployment-security-rules)
48. [Secrets Management](#48-secrets-management)
49. [Network Security](#49-network-security)
50. [Security Checklist](#50-security-checklist)

### Backup

51. [Backup Strategy](#51-backup-strategy)
52. [Database Backups](#52-database-backups)
53. [Volume And Config Backups](#53-volume-and-config-backups)
54. [Backup Verification](#54-backup-verification)

### Troubleshooting

55. [Deployment Failed](#55-deployment-failed)
56. [Container Not Starting](#56-container-not-starting)
57. [SSL And DNS Issues](#57-ssl-and-dns-issues)
58. [Nginx 502 Bad Gateway](#58-nginx-502-bad-gateway)
59. [Database And Redis Connectivity](#59-database-and-redis-connectivity)
60. [High Resource Usage](#60-high-resource-usage)
61. [Debug Workflow](#61-debug-workflow)

### Cleanup And Uninstall

62. [Tear Down Deployment (Linux / VPS)](#62-tear-down-deployment-linux--vps)
63. [Remove Docker Stack And Volumes](#63-remove-docker-stack-and-volumes)
64. [Clean Up Deployment On Mac](#64-clean-up-deployment-on-mac)
65. [Remove Docker Images And Cache](#65-remove-docker-images-and-cache)
66. [DNS And Cloudflare Cleanup](#66-dns-and-cloudflare-cleanup)
67. [Log Cleanup](#67-log-cleanup)
68. [Cache And Leftover Files](#68-cache-and-leftover-files)
69. [Verification After Removal](#69-verification-after-removal)

### Production Workflows

70. [Recommended Production Workflow](#70-recommended-production-workflow)
71. [Modern Workflow](#71-modern-workflow)
72. [Real-World Workflow](#72-real-world-workflow)
73. [Final Production Checklist](#73-final-production-checklist)

---

# 1. What Is Deployment

Deployment is the process of making an application available to users reliably and securely.

A production deployment includes:

* application code (Docker images)
* VPS infrastructure
* database and cache
* domain and DNS
* SSL/HTTPS
* monitoring and backups

Goal:

```txt
Users
↓
Access Application
↓
Reliably And Securely
```

---

# 2. Recommended Production Stack

```txt
Ubuntu 24.04 LTS VPS
↓
Docker + Docker Compose
↓
Nginx (reverse proxy)
↓
Cloudflare (DNS + SSL + WAF)
↓
Frontend + Backend + PostgreSQL + Redis
```

Components:

| Layer | Tool |
|-------|------|
| OS | Ubuntu LTS |
| Containers | Docker Compose |
| Proxy | Nginx |
| CDN/DNS | Cloudflare |
| Database | PostgreSQL 17 (Docker) |
| Cache | Redis 8 (Docker) |
| CI/CD | GitHub Actions |
| Registry | Docker Hub |

Alternative PaaS: **Coolify** on same VPS — see `05-coolify.md`.

---

# 3. Production Architecture

```txt
User
↓
Cloudflare
↓
Nginx (:443)
↓
Frontend Container (:3000 internal)
↓
Backend Container (:5000 internal)
↓
PostgreSQL Container (internal)
↓
Redis Container (internal)
```

Deploy flow:

```txt
Developer (Mac)
↓
GitHub Push
↓
GitHub Actions
↓
Docker Hub (build + push)
↓
SSH → VPS
↓
docker compose pull && up -d
↓
Users
```

Admin access:

```txt
Developer → SSH → VPS → docker compose commands
```

Never expose backend, PostgreSQL, or Redis ports publicly.

---

# 4. Production Folder Structure

## GitHub Repository

```txt
myapp/
├── apps/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── package.json
│   │   └── src/
│   └── backend/
│       ├── Dockerfile
│       ├── .dockerignore
│       ├── package.json
│       └── src/
├── nginx/
│   └── default.conf
├── docker-compose.yml
├── docker-compose.prod.yml
├── docker-compose.dev.yml
├── .env.example
├── .gitignore
└── .github/
    └── workflows/
        └── deploy.yml
```

## VPS Deployment Path

```txt
/var/www/myapp/
├── docker-compose.prod.yml
├── .env                    # chmod 600 — never in Git
├── nginx/
│   └── default.conf
└── backups/
    ├── postgres/
    ├── config/
    └── volumes/
```

## Mac (Development)

```txt
~/Projects/myapp/           # same repo as GitHub
├── .env                    # local dev secrets
└── docker-compose.dev.yml
```

---

# 5. Docker-First Deployment Philosophy

Production deployments must be:

```txt
Predictable   → same result every deploy
Repeatable    → docker compose up -d from any VPS
Automated     → GitHub Actions, not manual SSH edits
Immutable     → new image, not edited containers
Secure        → secrets in .env, databases internal
```

Production rule:

```txt
✓ Change code → commit → CI builds image → deploy
✗ SSH into VPS → edit files → restart manually
✗ SSH into container → modify running app
```

---

# 6. Development vs Production Deployment

| | Development (Mac) | Production (VPS) |
|--|-------------------|------------------|
| Compose file | `docker-compose.dev.yml` | `docker-compose.prod.yml` |
| Code | bind mounts, hot reload | immutable Docker images |
| Database | local Docker, disposable | persistent volumes, backed up |
| Secrets | local `.env` | server `.env` chmod 600 |
| Domain | localhost | Cloudflare + real domain |
| Deploy | `docker compose up` | CI/CD → SSH → compose pull |

---

# 7. Project Readiness Checklist

Before deploying:

```txt
✓ App works locally with Docker Compose
✓ Production build succeeds (npm run build)
✓ Docker build succeeds (docker compose build)
✓ .env.example documents all required vars
✓ No hardcoded secrets in code
✓ Health endpoint exists (/health)
✓ Database migrations ready
✓ .gitignore excludes .env and node_modules
✓ GitHub repo created (private if needed)
```

---

# 8. Project Structure

## Monorepo Example

```txt
myapp/
├── apps/frontend/     → Next.js / React
├── apps/backend/      → Node.js API
├── nginx/default.conf → reverse proxy config
├── docker-compose.prod.yml
└── .github/workflows/deploy.yml
```

## Single App Example

```txt
api/
├── src/
├── Dockerfile
├── docker-compose.prod.yml
└── nginx/default.conf
```

Each service that runs in production needs its own **Dockerfile**.

---

# 9. GitHub Preparation

## Initialize And Push

```bash
cd ~/Projects/myapp
git init
git add .
git commit -m "initial production setup"
git branch -M main
git remote add origin git@github.com:username/myapp.git
git push -u origin main
```

## .gitignore Essentials

```txt
.env
.env.local
.env.production
node_modules/
dist/
.next/
build/
*.log
.DS_Store
```

## Branch Strategy

```txt
main        → production deploys
staging     → pre-production testing (optional)
feature/*   → development branches
```

Never commit `.env` — use GitHub Secrets for CI/CD.

---

# 10. Environment Variables

## .env.example (Commit To Git)

```env
NODE_ENV=production
PORT=5000
DATABASE_URL=
REDIS_URL=
JWT_SECRET=
DOMAIN=yourdomain.com
```

## .env (Server Only — Never Commit)

```env
NODE_ENV=production
PORT=5000
DATABASE_URL=postgresql://user:pass@postgres:5432/myapp
REDIS_URL=redis://:pass@redis:6379
JWT_SECRET=long-random-secret
POSTGRES_USER=admin
POSTGRES_PASSWORD=long-random-secret
POSTGRES_DB=myapp
REDIS_PASSWORD=long-random-secret
TAG=latest
```

## On VPS

```bash
chmod 600 /var/www/myapp/.env
```

## In docker-compose.prod.yml

```yaml
services:
  backend:
    env_file:
      - .env
```

---

# 11. Dockerfile And Compose Preparation

## Production Backend Dockerfile

```dockerfile
FROM node:24-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:24-slim
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=builder /app/dist ./dist
USER node
EXPOSE 5000
HEALTHCHECK CMD node -e "fetch('http://localhost:5000/health').then(r=>process.exit(r.ok?0:1))"
CMD ["node", "dist/index.js"]
```

## Verify Build Locally

```bash
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
curl -f http://localhost:5000/health
docker compose down
```

See `04-docker.md` and `06-nodejs-npm.md` for full Dockerfile guides.

---

# 12. Domain Preparation

Before deployment:

```txt
✓ Domain purchased (Namecheap, Cloudflare, etc.)
✓ DNS managed by Cloudflare
✓ A records planned:
   yourdomain.com      → VPS IP
   api.yourdomain.com  → VPS IP
   www.yourdomain.com  → VPS IP (or CNAME)
```

See `12-domain-dns-cloudflare.md` for full DNS setup.

---

# 13. Project Preparation Checklist

✓ Good:

* Docker builds locally
* `.env.example` complete
* health endpoint working
* GitHub repo pushed
* domain ready

✗ Avoid:

* deploying without local Docker test
* secrets in GitHub repo
* missing `.dockerignore`

---

# 14. VPS Requirements

Minimum specs:

```txt
OS:       Ubuntu 22.04 / 24.04 LTS
RAM:      2 GB (4 GB recommended for full stack)
CPU:      2 vCPU
Disk:     40 GB SSD
Network:  Public IPv4
```

Providers: Hetzner, DigitalOcean, Vultr, Linode.

---

# 15. Initial VPS Setup

See `01-initial-vps-security-setup.md` and `03-linux-basics.md` for full steps.

```bash
ssh root@YOUR_PUBLIC_IP
apt update && apt upgrade -y
adduser mosabbir && usermod -aG sudo,docker mosabbir
# SSH hardening — see 02-ssh-guide.md
curl -fsSL https://get.docker.com | sh
mkdir -p /var/www/myapp && chown mosabbir:mosabbir /var/www/myapp
```

---

# 16. VPS Security Checklist

✓ Good:

* non-root admin user (mosabbir)
* SSH key-only, custom port
* UFW enabled
* Fail2Ban active
* automatic security updates

✗ Avoid:

* root SSH login
* password authentication
* all ports open

See `02-ssh-guide.md` for SSH hardening.

---

# 17. Firewall Configuration

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 1182/tcp    # SSH custom port
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose
```

## Do Not Open

```txt
5432   PostgreSQL
6379   Redis
27017  MongoDB
5000   Backend (Nginx proxies instead)
```

---

# 18. Docker Installation Verification

```bash
docker --version
docker compose version
sudo systemctl status docker
docker run --rm hello-world
docker ps
groups mosabbir    # should include docker
```

Expected:

```txt
Docker version 27+
Docker Compose version 2.x
```

---

# 19. VPS Readiness Checklist

```txt
✓ Ubuntu LTS updated
✓ Admin user created
✓ SSH hardened
✓ UFW enabled (80, 443, SSH only)
✓ Fail2Ban running
✓ Docker installed and running
✓ /var/www/myapp created
✓ Out-of-band console access verified
```

---

# 20. Install Docker On Linux VPS

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker mosabbir
sudo systemctl enable docker
sudo systemctl start docker
```

Log out and back in, then verify:

```bash
docker ps
docker compose version
```

See `04-docker.md` for full install/uninstall.

---

# 21. Docker On Mac (Development)

Install Docker Desktop for local development and testing before VPS deploy.

```bash
brew install --cask docker
docker --version
docker compose version
```

Local workflow:

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml up -d
docker compose logs -f
curl -f http://localhost:5000/health
```

Mac is **not** the production server — VPS is.

---

# 22. Verify Docker For Deployment

## On VPS

```bash
ssh vps-prod
docker info
docker compose version
df -h
free -h
docker run --rm alpine ping -c 2 google.com
```

## Local Before Push

```bash
docker compose -f docker-compose.prod.yml config --quiet
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
docker compose ps
curl -f http://localhost/health
docker compose down
```

---

# 23. Prepare Deployment Directory

```bash
ssh vps-prod
sudo mkdir -p /var/www/myapp/{nginx,backups}
sudo chown -R mosabbir:mosabbir /var/www/myapp
chmod 700 /var/www/myapp
```

Copy files to VPS:

```bash
scp docker-compose.prod.yml vps-prod:/var/www/myapp/
scp .env vps-prod:/var/www/myapp/
scp -r nginx/ vps-prod:/var/www/myapp/
ssh vps-prod "chmod 600 /var/www/myapp/.env"
```

Or deploy via CI/CD — preferred for production.

---

# 24. Docker Compose Deployment (Recommended)

Primary production method.

## docker-compose.prod.yml

```yaml
services:
  frontend:
    image: youruser/myapp-frontend:${TAG:-latest}
    restart: unless-stopped
    networks:
      - app-network

  backend:
    image: youruser/myapp-backend:${TAG:-latest}
    restart: unless-stopped
    env_file:
      - .env
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://localhost:5000/health').then(r=>process.exit(r.ok?0:1))"]
      interval: 30s
      timeout: 5s
      retries: 3

  postgres:
    image: postgres:17
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      retries: 5

  redis:
    image: redis:8-alpine
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      retries: 5

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx:/etc/nginx/conf.d:ro
    depends_on:
      - frontend
      - backend
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

## Deploy Commands

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d --remove-orphans
docker compose ps
curl -f https://yourdomain.com/health
```

---

# 25. Docker Hub Deployment

Build once, deploy anywhere.

## Workflow

```txt
Local/CI builds image
↓
Push to Docker Hub
↓
VPS pulls image
↓
docker compose up -d
```

## Push From Local

```bash
docker login
docker build -t youruser/myapp-backend:v1.0.0 apps/backend
docker push youruser/myapp-backend:v1.0.0
```

## Pull On VPS

```bash
ssh vps-prod
cd /var/www/myapp
export TAG=v1.0.0
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

Use explicit image tags in production — not `latest` alone.

---

# 26. GitHub Actions CI/CD Deployment

Recommended automated deploy.

## .github/workflows/deploy.yml

```yaml
name: Deploy Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 24
          cache: npm
          cache-dependency-path: apps/backend/package-lock.json
      - run: npm ci
        working-directory: apps/backend
      - run: npm test
        working-directory: apps/backend

  build-push:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: apps/backend
          push: true
          tags: youruser/myapp-backend:${{ github.sha }},youruser/myapp-backend:latest

  deploy:
    needs: build-push
    runs-on: ubuntu-latest
    steps:
      - uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          port: ${{ secrets.SERVER_SSH_PORT }}
          script: |
            cd /var/www/myapp
            export TAG=${{ github.sha }}
            docker compose -f docker-compose.prod.yml pull
            docker compose -f docker-compose.prod.yml up -d --remove-orphans
            docker compose -f docker-compose.prod.yml exec -T backend npx prisma migrate deploy
            docker compose ps
            docker image prune -f
```

## GitHub Secrets Required

```txt
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
SERVER_IP
SERVER_USER
SERVER_SSH_KEY
SERVER_SSH_PORT
```

See `13-git-github-ci-cd.md` for full CI/CD guide.

---

# 27. Coolify Deployment (Alternative)

Self-hosted PaaS — good for multi-app VPS without manual compose management.

```txt
GitHub Push
↓
Coolify Webhook
↓
Docker Build on VPS
↓
Traefik + SSL
↓
Users
```

Setup: see `05-coolify.md`.

Use Coolify when:

* managing multiple apps on one VPS
* prefer GUI over SSH deploy scripts
* want automatic SSL without manual Nginx config

Use Docker Compose + CI/CD when:

* full control over pipeline
* custom Nginx configuration
* team prefers infrastructure as code

---

# 28. Legacy Source Deployment (Avoid)

```txt
SSH → git pull → npm install → pm2 restart
```

✗ Avoid for new projects:

* not reproducible
* Node version tied to host
* no container isolation
* hard to rollback

If maintaining legacy PM2 deployment, migrate to Docker Compose incrementally.

---

# 29. Deployment Method Comparison

| Method | Best For | Production Ready |
|--------|----------|------------------|
| Docker Compose + CI/CD | Full control, SaaS | ✓ Recommended |
| Docker Hub + SSH | Multi-VPS, teams | ✓ Recommended |
| Coolify | Multi-app, fast setup | ✓ Good |
| Source + PM2 | Legacy only | ✗ Avoid |
| Manual SSH edits | Never | ✗ Never |

---

# 30. Production Docker Compose Stack

Full stack reference — see section 24 for complete YAML.

Key rules:

```txt
✓ restart: unless-stopped on all services
✓ healthcheck on backend, postgres, redis
✓ env_file: .env (not hardcoded secrets)
✓ volumes for postgres and redis only
✓ nginx is only service with ports 80/443
✓ explicit image tags in production
```

---

# 31. Nginx Integration

```txt
User → Cloudflare → Nginx :443 → frontend:3000 / backend:5000
```

## nginx/default.conf

```nginx
upstream backend {
    server backend:5000;
}

upstream frontend {
    server frontend:3000;
}

server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate     /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;

    location /api/ {
        proxy_pass http://backend/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

See `11-nginx-reverse-proxy.md` for full Nginx setup.

---

# 32. Cloudflare Integration

```txt
User → Cloudflare (DNS + WAF + SSL) → Nginx → App
```

## Cloudflare Settings

```txt
SSL/TLS mode:     Full (strict)
Always HTTPS:     On
Auto Minify:      JS, CSS, HTML
Brotli:           On
WAF:              On (free tier)
```

## Origin Certificate (Optional)

Generate in Cloudflare → SSL → Origin Server → install on Nginx.

See `12-domain-dns-cloudflare.md`.

---

# 33. DNS Configuration

## Cloudflare A Records

```txt
Type: A   Name: @      Content: YOUR_VPS_IP   Proxy: Proxied
Type: A   Name: api    Content: YOUR_VPS_IP   Proxy: Proxied
Type: A   Name: www     Content: YOUR_VPS_IP   Proxy: Proxied
```

## Verify DNS

```bash
dig yourdomain.com +short
dig api.yourdomain.com +short
```

Allow propagation (usually minutes, up to 24 hours).

---

# 34. SSL HTTPS Configuration

## Option 1 — Cloudflare Proxy (Simplest)

Cloudflare handles SSL between user and Cloudflare. Nginx uses Cloudflare Origin Certificate or Let's Encrypt.

## Option 2 — Let's Encrypt On Nginx

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com
```

## Option 3 — Cloudflare Origin Certificate

```txt
Cloudflare → SSL → Origin Server → Create Certificate
→ Install on Nginx
→ SSL mode: Full (strict)
```

## Verify HTTPS

```bash
curl -I https://yourdomain.com
curl -I https://api.yourdomain.com/health
```

---

# 35. Health Checks

## Backend Health Endpoint

```javascript
app.get("/health", async (req, res) => {
  await pool.query("SELECT 1");
  await redis.ping();
  res.json({ status: "ok", uptime: process.uptime() });
});
```

## Verify After Deploy

```bash
curl -f http://localhost:5000/health
curl -f https://yourdomain.com/health
curl -f https://api.yourdomain.com/health
docker compose ps
```

All services should show `healthy` or `Up`.

---

# 36. Production Infrastructure Checklist

```txt
✓ Domain DNS pointing to VPS
✓ Cloudflare SSL Full (strict)
✓ Nginx reverse proxy configured
✓ HTTPS redirect working
✓ Backend health check passing
✓ PostgreSQL internal only
✓ Redis internal only
✓ UFW blocks DB/cache ports
✓ .env chmod 600 on server
```

---

# 37. Deployment Monitoring

After every deploy:

```bash
ssh vps-prod
cd /var/www/myapp
docker compose ps
curl -f https://yourdomain.com/health
docker compose logs backend --tail=30
```

Monitor for 10–15 minutes after deploy for errors.

---

# 38. Docker Monitoring

```bash
docker compose ps
docker stats --no-stream
docker system df
docker compose logs -f --tail=50
```

Set up weekly cron or manual check:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker system df
```

---

# 39. Server Monitoring

```bash
df -h
free -h
uptime
sudo ufw status
sudo fail2ban-client status
```

Alert thresholds:

```txt
Disk > 85%  → prune images, expand disk
RAM  > 90%  → upgrade VPS or reduce services
```

See `14-server-monitoring.md`.

---

# 40. Log Monitoring

```bash
docker compose logs -f
docker compose logs backend --tail=100 --since 1h
docker compose logs nginx --tail=50
sudo tail -f /var/log/auth.log
```

Export before major changes:

```bash
docker compose logs > ~/logs/deploy-$(date +%F).log 2>&1
```

---

# 41. Monitoring Checklist

```txt
✓ docker compose ps — all Up/healthy
✓ curl health endpoints
✓ docker stats — no OOM
✓ df -h — disk under 85%
✓ auth.log — no brute-force spikes
✓ Cloudflare analytics — no error spike
```

---

# 42. Deployment Updates Workflow

```txt
1. Develop and test locally (Docker Compose dev)
2. Commit and push to GitHub
3. GitHub Actions: test → build → push image
4. SSH deploy: pull + up -d
5. Run migrations if needed
6. Verify health checks
7. Monitor logs for 15 minutes
```

Manual update (emergency):

```bash
ssh vps-prod
cd /var/www/myapp
export TAG=new-version
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
docker compose ps
```

---

# 43. Docker Image Updates

## Pull Latest

```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

## Pin Specific Version

```bash
export TAG=v1.2.3
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

## Prune Old Images

```bash
docker image prune -f
```

Always backup database before updates with schema changes.

---

# 44. Rollback Workflow

## Rollback Via Image Tag

```bash
ssh vps-prod
cd /var/www/myapp
export TAG=previous-stable-sha
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
docker compose ps
curl -f https://yourdomain.com/health
```

## Rollback Via Git

```bash
git revert BAD_COMMIT
git push origin main
# CI/CD redeploys previous working version
```

## Before Every Deploy — Tag Current

```bash
docker tag youruser/myapp-backend:latest youruser/myapp-backend:rollback
```

Keep last 3–5 known-good image tags in Docker Hub.

---

# 45. Database Rollback

## Before Migration

```bash
docker exec postgres pg_dump -U admin myapp > ~/backups/pre-migrate-$(date +%F).sql
```

## Rollback Migration (Prisma)

```bash
docker compose exec backend npx prisma migrate resolve --rolled-back MIGRATION_NAME
```

## Restore Database

```bash
docker compose stop backend
cat ~/backups/pre-migrate-YYYY-MM-DD.sql | docker exec -i postgres psql -U admin myapp
docker compose start backend
```

See `08-postgresql.md` for full backup/restore.

---

# 46. Update Checklist

```txt
✓ Database backed up before migration
✓ Previous image tag available for rollback
✓ Health checks passing after update
✓ Logs monitored post-deploy
✓ Cloudflare/DNS unchanged (unless intentional)
```

---

# 47. Deployment Security Rules

✓ Good:

* SSH key-only, custom port
* UFW minimal ports
* databases internal only
* secrets in .env (chmod 600)
* HTTPS everywhere
* Cloudflare WAF enabled
* non-root container users
* explicit image tags

✗ Avoid:

* `.env` in GitHub
* public database/cache ports
* editing running containers
* deploying without health checks
* `latest` tag without rollback plan

---

# 48. Secrets Management

## Server Secrets

```bash
/var/www/myapp/.env    # chmod 600
```

## CI/CD Secrets

```txt
GitHub → Settings → Secrets and variables → Actions
```

## Rotate Secrets

```txt
1. Generate new secret
2. Update .env on VPS
3. Redeploy: docker compose up -d
4. Verify app works
5. Revoke old secret
```

Never log secrets in GitHub Actions output.

---

# 49. Network Security

```txt
Public:   80, 443 (Nginx), SSH custom port
Internal: backend:5000, postgres:5432, redis:6379
Blocked:  all other ports via UFW
```

Verify:

```bash
sudo ufw status verbose
nc -zv YOUR_PUBLIC_IP 5432    # should fail
nc -zv YOUR_PUBLIC_IP 6379    # should fail
curl -I https://yourdomain.com  # should succeed
```

---

# 50. Security Checklist

```txt
✓ VPS hardened (SSH, UFW, Fail2Ban)
✓ .env not in Git
✓ databases not public
✓ HTTPS enforced
✓ Cloudflare proxy enabled
✓ containers run as non-root
✓ secrets rotated on schedule
```

---

# 51. Backup Strategy

```txt
Layer 1: Database pg_dump daily
Layer 2: Docker volume tar weekly
Layer 3: .env + compose config before every change
Layer 4: VPS snapshot monthly
Layer 5: GitHub repo (source of truth)
Layer 6: Docker Hub image tags
```

See `15-backup-snapshots.md` for full guide.

---

# 52. Database Backups

```bash
# Daily cron on VPS
0 2 * * * docker exec postgres pg_dump -U admin myapp | gzip > /home/mosabbir/backups/myapp-$(date +\%F).sql.gz
```

## MongoDB (If Used)

```bash
0 2 * * * docker exec mongodb mongodump --uri="mongodb://admin:PASS@localhost:27017" --out=/tmp/b && docker cp mongodb:/tmp/b /home/mosabbir/backups/mongo-$(date +\%F)
```

## Copy To Mac

```bash
scp vps-prod:~/backups/*.sql.gz ./backups/
```

---

# 53. Volume And Config Backups

## Config Backup

```bash
tar -czvf ~/backups/config-$(date +%F).tar.gz \
  /var/www/myapp/.env \
  /var/www/myapp/docker-compose.prod.yml \
  /var/www/myapp/nginx/
```

## Volume Backup

```bash
docker compose stop postgres
docker run --rm \
  -v myapp_postgres_data:/data \
  -v ~/backups:/backup \
  alpine tar -czvf /backup/postgres-vol-$(date +%F).tar.gz /data
docker compose start postgres
```

## VPS Snapshot

Use Hetzner/DigitalOcean panel before major upgrades.

---

# 54. Backup Verification

Monthly restore test:

```bash
# Restore to test database
cat ~/backups/myapp-YYYY-MM-DD.sql.gz | gunzip | docker exec -i postgres psql -U admin myapp_test
docker exec postgres psql -U admin myapp_test -c "SELECT count(*) FROM users;"
```

Verify backup files exist:

```bash
ls -lah ~/backups/
```

---

# 55. Deployment Failed

## Diagnose

```bash
docker compose ps -a
docker compose logs backend --tail=50
docker compose logs nginx --tail=30
```

## Common Causes

```txt
Missing .env variable
Docker image pull failed
Migration failed
Port conflict
Out of disk space
Health check failing
```

## Fix

```bash
df -h
docker compose -f docker-compose.prod.yml config
docker compose logs backend 2>&1 | tail -30
export TAG=rollback-tag
docker compose up -d
```

---

# 56. Container Not Starting

```bash
docker compose ps -a
docker compose logs SERVICE --tail=50
docker inspect CONTAINER | grep -A10 State
```

Common causes:

* missing env var
* database not ready
* OOM killed
* bad Dockerfile CMD

```bash
docker compose up -d SERVICE
docker compose logs SERVICE -f
```

---

# 57. SSL And DNS Issues

```bash
dig yourdomain.com +short
curl -I http://yourdomain.com
curl -I https://yourdomain.com
curl -vI https://yourdomain.com 2>&1 | grep -i ssl
```

Fixes:

```txt
DNS not resolving   → check Cloudflare A record
SSL error           → Cloudflare Full (strict), check origin cert
Mixed content       → ensure all assets use HTTPS
```

---

# 58. Nginx 502 Bad Gateway

```txt
Nginx running but backend unreachable
```

```bash
docker compose ps backend
docker compose logs backend --tail=30
docker compose exec nginx curl -I http://backend:5000/health
docker compose exec nginx nginx -t
```

Fixes:

* backend container down → `docker compose up -d backend`
* wrong upstream port in nginx config
* backend listening on 127.0.0.1 instead of 0.0.0.0

---

# 59. Database And Redis Connectivity

```bash
docker compose exec backend nc -zv postgres 5432
docker compose exec backend nc -zv redis 6379
docker compose exec backend env | grep -E 'DATABASE|REDIS'
docker compose ps postgres redis
```

Fix connection strings:

```env
DATABASE_URL=postgresql://user:pass@postgres:5432/myapp
REDIS_URL=redis://:pass@redis:6379
```

Use service names — not `localhost` inside containers.

---

# 60. High Resource Usage

```bash
free -h
df -h
docker stats --no-stream
docker system df
```

Fixes:

```bash
docker system prune -f
docker image prune -a -f
# Add swap — see 03-linux-basics.md
# Upgrade VPS RAM
```

---

# 61. Debug Workflow

When something breaks:

```txt
1. curl https://yourdomain.com/health
2. dig yourdomain.com
3. Check Cloudflare SSL/DNS
4. docker compose ps
5. docker compose logs -f
6. docker stats
7. df -h && free -h
8. sudo ufw status
9. sudo ss -tulpn
```

Quick debug script:

```bash
#!/bin/bash
cd /var/www/myapp
echo "=== Containers ===" && docker compose ps
echo "=== Health ===" && curl -sf http://localhost:5000/health || echo "FAIL"
echo "=== Disk ===" && df -h /
echo "=== Memory ===" && free -h
echo "=== Recent Logs ===" && docker compose logs backend --tail=10
```

---

# 62. Tear Down Deployment (Linux / VPS)

Stop all services without deleting data:

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml down
docker compose ps -a
```

Stop Nginx only:

```bash
docker compose stop nginx
```

Full stack stop:

```bash
docker compose -f docker-compose.prod.yml stop
```

---

# 63. Remove Docker Stack And Volumes

Warning: destroys all database data.

## Backup First

```bash
docker exec postgres pg_dump -U admin myapp > ~/backups/final-myapp.sql
tar -czvf ~/backups/final-config.tar.gz .env docker-compose.prod.yml nginx/
```

## Remove Stack

```bash
docker compose -f docker-compose.prod.yml down     # keeps volumes
docker compose -f docker-compose.prod.yml down -v  # DESTROYS volumes
```

## Remove Specific Volumes

```bash
docker volume ls | grep myapp
docker volume rm myapp_postgres_data myapp_redis_data
```

---

# 64. Clean Up Deployment On Mac

Mac holds local dev environment — not production deployment.

## Stop Local Dev Stack

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml down -v
```

## Remove Local Images

```bash
docker rmi youruser/myapp-backend:dev
docker rmi youruser/myapp-frontend:dev
docker image prune -f
```

## Remove Local Secrets (If Decommissioning)

```bash
rm -f ~/Projects/myapp/.env
rm -rf ~/Projects/myapp/node_modules
```

## Clear SSH Deploy Keys From Agent (Optional)

```bash
ssh-add -d ~/.ssh/vps_ed25519
```

## Verify (Mac)

```bash
docker ps -a | grep myapp
docker volume ls | grep myapp
docker images | grep myapp
```

---

# 65. Remove Docker Images And Cache

## VPS

```bash
ssh vps-prod
docker compose -f docker-compose.prod.yml down --rmi all
docker image prune -a -f
docker builder prune -a -f
docker system prune -f
```

## Mac

```bash
docker system prune -a -f
docker builder prune -a -f
docker volume prune -f
```

Warning: `volume prune` and `down -v` destroy database data permanently.

---

# 66. DNS And Cloudflare Cleanup

When decommissioning a deployment:

## Remove DNS Records

```txt
Cloudflare → DNS → Delete:
  A record: @
  A record: api
  A record: www
  A record: coolify (if used)
```

## Remove Cloudflare Origin Certificate

```txt
Cloudflare → SSL → Origin Server → Revoke certificate
```

## Update Domain (Optional)

Point domain elsewhere or let expire.

---

# 67. Log Cleanup

## VPS Docker Logs

```bash
docker compose logs > ~/logs/final-deploy.log 2>&1
truncate -s 0 $(docker inspect --format='{{.LogPath}}' CONTAINER) 2>/dev/null
docker compose down
```

## VPS System Logs

```bash
sudo journalctl --vacuum-time=14d
sudo journalctl --vacuum-size=500M
rm -f ~/logs/deploy-*.log
```

## Mac Logs

```bash
rm -f ~/Projects/myapp/*.log
rm -rf ~/Projects/myapp/logs/
docker compose logs > ~/logs/local-final.log 2>&1
```

## Nginx Logs (If Host-Installed)

```bash
sudo truncate -s 0 /var/log/nginx/access.log
sudo truncate -s 0 /var/log/nginx/error.log
```

---

# 68. Cache And Leftover Files

## VPS Leftovers

```bash
rm -rf /var/www/myapp
rm -rf ~/backups/myapp-2025-*
rm -rf ~/logs/deploy-*
docker network prune -f
docker volume prune -f    # after backup
sudo apt autoremove -y && sudo apt autoclean
```

## Mac Leftovers

```bash
cd ~/Projects/myapp
rm -rf node_modules dist .next build
rm -rf ~/.npm/_cacache
npm cache clean --force
docker system prune -a -f
brew cleanup
```

## Docker Leftovers (Both)

```bash
docker system df
docker image ls
docker volume ls
docker network ls
docker system prune -a -f
```

## Config Leftovers

```bash
# Remove deploy script if created
rm -f /var/www/myapp/deploy.sh
# Remove cron backup jobs
crontab -e   # remove pg_dump lines
```

---

# 69. Verification After Removal

## VPS

```bash
docker ps -a | grep myapp
docker volume ls | grep myapp
docker images | grep myapp
ls /var/www/myapp 2>&1
curl -I https://yourdomain.com 2>&1
sudo ufw status
```

Expected: no containers/volumes/images, directory gone or empty, domain unreachable.

## Mac

```bash
docker ps -a | grep myapp
docker volume ls | grep myapp
docker images | grep myapp
ls ~/Projects/myapp/node_modules 2>&1
```

## DNS

```bash
dig yourdomain.com +short
# Should not point to decommissioned VPS IP (or domain removed)
```

## Cleanup Checklist

✓ Good:

* database backed up before volume removal
* docker compose down -v only after backup
* DNS updated or domain removed
* Cloudflare records cleaned up
* Mac local dev containers removed
* cron backup jobs removed

✗ Avoid:

* `docker volume prune` without database backup
* leaving DNS pointing to deleted VPS

---

# 70. Recommended Production Workflow

```txt
1. Develop locally (Mac + Docker Compose dev)
2. Push to GitHub main
3. GitHub Actions: test → build → push Docker Hub
4. SSH to VPS: docker compose pull && up -d
5. Run database migrations
6. Verify health checks
7. Monitor logs 15 minutes
8. Confirm Cloudflare SSL active
```

---

# 71. Modern Workflow

```txt
Developer (Mac)
↓
Local Docker Compose (dev)
↓
GitHub Push
↓
GitHub Actions
↓
Docker Hub
↓
SSH → VPS
↓
docker compose pull && up -d
↓
Nginx
↓
Cloudflare
↓
Users
```

Alternative:

```txt
Developer → GitHub Push → Coolify → Docker → Traefik → Cloudflare → Users
```

---

# 72. Real-World Workflow

Example: deploy SaaS to Hetzner VPS.

## Day 1 — VPS Setup

```bash
ssh root@YOUR_IP
apt update && apt upgrade -y
adduser mosabbir && usermod -aG sudo,docker mosabbir
# SSH harden, UFW, Fail2Ban — see 01-initial-vps-security-setup.md
curl -fsSL https://get.docker.com | sh
mkdir -p /var/www/myapp && chown mosabbir:mosabbir /var/www/myapp
```

## Day 2 — First Deploy

```bash
scp docker-compose.prod.yml .env nginx/ vps-prod:/var/www/myapp/
ssh vps-prod "chmod 600 /var/www/myapp/.env"
ssh vps-prod "cd /var/www/myapp && docker compose -f docker-compose.prod.yml up -d"
curl -f https://yourdomain.com/health
```

## Day 3 — CI/CD

Push to GitHub → Actions builds and deploys automatically on every `main` push.

## Ongoing

```bash
# Weekly
ssh vps-prod "df -h && free -h && docker system df"
# Daily (automated)
pg_dump cron → ~/backups/
```

---

# 73. Final Production Checklist

## VPS

✓ Ubuntu LTS, 2 GB+ RAM
✓ SSH hardened, UFW enabled, Fail2Ban active
✓ Docker + Compose installed

## Application

✓ Docker Compose manages all services
✓ explicit image tags with rollback plan
✓ health endpoints responding
✓ migrations applied
✓ `.env` chmod 600, not in Git

## Infrastructure

✓ Cloudflare DNS configured
✓ SSL Full (strict)
✓ Nginx reverse proxy working
✓ PostgreSQL and Redis internal only

## Operations

✓ daily database backups
✓ CI/CD pipeline working
✓ monitoring checklist run post-deploy
✓ rollback procedure documented and tested

## Full Stack

```txt
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
VPS (Docker Compose)
↓
Nginx
↓
Cloudflare
↓
Users
```

✓ Good:

* Docker Compose + CI/CD
* immutable images
* automated backups
* health checks

✗ Avoid:

* PM2 on host for new projects
* manual SSH file edits in production
* public databases
* `.env` in GitHub
* deploy without rollback plan

---

## Deployment Quick Commands Cheat Sheet

```bash
# Local test
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
curl -f http://localhost:5000/health
docker compose down

# Deploy (VPS)
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d --remove-orphans
docker compose ps
curl -f https://yourdomain.com/health

# Monitor
docker compose logs -f backend
docker stats --no-stream
df -h && free -h

# Rollback
export TAG=previous-sha
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d

# Backup
docker exec postgres pg_dump -U admin myapp | gzip > ~/backups/myapp-$(date +%F).sql.gz

# Cleanup (VPS — backup first!)
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml down -v
docker system prune -a -f
rm -rf /var/www/myapp

# Cleanup (Mac)
docker compose -f docker-compose.dev.yml down -v
docker system prune -a -f
rm -rf node_modules
```
