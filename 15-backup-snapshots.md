# Backups & VPS Snapshots

## Why Backups Matter

Backups are critical for production systems.

Used for recovery after:

- server crashes
- accidental deletion
- hacking
- failed deployments
- corrupted databases
- VPS provider issues

Without backups, production data can be permanently lost.

---

# Recommended Backup Targets

Always backup:

- databases
- Docker volumes
- application files
- environment variables
- Nginx configs
- SSL certificates
- Git repositories

---

# Types Of Backups

## VPS Snapshots

Full VPS image backup.

Includes:

- operating system
- applications
- databases
- files
- Docker containers

---

## Database Backups

Backups for:

- MongoDB
- PostgreSQL
- MySQL
- Redis persistence

---

## File Backups

Backups for:

- source code
- uploads
- configs
- static assets

---

# VPS Snapshots

Most VPS providers support snapshots.

Examples:

- DigitalOcean Snapshots
- Hetzner Snapshots
- Vultr Snapshots
- AWS AMIs

---

# Snapshot Best Practices

Create snapshots:

- before major updates
- before deployments
- before database upgrades
- before security changes

---

# MongoDB Backup

## Create MongoDB Backup

```bash
mongodump --out backup-folder
```

Creates MongoDB backup.

---

## Restore MongoDB Backup

```bash
mongorestore backup-folder
```

Restores MongoDB backup.

---

# PostgreSQL Backup

## Backup PostgreSQL Database

```bash
pg_dump mydatabase > backup.sql
```

Creates PostgreSQL backup.

---

## Restore PostgreSQL Backup

```bash
psql mydatabase < backup.sql
```

Restores PostgreSQL backup.

---

# Backup All PostgreSQL Databases

## Full PostgreSQL Backup

```bash
pg_dumpall > all-databases.sql
```

Backs up all PostgreSQL databases/users.

---

# Redis Backup

Redis persistence file:

```txt
/var/lib/redis/dump.rdb
```

---

## Backup Redis

```bash
cp /var/lib/redis/dump.rdb redis-backup.rdb
```

Creates Redis backup.

---

# Docker Volume Backups

## List Docker Volumes

```bash
docker volume ls
```

Displays Docker volumes.

---

# Backup Docker Volume

## Create Volume Backup

```bash
docker run --rm \
-v myvolume:/volume \
-v $(pwd):/backup \
ubuntu \
tar cvf /backup/backup.tar /volume
```

Backs up Docker volume.

---

# Restore Docker Volume

## Restore Docker Volume

```bash
docker run --rm \
-v myvolume:/volume \
-v $(pwd):/backup \
ubuntu \
bash -c "cd /volume && tar xvf /backup/backup.tar --strip 1"
```

Restores Docker volume backup.

---

# Backup Application Files

## Create tar.gz Backup

```bash
tar -czvf app-backup.tar.gz /var/www/app
```

Creates compressed backup archive.

---

# Restore tar.gz Backup

## Extract Backup

```bash
tar -xzvf app-backup.tar.gz
```

Restores backup archive.

---

# Backup Nginx Configs

## Backup Nginx Configs

```bash
tar -czvf nginx-backup.tar.gz /etc/nginx
```

Backs up Nginx configurations.

---

# Backup SSL Certificates

## Backup SSL Certificates

```bash
tar -czvf ssl-backup.tar.gz /etc/letsencrypt
```

Backs up SSL certificates.

---

# Backup Environment Variables

## Backup .env Files

```bash
cp .env .env.backup
```

Creates `.env` backup.

Never expose `.env` publicly.

---

# Automated Backups

## Create Backup Script

```bash
nano backup.sh
```

Creates backup automation script.

---

# Example Backup Script

```bash
#!/bin/bash

DATE=$(date +%F)

mkdir -p /backup/$DATE

mongodump --out /backup/$DATE/mongodb

pg_dump mydatabase > /backup/$DATE/postgres.sql

tar -czvf /backup/$DATE/app.tar.gz /var/www/app
```

Basic backup automation example.

---

# Make Script Executable

## Add Execute Permission

```bash
chmod +x backup.sh
```

Makes backup script executable.

---

# Schedule Automatic Backups

## Edit Cron Jobs

```bash
crontab -e
```

Opens cron scheduler.

---

# Example Daily Backup Cron

```txt
0 2 * * * /root/backup.sh
```

Runs backup daily at 2 AM.

---

# Verify Cron Jobs

## Show Cron Jobs

```bash
crontab -l
```

Displays scheduled cron jobs.

---

# Backup Storage Recommendations

Recommended storage locations:

- separate VPS
- external storage
- cloud object storage
- local encrypted storage

Avoid storing only on same VPS.

---

# Backup Retention

Recommended:

- daily backups
- weekly backups
- monthly backups

Delete very old backups if storage is limited.

---

# Test Backup Restores

Backups are useless if restore does not work.

Always test:

- database restore
- Docker restore
- VPS recovery
- application startup

---

# Monitor Backup Size

## Check Backup Folder Size

```bash
du -sh /backup
```

Displays backup storage usage.

---

# Monitor Disk Space

## Check Disk Usage

```bash
df -h
```

Displays available disk space.

---

# Encrypt Sensitive Backups

Important backups may contain:

- passwords
- secrets
- database data
- user information

Use encryption for sensitive backups.

---

# Backup Security Best Practices

- Never expose backups publicly
- Encrypt sensitive backups
- Backup databases regularly
- Store backups offsite
- Monitor backup success
- Test restore process regularly
- Protect backup storage access
- Backup before major deployments

---

# Common Backup Issues

## Backup Disk Full

Check:

```bash
df -h
```

Possible reasons:

- old backups not deleted
- database growth
- Docker volume growth

---

## Corrupted Backup

Possible reasons:

- interrupted backup
- disk issues
- storage corruption

Always test restores.

---

## Cron Job Not Running

Check:

```bash
crontab -l
```

And:

```bash
sudo systemctl status cron
```

---

# Disaster Recovery Workflow

Recommended recovery steps:

1. Restore VPS snapshot
2. Restore databases
3. Restore Docker volumes
4. Restore application files
5. Restore `.env`
6. Restore Nginx configs
7. Restart services
8. Test application functionality

---

# Recommended Production Backup Workflow

1. Configure VPS snapshots
2. Backup databases daily
3. Backup Docker volumes
4. Backup application files
5. Backup configs/SSL
6. Automate backups with cron
7. Store backups externally
8. Monitor backup size
9. Test restores regularly
10. Keep backup strategy updated