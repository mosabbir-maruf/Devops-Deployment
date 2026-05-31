# Backups & VPS Snapshots

## Table Of Contents

### Fundamentals

1. [Why Backups Matter](#1-why-backups-matter)
2. [Backup Strategy Overview](#2-backup-strategy-overview)
3. [Production Architecture](#3-production-architecture)
4. [What To Backup](#4-what-to-backup)
5. [Backup Types](#5-backup-types)

### VPS Snapshots

6. [VPS Provider Snapshots](#6-vps-provider-snapshots)
7. [When To Create Snapshots](#7-when-to-create-snapshots)
8. [Snapshot Limitations](#8-snapshot-limitations)

### Database Backups (Docker)

9. [PostgreSQL Backup](#9-postgresql-backup)
10. [PostgreSQL Restore](#10-postgresql-restore)
11. [MongoDB Backup](#11-mongodb-backup)
12. [MongoDB Restore](#12-mongodb-restore)
13. [Redis Backup](#13-redis-backup)
14. [Redis Restore](#14-redis-restore)

### Docker Volume Backups

15. [List Docker Volumes](#15-list-docker-volumes)
16. [Backup Docker Volume](#16-backup-docker-volume)
17. [Restore Docker Volume](#17-restore-docker-volume)

### Application And Config Backups

18. [Backup Application Files](#18-backup-application-files)
19. [Backup Nginx Configs](#19-backup-nginx-configs)
20. [Backup SSL Certificates](#20-backup-ssl-certificates)
21. [Backup Environment Variables](#21-backup-environment-variables)
22. [Backup Docker Compose Files](#22-backup-docker-compose-files)

### Automation

23. [Production Backup Script](#23-production-backup-script)
24. [Schedule With Cron](#24-schedule-with-cron)
25. [Verify Cron Jobs](#25-verify-cron-jobs)
26. [Backup Retention Policy](#26-backup-retention-policy)

### Offsite Storage

27. [Offsite Backup Options](#27-offsite-backup-options)
28. [Upload To S3 / R2 (rclone)](#28-upload-to-s3--r2-rclone)
29. [Download Backup From Offsite](#29-download-backup-from-offsite)

### Restore And Testing

30. [Test Restore Procedure](#30-test-restore-procedure)
31. [Disaster Recovery Workflow](#31-disaster-recovery-workflow)
32. [Rollback After Failed Deployment](#32-rollback-after-failed-deployment)

### Security

33. [Backup Security Rules](#33-backup-security-rules)
34. [Encrypt Sensitive Backups](#34-encrypt-sensitive-backups)
35. [Security Checklist](#35-security-checklist)

### Troubleshooting

36. [Backup Disk Full](#36-backup-disk-full)
37. [Corrupted Backup](#37-corrupted-backup)
38. [Cron Job Not Running](#38-cron-job-not-running)
39. [Restore Failed](#39-restore-failed)

### Cleanup

40. [Remove Old Backups](#40-remove-old-backups)
41. [Remove Backup Scripts And Cron](#41-remove-backup-scripts-and-cron)
42. [Log And Cache Cleanup](#42-log-and-cache-cleanup)
43. [Verification After Cleanup](#43-verification-after-cleanup)

### Production Workflows

44. [Recommended Production Workflow](#44-recommended-production-workflow)
45. [Modern Workflow](#45-modern-workflow)
46. [Real-World Workflow](#46-real-world-workflow)
47. [Final Production Checklist](#47-final-production-checklist)

---

# 1. Why Backups Matter

Without backups, production data loss is permanent.

Recovery scenarios:

* VPS crash or provider outage
* accidental `docker volume rm`
* failed deployment corrupting database
* ransomware or security breach
* database corruption

Rule: **backups are useless until you test a restore.**

---

# 2. Backup Strategy Overview

Use three layers:

```txt
Layer 1: VPS snapshot (full disk, provider-level)
Layer 2: Daily database dumps (PostgreSQL, MongoDB, Redis)
Layer 3: Offsite copy (S3, R2, separate VPS)
```

```txt
Daily   → pg_dump, mongodump, volume tar
Weekly  → full snapshot + offsite upload
Monthly → archive + retention cleanup
```

---

# 3. Production Architecture

```txt
VPS (/var/www/myapp)
├── docker compose (app + DB containers)
├── ~/backups/YYYY-MM-DD/
│   ├── postgres.sql.gz
│   ├── mongodb/
│   ├── redis.rdb
│   ├── volumes.tar.gz
│   └── env.backup (encrypted)
└── cron → backup.sh → rclone → Cloudflare R2 / S3

Provider snapshot (Hetzner / DigitalOcean / Vultr)
```

Never store backups only on the same VPS.

---

# 4. What To Backup

| Target | Priority | Method |
|--------|----------|--------|
| PostgreSQL data | Critical | `pg_dump` via Docker |
| MongoDB data | Critical | `mongodump` via Docker |
| Redis RDB | High | `SAVE` + copy dump.rdb |
| Docker volumes | High | tar via temp container |
| `.env` / secrets | Critical | encrypted copy |
| `docker-compose.yml` | High | git + local tar |
| Nginx configs | High | tar `/etc/nginx` or repo |
| SSL certs | Medium | Let's Encrypt or Cloudflare Origin |
| Application uploads | High | tar volume or S3 sync |

---

# 5. Backup Types

## VPS Snapshot

Full disk image — fastest full recovery. Provider-dependent.

## Logical Database Backup

SQL dump or `mongodump` — portable, smaller, version-specific.

## Docker Volume Backup

Tar archive of named volume — includes uploads, Redis RDB, etc.

## File Backup

`tar.gz` of configs, `.env`, compose files.

---

# 6. VPS Provider Snapshots

Create via provider dashboard or API before major changes.

Examples:

* Hetzner: Server → Snapshots → Create
* DigitalOcean: Droplets → Snapshots
* Vultr: Server → Snapshots
* AWS: AMI from EC2 instance

Document snapshot name and date in your runbook.

---

# 7. When To Create Snapshots

Create snapshot before:

* OS upgrade (`apt upgrade` with kernel changes)
* Docker major version upgrade
* database version migration
* Nginx SSL reconfiguration
* first production deployment

---

# 8. Snapshot Limitations

✗ Snapshots are not a substitute for logical DB backups
✗ Snapshots may not restore across regions/providers
✗ Snapshots cost storage fees
✗ Point-in-time recovery requires WAL/binlog (advanced)

Always keep daily `pg_dump` / `mongodump` in addition to snapshots.

---

# 9. PostgreSQL Backup

```bash
cd /var/www/myapp
mkdir -p ~/backups/$(date +%F)

docker compose exec -T postgres pg_dump -U admin myapp \
  | gzip > ~/backups/$(date +%F)/postgres-myapp.sql.gz
```

All databases:

```bash
docker compose exec -T postgres pg_dumpall -U admin \
  | gzip > ~/backups/$(date +%F)/postgres-all.sql.gz
```

Verify:

```bash
gzip -t ~/backups/$(date +%F)/postgres-myapp.sql.gz
ls -lh ~/backups/$(date +%F)/postgres-myapp.sql.gz
```

---

# 10. PostgreSQL Restore

```bash
# Stop app to prevent writes
docker compose stop backend

# Drop and recreate (DESTRUCTIVE — test on staging first)
docker compose exec -T postgres psql -U admin -c "DROP DATABASE IF EXISTS myapp;"
docker compose exec -T postgres psql -U admin -c "CREATE DATABASE myapp;"

gunzip -c ~/backups/2026-06-01/postgres-myapp.sql.gz \
  | docker compose exec -T postgres psql -U admin -d myapp

docker compose start backend
docker compose logs backend --tail=20
```

---

# 11. MongoDB Backup

```bash
mkdir -p ~/backups/$(date +%F)

docker compose exec mongodb mongodump \
  --username=admin --password=PASSWORD --authenticationDatabase=admin \
  --out=/tmp/mongodump

docker compose cp mongodb:/tmp/mongodump ~/backups/$(date +%F)/mongodb
tar -czvf ~/backups/$(date +%F)/mongodb.tar.gz -C ~/backups/$(date +%F) mongodb
```

Single command alternative:

```bash
docker compose exec mongodb mongodump \
  --uri="mongodb://admin:PASSWORD@localhost:27017/?authSource=admin" \
  --archive=/tmp/mongo.archive --gzip

docker compose cp mongodb:/tmp/mongo.archive ~/backups/$(date +%F)/mongo.archive.gz
```

---

# 12. MongoDB Restore

```bash
docker compose stop backend

docker compose cp ~/backups/2026-06-01/mongo.archive.gz mongodb:/tmp/
docker compose exec mongodb mongorestore \
  --uri="mongodb://admin:PASSWORD@localhost:27017/?authSource=admin" \
  --archive=/tmp/mongo.archive.gz --gzip --drop

docker compose start backend
```

---

# 13. Redis Backup

```bash
mkdir -p ~/backups/$(date +%F)

# Trigger RDB save
docker compose exec redis redis-cli -a PASSWORD BGSAVE
sleep 5

docker compose cp redis:/data/dump.rdb ~/backups/$(date +%F)/redis.rdb
```

Verify:

```bash
file ~/backups/$(date +%F)/redis.rdb
ls -lh ~/backups/$(date +%F)/redis.rdb
```

---

# 14. Redis Restore

```bash
docker compose stop backend redis

docker compose cp ~/backups/2026-06-01/redis.rdb redis:/data/dump.rdb
docker compose exec redis chown redis:redis /data/dump.rdb

docker compose start redis backend
docker compose exec redis redis-cli -a PASSWORD ping
```

---

# 15. List Docker Volumes

```bash
docker volume ls
docker volume inspect myapp_postgres_data
docker system df -v
```

---

# 16. Backup Docker Volume

```bash
mkdir -p ~/backups/$(date +%F)

docker run --rm \
  -v myapp_postgres_data:/volume:ro \
  -v ~/backups/$(date +%F):/backup \
  alpine tar czf /backup/postgres-volume.tar.gz -C /volume .
```

Multiple volumes:

```bash
for vol in myapp_postgres_data myapp_uploads; do
  docker run --rm \
    -v ${vol}:/volume:ro \
    -v ~/backups/$(date +%F):/backup \
    alpine tar czf /backup/${vol}.tar.gz -C /volume .
done
```

---

# 17. Restore Docker Volume

```bash
docker compose down

docker run --rm \
  -v myapp_postgres_data:/volume \
  -v ~/backups/2026-06-01:/backup \
  alpine sh -c "rm -rf /volume/* && tar xzf /backup/postgres-volume.tar.gz -C /volume"

docker compose up -d
docker compose ps
```

---

# 18. Backup Application Files

```bash
mkdir -p ~/backups/$(date +%F)

tar -czvf ~/backups/$(date +%F)/app-files.tar.gz \
  /var/www/myapp/docker-compose.yml \
  /var/www/myapp/.env \
  /var/www/myapp/nginx/
```

Exclude secrets from git — backup `.env` separately and encrypted.

---

# 19. Backup Nginx Configs

## Docker Nginx (in project)

Included in app-files tar above.

## Host Nginx

```bash
sudo tar -czvf ~/backups/$(date +%F)/nginx-host.tar.gz /etc/nginx
```

---

# 20. Backup SSL Certificates

## Let's Encrypt (host)

```bash
sudo tar -czvf ~/backups/$(date +%F)/letsencrypt.tar.gz /etc/letsencrypt
```

## Cloudflare Origin Certificate

Store in password manager + encrypted backup — not in public git.

---

# 21. Backup Environment Variables

```bash
cp /var/www/myapp/.env ~/backups/$(date +%F)/env.backup
chmod 600 ~/backups/$(date +%F)/env.backup
```

Encrypt:

```bash
gpg -c ~/backups/$(date +%F)/env.backup
rm ~/backups/$(date +%F)/env.backup
# Creates env.backup.gpg
```

Never commit `.env` to GitHub.

---

# 22. Backup Docker Compose Files

Compose files should live in git. Also tar locally:

```bash
tar -czvf ~/backups/$(date +%F)/compose.tar.gz \
  /var/www/myapp/docker-compose.yml \
  /var/www/myapp/docker-compose.prod.yml
```

---

# 23. Production Backup Script

```bash
mkdir -p ~/scripts ~/backups ~/logs
nano ~/scripts/backup.sh
```

```bash
#!/bin/bash
set -euo pipefail

DATE=$(date +%F)
BACKUP_DIR="$HOME/backups/$DATE"
APP_DIR="/var/www/myapp"
LOG="$HOME/logs/backup-$DATE.log"

mkdir -p "$BACKUP_DIR"
cd "$APP_DIR"

echo "=== Backup started $DATE ===" | tee -a "$LOG"

# PostgreSQL
docker compose exec -T postgres pg_dump -U admin myapp \
  | gzip > "$BACKUP_DIR/postgres-myapp.sql.gz"
echo "PostgreSQL done" | tee -a "$LOG"

# MongoDB (if used)
# docker compose exec mongodb mongodump ... (see section 11)

# Redis
docker compose exec redis redis-cli -a "$REDIS_PASSWORD" BGSAVE
sleep 5
docker compose cp redis:/data/dump.rdb "$BACKUP_DIR/redis.rdb"
echo "Redis done" | tee -a "$LOG"

# Configs
cp "$APP_DIR/.env" "$BACKUP_DIR/env.backup"
chmod 600 "$BACKUP_DIR/env.backup"
tar -czf "$BACKUP_DIR/app-config.tar.gz" docker-compose.yml nginx/ 2>/dev/null || true
echo "Config done" | tee -a "$LOG"

# Retention: delete backups older than 14 days
find "$HOME/backups" -maxdepth 1 -type d -mtime +14 -exec rm -rf {} \;

# Optional offsite
# rclone copy "$BACKUP_DIR" r2:mybucket/backups/$DATE

echo "=== Backup finished $DATE ===" | tee -a "$LOG"
```

```bash
chmod +x ~/scripts/backup.sh
~/scripts/backup.sh
```

---

# 24. Schedule With Cron

```bash
crontab -e
```

```txt
# Daily backup at 2 AM
0 2 * * * /home/mosabbir/scripts/backup.sh >> /home/mosabbir/logs/backup-cron.log 2>&1
```

---

# 25. Verify Cron Jobs

```bash
crontab -l
sudo systemctl status cron
grep CRON /var/log/syslog | tail -10
ls -lt ~/backups/ | head -5
```

---

# 26. Backup Retention Policy

```txt
Daily backups  → keep 14 days locally
Weekly archive → keep 8 weeks offsite
Monthly        → keep 6 months offsite
Snapshots      → keep last 3 before major changes
```

```bash
find ~/backups -maxdepth 1 -type d -mtime +14 -exec rm -rf {} \;
```

---

# 27. Offsite Backup Options

* Cloudflare R2 (S3-compatible, no egress fees)
* AWS S3
* Backblaze B2
* Separate VPS via `rsync`
* Encrypted external drive (manual)

Rule: **3-2-1** — 3 copies, 2 media types, 1 offsite.

---

# 28. Upload To S3 / R2 (rclone)

```bash
sudo apt install -y rclone
rclone config
# Create remote: r2 or s3

rclone copy ~/backups/$(date +%F)/ r2:mybucket/backups/$(date +%F)/ -v
rclone ls r2:mybucket/backups/
```

Add to backup script after local backup completes.

---

# 29. Download Backup From Offsite

```bash
rclone copy r2:mybucket/backups/2026-06-01/ ~/restore/2026-06-01/ -v
ls ~/restore/2026-06-01/
```

Then follow restore sections 10–14.

---

# 30. Test Restore Procedure

Monthly on staging VPS:

```bash
# 1. Copy production backup to staging
scp vps-prod:~/backups/latest/postgres-myapp.sql.gz ./

# 2. Restore to staging DB
gunzip -c postgres-myapp.sql.gz | docker compose exec -T postgres psql -U admin -d myapp_staging

# 3. Verify row counts
docker compose exec postgres psql -U admin -d myapp_staging -c "SELECT count(*) FROM users;"

# 4. Start app and smoke test
curl -f http://localhost:5000/health
```

Document results in runbook.

---

# 31. Disaster Recovery Workflow

```txt
1. Assess damage (logs, provider status)
2. Restore VPS snapshot OR rebuild VPS from scratch
3. Install Docker + clone compose repo
4. Restore PostgreSQL / MongoDB from latest dump
5. Restore Redis RDB if needed
6. Restore .env from encrypted backup
7. docker compose up -d
8. Verify health endpoints + DNS
9. Notify users if data loss occurred
```

---

# 32. Rollback After Failed Deployment

```bash
cd /var/www/myapp

# Rollback Docker image tag in compose
nano docker-compose.yml
# image: myuser/myapp:previous-tag

docker compose pull
docker compose up -d

# If DB migration failed — restore DB from pre-deploy backup
gunzip -c ~/backups/pre-deploy/postgres-myapp.sql.gz | \
  docker compose exec -T postgres psql -U admin -d myapp
```

Always snapshot or backup before deploying.

---

# 33. Backup Security Rules

✓ Good:

* encrypt `.env` backups
* offsite storage with IAM/R2 tokens
* chmod 600 on backup files
* separate backup credentials from app credentials

✗ Avoid:

* public S3 buckets
* committing secrets to git
* storing only on same VPS

---

# 34. Encrypt Sensitive Backups

```bash
# GPG encrypt
gpg -c ~/backups/$(date +%F)/env.backup

# Decrypt
gpg ~/backups/2026-06-01/env.backup.gpg
```

```bash
# OpenSSL encrypt entire backup folder
tar -czf - ~/backups/2026-06-01 | openssl enc -aes-256-cbc -salt -out backup-2026-06-01.tar.gz.enc
```

---

# 35. Security Checklist

✓ Backups encrypted at rest (offsite)
✓ `.env` never in public git
✓ backup bucket private
✓ restore tested on staging
✓ pre-deploy backup mandatory

---

# 36. Backup Disk Full

```bash
df -h
du -sh ~/backups
find ~/backups -maxdepth 1 -type d | sort
```

Fix:

```bash
find ~/backups -maxdepth 1 -type d -mtime +14 -exec rm -rf {} \;
rclone move old backups offsite then delete local
```

---

# 37. Corrupted Backup

Symptoms: `gzip -t` fails, restore errors.

Prevention:

```bash
gzip -t ~/backups/$(date +%F)/postgres-myapp.sql.gz
echo $?  # 0 = OK
```

Always verify immediately after backup script runs.

---

# 38. Cron Job Not Running

```bash
crontab -l
sudo systemctl status cron
grep backup /var/log/syslog
~/scripts/backup.sh  # run manually to see errors
```

Common issues: wrong path, missing execute permission, `.env` not loaded in cron.

---

# 39. Restore Failed

```bash
# Check dump integrity
gzip -t backup.sql.gz
file redis.rdb

# Check container logs
docker compose logs postgres --tail=50

# Check permissions
docker compose exec postgres ls -la /var/lib/postgresql/data
```

Restore on staging first — never experiment on production.

---

# 40. Remove Old Backups

```bash
# Delete backups older than 14 days
find ~/backups -maxdepth 1 -type d -mtime +14 -exec rm -rf {} \;

# Delete specific date
rm -rf ~/backups/2026-01-01
```

Verify disk freed:

```bash
df -h
du -sh ~/backups
```

---

# 41. Remove Backup Scripts And Cron

```bash
crontab -e
# Remove backup cron line

rm ~/scripts/backup.sh
rm ~/logs/backup-*.log
```

---

# 42. Log And Cache Cleanup

```bash
rm -f ~/logs/backup-*.log
rm -f /tmp/mongo.archive*
docker compose exec mongodb rm -rf /tmp/mongodump 2>/dev/null
```

---

# 43. Verification After Cleanup

```bash
crontab -l
ls ~/scripts/
df -h
```

---

# 44. Recommended Production Workflow

```txt
1. Create VPS snapshot before first deploy
2. Write backup.sh (PostgreSQL + Redis + .env)
3. Schedule daily cron at 2 AM
4. Configure rclone offsite upload
5. Set 14-day local retention
6. Test restore on staging monthly
7. Snapshot before every major upgrade
8. Document disaster recovery runbook
```

---

# 45. Modern Workflow

```txt
GitHub Actions deploy
  → pre-deploy: ssh backup.sh on VPS
  → deploy: docker compose pull && up -d
  → post-deploy: health check

Daily cron
  → pg_dump + redis.rdb + env
  → rclone → Cloudflare R2

Monthly
  → restore test on staging VPS
```

---

# 46. Real-World Workflow

```bash
# Before deploy
ssh vps-prod '~/scripts/backup.sh'

# Deploy via GitHub Actions
# ...

# Verify backup ran last night
ssh vps-prod 'ls -lt ~/backups/ | head -3'

# Monthly restore test on staging
gunzip -c postgres-myapp.sql.gz | docker compose exec -T postgres psql -U admin -d myapp_test
```

---

# 47. Final Production Checklist

✓ Daily automated DB backups
✓ Offsite copy configured
✓ Retention policy enforced
✓ Restore tested monthly
✓ Pre-deploy backup mandatory
✓ VPS snapshot before major changes
✓ `.env` encrypted in backups
✓ backup success monitored (see `14-server-monitoring.md`)

---

## Backup Quick Commands

```bash
# PostgreSQL
docker compose exec -T postgres pg_dump -U admin myapp | gzip > ~/backups/$(date +%F)/db.sql.gz

# Redis
docker compose exec redis redis-cli -a PASSWORD BGSAVE && sleep 5
docker compose cp redis:/data/dump.rdb ~/backups/$(date +%F)/

# Volume
docker run --rm -v myapp_postgres_data:/v:ro -v ~/backups:/b alpine tar czf /b/vol.tar.gz -C /v .

# Verify
gzip -t ~/backups/$(date +%F)/db.sql.gz

# Offsite
rclone copy ~/backups/$(date +%F)/ r2:bucket/backups/$(date +%F)/

# Retention
find ~/backups -maxdepth 1 -type d -mtime +14 -exec rm -rf {} \;
```
