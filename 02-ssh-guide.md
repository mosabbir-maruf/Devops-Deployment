# SSH Guide

## Table Of Contents

### Fundamentals

1. [What Is SSH](#1-what-is-ssh)
2. [SSH Key Authentication](#2-ssh-key-authentication)
3. [Production SSH Architecture](#3-production-ssh-architecture)
4. [Production Folder Structure](#4-production-folder-structure)

### Installation

5. [Install OpenSSH Client On Linux](#5-install-openssh-client-on-linux)
6. [Install OpenSSH Client On Mac](#6-install-openssh-client-on-mac)
7. [Install OpenSSH In Docker](#7-install-openssh-in-docker)
8. [Install OpenSSH Server On Linux (VPS)](#8-install-openssh-server-on-linux-vps)
9. [Verify SSH Installation](#9-verify-ssh-installation)

### Configuration

10. [Generate SSH Keys (Production)](#10-generate-ssh-keys-production)
11. [SSH Config File](#11-ssh-config-file)
12. [SSH Agent And Passphrase](#12-ssh-agent-and-passphrase)
13. [Copy Public Key To Server](#13-copy-public-key-to-server)
14. [Server SSH Configuration (sshd_config)](#14-server-ssh-configuration-sshd_config)
15. [SSH Config For Multiple Environments](#15-ssh-config-for-multiple-environments)
16. [Connection Multiplexing](#16-connection-multiplexing)
17. [Known Hosts Management](#17-known-hosts-management)
18. [File Permissions](#18-file-permissions)

### Development Workflow

19. [Local Development SSH Workflow](#19-local-development-ssh-workflow)
20. [GitHub SSH Authentication](#20-github-ssh-authentication)
21. [SSH Tunneling For Development](#21-ssh-tunneling-for-development)
22. [SCP And SFTP](#22-scp-and-sftp)
23. [Development Best Practices](#23-development-best-practices)

### Production Workflow

24. [VPS SSH Setup Workflow](#24-vps-ssh-setup-workflow)
25. [SSH With Docker Production Stack](#25-ssh-with-docker-production-stack)
26. [GitHub Actions SSH Deployment](#26-github-actions-ssh-deployment)
27. [Docker Compose Deployment Via SSH](#27-docker-compose-deployment-via-ssh)
28. [Nginx And Cloudflare Integration](#28-nginx-and-cloudflare-integration)
29. [Rollback Safety Before SSH Changes](#29-rollback-safety-before-ssh-changes)
30. [Production SSH Checklist](#30-production-ssh-checklist)

### Security Best Practices

31. [Client Security](#31-client-security)
32. [Server Security Hardening](#32-server-security-hardening)
33. [Firewall And Fail2Ban Integration](#33-firewall-and-fail2ban-integration)
34. [SSH Security Checklist](#34-ssh-security-checklist)

### Monitoring And Logging

35. [SSH Logs](#35-ssh-logs)
36. [Active Connection Monitoring](#36-active-connection-monitoring)
37. [Health Checks](#37-health-checks)
38. [Resource Monitoring](#38-resource-monitoring)
39. [SSH Debugging](#39-ssh-debugging)

### Backup And Restore

40. [Backup SSH Keys](#40-backup-ssh-keys)
41. [Backup Server authorized_keys](#41-backup-server-authorized_keys)
42. [Restore Workflow](#42-restore-workflow)
43. [Recovery Workflow](#43-recovery-workflow)

### Troubleshooting

44. [Permission Denied (publickey)](#44-permission-denied-publickey)
45. [Port Already In Use](#45-port-already-in-use)
46. [Host Key Verification Failed](#46-host-key-verification-failed)
47. [Connection Timed Out](#47-connection-timed-out)
48. [DNS Issues](#48-dns-issues)
49. [Container And Docker SSH Issues](#49-container-and-docker-ssh-issues)
50. [Service Connectivity Issues](#50-service-connectivity-issues)

### Cleanup And Uninstall

51. [Remove SSH Keys On Mac](#51-remove-ssh-keys-on-mac)
52. [Remove SSH Keys On Linux](#52-remove-ssh-keys-on-linux)
53. [Remove OpenSSH Client In Docker](#53-remove-openssh-client-in-docker)
54. [Uninstall OpenSSH Server On Linux](#54-uninstall-openssh-server-on-linux)
55. [Cache And Leftover File Cleanup](#55-cache-and-leftover-file-cleanup)
56. [Verification After Removal](#56-verification-after-removal)

### Production Workflows

57. [Recommended Production Workflow](#57-recommended-production-workflow)
58. [Modern Workflow](#58-modern-workflow)
59. [Real-World Workflow](#59-real-world-workflow)
60. [Final Production Checklist](#60-final-production-checklist)

---

# 1. What Is SSH

SSH (Secure Shell) is the standard protocol for secure remote server administration, file transfer, and automated deployments.

Production use cases:

* VPS access
* GitHub authentication
* CI/CD deployment to servers
* secure tunnels to private services

Basic connection:

```bash
ssh user@SERVER_IP
```

---

# 2. SSH Key Authentication

SSH uses public/private key pairs. The public key lives on the server; the private key stays on your machine or in CI secrets.

```txt
Private Key (client)
↓
Proves identity
↓
Public Key (server authorized_keys)
↓
Access granted
```

Always use **Ed25519** keys in production. Never share private keys.

---

# 3. Production SSH Architecture

SSH is the entry point to your production stack. Users never SSH into application containers directly.

```txt
Developer
↓
SSH (custom port + key only)
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

Full production traffic flow:

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

SSH access point:

```txt
Developer / GitHub Actions
↓
SSH → VPS (port 1182)
↓
docker compose commands
↓
Containers updated
```

---

# 4. Production Folder Structure

## Client (Mac / Linux)

```txt
~/.ssh/
├── config                  # Host aliases, ports, keys
├── id_ed25519              # GitHub / default key (private)
├── id_ed25519.pub          # GitHub public key
├── vps_ed25519             # VPS-only key (private)
├── vps_ed25519.pub         # VPS public key
├── ci_deploy_ed25519       # CI/CD deploy key (private, encrypted backup)
├── ci_deploy_ed25519.pub   # CI/CD public key
├── known_hosts             # Trusted server fingerprints
└── control-*               # Multiplexing sockets (auto-created)
```

## Server (VPS)

```txt
/home/mosabbir/.ssh/
├── authorized_keys         # Allowed public keys
└── (no private keys on server)

/etc/ssh/
├── sshd_config             # Server SSH configuration
├── sshd_config.d/          # Modular config snippets
└── ssh_host_*              # Server host keys (auto-generated)

/var/log/auth.log           # SSH authentication logs (Ubuntu/Debian)
```

## Production Project (VPS)

```txt
/var/www/myapp/
├── docker-compose.yml
├── docker-compose.prod.yml
├── .env
├── nginx/
│   └── default.conf
└── backups/
    └── ssh/
        └── authorized_keys.backup
```

---

# 5. Install OpenSSH Client On Linux

## Update System

```bash
sudo apt update && sudo apt upgrade -y
```

## Install OpenSSH Client

```bash
sudo apt install openssh-client -y
```

## Verify Client

```bash
ssh -V
```

Expected:

```txt
OpenSSH_9.x ...
```

---

# 6. Install OpenSSH Client On Mac

OpenSSH client is pre-installed on macOS.

## Verify Client

```bash
ssh -V
```

## Install Latest OpenSSH (Optional)

```bash
brew install openssh
```

Use Homebrew version only if you need a newer client than macOS provides.

---

# 7. Install OpenSSH In Docker

Do **not** run `sshd` inside application containers in production.

Use OpenSSH client inside CI/CD or deployment containers only.

## Dockerfile — Deploy Container With SSH Client

```dockerfile
FROM alpine:3.21

RUN apk add --no-cache openssh-client bash git

WORKDIR /deploy
```

## Docker Compose — CI Deploy Sidecar (Example)

```yaml
services:
  deploy:
    image: alpine:3.21
    command: sleep infinity
    volumes:
      - ./:/deploy
    environment:
      - SSH_AUTH_SOCK=/ssh-agent
    volumes_from:
      - ssh-agent

  ssh-agent:
    image: alpine:3.21
    command: sh -c "apk add --no-cache openssh-client && ssh-agent -a /tmp/agent.sock && sleep infinity"
    volumes:
      - ssh-agent-sock:/tmp
```

Production rule:

```txt
✓ SSH client in CI/CD runner or deploy container
✓ SSH to VPS host, then run docker compose
✗ SSH daemon inside app/database containers
✗ docker exec as a deployment strategy
```

---

# 8. Install OpenSSH Server On Linux (VPS)

Most VPS images include OpenSSH server. Verify before installing.

## Check If SSH Server Is Running

```bash
sudo systemctl status ssh
```

## Install OpenSSH Server

```bash
sudo apt install openssh-server -y
```

## Enable On Boot

```bash
sudo systemctl enable ssh
```

## Start SSH Server

```bash
sudo systemctl start ssh
```

---

# 9. Verify SSH Installation

## Linux Client Verification

```bash
which ssh
ssh -V
```

## Mac Client Verification

```bash
which ssh
ssh -V
```

## Linux Server Verification

```bash
sudo systemctl status ssh
sudo ss -tlnp | grep sshd
```

Expected:

```txt
LISTEN 0 128 0.0.0.0:22 ... sshd
```

## Docker Client Verification

```bash
docker run --rm alpine:3.21 sh -c "apk add --no-cache openssh-client && ssh -V"
```

## End-To-End Connection Test

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

---

# 10. Generate SSH Keys (Production)

Use separate keys per purpose. Never reuse one key for GitHub, VPS, and CI/CD.

## Generate GitHub Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "github-access"
```

## Generate VPS Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/vps_ed25519 -C "vps-access"
```

## Generate CI/CD Deploy Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ci_deploy_ed25519 -C "ci-deploy-production"
```

Always set a passphrase on keys used on developer machines.

## View Public Keys

```bash
cat ~/.ssh/id_ed25519.pub
cat ~/.ssh/vps_ed25519.pub
cat ~/.ssh/ci_deploy_ed25519.pub
```

## Copy Public Key To Clipboard (Mac)

```bash
pbcopy < ~/.ssh/vps_ed25519.pub
```

## Copy Public Key To Clipboard (Linux)

```bash
xclip -selection clipboard < ~/.ssh/vps_ed25519.pub
```

## Key Type Reference

```txt
-t ed25519   → Modern, fast, secure (recommended)
-f PATH      → Custom key file path
-C "label"   → Comment/identifier only (no security effect)
```

✓ Good:

* Ed25519 keys
* Separate keys per service
* Passphrase on local keys
* Descriptive `-C` labels

✗ Avoid:

* RSA 2048 or weaker
* One key for everything
* Unencrypted keys on laptops
* Generating keys on the server

---

# 11. SSH Config File

## Location

```txt
~/.ssh/config
```

## Create Config File

```bash
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

## Production Config Example

```txt
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

# Production VPS
Host vps-prod
    HostName YOUR_PUBLIC_IP
    User mosabbir
    Port 1182
    IdentityFile ~/.ssh/vps_ed25519
    IdentitiesOnly yes

# Staging VPS
Host vps-staging
    HostName STAGING_IP
    User mosabbir
    Port 1182
    IdentityFile ~/.ssh/vps_ed25519
    IdentitiesOnly yes
```

## Connect Using Alias

```bash
ssh vps-prod
```

## Custom Port Without Config

```bash
ssh -p 1182 mosabbir@YOUR_PUBLIC_IP
```

## Specify Key Without Config

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

---

# 12. SSH Agent And Passphrase

Passphrases protect private keys if your device is compromised.

## Start SSH Agent (Linux / Mac)

```bash
eval "$(ssh-agent -s)"
```

## Add Key To Agent

```bash
ssh-add ~/.ssh/vps_ed25519
ssh-add ~/.ssh/id_ed25519
```

## List Loaded Keys

```bash
ssh-add -l
```

## macOS — Persist Keys In Keychain

```bash
ssh-add --apple-use-keychain ~/.ssh/vps_ed25519
```

Add to `~/.ssh/config`:

```txt
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
```

✓ Good:

* Passphrase on all local keys
* SSH agent for session convenience
* macOS Keychain integration

✗ Avoid:

* Empty passphrase on production keys
* Sharing agent sockets across untrusted machines

---

# 13. Copy Public Key To Server

## Method 1 — ssh-copy-id (Recommended)

```bash
ssh-copy-id -i ~/.ssh/vps_ed25519.pub -p 1182 mosabbir@YOUR_PUBLIC_IP
```

## Method 2 — Manual (First Login / Cloud Console)

On your local machine:

```bash
cat ~/.ssh/vps_ed25519.pub
```

On the server:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
# Paste public key, save
chmod 600 ~/.ssh/authorized_keys
```

## Method 3 — Cloud Provider Panel

Paste public key during VPS creation (DigitalOcean, Hetzner, AWS, etc.).

## Verify Key Was Added

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

---

# 14. Server SSH Configuration (sshd_config)

Always keep a second SSH session open while applying changes.

## Open Config

```bash
sudo nano /etc/ssh/sshd_config
```

## Production Settings

```txt
Port 1182
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
AllowUsers mosabbir
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowTcpForwarding yes
```

Setting reference:

```txt
Port 1182                    → Custom port (not default 22)
PermitRootLogin no           → Block root SSH login
PasswordAuthentication no    → Keys only
AllowUsers mosabbir          → Restrict to named users
MaxAuthTries 3               → Limit brute-force attempts
```

## Validate Config Before Restart

```bash
sudo sshd -t
```

No output = valid config.

## Apply Changes

```bash
sudo systemctl restart ssh
```

## Verify Service

```bash
sudo systemctl status ssh
```

Expected:

```txt
active (running)
```

## Test New Connection (Keep Old Session Open)

```bash
ssh vps-prod
```

---

# 15. SSH Config For Multiple Environments

```txt
Host vps-prod
    HostName 203.0.113.10
    User mosabbir
    Port 1182
    IdentityFile ~/.ssh/vps_ed25519

Host vps-staging
    HostName 203.0.113.20
    User mosabbir
    Port 1182
    IdentityFile ~/.ssh/vps_ed25519

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Connect:

```bash
ssh vps-prod
ssh vps-staging
git clone git@github.com:username/repo.git
```

---

# 16. Connection Multiplexing

Reuses existing SSH connections for faster repeated access (deploy scripts, SCP, rsync).

Add to `~/.ssh/config`:

```txt
Host vps-prod vps-staging
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m
```

Benefits:

* faster repeated connections
* fewer authentication round-trips
* smoother CI/CD and rsync workflows

---

# 17. Known Hosts Management

## Known Hosts File

```txt
~/.ssh/known_hosts
```

Stores trusted server fingerprints to prevent man-in-the-middle attacks.

## Remove Stale Entry (After VPS Reinstall)

```bash
ssh-keygen -R YOUR_PUBLIC_IP
ssh-keygen -R vps-prod
```

## Remove By Hostname And Port

```bash
ssh-keygen -R "[YOUR_PUBLIC_IP]:1182"
```

Reconnect to accept the new fingerprint:

```bash
ssh vps-prod
```

---

# 18. File Permissions

Incorrect permissions cause `Permission denied (publickey)`.

## Client (Mac / Linux)

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 600 ~/.ssh/vps_ed25519
chmod 600 ~/.ssh/config
chmod 644 ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/vps_ed25519.pub
```

## Server

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown -R mosabbir:mosabbir ~/.ssh
```

## Verify Permissions

```bash
ls -la ~/.ssh
```

Expected:

```txt
drwx------  .ssh
-rw-------  id_ed25519
-rw-------  vps_ed25519
-rw-------  config
-rw-r--r--  id_ed25519.pub
-rw-r--r--  vps_ed25519.pub
```

---

# 19. Local Development SSH Workflow

Recommended daily workflow:

```txt
1. Generate keys (once)
2. Add keys to ssh-agent
3. Configure ~/.ssh/config aliases
4. Connect: ssh vps-prod
5. Run docker compose commands on VPS
6. Monitor logs
7. Disconnect
```

## Quick Dev Session

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/vps_ed25519
ssh vps-prod
cd /var/www/myapp
docker compose logs -f backend
```

✓ Good:

* Config aliases
* Dedicated VPS key
* SSH only to VPS host

✗ Avoid:

* SSH into running containers to edit code
* Password-based login
* Root login for daily work

---

# 20. GitHub SSH Authentication

## Test GitHub Connection

```bash
ssh -T git@github.com
```

Expected:

```txt
Hi username! You've successfully authenticated...
```

## Clone Repository

```bash
git clone git@github.com:username/repo.git
```

## Add Deploy Key (Read-Only, Per Repo)

GitHub → Repository → Settings → Deploy keys → Add deploy key

Use a dedicated key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy_myapp -C "deploy-myapp"
```

Config:

```txt
Host github-myapp
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_deploy_myapp
    IdentitiesOnly yes
```

Clone:

```bash
git clone git@github-myapp:username/myapp.git
```

---

# 21. SSH Tunneling For Development

Access private services without exposing ports publicly.

## Forward Local Port To Remote Service

```bash
ssh -L 5432:localhost:5432 vps-prod
```

Connect locally:

```bash
psql -h localhost -p 5432 -U postgres
```

## Forward To Docker Container Port On VPS

```bash
ssh -L 8080:127.0.0.1:8080 vps-prod
```

## Background Tunnel

```bash
ssh -f -N -L 3000:127.0.0.1:3000 vps-prod
```

Use cases:

* private admin panels
* database access during debugging
* Redis/PostgreSQL inspection

✓ Good:

* localhost-only binding on server
* tunnels for temporary debugging

✗ Avoid:

* exposing database ports in UFW
* permanent tunnels instead of proper access controls

---

# 22. SCP And SFTP

## Copy File To VPS

```bash
scp -P 1182 -i ~/.ssh/vps_ed25519 file.txt mosabbir@YOUR_PUBLIC_IP:/home/mosabbir/
```

## Copy File From VPS

```bash
scp -P 1182 -i ~/.ssh/vps_ed25519 mosabbir@YOUR_PUBLIC_IP:/home/mosabbir/file.txt .
```

## Copy Directory Recursively

```bash
scp -r -P 1182 -i ~/.ssh/vps_ed25519 ./config/ vps-prod:/var/www/myapp/config/
```

## SFTP Session

```bash
sftp -P 1182 -i ~/.ssh/vps_ed25519 mosabbir@YOUR_PUBLIC_IP
```

Production preference: use Git + CI/CD or `rsync` over SCP for deployments. SCP is for config files, backups, and one-off transfers.

## Rsync Over SSH (Production Deployments)

```bash
rsync -avz -e "ssh -p 1182 -i ~/.ssh/vps_ed25519" \
  ./docker-compose.prod.yml vps-prod:/var/www/myapp/
```

---

# 23. Development Best Practices

✓ Good:

* Separate GitHub and VPS keys
* SSH config aliases
* Passphrase + ssh-agent
* Tunnel for private service access
* `IdentitiesOnly yes` in config

✗ Avoid:

* Password authentication
* Sharing private keys in chat/email
* Using production keys on shared machines
* Editing code directly on the server

---

# 24. VPS SSH Setup Workflow

Complete first-time VPS SSH hardening:

```txt
1. Generate VPS key locally
2. Connect as root (initial login only)
3. Create admin user (mosabbir)
4. Copy public key to admin user
5. Fix permissions
6. Enable UFW + allow SSH port
7. Harden sshd_config
8. Validate: sudo sshd -t
9. Restart SSH (keep old session open)
10. Test new login with admin user + custom port
11. Disable root login and password auth
12. Remove port 22 from firewall
```

Commands summary:

```bash
# Local
ssh-keygen -t ed25519 -f ~/.ssh/vps_ed25519 -C "vps-access"
ssh-copy-id -i ~/.ssh/vps_ed25519.pub root@YOUR_PUBLIC_IP

# Server
adduser mosabbir
usermod -aG sudo mosabbir
mkdir -p /home/mosabbir/.ssh
cp ~/.ssh/authorized_keys /home/mosabbir/.ssh/
chown -R mosabbir:mosabbir /home/mosabbir/.ssh
chmod 700 /home/mosabbir/.ssh
chmod 600 /home/mosabbir/.ssh/authorized_keys
```

See `01-initial-vps-security-setup.md` for full VPS hardening steps.

---

# 25. SSH With Docker Production Stack

SSH connects to the **VPS host**. Docker containers are managed from the host.

```txt
Developer
↓
ssh vps-prod
↓
cd /var/www/myapp
↓
docker compose pull
↓
docker compose up -d
↓
docker compose ps
```

## Production Commands After SSH

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
docker compose ps
docker compose logs -f --tail=100
```

## Never Do This In Production

```txt
SSH Into Container
↓
Edit Files
↓
Restart Container
```

Use immutable deployments:

```txt
Code Change
↓
GitHub Actions Build
↓
Push Image
↓
SSH → docker compose up -d
```

---

# 26. GitHub Actions SSH Deployment

## Architecture

```txt
Developer
↓
GitHub Push
↓
GitHub Actions
↓
SSH (deploy key)
↓
VPS
↓
docker compose up -d
↓
Nginx
↓
Cloudflare
↓
Users
```

## Docker Compose Deploy Workflow

```yaml
name: Deploy Production

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          port: ${{ secrets.SERVER_SSH_PORT }}
          script: |
            cd /var/www/myapp
            docker compose pull
            docker compose up -d --remove-orphans
            docker compose ps
            docker image prune -f
```

## Required GitHub Secrets

```txt
SERVER_IP
SERVER_USER
SERVER_SSH_KEY        # Private key (ci_deploy_ed25519)
SERVER_SSH_PORT       # 1182
```

## Add CI Public Key To Server

On VPS:

```bash
echo "CI_PUBLIC_KEY_CONTENT" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

✓ Good:

* Dedicated deploy key per environment
* Restrict deploy user permissions
* Deploy script runs docker compose only

✗ Avoid:

* Personal SSH keys in GitHub Secrets
* Root user for CI/CD deploys
* `git pull` + manual edits on production (use images)

---

# 27. Docker Compose Deployment Via SSH

## Production docker-compose.prod.yml (On VPS)

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
    networks:
      - app-network

  postgres:
    image: postgres:17
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:8-alpine
    restart: unless-stopped
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx:/etc/nginx/conf.d:ro
      - ./certs:/etc/nginx/certs:ro
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
```

## Deploy Script (Run Via SSH)

```bash
#!/bin/bash
set -euo pipefail
cd /var/www/myapp
export TAG="${1:-latest}"
docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
docker compose ps
```

---

# 28. Nginx And Cloudflare Integration

SSH is not in the user traffic path. It administers the VPS running Nginx.

```txt
User
↓
Cloudflare (DNS + SSL + WAF)
↓
Nginx (reverse proxy on VPS)
↓
Frontend / Backend containers
```

Admin access:

```bash
ssh vps-prod
sudo nginx -t
sudo systemctl reload nginx
# Or for Docker Nginx:
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
```

Cloudflare SSH considerations:

* SSH connects to VPS public IP (or VPN/bastion IP)
* Do not expose SSH through Cloudflare proxy (orange cloud is HTTP/HTTPS only)
* Restrict SSH source IPs in UFW when possible

```bash
sudo ufw allow from YOUR_HOME_IP to any port 1182 proto tcp
```

---

# 29. Rollback Safety Before SSH Changes

Before changing SSH port, auth, or firewall rules:

## Pre-Change Checklist

```txt
✓ Keep current SSH session open
✓ Open second terminal and test new connection
✓ Run sudo sshd -t before restart
✓ Confirm cloud provider console access (out-of-band recovery)
✓ Backup sshd_config and authorized_keys
✓ Document rollback commands
```

## Backup Before Change

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%F)
cp ~/.ssh/authorized_keys ~/authorized_keys.backup.$(date +%F)
```

## Rollback sshd_config

```bash
sudo cp /etc/ssh/sshd_config.backup.YYYY-MM-DD /etc/ssh/sshd_config
sudo sshd -t
sudo systemctl restart ssh
```

## Rollback Docker Deployment

```bash
ssh vps-prod
cd /var/www/myapp
export TAG=previous-stable
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

# 30. Production SSH Checklist

✓ Good:

* Ed25519 keys, separate per service
* Custom SSH port (e.g. 1182)
* Key-only authentication
* Non-root deploy user with sudo
* UFW allows only required ports
* Fail2Ban enabled
* SSH config aliases on client
* CI/CD uses dedicated deploy key
* Encrypted backup of private keys

✗ Avoid:

* Password authentication
* Root SSH login
* Default port 22 exposed
* Shared keys across team members
* Editing production containers via SSH
* Applying SSH changes without `sshd -t`

---

# 31. Client Security

✓ Good:

* Passphrase-protected private keys
* `IdentitiesOnly yes` in config
* Separate keys for GitHub, VPS, CI/CD
* Encrypted backup of `~/.ssh/` (password manager, encrypted drive)
* Rotate keys after team member departure or compromise
* Full disk encryption on developer machines

✗ Avoid:

* Private keys in Git repositories
* Private keys in Slack/email
* Unencrypted USB backups of keys
* Using production keys on public/shared computers

---

# 32. Server Security Hardening

## sshd_config Production Template

```txt
Port 1182
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
AllowUsers mosabbir
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowAgentForwarding no
PermitTunnel no
```

## Disable Unused Authentication

```bash
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sshd -t && sudo systemctl restart ssh
```

## Remove Unused authorized_keys

```bash
nano ~/.ssh/authorized_keys
# Remove keys for departed team members or rotated keys
```

✓ Good:

* AllowUsers restriction
* MaxAuthTries limit
* Regular authorized_keys audit

✗ Avoid:

* `PermitRootLogin yes`
* `PasswordAuthentication yes`
* Wildcard `AllowUsers` across untrusted accounts

---

# 33. Firewall And Fail2Ban Integration

## UFW — Allow Custom SSH Port

```bash
sudo ufw allow 1182/tcp
sudo ufw enable
sudo ufw status
```

## Remove Default SSH Port After Verification

```bash
sudo ufw delete allow OpenSSH
sudo ufw status
```

## Restrict SSH To Known IP (Recommended)

```bash
sudo ufw allow from YOUR_HOME_IP to any port 1182 proto tcp
sudo ufw allow from GITHUB_ACTIONS_IP to any port 1182 proto tcp
```

## Fail2Ban

```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo fail2ban-client status sshd
```

---

# 34. SSH Security Checklist

✓ Good:

* Custom port + key-only auth
* Non-root user
* UFW + Fail2Ban
* Separate deploy keys
* Regular key rotation
* auth.log monitoring
* Out-of-band console access configured

✗ Avoid:

* SSH on port 22 publicly
* Password login enabled
* Root login enabled
* Shared team SSH keys
* Ignoring Fail2Ban alerts

---

# 35. SSH Logs

## Ubuntu / Debian Auth Log

```bash
sudo tail -f /var/log/auth.log
```

## Filter SSH Login Attempts

```bash
sudo grep "sshd" /var/log/auth.log | tail -50
```

## Failed Login Attempts

```bash
sudo grep "Failed password\|Invalid user\|Connection closed by authenticating user" /var/log/auth.log
```

## Successful Logins

```bash
sudo grep "Accepted publickey" /var/log/auth.log | tail -20
```

## RHEL / CentOS

```bash
sudo tail -f /var/log/secure
```

## journalctl

```bash
sudo journalctl -u ssh -f
sudo journalctl -u ssh --since "1 hour ago"
```

---

# 36. Active Connection Monitoring

## Current Logged-In Users

```bash
who
w
```

## Active SSH Connections

```bash
ss -tnp | grep sshd
```

## Show SSH Process Tree

```bash
ps aux | grep sshd
```

## Disconnect Suspicious Session

```bash
sudo pkill -u suspicious_user
```

---

# 37. Health Checks

## SSH Service Status

```bash
sudo systemctl status ssh
```

## SSH Port Listening

```bash
sudo ss -tlnp | grep 1182
```

## Config Syntax Check

```bash
sudo sshd -t
```

## Remote Health Check Script

```bash
#!/bin/bash
systemctl is-active ssh || exit 1
sshd -t || exit 1
ss -tlnp | grep -q ":1182" || exit 1
echo "SSH healthy"
```

## External Port Check (From Local Machine)

```bash
nc -zv YOUR_PUBLIC_IP 1182
```

---

# 38. Resource Monitoring

## SSH Connection Count

```bash
ss -tn | grep :1182 | wc -l
```

## Auth Log Disk Usage

```bash
du -sh /var/log/auth.log*
```

## Logrotate Status

```bash
ls -la /var/log/auth.log*
```

High failed login volume may indicate brute-force attacks — verify Fail2Ban is active.

---

# 39. SSH Debugging

## Verbose Connection

```bash
ssh -v vps-prod
```

## Maximum Verbosity

```bash
ssh -vvv vps-prod
```

## Test Specific Key

```bash
ssh -i ~/.ssh/vps_ed25519 -vvv -p 1182 mosabbir@YOUR_PUBLIC_IP
```

## Server-Side Debug (Temporary — Remove After)

```bash
sudo /usr/sbin/sshd -d -p 1183
```

Connect to debug port from another terminal:

```bash
ssh -p 1183 mosabbir@localhost
```

## Common Debug Signals

```txt
Offering public key        → Client sending key
Authentications that can continue → Key rejected, check authorized_keys
Connection timed out       → Firewall, wrong IP, or SSH not running
Permission denied (publickey) → Key/permissions/user mismatch
```

---

# 40. Backup SSH Keys

## Encrypted Archive (Mac / Linux)

```bash
tar czf ~/ssh-backup-$(date +%F).tar.gz -C ~ .ssh
gpg -c ~/ssh-backup-$(date +%F).tar.gz
rm ~/ssh-backup-$(date +%F).tar.gz
```

## Backup Individual Keys

```bash
cp ~/.ssh/vps_ed25519 ~/Backups/encrypted-drive/vps_ed25519.backup
cp ~/.ssh/config ~/Backups/encrypted-drive/ssh-config.backup
```

✓ Good:

* Encrypted offsite backup
* Password manager for recovery codes
* Document which key belongs to which service

✗ Avoid:

* Plaintext cloud sync of `~/.ssh/`
* Backups without encryption

---

# 41. Backup Server authorized_keys

```bash
ssh vps-prod
cp ~/.ssh/authorized_keys ~/authorized_keys.backup.$(date +%F)
```

Copy to local machine:

```bash
scp vps-prod:~/authorized_keys.backup.* ./backups/ssh/
```

Backup sshd_config:

```bash
sudo cp /etc/ssh/sshd_config /root/sshd_config.backup.$(date +%F)
scp vps-prod:/root/sshd_config.backup.* ./backups/ssh/
```

---

# 42. Restore Workflow

## Restore Client Keys

```bash
gpg -d ~/ssh-backup-YYYY-MM-DD.tar.gz.gpg | tar xzf - -C ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub
```

## Restore Server authorized_keys

```bash
ssh vps-prod
cp ~/authorized_keys.backup.YYYY-MM-DD ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## Restore sshd_config

```bash
sudo cp /root/sshd_config.backup.YYYY-MM-DD /etc/ssh/sshd_config
sudo sshd -t
sudo systemctl restart ssh
```

## Verify Restore

```bash
ssh vps-prod
sudo systemctl status ssh
```

---

# 43. Recovery Workflow

Locked out of SSH?

```txt
1. Use cloud provider web console (VNC/serial)
2. Login as root or recovery user
3. Fix sshd_config / authorized_keys / UFW
4. Run sudo sshd -t
5. Restart SSH: sudo systemctl restart ssh
6. Test from local machine before closing console
```

Console recovery commands:

```bash
sudo ufw allow 1182/tcp
sudo nano /etc/ssh/sshd_config
sudo sshd -t
sudo systemctl restart ssh
chmod 700 /home/mosabbir/.ssh
chmod 600 /home/mosabbir/.ssh/authorized_keys
```

---

# 44. Permission Denied (publickey)

## Symptoms

```txt
Permission denied (publickey).
```

## Fix Checklist

```bash
# 1. Correct key
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP

# 2. Client permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/vps_ed25519

# 3. Server permissions (via console if locked out)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown -R mosabbir:mosabbir ~/.ssh

# 4. Verify public key is in authorized_keys
cat ~/.ssh/authorized_keys

# 5. Debug
ssh -vvv vps-prod
```

Common causes:

* wrong key file
* wrong username
* wrong port
* incorrect `~/.ssh` or `authorized_keys` permissions
* key not in `authorized_keys`

---

# 45. Port Already In Use

## Symptoms

```txt
Bind to port 22: Address already in use
```

## Find Process Using Port

```bash
sudo ss -tlnp | grep :1182
sudo lsof -i :1182
```

## Kill Stale sshd (Careful)

```bash
sudo systemctl restart ssh
```

## Change Port In sshd_config

```bash
sudo nano /etc/ssh/sshd_config
# Set Port 1182
sudo sshd -t
sudo systemctl restart ssh
```

Always keep an open session when changing ports.

---

# 46. Host Key Verification Failed

## Symptoms

```txt
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
```

## Cause

* VPS reinstalled
* IP reassigned to different server
* Man-in-the-middle attack (investigate if unexpected)

## Fix

```bash
ssh-keygen -R YOUR_PUBLIC_IP
ssh-keygen -R "[YOUR_PUBLIC_IP]:1182"
ssh vps-prod
# Accept new fingerprint after verifying server identity
```

---

# 47. Connection Timed Out

## Symptoms

```txt
ssh: connect to host X port 1182: Connection timed out
```

## Diagnosis

```bash
# Port reachable?
nc -zv YOUR_PUBLIC_IP 1182

# Server online?
ping YOUR_PUBLIC_IP

# SSH running on server? (via console)
sudo systemctl status ssh
sudo ss -tlnp | grep sshd
```

## Common Causes

* UFW blocking port
* wrong IP or port
* SSH service stopped
* cloud provider firewall blocking port
* home network blocking outbound custom ports

## Fix

```bash
# On server (console)
sudo ufw allow 1182/tcp
sudo systemctl start ssh
sudo systemctl status ssh
```

---

# 48. DNS Issues

## Symptoms

```txt
Could not resolve hostname
```

## Diagnosis

```bash
nslookup your-vps.example.com
dig your-vps.example.com
ssh -vvv vps-prod
```

## Fix

Use IP in SSH config until DNS propagates:

```txt
Host vps-prod
    HostName YOUR_PUBLIC_IP
```

Or fix DNS A record in Cloudflare:

```txt
Type: A
Name: vps (or @)
Content: YOUR_PUBLIC_IP
Proxy: DNS only (grey cloud)
```

Note: SSH connects by IP or direct DNS — never through Cloudflare HTTP proxy.

---

# 49. Container And Docker SSH Issues

## Wrong Approach

```txt
Container restart loop
↓
ssh into container to fix
↓
Changes lost on restart
```

## Correct Approach

```bash
ssh vps-prod
cd /var/www/myapp
docker compose logs backend
docker compose ps
docker compose up -d backend
```

## Debug Container (Not SSH)

```bash
docker compose exec backend sh
docker compose logs -f backend
```

## Container Restart Loop Checklist

```bash
docker compose ps
docker compose logs --tail=100 backend
docker inspect myapp-backend-1 | grep -A5 RestartCount
```

Fix root cause in image/config, redeploy — do not patch running containers.

✓ Good:

* SSH to VPS host
* `docker compose logs` and `exec` for debugging

✗ Avoid:

* Running sshd in app containers
* Permanent fixes via `docker exec`

---

# 50. Service Connectivity Issues

## SSH Works But App Unreachable

```bash
ssh vps-prod
docker compose ps
curl -I http://localhost
sudo ufw status
docker compose logs nginx
```

## Verify Nginx → Backend

```bash
docker compose exec nginx curl -I http://backend:5000/health
```

## Verify Backend → Database

```bash
docker compose exec backend sh -c 'nc -zv postgres 5432'
```

## Full Stack Check

```txt
SSH OK?
↓
Docker containers running?
↓
Nginx config valid?
↓
Backend health endpoint?
↓
Database reachable?
↓
Cloudflare DNS correct?
```

---

# 51. Remove SSH Keys On Mac

## Remove Specific Key

```bash
ssh-add -d ~/.ssh/vps_ed25519
rm ~/.ssh/vps_ed25519
rm ~/.ssh/vps_ed25519.pub
```

## Remove Key From Agent

```bash
ssh-add -D
```

## Remove Entire .ssh Directory (Nuclear)

```bash
rm -rf ~/.ssh
```

Warning: removes all keys, config, and known_hosts.

## Remove From macOS Keychain

```bash
ssh-add -d ~/.ssh/vps_ed25519
# Keychain Access → search "ssh" → delete related entries
```

---

# 52. Remove SSH Keys On Linux

## Remove Specific Key

```bash
ssh-add -d ~/.ssh/vps_ed25519
rm ~/.ssh/vps_ed25519 ~/.ssh/vps_ed25519.pub
```

## Remove From Server authorized_keys

```bash
ssh vps-prod
nano ~/.ssh/authorized_keys
# Delete the line containing the old public key
```

## Remove Entire Client .ssh

```bash
rm -rf ~/.ssh
```

---

# 53. Remove OpenSSH Client In Docker

Remove from Dockerfile:

```dockerfile
# Remove this line:
# RUN apk add --no-cache openssh-client
```

Rebuild image:

```bash
docker compose build --no-cache deploy
docker compose up -d deploy
```

Verify client absent:

```bash
docker compose exec deploy which ssh
```

Expected: no output.

---

# 54. Uninstall OpenSSH Server On Linux

Warning: this removes remote access. Only do this if another access method exists.

## Stop SSH Service

```bash
sudo systemctl stop ssh
```

## Disable On Boot

```bash
sudo systemctl disable ssh
```

## Remove Package

```bash
sudo apt purge openssh-server -y
sudo apt autoremove -y
sudo apt autoclean
```

## Verify Removal

```bash
systemctl status ssh
which sshd
```

Expected:

```txt
Unit ssh.service could not be found
```

---

# 55. Cache And Leftover File Cleanup

## Client Leftover Files

```bash
rm -f ~/.ssh/control-*
rm -f ~/.ssh/known_hosts.old
rm -f ~/ssh-backup-*.tar.gz
```

## Server Leftover Files

```bash
sudo rm -f /etc/ssh/sshd_config.backup.*
rm -f ~/authorized_keys.backup.*
```

## Remove Stale Host Keys (Client)

```bash
ssh-keygen -R OLD_SERVER_IP
```

## Package Cache (Linux)

```bash
sudo apt autoremove -y
sudo apt autoclean
```

---

# 56. Verification After Removal

## Client — Key Removed

```bash
ls ~/.ssh/vps_ed25519
ssh-add -l
```

Expected: file not found / key not listed.

## Client — Connection Fails With Removed Key

```bash
ssh -i ~/.ssh/vps_ed25519 vps-prod
```

Expected: key file error or permission denied.

## Server — OpenSSH Server Removed

```bash
systemctl status ssh
dpkg -l | grep openssh-server
ss -tlnp | grep sshd
```

Expected: service not found, package not installed, no sshd listening.

## Docker — Client Removed From Container

```bash
docker compose exec deploy which ssh
```

Expected: no output.

---

# 57. Recommended Production Workflow

```txt
1. Generate separate Ed25519 keys (GitHub, VPS, CI/CD)
2. Harden VPS SSH (custom port, key-only, non-root user)
3. Configure ~/.ssh/config aliases
4. Enable UFW + Fail2Ban
5. Backup keys and authorized_keys (encrypted)
6. Deploy via GitHub Actions → SSH → docker compose
7. Monitor auth.log
8. Rotate keys on schedule or after personnel changes
```

Daily operations:

```bash
ssh vps-prod
cd /var/www/myapp
docker compose ps
docker compose logs -f --tail=50
```

---

# 58. Modern Workflow

```txt
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub (build + push images)
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

Key principles:

* immutable Docker images
* SSH only to VPS host
* automated deploys via CI/CD
* no manual server file edits
* rollback via previous image tag

---

# 59. Real-World Workflow

Example: deploy a full-stack app to Hetzner VPS.

## One-Time Setup

```bash
# Local
ssh-keygen -t ed25519 -f ~/.ssh/vps_ed25519 -C "vps-prod"
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "github"

# Add GitHub key → GitHub Settings → SSH Keys
# Add VPS key → Hetzner panel or ssh-copy-id

# Configure alias
nano ~/.ssh/config
```

## VPS Hardening

```bash
ssh root@YOUR_PUBLIC_IP
adduser mosabbir && usermod -aG sudo mosabbir
# Copy keys, harden sshd, UFW, Fail2Ban
```

## Deploy Stack

```bash
ssh vps-prod
mkdir -p /var/www/myapp && cd /var/www/myapp
# Copy docker-compose.prod.yml, .env, nginx config
docker compose up -d
```

## CI/CD (Every Push To main)

```txt
GitHub Actions builds images
↓
Pushes to Docker Hub
↓
SSH to vps-prod
↓
docker compose pull && up -d
↓
Health check passes
```

## Rollback

```bash
ssh vps-prod
cd /var/www/myapp
export TAG=v1.2.3
docker compose up -d
```

---

# 60. Final Production Checklist

## Keys And Client

✓ Ed25519 keys generated with separate files per service
✓ Passphrase set on local keys
✓ `~/.ssh/config` aliases configured
✓ `IdentitiesOnly yes` set per host
✓ Encrypted backup of private keys exists

✗ No shared team keys
✗ No keys in Git repos or plaintext cloud sync

## Server

✓ Custom SSH port configured
✓ Root login disabled
✓ Password authentication disabled
✓ Non-root user with sudo
✓ UFW allows only required ports
✓ Fail2Ban active
✓ `sudo sshd -t` passes

✗ Port 22 open publicly
✗ Password login enabled

## Docker Production

✓ SSH to VPS host only
✓ Deploy via docker compose pull/up
✓ GitHub Actions uses dedicated deploy key
✓ Rollback tag strategy defined

✗ SSH daemon in app containers
✗ Manual file edits inside containers

## Monitoring And Recovery

✓ auth.log monitored
✓ Cloud console access verified
✓ authorized_keys and sshd_config backed up
✓ Recovery procedure documented

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
VPS (SSH)
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

## SSH Quick Commands Cheat Sheet

```bash
# Connect
ssh vps-prod

# Connect with options
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP

# Copy key to server
ssh-copy-id -i ~/.ssh/vps_ed25519.pub -p 1182 mosabbir@YOUR_PUBLIC_IP

# Test GitHub
ssh -T git@github.com

# Debug
ssh -vvv vps-prod

# Tunnel
ssh -L 5432:localhost:5432 vps-prod

# SCP
scp -P 1182 file.txt vps-prod:/home/mosabbir/

# Server status
sudo systemctl status ssh
sudo sshd -t
sudo tail -f /var/log/auth.log

# Remove stale host key
ssh-keygen -R YOUR_PUBLIC_IP
```
