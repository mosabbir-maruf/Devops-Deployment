# PostgreSQL

## Table Of Contents

### Fundamentals

1. [What Is PostgreSQL](#1-what-is-postgresql)
2. [PostgreSQL In Production](#2-postgresql-in-production)
3. [Production Architecture](#3-production-architecture)
4. [Production Folder Structure](#4-production-folder-structure)
5. [Docker-First vs Host Install](#5-docker-first-vs-host-install)

### Installation

6. [Install PostgreSQL With Docker (Recommended)](#6-install-postgresql-with-docker-recommended)
7. [Install PostgreSQL On Linux (Host)](#7-install-postgresql-on-linux-host)
8. [Install PostgreSQL Tools On Mac](#8-install-postgresql-tools-on-mac)
9. [Verify PostgreSQL Installation](#9-verify-postgresql-installation)

### Configuration

10. [Docker Compose Production Setup](#10-docker-compose-production-setup)
11. [Environment Variables](#11-environment-variables)
12. [Create Database And User](#12-create-database-and-user)
13. [Connection Strings](#13-connection-strings)
14. [Authentication (pg_hba.conf)](#14-authentication-pg_hbaconf)
15. [PostgreSQL Configuration (postgresql.conf)](#15-postgresql-configuration-postgresqlconf)
16. [Indexes](#16-indexes)

### Development Workflow

17. [Local Development With Docker](#17-local-development-with-docker)
18. [PostgreSQL Shell (psql)](#18-postgresql-shell-psql)
19. [GUI Tools On Mac](#19-gui-tools-on-mac)
20. [Development Best Practices](#20-development-best-practices)

### Production Workflow

21. [Production Docker Compose Stack](#21-production-docker-compose-stack)
22. [Deploy With Coolify](#22-deploy-with-coolify)
23. [Backend Integration (Node.js)](#23-backend-integration-nodejs)
24. [Nginx And Cloudflare Integration](#24-nginx-and-cloudflare-integration)
25. [Rollback And Safe Updates](#25-rollback-and-safe-updates)
26. [Production PostgreSQL Checklist](#26-production-postgresql-checklist)

### Security Best Practices

27. [Network Security](#27-network-security)
28. [Authentication Security](#28-authentication-security)
29. [Firewall Rules](#29-firewall-rules)
30. [Security Checklist](#30-security-checklist)

### Monitoring And Logging

31. [PostgreSQL Logs](#31-postgresql-logs)
32. [Docker Container Logs](#32-docker-container-logs)
33. [Resource Monitoring](#33-resource-monitoring)
34. [Health Checks](#34-health-checks)
35. [Debugging](#35-debugging)

### Backup And Restore

36. [Backup Strategy](#36-backup-strategy)
37. [Backup Commands](#37-backup-commands)
38. [Restore Workflow](#38-restore-workflow)
39. [Recovery Workflow](#39-recovery-workflow)

### Troubleshooting

40. [PostgreSQL Not Starting](#40-postgresql-not-starting)
41. [Authentication Failed](#41-authentication-failed)
42. [Port Already In Use](#42-port-already-in-use)
43. [Too Many Connections](#43-too-many-connections)
44. [Connection Refused From App](#44-connection-refused-from-app)
45. [Disk Full](#45-disk-full)
46. [Container Restart Loops](#46-container-restart-loops)

### Cleanup And Uninstall

47. [Remove PostgreSQL Docker Container (Linux / VPS)](#47-remove-postgresql-docker-container-linux--vps)
48. [Remove PostgreSQL Volumes](#48-remove-postgresql-volumes)
49. [Remove PostgreSQL Dev Container (Mac / Docker Desktop)](#49-remove-postgresql-dev-container-mac--docker-desktop)
50. [Uninstall PostgreSQL On Mac](#50-uninstall-postgresql-on-mac)
51. [Uninstall PostgreSQL On Linux (Host)](#51-uninstall-postgresql-on-linux-host)
52. [Log Cleanup](#52-log-cleanup)
53. [Cache And Leftover Files](#53-cache-and-leftover-files)
54. [Verification After Removal](#54-verification-after-removal)

### Production Workflows

55. [Recommended Production Workflow](#55-recommended-production-workflow)
56. [Modern Workflow](#56-modern-workflow)
57. [Real-World Workflow](#57-real-world-workflow)
58. [Final Production Checklist](#58-final-production-checklist)

---

# 1. What Is PostgreSQL

PostgreSQL is a powerful open-source relational SQL database used for structured, transactional data.

Production use cases:

* SaaS application backends
* user accounts and billing
* analytics and reporting
* any data requiring ACID transactions

Recommended version: **PostgreSQL 17** via official Docker image `postgres:17`.

---

# 2. PostgreSQL In Production

PostgreSQL runs as a **Docker container** on the VPS — never exposed to the public internet.

```txt
User
↓
Cloudflare
↓
Nginx
↓
Backend (Node.js)
↓
PostgreSQL Container (internal network only)
```

Only the backend connects to PostgreSQL over the Docker internal network.

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
Redis Container (cache/sessions)
```

Internal connections:

```txt
backend → postgres:5432
backend → redis:6379
```

Deploy flow:

```txt
Developer
↓
GitHub
↓
GitHub Actions / Coolify
↓
Docker Compose on VPS
↓
postgres_data volume persists data
```

---

# 4. Production Folder Structure

## VPS With Docker Compose

```txt
/var/www/myapp/
├── docker-compose.prod.yml
├── .env
├── nginx/
│   └── default.conf
└── backups/
    └── postgres/
        ├── mydb-2026-06-01.sql
        └── mydb-latest.sql
```

## Docker Volume

```txt
/var/lib/docker/volumes/myapp_postgres_data/_data/
└── (PostgreSQL data — do not edit manually)
```

## Host Install (Legacy)

```txt
/etc/postgresql/17/main/
├── postgresql.conf
└── pg_hba.conf
/var/lib/postgresql/17/main/
/var/log/postgresql/
```

---

# 5. Docker-First vs Host Install

| Approach | Use Case |
|----------|----------|
| **Docker (recommended)** | All production deployments |
| **Host install (legacy)** | Existing bare-metal setups |
| **Coolify database** | Managed PostgreSQL from dashboard |
| **Managed cloud DB** | AWS RDS, Supabase (external to VPS) |

Production rule:

```txt
✓ PostgreSQL in Docker container
✓ Persistent Docker volume
✓ Internal Docker network only
✗ Port 5432 exposed publicly
✗ apt install postgresql for new production projects
```

---

# 6. Install PostgreSQL With Docker (Recommended)

## Pull Official Image

```bash
docker pull postgres:17
```

## Run Single Container (Testing)

```bash
docker run -d \
  --name postgres \
  --restart unless-stopped \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=STRONG_PASSWORD \
  -e POSTGRES_DB=mydb \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:17
```

No `-p 5432:5432` in production — internal network only.

## Verify

```bash
docker ps | grep postgres
docker logs postgres --tail=20
docker exec -it postgres psql -U admin -d mydb -c "SELECT version();"
```

---

# 7. Install PostgreSQL On Linux (Host)

Legacy approach — use Docker for new projects.

## Install

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
```

## Enable And Start

```bash
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl status postgresql
```

## Default System User

```txt
postgres
```

## Access Shell

```bash
sudo -u postgres psql
```

---

# 8. Install PostgreSQL Tools On Mac

## psql via Homebrew

```bash
brew install postgresql@17
brew link postgresql@17 --force
psql --version
```

## GUI Tools

* [TablePlus](https://tableplus.com/)
* [pgAdmin](https://www.pgadmin.org/)
* [DBeaver](https://dbeaver.io/)

## Connect Via SSH Tunnel

```bash
ssh -L 5432:127.0.0.1:5432 vps-prod
psql postgresql://admin:PASSWORD@localhost:5432/mydb
```

---

# 9. Verify PostgreSQL Installation

## Docker

```bash
docker ps | grep postgres
docker exec postgres pg_isready -U admin
docker exec postgres psql -U admin -d mydb -c "SELECT 1;"
```

## Host Install

```bash
psql --version
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"
```

Expected:

```txt
/var/run/postgresql:5432 - accepting connections
```

---

# 10. Docker Compose Production Setup

```yaml
services:
  postgres:
    image: postgres:17
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    # NO ports section — internal only

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

## Start

```bash
docker compose -f docker-compose.prod.yml up -d postgres
docker compose ps postgres
docker exec postgres pg_isready -U admin
```

---

# 11. Environment Variables

## .env (Server Only)

```env
POSTGRES_USER=admin
POSTGRES_PASSWORD=long-random-secret-here
POSTGRES_DB=myapp
APP_DB_USER=myapp_user
APP_DB_PASSWORD=another-long-secret
```

## Backend Connection

```env
DATABASE_URL=postgresql://myapp_user:PASSWORD@postgres:5432/myapp
```

## Rules

```txt
✓ Secrets in .env (chmod 600)
✓ Separate credentials per environment
✗ Commit .env to GitHub
✗ POSTGRES_PASSWORD in docker-compose.yml plaintext
```

---

# 12. Create Database And User

## Via psql (Docker)

```bash
docker exec -it postgres psql -U admin -d mydb
```

```sql
CREATE USER myapp_user WITH PASSWORD 'STRONG_APP_PASSWORD';
CREATE DATABASE myapp OWNER myapp_user;
GRANT ALL PRIVILEGES ON DATABASE myapp TO myapp_user;
\c myapp
GRANT ALL ON SCHEMA public TO myapp_user;
```

## Init Script (docker-entrypoint-initdb.d/init.sql)

```sql
CREATE USER myapp_user WITH PASSWORD 'STRONG_APP_PASSWORD';
CREATE DATABASE myapp OWNER myapp_user;
GRANT ALL PRIVILEGES ON DATABASE myapp TO myapp_user;
```

Mount in compose:

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
  - ./postgres-init:/docker-entrypoint-initdb.d:ro
```

Runs only on first container start (empty volume).

---

# 13. Connection Strings

## Internal (Docker — Production)

```txt
postgresql://myapp_user:PASSWORD@postgres:5432/myapp
```

## Local Dev

```txt
postgresql://myapp_user:PASSWORD@localhost:5432/myapp
```

## With SSL (External Managed DB)

```txt
postgresql://user:pass@host:5432/db?sslmode=require
```

## Node.js (Prisma)

```env
DATABASE_URL=postgresql://myapp_user:PASSWORD@postgres:5432/myapp
```

## Node.js (pg)

```javascript
import pg from "pg";
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
```

---

# 14. Authentication (pg_hba.conf)

Host install only — Docker handles auth via env vars.

## File Location

```txt
/etc/postgresql/17/main/pg_hba.conf
```

## Production Rules

```txt
# Local connections
local   all   postgres                    peer
local   all   all                         scram-sha-256
host    all   all   127.0.0.1/32          scram-sha-256

# DO NOT add 0.0.0.0/0 in production
```

## Apply Changes

```bash
sudo systemctl restart postgresql
```

Docker production: restrict via network — PostgreSQL never on public interface.

---

# 15. PostgreSQL Configuration (postgresql.conf)

Host install tuning — Docker uses defaults suitable for small VPS.

## File Location

```txt
/etc/postgresql/17/main/postgresql.conf
```

## Key Settings (Production VPS)

```txt
listen_addresses = 'localhost'     # Host install — local only
max_connections = 100
shared_buffers = 256MB               # ~25% RAM for dedicated DB VPS
effective_cache_size = 768MB
log_min_duration_statement = 1000    # Log queries > 1s
```

```bash
sudo systemctl restart postgresql
```

For Docker: pass config via mounted file if tuning needed:

```yaml
volumes:
  - ./postgresql.conf:/etc/postgresql/postgresql.conf
```

---

# 16. Indexes

## Create Index

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);
CREATE INDEX idx_orders_user_id_created ON orders(user_id, created_at DESC);
```

## List Indexes

```sql
\di
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'users';
```

## Analyze Slow Queries

```sql
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';
```

## Show Table Sizes

```sql
SELECT relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
```

---

# 17. Local Development With Docker

## docker-compose.dev.yml

```yaml
services:
  postgres:
    image: postgres:17
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: devpassword
      POSTGRES_DB: myapp_dev
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data

volumes:
  postgres_dev_data:
```

Port exposure acceptable for **local Mac dev only**.

```bash
docker compose -f docker-compose.dev.yml up -d postgres
psql postgresql://dev:devpassword@localhost:5432/myapp_dev
```

---

# 18. PostgreSQL Shell (psql)

## Connect (Docker)

```bash
docker exec -it postgres psql -U admin -d myapp
```

## Common Commands

```sql
\l                          -- list databases
\c myapp                    -- connect database
\dt                         -- list tables
\d users                    -- describe table
\du                         -- list users
SELECT * FROM users LIMIT 5;
\q                          -- quit
```

## Create Table Example

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO users (name, email) VALUES ('Mosabbir', 'test@example.com');
SELECT * FROM users;
```

---

# 19. GUI Tools On Mac

## TablePlus Via SSH Tunnel

Terminal:

```bash
ssh -L 5432:127.0.0.1:5432 vps-prod
```

TablePlus settings:

```txt
Host:     localhost
Port:     5432
User:     myapp_user
Password: PASSWORD
Database: myapp
```

## pgAdmin

Use SSH tunnel mode — never expose port 5432 publicly for GUI access.

✓ Good:

* SSH tunnel for production DB access
* read-only DB user for debugging

✗ Avoid:

* opening port 5432 for GUI tools

---

# 20. Development Best Practices

✓ Good:

* Docker Compose for local PostgreSQL
* same PostgreSQL 17 as production
* migration files in repo (Prisma, Drizzle, Knex)
* seed scripts for dev data

✗ Avoid:

* developing against production database
* manual schema changes without migrations
* shared dev/prod credentials

---

# 21. Production Docker Compose Stack

```yaml
services:
  backend:
    image: youruser/myapp-backend:${TAG:-latest}
    restart: unless-stopped
    env_file:
      - .env
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network

  postgres:
    image: postgres:17
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgres-init:/docker-entrypoint-initdb.d:ro
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

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
    depends_on:
      - backend
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
```

## Deploy

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml up -d
docker compose ps
docker exec postgres pg_isready -U admin
```

---

# 22. Deploy With Coolify

```txt
Coolify → New Resource → Database → PostgreSQL
→ Set version, name, credentials
→ Deploy
→ Copy internal connection string
→ Add DATABASE_URL to application env vars
```

Application env:

```env
DATABASE_URL=postgresql://user:pass@CONTAINER_NAME:5432/myapp
```

See `05-coolify.md` for full setup.

---

# 23. Backend Integration (Node.js)

## Prisma

```bash
npm install prisma @prisma/client
npx prisma init
```

```env
DATABASE_URL=postgresql://myapp_user:PASSWORD@postgres:5432/myapp
```

```bash
npx prisma migrate deploy
npx prisma db seed
```

## pg (node-postgres)

```javascript
import pg from "pg";

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
});

const result = await pool.query("SELECT NOW()");
```

## Verify From Backend Container

```bash
docker compose exec backend node -e "
const { Client } = require('pg');
const c = new Client({ connectionString: process.env.DATABASE_URL });
c.connect().then(() => { console.log('OK'); c.end(); }).catch(console.error);
"
```

---

# 24. Nginx And Cloudflare Integration

PostgreSQL is internal — not proxied by Nginx.

```txt
User → Cloudflare → Nginx → Backend → PostgreSQL (internal)
```

Verify not publicly reachable:

```bash
nc -zv YOUR_PUBLIC_IP 5432    # Should fail/refused
sudo ufw status | grep 5432   # Should not be allowed
```

---

# 25. Rollback And Safe Updates

## Before Upgrade / Migration

```bash
docker exec postgres pg_dump -U admin myapp > ~/backups/myapp-pre-migrate-$(date +%F).sql
```

## Rollback Migration

```bash
# Prisma
npx prisma migrate resolve --rolled-back MIGRATION_NAME

# Restore from backup
docker compose stop backend
cat ~/backups/myapp-pre-migrate.sql | docker exec -i postgres psql -U admin myapp
docker compose start backend
```

## Rollback PostgreSQL Image

```bash
# Pin image tag in compose: postgres:17.2
docker compose -f docker-compose.prod.yml up -d postgres
```

Always backup before major version upgrades.

---

# 26. Production PostgreSQL Checklist

✓ Good:

* postgres:17 in Docker
* persistent volume
* health check with pg_isready
* port 5432 not public
* app-specific DB user
* daily pg_dump backups
* migrations in CI/CD

✗ Avoid:

* public port 5432
* postgres superuser in app connection
* no backups before migrations

---

# 27. Network Security

```txt
✓ PostgreSQL on internal Docker network
✓ Backend connects via postgres:5432
✓ UFW blocks port 5432
✓ SSH tunnel for admin GUI access

✗ listen_addresses = '*' on public VPS
✗ -p 5432:5432 in production compose
```

## Verify

```bash
docker compose exec backend nc -zv postgres 5432
nc -zv YOUR_PUBLIC_IP 5432
```

---

# 28. Authentication Security

✓ Good:

* app user with limited privileges (not superuser)
* scram-sha-256 passwords
* strong random passwords (32+ chars)
* rotate credentials periodically

✗ Avoid:

* postgres superuser in DATABASE_URL
* trust authentication
* shared passwords across environments

---

# 29. Firewall Rules

```bash
sudo ufw deny 5432
sudo ufw status verbose
```

If remote access required (not recommended):

```bash
sudo ufw allow from YOUR_HOME_IP to any port 5432 proto tcp
```

Prefer SSH tunnel:

```bash
ssh -L 5432:127.0.0.1:5432 vps-prod
psql postgresql://user:pass@localhost:5432/myapp
```

---

# 30. Security Checklist

✓ Good:

* Docker internal network
* UFW denies 5432
* app-specific DB user
* .env chmod 600
* daily backups
* migration-based schema changes

✗ Avoid:

* public PostgreSQL port
* superuser in application
* manual prod schema edits without backup

---

# 31. PostgreSQL Logs

## Docker

```bash
docker logs postgres -f
docker logs postgres --tail=100 --since 1h
```

## Host Install

```bash
sudo tail -f /var/log/postgresql/postgresql-17-main.log
sudo journalctl -u postgresql -f
```

## Enable Slow Query Log (Host)

```txt
# postgresql.conf
log_min_duration_statement = 1000
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d '
```

---

# 32. Docker Container Logs

```bash
docker compose logs -f postgres
docker compose logs postgres --tail=200
```

## Export

```bash
docker logs postgres > postgres-$(date +%F).log 2>&1
```

---

# 33. Resource Monitoring

## Disk Usage

```bash
docker exec postgres du -sh /var/lib/postgresql/data
du -sh /var/lib/docker/volumes/myapp_postgres_data
df -h
```

## Database Sizes

```sql
SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database ORDER BY pg_database_size(datname) DESC;
```

## Active Connections

```sql
SELECT count(*) FROM pg_stat_activity;
SELECT pid, usename, datname, state, query
FROM pg_stat_activity WHERE state != 'idle';
```

## Container Stats

```bash
docker stats postgres --no-stream
```

---

# 34. Health Checks

## Docker Compose

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 10s
```

## Manual

```bash
docker exec postgres pg_isready -U admin -d myapp
docker compose ps postgres
```

## From Backend Health Endpoint

```javascript
app.get("/health", async (req, res) => {
  await pool.query("SELECT 1");
  res.json({ status: "ok" });
});
```

---

# 35. Debugging

## Connection Debug

```bash
docker compose ps
docker compose exec backend env | grep DATABASE
docker compose exec backend nc -zv postgres 5432
docker logs postgres --tail=50
```

## psql Debug

```bash
docker exec -it postgres psql -U myapp_user -d myapp -c "SELECT 1;"
```

## Inspect

```bash
docker inspect postgres | grep -A10 State
docker volume inspect myapp_postgres_data
```

---

# 36. Backup Strategy

```txt
1. pg_dump daily (logical backup)
2. Docker volume tar weekly
3. VPS snapshot monthly
4. Offsite copy (S3, Backblaze)
5. Test restore monthly
```

Critical rule: **always backup before migrations**.

See `15-backup-snapshots.md` for full guide.

---

# 37. Backup Commands

## pg_dump Single Database (Docker)

```bash
docker exec postgres pg_dump -U admin myapp > ~/backups/myapp-$(date +%F).sql
```

## Compressed Backup

```bash
docker exec postgres pg_dump -U admin myapp | gzip > ~/backups/myapp-$(date +%F).sql.gz
```

## All Databases

```bash
docker exec postgres pg_dumpall -U admin > ~/backups/all-databases-$(date +%F).sql
```

## Volume Backup

```bash
docker compose stop postgres
docker run --rm \
  -v myapp_postgres_data:/data \
  -v ~/backups:/backup \
  alpine tar -czvf /backup/postgres-volume-$(date +%F).tar.gz /data
docker compose start postgres
```

## Copy To Mac

```bash
scp vps-prod:~/backups/myapp-*.sql.gz ./backups/
```

## Automated Cron

```bash
crontab -e
```

```cron
0 2 * * * docker exec postgres pg_dump -U admin myapp | gzip > /home/mosabbir/backups/myapp-$(date +\%F).sql.gz
```

---

# 38. Restore Workflow

## Restore Single Database

```bash
docker compose stop backend
cat ~/backups/myapp-YYYY-MM-DD.sql | docker exec -i postgres psql -U admin myapp
docker compose start backend
```

## Restore Compressed

```bash
gunzip -c ~/backups/myapp-YYYY-MM-DD.sql.gz | docker exec -i postgres psql -U admin myapp
```

## Restore All Databases

```bash
cat ~/backups/all-databases-YYYY-MM-DD.sql | docker exec -i postgres psql -U admin
```

## Restore Volume

```bash
docker compose down postgres
docker run --rm \
  -v myapp_postgres_data:/data \
  -v ~/backups:/backup \
  alpine sh -c "rm -rf /data/* && tar -xzvf /backup/postgres-volume-YYYY-MM-DD.tar.gz -C /"
docker compose up -d postgres
```

## Verify

```bash
docker exec postgres psql -U admin myapp -c "SELECT count(*) FROM users;"
curl -f http://localhost:5000/health
```

---

# 39. Recovery Workflow

Complete failure recovery:

```txt
1. Provision / restore VPS
2. Install Docker
3. Restore docker-compose.prod.yml + .env
4. Restore postgres volume OR pg_restore from dump
5. docker compose up -d
6. Run pending migrations
7. Verify backend health
8. Verify data integrity
```

Emergency — restart PostgreSQL:

```bash
docker compose restart postgres
docker exec postgres pg_isready -U admin
docker compose logs postgres --tail=30
```

---

# 40. PostgreSQL Not Starting

## Diagnose

```bash
docker compose ps -a
docker logs postgres --tail=50
docker inspect postgres | grep -A5 State
```

## Host

```bash
sudo systemctl status postgresql
sudo journalctl -u postgresql --since "10 min ago"
```

## Common Fixes

```txt
Out of disk space    → df -h, clean logs/images
Corrupt data         → restore from backup
Port conflict        → ss -tlnp | grep 5432
Wrong permissions    → volume ownership
```

```bash
df -h
docker compose down && docker compose up -d postgres
```

---

# 41. Authentication Failed

## Symptoms

```txt
FATAL: password authentication failed for user
```

## Fix

```bash
docker compose exec backend env | grep DATABASE
docker exec -it postgres psql -U myapp_user -d myapp -c "SELECT 1;"
```

Reset password:

```sql
ALTER USER myapp_user WITH PASSWORD 'NEW_STRONG_PASSWORD';
```

Update `.env` and redeploy backend.

---

# 42. Port Already In Use

```bash
sudo ss -tlnp | grep 5432
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep 5432
```

## Fix

```bash
docker stop conflicting_container
# Dev: change to ports: - "5433:5432"
```

---

# 43. Too Many Connections

## Check

```sql
SELECT count(*) FROM pg_stat_activity;
SHOW max_connections;
```

## Kill Idle Connections

```sql
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle' AND query_start < NOW() - INTERVAL '10 minutes';
```

## Fix In Application

```javascript
const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,  // limit pool size
});
```

---

# 44. Connection Refused From App

## Diagnose

```bash
docker compose exec backend nc -zv postgres 5432
docker compose ps postgres
docker network inspect myapp_app-network
```

## Common Causes

```txt
Wrong hostname (use "postgres" not "localhost" in container)
Different Docker network
PostgreSQL not ready (add depends_on + healthcheck)
DATABASE_URL typo
```

## Fix

```env
DATABASE_URL=postgresql://user:pass@postgres:5432/myapp
```

---

# 45. Disk Full

```bash
df -h
docker exec postgres du -sh /var/lib/postgresql/data
```

## Find Large Tables

```sql
SELECT relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC LIMIT 10;
```

## Free Space

```bash
docker system prune -f
sudo journalctl --vacuum-time=7d
# Vacuum database
docker exec postgres psql -U admin myapp -c "VACUUM FULL;"
```

Plan disk upgrade before 85% usage.

---

# 46. Container Restart Loops

```bash
docker compose ps
docker logs postgres --tail=30
docker inspect postgres --format='{{.State.RestartCount}}'
```

Common causes:

* corrupt data directory
* out of memory
* invalid config mount
* permission errors on volume

```bash
docker logs postgres 2>&1 | tail -20
free -h
```

Restore from backup if data corruption confirmed.

---

# 47. Remove PostgreSQL Docker Container (Linux / VPS)

Production PostgreSQL runs on the VPS via Docker Compose.

## Stop And Remove Container

```bash
cd /var/www/myapp
docker compose stop postgres
docker compose rm postgres
```

## Remove Full Stack

```bash
docker compose down       # keeps volumes
docker compose down -v    # DESTROYS all data
```

## Remove Standalone Container

```bash
docker stop postgres
docker rm postgres
docker rmi postgres:17
```

---

# 48. Remove PostgreSQL Volumes

## List Volumes

```bash
docker volume ls | grep postgres
```

## Backup Then Remove

```bash
docker exec postgres pg_dump -U admin myapp > ~/backups/final-myapp.sql
docker compose down
docker volume rm myapp_postgres_data
```

✓ Good:

* backup before removing any volume

✗ Avoid:

* `docker volume rm` without backup in production

---

# 49. Remove PostgreSQL Dev Container (Mac / Docker Desktop)

Local dev PostgreSQL from `docker-compose.dev.yml` on Mac.

## Stop Dev Stack

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml stop postgres
docker compose -f docker-compose.dev.yml rm postgres
```

## Remove Dev Stack And Volume

```bash
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml down -v
```

## Remove Dev Image

```bash
docker rmi postgres:17
docker image prune -f
```

## Verify (Mac)

```bash
docker ps -a | grep postgres
docker volume ls | grep postgres
nc -zv localhost 5432
```

Expected: no dev containers, port 5432 closed.

---

# 50. Uninstall PostgreSQL On Mac

For Homebrew-installed `psql` and local PostgreSQL — not production VPS.

## Stop Local PostgreSQL Service (If Running)

```bash
brew services stop postgresql@17
```

## Uninstall PostgreSQL

```bash
brew uninstall postgresql@17
brew unlink postgresql@17
```

## Uninstall GUI Tools (Optional)

```bash
brew uninstall --cask tableplus
brew uninstall --cask pgadmin4
brew uninstall --cask dbeaver-community
```

## Remove Mac Data Directories

```bash
rm -rf /usr/local/var/postgresql@17
rm -rf /opt/homebrew/var/postgresql@17
rm -rf ~/Library/Application\ Support/Postgres
rm -rf ~/Library/Logs/PostgreSQL
rm -rf ~/.pgadmin
rm -rf ~/Library/Preferences/org.pgadmin.pgadmin4.plist
```

## Remove Homebrew Leftovers

```bash
brew cleanup
brew autoremove
```

## Verify (Mac)

```bash
which psql
which postgres
psql --version 2>&1
brew list | grep postgres
ls ~/Library/Application\ Support/ | grep -i postgres
```

Expected: commands not found, no postgres packages listed.

---

# 51. Uninstall PostgreSQL On Linux (Host)

Legacy host install only — production should use Docker.

## Stop And Disable Service

```bash
sudo systemctl stop postgresql
sudo systemctl disable postgresql
```

## Remove Packages

```bash
sudo apt purge -y postgresql postgresql-* 
sudo apt autoremove -y
sudo apt autoclean
```

## Remove Data, Logs, Config

```bash
sudo rm -rf /var/lib/postgresql
sudo rm -rf /var/log/postgresql
sudo rm -rf /etc/postgresql
sudo rm -rf /tmp/pgsql-*
```

## Verify (Linux Host)

```bash
which psql
which postgres
systemctl status postgresql
dpkg -l | grep postgres
sudo ss -tlnp | grep 5432
```

Expected: commands not found, service absent, port closed.

---

# 52. Log Cleanup

## Docker Logs (Linux / VPS)

```bash
# Truncate container logs without removing container
truncate -s 0 $(docker inspect --format='{{.LogPath}}' postgres)

# Or configure log rotation in compose:
# logging:
#   driver: json-file
#   options:
#     max-size: "10m"
#     max-file: "3"
```

## Docker Compose Log Export Then Restart

```bash
docker logs postgres > ~/logs/postgres-final.log 2>&1
docker compose restart postgres
```

## Host Install Logs (Linux)

```bash
sudo truncate -s 0 /var/log/postgresql/postgresql-17-main.log
sudo rm -f /var/log/postgresql/postgresql-17-main.log.*
sudo journalctl --vacuum-time=7d
```

## Mac Logs

```bash
rm -rf ~/Library/Logs/PostgreSQL
rm -rf ~/Library/Application\ Support/Postgres/var-17
rm -rf ~/.pgadmin/pgadmin4.log
```

## Exported Backup Logs (Safe To Delete)

```bash
rm -f ~/logs/postgres-*.log
rm -f ~/backups/*.log
```

## WAL Files (Host — Do Not Delete Manually)

WAL files are managed by PostgreSQL. Only remove after understanding WAL archiving or during full uninstall.

---

# 53. Cache And Leftover Files

## Docker Cache (Linux / Mac)

```bash
docker builder prune -f
docker image prune -f
docker image rm postgres:17
docker system prune -f
```

Remove unused PostgreSQL volumes (backup first):

```bash
docker volume ls | grep postgres
docker volume prune -f
```

Warning: `docker volume prune` deletes unused volumes permanently.

## Linux Host Leftovers

```bash
sudo rm -rf /var/lib/postgresql
sudo rm -rf /var/log/postgresql
sudo rm -rf /etc/postgresql
sudo rm -rf /tmp/pgsql-*
sudo apt autoremove -y
sudo apt autoclean
```

## Mac Leftovers

```bash
rm -rf /usr/local/var/postgresql@17
rm -rf /opt/homebrew/var/postgresql@17
rm -rf ~/.pgadmin
rm -rf ~/Library/Application\ Support/Postgres
rm -rf ~/Library/Caches/com.tinyapp.TablePlus
brew cleanup
```

## Old Backup Files

```bash
ls ~/backups/
rm ~/backups/myapp-2025-*.sql.gz
rm -f ~/backups/all-databases-2025-*.sql
```

## psql History And Temp Files

```bash
rm -f ~/.psql_history
rm -f /tmp/pgsql-*
```

## Orphan Docker Networks

```bash
docker network ls | grep myapp
docker network prune -f
```

---

# 54. Verification After Removal

## Docker (Linux / VPS)

```bash
docker ps -a | grep postgres
docker volume ls | grep postgres
docker images | grep postgres
nc -zv localhost 5432
```

Expected: no containers, no volumes (if removed), no images, port closed.

## Mac

```bash
which psql
which postgres
brew list | grep postgres
docker ps -a | grep postgres
docker volume ls | grep postgres
nc -zv localhost 5432
ls ~/Library/Application\ Support/ | grep -i postgres
```

Expected: commands not found, no brew postgres packages, no dev containers, port closed.

## Linux Host

```bash
which psql
systemctl status postgresql
dpkg -l | grep postgres
sudo ss -tlnp | grep 5432
ls /var/lib/postgresql 2>&1
```

Expected: command not found, service absent, port closed, data directory gone.

## Cleanup Checklist

✓ Good:

* containers removed
* volumes backed up then removed (if intended)
* Mac Homebrew packages uninstalled
* log and cache directories cleared
* port 5432 not listening

✗ Avoid:

* `docker volume prune` without backup
* deleting WAL files manually on running host install

---

# 55. Recommended Production Workflow

```txt
1. Add postgres:17 to docker-compose.prod.yml
2. Configure POSTGRES_* env vars in .env
3. Create app user via init script
4. Run migrations (Prisma/Drizzle)
5. Connect backend via DATABASE_URL (internal)
6. Block port 5432 in UFW
7. Schedule daily pg_dump
8. Test restore monthly
9. Monitor disk and connections
```

---

# 56. Modern Workflow

```txt
Developer (Mac)
↓
Local Docker Compose (dev PostgreSQL)
↓
Migrations in repo
↓
GitHub Push
↓
GitHub Actions (test + migrate + deploy)
↓
VPS Docker Compose
↓
PostgreSQL volume persists
↓
Backend connects internally
```

---

# 57. Real-World Workflow

Example: SaaS API with Prisma on Hetzner VPS.

## Setup

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml up -d
docker exec postgres pg_isready -U admin
```

## Run Migrations On Deploy

```yaml
# GitHub Actions deploy step
script: |
  cd /var/www/myapp
  docker compose pull
  docker compose up -d
  docker compose exec backend npx prisma migrate deploy
```

## Daily Backup

```cron
0 2 * * * docker exec postgres pg_dump -U admin myapp | gzip > /home/mosabbir/backups/myapp-$(date +\%F).sql.gz
```

## Debug From Mac

```bash
ssh -L 5432:127.0.0.1:5432 vps-prod
# TablePlus → localhost:5432
```

---

# 58. Final Production Checklist

## PostgreSQL Container

✓ postgres:17 image
✓ persistent volume
✓ pg_isready health check
✓ no public port mapping
✓ app user (not superuser)

## Security

✓ UFW blocks 5432
✓ DATABASE_URL in .env (chmod 600)
✓ SSH tunnel for GUI access

## Operations

✓ daily pg_dump backups
✓ restore tested monthly
✓ migrations version-controlled
✓ indexes on queried columns
✓ disk monitoring enabled

## Full Stack

```txt
User → Cloudflare → Nginx → Backend → PostgreSQL (internal)
```

---

## PostgreSQL Quick Commands Cheat Sheet

```bash
# Start
docker compose up -d postgres
docker compose ps postgres

# Health
docker exec postgres pg_isready -U admin -d myapp

# Shell
docker exec -it postgres psql -U admin -d myapp

# Logs
docker logs postgres -f

# Backup
docker exec postgres pg_dump -U admin myapp > backup.sql
docker exec postgres pg_dump -U admin myapp | gzip > backup.sql.gz

# Restore
cat backup.sql | docker exec -i postgres psql -U admin myapp

# Stats
docker stats postgres --no-stream
docker exec postgres psql -U admin myapp -c "SELECT pg_size_pretty(pg_database_size('myapp'));"

# Connections
docker exec postgres psql -U admin -c "SELECT count(*) FROM pg_stat_activity;"

# Cleanup (VPS / Docker)
docker compose down       # keeps volume
docker compose down -v    # DESTROYS data
docker volume prune -f    # backup first

# Uninstall Mac (Homebrew)
brew services stop postgresql@17
brew uninstall postgresql@17
rm -rf /opt/homebrew/var/postgresql@17 ~/.pgadmin ~/Library/Logs/PostgreSQL

# Uninstall Linux (host)
sudo apt purge -y postgresql postgresql-* && sudo apt autoremove -y
sudo rm -rf /var/lib/postgresql /var/log/postgresql /etc/postgresql
```
