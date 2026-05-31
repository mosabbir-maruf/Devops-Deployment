# Linux Basics

## Table Of Contents

### Fundamentals

1. [What Is Linux](#1-what-is-linux)
2. [Linux In Production](#2-linux-in-production)
3. [Production Architecture](#3-production-architecture)
4. [Production Folder Structure](#4-production-folder-structure)
5. [Linux vs Mac vs Docker Context](#5-linux-vs-mac-vs-docker-context)

### Installation

6. [Initial Linux VPS Setup](#6-initial-linux-vps-setup)
7. [Essential Tools On Mac](#7-essential-tools-on-mac)
8. [Linux Inside Docker Containers](#8-linux-inside-docker-containers)
9. [Verify Linux Environment](#9-verify-linux-environment)

### Configuration

10. [User And Group Management](#10-user-and-group-management)
11. [File Permissions](#11-file-permissions)
12. [Environment Variables](#12-environment-variables)
13. [Shell And Bash Basics](#13-shell-and-bash-basics)
14. [Timezone And Locale](#14-timezone-and-locale)
15. [Swap And System Limits](#15-swap-and-system-limits)

### File System Operations

16. [Navigation And Directory Structure](#16-navigation-and-directory-structure)
17. [Create Copy Move Remove](#17-create-copy-move-remove)
18. [View And Edit Files](#18-view-and-edit-files)
19. [Search And Find](#19-search-and-find)
20. [Archives And Compression](#20-archives-and-compression)
21. [Download Files](#21-download-files)

### Package Management

22. [APT Package Management (Linux)](#22-apt-package-management-linux)
23. [Homebrew On Mac](#23-homebrew-on-mac)
24. [Package Management In Docker](#24-package-management-in-docker)

### Service Management

25. [systemd Service Management](#25-systemd-service-management)
26. [Common Production Services](#26-common-production-services)

### Network

27. [Network Commands](#27-network-commands)
28. [Firewall (UFW)](#28-firewall-ufw)
29. [DNS And Connectivity](#29-dns-and-connectivity)

### Development Workflow

30. [Local Dev With Mac Terminal](#30-local-dev-with-mac-terminal)
31. [Working Inside Docker Containers](#31-working-inside-docker-containers)
32. [Development Best Practices](#32-development-best-practices)

### Production Workflow

33. [VPS Initial Setup Workflow](#33-vps-initial-setup-workflow)
34. [Production Server Maintenance](#34-production-server-maintenance)
35. [Docker Host Management](#35-docker-host-management)
36. [CI/CD Server Preparation](#36-cicd-server-preparation)
37. [Rollback And Safe Updates](#37-rollback-and-safe-updates)
38. [Production Linux Checklist](#38-production-linux-checklist)

### Security Best Practices

39. [Linux Security Rules](#39-linux-security-rules)
40. [User And Sudo Security](#40-user-and-sudo-security)
41. [Firewall And Fail2Ban](#41-firewall-and-fail2ban)
42. [Security Checklist](#42-security-checklist)

### Monitoring And Logging

43. [System Logs](#43-system-logs)
44. [Service Logs](#44-service-logs)
45. [Resource Monitoring](#45-resource-monitoring)
46. [Process Management](#46-process-management)
47. [Health Checks](#47-health-checks)
48. [Debugging](#48-debugging)

### Backup And Restore

49. [Backup Strategy](#49-backup-strategy)
50. [Backup Commands](#50-backup-commands)
51. [Restore Workflow](#51-restore-workflow)
52. [Recovery Workflow](#52-recovery-workflow)

### Troubleshooting

53. [Permission Denied](#53-permission-denied)
54. [Disk Full](#54-disk-full)
55. [Service Failed To Start](#55-service-failed-to-start)
56. [Port Already In Use](#56-port-already-in-use)
57. [Package Install Failures](#57-package-install-failures)
58. [Container Host Issues](#58-container-host-issues)
59. [Network Connectivity Issues](#59-network-connectivity-issues)

### Cleanup And Uninstall

60. [Package Removal On Linux](#60-package-removal-on-linux)
61. [System Cleanup On Linux](#61-system-cleanup-on-linux)
62. [Docker Container Cleanup](#62-docker-container-cleanup)
63. [Cache And Leftover Files](#63-cache-and-leftover-files)
64. [Verification After Cleanup](#64-verification-after-cleanup)

### Production Workflows

65. [Recommended Production Workflow](#65-recommended-production-workflow)
66. [Modern Workflow](#66-modern-workflow)
67. [Real-World Workflow](#67-real-world-workflow)
68. [Final Production Checklist](#68-final-production-checklist)

---

# 1. What Is Linux

Linux is the operating system that runs most production servers, cloud infrastructure, and Docker containers.

Production use cases:

* VPS servers (Ubuntu, Debian)
* Docker hosts
* container base images
* CI/CD runners
* database and cache servers

You manage Linux daily via SSH from your Mac.

---

# 2. Linux In Production

In a modern production stack, Linux is the foundation layer — not where application code runs directly.

```txt
Developer (Mac)
↓
SSH
↓
Linux VPS
↓
Docker
↓
Containers (Frontend, Backend, DB, Redis, Nginx)
```

Production focus:

* stable Ubuntu LTS VPS
* non-root admin user
* Docker for applications
* systemd for host services (SSH, UFW, Fail2Ban)
* automated updates and monitoring

---

# 3. Production Architecture

```txt
User
↓
Cloudflare
↓
Nginx
↓
Frontend Container
↓
Backend Container
↓
PostgreSQL Container
↓
Redis Container
```

Linux VPS role:

```txt
Linux Host
├── Docker Engine
├── UFW Firewall
├── Fail2Ban
├── SSH (custom port)
├── Nginx (host or container)
└── /var/www/myapp/ (project files)
```

Admin access:

```txt
Developer
↓
SSH → Linux VPS
↓
docker compose commands
↓
Containers managed
```

---

# 4. Production Folder Structure

## Linux VPS (Production Host)

```txt
/
├── etc/
│   ├── ssh/sshd_config          # SSH configuration
│   ├── nginx/                   # Nginx (if host-installed)
│   └── docker/                  # Docker daemon config
├── var/
│   ├── www/myapp/               # Application deployment root
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.prod.yml
│   │   ├── .env
│   │   ├── nginx/
│   │   └── backups/
│   ├── log/
│   │   ├── auth.log             # SSH auth logs
│   │   ├── nginx/
│   │   └── syslog
│   └── lib/docker/              # Docker images, volumes, containers
├── home/mosabbir/               # Admin user home
│   ├── .ssh/authorized_keys
│   └── scripts/
└── opt/                         # Optional third-party software
```

## Mac (Developer Machine)

```txt
~/
├── .ssh/                        # SSH keys and config
├── Projects/myapp/              # Local development
└── Backups/vps/                 # Config backups
```

## Docker Container (Inside VPS)

```txt
/app/                            # Application code (immutable in prod)
/etc/nginx/conf.d/               # Nginx config (if nginx container)
/var/log/                        # Container logs
```

---

# 5. Linux vs Mac vs Docker Context

| Task | Linux (VPS) | Mac (Local) | Docker Container |
|------|-------------|-------------|------------------|
| Package manager | `apt` | `brew` | `apt` / `apk` |
| Service manager | `systemctl` | N/A | N/A (use compose) |
| Firewall | `ufw` | macOS firewall | N/A (host UFW) |
| Deploy apps | `docker compose` | build locally | runs inside container |
| Edit prod config | `nano` / `vim` | local editor + SCP | avoid — rebuild image |
| Logs | `journalctl`, `/var/log` | N/A | `docker compose logs` |

Rule: **run production commands on the Linux VPS**. Use Mac for development and SSH access only.

---

# 6. Initial Linux VPS Setup

Fresh Ubuntu VPS first boot sequence.

## Connect (Initial Root Login)

```bash
ssh root@YOUR_PUBLIC_IP
```

## Update System

```bash
sudo apt update && sudo apt upgrade -y
```

## Install Essential Tools

```bash
sudo apt install -y \
  curl \
  wget \
  git \
  nano \
  htop \
  ufw \
  fail2ban \
  ca-certificates \
  gnupg \
  lsb-release \
  unzip \
  rsync
```

## Reboot After Kernel Update

```bash
sudo reboot
```

## Verify After Reboot

```bash
ssh root@YOUR_PUBLIC_IP
uname -a
cat /etc/os-release
```

---

# 7. Essential Tools On Mac

Mac is your local workstation. Install tools for SSH, Git, and Docker development.

## Verify Built-In Tools

```bash
ssh -V
git --version
curl --version
```

## Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Install Dev Tools

```bash
brew install git curl wget jq htop
```

## Install Docker Desktop

Download from [docker.com](https://www.docker.com/products/docker-desktop/) or:

```bash
brew install --cask docker
```

## Verify Docker On Mac

```bash
docker --version
docker compose version
```

---

# 8. Linux Inside Docker Containers

Containers run Linux even when your Mac host is macOS.

## Enter Running Container

```bash
docker compose exec backend sh
# or for Debian/Ubuntu-based images:
docker compose exec backend bash
```

## Run One-Off Command

```bash
docker compose exec backend ls -la /app
```

## Alpine Container (apk)

```bash
docker run -it alpine:3.21 sh
apk add --no-cache curl bash
```

## Debian/Ubuntu Container (apt)

```bash
docker run -it ubuntu:24.04 bash
apt update && apt install -y curl
```

Production rule:

```txt
✓ Use docker compose exec for debugging
✓ Install packages in Dockerfile, not running containers
✗ apt install inside production containers manually
✗ Treat containers as persistent servers
```

---

# 9. Verify Linux Environment

## Linux VPS

```bash
whoami
cat /etc/os-release
uname -r
df -h
free -h
systemctl is-system-running
docker --version
docker compose version
```

## Mac

```bash
sw_vers
docker info
ssh -V
```

## Docker Container

```bash
docker compose exec backend cat /etc/os-release
docker compose exec backend whoami
```

Expected VPS output:

```txt
Ubuntu 24.04 LTS
Docker version 27.x
```

---

# 10. User And Group Management

Never run daily operations as root.

## Create Admin User

```bash
adduser mosabbir
```

## Add Sudo Access

```bash
usermod -aG sudo mosabbir
```

## Add User To Docker Group

```bash
usermod -aG docker mosabbir
```

## Verify Groups

```bash
groups mosabbir
```

## Switch User

```bash
su - mosabbir
```

## Show Current User

```bash
whoami
id
```

✓ Good:

* dedicated admin user (mosabbir)
* sudo for elevated commands
* docker group for compose without sudo

✗ Avoid:

* daily work as root
* shared admin accounts

---

# 11. File Permissions

Linux permissions control who can read, write, and execute files.

## Permission Format

```txt
drwxr-xr-x
│││││││││
│└┴┴ owner (rwx)
│  └┴┴ group (r-x)
│    └┴┴ others (r-x)
```

## Common Production Permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 .env
chmod 755 /var/www/myapp
chmod 644 docker-compose.yml
```

## Make Script Executable

```bash
chmod +x deploy.sh
```

## Change Ownership

```bash
sudo chown -R mosabbir:mosabbir /var/www/myapp
sudo chown -R mosabbir:mosabbir ~/.ssh
```

## View Permissions

```bash
ls -la
ls -la /var/www/myapp
```

## Recursive Permission Fix

```bash
sudo chown -R mosabbir:mosabbir /var/www/myapp
find /var/www/myapp -type d -exec chmod 755 {} \;
find /var/www/myapp -type f -exec chmod 644 {} \;
chmod 600 /var/www/myapp/.env
```

---

# 12. Environment Variables

## View Environment

```bash
env
printenv
echo $HOME
echo $USER
```

## Set Temporary Variable

```bash
export TAG=latest
export NODE_ENV=production
```

## Load From .env File

```bash
set -a
source .env
set +a
```

## Docker Compose .env

```txt
/var/www/myapp/.env
```

```bash
# Never commit .env to Git
chmod 600 .env
```

✓ Good:

* `.env` on server only
* `chmod 600` on secret files
* separate `.env` per environment

✗ Avoid:

* secrets in shell history
* world-readable `.env` files

---

# 13. Shell And Bash Basics

## Current Shell

```bash
echo $SHELL
```

## Run Script

```bash
bash deploy.sh
./deploy.sh
```

## Shebang (Production Scripts)

```bash
#!/bin/bash
set -euo pipefail
```

## Command History

```bash
history
history | grep docker
```

## Clear Terminal

```bash
clear
```

## Run Multiple Commands

```bash
sudo apt update && sudo apt upgrade -y
cd /var/www/myapp && docker compose ps
```

## Background Process

```bash
nohup ./long-task.sh > task.log 2>&1 &
```

---

# 14. Timezone And Locale

## Show Timezone

```bash
timedatectl
```

## Set Timezone (Production VPS)

```bash
sudo timedatectl set-timezone UTC
```

## Verify

```bash
date
timedatectl status
```

Use UTC on servers for consistent logs across regions.

---

# 15. Swap And System Limits

## Check Swap

```bash
free -h
swapon --show
```

## Create Swap File (Small VPS)

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## Check Open File Limits

```bash
ulimit -n
cat /proc/sys/fs/file-max
```

Useful on VPS with Docker running many containers.

---

# 16. Navigation And Directory Structure

## Show Current Directory

```bash
pwd
```

## List Files

```bash
ls
ls -la
ls -lah /var/www/
```

## Change Directory

```bash
cd /var/www/myapp
cd ..
cd ~
cd /
```

## Production Paths Reference

```txt
/                    → root
/home/mosabbir       → admin home
/var/www/myapp       → application root
/var/log             → system logs
/var/lib/docker      → Docker data
/etc/ssh             → SSH config
/etc/nginx           → Nginx config
/tmp                 → temporary files
```

---

# 17. Create Copy Move Remove

## Create Directory

```bash
mkdir /var/www/myapp
mkdir -p /var/www/myapp/{nginx,backups,scripts}
```

## Create Empty File

```bash
touch /var/www/myapp/.env
touch deploy.sh
```

## Copy File

```bash
cp docker-compose.yml docker-compose.yml.backup
cp .env .env.backup.$(date +%F)
```

## Copy Directory

```bash
cp -r /var/www/myapp /var/www/myapp.backup.$(date +%F)
```

## Move / Rename

```bash
mv old-compose.yml docker-compose.yml
```

## Remove File

```bash
rm file.txt
```

## Remove Directory

```bash
rm -r folder-name
```

✓ Good:

* backup before delete
* `cp` config before editing

✗ Avoid:

* `rm -rf /` (never)
* `rm -rf /var/lib/docker` without understanding impact

---

# 18. View And Edit Files

## View Full File

```bash
cat docker-compose.yml
```

## View Long Files

```bash
less /var/log/auth.log
```

Less keys: `q` quit, `Space` next page, `/text` search.

## First / Last Lines

```bash
head -20 .env
tail -50 /var/log/auth.log
```

## Live Log Tail

```bash
tail -f /var/log/auth.log
tail -f /var/log/nginx/access.log
```

## Edit With Nano

```bash
nano /var/www/myapp/.env
```

Nano shortcuts:

```txt
Ctrl + O → Save
Enter   → Confirm
Ctrl + X → Exit
Ctrl + K → Cut line
Ctrl + W → Search
```

## Edit With Vim (Optional)

```bash
vim /etc/ssh/sshd_config
# i → insert, Esc → normal, :wq → save quit, :q! → quit without save
```

Production preference: edit locally, deploy via Git/CI — not manual edits on server when avoidable.

---

# 19. Search And Find

## Search File Content

```bash
grep "error" /var/log/syslog
grep -r "DATABASE_URL" /var/www/myapp/
grep -i "failed" /var/log/auth.log
```

## Search With Line Numbers

```bash
grep -n "Port" /etc/ssh/sshd_config
```

## Find Files By Name

```bash
find /var/www -name "docker-compose*.yml"
find /home/mosabbir -name "*.pub"
```

## Find Large Files

```bash
find /var -type f -size +100M 2>/dev/null | head -20
du -sh /var/* | sort -hr | head -20
```

## Which Command

```bash
which docker
which nginx
which node
```

---

# 20. Archives And Compression

## Create tar.gz Backup

```bash
tar -czvf myapp-backup-$(date +%F).tar.gz /var/www/myapp
```

## Extract tar.gz

```bash
tar -xzvf myapp-backup-2026-06-01.tar.gz
```

## Create ZIP

```bash
zip -r config-backup.zip /var/www/myapp/nginx/
```

## Extract ZIP

```bash
unzip config-backup.zip
```

## Backup .env And Compose Only

```bash
tar -czvf config-$(date +%F).tar.gz \
  /var/www/myapp/.env \
  /var/www/myapp/docker-compose.yml \
  /var/www/myapp/docker-compose.prod.yml \
  /var/www/myapp/nginx/
```

---

# 21. Download Files

## Download With curl

```bash
curl -O https://example.com/file.tar.gz
curl -fsSL https://get.docker.com -o get-docker.sh
```

## Download With wget

```bash
wget https://example.com/file.tar.gz
```

## Docker Install Script (Official)

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Always verify scripts before running with `sudo sh`.

---

# 22. APT Package Management (Linux)

Ubuntu/Debian package manager for the VPS host.

## Update Package Lists

```bash
sudo apt update
```

## Upgrade Installed Packages

```bash
sudo apt upgrade -y
```

## Full System Upgrade

```bash
sudo apt update && sudo apt upgrade -y
```

## Install Package

```bash
sudo apt install nginx -y
sudo apt install docker-compose-plugin -y
```

## Remove Package

```bash
sudo apt remove nginx -y
```

## Purge Package And Config

```bash
sudo apt purge nginx -y
```

## Search Package

```bash
apt search nginx
apt show nginx
```

## List Installed

```bash
apt list --installed | grep docker
dpkg -l | grep nginx
```

## Clean Cache

```bash
sudo apt autoremove -y
sudo apt autoclean
```

---

# 23. Homebrew On Mac

Mac package manager for local development tools.

## Update Homebrew

```bash
brew update && brew upgrade
```

## Install Package

```bash
brew install jq curl wget
```

## Install Cask (GUI Apps)

```bash
brew install --cask docker
```

## Remove Package

```bash
brew uninstall jq
```

## List Installed

```bash
brew list
```

## Cleanup

```bash
brew cleanup
```

---

# 24. Package Management In Docker

Install packages in the **Dockerfile**, not in running production containers.

## Dockerfile — Debian/Ubuntu

```dockerfile
FROM node:24-slim
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*
```

## Dockerfile — Alpine

```dockerfile
FROM node:24-alpine
RUN apk add --no-cache curl bash
```

## Rebuild After Dockerfile Change

```bash
docker compose build --no-cache backend
docker compose up -d backend
```

✓ Good:

* packages in Dockerfile
* `--no-cache` when adding dependencies

✗ Avoid:

* `apt install` in running production containers

---

# 25. systemd Service Management

Manage host services on Linux VPS.

## Start Service

```bash
sudo systemctl start nginx
sudo systemctl start docker
sudo systemctl start ssh
```

## Stop Service

```bash
sudo systemctl stop nginx
```

## Restart Service

```bash
sudo systemctl restart nginx
sudo systemctl restart ssh
```

## Reload Config (No Downtime)

```bash
sudo systemctl reload nginx
```

## Service Status

```bash
sudo systemctl status nginx
sudo systemctl status docker
sudo systemctl status ssh
```

## Enable On Boot

```bash
sudo systemctl enable docker
sudo systemctl enable nginx
```

## Disable On Boot

```bash
sudo systemctl disable nginx
```

## List Running Services

```bash
systemctl list-units --type=service --state=running
```

---

# 26. Common Production Services

| Service | Purpose | Status Command |
|---------|---------|----------------|
| `ssh` | Remote access | `sudo systemctl status ssh` |
| `docker` | Container runtime | `sudo systemctl status docker` |
| `nginx` | Reverse proxy (if host) | `sudo systemctl status nginx` |
| `ufw` | Firewall | `sudo ufw status` |
| `fail2ban` | Brute-force protection | `sudo systemctl status fail2ban` |

Docker Compose services (nginx, backend, postgres) are managed with:

```bash
docker compose ps
docker compose restart nginx
docker compose up -d
```

Not with `systemctl` (unless using systemd unit for compose).

---

# 27. Network Commands

## Show IP Addresses

```bash
ip a
hostname -I
```

## Show Open Ports

```bash
sudo ss -tulpn
sudo ss -tlnp | grep -E ':80|:443|:1182'
```

## Test Connectivity

```bash
ping -c 4 google.com
curl -I https://example.com
nc -zv localhost 80
nc -zv YOUR_PUBLIC_IP 1182
```

## DNS Lookup

```bash
nslookup example.com
dig example.com +short
dig A example.com
```

## Route Table

```bash
ip route
```

## Active Connections

```bash
ss -tnp
who
w
```

---

# 28. Firewall (UFW)

UFW manages the Linux VPS host firewall.

## Enable UFW

```bash
sudo ufw enable
sudo ufw status verbose
```

## Allow SSH (Custom Port)

```bash
sudo ufw allow 1182/tcp
```

## Allow Web Traffic

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

## Allow From Specific IP

```bash
sudo ufw allow from YOUR_HOME_IP to any port 1182 proto tcp
```

## Remove Rule

```bash
sudo ufw delete allow OpenSSH
sudo ufw status numbered
sudo ufw delete 3
```

## Default Policies

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

## Production UFW Setup

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 1182/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

✓ Good:

* deny incoming by default
* only required ports open
* SSH on custom port

✗ Avoid:

* `ufw disable` in production
* exposing database ports (5432, 27017) publicly

---

# 29. DNS And Connectivity

## Verify Domain Points To VPS

```bash
dig A yourdomain.com +short
dig A api.yourdomain.com +short
```

Expected: your VPS public IP.

## Test HTTP From VPS

```bash
curl -I http://localhost
curl -I https://yourdomain.com
```

## Test Backend Health

```bash
curl http://localhost:5000/health
docker compose exec nginx curl -I http://backend:5000/health
```

Cloudflare note: DNS-only (grey cloud) for direct VPS verification during setup.

---

# 30. Local Dev With Mac Terminal

Daily developer workflow on Mac:

```txt
1. Open Terminal
2. cd ~/Projects/myapp
3. git pull
4. docker compose up -d (local dev)
5. ssh vps-prod (for server ops)
6. Run deploy commands on VPS
```

## Local Docker Dev

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
docker compose logs -f
docker compose down
```

## SSH To VPS From Mac

```bash
ssh vps-prod
cd /var/www/myapp
docker compose ps
```

Mac runs Docker Desktop locally. Production runs Docker on Linux VPS.

---

# 31. Working Inside Docker Containers

## Open Shell In Container

```bash
docker compose exec backend sh
docker compose exec postgres psql -U postgres
```

## Run Single Command

```bash
docker compose exec backend node -v
docker compose exec backend ls -la /app
```

## Copy File From Container

```bash
docker cp myapp-backend-1:/app/logs/error.log ./error.log
```

## Copy File To Container (Debug Only)

```bash
docker cp config.json myapp-backend-1:/app/config.json
```

Production: fix issues in source code and redeploy — not via `docker cp`.

---

# 32. Development Best Practices

✓ Good:

* Docker Compose for local dev
* same compose structure as production
* `.env.example` in Git, `.env` excluded
* test locally before SSH deploy

✗ Avoid:

* editing files directly on production VPS
* different folder structure local vs production
* running production as root

---

# 33. VPS Initial Setup Workflow

Complete first-time Linux VPS setup:

```txt
1. SSH as root
2. apt update && apt upgrade
3. Create admin user (mosabbir)
4. Configure SSH keys + harden sshd
5. Enable UFW + Fail2Ban
6. Install Docker
7. Create /var/www/myapp
8. Deploy docker compose stack
9. Configure Nginx + Cloudflare
10. Verify health checks
```

Commands:

```bash
ssh root@YOUR_PUBLIC_IP
sudo apt update && sudo apt upgrade -y
adduser mosabbir
usermod -aG sudo,docker mosabbir
# SSH hardening — see 02-ssh-guide.md
curl -fsSL https://get.docker.com | sudo sh
sudo mkdir -p /var/www/myapp
sudo chown -R mosabbir:mosabbir /var/www/myapp
```

See `01-initial-vps-security-setup.md` for full security steps.

---

# 34. Production Server Maintenance

## Weekly Maintenance

```bash
ssh vps-prod
sudo apt update && sudo apt upgrade -y
docker compose ps
docker system df
df -h
free -h
sudo ufw status
sudo fail2ban-client status sshd
```

## Reboot If Kernel Updated

```bash
sudo reboot
```

## Verify After Reboot

```bash
ssh vps-prod
sudo systemctl status docker
docker compose ps
curl -I http://localhost
```

## Prune Unused Docker Resources

```bash
docker system prune -f
docker image prune -f
```

Run prune carefully in production — never prune volumes without backup.

---

# 35. Docker Host Management

Linux VPS as Docker host.

## Check Docker Disk Usage

```bash
docker system df
du -sh /var/lib/docker
```

## List Containers

```bash
docker ps
docker compose ps
```

## View Resource Usage

```bash
docker stats --no-stream
```

## Restart Stack

```bash
cd /var/www/myapp
docker compose pull
docker compose up -d
```

## Inspect Container

```bash
docker inspect myapp-backend-1
docker compose logs backend --tail=100
```

---

# 36. CI/CD Server Preparation

Prepare VPS for GitHub Actions SSH deploy.

## Create Deploy Directory

```bash
sudo mkdir -p /var/www/myapp
sudo chown -R mosabbir:mosabbir /var/www/myapp
```

## Add CI Deploy Key

```bash
echo "CI_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## Create Deploy Script

```bash
nano /var/www/myapp/deploy.sh
```

```bash
#!/bin/bash
set -euo pipefail
cd /var/www/myapp
docker compose pull
docker compose up -d --remove-orphans
docker compose ps
```

```bash
chmod +x /var/www/myapp/deploy.sh
```

## GitHub Actions Calls

```yaml
script: |
  cd /var/www/myapp
  ./deploy.sh
```

---

# 37. Rollback And Safe Updates

## Before System Update

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%F)
tar -czvf /home/mosabbir/backups/pre-update-$(date +%F).tar.gz /var/www/myapp/.env /var/www/myapp/docker-compose*.yml
```

## Before Docker Deploy

```bash
docker compose ps > ~/deploy-state-before.txt
export PREVIOUS_TAG=$(docker inspect myapp-backend-1 --format='{{.Config.Image}}')
```

## Rollback Docker Images

```bash
cd /var/www/myapp
export TAG=v1.2.3
docker compose up -d
docker compose ps
```

## Rollback System Package

```bash
sudo apt install package-name=OLD_VERSION
```

Keep an open SSH session when applying system-level changes.

---

# 38. Production Linux Checklist

✓ Good:

* Ubuntu LTS VPS
* non-root admin user
* UFW + Fail2Ban enabled
* Docker for all apps
* `/var/www/myapp` standard path
* regular apt updates
* monitoring disk and memory

✗ Avoid:

* root for daily ops
* apps running directly on host (use Docker)
* unpatched system packages
* no firewall

---

# 39. Linux Security Rules

✓ Good:

* SSH key-only auth (see `02-ssh-guide.md`)
* custom SSH port
* UFW deny incoming default
* Fail2Ban for SSH
* non-root deploy user
* automatic security updates
* `.env` chmod 600

✗ Avoid:

* password SSH login
* root SSH login
* exposed database ports
* world-writable config files
* running untrusted scripts with sudo

---

# 40. User And Sudo Security

## Limit Sudo Access

Only trusted admin users in sudo group:

```bash
getent group sudo
```

## Sudo Without Password (CI Only — Use Carefully)

```bash
sudo visudo
# mosabbir ALL=(ALL) NOPASSWD: /usr/bin/docker
```

Prefer running docker via docker group, not passwordless sudo for everything.

## Lock User Account

```bash
sudo usermod -L suspicious_user
```

## Audit Logged-In Users

```bash
who
last -10
```

---

# 41. Firewall And Fail2Ban

## Install Fail2Ban

```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Check Fail2Ban Status

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

## Unban IP

```bash
sudo fail2ban-client set sshd unbanip IP_ADDRESS
```

## Combined Security Stack

```txt
UFW (block ports)
↓
Fail2Ban (block repeat offenders)
↓
SSH key-only auth
↓
Custom SSH port
```

---

# 42. Security Checklist

✓ Good:

* UFW enabled with minimal ports
* Fail2Ban active
* SSH hardened
* no root login
* `.env` permissions restricted
* regular updates

✗ Avoid:

* disabled firewall
* password authentication
* shared root credentials

---

# 43. System Logs

## All System Logs

```bash
sudo journalctl
sudo journalctl --since "1 hour ago"
sudo journalctl --since today
```

## Live Log Stream

```bash
sudo journalctl -f
```

## Auth / SSH Logs

```bash
sudo tail -f /var/log/auth.log
sudo grep "sshd" /var/log/auth.log | tail -30
```

## Syslog

```bash
sudo tail -f /var/log/syslog
```

## Nginx Logs (Host)

```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Nginx Logs (Docker)

```bash
docker compose logs -f nginx
```

---

# 44. Service Logs

## systemd Service Logs

```bash
sudo journalctl -u docker -f
sudo journalctl -u nginx -f
sudo journalctl -u ssh -f
sudo journalctl -u fail2ban -f
```

## Docker Compose Logs

```bash
docker compose logs -f
docker compose logs -f backend
docker compose logs backend --tail=200
docker compose logs backend --since 1h
```

## Export Logs

```bash
docker compose logs backend > backend-$(date +%F).log
sudo journalctl -u docker --since today > docker-today.log
```

---

# 45. Resource Monitoring

## Disk Usage

```bash
df -h
du -sh /var/www/*
du -sh /var/lib/docker
```

## Memory Usage

```bash
free -h
```

## CPU And Load

```bash
uptime
top
htop
lscpu
```

## Docker Resource Usage

```bash
docker stats --no-stream
docker system df
```

## IO Wait

```bash
iostat -x 1 5
# install: sudo apt install sysstat -y
```

## Set Up Alerts (Manual Check Script)

```bash
#!/bin/bash
DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
MEM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
echo "Disk: ${DISK}% | Memory: ${MEM}%"
[ "$DISK" -gt 85 ] && echo "WARNING: Disk usage high"
[ "$MEM" -gt 90 ] && echo "WARNING: Memory usage high"
```

---

# 46. Process Management

## List Processes

```bash
ps aux
ps aux | grep nginx
ps aux | grep docker
```

## Real-Time Monitor

```bash
htop
top
```

Install htop:

```bash
sudo apt install htop -y
```

## Find Process By Port

```bash
sudo ss -tlnp | grep :80
sudo lsof -i :5000
```

## Kill Process

```bash
kill PID
kill -15 PID
kill -9 PID
```

Use `kill -9` only when graceful stop fails.

## Kill By Name

```bash
pkill -f "process-name"
```

---

# 47. Health Checks

## VPS Host Health

```bash
uptime
df -h /
free -h
systemctl is-active docker
systemctl is-active ssh
sudo ufw status
```

## Docker Stack Health

```bash
docker compose ps
docker compose exec backend curl -f http://localhost:5000/health
curl -I http://localhost
curl -I https://yourdomain.com
```

## Health Check Script

```bash
#!/bin/bash
set -e
systemctl is-active --quiet docker
cd /var/www/myapp
docker compose ps | grep -q "Up"
curl -sf http://localhost/health > /dev/null
echo "All checks passed"
```

---

# 48. Debugging

## Verbose Command Output

```bash
bash -x deploy.sh
docker compose config
docker compose ps -a
```

## Check Config Syntax

```bash
sudo nginx -t
docker compose exec nginx nginx -t
sudo sshd -t
docker compose config --quiet
```

## Inspect Failed Container

```bash
docker compose ps -a
docker compose logs backend --tail=100
docker inspect myapp-backend-1 | grep -A10 State
```

## Network Debug

```bash
docker compose exec backend ping -c 2 postgres
docker compose exec backend nc -zv postgres 5432
curl -v http://localhost:5000/health
```

## System Debug

```bash
dmesg | tail -20
sudo journalctl -p err --since today
```

---

# 49. Backup Strategy

Production backup layers:

```txt
1. Docker volume backups (PostgreSQL, uploads)
2. Config backups (.env, compose, nginx)
3. System config backups (sshd, ufw)
4. Offsite copy (S3, another server)
5. Verify restore regularly
```

Backup schedule:

```txt
Database    → daily
Config      → before every deploy
Full volume → weekly
```

See `15-backup-snapshots.md` for full backup guide.

---

# 50. Backup Commands

## Config Backup

```bash
tar -czvf ~/backups/myapp-config-$(date +%F).tar.gz \
  /var/www/myapp/.env \
  /var/www/myapp/docker-compose.yml \
  /var/www/myapp/docker-compose.prod.yml \
  /var/www/myapp/nginx/
```

## PostgreSQL Backup (Docker)

```bash
docker compose exec postgres pg_dump -U postgres mydb > ~/backups/mydb-$(date +%F).sql
```

## Volume Backup

```bash
docker run --rm \
  -v myapp_postgres_data:/data \
  -v ~/backups:/backup \
  alpine tar -czvf /backup/postgres-data-$(date +%F).tar.gz /data
```

## Full Project Backup

```bash
tar -czvf ~/backups/myapp-full-$(date +%F).tar.gz /var/www/myapp
```

## Copy Backup To Mac

```bash
scp vps-prod:~/backups/myapp-config-*.tar.gz ./backups/
```

---

# 51. Restore Workflow

## Restore Config

```bash
tar -xzvf ~/backups/myapp-config-YYYY-MM-DD.tar.gz -C /
cd /var/www/myapp
docker compose up -d
```

## Restore PostgreSQL

```bash
cat ~/backups/mydb-YYYY-MM-DD.sql | docker compose exec -T postgres psql -U postgres mydb
```

## Restore Volume

```bash
docker compose down
docker run --rm \
  -v myapp_postgres_data:/data \
  -v ~/backups:/backup \
  alpine sh -c "cd /data && tar -xzvf /backup/postgres-data-YYYY-MM-DD.tar.gz --strip-components=1"
docker compose up -d
```

## Verify Restore

```bash
docker compose ps
docker compose exec backend curl -f http://localhost:5000/health
```

---

# 52. Recovery Workflow

Server failure recovery:

```txt
1. Provision new VPS (same OS version)
2. Restore SSH access
3. Install Docker
4. Restore /var/www/myapp from backup
5. Restore Docker volumes
6. docker compose up -d
7. Update Cloudflare DNS if IP changed
8. Verify health checks
```

Emergency commands on broken server:

```bash
# Check if Docker is the issue
sudo systemctl restart docker
docker compose up -d

# Check disk full
df -h
docker system prune -f

# Console access via cloud provider if SSH fails
```

---

# 53. Permission Denied

## Symptoms

```txt
Permission denied
bash: ./deploy.sh: Permission denied
```

## Fix File Permissions

```bash
chmod +x deploy.sh
chmod 600 .env
sudo chown -R mosabbir:mosabbir /var/www/myapp
```

## Fix Docker Permission

```bash
sudo usermod -aG docker mosabbir
# Log out and back in
newgrp docker
docker ps
```

## Fix Sudo

```bash
sudo -l
groups
```

---

# 54. Disk Full

## Symptoms

```txt
No space left on device
```

## Diagnose

```bash
df -h
du -sh /var/* | sort -hr | head -10
du -sh /var/lib/docker
docker system df
```

## Fix

```bash
docker system prune -f
docker image prune -a -f
sudo journalctl --vacuum-time=7d
sudo apt autoremove -y
```

## Find Large Log Files

```bash
find /var/log -type f -size +50M -exec ls -lh {} \;
sudo truncate -s 0 /var/log/large-log.log
```

✓ Good:

* monitor disk weekly
* log rotation configured
* prune old Docker images

✗ Avoid:

* `docker volume prune` without backup

---

# 55. Service Failed To Start

## Diagnose

```bash
sudo systemctl status nginx
sudo journalctl -u nginx --since "10 min ago"
sudo nginx -t
```

## Docker Service

```bash
sudo systemctl status docker
sudo journalctl -u docker --since "10 min ago"
```

## Container Failed

```bash
docker compose ps -a
docker compose logs backend --tail=100
```

## Common Fixes

```bash
sudo nginx -t && sudo systemctl restart nginx
sudo systemctl restart docker
docker compose up -d
```

---

# 56. Port Already In Use

## Find Process

```bash
sudo ss -tlnp | grep :80
sudo lsof -i :80
sudo lsof -i :5000
```

## Kill Conflicting Process

```bash
sudo kill $(sudo lsof -t -i :5000)
```

## Docker Port Conflict

```bash
docker compose ps
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

Stop conflicting container:

```bash
docker compose down
docker stop CONTAINER_ID
```

---

# 57. Package Install Failures

## Symptoms

```txt
E: Unable to locate package
E: Could not get lock /var/lib/dpkg/lock
```

## Fix Lock

```bash
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/apt/lists/lock
sudo dpkg --configure -a
sudo apt update
```

## Fix Broken Packages

```bash
sudo apt --fix-broken install -y
sudo apt update && sudo apt upgrade -y
```

## Package Not Found

```bash
sudo apt update
apt search package-name
```

---

# 58. Container Host Issues

## Docker Daemon Not Running

```bash
sudo systemctl status docker
sudo systemctl start docker
sudo journalctl -u docker --since "5 min ago"
```

## Container Restart Loop

```bash
docker compose ps
docker compose logs backend --tail=50
docker inspect myapp-backend-1 --format='{{.State.RestartCount}}'
```

Fix in source/Dockerfile — redeploy, do not patch running container.

## Out Of Memory Kill

```bash
dmesg | grep -i "out of memory"
free -h
docker stats --no-stream
```

Add swap or upgrade VPS RAM.

---

# 59. Network Connectivity Issues

## Cannot Reach VPS

```bash
ping YOUR_PUBLIC_IP
nc -zv YOUR_PUBLIC_IP 1182
```

Check UFW and cloud provider firewall.

## Container Cannot Reach Database

```bash
docker compose exec backend nc -zv postgres 5432
docker network ls
docker compose exec backend ping postgres
```

## DNS Not Resolving

```bash
dig yourdomain.com +short
nslookup yourdomain.com
```

Update Cloudflare A record if IP changed.

## External HTTP Fails

```bash
curl -I http://localhost
curl -I https://yourdomain.com
docker compose logs nginx
sudo ufw status
```

---

# 60. Package Removal On Linux

## Remove Package

```bash
sudo apt remove package-name -y
```

## Purge With Config

```bash
sudo apt purge package-name -y
```

## Remove Dependencies

```bash
sudo apt autoremove -y
```

## Remove Docker (If Needed)

```bash
sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt autoremove -y
```

See `04-docker.md` for full Docker uninstall steps.

---

# 61. System Cleanup On Linux

## Remove Unused Packages

```bash
sudo apt autoremove -y
sudo apt autoclean
```

## Clean Journal Logs

```bash
sudo journalctl --vacuum-time=14d
sudo journalctl --vacuum-size=500M
```

## Remove Old Kernels (Ubuntu)

```bash
sudo apt autoremove --purge -y
```

## Clear Temp Files

```bash
sudo rm -rf /tmp/*
```

Use `/tmp` cleanup carefully on active servers.

---

# 62. Docker Container Cleanup

## Remove Stopped Containers

```bash
docker container prune -f
```

## Remove Unused Images

```bash
docker image prune -f
docker image prune -a -f
```

## Remove Unused Volumes (Careful)

```bash
docker volume ls
docker volume prune -f
```

Warning: destroys unused volume data permanently.

## Full System Prune (No Volumes)

```bash
docker system prune -f
```

## Remove Specific Stack

```bash
cd /var/www/myapp
docker compose down
docker compose down --rmi all
```

---

# 63. Cache And Leftover Files

## APT Cache

```bash
sudo apt clean
sudo apt autoclean
```

## Docker Build Cache

```bash
docker builder prune -f
docker builder prune -a -f
```

## Old Backups

```bash
ls -lah ~/backups/
rm ~/backups/myapp-config-2025-*.tar.gz
```

## Orphan Docker Resources

```bash
docker system df
docker network prune -f
```

---

# 64. Verification After Cleanup

## Disk Space Recovered

```bash
df -h
docker system df
```

## Services Still Running

```bash
sudo systemctl status docker
docker compose ps
curl -I http://localhost
```

## No Broken Packages

```bash
sudo dpkg --configure -a
sudo apt update
```

## Application Health

```bash
docker compose exec backend curl -f http://localhost:5000/health
curl -I https://yourdomain.com
```

---

# 65. Recommended Production Workflow

```txt
1. Provision Ubuntu LTS VPS
2. Create admin user + SSH hardening
3. Enable UFW + Fail2Ban
4. Install Docker
5. Create /var/www/myapp structure
6. Deploy via Docker Compose
7. Configure Nginx + Cloudflare
8. Set up backups and monitoring
9. Weekly apt update + health check
10. Deploy updates via CI/CD
```

Daily commands:

```bash
ssh vps-prod
cd /var/www/myapp
docker compose ps
docker compose logs -f --tail=50
df -h && free -h
```

---

# 66. Modern Workflow

```txt
Developer (Mac)
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
SSH → Linux VPS
↓
docker compose pull && up -d
↓
Nginx
↓
Cloudflare
↓
Users
```

Linux VPS responsibilities:

* run Docker Engine
* host firewall (UFW)
* SSH access point
* store configs and volumes
* never run app code directly on host

---

# 67. Real-World Workflow

Example: Hetzner VPS running a full-stack app.

## Day 1 — Server Setup

```bash
ssh root@YOUR_PUBLIC_IP
apt update && apt upgrade -y
adduser mosabbir && usermod -aG sudo,docker mosabbir
# SSH harden, UFW, Fail2Ban
curl -fsSL https://get.docker.com | sh
mkdir -p /var/www/myapp && chown mosabbir:mosabbir /var/www/myapp
```

## Day 2 — Deploy Stack

```bash
ssh vps-prod
cd /var/www/myapp
# Upload docker-compose.prod.yml, .env, nginx/
docker compose up -d
docker compose ps
curl -I http://localhost
```

## Ongoing — Deploy Updates

```bash
# GitHub Actions SSH deploy
cd /var/www/myapp
docker compose pull
docker compose up -d
docker compose ps
docker compose logs backend --tail=20
```

## Weekly — Maintenance

```bash
ssh vps-prod
sudo apt update && sudo apt upgrade -y
df -h
docker system df
docker system prune -f
```

---

# 68. Final Production Checklist

## VPS Setup

✓ Ubuntu LTS installed
✓ Admin user created (non-root)
✓ SSH hardened (custom port, key-only)
✓ UFW enabled (80, 443, SSH port only)
✓ Fail2Ban active
✓ Docker installed and enabled on boot

✗ Root daily login
✗ Password SSH enabled
✗ All ports open

## Application

✓ Docker Compose manages all services
✓ `/var/www/myapp` deployment path
✓ `.env` chmod 600, not in Git
✓ Nginx reverse proxy configured
✓ Cloudflare DNS + SSL configured
✓ Health checks passing

✗ Apps running directly on host via PM2/systemd
✗ Database port exposed publicly

## Operations

✓ Backups scheduled (DB + config)
✓ Log monitoring in place
✓ Disk/memory checks weekly
✓ CI/CD deploy pipeline working
✓ Rollback procedure documented

## Full Stack Verified

```txt
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
Linux VPS
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

## Linux Quick Commands Cheat Sheet

```bash
# Navigation
pwd && ls -la && cd /var/www/myapp

# System info
whoami && uname -a && df -h && free -h

# Packages
sudo apt update && sudo apt upgrade -y
sudo apt install PACKAGE -y

# Services
sudo systemctl status SERVICE
sudo systemctl restart SERVICE

# Docker
docker compose ps
docker compose logs -f
docker compose up -d
docker system df

# Network
ip a
sudo ss -tulpn
sudo ufw status
nc -zv localhost 80

# Logs
sudo tail -f /var/log/auth.log
sudo journalctl -f
docker compose logs backend --tail=100

# Permissions
chmod 600 .env
sudo chown -R mosabbir:mosabbir /var/www/myapp

# Backup
tar -czvf backup-$(date +%F).tar.gz /var/www/myapp/.env /var/www/myapp/docker-compose*.yml

# Cleanup
docker system prune -f
sudo apt autoremove -y
```
