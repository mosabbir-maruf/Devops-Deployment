# Useful Commands Cheat Sheet

## SSH Commands

### Login VPS

```bash
ssh user@SERVER_IP
```

---

### Login Using Custom Port

```bash
ssh -p 1182 user@SERVER_IP
```

---

### Generate SSH Key

```bash
ssh-keygen -t ed25519
```

---

### View Public SSH Key

```bash
cat ~/.ssh/id_ed25519.pub
```

---

### Restart SSH

```bash
sudo systemctl restart ssh
```

---

### Check SSH Status

```bash
sudo systemctl status ssh
```

---

# Linux Basics

### Show Current Directory

```bash
pwd
```

---

### List Files

```bash
ls
```

---

### List Hidden Files

```bash
ls -la
```

---

### Change Directory

```bash
cd folder-name
```

---

### Go Back One Directory

```bash
cd ..
```

---

### Go Home Directory

```bash
cd ~
```

---

### Create Folder

```bash
mkdir folder-name
```

---

### Create Nested Folder

```bash
mkdir -p folder/subfolder
```

---

### Create File

```bash
touch file.txt
```

---

### Remove File

```bash
rm file.txt
```

---

### Remove Folder

```bash
rm -r folder-name
```

---

### Copy File

```bash
cp source.txt destination.txt
```

---

### Move/Rename File

```bash
mv old.txt new.txt
```

---

### Open Nano Editor

```bash
nano file.txt
```

---

### Show File Content

```bash
cat file.txt
```

---

# System Monitoring

### Check RAM Usage

```bash
free -h
```

---

### Check Disk Usage

```bash
df -h
```

---

### Check CPU Usage

```bash
htop
```

---

### Show Running Processes

```bash
ps aux
```

---

### Show Open Ports

```bash
sudo ss -tulpn
```

---

### Show Logged-in Users

```bash
who
```

---

### Check Server Uptime

```bash
uptime
```

---

# Package Management

### Update Packages

```bash
sudo apt update
```

---

### Upgrade Packages

```bash
sudo apt upgrade -y
```

---

### Install Package

```bash
sudo apt install package-name
```

---

### Remove Package

```bash
sudo apt remove package-name
```

---

# Firewall (UFW)

### Enable Firewall

```bash
sudo ufw enable
```

---

### Check Firewall Status

```bash
sudo ufw status
```

---

### Allow Port

```bash
sudo ufw allow 3000/tcp
```

---

### Deny Port

```bash
sudo ufw deny 3000/tcp
```

---

# Fail2Ban

### Check Fail2Ban Status

```bash
sudo fail2ban-client status
```

---

### Check SSH Jail

```bash
sudo fail2ban-client status sshd
```

---

# Docker Commands

### Check Docker Version

```bash
docker --version
```

---

### Show Running Containers

```bash
docker ps
```

---

### Show All Containers

```bash
docker ps -a
```

---

### Show Docker Images

```bash
docker images
```

---

### Pull Docker Image

```bash
docker pull nginx
```

---

### Run Container

```bash
docker run nginx
```

---

### Run Container In Background

```bash
docker run -d nginx
```

---

### Stop Container

```bash
docker stop CONTAINER_ID
```

---

### Start Container

```bash
docker start CONTAINER_ID
```

---

### Restart Container

```bash
docker restart CONTAINER_ID
```

---

### Remove Container

```bash
docker rm CONTAINER_ID
```

---

### Remove Image

```bash
docker rmi IMAGE_ID
```

---

### Show Container Logs

```bash
docker logs CONTAINER_ID
```

---

### Live Logs

```bash
docker logs -f CONTAINER_ID
```

---

### Container Resource Usage

```bash
docker stats
```

---

### Clean Unused Docker Resources

```bash
docker system prune -a
```

---

# Docker Compose

### Start Compose

```bash
docker compose up -d
```

---

### Stop Compose

```bash
docker compose down
```

---

### Restart Compose

```bash
docker compose restart
```

---

### Rebuild Compose

```bash
docker compose up -d --build
```

---

### Compose Logs

```bash
docker compose logs
```

---

# PM2 Commands

### Install PM2

```bash
npm install -g pm2
```

---

### Start App

```bash
pm2 start index.js
```

---

### Show Running Apps

```bash
pm2 list
```

---

### Restart App

```bash
pm2 restart APP_NAME
```

---

### Stop App

```bash
pm2 stop APP_NAME
```

---

### Delete App

```bash
pm2 delete APP_NAME
```

---

### PM2 Monitoring

