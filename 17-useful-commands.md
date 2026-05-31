# Useful Commands Cheat Sheet

Production-focused command reference for Mac (dev) and Linux VPS (production). Docker-first stack: Docker Compose, PostgreSQL, Redis, MongoDB, Nginx, Cloudflare.

See dedicated guides for full workflows: `02-ssh-guide.md`, `03-linux-basics.md`, `04-docker.md`, `10-project-deployment.md`.

## Table Of Contents

### SSH

1. [SSH Login And Keys](#1-ssh-login-and-keys)
2. [SSH Config And Tunneling](#2-ssh-config-and-tunneling)
3. [SSH Service Management](#3-ssh-service-management)

### Linux Basics

4. [Navigation And Files](#4-navigation-and-files)
5. [File Permissions](#5-file-permissions)
6. [Search And Text Processing](#6-search-and-text-processing)

### System Monitoring

7. [CPU, RAM, Disk](#7-cpu-ram-disk)
8. [Processes And Ports](#8-processes-and-ports)
9. [Logs](#9-logs)

### Package Management

10. [apt (Linux VPS)](#10-apt-linux-vps)
11. [Homebrew (Mac)](#11-homebrew-mac)

### Firewall And Security

12. [UFW Firewall](#12-ufw-firewall)
13. [Fail2Ban](#13-fail2ban)

### Docker

14. [Docker Basics](#14-docker-basics)
15. [Docker Images And Containers](#15-docker-images-and-containers)
16. [Docker Logs And Stats](#16-docker-logs-and-stats)
17. [Docker Cleanup](#17-docker-cleanup)

### Docker Compose

18. [Compose Lifecycle](#18-compose-lifecycle)
19. [Compose Logs And Debug](#19-compose-logs-and-debug)

### Git And GitHub

20. [Git Essentials](#20-git-essentials)
21. [Git Branches](#21-git-branches)

### Node.js And npm (Dev)

22. [Node.js Version And Packages](#22-nodejs-version-and-packages)
23. [npm Scripts And Audit](#23-npm-scripts-and-audit)

### PostgreSQL (Docker)

24. [PostgreSQL CLI](#24-postgresql-cli)
25. [PostgreSQL Backup](#25-postgresql-backup)

### MongoDB (Docker)

26. [MongoDB Shell](#26-mongodb-shell)
27. [MongoDB Backup](#27-mongodb-backup)

### Redis (Docker)

28. [Redis CLI](#28-redis-cli)
29. [Redis Backup](#29-redis-backup)

### Nginx

30. [Nginx Service](#30-nginx-service)
31. [Nginx Logs](#31-nginx-logs)

### Domain, DNS, SSL

32. [DNS Lookup](#32-dns-lookup)
33. [SSL And HTTPS](#33-ssl-and-https)
34. [Cloudflare Quick Checks](#34-cloudflare-quick-checks)

### Backups

35. [Archive Commands](#35-archive-commands)
36. [Database Dumps](#36-database-dumps)

### Service Management

37. [systemctl Commands](#37-systemctl-commands)

### Server Control

38. [Reboot And Shutdown](#38-reboot-and-shutdown)

### Production Quick Workflows

39. [Daily VPS Check](#39-daily-vps-check)
40. [Deploy Commands](#40-deploy-commands)
41. [Emergency Fix Commands](#41-emergency-fix-commands)
42. [Legacy PM2 (Avoid In Production)](#42-legacy-pm2-avoid-in-production)

### Reference

43. [Port Reference](#43-port-reference)
44. [File Path Reference](#44-file-path-reference)
45. [Final Production Checklist](#45-final-production-checklist)

---

# 1. SSH Login And Keys

```bash
# Login
ssh user@SERVER_IP
ssh -p 1182 mosabbir@SERVER_IP
ssh vps-prod                    # using ~/.ssh/config alias

# Generate key (Mac)
ssh-keygen -t ed25519 -C "your@email.com"

# View public key
cat ~/.ssh/id_ed25519.pub

# Copy key to VPS
ssh-copy-id -p 1182 mosabbir@SERVER_IP
```

---

# 2. SSH Config And Tunneling

`~/.ssh/config`:

```txt
Host vps-prod
  HostName SERVER_IP
  User mosabbir
  Port 1182
  IdentityFile ~/.ssh/id_ed25519
```

Tunnel (Netdata, private dashboards):

```bash
ssh -L 19999:127.0.0.1:19999 vps-prod
```

---

# 3. SSH Service Management

```bash
sudo systemctl status ssh
sudo systemctl restart ssh
sudo journalctl -u ssh --since "1 hour ago"
sudo tail -f /var/log/auth.log
```

---

# 4. Navigation And Files

```bash
pwd
ls -la
cd /var/www/myapp
cd ~
mkdir -p folder/subfolder
touch file.txt
cp source.txt dest.txt
mv old.txt new.txt
rm file.txt
rm -rf folder
nano file.txt
cat file.txt
less file.txt
head -20 file.txt
tail -20 file.txt
```

---

# 5. File Permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 600 ~/.ssh/authorized_keys
chmod 600 .env
chown -R mosabbir:mosabbir /var/www/myapp
ls -la
```

---

# 6. Search And Text Processing

```bash
grep -r "ERROR" /var/log/
grep -i error docker-compose.log
find /var/www -name "*.env"
du -sh *
sort file.txt
wc -l file.txt
```

---

# 7. CPU, RAM, Disk

```bash
free -h
htop
top -bn1 | head -20
df -h
df -i
du -sh /var/lib/docker
du -h --max-depth=1 /var | sort -hr | head -10
uptime
```

---

# 8. Processes And Ports

```bash
ps aux
ps aux --sort=-%mem | head -10
sudo ss -tulpn
sudo ss -tlnp | grep -E ':80|:443|:1182'
sudo lsof -i :5000
who
w
```

---

# 9. Logs

```bash
sudo journalctl -xe
sudo journalctl -f
sudo journalctl --since "1 hour ago"
sudo journalctl -u docker -f
sudo journalctl -p err --since today
```

---

# 10. apt (Linux VPS)

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y htop curl git ufw fail2ban
sudo apt remove package-name
sudo apt autoremove -y
apt list --installed | grep docker
```

---

# 11. Homebrew (Mac)

```bash
brew update
brew upgrade
brew install node git htop jq
brew uninstall package
brew list
node -v
```

---

# 12. UFW Firewall

```bash
sudo ufw enable
sudo ufw status verbose
sudo ufw allow 1182/tcp      # SSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 5432/tcp       # block DB ports
sudo ufw reload
```

---

# 13. Fail2Ban

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip YOUR_IP
```

---

# 14. Docker Basics

```bash
docker --version
docker compose version
docker info
docker ps
docker ps -a
docker network ls
docker volume ls
```

---

# 15. Docker Images And Containers

```bash
docker images
docker pull nginx:alpine
docker pull myuser/myapp:latest

docker run -d --name test nginx:alpine
docker stop CONTAINER
docker start CONTAINER
docker restart CONTAINER
docker rm CONTAINER
docker rmi IMAGE

docker inspect CONTAINER
docker exec -it CONTAINER sh
```

---

# 16. Docker Logs And Stats

```bash
docker logs CONTAINER
docker logs -f CONTAINER --tail=100
docker stats
docker stats --no-stream
docker stats backend postgres --no-stream
```

---

# 17. Docker Cleanup

```bash
docker system df
docker image prune -f
docker container prune -f
docker volume prune -f          # unused volumes only
docker system prune -f
docker system prune -a -f       # CAREFUL — removes unused images
```

---

# 18. Compose Lifecycle

```bash
cd /var/www/myapp

docker compose up -d
docker compose down
docker compose restart
docker compose restart backend
docker compose pull
docker compose up -d --build
docker compose up -d --force-recreate
docker compose ps
docker compose ps -a
docker compose config
```

---

# 19. Compose Logs And Debug

```bash
docker compose logs
docker compose logs -f
docker compose logs backend --tail=100 --since 1h
docker compose logs backend postgres nginx
docker compose exec backend sh
docker compose exec backend printenv
```

---

# 20. Git Essentials

```bash
git init
git status
git add .
git commit -m "message"
git push origin main
git pull origin main
git clone https://github.com/user/repo.git
git log --oneline -10
git diff
git stash
git stash pop
```

---

# 21. Git Branches

```bash
git branch
git branch -a
git checkout -b feature/name
git checkout main
git merge feature/name
git push -u origin feature/name
```

---

# 22. Node.js Version And Packages

```bash
node -v
npm -v
nvm use 20                    # Mac, if using nvm
npm install
npm install package-name
npm uninstall package-name
npm ci                        # clean install from lock file
rm -rf node_modules package-lock.json && npm install
```

---

# 23. npm Scripts And Audit

```bash
npm run build
npm start
npm run dev
npm test
npm audit
npm audit fix
```

---

# 24. PostgreSQL CLI

```bash
docker compose exec postgres pg_isready -U admin
docker compose exec postgres psql -U admin -d myapp

# Inside psql:
\l                  # list databases
\c myapp            # connect
\dt                 # list tables
\d users            # describe table
SELECT count(*) FROM pg_stat_activity;
\q                  # quit
```

---

# 25. PostgreSQL Backup

```bash
# Backup
docker compose exec -T postgres pg_dump -U admin myapp \
  | gzip > ~/backups/$(date +%F)/postgres.sql.gz

# Restore
gunzip -c ~/backups/DATE/postgres.sql.gz \
  | docker compose exec -T postgres psql -U admin -d myapp

# Verify
gzip -t ~/backups/DATE/postgres.sql.gz
```

---

# 26. MongoDB Shell

```bash
docker compose exec mongodb mongosh -u admin -p PASSWORD --authenticationDatabase admin

# Inside mongosh:
show dbs
use myapp
show collections
db.users.countDocuments()
db.adminCommand('ping')
```

---

# 27. MongoDB Backup

```bash
docker compose exec mongodb mongodump \
  --uri="mongodb://admin:PASSWORD@localhost:27017/?authSource=admin" \
  --archive=/tmp/mongo.archive --gzip

docker compose cp mongodb:/tmp/mongo.archive ~/backups/$(date +%F)/mongo.archive.gz
```

---

# 28. Redis CLI

```bash
docker compose exec redis redis-cli -a PASSWORD ping
docker compose exec redis redis-cli -a PASSWORD INFO memory
docker compose exec redis redis-cli -a PASSWORD INFO stats
docker compose exec redis redis-cli -a PASSWORD KEYS '*'
docker compose exec redis redis-cli -a PASSWORD GET key
docker compose exec redis redis-cli -a PASSWORD FLUSHALL   # CAREFUL — dev only
```

---

# 29. Redis Backup

```bash
docker compose exec redis redis-cli -a PASSWORD BGSAVE
sleep 5
docker compose cp redis:/data/dump.rdb ~/backups/$(date +%F)/redis.rdb
```

---

# 30. Nginx Service

```bash
# Docker Nginx
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
docker compose restart nginx

# Host Nginx
sudo systemctl status nginx
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl restart nginx
```

---

# 31. Nginx Logs

```bash
# Docker
docker compose logs nginx -f
docker compose logs nginx --tail=50

# Host
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

# 32. DNS Lookup

```bash
dig yourdomain.com +short
dig api.yourdomain.com +short
nslookup yourdomain.com
host yourdomain.com
curl ifconfig.me              # VPS public IP
ping -c 4 yourdomain.com
```

Mac flush DNS:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

---

# 33. SSL And HTTPS

```bash
curl -vI https://yourdomain.com
sudo certbot certificates
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
sudo certbot renew --dry-run
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com </dev/null 2>/dev/null | openssl x509 -noout -dates
```

---

# 34. Cloudflare Quick Checks

```txt
SSL mode     → Full (strict)
A record     → VPS IP (proxied orange cloud)
522 error    → VPS offline or firewall blocking
525/526      → origin SSL cert missing/invalid
```

```bash
curl -I https://yourdomain.com
dig yourdomain.com +short
```

See `12-domain-dns-cloudflare.md`.

---

# 35. Archive Commands

```bash
tar -czvf backup.tar.gz folder/
tar -xzvf backup.tar.gz
tar -tzvf backup.tar.gz       # list contents
zip -r backup.zip folder/
unzip backup.zip
```

---

# 36. Database Dumps

```bash
# PostgreSQL
docker compose exec -T postgres pg_dump -U admin myapp | gzip > db.sql.gz

# MongoDB
docker compose exec mongodb mongodump --out /tmp/dump
docker compose cp mongodb:/tmp/dump ./mongodb-backup

# Redis
docker compose exec redis redis-cli -a PASSWORD BGSAVE
docker compose cp redis:/data/dump.rdb ./redis.rdb

# Docker volume
docker run --rm -v VOLUME:/v:ro -v $(pwd):/b alpine tar czf /b/vol.tar.gz -C /v .
```

See `15-backup-snapshots.md`.

---

# 37. systemctl Commands

```bash
sudo systemctl status SERVICE
sudo systemctl start SERVICE
sudo systemctl stop SERVICE
sudo systemctl restart SERVICE
sudo systemctl enable SERVICE
sudo systemctl disable SERVICE
sudo journalctl -u SERVICE -f
```

Common services: `docker`, `ssh`, `nginx`, `cron`.

---

# 38. Reboot And Shutdown

```bash
sudo reboot
sudo shutdown -h now
sudo shutdown -r +5 "Reboot in 5 minutes"
```

Before reboot — ensure containers restart:

```yaml
# docker-compose.yml
restart: unless-stopped
```

---

# 39. Daily VPS Check

```bash
ssh vps-prod << 'EOF'
cd /var/www/myapp
echo "=== Containers ==="
docker compose ps
echo "=== Health ==="
curl -sf http://localhost:5000/health && echo OK || echo FAIL
echo "=== Disk/RAM ==="
df -h / && free -h
echo "=== Fail2Ban ==="
sudo fail2ban-client status sshd
echo "=== Recent backups ==="
ls -lt ~/backups/ | head -3
EOF
```

---

# 40. Deploy Commands

```bash
# Manual deploy on VPS
cd /var/www/myapp
~/scripts/backup.sh
docker compose pull
docker compose up -d
docker compose ps
curl -f http://localhost:5000/health

# GitHub Actions handles this automatically — see 13-git-github-ci-cd.md
```

---

# 41. Emergency Fix Commands

```bash
# Site down — 60 second diagnosis
ssh vps-prod "cd /var/www/myapp && docker compose ps && docker compose logs backend --tail=20 && df -h /"

# Restart backend
docker compose up -d backend

# Disk full
docker system prune -f && sudo journalctl --vacuum-time=7d

# 502 Bad Gateway
docker compose up -d backend nginx
docker compose logs backend --tail=30

# Rollback image
# Edit docker-compose.yml → previous tag
docker compose pull backend && docker compose up -d backend
```

See `16-troubleshooting.md`.

---

# 42. Legacy PM2 (Avoid In Production)

Use Docker Compose in production. PM2 for legacy host deployments only.

```bash
npm install -g pm2
pm2 start index.js --name myapp
pm2 list
pm2 restart myapp
pm2 logs
pm2 monit
pm2 save
pm2 startup
pm2 delete myapp
```

---

# 43. Port Reference

| Port | Service | Public? |
|------|---------|---------|
| 1182 | SSH (custom) | Yes |
| 80 | HTTP | Yes |
| 443 | HTTPS | Yes |
| 5000 | Node backend | No (Nginx proxy) |
| 5432 | PostgreSQL | No |
| 6379 | Redis | No |
| 27017 | MongoDB | No |
| 19999 | Netdata | No (SSH tunnel) |

---

# 44. File Path Reference

| Path | Purpose |
|------|---------|
| `/var/www/myapp/` | Production app |
| `/var/www/myapp/docker-compose.yml` | Compose config |
| `/var/www/myapp/.env` | Secrets (never git) |
| `~/backups/` | Local backups |
| `~/scripts/backup.sh` | Backup script |
| `~/.ssh/` | SSH keys |
| `/var/log/auth.log` | SSH auth log |
| `/var/log/nginx/` | Nginx logs (host) |
| `/var/lib/docker/` | Docker data |

---

# 45. Final Production Checklist

✓ SSH key auth only (no password)
✓ UFW: 80, 443, SSH port only
✓ Docker Compose for all services
✓ DB ports not public
✓ Daily backup cron running
✓ Health endpoint monitored
✓ Cloudflare Full (strict) SSL
✓ This cheat sheet bookmarked

---

## One-Page Production Cheat Sheet

```bash
# SSH
ssh vps-prod

# Status
cd /var/www/myapp && docker compose ps && curl -sf http://localhost:5000/health

# Logs
docker compose logs backend --tail=50 -f

# Deploy
~/scripts/backup.sh && docker compose pull && docker compose up -d

# Resources
free -h && df -h && docker stats --no-stream

# Security
sudo ufw status && sudo fail2ban-client status sshd

# Backup
docker compose exec -T postgres pg_dump -U admin myapp | gzip > ~/backups/$(date +%F)/db.sql.gz

# Emergency
docker compose up -d backend && docker compose logs backend --tail=20
```
