# DevOps Deployment

Production-ready DevOps documentation for VPS hosting, Docker, security, deployment, and self-hosted infrastructure by **Mosabbir Maruf**.

**Stack:** Ubuntu VPS · Docker · Node.js / Go / Python · PostgreSQL / MongoDB / Redis · Nginx · Cloudflare · GitHub Actions

**Platforms:** Mac (development) · Linux VPS (production)

**Languages:** Node.js · Go · Python — auto-detected by the Makefile

Designed for:

- beginners learning DevOps hands-on
- developers deploying real full-stack projects
- production-grade VPS and Docker workflows
- self-hosted infrastructure without vendor lock-in
- CI/CD automation (GitHub Actions → Docker Hub → SSH deploy)

Each guide includes a full **Table of Contents**, numbered sections, production commands, Mac/Linux/Docker coverage, cleanup/uninstall steps, and final checklists.

---

# Quick Start

```bash
git clone https://github.com/mosabbir-maruf/devops-deployment.git
cd devops-deployment
make help      # show all targets
make info      # show detected project info
make dev       # run in dev mode (hot-reload)
make prod      # build & run in production
```

Start with [01-initial-vps-security-setup.md](./01-initial-vps-security-setup.md) on a fresh VPS, then follow the guides in order.

---

# Makefile

The Makefile auto-detects your project type (**Node.js**, **Go**, **Python**) and adapts commands.

| Command | Description |
|---------|-------------|
| `make dev` | Run in dev mode with hot-reload (file changes auto-restart) — auto-deletes container, image & build cache on stop |
| `make build` | Build Docker image |
| `make prod` | Build & run in production mode |
| `make stop` | Stop dev & prod containers |
| `make logs` | Follow production container logs |
| `make install` | Install dependencies (npm / go mod / pip) |
| `make lint` | Run linter (ESLint / golangci-lint / ruff) |
| `make test` | Run tests (npm test / go test / pytest) |
| `make shell` | Open shell in Node container |
| `make clean` | Remove dangling Docker resources |
| `make deep-clean` | Remove ALL unused Docker resources |
| `make info` | Show detected project info |

## Overridable variables

| Variable | Default | Example |
|----------|---------|---------|
| `PORT` | `3000` | `make dev PORT=5000` |
| `DEV_PORT` | `$(PORT)` | `make dev DEV_PORT=3001` |
| `PROD_PORT` | `$(PORT)` | `make prod PROD_PORT=80` |
| `IMAGE_NAME` | directory name | `make build IMAGE_NAME=myapp:v1` |

Example workflow:

```bash
make info          # see detected project type
make install       # install dependencies
make dev           # start development (cleans up on stop)
make lint && make test   # check quality
make prod          # build & run for production
make stop          # stop everything
```

---

# Documentation Structure

## VPS & Security

### [01-initial-vps-security-setup.md](./01-initial-vps-security-setup.md)

First guide — harden a fresh Ubuntu VPS before anything else.

Includes:

- separate GitHub and VPS SSH keys (Ed25519)
- first root login, Ubuntu update, reboot
- non-root admin user with sudo
- UFW firewall setup
- Fail2Ban installation
- SSH hardening (disable root, disable passwords, custom port 1182)
- Mac `~/.ssh/config` alias
- final security checklist

---

### [02-ssh-guide.md](./02-ssh-guide.md)

Complete SSH workflow and security reference.

Includes:

- SSH keys, Ed25519, SSH agent
- SSH config, permissions, SCP, SFTP
- SSH debugging and lockout recovery
- GitHub SSH authentication
- Mac and Linux workflows
- cleanup and uninstall

---

### [03-linux-basics.md](./03-linux-basics.md)

Essential Linux commands for VPS management.

Includes:

- navigation, files, permissions
- package management (`apt`)
- processes, services, logs
- networking, compression, archives
- Mac vs Linux differences
- security basics and cleanup

---

## Docker & Containers

### [04-docker.md](./04-docker.md)

Docker-first production workflow.

Includes:

- Docker install (Mac + Linux VPS)
- images, containers, volumes, networks
- Dockerfile and `.dockerignore`
- Docker Compose (dev + production)
- Docker Hub, health checks, security
- monitoring, cleanup, production checklists

---

### [05-coolify.md](./05-coolify.md)

Self-hosted PaaS alternative to manual Docker deploys.

Includes:

- Coolify installation on VPS
- GitHub integration and deployments
- domains, SSL, environment variables
- Docker integration, monitoring, backups
- Mac browser/SSH cleanup, security practices

---

## Backend & Runtime

### [06-nodejs-npm.md](./06-nodejs-npm.md)