```bash
pm2 monit
```

---

### PM2 Logs

```bash
pm2 logs
```

---

### Save PM2 Processes

```bash
pm2 save
```

---

# Git Commands

### Initialize Git

```bash
git init
```

---

### Check Git Status

```bash
git status
```

---

### Add Files

```bash
git add .
```

---

### Commit Changes

```bash
git commit -m "message"
```

---

### Push Code

```bash
git push
```

---

### Pull Changes

```bash
git pull
```

---

### Clone Repository

```bash
git clone REPOSITORY_URL
```

---

### Show Branches

```bash
git branch
```

---

### Create Branch

```bash
git checkout -b branch-name
```

---

### View Commit Logs

```bash
git log --oneline
```

---

# Node.js & npm

### Check Node Version

```bash
node -v
```

---

### Check npm Version

```bash
npm -v
```

---

### Install Dependencies

```bash
npm install
```

---

### Install Package

```bash
npm install package-name
```

---

### Remove Package

```bash
npm uninstall package-name
```

---

### Run Build

```bash
npm run build
```

---

### Start Application

```bash
npm start
```

---

### Run Development Server

```bash
npm run dev
```

---

### Security Audit

```bash
npm audit
```

---

### Fix Vulnerabilities

```bash
npm audit fix
```

---

# MongoDB Commands

### Open Mongo Shell

```bash
mongosh
```

---

### Show Databases

```javascript
show dbs
```

---

### Use Database

```javascript
use mydatabase
```

---

### Show Collections

```javascript
show collections
```

---

### Restart MongoDB

```bash
sudo systemctl restart mongod
```

---

### Check MongoDB Status

```bash
sudo systemctl status mongod
```

---

### MongoDB Logs

```bash
sudo journalctl -u mongod
```

---

# PostgreSQL Commands

### Open PostgreSQL Shell

```bash
sudo -u postgres psql
```

---

### Show Databases

```sql
\l
```

---

### Show Tables

```sql
\dt
```

---

### Connect Database

```sql
\c mydatabase
```

---

### Restart PostgreSQL

```bash
sudo systemctl restart postgresql
```

---

### PostgreSQL Logs

```bash
sudo tail -f /var/log/postgresql/postgresql-*.log
```

---

# Redis Commands

### Open Redis CLI

```bash
redis-cli
```

---

### Set Value

```bash
SET key value
```

---

### Get Value

```bash
GET key
```

---

### Restart Redis

```bash
sudo systemctl restart redis-server
```

---

### Redis Memory Usage

```bash
redis-cli INFO memory
```

---

# Nginx Commands

### Check Nginx Status

```bash
sudo systemctl status nginx
```

---

### Restart Nginx

```bash
sudo systemctl restart nginx
```

---

### Reload Nginx

```bash
sudo systemctl reload nginx
```

---

### Test Nginx Config

```bash
sudo nginx -t
```

---

### Access Logs

```bash
sudo tail -f /var/log/nginx/access.log
```

---

### Error Logs

```bash
sudo tail -f /var/log/nginx/error.log
```

---

# Domain & DNS

### Check DNS

```bash
nslookup example.com
```

---

### DNS Information

```bash
dig example.com
```

---

### Ping Domain

```bash
ping example.com
```

---

### Check Public IP

```bash
curl ifconfig.me
```

---

# SSL / HTTPS

### Install Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

---

### Generate SSL

```bash
sudo certbot --nginx -d example.com
```

---

### Test SSL Renewal

```bash
sudo certbot renew --dry-run
```

---

# Backups

### Create tar.gz Backup

```bash
tar -czvf backup.tar.gz folder-name
```

---

### Extract Backup

```bash
tar -xzvf backup.tar.gz
```

---

### MongoDB Backup

```bash
mongodump --out backup-folder
```

---

### PostgreSQL Backup

```bash
pg_dump mydatabase > backup.sql
```

---

# Service Management

### Restart Service

```bash
sudo systemctl restart service-name
```

---

### Start Service

```bash
sudo systemctl start service-name
```

---

### Stop Service

```bash
sudo systemctl stop service-name
```

---

### Check Service Status

```bash
sudo systemctl status service-name
```

---

# Server Restart & Shutdown

### Reboot Server

```bash
reboot
```

---

### Shutdown Server

```bash
shutdown now
```

---

# Useful Production Workflow

1. Check logs first
2. Monitor RAM/CPU
3. Check Docker containers
4. Check database status
5. Check firewall/ports
6. Verify domain/DNS
7. Restart services carefully
8. Backup before major changes