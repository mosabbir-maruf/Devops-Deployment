# Project Deployment

## Table Of Contents

### Fundamentals

1. [What Is Deployment](#what-is-deployment)
2. [Deployment Types](#deployment-types)
3. [Recommended Production Stack](#recommended-production-stack)
4. [Deployment Architectures](#deployment-architectures)
5. [Basic Deployment Workflow](#basic-deployment-workflow)

### Project Preparation

6. [Project Preparation](#project-preparation)
7. [Project Structure](#project-structure)
8. [GitHub Preparation](#github-preparation)
9. [Environment Variables](#environment-variables)
10. [Environment Variable Security](#environment-variable-security)

### VPS Preparation

11. [VPS Preparation](#vps-preparation)
12. [VPS Security Checklist](#vps-security-checklist)
13. [Firewall Configuration](#firewall-configuration)
14. [Docker Installation Verification](#docker-installation-verification)

### Deployment Methods

15. [Source Code Deployment](#source-code-deployment)
16. [Docker Deployment](#docker-deployment)
17. [Docker Compose Deployment](#docker-compose-deployment)
18. [Docker Hub Deployment](#docker-hub-deployment)
19. [Coolify Deployment](#coolify-deployment)

### Production Infrastructure

20. [Production Architecture](#production-architecture)
21. [Production Project Structure](#production-project-structure)
22. [Nginx Integration](#nginx-integration)
23. [Cloudflare Integration](#cloudflare-integration)
24. [Domain Configuration](#domain-configuration)
25. [DNS Configuration](#dns-configuration)
26. [SSL HTTPS Configuration](#ssl-https-configuration)

### Monitoring

27. [Deployment Monitoring](#deployment-monitoring)
28. [Docker Monitoring](#docker-monitoring)
29. [Server Monitoring](#server-monitoring)
30. [Log Monitoring](#log-monitoring)

### Updates

31. [Deployment Updates](#deployment-updates)
32. [Source Deployment Updates](#source-deployment-updates)
33. [Docker Deployment Updates](#docker-deployment-updates)
34. [Coolify Deployment Updates](#coolify-deployment-updates)

### Rollbacks

35. [Rollback Workflow](#rollback-workflow)
36. [Source Rollback](#source-rollback)
37. [Docker Rollback](#docker-rollback)
38. [Database Rollback](#database-rollback)

### CI/CD

39. [GitHub Actions Deployment](#github-actions-deployment)
40. [Docker Hub CI/CD Workflow](#docker-hub-cicd-workflow)
41. [Production CI/CD Workflow](#production-cicd-workflow)

### Security

42. [Deployment Security](#deployment-security)
43. [Production Security Rules](#production-security-rules)
44. [Deployment Checklist](#deployment-checklist)

### Backups

45. [Backup Strategy](#backup-strategy)
46. [Database Backups](#database-backups)
47. [Volume Backups](#volume-backups)
48. [Configuration Backups](#configuration-backups)

### Troubleshooting

49. [Common Deployment Issues](#common-deployment-issues)
50. [Deployment Debug Workflow](#deployment-debug-workflow)

### Production Workflow

51. [Recommended Production Workflow](#recommended-production-workflow)
52. [Modern Deployment Workflow](#modern-deployment-workflow)
# What Is Deployment?

Deployment is the process of making an application available to users.

A deployment typically includes:

* application code
* infrastructure
* database
* domain
* SSL
* monitoring

Goal:

```txt
Users
↓
Access Application
↓
Reliably And Securely
```

---

# Deployment Types

There are multiple deployment approaches.

---

## Traditional VPS Deployment

Application runs directly on the server.

Example:

```txt
Ubuntu VPS
↓
Node.js
↓
Application
```

Usually managed with:

```txt
PM2
Systemd
```

---

## Docker Deployment

Application runs inside containers.

Example:

```txt
Ubuntu VPS
↓
Docker
↓
Application Container
```

---

## Docker Compose Deployment

Multiple services managed together.

Example:

```txt
Frontend

Backend

Database

Redis

Nginx
```

Managed by:

```txt
docker compose
```

---

## Docker Hub Deployment

Images are built once and deployed anywhere.

Workflow:

```txt
Build Image
↓
Push Docker Hub
↓
Pull On VPS
↓
Deploy
```

---

## Coolify Deployment

Platform-as-a-Service on your VPS.

Provides:

* GitHub integration
* automatic deployments
* SSL management
* environment management

---

## Kubernetes Deployment

Used for:

```txt
Large Scale Applications

Multi Server Clusters

Advanced Orchestration
```

Not required for most personal projects.

---

# Recommended Production Stack

Recommended stack for modern projects:

```txt
Ubuntu VPS
↓
Docker
↓
Docker Compose
↓
Nginx
↓
Cloudflare
```

Application stack:

```txt
Frontend
Backend
PostgreSQL
Redis
```

---

## Recommended Tools

Infrastructure:

```txt
Ubuntu 24.04 LTS
Docker
Docker Compose
Nginx
Cloudflare
```

---

Application:

```txt
Node.js

Next.js

PostgreSQL

Redis
```

---

Version Control:

```txt
Git
GitHub
```

---

# Deployment Architectures

## Basic Single App

```txt
Users
↓
Domain
↓
Application
```

---

## Reverse Proxy Architecture

```txt
Users
↓
Nginx
↓
Application
```

---

## Modern Production Architecture

```txt
Users
↓
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
```

---

## Full Production Architecture

```txt
Users
↓
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
PostgreSQL
↓
Redis
```

---

## Recommended Architecture

For personal projects:

```txt
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

This provides:

* HTTPS
* DDoS protection
* caching
* reverse proxy
* database isolation
* production security

---

# Basic Deployment Workflow

## Source Deployment Workflow

```txt
Write Code
↓
Git Commit
↓
Git Push
↓
SSH VPS
↓
Git Pull
↓
Deploy
```

---

## Docker Deployment Workflow

```txt
Write Code
↓
Git Push
↓
SSH VPS
↓
docker compose build
↓
docker compose up -d
```

---

## Docker Hub Deployment Workflow

```txt
Write Code
↓
Build Image
↓
Push Docker Hub
↓
VPS Pull Image
↓
Deploy
```

---

## CI/CD Deployment Workflow

```txt
Git Push
↓
GitHub Actions
↓
Build Docker Image
↓
Push Registry
↓
Deploy VPS
```

---

# Production Deployment Philosophy

Production deployments should be:

```txt
Predictable

Repeatable

Automated

Secure
```

---

## Production Rule

Never:

```txt
SSH VPS
↓
Manually Edit Application Files
```

---

Always:

```txt
Change Source Code
↓
Commit
↓
Deploy New Version
```

---

# Development vs Deployment

## Development

```txt
Build Features
Fix Bugs
Test Locally
```

---

## Deployment

```txt
Build
Deploy
Monitor
Maintain
```

---

# Production Goals

Every deployment should provide:

```txt
✓ Availability

✓ Security

✓ Reliability

✓ Monitoring

✓ Backups

✓ Rollback Capability
```

---

# Deployment Overview

Recommended workflow:

```txt
Mac
↓
GitHub
↓
VPS
↓
Docker Compose
↓
Nginx
↓
Cloudflare
↓
Users
```

This will be the deployment workflow used throughout the rest of this guide.

# Project Preparation

Before deploying any application, ensure the project is production-ready.

---

## Project Readiness Checklist

Verify:

```txt id="2a4f8g"
✓ Application Working Locally

✓ No Development Errors

✓ Environment Variables Ready

✓ Database Ready

✓ Dockerfile Ready

✓ Docker Compose Ready

✓ GitHub Repository Ready

✓ Domain Ready
```

---

## Production Readiness Checklist

Verify:

```txt id="8c9v1k"
✓ Production Build Works

✓ Docker Build Works

✓ No Hardcoded Secrets

✓ HTTPS Planned

✓ Database Backups Planned

✓ Logging Configured

✓ Error Handling Configured
```

---

# Project Structure

A clean project structure simplifies deployments.

---

## Recommended Structure

```txt id="6h3w9q"
project/
├── frontend/
├── backend/
│
├── docker-compose.yml
├── .env
├── .gitignore
│
├── nginx/
│   ├── default.conf
│   └── ssl/
│
├── backups/
│
└── docs/
```

---

## Frontend Structure

Example:

```txt id="5j7n2r"
frontend/
├── src/
├── public/
├── package.json
├── Dockerfile
└── .dockerignore
```

---

## Backend Structure

Example:

```txt id="3m8k6x"
backend/
├── src/
├── package.json
├── Dockerfile
├── .dockerignore
└── uploads/
```

---

## Nginx Structure

Example:

```txt id="1w4v9p"
nginx/
├── default.conf
└── ssl/
    ├── cert.pem
    └── key.pem
```

---

# GitHub Preparation

GitHub should be the source of truth.

---

## Initialize Git

```bash id="9r5x2m"
git init
```

---

## Add Remote Repository

```bash id="7q8n4v"
git remote add origin REPOSITORY_URL
```

---

## Verify Remote

```bash id="4k6m1t"
git remote -v
```

---

# Create .gitignore

## Create File

```bash id="8v2p7n"
nano .gitignore
```

---

## Recommended .gitignore

```gitignore id="6n9w4x"
.env
.env.*

node_modules

.next

dist

coverage

Dockerfile.local

*.log

uploads

.vscode

.idea
```

---

# Git Workflow

## Check Status

```bash id="3p7v9m"
git status
```

---

## Add Files

```bash id="2x8k6n"
git add .
```

---

## Commit

```bash id="5m1v4q"
git commit -m "initial commit"
```

---

## Push

```bash id="7n3x8p"
git push origin main
```

---

# Environment Variables

Environment variables should contain all secrets and configuration.

---

## Create Environment File

```bash id="4v7m2x"
nano .env
```

---

## Example

```env id="1p8k5w"
NODE_ENV=production

PORT=3000

DATABASE_URL=postgres://user:password@postgres:5432/app

REDIS_URL=redis://redis:6379

JWT_SECRET=your-secret

API_KEY=your-api-key
```

---

## Production Rule

Store:

```txt id="9x3m7k"
Database URLs

JWT Secrets

API Keys

SMTP Credentials

OAuth Credentials

Third Party Tokens
```

inside:

```txt id="6v2n8q"
.env
```

---

# Environment Variable Security

## Never Commit

Never upload:

```txt id="5w7p2m"
.env

.env.local

.env.production
```

to GitHub.

---

## Verify Before Push

Check:

```bash id="2k8v6n"
git status
```

Ensure:

```txt id="8m4x1q"
.env
```

does not appear.

---

## Good Practice

```txt id="4n9v7k"
.env
↓
Server Only
```

---

## Bad Practice

```txt id="7p2m8x"
.env
↓
GitHub
```

---

# Environment Example Structure

## Development

```env id="3v8k5q"
NODE_ENV=development
```

---

## Production

```env id="9m2x6w"
NODE_ENV=production
```

---

## Separate Environments

```txt id="6k7v4p"
.env.local

.env.staging

.env.production
```

---

# Docker Environment Variables

## Compose Example

```yaml id="1x9m7q"
services:

  backend:

    env_file:
      - .env
```

---

## Access In Application

Node.js:

```javascript id="5p8v2m"
process.env.JWT_SECRET
```

---

# Secrets Checklist

Before deployment verify:

```txt id="8q4n7v"
✓ No Secrets In Source Code

✓ No Secrets In GitHub

✓ .env Added To .gitignore

✓ Production Secrets Configured

✓ Database Credentials Configured

✓ API Keys Configured
```

---

# Project Preparation Checklist

Before moving to VPS setup:

```txt id="2m7x5k"
✓ Project Structure Ready

✓ Git Repository Ready

✓ GitHub Repository Ready

✓ Dockerfile Ready

✓ Docker Compose Ready

✓ .gitignore Ready

✓ Environment Variables Ready

✓ Production Build Tested
```

At this point the project is ready to move to VPS preparation and deployment.

# VPS Preparation

Before deploying applications, prepare the VPS properly.

A production VPS should be:

```txt id="p2k8mx"
Secure

Updated

Monitored

Deployment Ready
```

---

# VPS Requirements

## Minimum Personal Project VPS

```txt id="v7n4qw"
1 vCPU

1 GB RAM

20 GB SSD
```

Recommended:

```txt id="x3m9kr"
2 vCPU

2 GB RAM

40+ GB SSD
```

---

## Recommended Operating System

Use:

```txt id="m5q7vx"
Ubuntu 24.04 LTS
```

Avoid old unsupported releases.

---

# Initial VPS Setup

## Connect To VPS

```bash id="n4v8kt"
ssh username@SERVER_IP
```

---

## Verify Current User

```bash id="r8m2qw"
whoami
```

---

## Verify Sudo Access

```bash id="p6v4kx"
sudo -l
```

---

# Update Server

## Update Package Index

```bash id="w2m7qr"
sudo apt update
```

---

## Upgrade Packages

```bash id="x8v4kn"
sudo apt upgrade -y
```

---

## Reboot If Required

```bash id="m4q8vx"
sudo reboot
```

---

# Server Information

## Check Memory

```bash id="r2v7kw"
free -h
```

---

## Check CPU

```bash id="y4m9qx"
nproc
```

---

## Check Disk Space

```bash id="k7v3mw"
df -h
```

---

## Check OS Version

```bash id="n5q8vx"
lsb_release -a
```

---

# Configure Swap

Recommended for:

```txt id="p3m7kr"
1 GB VPS

2 GB VPS
```

---

## Create Swap File

```bash id="x6v2qw"
sudo fallocate -l 2G /swapfile
```

---

## Secure Swap File

```bash id="r9m4vx"
sudo chmod 600 /swapfile
```

---

## Create Swap

```bash id="w7q2kr"
sudo mkswap /swapfile
```

---

## Enable Swap

```bash id="m8v5qx"
sudo swapon /swapfile
```

---

## Verify Swap

```bash id="k2q9vw"
free -h
```

---

## Persist After Reboot

```bash id="x4m7kr"
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## Verify

```bash id="v8q3mx"
swapon --show
```

---

# VPS Security Checklist

Production servers should have:

```txt id="q5m8vx"
✓ SSH Working

✓ Root Login Disabled

✓ Firewall Enabled

✓ Docker Installed

✓ Swap Configured

✓ Security Updates Installed

✓ Domain Ready
```

---

# SSH Security

## Check Current User

```bash id="p8v4qw"
id
```

---

## Check SSH Port

```bash id="r4m9kx"
sudo ss -tulpn
```

---

## Verify SSH Configuration

```bash id="x7q2mv"
sudo cat /etc/ssh/sshd_config
```

---

# Root Login

## Recommended Setting

```txt id="m2v8kr"
PermitRootLogin no
```

---

## Verify Current Setting

```bash id="n8q4vx"
sudo grep PermitRootLogin /etc/ssh/sshd_config
```

---

## Restart SSH

```bash id="p5m7qw"
sudo systemctl restart ssh
```

---

# Firewall Configuration

Use UFW.

---

## Enable Firewall

```bash id="r7v2kx"
sudo ufw enable
```

---

## Check Status

```bash id="x3m8qv"
sudo ufw status
```

---

# Allow SSH

Default:

```bash id="k6v4mr"
sudo ufw allow 22/tcp
```

---

Custom Port Example:

```bash id="m9q2vx"
sudo ufw allow 1182/tcp
```

---

# Allow HTTP

```bash id="p2v7kw"
sudo ufw allow 80/tcp
```

---

# Allow HTTPS

```bash id="r8m5qx"
sudo ufw allow 443/tcp
```

---

# Recommended UFW Rules

```txt id="x4q9kv"
SSH

80

443
```

Only.

---

## Verify Rules

```bash id="m7v3qw"
sudo ufw status
```

Example:

```txt id="k3q8mx"
1182/tcp ALLOW

80/tcp ALLOW

443/tcp ALLOW
```

---

# Docker Installation Verification

## Verify Docker

```bash id="r5v8kw"
docker --version
```

---

## Verify Compose

```bash id="p8m4qx"
docker compose version
```

---

## Verify Docker Service

```bash id="x2q7mv"
sudo systemctl status docker
```

Expected:

```txt id="m4v9kr"
active (running)
```

---

## Verify Docker Group

```bash id="r7m2qx"
groups
```

Expected:

```txt id="p3v8kw"
docker
```

---

## Verify Docker Access

```bash id="x5m4qv"
docker ps
```

Should work without:

```txt id="n8q2kr"
sudo
```

---

# Verify Open Ports

## Check Listening Ports

```bash id="r4v7mw"
sudo ss -tulpn
```

---

Recommended output:

```txt id="m7q9vx"
SSH

80

443
```

Only required services should be exposed.

---

# Docker Deployment Readiness

Before deployment verify:

```txt id="p8v4mx"
✓ Docker Running

✓ Compose Working

✓ Firewall Configured

✓ SSH Working

✓ Domain Ready

✓ Environment Variables Ready

✓ GitHub Repository Ready
```

---

# Server Monitoring Tools

## Install htop

```bash id="x3m8kr"
sudo apt install htop -y
```

---

## Monitor Resources

```bash id="n5q7vx"
htop
```

---

## Monitor Disk Usage

```bash id="p7v2qw"
df -h
```

---

## Monitor Memory

```bash id="r2m8kx"
free -h
```

---

# VPS Readiness Checklist

Before deploying applications:

```txt id="w9q4mv"
✓ Ubuntu Updated

✓ SSH Configured

✓ Root Login Disabled

✓ Firewall Enabled

✓ HTTP Allowed

✓ HTTPS Allowed

✓ Docker Installed

✓ Docker Compose Installed

✓ Swap Configured

✓ Monitoring Installed

✓ Domain Ready

✓ GitHub Ready
```

At this point the VPS is production-ready and deployment can begin.

# Source Code Deployment

Source deployment means deploying application source code directly from GitHub to a VPS.

Workflow:

```txt id="w7n2mk"
GitHub
↓
VPS
↓
Git Pull
↓
Build
↓
Deploy
```

---

## Connect To VPS

```bash id="p4v8qx"
ssh username@SERVER_IP
```

---

## Clone Repository

```bash id="x8m3kv"
git clone REPOSITORY_URL
```

---

## Enter Project

```bash id="r5q7mw"
cd project
```

---

## Verify Repository

```bash id="m9v2qx"
git status
```

---

## Configure Environment Variables

```bash id="k3m8vr"
nano .env
```

---

## Verify Files

```bash id="p8q4mx"
ls -la
```

Expected:

```txt id="v2m7kw"
docker-compose.yml

.env

frontend/

backend/
```

---

# Source Code Deployment Workflow

## Pull Latest Changes

```bash id="x7q3mv"
git pull origin main
```

---

## Build Images

```bash id="n5v8kr"
docker compose build
```

---

## Deploy Containers

```bash id="r2q7wx"
docker compose up -d
```

---

## Verify Deployment

```bash id="m7v4qx"
docker ps
```

---

## Verify Logs

```bash id="p3m9kv"
docker compose logs -f
```

---

# Docker Deployment

Docker deployment packages the application inside images.

Workflow:

```txt id="k8v2mr"
Source Code
↓
Docker Image
↓
Container
↓
Application
```

---

# Production Dockerfile Example

## Backend Dockerfile

```dockerfile id="x4q7mw"
FROM node:24-slim

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

---

## Build Image

```bash id="m2v8qx"
docker build -t backend .
```

---

## Verify Image

```bash id="r8q3mv"
docker images
```

---

## Run Image

```bash id="p7m4kw"
docker run -d \
--name backend \
-p 3000:3000 \
--env-file .env \
backend
```

---

## Verify Container

```bash id="x3v9qr"
docker ps
```

---

# Docker Compose Deployment

Production deployments should use Docker Compose.

---

## Why Docker Compose?

Benefits:

```txt id="m6q2vx"
Frontend

Backend

Database

Redis

Nginx
```

managed together.

---

# Production Compose Example

## docker-compose.yml

```yaml id="p8v5kw"
services:

  frontend:
    build: ./frontend

    restart: unless-stopped

    expose:
      - "3000"

  backend:
    build: ./backend

    restart: unless-stopped

    expose:
      - "5000"

    env_file:
      - .env

  postgres:
    image: postgres:17

    restart: unless-stopped

    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:8

    restart: unless-stopped

    volumes:
      - redis-data:/data

  nginx:
    image: nginx:alpine

    restart: unless-stopped

    depends_on:
      - frontend
      - backend

    ports:
      - "80:80"
      - "443:443"

    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro

volumes:
  postgres-data:
  redis-data:
```

---

## Start Stack

```bash id="r3m7qx"
docker compose up -d
```

---

## Stop Stack

```bash id="x7v2kw"
docker compose down
```

---

## Restart Stack

```bash id="m9q4vr"
docker compose restart
```

---

## Rebuild Stack

```bash id="p2v8mx"
docker compose up -d --build
```

---

## Verify Services

```bash id="k5m7qw"
docker compose ps
```

---

## View Logs

```bash id="r8v3qx"
docker compose logs -f
```

---

# Docker Hub Deployment

Docker Hub deployment is recommended when:

```txt id="x4m9kv"
Multiple VPS

CI/CD

Team Projects

Production Environments
```

---

# Docker Hub Workflow

```txt id="n7q2mw"
Build Image
↓
Push Docker Hub
↓
Pull On VPS
↓
Deploy
```

---

## Login

```bash id="p8v4qr"
docker login
```

---

## Build Image

```bash id="m3q7vx"
docker build -t backend:v1.0.0 .
```

---

## Tag Image

```bash id="r2v9kw"
docker tag backend:v1.0.0 username/backend:v1.0.0
```

---

## Push Image

```bash id="x5m8qr"
docker push username/backend:v1.0.0
```

---

# VPS Deployment Using Docker Hub

## Pull Image

```bash id="k8q3mv"
docker pull username/backend:v1.0.0
```

---

## Compose Example

```yaml id="m4v7qx"
services:

  backend:
    image: username/backend:v1.0.0
```

---

## Deploy

```bash id="p9q2kw"
docker compose up -d
```

---

## Update Version

Old:

```yaml id="r5v8mx"
image: username/backend:v1.0.0
```

---

New:

```yaml id="x2m7qr"
image: username/backend:v1.1.0
```

---

Deploy:

```bash id="k7v4qw"
docker compose pull

docker compose up -d
```

---

# Deployment Verification

## Verify Containers

```bash id="m8q2vx"
docker ps
```

---

## Verify Logs

```bash id="r4v9kw"
docker compose logs -f
```

---

## Verify Resources

```bash id="x8m3qr"
docker stats
```

---

## Verify Domain

```bash id="p3v7mx"
curl DOMAIN_NAME
```

---

# Deployment Checklist

Before continuing:

```txt id="k5q8vw"
✓ GitHub Repository Connected

✓ Environment Variables Added

✓ Dockerfile Working

✓ Docker Compose Working

✓ Images Built

✓ Containers Running

✓ Logs Verified

✓ Domain Ready

✓ Nginx Ready

✓ Cloudflare Ready
```

At this point the application is deployed and ready for production infrastructure configuration.

# Coolify Deployment

Coolify is a self-hosted deployment platform that runs on your own VPS.

It provides:

* GitHub integration
* automatic deployments
* SSL management
* environment management
* Docker orchestration

---

## Coolify Workflow

```txt id="j3k8wp"
GitHub
↓
Coolify
↓
Docker
↓
Application
```

---

## Recommended Use Cases

Good for:

```txt id="x7m4qv"
Personal Projects

Client Projects

SaaS Projects

Multi-App VPS
```

---

## Requirements

Before installing Coolify:

```txt id="m2v8kr"
Ubuntu VPS

Docker Installed

Domain Ready

Firewall Configured
```

---

## Install Coolify

Official installer:

```bash id="p8q3mv"
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

---

## Access Coolify

```txt id="k4v9qx"
http://SERVER_IP:8000
```

After setup:

```txt id="r7m2kw"
https://coolify.domain.com
```

---

# Connect GitHub Repository

## Create Resource

Inside Coolify:

```txt id="x3q8mv"
New Resource
↓
Application
```

---

## Connect GitHub

```txt id="m9v4kw"
GitHub
↓
Repository
↓
Branch
```

---

## Configure Build Settings

Verify:

```txt id="k2q7vx"
Dockerfile

Port

Environment Variables
```

---

## Deploy

```txt id="p5v8mr"
Deploy
```

Coolify automatically:

```txt id="r8q4kw"
Builds Image

Creates Container

Starts Application
```

---

# Environment Variables

Inside Coolify:

```txt id="x7m3qv"
Settings
↓
Environment Variables
```

---

## Example

```env id="m4v8kw"
NODE_ENV=production

DATABASE_URL=...

JWT_SECRET=...
```

---

## Production Rule

Never commit:

```txt id="k8q2mx"
.env
```

to GitHub.

---

# Production Architecture

Recommended architecture:

```txt id="v3m7qw"
Users
↓
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
PostgreSQL
↓
Redis
```

---

## Public Layer

Accessible from the internet:

```txt id="p9q4kv"
Cloudflare

Nginx

Frontend
```

---

## Private Layer

Internal only:

```txt id="r5v8mx"
Backend

PostgreSQL

Redis
```

---

# Production Project Structure

## Recommended Structure

```txt id="x2m7qw"
project/
│
├── frontend/
│
├── backend/
│
├── docker-compose.yml
│
├── .env
│
├── nginx/
│   ├── default.conf
│   └── ssl/
│       ├── cert.pem
│       └── key.pem
│
├── backups/
│
└── docs/
```

---

## Frontend

```txt id="m7q3vx"
frontend/
├── src/
├── public/
├── package.json
├── Dockerfile
└── .dockerignore
```

---

## Backend

```txt id="p4v9kw"
backend/
├── src/
├── package.json
├── Dockerfile
├── .dockerignore
└── uploads/
```

---

# Nginx Integration

Nginx should be the only public entry point.

---

## Traffic Flow

```txt id="r8m2qx"
Users
↓
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
```

---

## Benefits

```txt id="k5v7mw"
HTTPS

Reverse Proxy

Routing

Security Headers

Cloudflare Integration
```

---

## Recommended Nginx Structure

```txt id="x8q4mv"
nginx/
├── default.conf
└── ssl/
    ├── cert.pem
    └── key.pem
```

---

## Nginx Docker Mounts

```yaml id="m2v8kr"
volumes:
  - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
  - ./nginx/ssl:/etc/nginx/ssl:ro
```

---

## Production Rule

Expose:

```txt id="p7q3vx"
80

443
```

Only.

---

Keep private:

```txt id="r4v8kw"
3000

5000

5432

6379
```

---

# Cloudflare Integration

Cloudflare should sit in front of Nginx.

---

## Traffic Flow

```txt id="x9m2qr"
Users
↓
Cloudflare
↓
Nginx
↓
Application
```

---

## Benefits

```txt id="k3v7mw"
HTTPS

DDoS Protection

Caching

WAF

Bot Protection

Origin IP Protection
```

---

# DNS Configuration

## Root Domain

```txt id="m8q4vx"
Type: A

Name: @

Value: SERVER_IP
```

---

## API Subdomain

```txt id="p2v9kw"
Type: A

Name: api

Value: SERVER_IP
```

---

## Enable Proxy

Recommended:

```txt id="r7q3mx"
Orange Cloud
```

Enabled.

---

# SSL Configuration

## Cloudflare SSL Mode

Recommended:

```txt id="x4v8kr"
Full (Strict)
```

---

Avoid:

```txt id="m9q2vw"
Flexible
```

---

# Production Infrastructure Checklist

Verify:

```txt id="k6v4qx"
✓ Cloudflare Configured

✓ DNS Configured

✓ Nginx Configured

✓ HTTPS Enabled

✓ Docker Running

✓ Containers Running

✓ Environment Variables Added

✓ Database Private

✓ Redis Private
```

---

# Production Rules

Always:

```txt id="p3q8mv"
✓ Use Docker Compose

✓ Use Nginx

✓ Use Cloudflare

✓ Use HTTPS

✓ Keep Databases Private

✓ Use Environment Variables

✓ Use Backups

✓ Monitor Logs
```

---

Avoid:

```txt id="r8v2kw"
✗ Public PostgreSQL

✗ Public Redis

✗ Secrets In GitHub

✗ Open Unnecessary Ports

✗ Disable HTTPS

✗ Expose Internal Services
```

---

# Infrastructure Overview

Recommended deployment architecture:

```txt id="x5m7qr"
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
PostgreSQL
↓
Redis
```

This architecture will be used throughout the remainder of this deployment guide.
# Domain Configuration

A domain allows users to access your application using a human-readable address.

Example:

```txt id="v7m4qx"
animewarp.app
```

instead of:

```txt id="k2q8mv"
104.21.x.x
```

---

# Domain Requirements

Before configuring a domain:

```txt id="r5v9kw"
✓ VPS Running

✓ Application Running

✓ Public IP Available

✓ Cloudflare Account Ready
```

---

# Domain Strategy

## Root Domain

Example:

```txt id="x8m3qr"
animewarp.app
```

Usually points to:

```txt id="m4q7vx"
Frontend
```

---

## API Subdomain

Example:

```txt id="p9v2kw"
api.animewarp.app
```

Usually points to:

```txt id="r3q8mx"
Backend API
```

---

## Admin Subdomain

Example:

```txt id="x7v4kr"
admin.animewarp.app
```

Usually points to:

```txt id="m2q9vw"
Admin Panel
```

---

# DNS Configuration

DNS connects domain names to servers.

---

## Root Domain Record

Example:

```txt id="k5v8qx"
Type: A

Name: @

Value: SERVER_IP
```

---

## API Record

Example:

```txt id="r8q3mv"
Type: A

Name: api

Value: SERVER_IP
```

---

## Admin Record

Example:

```txt id="x3m7qw"
Type: A

Name: admin

Value: SERVER_IP
```

---

# Cloudflare DNS

Recommended provider:

```txt id="m7v2kx"
Cloudflare
```

---

## Enable Proxy

Enable:

```txt id="p4q9vw"
Orange Cloud
```

---

Benefits:

```txt id="r7v3mx"
DDoS Protection

Caching

WAF

Hide Origin IP
```

---

## Verify DNS

Check:

```bash id="x9m4kr"
nslookup DOMAIN_NAME
```

Example:

```bash id="k3q8vx"
nslookup animewarp.app
```

---

## Verify Public Resolution

```bash id="m8v2qw"
dig animewarp.app
```

---

# SSL HTTPS Configuration

All production applications should use HTTPS.

---

# SSL Options

## Cloudflare SSL

Recommended:

```txt id="r4q7mx"
Cloudflare
+
Nginx
```

---

## Let's Encrypt SSL

Alternative:

```txt id="x8v3kw"
Nginx
+
Certbot
```

---

## Coolify SSL

Alternative:

```txt id="m5q9vx"
Coolify Automatic SSL
```

---

# Recommended SSL Mode

Inside Cloudflare:

```txt id="p8v4kr"
SSL/TLS
↓
Full (Strict)
```

---

Avoid:

```txt id="r2q7vw"
Flexible
```

---

# SSL Verification

## Verify HTTPS

```bash id="x6m8qx"
curl -I https://DOMAIN_NAME
```

---

Example:

```bash id="k9v3mw"
curl -I https://animewarp.app
```

---

Expected:

```txt id="m3q7vx"
HTTP/2 200
```

or

```txt id="p7v2kw"
HTTP/2 301
```

---

# Nginx HTTPS Flow

```txt id="r8m4qx"
Users
↓
Cloudflare
↓
HTTPS
↓
Nginx
↓
Application
```

---

# Deployment Monitoring

Monitoring should begin immediately after deployment.

---

## Monitoring Goals

Verify:

```txt id="x5q8vw"
Application Healthy

Containers Running

Resources Available

Domain Working

HTTPS Working
```

---

# Docker Monitoring

## Running Containers

```bash id="m2v7kr"
docker ps
```

---

## Container Resource Usage

```bash id="p9q3mx"
docker stats
```

---

## Compose Status

```bash id="r4v8kw"
docker compose ps
```

---

## Compose Logs

```bash id="x7m2qw"
docker compose logs -f
```

---

## Specific Service Logs

```bash id="k5q9vx"
docker compose logs -f backend
```

---

# Server Monitoring

## CPU And Memory

```bash id="m8v4kr"
htop
```

---

## Disk Usage

```bash id="p3q7mx"
df -h
```

---

## Memory Usage

```bash id="r9v2kw"
free -h
```

---

## Open Ports

```bash id="x4m8qx"
sudo ss -tulpn
```

---

# Log Monitoring

Logs are the first place to check when troubleshooting.

---

## Container Logs

```bash id="k8q4vw"
docker logs CONTAINER_ID
```

---

## Live Logs

```bash id="m5v7kr"
docker logs -f CONTAINER_ID
```

---

## Compose Logs

```bash id="p8q2mx"
docker compose logs -f
```

---

## Last 100 Lines

```bash id="r3v9kw"
docker compose logs --tail=100
```

---

# Health Verification

## Verify Frontend

```bash id="x7q4mv"
curl DOMAIN_NAME
```

---

## Verify API

```bash id="k2v8qw"
curl https://api.DOMAIN_NAME
```

---

## Verify Containers

```bash id="m9q3kr"
docker ps
```

---

## Verify HTTPS

```bash id="p4v7mx"
curl -I https://DOMAIN_NAME
```

---

# Monitoring Checklist

Verify:

```txt id="r8q2vw"
✓ Frontend Reachable

✓ Backend Reachable

✓ HTTPS Working

✓ Containers Running

✓ Domain Resolving

✓ DNS Working

✓ Resources Available

✓ Logs Accessible
```

---

# Production Monitoring Rules

Always monitor:

```txt id="x5m9kr"
CPU

RAM

Disk

Container Health

Application Logs

SSL Status
```

---

Never ignore:

```txt id="k3q7vx"
Restart Loops

High Memory Usage

Disk Full Warnings

SSL Errors

Database Errors
```

---

# Domain And SSL Checklist

Before continuing:

```txt id="m7v4qw"
✓ Domain Added

✓ DNS Configured

✓ Cloudflare Proxy Enabled

✓ SSL Configured

✓ Full (Strict) Enabled

✓ HTTPS Working

✓ Frontend Reachable

✓ API Reachable
```

At this point the application is publicly accessible and production monitoring is in place.

# Deployment Updates

Applications require regular updates.

Updates may include:

* new features
* bug fixes
* security fixes
* dependency updates
* infrastructure updates

---

# Production Update Principles

Updates should be:

```txt id="p7v4mx"
Predictable

Repeatable

Fast

Rollback Safe
```

---

## Production Rule

Never:

```txt id="x4m8qw"
SSH VPS
↓
Edit Files Directly
↓
Save
```

---

Always:

```txt id="m8q2vx"
Change Source Code
↓
Commit
↓
Push
↓
Deploy New Version
```

---

# Source Deployment Updates

Used when deploying directly from GitHub source code.

---

## Connect To VPS

```bash id="r3v7kw"
ssh username@SERVER_IP
```

---

## Enter Project

```bash id="p8q2mx"
cd project
```

---

## Pull Latest Changes

```bash id="k5v8qw"
git pull origin main
```

---

## Rebuild Containers

```bash id="m2v7kr"
docker compose build
```

---

## Deploy

```bash id="x7q4mv"
docker compose up -d
```

---

## Verify

```bash id="r9v3kw"
docker ps
```

---

## Verify Logs

```bash id="p4q8mx"
docker compose logs -f
```

---

# Source Deployment Workflow

```txt id="m7v2qx"
Code Change
↓
Git Commit
↓
Git Push
↓
SSH VPS
↓
Git Pull
↓
Build
↓
Deploy
```

---

# Docker Deployment Updates

Used when deploying local Docker builds.

---

## Rebuild Image

```bash id="k8q4vw"
docker compose build
```

---

## Deploy Updated Containers

```bash id="x5m9kr"
docker compose up -d
```

---

## Force Recreate

```bash id="p3v7mx"
docker compose up -d --force-recreate
```

---

## Verify Running Containers

```bash id="r7q2vw"
docker ps
```

---

# Docker Hub Deployment Updates

Recommended production workflow.

---

## Update Image Version

Old:

```yaml id="m4v8qx"
image: username/backend:v1.0.0
```

---

New:

```yaml id="p8q3mw"
image: username/backend:v1.1.0
```

---

## Pull New Images

```bash id="x2m7kv"
docker compose pull
```

---

## Deploy

```bash id="r5v9qw"
docker compose up -d
```

---

## Verify

```bash id="k7q4mx"
docker ps
```

---

# Docker Hub Update Workflow

```txt id="m9v2kw"
Code Change
↓
Build Image
↓
Push Docker Hub
↓
VPS Pull
↓
Deploy
```

---

# Coolify Deployment Updates

Coolify automates deployments.

---

## Automatic Deployment

Workflow:

```txt id="p5v8qx"
Git Push
↓
Coolify Detects Change
↓
Build
↓
Deploy
```

---

## Manual Deployment

Inside Coolify:

```txt id="r8q2mv"
Application
↓
Deploy
```

---

## Verify Deployment

Inside Coolify:

```txt id="x4m7kw"
Logs

Deployments

Containers
```

---

# Rollback Workflow

Every production deployment should have a rollback strategy.

---

## Why Rollback?

Possible issues:

```txt id="m2q9vx"
Application Errors

Broken Features

Bad Releases

Database Issues
```

---

## Rollback Goal

```txt id="p7v3kw"
Restore Stable Version
↓
Quickly
```

---

# Source Rollback

## View Commit History

```bash id="r4q8mx"
git log --oneline
```

---

## Checkout Previous Commit

```bash id="x8m3qw"
git checkout COMMIT_ID
```

---

## Rebuild

```bash id="k5v7mx"
docker compose build
```

---

## Redeploy

```bash id="m8q2vw"
docker compose up -d
```

---

# Git Rollback Workflow

```txt id="p2v9kr"
Current Commit
↓
Issue Found
↓
Previous Commit
↓
Build
↓
Deploy
```

---

# Docker Rollback

Recommended for production.

---

## Previous Version

Current:

```txt id="r7q4mx"
backend:v1.1.0
```

---

Rollback:

```txt id="x3m8qw"
backend:v1.0.0
```

---

## Update Compose

```yaml id="k8v2mw"
image: username/backend:v1.0.0
```

---

## Pull Previous Version

```bash id="m5q7vx"
docker compose pull
```

---

## Deploy

```bash id="p9v3kr"
docker compose up -d
```

---

# Docker Rollback Workflow

```txt id="r2q8mw"
Current Version
↓
Issue Found
↓
Previous Image Tag
↓
Deploy
```

---

# Database Rollback

Database rollbacks require backups.

---

## Production Rule

Never deploy without:

```txt id="x7m4kr"
Database Backup
```

---

# Backup Before Migration

Example:

```txt id="m3q8vw"
Backup
↓
Migration
↓
Deploy
```

---

# Restore Workflow

```txt id="p6v2qx"
Backup
↓
Restore
↓
Verify
```

---

# Safe Deployment Strategy

Recommended workflow:

```txt id="r8v5kw"
Backup
↓
Deploy
↓
Verify
↓
Monitor
```

---

# Deployment Verification

After every update verify:

---

## Containers

```bash id="x4q9mv"
docker ps
```

---

## Logs

```bash id="k7v3qw"
docker compose logs -f
```

---

## Resource Usage

```bash id="m2q8vx"
docker stats
```

---

## Frontend

```bash id="p8v4kr"
curl DOMAIN_NAME
```

---

## API

```bash id="r5q7mx"
curl https://api.DOMAIN_NAME
```

---

## HTTPS

```bash id="x8m2qw"
curl -I https://DOMAIN_NAME
```

---

# Update Checklist

Before deploying:

```txt id="m4v9kw"
✓ Code Tested

✓ Git Commit Created

✓ Backup Available

✓ Environment Variables Verified

✓ Docker Compose Valid
```

---

After deploying:

```txt id="p7q2vx"
✓ Containers Running

✓ Logs Clean

✓ Domain Working

✓ HTTPS Working

✓ Database Working

✓ No Restart Loops
```

---

# Rollback Checklist

Verify:

```txt id="r3v8kw"
✓ Previous Version Available

✓ Database Backup Available

✓ Rollback Procedure Tested

✓ Monitoring Available

✓ Logs Accessible
```

---

# Production Update Strategy

Recommended workflow:

```txt id="x5m7qr"
Backup
↓
Deploy
↓
Verify
↓
Monitor
↓
Keep Running
```

If issues occur:

```txt id="m9q3vx"
Rollback
↓
Investigate
↓
Fix
↓
Redeploy
```

A deployment is only successful after verification and monitoring, not immediately after running the deploy command.

# GitHub Actions Deployment

GitHub Actions enables automatic deployments.

Workflow:

```txt id="r7m3qx"
Git Push
↓
GitHub Actions
↓
Build
↓
Deploy
```

---

# Benefits

```txt id="p4v8kw"
Automation

Consistency

Faster Deployments

Reduced Human Error

Versioned Workflows
```

---

# GitHub Actions Requirements

Before using CI/CD:

```txt id="x8q2mv"
GitHub Repository

VPS

SSH Access

Docker Installed

Docker Compose Installed
```

---

# GitHub Secrets

Store sensitive values inside GitHub Secrets.

---

## Required Secrets

```txt id="m5v7kr"
SERVER_IP

SERVER_USER

SERVER_SSH_KEY
```

---

## Add Secrets

GitHub:

```txt id="k3q9vx"
Repository
↓
Settings
↓
Secrets And Variables
↓
Actions
```

---

# Basic GitHub Actions Workflow

## Create Workflow Directory

```bash id="p8v4mx"
mkdir -p .github/workflows
```

---

## Create Deploy Workflow

```bash id="r2q8kw"
nano .github/workflows/deploy.yml
```

---

## Example Workflow

```yaml id="x5m7vr"
name: Deploy

on:
  push:
    branches:
      - main

jobs:

  deploy:

    runs-on: ubuntu-latest

    steps:

      - name: Deploy To VPS
        uses: appleboy/ssh-action@v1

        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}

          script: |
            cd project
            git pull origin main
            docker compose build
            docker compose up -d
```

---

# Workflow Verification

After pushing:

```txt id="m9q2kw"
GitHub
↓
Actions
↓
Deploy Workflow
```

---

Expected:

```txt id="r4v8mx"
Green Checkmark
```

---

# Docker Hub CI/CD Workflow

Recommended for production deployments.

---

# Workflow

```txt id="x7m3qw"
Git Push
↓
GitHub Actions
↓
Build Image
↓
Push Docker Hub
↓
VPS Pull Image
↓
Deploy
```

---

# Benefits

```txt id="k6q8vx"
Smaller VPS

Faster Deployments

Versioned Releases

Easier Rollbacks
```

---

# Docker Hub Secrets

Add:

```txt id="m2v9kr"
DOCKER_USERNAME

DOCKER_PASSWORD
```

or:

```txt id="p5q7mx"
DOCKER_TOKEN
```

---

# Build And Push Example

```yaml id="r8v3kw"
- name: Login Docker Hub

  uses: docker/login-action@v3

  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

- name: Build And Push

  uses: docker/build-push-action@v6

  with:
    push: true
    tags: username/backend:v1.0.0
```

---

# VPS Deployment

Pull:

```bash id="x3m8qw"
docker compose pull
```

---

Deploy:

```bash id="k7q4mv"
docker compose up -d
```

---

# Production CI/CD Workflow

Recommended workflow:

```txt id="m4v8kr"
Code Change
↓
Git Commit
↓
Git Push
↓
GitHub Actions
↓
Build Docker Image
↓
Push Docker Hub
↓
VPS Pull
↓
Deploy
```

---

# Modern Production Workflow

```txt id="p8q2vw"
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
VPS
↓
Docker Compose
↓
Nginx
↓
Cloudflare
↓
Users
```

---

# Deployment Security

Deployment security is critical.

---

# Environment Security

Always:

```txt id="r5v7mx"
Use Environment Variables

Use GitHub Secrets

Keep Secrets Off GitHub
```

---

Never:

```txt id="x8m4qw"
Commit .env

Hardcode API Keys

Store Secrets In Source Code
```

---

# SSH Security

Always:

```txt id="m3q9vx"
Use SSH Keys

Use Non-Root Users

Use Firewall Rules
```

---

Avoid:

```txt id="p6v2kw"
Password Authentication

Root SSH Access
```

---

# VPS Security

Verify:

```txt id="r9q4mx"
Firewall Enabled

SSH Secured

Docker Updated

System Updated
```

---

# Docker Security

Always:

```txt id="x4m8kr"
Use Official Images

Use Explicit Versions

Use Private Networks

Use Read-Only Mounts
```

---

Avoid:

```txt id="k8q3vw"
latest Everywhere

Public Databases

Public Redis
```

---

# Database Security

Keep private:

```txt id="m5v7qx"
PostgreSQL

MongoDB

Redis
```

---

Expose only:

```txt id="p2q9kr"
80

443
```

---

# Cloudflare Security

Recommended:

```txt id="r7v4mx"
Proxy Enabled

WAF Enabled

DDoS Protection Enabled
```

---

# Production Security Rules

Always:

```txt id="x9m2qw"
✓ Use HTTPS

✓ Use Cloudflare

✓ Use Nginx

✓ Use Docker Compose

✓ Use Environment Variables

✓ Use GitHub Secrets

✓ Use Backups

✓ Monitor Logs

✓ Keep Dependencies Updated
```

---

Avoid:

```txt id="k4q8vx"
✗ Commit .env

✗ Expose Databases

✗ Disable Firewall

✗ Use Root Containers

✗ Open Unnecessary Ports

✗ Disable HTTPS
```

---

# Deployment Checklist

Before Deployment:

```txt id="m8v3kw"
✓ VPS Ready

✓ Docker Ready

✓ Compose Ready

✓ Domain Ready

✓ Cloudflare Ready

✓ Environment Variables Ready

✓ Repository Ready
```

---

During Deployment:

```txt id="p4q7mx"
✓ Build Successful

✓ Containers Started

✓ Logs Verified

✓ HTTPS Verified
```

---

After Deployment:

```txt id="r8v2kw"
✓ Domain Reachable

✓ API Reachable

✓ SSL Working

✓ Monitoring Active

✓ Backups Ready

✓ No Restart Loops
```

---

# CI/CD Readiness Checklist

Verify:

```txt id="x5m9qr"
✓ GitHub Actions Configured

✓ GitHub Secrets Added

✓ Docker Hub Ready

✓ VPS Access Ready

✓ Rollback Strategy Ready
```

A deployment pipeline is considered production-ready only when security, monitoring, backups, and rollback procedures are in place.
# Backup Strategy

Backups are mandatory in production.

Never deploy critical applications without backups.

---

# Why Backups Matter

Backups protect against:

```txt id="m7q2vx"
Server Failure

Accidental Deletion

Database Corruption

Bad Deployments

Security Incidents
```

---

# Production Backup Rule

Always backup before:

```txt id="p4v8kw"
Major Deployments

Database Migrations

Infrastructure Changes

Server Maintenance
```

---

# Backup Priority

Highest priority:

```txt id="x8q3mv"
Database

Environment Variables

Docker Volumes

SSL Certificates

Nginx Configuration
```

---

# Database Backups

Databases are usually the most important data.

---

## PostgreSQL Backup

```bash id="m5v7kr"
docker exec postgres \
pg_dump -U postgres DATABASE_NAME \
> backup.sql
```

---

## PostgreSQL Restore

```bash id="k3q8vx"
cat backup.sql | docker exec -i postgres \
psql -U postgres DATABASE_NAME
```

---

## MongoDB Backup

```bash id="p8v4mx"
docker exec mongodb \
mongodump --out /backup
```

---

## MongoDB Restore

```bash id="r2q7kw"
docker exec mongodb \
mongorestore /backup
```

---

# Database Backup Workflow

```txt id="x5m9vr"
Database
↓
Backup
↓
Store Safely
↓
Verify
```

---

# Volume Backups

Docker volumes often contain:

```txt id="m4v8kr"
Uploads

Database Files

Application Data

Persistent Storage
```

---

## List Volumes

```bash id="p8q2vw"
docker volume ls
```

---

## Inspect Volume

```bash id="r5v7mx"
docker volume inspect VOLUME_NAME
```

---

## Backup Volume

```bash id="x8m4qw"
docker run --rm \
-v VOLUME_NAME:/source \
-v $(pwd):/backup \
ubuntu \
tar czf /backup/volume-backup.tar.gz /source
```

---

## Restore Volume

```bash id="k4q8vx"
docker run --rm \
-v VOLUME_NAME:/target \
-v $(pwd):/backup \
ubuntu \
bash -c "cd /target && tar xzf /backup/volume-backup.tar.gz --strip 1"
```

---

# Configuration Backups

Always backup:

```txt id="m8v3kw"
docker-compose.yml

.env

Nginx Configs

SSL Certificates
```

---

# Backup Environment Variables

```bash id="p4q7mx"
cp .env .env.backup
```

---

# Backup Docker Compose

```bash id="r8v2kw"
cp docker-compose.yml docker-compose.yml.backup
```

---

# Backup Nginx

```bash id="x5m9qr"
cp -r nginx nginx-backup
```

---

# Backup SSL Certificates

```bash id="k8q4vx"
cp -r nginx/ssl ssl-backup
```

---

# VPS Snapshot Backups

Recommended for production.

---

## Example Workflow

```txt id="m2v8kw"
VPS
↓
Snapshot
↓
Store
↓
Restore If Needed
```

---

## Recommended Providers

```txt id="p7q3mx"
DigitalOcean

Hetzner

Azure

AWS

Google Cloud
```

---

# Backup Schedule

Recommended:

```txt id="r4v8kw"
Daily Database Backups

Weekly Volume Backups

Weekly VPS Snapshots

Before Every Major Deployment
```

---

# Common Deployment Issues

---

## Port Already In Use

Check:

```bash id="x7m2qw"
sudo ss -tulpn
```

---

Fix:

```txt id="k5q9vx"
Stop Conflicting Service

Or

Change Port
```

---

## Container Not Starting

Check:

```bash id="m8v4kr"
docker logs CONTAINER_ID
```

---

## Container Restart Loop

Check:

```bash id="p3q7mx"
docker ps
```

Look for:

```txt id="r9v2kw"
Restarting
```

---

Then:

```bash id="x4m8qx"
docker logs CONTAINER_ID
```

---

## Cannot Connect To Docker

Check:

```bash id="k8q4vw"
docker ps
```

---

Linux:

```bash id="m5v7kr"
sudo systemctl status docker
```

---

## Permission Denied

Fix:

```bash id="p8q2mx"
sudo usermod -aG docker $USER
```

---

Apply:

```bash id="r3v9kw"
newgrp docker
```

---

## Domain Not Working

Verify:

```txt id="x5m9kr"
DNS Records

Cloudflare

Server IP
```

---

Check:

```bash id="k3q7vx"
nslookup DOMAIN_NAME
```

---

## SSL Not Working

Verify:

```txt id="m7v4qw"
Cloudflare SSL Mode

Nginx SSL

Certificate Paths
```

---

## 522 Cloudflare Error

Usually means:

```txt id="p2q8mx"
Server Unreachable

Port Blocked

Firewall Blocking

Nginx Not Running
```

---

Verify:

```bash id="r8v3kw"
sudo ufw status

docker ps

curl localhost
```

---

## 502 Bad Gateway

Usually means:

```txt id="x4q9mv"
Backend Down

Wrong Proxy Port

Backend Crash
```

---

Verify:

```bash id="k7v3qw"
docker logs backend
```

---

## High Memory Usage

Check:

```bash id="m2q8vx"
free -h
```

---

For low RAM VPS:

```txt id="p8v4kr"
Configure Swap

Monitor Containers

Limit Resources
```

---

# Deployment Debug Workflow

When something breaks:

```txt id="r5q7mx"
Check Domain
↓
Check DNS
↓
Check Cloudflare
↓
Check Nginx
↓
Check Containers
↓
Check Logs
↓
Check Resources
```

---

## Debug Checklist

```txt id="x8m2qw"
docker ps

docker compose logs -f

docker stats

free -h

df -h

sudo ss -tulpn
```

---

# Recommended Production Workflow

## Source Deployment Workflow

```txt id="m4v9kw"
Code
↓
GitHub
↓
SSH VPS
↓
Git Pull
↓
Docker Compose Build
↓
Deploy
```

---

## Docker Hub Workflow

Recommended:

```txt id="p7q2vx"
Code
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
VPS Pull
↓
Deploy
```

---

# Modern Deployment Workflow

Recommended architecture:

```txt id="r3v8kw"
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
VPS
↓
Docker Compose
↓
Nginx
↓
Cloudflare
↓
Users
```

---

# Final Production Checklist

Before going live verify:

```txt id="x5m7qr"
✓ VPS Secured

✓ Firewall Enabled

✓ Docker Installed

✓ Docker Compose Installed

✓ Domain Configured

✓ Cloudflare Configured

✓ HTTPS Enabled

✓ Nginx Configured

✓ Environment Variables Added

✓ Database Private

✓ Redis Private

✓ Backups Configured

✓ Monitoring Configured

✓ Rollback Strategy Ready

✓ CI/CD Ready
```

---

# Production Rules

Always:

```txt id="m9q3vx"
✓ Use Docker Compose

✓ Use Nginx

✓ Use Cloudflare

✓ Use HTTPS

✓ Use Environment Variables

✓ Use Backups

✓ Monitor Logs

✓ Keep Images Updated

✓ Use Explicit Image Versions
```

---

Avoid:

```txt id="p6v2kw"
✗ Commit .env

✗ Public Databases

✗ Public Redis

✗ Edit Production Containers

✗ Disable HTTPS

✗ Open Unnecessary Ports

✗ Deploy Without Backups
```

---

# Final Architecture

```txt id="r9v4mx"
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
VPS
↓
Docker Compose
↓
Nginx
↓
Cloudflare
↓
Users
```

This is the recommended modern production deployment workflow for personal projects, SaaS applications, client projects, and scalable web applications.