Node.js and npm for development; Docker for production.

Includes:

- Node.js install (Mac + Linux)
- npm, pnpm, yarn
- environment variables and production builds
- PM2 (legacy — Docker preferred in production)
- Mac/Linux cleanup, cache, log removal

---

## Databases (Docker-First)

All database guides use **Docker containers** on VPS — never expose DB ports publicly.

### [07-mongodb.md](./07-mongodb.md)

MongoDB 8 in Docker.

Includes:

- Docker Compose setup and authentication
- backups, restore, indexes
- monitoring, security, UFW rules
- Mac/Linux/Docker cleanup and uninstall

---

### [08-postgresql.md](./08-postgresql.md)

PostgreSQL 17 in Docker.

Includes:

- Docker Compose setup, users, databases
- SQL basics, connection strings
- backups, restore, indexing
- monitoring, security, cleanup (Mac + Linux + Docker)

---

### [09-redis.md](./09-redis.md)

Redis 8-alpine in Docker.

Includes:

- caching, persistence, password auth
- Docker Compose setup
- memory limits, monitoring
- production practices and cleanup

---

## Deployment & Infrastructure

### [10-project-deployment.md](./10-project-deployment.md)

Primary deployment guide — Docker Compose + GitHub Actions.

Includes:

- production stack architecture
- VPS preparation and security checklist
- Docker Compose deployment (recommended)
- Docker Hub + GitHub Actions CI/CD
- Coolify (alternative)
- Nginx, Cloudflare, SSL, health checks
- rollback, monitoring, cleanup

---

### [11-nginx-reverse-proxy.md](./11-nginx-reverse-proxy.md)

Nginx as reverse proxy in Docker or on host.

Includes:

