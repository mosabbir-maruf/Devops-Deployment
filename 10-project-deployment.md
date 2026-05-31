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
