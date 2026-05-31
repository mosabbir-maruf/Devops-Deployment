# Coolify

## Table Of Contents

### Fundamentals

1. [What Is Coolify](#1-what-is-coolify)
2. [Coolify vs Manual Docker Deploy](#2-coolify-vs-manual-docker-deploy)
3. [Production Architecture](#3-production-architecture)
4. [Production Folder Structure](#4-production-folder-structure)

### Installation

5. [Requirements Before Install](#5-requirements-before-install)
6. [Install Coolify On Linux (VPS)](#6-install-coolify-on-linux-vps)
7. [Access Coolify From Mac](#7-access-coolify-from-mac)
8. [Coolify And Docker](#8-coolify-and-docker)
9. [Verify Coolify Installation](#9-verify-coolify-installation)

### Configuration

10. [Initial Dashboard Setup](#10-initial-dashboard-setup)
11. [Secure Coolify Dashboard](#11-secure-coolify-dashboard)
12. [Connect GitHub](#12-connect-github)
13. [Environment Variables](#13-environment-variables)
14. [Domain And DNS Configuration](#14-domain-and-dns-configuration)
15. [SSL And HTTPS](#15-ssl-and-https)
16. [Database Services In Coolify](#16-database-services-in-coolify)

### Development Workflow

17. [Local Development With Coolify](#17-local-development-with-coolify)
18. [Preview Deployments](#18-preview-deployments)
19. [Development Best Practices](#19-development-best-practices)

### Production Workflow

20. [Deploy Application From GitHub](#20-deploy-application-from-github)
21. [Production Build Settings](#21-production-build-settings)
22. [Coolify With Nginx And Cloudflare](#22-coolify-with-nginx-and-cloudflare)
23. [Multi-App VPS Management](#23-multi-app-vps-management)
24. [Coolify Updates](#24-coolify-updates)
25. [Rollback Workflow](#25-rollback-workflow)
26. [Production Coolify Checklist](#26-production-coolify-checklist)

### Security Best Practices

27. [Coolify Security Rules](#27-coolify-security-rules)
28. [Firewall Configuration](#28-firewall-configuration)
29. [Secrets Management](#29-secrets-management)
30. [Security Checklist](#30-security-checklist)

### Monitoring And Logging

31. [Coolify Container Logs](#31-coolify-container-logs)
32. [Application Logs](#32-application-logs)
33. [Resource Monitoring](#33-resource-monitoring)
34. [Health Checks](#34-health-checks)
35. [Debugging Deployments](#35-debugging-deployments)

### Backup And Restore

36. [Backup Strategy](#36-backup-strategy)
37. [Backup Commands](#37-backup-commands)
38. [Restore Workflow](#38-restore-workflow)
39. [Recovery Workflow](#39-recovery-workflow)

### Troubleshooting

40. [Application Not Starting](#40-application-not-starting)
41. [Deployment Failed](#41-deployment-failed)
42. [SSL Not Working](#42-ssl-not-working)
43. [DNS Issues](#43-dns-issues)
44. [Port Already In Use](#44-port-already-in-use)
45. [Container Restart Loops](#45-container-restart-loops)
46. [GitHub Connection Issues](#46-github-connection-issues)

### Cleanup And Uninstall

47. [Remove Applications In Coolify](#47-remove-applications-in-coolify)
48. [Stop And Remove Coolify Containers (Linux / VPS)](#48-stop-and-remove-coolify-containers-linux--vps)
49. [Clean Up Coolify On Mac](#49-clean-up-coolify-on-mac)
50. [Uninstall Coolify On Linux](#50-uninstall-coolify-on-linux)
51. [Log Cleanup](#51-log-cleanup)
52. [Cache And Leftover Files](#52-cache-and-leftover-files)
53. [Verification After Removal](#53-verification-after-removal)

### Production Workflows

54. [Recommended Production Workflow](#54-recommended-production-workflow)
55. [Modern Workflow](#55-modern-workflow)
56. [Real-World Workflow](#56-real-world-workflow)
57. [Final Production Checklist](#57-final-production-checklist)

---

# 1. What Is Coolify

Coolify is a self-hosted PaaS that deploys and manages Docker applications, databases, and services on your own VPS.

Production use cases:

* GitHub push-to-deploy
* multi-app VPS management
* automatic SSL
* managed PostgreSQL, Redis, MongoDB
* no monthly PaaS fees (you own the VPS)

Coolify runs on Docker and handles builds, reverse proxy, and SSL automatically.

---

# 2. Coolify vs Manual Docker Deploy

| Approach | Best For |
|----------|----------|
| **Coolify** | Multi-app VPS, fast setup, GUI management, teams preferring dashboard |
| **Docker Compose + CI/CD** | Full control, custom pipelines, large production teams |

Both are production-valid. Coolify is Docker underneath — not a replacement for understanding Docker.

```txt
Coolify = Docker + Traefik + Build Pipeline + Dashboard
```

✓ Good:

* Coolify for managing multiple client/personal apps on one VPS
* Manual Docker Compose when you need full pipeline control

✗ Avoid:

* Coolify as excuse to skip Docker fundamentals
* Running Coolify on an undersized VPS (< 2 GB RAM)

---

# 3. Production Architecture

## Single App With Coolify

```txt
User
↓
Cloudflare
↓
Coolify Proxy (Traefik)
↓
Application Container
↓
PostgreSQL Container
↓
Redis Container
```

## Full Stack

```txt
User
↓
Cloudflare
↓
Coolify (Traefik + SSL)
↓
Frontend Container
↓
Backend Container
↓
PostgreSQL Container
↓
Redis Container
```

## Deploy Flow

```txt
Developer
↓
GitHub Push
↓
Coolify Webhook
↓
Docker Build
↓
Container Deploy
↓
Automatic SSL
↓
Users
```

---

# 4. Production Folder Structure

## VPS With Coolify

```txt
/data/coolify/                    # Coolify data (managed by installer)
├── source/
├── applications/
├── databases/
├── backups/
└── ssh/

/var/lib/docker/                  # All Docker images, volumes, networks
├── volumes/
│   ├── coolify-db/
│   ├── app-postgres-data/
│   └── app-redis-data/
└── overlay2/

/home/mosabbir/                   # Admin SSH user (not Coolify data)
└── .ssh/
```

## Your Application Repo (GitHub)

```txt
myapp/
├── Dockerfile
├── docker-compose.yml            # Optional (Coolify uses Dockerfile primarily)
├── .dockerignore
├── .env.example
├── src/
├── package.json
└── .github/
    └── workflows/                # Optional CI before Coolify deploy
```

Never commit `.env` to GitHub.

---

# 5. Requirements Before Install

## VPS Requirements

```txt
Ubuntu 22.04 / 24.04 LTS
Minimum 2 GB RAM (4 GB recommended)
2 vCPU recommended
Docker installed and running
Non-root admin user (mosabbir)
SSH hardened (see 02-ssh-guide.md)
UFW configured
Domain ready (optional but recommended)
```

## Pre-Install Checklist

```bash
ssh vps-prod
docker --version
docker compose version
free -h
df -h
sudo ufw status
```

Expected:

```txt
Docker 24+
RAM: 2 GB+
Disk: 20 GB+ free
```

---

# 6. Install Coolify On Linux (VPS)

Coolify installs via official script on the VPS host.

## Ensure Docker Is Running

```bash
sudo systemctl status docker
docker ps
```

Install Docker if missing — see `04-docker.md`.

## Install Coolify

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

## Allow Coolify Ports In UFW

```bash
sudo ufw allow 8000/tcp    # Dashboard (temporary — restrict after domain setup)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 6001:6002/tcp   # Realtime / terminal (if used)
sudo ufw reload
sudo ufw status
```

## Verify Containers Started

```bash
docker ps
```

Expected Coolify-related containers running.

---

# 7. Access Coolify From Mac

## Initial Access (IP)

Open in browser:

```txt
http://YOUR_PUBLIC_IP:8000
```

## Production Access (Domain)

After setup:

```txt
https://coolify.yourdomain.com
```

## SSH Tunnel (If Port 8000 Not Public)

```bash
ssh -L 8000:127.0.0.1:8000 vps-prod
```

Then open:

```txt
http://localhost:8000
```

✓ Good:

* Access dashboard via HTTPS domain in production
* Restrict port 8000 after domain configured

✗ Avoid:

* Leaving port 8000 open to the world long-term

---

# 8. Coolify And Docker

Coolify manages Docker containers on your behalf.

## View All Containers

```bash
docker ps -a
```

## Coolify Core Containers

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -i coolify
```

## Coolify CLI Update

```bash
coolify update
```

## Restart Coolify

```bash
docker restart coolify
# or restart all coolify containers:
docker ps --filter "name=coolify" -q | xargs docker restart
```

Production rule: manage **applications** via Coolify dashboard. Use SSH + `docker` commands for debugging only.

---

# 9. Verify Coolify Installation

## Container Status

```bash
docker ps
sudo systemctl status docker
```

## Coolify Logs

```bash
docker logs coolify --tail=50
docker logs coolify -f
```

## Dashboard Accessible

```bash
curl -I http://localhost:8000
```

## Disk And Memory

```bash
df -h
free -h
docker system df
```

## Health Summary

```txt
✓ Coolify container running
✓ Docker active
✓ Dashboard loads in browser
✓ Port 80/443 open in UFW
```

---

# 10. Initial Dashboard Setup

After opening `http://YOUR_PUBLIC_IP:8000`:

```txt
1. Create admin account (strong password)
2. Set server name
3. Configure instance domain (coolify.yourdomain.com)
4. Verify server connection
5. Set timezone (UTC recommended)
```

Admin account tips:

* use password manager
* enable 2FA if available in your Coolify version
* do not reuse VPS or GitHub passwords

---

# 11. Secure Coolify Dashboard

## Set Custom Domain For Dashboard

Coolify → Settings → Configuration:

```txt
Instance Domain: coolify.yourdomain.com
```

DNS (Cloudflare):

```txt
Type: A
Name: coolify
Content: YOUR_PUBLIC_IP
Proxy: DNS only (grey cloud)
```

## Enable HTTPS For Dashboard

Coolify auto-provisions Let's Encrypt SSL once DNS resolves.

## Restrict Dashboard Port

After domain works, remove public access to port 8000:

```bash
sudo ufw delete allow 8000/tcp
sudo ufw status
```

Access via `https://coolify.yourdomain.com` only.

✓ Good:

* HTTPS dashboard on subdomain
* port 8000 blocked after domain setup
* strong admin password

✗ Avoid:

* HTTP dashboard on public IP long-term
* weak admin credentials

---

# 12. Connect GitHub

## In Coolify Dashboard

```txt
Settings → Sources → Add GitHub
```

## GitHub App Method (Recommended)

```txt
1. Coolify → Add GitHub App
2. Authorize on GitHub
3. Select repositories (or all)
4. Save connection
```

## Deploy Key Method (Single Repo)

For private repos without full GitHub App:

```txt
1. Generate deploy key in Coolify
2. Add public key to GitHub repo → Settings → Deploy keys
3. Connect repository in Coolify
```

## Verify Connection

```txt
Coolify → New Resource → Application → Select GitHub repo
```

Repo list should appear.

---

# 13. Environment Variables

Set in Coolify → Application → Environment Variables.

## Production Example

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:pass@postgres:5432/mydb
REDIS_URL=redis://redis:6379
JWT_SECRET=your-long-random-secret
```

## Rules

```txt
✓ Set secrets in Coolify dashboard only
✓ Use .env.example in GitHub (no real values)
✓ Mark sensitive vars as "secret" in Coolify

✗ Commit .env to GitHub
✗ Hardcode secrets in Dockerfile
```

## Sync From .env.example

Keep `.env.example` in repo as documentation:

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=
JWT_SECRET=
```

---

# 14. Domain And DNS Configuration

## Add Domain To Application

Coolify → Application → Settings → Domains:

```txt
app.yourdomain.com
api.yourdomain.com
```

## Cloudflare DNS Records

```txt
Type: A
Name: app
Content: YOUR_PUBLIC_IP
Proxy: Proxied (orange cloud) — optional

Type: A
Name: api
Content: YOUR_PUBLIC_IP
Proxy: Proxied
```

## Verify DNS

```bash
dig app.yourdomain.com +short
dig api.yourdomain.com +short
```

Expected: your VPS IP (or Cloudflare proxy IP if proxied).

---

# 15. SSL And HTTPS

Coolify uses Traefik to auto-provision Let's Encrypt certificates.

## Enable SSL

Coolify → Application → Domains → Enable HTTPS

Coolify automatically:

```txt
Requests Let's Encrypt certificate
Configures Traefik routing
Renews certificate before expiry
```

## Cloudflare SSL Mode

If using Cloudflare proxy:

```txt
Cloudflare SSL/TLS → Full (strict)
```

Use Cloudflare Origin Certificate if needed — see `12-domain-dns-cloudflare.md`.

## Verify HTTPS

```bash
curl -I https://app.yourdomain.com
```

Expected:

```txt
HTTP/2 200
```

---

# 16. Database Services In Coolify

Deploy databases from Coolify dashboard — not exposed publicly.

## Supported Databases

```txt
PostgreSQL
MySQL
MariaDB
MongoDB
Redis
```

## Create Database

```txt
Coolify → New Resource → Database → PostgreSQL
→ Set name, version, credentials
→ Deploy
```

## Connect Application

Use internal Docker network hostname in `DATABASE_URL`:

```env
DATABASE_URL=postgresql://user:password@CONTAINER_NAME:5432/dbname
```

Coolify shows internal connection string in database settings.

✓ Good:

* databases on internal Docker network only
* credentials generated by Coolify

✗ Avoid:

* exposing database ports (5432, 27017) in UFW
* public database access

---

# 17. Local Development With Coolify

Coolify is for **deployment**, not local development.

## Recommended Split

```txt
Local (Mac)          → docker compose dev → test locally
GitHub               → push to main
Coolify (VPS)        → auto-deploy production
```

## Local Dev Commands

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml up -d
docker compose logs -f
```

Push to GitHub when ready — Coolify deploys automatically.

---

# 18. Preview Deployments

Coolify supports preview deployments for pull requests (version-dependent).

```txt
PR opened on GitHub
↓
Coolify builds preview
↓
preview-123.app.yourdomain.com
↓
Review → merge → production deploy
```

Configure in Coolify → Application → Preview Deployments.

---

# 19. Development Best Practices

✓ Good:

* develop locally with Docker Compose
* push to staging branch first
* use preview deployments for PRs
* keep Dockerfile in repo

✗ Avoid:

* editing code on the VPS directly
* deploying untested builds to production branch
* skipping local Docker testing

---

# 20. Deploy Application From GitHub

## Full Deploy Workflow

```txt
1. Push code to GitHub
2. Coolify → New Resource → Application
3. Select GitHub repo + branch (main)
4. Configure build pack / Dockerfile
5. Set environment variables
6. Add domain
7. Enable SSL
8. Deploy
```

## Dashboard Steps

```txt
New Resource
↓
Application
↓
Public Repository / GitHub App
↓
Select repo: username/myapp
↓
Branch: main
↓
Build Pack: Dockerfile (recommended)
↓
Port: 3000
↓
Deploy
```

## Verify Deployment

```bash
ssh vps-prod
docker ps
curl -I https://app.yourdomain.com
```

---

# 21. Production Build Settings

## Dockerfile-Based Build (Recommended)

Ensure repo contains production Dockerfile:

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
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Coolify Build Settings

```txt
Build Pack:     Dockerfile
Dockerfile:     Dockerfile
Port:           3000
Start Command:  (leave empty — use Dockerfile CMD)
Base Directory: / (or /apps/backend for monorepos)
```

## Monorepo Example

```txt
Base Directory: /apps/api
Dockerfile:     /apps/api/Dockerfile
Port:           5000
```

---

# 22. Coolify With Nginx And Cloudflare

Coolify includes Traefik as reverse proxy — separate Nginx is optional.

## Default (Coolify Handles Routing)

```txt
User → Cloudflare → Coolify Traefik → App Container
```

## With External Nginx (Advanced)

Use when you need custom Nginx config Coolify cannot provide:

```txt
User → Cloudflare → Nginx (host) → Coolify Traefik → App
```

Most deployments do not need external Nginx.

## Cloudflare Integration

```txt
1. A record → VPS IP
2. SSL mode: Full (strict)
3. Enable WAF rules
4. Rate limiting on /api/*
```

See `12-domain-dns-cloudflare.md` for full DNS setup.

---

# 23. Multi-App VPS Management

Coolify excels at running multiple apps on one VPS.

```txt
VPS
├── coolify.yourdomain.com     (dashboard)
├── app1.yourdomain.com        (SaaS product)
├── app2.yourdomain.com        (client project)
├── api.yourdomain.com         (API)
├── postgres-app1              (database)
└── redis-app1                 (cache)
```

## Resource Limits

Set per-application in Coolify to prevent one app consuming all RAM:

```txt
Application → Settings → Resource Limits
CPU: 1
Memory: 512 MB
```

## Monitor Total Usage

```bash
docker stats --no-stream
free -h
```

Upgrade VPS if consistently above 80% RAM.

---

# 24. Coolify Updates

## Update Coolify

```bash
ssh vps-prod
coolify update
```

## Verify After Update

```bash
docker ps
docker logs coolify --tail=30
curl -I http://localhost:8000
```

## Update Application

Push to GitHub — Coolify auto-redeploys if webhook configured.

Or manually:

```txt
Coolify → Application → Deploy
```

---

# 25. Rollback Workflow

## Rollback Via Git

```txt
1. git revert BAD_COMMIT (or reset branch)
2. Push to GitHub
3. Coolify auto-redeploys previous working version
```

## Rollback Via Coolify Dashboard

```txt
Application → Deployments → Select previous deployment → Redeploy
```

## Rollback Database (If Migration Failed)

```bash
ssh vps-prod
docker ps | grep postgres
docker exec -it POSTGRES_CONTAINER pg_restore ...
```

Always backup database before deploys with schema changes.

## Emergency Stop

```txt
Coolify → Application → Stop
```

Or via SSH:

```bash
docker stop APP_CONTAINER_NAME
```

---

# 26. Production Coolify Checklist

✓ Good:

* VPS hardened (SSH, UFW, Fail2Ban)
* Coolify dashboard on HTTPS subdomain
* GitHub App connected
* Dockerfile in repo
* env vars in Coolify (not Git)
* databases internal only
* SSL enabled on all domains
* backups configured

✗ Avoid:

* port 8000 open publicly
* databases exposed to internet
* secrets in GitHub
* deploying without Dockerfile

---

# 27. Coolify Security Rules

✓ Good:

* strong Coolify admin password
* dashboard on HTTPS with restricted access
* Cloudflare WAF in front of public apps
* secrets in Coolify env vars
* regular Coolify updates
* VPS kept patched (`apt upgrade`)

✗ Avoid:

* sharing admin credentials
* exposing database ports in UFW
* running Coolify on same VPS as untrusted workloads without isolation
* skipping backups

---

# 28. Firewall Configuration

## Production UFW Rules

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 1182/tcp      # SSH custom port
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose
```

## Do Not Open

```txt
5432   PostgreSQL
27017  MongoDB
6379   Redis
8000   Coolify dashboard (after domain configured)
```

## Verify

```bash
sudo ss -tlnp | grep -E ':80|:443|:1182'
nc -zv YOUR_PUBLIC_IP 5432   # Should fail/refused
```

---

# 29. Secrets Management

## Store In Coolify

```txt
Application → Environment Variables → Add
→ Mark as secret
```

## Required Secrets Example

```env
JWT_SECRET=
DATABASE_URL=
STRIPE_SECRET_KEY=
AWS_SECRET_ACCESS_KEY=
```

## Rotate Secrets

```txt
1. Generate new secret
2. Update in Coolify env vars
3. Redeploy application
4. Verify app works
5. Revoke old secret
```

Never log secrets in build output — verify Coolify build logs do not print env vars.

---

# 30. Security Checklist

✓ Good:

* HTTPS on all public endpoints
* UFW minimal ports
* databases not public
* secrets in Coolify only
* Coolify updated
* Cloudflare protection enabled

✗ Avoid:

* HTTP-only production apps
* `.env` in GitHub
* public admin panels without auth

---

# 31. Coolify Container Logs

## Coolify Platform Logs

```bash
docker logs coolify --tail=100
docker logs coolify -f
```

## All Coolify Containers

```bash
docker ps --filter "name=coolify" --format "{{.Names}}" | xargs -I{} docker logs {} --tail=20
```

## Traefik / Proxy Logs

```bash
docker ps | grep -i traefik
docker logs TRAEFIK_CONTAINER --tail=50
```

---

# 32. Application Logs

## Via Coolify Dashboard

```txt
Application → Logs → Live stream
```

## Via SSH

```bash
docker ps
docker logs APP_CONTAINER_NAME -f
docker logs APP_CONTAINER_NAME --tail=200 --since 1h
```

## Export Logs

```bash
docker logs APP_CONTAINER_NAME > app-logs-$(date +%F).log
```

---

# 33. Resource Monitoring

## Container Resource Usage

```bash
docker stats --no-stream
docker stats APP_CONTAINER_NAME
```

## VPS Resources

```bash
free -h
df -h
htop
```

## Docker Disk Usage

```bash
docker system df
du -sh /var/lib/docker
du -sh /data/coolify
```

## Alert Thresholds

```txt
RAM  > 85%  → upgrade VPS or reduce apps
Disk > 85%  → prune images, expand disk
CPU  > 90% sustained → investigate app performance
```

---

# 34. Health Checks

## Application Health Endpoint

Add to your app:

```javascript
app.get("/health", (req, res) => res.json({ status: "ok" }));
```

## Verify From VPS

```bash
curl -f http://localhost:PORT/health
curl -f https://app.yourdomain.com/health
```

## Container Health

```bash
docker ps
docker inspect APP_CONTAINER --format='{{.State.Health.Status}}'
```

## Coolify Dashboard

```txt
Application → Status should show "Running"
Deployments → Latest should show "Success"
```

---

# 35. Debugging Deployments

## Check Build Logs

```txt
Coolify → Application → Deployments → Latest → Build Logs
```

## Check Runtime Logs

```bash
docker logs APP_CONTAINER --tail=100
```

## Inspect Container

```bash
docker inspect APP_CONTAINER | grep -A10 State
docker exec -it APP_CONTAINER sh
```

## Common Debug Commands

```bash
docker ps -a
docker compose logs 2>/dev/null || docker logs $(docker ps -q) --tail=20
curl -v http://localhost:3000
dig app.yourdomain.com +short
```

---

# 36. Backup Strategy

Production backup layers:

```txt
1. Coolify database backups (if enabled)
2. Application database volume backups
3. VPS snapshot (Hetzner, DigitalOcean)
4. GitHub repo (source of truth)
5. Environment variable export from Coolify
```

Schedule:

```txt
Database volumes  → daily
VPS snapshot      → weekly
Env var export    → before every major change
```

See `15-backup-snapshots.md` for full backup guide.

---

# 37. Backup Commands

## Export Coolify Env Vars (Manual)

Copy from Coolify dashboard → Application → Environment Variables.

## PostgreSQL Backup

```bash
docker ps | grep postgres
docker exec POSTGRES_CONTAINER pg_dump -U postgres mydb > ~/backups/mydb-$(date +%F).sql
```

## Docker Volume Backup

```bash
docker run --rm \
  -v VOLUME_NAME:/data \
  -v ~/backups:/backup \
  alpine tar -czvf /backup/volume-$(date +%F).tar.gz /data
```

## VPS Snapshot

Use cloud provider panel:

```txt
Hetzner → Server → Snapshots → Create
DigitalOcean → Droplet → Snapshots → Take Snapshot
```

---

# 38. Restore Workflow

## Restore Database

```bash
cat ~/backups/mydb-YYYY-MM-DD.sql | docker exec -i POSTGRES_CONTAINER psql -U postgres mydb
```

## Restore Volume

```bash
docker stop APP_CONTAINER
docker run --rm \
  -v VOLUME_NAME:/data \
  -v ~/backups:/backup \
  alpine sh -c "cd /data && tar -xzvf /backup/volume-YYYY-MM-DD.tar.gz --strip-components=1"
docker start APP_CONTAINER
```

## Redeploy Application

```txt
Coolify → Application → Deploy
```

## Verify

```bash
curl -f https://app.yourdomain.com/health
docker ps
```

---

# 39. Recovery Workflow

Complete VPS failure:

```txt
1. Provision new VPS (same specs)
2. Install Docker
3. Install Coolify (curl install script)
4. Restore VPS snapshot OR reconfigure manually
5. Reconnect GitHub
6. Restore database volumes from backup
7. Redeploy applications
8. Update Cloudflare DNS if IP changed
9. Verify all domains and SSL
```

If Coolify data lost but GitHub intact:

```txt
Reinstall Coolify → reconnect GitHub → redeploy all apps from repos
```

---

# 40. Application Not Starting

## Check Logs

```bash
docker ps -a
docker logs APP_CONTAINER --tail=100
```

## Common Causes

```txt
Wrong PORT in Coolify settings
Missing environment variables
Build failed (check build logs)
App crash on startup (missing DATABASE_URL)
Out of memory
```

## Fix

```txt
1. Coolify → Application → Deployments → Build Logs
2. Fix Dockerfile or env vars
3. Push to GitHub or click Redeploy
```

```bash
docker restart APP_CONTAINER
docker logs APP_CONTAINER -f
```

---

# 41. Deployment Failed

## Check Build Logs

```txt
Coolify → Deployments → Failed deployment → Logs
```

## Common Causes

```txt
Dockerfile error
npm install failure
Missing package-lock.json
Wrong base directory (monorepo)
GitHub permission revoked
Out of disk space
```

## Fix Disk Space

```bash
df -h
docker system prune -f
docker builder prune -f
```

## Fix GitHub Access

```txt
Coolify → Settings → Sources → Reconnect GitHub
GitHub → Settings → Applications → Coolify → Configure
```

---

# 42. SSL Not Working

## Checklist

```txt
✓ DNS A record points to VPS IP
✓ Port 80 and 443 open in UFW
✓ Domain added in Coolify application settings
✓ Cloudflare SSL mode: Full (strict)
✓ No conflicting certificate on host
```

## Diagnose

```bash
curl -I http://app.yourdomain.com
curl -I https://app.yourdomain.com
dig app.yourdomain.com +short
sudo ufw status
docker logs TRAEFIK_CONTAINER --tail=50
```

## Cloudflare Fix

```txt
SSL/TLS → Full (strict)
Disable "Always Use HTTPS" temporarily during cert provisioning
Wait 5–10 minutes for Let's Encrypt
```

---

# 43. DNS Issues

## Symptoms

```txt
Domain not resolving
SSL certificate provisioning fails
```

## Diagnose

```bash
dig app.yourdomain.com +short
dig app.yourdomain.com A
nslookup app.yourdomain.com
```

## Fix Cloudflare Record

```txt
Type: A
Name: app
Content: YOUR_VPS_IP
TTL: Auto
Proxy: DNS only (grey) during initial SSL setup, then proxied
```

Allow DNS propagation (up to 24 hours, usually minutes).

---

# 44. Port Already In Use

## Find Conflicting Process

```bash
sudo ss -tlnp | grep :80
sudo ss -tlnp | grep :443
sudo lsof -i :80
```

## Common Conflict

Host Nginx and Coolify Traefik both on port 80.

## Fix

```bash
sudo systemctl stop nginx
sudo systemctl disable nginx
docker restart TRAEFIK_CONTAINER
```

Or configure Nginx to proxy to Traefik — advanced setup only.

---

# 45. Container Restart Loops

## Diagnose

```bash
docker ps -a
docker logs APP_CONTAINER --tail=50
docker inspect APP_CONTAINER --format='{{.State.RestartCount}}'
```

## Common Causes

```txt
App crashes on boot (missing env var)
Database not reachable
Port mismatch
Out of memory (OOM killed)
```

## Fix

```bash
docker logs APP_CONTAINER 2>&1 | tail -30
docker stats APP_CONTAINER --no-stream
# Fix env vars in Coolify → Redeploy
```

---

# 46. GitHub Connection Issues

## Symptoms

```txt
Repository not listed
Webhook not triggering deploy
Permission denied (repo)
```

## Fix

```txt
1. Coolify → Settings → Sources → Reconnect GitHub
2. GitHub → Settings → Applications → Coolify → grant repo access
3. Verify webhook: GitHub repo → Settings → Webhooks
4. Test deploy manually: Coolify → Deploy
```

## Webhook Test

Push empty commit:

```bash
git commit --allow-empty -m "trigger coolify deploy"
git push origin main
```

Check Coolify → Deployments for new build.

---

# 47. Remove Applications In Coolify

## Via Dashboard

```txt
Application → Settings → Delete Application
```

Confirm deletion of containers and volumes if prompted.

## Via SSH (If Dashboard Unavailable)

```bash
docker ps -a | grep APP_NAME
docker stop APP_CONTAINER
docker rm APP_CONTAINER
docker volume ls | grep APP_NAME
docker volume rm VOLUME_NAME
```

---

# 48. Stop And Remove Coolify Containers (Linux / VPS)

Coolify runs only on the Linux VPS — not on Mac.

## Stop All Coolify Containers

```bash
ssh vps-prod
docker ps --filter "name=coolify" -q | xargs docker stop
```

## Remove Coolify Containers

```bash
docker ps -a --filter "name=coolify" -q | xargs docker rm
```

## Remove Traefik (If Installed By Coolify)

```bash
docker ps -a | grep traefik
docker rm -f TRAEFIK_CONTAINER_NAME
```

Warning: stopping Coolify stops all managed application deployments.

---

# 49. Clean Up Coolify On Mac

Coolify is accessed from Mac via browser only — nothing installs on Mac except local dev tools.

## Remove Browser Data (Optional)

```txt
Chrome → Settings → Privacy → Clear browsing data
→ Cookies for coolify.yourdomain.com
```

Or remove saved passwords for Coolify dashboard in your password manager if decommissioning.

## Remove SSH Tunnel Config (If Used)

Edit `~/.ssh/config` and remove Coolify-related entries:

```bash
nano ~/.ssh/config
# Remove Host blocks used only for Coolify dashboard tunnel
```

## Stop Local Dev Containers (If Testing Coolify Locally)

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml down -v
docker ps -a | grep -E 'coolify|traefik'
```

## Remove Local Docker Images (Dev Only)

```bash
docker images | grep -E 'coolify|traefik'
docker rmi IMAGE_ID
docker image prune -f
```

## Clear Mac Docker Desktop Cache

```bash
# Docker Desktop → Troubleshoot → Clean / Purge data (GUI)
# Or via CLI:
docker system prune -a -f
```

## Verify (Mac)

```bash
docker ps -a | grep coolify
docker volume ls | grep coolify
# Browser: coolify.yourdomain.com should be unreachable or removed from DNS
```

Expected: no local coolify containers, no orphaned dev volumes.

---

# 50. Uninstall Coolify On Linux

## Stop Coolify

```bash
ssh vps-prod
docker ps --filter "name=coolify" -q | xargs docker stop
```

## Remove Coolify Data Directory

```bash
sudo rm -rf /data/coolify
```

## Remove Coolify CLI

```bash
sudo rm -f /usr/local/bin/coolify
which coolify
```

## Remove Coolify Docker Resources

```bash
docker ps -a --filter "name=coolify" -q | xargs docker rm -f
docker volume ls | grep coolify
docker volume rm $(docker volume ls -q | grep coolify) 2>/dev/null
docker network ls | grep coolify
docker network prune -f
```

## Remove Traefik

```bash
docker ps -a | grep traefik
docker rm -f $(docker ps -a --filter "name=traefik" -q)
```

## Remove Coolify Docker Images

```bash
docker images | grep -i coolify
docker images | grep traefik
docker rmi IMAGE_ID
docker image prune -a -f
```

## Verify (Linux)

```bash
ls /data/coolify 2>&1
which coolify
docker ps -a | grep coolify
curl -I http://localhost:8000
```

Expected: data dir gone, CLI not found, no containers, port 8000 closed.

---

# 51. Log Cleanup

## Coolify Platform Logs (Linux / VPS)

```bash
docker logs coolify --tail=100 > ~/logs/coolify-final.log 2>&1
docker logs coolify -f

# Truncate log file (container keeps running)
truncate -s 0 $(docker inspect --format='{{.LogPath}}' coolify)
```

## All Coolify-Related Container Logs

```bash
docker ps --filter "name=coolify" --format "{{.Names}}" | while read c; do
  docker logs "$c" > ~/logs/"$c"-$(date +%F).log 2>&1
done
```

## Traefik / Proxy Logs

```bash
docker ps | grep traefik
docker logs TRAEFIK_CONTAINER --tail=200 > ~/logs/traefik-final.log 2>&1
```

## Application Logs (Managed By Coolify)

Export from Coolify dashboard before removal:

```txt
Application → Logs → Export / copy
```

Or via SSH:

```bash
docker logs APP_CONTAINER_NAME > ~/logs/app-final.log 2>&1
```

## Mac — Local Dev Logs

```bash
rm -f ~/logs/coolify-*.log
rm -f ~/Projects/myapp/*.log
docker compose logs > ~/logs/compose-final.log 2>&1
```

## System Logs (Linux — If Coolify Installer Used systemd)

```bash
sudo journalctl --vacuum-time=14d
sudo journalctl --vacuum-size=500M
```

---

# 52. Cache And Leftover Files

## Docker Cache (Linux / VPS)

```bash
docker system prune -f
docker builder prune -f
docker image prune -a -f
```

## Coolify Leftover Volumes (Backup First)

```bash
docker volume ls
docker volume ls | grep -E 'coolify|app'
# Backup important app volumes before prune
docker volume prune -f
```

Warning: `volume prune` removes unused volumes permanently.

## Coolify Leftover Networks

```bash
docker network ls | grep coolify
docker network prune -f
```

## Linux Host Leftovers

```bash
sudo rm -rf /data/coolify
sudo rm -f /usr/local/bin/coolify
sudo rm -rf /tmp/coolify-*
sudo rm -rf ~/logs/coolify-*
```

## Mac Leftovers

```bash
rm -rf ~/logs/coolify-*
rm -rf ~/Library/Caches/*coolify* 2>/dev/null
docker system prune -f
docker volume prune -f
```

## UFW Cleanup (Linux)

```bash
sudo ufw delete allow 8000/tcp
sudo ufw delete allow 6001:6002/tcp
sudo ufw reload
sudo ufw status
```

## DNS Cleanup (Cloudflare)

Remove records if decommissioning Coolify dashboard:

```txt
Type: A  Name: coolify  → Delete
```

## Old Deployment Backups

```bash
ls ~/backups/
rm -rf ~/backups/coolify-*
rm -rf ~/backups/myapp-2025-*
```

---

# 53. Verification After Removal

## Linux / VPS — Coolify Removed

```bash
docker ps -a | grep coolify
docker volume ls | grep coolify
docker images | grep -i coolify
ls /data/coolify 2>&1
which coolify
curl -I http://localhost:8000
sudo ufw status | grep 8000
```

Expected: no coolify containers/volumes/images, data dir gone, CLI missing, port 8000 closed.

## Mac

```bash
docker ps -a | grep coolify
docker volume ls | grep coolify
ls ~/logs/coolify-* 2>&1
```

Expected: no local coolify containers, no leftover log dirs.

## Docker Still Working (Linux)

```bash
docker --version
docker ps
sudo systemctl status docker
```

## Manual Apps Still Running (If Keeping VPS)

```bash
docker ps
curl -I http://localhost
```

## Cleanup Checklist

✓ Good:

* Coolify containers and `/data/coolify` removed
* UFW rules for 8000/6001 removed
* app volumes backed up before prune
* DNS records updated if decommissioning
* Mac browser credentials rotated/removed

✗ Avoid:

* `docker volume prune` without backing up databases
* leaving port 8000 open after uninstall

---

# 54. Recommended Production Workflow

```txt
1. Harden VPS (SSH, UFW, Fail2Ban)
2. Install Docker
3. Install Coolify
4. Secure dashboard (HTTPS domain, close port 8000)
5. Connect GitHub
6. Deploy apps with Dockerfile
7. Add databases via Coolify
8. Configure domains + Cloudflare + SSL
9. Set up backups
10. Monitor resources weekly
```

---

# 55. Modern Workflow

```txt
Developer (Mac)
↓
Local Docker Compose (dev)
↓
GitHub Push
↓
Coolify Webhook
↓
Docker Build on VPS
↓
Traefik + SSL
↓
Cloudflare
↓
Users
```

Alternative without Coolify:

```txt
Developer → GitHub → GitHub Actions → Docker Hub → SSH → docker compose
```

Choose Coolify for speed and multi-app management. Choose manual CI/CD for maximum control.

---

# 56. Real-World Workflow

Example: deploy a Node.js SaaS on Hetzner with Coolify.

## Day 1 — Setup

```bash
ssh vps-prod
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
# Open http://IP:8000 → create admin
# Set domain: coolify.mysaas.com
```

## Day 2 — First App

```txt
Coolify → New Application → GitHub → mysaas/api
Build: Dockerfile, Port: 5000
Env: DATABASE_URL, JWT_SECRET, NODE_ENV=production
Domain: api.mysaas.com → Enable SSL
Deploy
```

## Day 3 — Database

```txt
Coolify → New Database → PostgreSQL
Copy internal connection string → update app env vars
Redeploy
```

## Ongoing

```bash
git push origin main    # Coolify auto-deploys
ssh vps-prod
docker stats --no-stream
```

---

# 57. Final Production Checklist

## VPS

✓ Ubuntu LTS, 2 GB+ RAM
✓ SSH hardened, UFW enabled
✓ Docker running

## Coolify

✓ Dashboard on HTTPS subdomain
✓ Port 8000 not publicly open
✓ Admin strong password
✓ Coolify updated

## Applications

✓ Dockerfile in every repo
✓ Secrets in Coolify env vars
✓ Domains + SSL configured
✓ Health endpoint working
✓ Databases internal only

## Infrastructure

✓ Cloudflare DNS configured
✓ Backups scheduled
✓ Resource monitoring in place

## Full Stack

```txt
Developer
↓
GitHub
↓
Coolify
↓
Docker
↓
Traefik + SSL
↓
Cloudflare
↓
Users
```

---

## Coolify Quick Commands Cheat Sheet

```bash
# Install
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

# Update
coolify update

# Status
docker ps
docker logs coolify --tail=50
docker stats --no-stream

# App logs
docker logs APP_CONTAINER -f

# Resources
free -h && df -h
docker system df

# Firewall
sudo ufw status
sudo ufw allow 80/tcp && sudo ufw allow 443/tcp

# Cleanup (VPS)
docker ps --filter "name=coolify" -q | xargs docker stop
sudo rm -rf /data/coolify
sudo rm -f /usr/local/bin/coolify
docker volume prune -f    # backup DBs first
sudo ufw delete allow 8000/tcp

# Cleanup (Mac — local dev)
docker compose -f docker-compose.dev.yml down -v
docker system prune -f
rm -rf ~/logs/coolify-*
```