- reverse proxy for multiple apps
- HTTPS/SSL (Let's Encrypt + Cloudflare Origin)
- WebSocket support, security headers, rate limiting
- Docker Compose integration
- Mac/Linux/Docker cleanup

---

### [12-domain-dns-cloudflare.md](./12-domain-dns-cloudflare.md)

Domain, DNS, and Cloudflare for production.

Includes:

- DNS records (A, CNAME, MX)
- Cloudflare proxy, SSL Full (strict)
- Origin certificates
- WAF, CDN, troubleshooting 522/525 errors

---

## Git & CI/CD

### [13-git-github-ci-cd.md](./13-git-github-ci-cd.md)

Git, GitHub, and automated deployment pipelines.

Includes:

- Git workflows and branching
- GitHub SSH keys and secrets
- GitHub Actions → Docker Hub → SSH → `docker compose`
- verified commits, SSH signing
- rollback and production automation

---

## Monitoring & Operations

### [14-server-monitoring.md](./14-server-monitoring.md)

Monitor VPS, Docker, and application health.

Includes:

- CPU, RAM, disk, inode monitoring
- Docker stats and compose logs
- PostgreSQL, Redis, MongoDB monitoring
- Fail2Ban and auth log review
- automated `monitor.sh` cron, Uptime Kuma
- Netdata (SSH tunnel), cleanup

---

### [15-backup-snapshots.md](./15-backup-snapshots.md)

Production backup and disaster recovery.

Includes:

- 3-layer strategy (snapshot + daily dump + offsite)
- VPS provider snapshots
- PostgreSQL, MongoDB, Redis backups via Docker
- Docker volume tar backups
- `backup.sh` + cron + rclone offsite (R2/S3)
- restore testing, encryption, retention

---

### [16-troubleshooting.md](./16-troubleshooting.md)

Systematic production debugging guide.

Includes:

- standard debug workflow (logs → services → ports → DNS)
- Docker Compose, Nginx 502/504, Cloudflare errors
- database connection issues
- CI/CD deploy failures
- emergency 60-second diagnosis
- rollback and restore from backup

---

### [17-useful-commands.md](./17-useful-commands.md)

One-page production command reference.

Includes:

- SSH, Linux, UFW, Fail2Ban
- Docker and Docker Compose
- Git, Node.js/npm (dev)
- PostgreSQL, MongoDB, Redis (Docker)
- Nginx, DNS, SSL, Cloudflare
- daily VPS check, deploy, emergency fix commands
- port and file path reference tables

---

## Deployment & Infrastructure

### [18-production-reverse-proxy-shared-network.md](./18-production-reverse-proxy-shared-network.md)

Production-grade Docker-based reverse proxy architecture for hosting multiple projects on a single VPS.

Includes:

- centralized Nginx reverse proxy with shared Docker network
- multi-project architecture (gateway, API, admin)
- Let's Encrypt SSL, Cloudflare integration
- CI/CD with GitHub Actions and GHCR
- monitoring, health checks, zero-downtime deployment
- backup, disaster recovery, reverse proxy rules

---

### [19-production-deployment-runbook.md](./19-production-deployment-runbook.md)

Consolidated production deployment runbook for fresh deployment, SSL management, reverse proxy, application deployment, disaster recovery, and day-to-day operations.

Includes:

- Infrastructure foundation (Docker, networking, firewall)
- Reverse proxy stack (Nginx, Certbot, shared network)
- SSL & HTTPS lifecycle (Cloudflare, Let's Encrypt, auto-renewal)
- Application deployment, update, and rollback procedures
- Centralized production validation checklist
- Backup and restore procedures
- Disaster recovery with phase references
- Emergency and operational command reference

---

### [Infra-Bot](https://github.com/mosabbir-maruf/Infra-Bot)

Cloudflare Workers-powered infrastructure control plane with Telegram operations, AWS EC2, Azure & DigitalOcean management, telemetry monitoring, rate limiting, and secure remote administration.

---

# Recommended Learning Path

Follow this order for a complete production setup:

| # | Guide | Purpose |
|---|-------|---------|
| 01 | [initial-vps-security-setup](./01-initial-vps-security-setup.md) | Secure fresh VPS |
| 02 | [ssh-guide](./02-ssh-guide.md) | SSH mastery |
| 03 | [linux-basics](./03-linux-basics.md) | Linux fundamentals |
| 04 | [docker](./04-docker.md) | Docker foundation |
| 05 | [coolify](./05-coolify.md) | Optional PaaS |
| 06 | [nodejs-npm](./06-nodejs-npm.md) | Node.js dev setup |
| 07 | [mongodb](./07-mongodb.md) | MongoDB in Docker |
| 08 | [postgresql](./08-postgresql.md) | PostgreSQL in Docker |
| 09 | [redis](./09-redis.md) | Redis in Docker |
| 10 | [project-deployment](./10-project-deployment.md) | Deploy to production |
| 11 | [nginx-reverse-proxy](./11-nginx-reverse-proxy.md) | Reverse proxy + SSL |
| 12 | [domain-dns-cloudflare](./12-domain-dns-cloudflare.md) | Domain + CDN |
| 13 | [git-github-ci-cd](./13-git-github-ci-cd.md) | CI/CD automation |
| 14 | [server-monitoring](./14-server-monitoring.md) | Monitor everything |
| 15 | [backup-snapshots](./15-backup-snapshots.md) | Backup strategy |
| 16 | [troubleshooting](./16-troubleshooting.md) | Debug production |
| 17 | [useful-commands](./17-useful-commands.md) | Quick reference |
| 18 | [production-reverse-proxy-shared-network](./18-production-reverse-proxy-shared-network.md) | Multi-project reverse proxy |
| 19 | [production-deployment-runbook](./19-production-deployment-runbook.md) | Production deployment runbook |
| 20 | [Infra-Bot](https://github.com/mosabbir-maruf/Infra-Bot) | Cloudflare Workers infra control plane |

---

# Production Stack Overview

```txt
User
↓
Cloudflare (DNS, SSL Full strict, WAF, CDN)
↓
Nginx (reverse proxy, HTTPS)
↓
Docker Compose
├── backend (Node.js / Go / Python app)
├── postgres (PostgreSQL 17)
├── redis (Redis 8-alpine)
└── mongodb (MongoDB 8, if needed)
↓
GitHub Actions → Docker Hub → SSH → docker compose up -d
```

---

# Production Rules

✓ Good:

- SSH key authentication only (custom port)
- UFW: allow 80, 443, SSH port only
- databases on Docker internal network — never public
- HTTPS everywhere (Cloudflare Full strict)
- `.env` for secrets — never in git
- backup before every deploy
- health check endpoints monitored daily

✗ Avoid:

- exposing PostgreSQL (5432), Redis (6379), MongoDB (27017) publicly
- PM2 or git-pull deploys in production (use Docker Compose)
- password SSH login or root SSH login
- skipping backup restore tests

---

# Goals

This repository focuses on:

- secure VPS setup from day one
- Docker-first production deployments
- practical, command-heavy DevOps learning
- self-hosted infrastructure
- CI/CD automation with GitHub Actions
- real-world monitoring, backup, and troubleshooting
- Mac dev workstation + Linux VPS production workflows

---

# Author

Created and maintained by **Mosabbir Maruf**

GitHub: [https://github.com/mosabbir-maruf](https://github.com/mosabbir-maruf)

---

# License

This repository is licensed under the MIT License.
