# Redis

## Table Of Contents

### Fundamentals

1. [What Is Redis](#1-what-is-redis)
2. [Redis In Production](#2-redis-in-production)
3. [Production Architecture](#3-production-architecture)
4. [Production Folder Structure](#4-production-folder-structure)
5. [Docker-First vs Host Install](#5-docker-first-vs-host-install)

### Installation

6. [Install Redis With Docker (Recommended)](#6-install-redis-with-docker-recommended)
7. [Install Redis On Linux (Host)](#7-install-redis-on-linux-host)
8. [Install Redis Tools On Mac](#8-install-redis-tools-on-mac)
9. [Verify Redis Installation](#9-verify-redis-installation)

### Configuration

10. [Docker Compose Production Setup](#10-docker-compose-production-setup)
11. [Environment Variables](#11-environment-variables)
12. [Connection Strings](#12-connection-strings)
13. [Authentication And Security Config](#13-authentication-and-security-config)
14. [Persistence (RDB And AOF)](#14-persistence-rdb-and-aof)
15. [Redis CLI Basics](#15-redis-cli-basics)
16. [Host Configuration (redis.conf)](#16-host-configuration-redisconf)

### Development Workflow

17. [Local Development With Docker](#17-local-development-with-docker)
18. [Redis CLI And GUI Tools](#18-redis-cli-and-gui-tools)
19. [Backend Integration (Node.js)](#19-backend-integration-nodejs)
20. [Development Best Practices](#20-development-best-practices)

### Production Workflow

21. [Production Docker Compose Stack](#21-production-docker-compose-stack)
22. [Deploy With Coolify](#22-deploy-with-coolify)
23. [Sessions, Cache, And Queues](#23-sessions-cache-and-queues)
24. [Nginx And Cloudflare Integration](#24-nginx-and-cloudflare-integration)
25. [Rollback And Safe Updates](#25-rollback-and-safe-updates)
26. [Production Redis Checklist](#26-production-redis-checklist)

### Security Best Practices

27. [Network Security](#27-network-security)
28. [Authentication Security](#28-authentication-security)
29. [Firewall Rules](#29-firewall-rules)
30. [Security Checklist](#30-security-checklist)

### Monitoring And Logging

31. [Redis Logs](#31-redis-logs)
32. [Docker Container Logs](#32-docker-container-logs)
33. [Resource And Memory Monitoring](#33-resource-and-memory-monitoring)
34. [Health Checks](#34-health-checks)
35. [Debugging](#35-debugging)

### Backup And Restore

36. [Backup Strategy](#36-backup-strategy)
37. [Backup Commands](#37-backup-commands)
38. [Restore Workflow](#38-restore-workflow)
39. [Recovery Workflow](#39-recovery-workflow)

### Troubleshooting

40. [Connection Refused](#40-connection-refused)
41. [Authentication Failed](#41-authentication-failed)
42. [Port Already In Use](#42-port-already-in-use)
43. [High Memory Usage](#43-high-memory-usage)
44. [Connection Refused From App](#44-connection-refused-from-app)
45. [Container Restart Loops](#45-container-restart-loops)

### Cleanup And Uninstall

46. [Remove Redis Docker Container (Linux / VPS)](#46-remove-redis-docker-container-linux--vps)
47. [Remove Redis Volumes](#47-remove-redis-volumes)
48. [Remove Redis Dev Container (Mac / Docker Desktop)](#48-remove-redis-dev-container-mac--docker-desktop)
49. [Uninstall Redis On Mac](#49-uninstall-redis-on-mac)
50. [Uninstall Redis On Linux (Host)](#50-uninstall-redis-on-linux-host)
51. [Log Cleanup](#51-log-cleanup)
52. [Cache And Leftover Files](#52-cache-and-leftover-files)
53. [Verification After Removal](#53-verification-after-removal)

### Production Workflows

54. [Recommended Production Workflow](#54-recommended-production-workflow)
55. [Modern Workflow](#55-modern-workflow)
56. [Real-World Workflow](#56-real-world-workflow)
57. [Final Production Checklist](#57-final-production-checklist)

---

# 1. What Is Redis

Redis is an in-memory data store used for caching, sessions, queues, pub/sub, and rate limiting.

Production use cases:

* API response caching
* session storage
* JWT blacklist / token cache
* background job queues (BullMQ)
* Socket.IO adapter for scaling
* rate limiting

Recommended version: **Redis 8** via official Docker image `redis:8-alpine`.

Redis is fast because data lives in RAM — plan memory limits carefully on small VPS.

---

# 2. Redis In Production

Redis runs as a **Docker container** on the internal network — never exposed publicly.

```txt
User
↓
Cloudflare
↓
Nginx
↓
Backend (Node.js)
↓
Redis Container (internal only)
```

Redis is ephemeral by design — use TTLs for cache data. Persist only when sessions/queues require it.

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

Internal connections:

```txt
backend → redis:6379
backend → postgres:5432
```

Typical Redis roles in stack:

```txt
Cache        → TTL keys, no persistence required
Sessions     → AOF or RDB persistence
Job queues   → AOF persistence recommended
Rate limit   → TTL keys only
```

---

# 4. Production Folder Structure

## VPS With Docker Compose

```txt
/var/www/myapp/
├── docker-compose.prod.yml
├── .env
├── redis/
│   └── redis.conf          # optional custom config
└── backups/
    └── redis/
        └── dump-2026-06-01.rdb
```

## Docker Volume

```txt
/var/lib/docker/volumes/myapp_redis_data/_data/
└── appendonly.aof / dump.rdb
```

## Host Install (Legacy)

```txt
/etc/redis/redis.conf
/var/lib/redis/dump.rdb
/var/log/redis/redis-server.log
```

---

# 5. Docker-First vs Host Install

| Approach | Use Case |
|----------|----------|
| **Docker (recommended)** | All production deployments |
| **Host install (legacy)** | Existing bare-metal setups |
| **Coolify database** | Managed Redis from dashboard |

Production rule:

```txt
✓ Redis in Docker container
✓ Internal Docker network only
✓ Password authentication
✗ Port 6379 exposed publicly
✗ Redis without AUTH in production
```

---

# 6. Install Redis With Docker (Recommended)

## Pull Official Image

```bash
docker pull redis:8-alpine
```

## Run Single Container (Testing)

```bash
docker run -d \
  --name redis \
  --restart unless-stopped \
  -v redis_data:/data \
  redis:8-alpine redis-server \
  --requirepass STRONG_PASSWORD \
  --appendonly yes
```

No `-p 6379:6379` in production — internal network only.

## Verify

```bash
docker ps | grep redis
docker exec redis redis-cli -a STRONG_PASSWORD ping
```

Expected:

```txt
PONG
```

---

# 7. Install Redis On Linux (Host)

Legacy approach — use Docker for new projects.

## Install

```bash
sudo apt update
sudo apt install redis-server -y
```

## Enable And Start

```bash
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo systemctl status redis-server
```

## Verify

```bash
redis-server --version
redis-cli ping
```

---

# 8. Install Redis Tools On Mac

Mac is for development access — not running production Redis.

## redis-cli via Homebrew

```bash
brew install redis
redis-cli --version
```

## Connect To VPS Redis Via SSH Tunnel

```bash
ssh -L 6379:127.0.0.1:6379 vps-prod
redis-cli -a PASSWORD -h localhost ping
```

## GUI Tools (Optional)

* [Redis Insight](https://redis.io/insight/) — official GUI
* [Medis](https://getmedis.com/) — Mac Redis GUI

---

# 9. Verify Redis Installation

## Docker

```bash
docker ps | grep redis
docker exec redis redis-cli -a PASSWORD ping
docker exec redis redis-server --version
```

## Host Install

```bash
redis-server --version
sudo systemctl status redis-server
redis-cli ping
sudo ss -tlnp | grep 6379
```

## From Backend Container

```bash
docker compose exec backend sh -c 'nc -zv redis 6379'
```

---

# 10. Docker Compose Production Setup

```yaml
services:
  redis:
    image: redis:8-alpine
    restart: unless-stopped
    command: >
      redis-server
      --requirepass ${REDIS_PASSWORD}
      --appendonly yes
      --maxmemory 256mb
      --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 5s
      retries: 5
    # NO ports section — internal network only

volumes:
  redis_data:

networks:
  app-network:
    driver: bridge
```

## Start

```bash
docker compose -f docker-compose.prod.yml up -d redis
docker compose ps redis
docker exec redis redis-cli -a PASSWORD ping
```

---

# 11. Environment Variables

## .env (Server Only)

```env
REDIS_PASSWORD=long-random-secret-here
REDIS_URL=redis://:PASSWORD@redis:6379
```

Note: URL format with password:

```env
REDIS_URL=redis://:YOUR_PASSWORD@redis:6379
```

## Rules

```txt
✓ REDIS_PASSWORD in .env (chmod 600)
✓ Different passwords per environment
✗ Commit .env to GitHub
✗ Empty requirepass in production
```

---

# 12. Connection Strings

## Internal (Docker — Production)

```txt
redis://:PASSWORD@redis:6379
redis://:PASSWORD@redis:6379/0
```

## With Database Index

```txt
redis://:PASSWORD@redis:6379/1    # cache
redis://:PASSWORD@redis:6379/2    # sessions
redis://:PASSWORD@redis:6379/3    # queues
```

## Local Dev

```txt
redis://:devpassword@localhost:6379
```

## Node.js (ioredis)

```javascript
import Redis from "ioredis";

const redis = new Redis(process.env.REDIS_URL);
await redis.ping();
```

---

# 13. Authentication And Security Config

## Docker Command Flags

```txt
--requirepass STRONG_PASSWORD
--rename-command FLUSHALL ""
--rename-command FLUSHDB ""
--rename-command CONFIG ""
```

## Full Secure Command (Compose)

```yaml
command: >
  redis-server
  --requirepass ${REDIS_PASSWORD}
  --appendonly yes
  --maxmemory 256mb
  --maxmemory-policy allkeys-lru
  --rename-command FLUSHALL ""
  --rename-command FLUSHDB ""
  --rename-command CONFIG ""
```

## Host redis.conf

```txt
requirepass STRONG_PASSWORD
bind 127.0.0.1
rename-command FLUSHALL ""
rename-command FLUSHDB ""
```

```bash
sudo systemctl restart redis-server
```

✓ Good:

* password on all production instances
* dangerous commands disabled

✗ Avoid:

* no authentication
* `bind 0.0.0.0` without firewall

---

# 14. Persistence (RDB And AOF)

## When To Persist

```txt
Cache only       → no persistence needed (or RDB snapshots)
Sessions         → AOF recommended
Job queues       → AOF recommended
```

## Docker — Enable AOF

```yaml
command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
volumes:
  - redis_data:/data
```

## RDB Snapshot (Host redis.conf)

```txt
save 900 1
save 300 10
save 60 10000
```

## AOF (Host redis.conf)

```txt
appendonly yes
appendfsync everysec
```

## Disable Persistence (Cache-Only)

```yaml
command: redis-server --requirepass ${REDIS_PASSWORD} --save ""
```

Use for pure cache where data loss on restart is acceptable.

---

# 15. Redis CLI Basics

## Connect (Docker)

```bash
docker exec -it redis redis-cli -a PASSWORD
```

## Common Commands

```bash
PING
SET username "mosabbir"
GET username
DEL username
EXISTS username
EXPIRE username 3600
TTL username
KEYS user:*          # avoid KEYS * in production
SCAN 0 MATCH user:* COUNT 100
INFO memory
DBSIZE
FLUSHDB              # disabled in production config
```

## Hash Example

```bash
HSET user:1 name "Mosabbir" email "test@example.com"
HGET user:1 name
HGETALL user:1
```

---

# 16. Host Configuration (redis.conf)

Host install only — Docker uses command flags or mounted config.

## File Location

```txt
/etc/redis/redis.conf
```

## Production Settings

```txt
bind 127.0.0.1
port 6379
requirepass STRONG_PASSWORD
maxmemory 256mb
maxmemory-policy allkeys-lru
appendonly yes
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command CONFIG ""
```

```bash
sudo systemctl restart redis-server
```

---

# 17. Local Development With Docker

## docker-compose.dev.yml

```yaml
services:
  redis:
    image: redis:8-alpine
    ports:
      - "6379:6379"
    command: redis-server --requirepass devpassword
    volumes:
      - redis_dev_data:/data

volumes:
  redis_dev_data:
```

Port exposure acceptable for **local Mac dev only**.

```bash
docker compose -f docker-compose.dev.yml up -d redis
redis-cli -a devpassword ping
```

---

# 18. Redis CLI And GUI Tools

## Local CLI

```bash
redis-cli -a devpassword ping
redis-cli -a devpassword
```

## VPS Via SSH Tunnel (Mac)

```bash
ssh -L 6379:127.0.0.1:6379 vps-prod
redis-cli -a PASSWORD -h localhost ping
```

## Redis Insight

Connect via SSH tunnel to `localhost:6379` with password.

✓ Good:

* SSH tunnel for production GUI access

✗ Avoid:

* exposing port 6379 for GUI tools

---

# 19. Backend Integration (Node.js)

## ioredis (Recommended)

```bash
npm install ioredis
```

```javascript
import Redis from "ioredis";

const redis = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: 3,
  lazyConnect: true,
});

redis.on("error", (err) => console.error("Redis error:", err.message));

await redis.connect();
await redis.set("key", "value", "EX", 3600);
const value = await redis.get("key");
```

## Cache Example

```javascript
async function getCachedUser(id) {
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);
  const user = await db.findUser(id);
  await redis.set(`user:${id}`, JSON.stringify(user), "EX", 300);
  return user;
}
```

## BullMQ Queue

```bash
npm install bullmq
```

```javascript
import { Queue } from "bullmq";

const emailQueue = new Queue("email", {
  connection: { url: process.env.REDIS_URL },
});
await emailQueue.add("send", { to: "user@example.com" });
```

## Verify From Backend Container

```bash
docker compose exec backend node -e "
const Redis = require('ioredis');
const r = new Redis(process.env.REDIS_URL);
r.ping().then(console.log).finally(() => r.quit());
"
```

---

# 20. Development Best Practices

✓ Good:

* separate Redis DB indexes per purpose (cache/sessions/queues)
* TTL on all cache keys
* same Redis version as production (8)
* `.env.example` documents REDIS_URL

✗ Avoid:

* `KEYS *` in production
* storing large objects in Redis
* no TTL on cache keys
* developing against production Redis

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
      redis:
        condition: service_healthy
      postgres:
        condition: service_healthy
    networks:
      - app-network

  redis:
    image: redis:8-alpine
    restart: unless-stopped
    command: >
      redis-server
      --requirepass ${REDIS_PASSWORD}
      --appendonly yes
      --maxmemory 256mb
      --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 5s
      retries: 5

volumes:
  redis_data:

networks:
  app-network:
```

## Deploy

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml up -d
docker compose exec redis redis-cli -a PASSWORD ping
```

---

# 22. Deploy With Coolify

```txt
Coolify → New Resource → Database → Redis
→ Set password
→ Deploy
→ Copy internal connection string
→ Add REDIS_URL to application env vars
```

```env
REDIS_URL=redis://:PASSWORD@CONTAINER_NAME:6379
```

See `05-coolify.md` for full setup.

---

# 23. Sessions, Cache, And Queues

## Use Case Map

| Use Case | Persistence | TTL | Library |
|----------|-------------|-----|---------|
| API cache | Optional | Yes | ioredis |
| Sessions | AOF | Session expiry | express-session + connect-redis |
| Job queue | AOF | No (processed) | BullMQ |
| Rate limit | No | Yes | ioredis / rate-limiter-flexible |
| Pub/Sub | No | N/A | ioredis / Socket.IO adapter |

## Session Store Example

```bash
npm install express-session connect-redis
```

```javascript
import session from "express-session";
import RedisStore from "connect-redis";
import { createClient } from "redis";

const redisClient = createClient({ url: process.env.REDIS_URL });
await redisClient.connect();

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { secure: true, maxAge: 86400000 },
}));
```

---

# 24. Nginx And Cloudflare Integration

Redis is internal — not proxied by Nginx or Cloudflare.

```txt
User → Cloudflare → Nginx → Backend → Redis (internal)
```

Verify Redis is not publicly reachable:

```bash
nc -zv YOUR_PUBLIC_IP 6379    # Should fail/refused
sudo ufw status | grep 6379   # Should not be allowed
```

---

# 25. Rollback And Safe Updates

## Before Redis Upgrade

```bash
docker exec redis redis-cli -a PASSWORD BGSAVE
docker cp redis:/data/dump.rdb ~/backups/redis-$(date +%F).rdb
```

## Rollback Image

```bash
cd /var/www/myapp
docker compose -f docker-compose.prod.yml pull redis
docker compose -f docker-compose.prod.yml up -d redis
```

## Rollback Data

```bash
docker compose stop backend redis
docker cp ~/backups/redis-YYYY-MM-DD.rdb redis:/data/dump.rdb
docker compose start redis backend
```

Cache data loss on restart is often acceptable — sessions/queues need backup first.

---

# 26. Production Redis Checklist

✓ Good:

* redis:8-alpine in Docker
* password authentication
* maxmemory + eviction policy set
* no public port 6379
* health check configured
* TTL on cache keys

✗ Avoid:

* public Redis port
* no password
* `KEYS *` in production code
* unlimited memory usage on small VPS

---

# 27. Network Security

```txt
✓ Redis on internal Docker network
✓ Backend connects via redis:6379
✓ UFW blocks port 6379
✓ SSH tunnel for admin CLI access

✗ bind 0.0.0.0 without firewall
✗ -p 6379:6379 in production compose
```

## Verify

```bash
docker compose exec backend nc -zv redis 6379
nc -zv YOUR_PUBLIC_IP 6379
sudo ufw deny 6379
```

---

# 28. Authentication Security

✓ Good:

* strong random password (32+ chars)
* `--requirepass` in all environments
* disable FLUSHALL/FLUSHDB/CONFIG
* rotate password periodically

✗ Avoid:

* no password in production
* default password
* shared Redis across untrusted apps without DB index separation

---

# 29. Firewall Rules

```bash
sudo ufw deny 6379
sudo ufw status verbose
```

If remote access required (not recommended):

```bash
sudo ufw allow from YOUR_HOME_IP to any port 6379 proto tcp
```

Prefer SSH tunnel:

```bash
ssh -L 6379:127.0.0.1:6379 vps-prod
redis-cli -a PASSWORD -h localhost ping
```

---

# 30. Security Checklist

✓ Good:

* Docker internal network
* AUTH enabled
* UFW denies 6379
* dangerous commands renamed/disabled
* secrets in .env

✗ Avoid:

* public Redis
* no authentication
* FLUSHALL available in production

---

# 31. Redis Logs

## Docker

```bash
docker logs redis -f
docker logs redis --tail=100 --since 1h
```

## Host Install

```bash
sudo tail -f /var/log/redis/redis-server.log
sudo journalctl -u redis-server -f
```

## Slow Log (Inside redis-cli)

```bash
docker exec -it redis redis-cli -a PASSWORD
CONFIG SET slowlog-log-slower-than 10000
SLOWLOG GET 10
```

---

# 32. Docker Container Logs

```bash
docker compose logs -f redis
docker compose logs redis --tail=200
```

## Export

```bash
docker logs redis > redis-$(date +%F).log 2>&1
```

---

# 33. Resource And Memory Monitoring

## Memory Info

```bash
docker exec redis redis-cli -a PASSWORD INFO memory
docker exec redis redis-cli -a PASSWORD INFO stats
```

Key metrics:

```txt
used_memory_human
used_memory_peak_human
maxmemory_human
evicted_keys
```

## Container Stats

```bash
docker stats redis --no-stream
```

## Host RAM

```bash
free -h
```

Set `--maxmemory` to ~70% of allocated container RAM. On shared VPS, 128–256 MB is typical for small apps.

---

# 34. Health Checks

## Docker Compose

```yaml
healthcheck:
  test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
  interval: 30s
  timeout: 5s
  retries: 5
```

## Manual

```bash
docker exec redis redis-cli -a PASSWORD ping
docker compose ps redis
```

## From Backend Health Endpoint

```javascript
app.get("/health", async (req, res) => {
  await redis.ping();
  res.json({ status: "ok" });
});
```

---

# 35. Debugging

## Connection Debug

```bash
docker compose ps
docker compose exec backend env | grep REDIS
docker compose exec backend nc -zv redis 6379
docker logs redis --tail=50
```

## Auth Debug

```bash
docker exec -it redis redis-cli -a PASSWORD ping
```

## Memory Debug

```bash
docker exec redis redis-cli -a PASSWORD INFO memory
docker exec redis redis-cli -a PASSWORD --bigkeys
```

---

# 36. Backup Strategy

```txt
Cache-only Redis  → backup optional (data is disposable)
Sessions/Queues   → daily RDB or AOF backup
Before upgrade    → always BGSAVE + copy dump.rdb
```

Schedule:

```txt
BGSAVE + copy dump.rdb  → daily (if persistence enabled)
Volume tar              → weekly
```

See `15-backup-snapshots.md` for full guide.

---

# 37. Backup Commands

## BGSAVE (Docker)

```bash
docker exec redis redis-cli -a PASSWORD BGSAVE
docker exec redis redis-cli -a PASSWORD LASTSAVE
docker cp redis:/data/dump.rdb ~/backups/redis-$(date +%F).rdb
docker cp redis:/data/appendonly.aof ~/backups/redis-$(date +%F).aof
```

## Volume Backup

```bash
docker compose stop redis
docker run --rm \
  -v myapp_redis_data:/data \
  -v ~/backups:/backup \
  alpine tar -czvf /backup/redis-volume-$(date +%F).tar.gz /data
docker compose start redis
```

## Host Install

```bash
redis-cli -a PASSWORD BGSAVE
cp /var/lib/redis/dump.rdb ~/backups/redis-$(date +%F).rdb
```

## Copy To Mac

```bash
scp vps-prod:~/backups/redis-*.rdb ./backups/
```

---

# 38. Restore Workflow

## Restore RDB (Docker)

```bash
docker compose stop backend redis
docker cp ~/backups/redis-YYYY-MM-DD.rdb redis:/data/dump.rdb
docker compose start redis
docker exec redis redis-cli -a PASSWORD ping
docker compose start backend
```

## Restore Volume

```bash
docker compose down redis
docker run --rm \
  -v myapp_redis_data:/data \
  -v ~/backups:/backup \
  alpine sh -c "rm -rf /data/* && tar -xzvf /backup/redis-volume-YYYY-MM-DD.tar.gz -C /"
docker compose up -d redis
```

## Verify

```bash
docker exec redis redis-cli -a PASSWORD DBSIZE
docker exec redis redis-cli -a PASSWORD ping
```

---

# 39. Recovery Workflow

```txt
1. Provision / restore VPS
2. Restore docker-compose.prod.yml + .env
3. Restore redis volume OR copy dump.rdb
4. docker compose up -d
5. Verify backend connects
```

Cache-only recovery (no backup needed):

```bash
docker compose up -d redis
docker compose exec redis redis-cli -a PASSWORD ping
```

Sessions/queues lost if no backup — users re-login, jobs re-queue.

---

# 40. Connection Refused

## Diagnose

```bash
docker compose ps redis
docker logs redis --tail=30
sudo systemctl status redis-server
```

## Fix

```bash
docker compose up -d redis
docker compose exec backend nc -zv redis 6379
```

---

# 41. Authentication Failed

## Symptoms

```txt
NOAUTH Authentication required
WRONGPASS invalid username-password pair
```

## Fix

```bash
docker compose exec backend env | grep REDIS
docker exec redis redis-cli -a PASSWORD ping

# URL must include password:
# redis://:PASSWORD@redis:6379
```

---

# 42. Port Already In Use

```bash
sudo ss -tlnp | grep 6379
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep 6379
```

## Fix

```bash
docker stop conflicting_container
# Dev: change to ports: - "6380:6379"
```

---

# 43. High Memory Usage

```bash
docker exec redis redis-cli -a PASSWORD INFO memory
docker exec redis redis-cli -a PASSWORD INFO stats | grep evicted
free -h
```

## Fix

```yaml
command: >
  redis-server
  --requirepass ${REDIS_PASSWORD}
  --maxmemory 256mb
  --maxmemory-policy allkeys-lru
```

Review keys without TTL:

```bash
docker exec redis redis-cli -a PASSWORD --scan --pattern '*' | head -20
```

---

# 44. Connection Refused From App

## Diagnose

```bash
docker compose exec backend nc -zv redis 6379
docker compose ps redis
docker network inspect myapp_app-network
```

## Common Causes

```txt
Wrong hostname (use "redis" not "localhost" in containers)
Missing password in REDIS_URL
Redis container not running
Wrong Docker network
```

## Fix

```env
REDIS_URL=redis://:PASSWORD@redis:6379
```

---

# 45. Container Restart Loops

```bash
docker compose ps
docker logs redis --tail=30
docker inspect redis --format='{{.State.RestartCount}}'
```

Common causes:

* corrupt AOF file
* out of memory
* invalid config

```bash
docker logs redis 2>&1 | tail -20
free -h
# Fix AOF: docker exec redis redis-check-aof --fix /data/appendonly.aof
```

---

# 46. Remove Redis Docker Container (Linux / VPS)

```bash
cd /var/www/myapp
docker compose stop redis
docker compose rm redis
docker compose down       # keeps volumes
docker compose down -v    # DESTROYS data
docker stop redis && docker rm redis
docker rmi redis:8-alpine
```

---

# 47. Remove Redis Volumes

```bash
docker volume ls | grep redis
docker compose down
docker volume rm myapp_redis_data
```

## Backup Before Remove

```bash
docker exec redis redis-cli -a PASSWORD BGSAVE
docker cp redis:/data/dump.rdb ~/backups/final-redis.rdb
docker volume rm myapp_redis_data
```

---

# 48. Remove Redis Dev Container (Mac / Docker Desktop)

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml down -v
docker rmi redis:8-alpine
docker image prune -f
```

## Verify (Mac)

```bash
docker ps -a | grep redis
docker volume ls | grep redis
nc -zv localhost 6379
```

---

# 49. Uninstall Redis On Mac

## Stop Service

```bash
brew services stop redis
```

## Uninstall

```bash
brew uninstall redis
brew cleanup
brew autoremove
```

## Remove Mac Data

```bash
rm -rf /usr/local/var/db/redis
rm -rf /opt/homebrew/var/db/redis
rm -rf ~/Library/Caches/redis
rm -rf ~/.rediscli_history
```

## Uninstall Redis Insight (Optional)

```bash
brew uninstall --cask redis-insight
rm -rf ~/Library/Application\ Support/RedisInsight
```

## Verify (Mac)

```bash
which redis-server
which redis-cli
redis-cli --version 2>&1
brew list | grep redis
```

---

# 50. Uninstall Redis On Linux (Host)

```bash
sudo systemctl stop redis-server
sudo systemctl disable redis-server
sudo apt purge -y redis-server redis-tools
sudo apt autoremove -y
sudo apt autoclean
sudo rm -rf /var/lib/redis
sudo rm -rf /var/log/redis
sudo rm -f /etc/redis/redis.conf
```

## Verify (Linux Host)

```bash
which redis-server
systemctl status redis-server
dpkg -l | grep redis
sudo ss -tlnp | grep 6379
```

---

# 51. Log Cleanup

## Docker Logs (Linux / VPS)

```bash
docker logs redis > ~/logs/redis-final.log 2>&1
truncate -s 0 $(docker inspect --format='{{.LogPath}}' redis)
```

## Host Logs (Linux)

```bash
sudo truncate -s 0 /var/log/redis/redis-server.log
sudo rm -f /var/log/redis/redis-server.log.*
sudo journalctl --vacuum-time=7d
```

## Mac Logs

```bash
rm -rf ~/Library/Logs/redis
rm -f ~/.rediscli_history
```

## Exported Logs

```bash
rm -f ~/logs/redis-*.log
```

---

# 52. Cache And Leftover Files

## Docker Cache (Linux / Mac)

```bash
docker builder prune -f
docker image rm redis:8-alpine
docker image prune -f
docker volume ls | grep redis
docker volume prune -f    # backup first
docker network prune -f
```

## Linux Host Leftovers

```bash
sudo rm -rf /var/lib/redis /var/log/redis
sudo rm -f /etc/redis/redis.conf
sudo apt autoremove -y && sudo apt autoclean
```

## Mac Leftovers

```bash
rm -rf /usr/local/var/db/redis /opt/homebrew/var/db/redis
rm -rf ~/Library/Application\ Support/RedisInsight
rm -rf ~/Library/Caches/redis
brew cleanup
```

## Old Backups

```bash
rm -f ~/backups/redis-2025-*.rdb
rm -f ~/backups/redis-2025-*.aof
```

---

# 53. Verification After Removal

## Docker (Linux / VPS)

```bash
docker ps -a | grep redis
docker volume ls | grep redis
docker images | grep redis
nc -zv localhost 6379
```

## Mac

```bash
which redis-server redis-cli
brew list | grep redis
docker ps -a | grep redis
nc -zv localhost 6379
```

## Linux Host

```bash
which redis-server
systemctl status redis-server
dpkg -l | grep redis
ls /var/lib/redis 2>&1
```

## Cleanup Checklist

✓ Good:

* containers and volumes removed (after backup)
* Mac Homebrew redis uninstalled
* logs and cache cleared
* port 6379 not listening

✗ Avoid:

* `docker volume prune` without backup when sessions/queues persisted

---

# 54. Recommended Production Workflow

```txt
1. Add redis:8-alpine to docker-compose.prod.yml
2. Set REDIS_PASSWORD in .env
3. Enable maxmemory + eviction policy
4. Connect backend via internal REDIS_URL
5. Block port 6379 in UFW
6. Set TTL on all cache keys
7. BGSAVE backup if sessions/queues enabled
8. Monitor memory weekly
```

---

# 55. Modern Workflow

```txt
Developer (Mac)
↓
Local Docker Compose (dev Redis)
↓
GitHub Push
↓
GitHub Actions / Coolify
↓
VPS Docker Compose
↓
Redis Container (internal)
↓
Backend (cache / sessions / queues)
```

---

# 56. Real-World Workflow

Example: Node.js API with Redis cache + BullMQ on Hetzner VPS.

## Setup

```bash
ssh vps-prod
cd /var/www/myapp
docker compose up -d
docker compose exec redis redis-cli -a PASSWORD ping
```

## Daily Backup Cron (Sessions Enabled)

```cron
0 3 * * * docker exec redis redis-cli -a PASSWORD BGSAVE && docker cp redis:/data/dump.rdb /home/mosabbir/backups/redis-$(date +\%F).rdb
```

## Debug From Mac

```bash
ssh -L 6379:127.0.0.1:6379 vps-prod
redis-cli -a PASSWORD -h localhost INFO memory
```

---

# 57. Final Production Checklist

## Redis Container

✓ redis:8-alpine
✓ password authentication
✓ maxmemory + allkeys-lru
✓ no public port 6379
✓ health check configured
✓ TTL on cache keys

## Security

✓ UFW blocks 6379
✓ FLUSHALL/FLUSHDB disabled
✓ REDIS_URL in .env (chmod 600)

## Operations

✓ memory monitored weekly
✓ backup if sessions/queues enabled
✓ eviction policy appropriate for use case

## Full Stack

```txt
User → Cloudflare → Nginx → Backend → Redis (internal)
```

---

## Redis Quick Commands Cheat Sheet

```bash
# Start
docker compose up -d redis
docker compose ps redis

# Health
docker exec redis redis-cli -a PASSWORD ping

# CLI
docker exec -it redis redis-cli -a PASSWORD

# Memory
docker exec redis redis-cli -a PASSWORD INFO memory

# Logs
docker logs redis -f

# Backup
docker exec redis redis-cli -a PASSWORD BGSAVE
docker cp redis:/data/dump.rdb ~/backups/

# Stats
docker stats redis --no-stream

# Cleanup (VPS / Docker)
docker compose down
docker compose down -v     # DESTROYS data
docker volume prune -f   # backup first

# Uninstall Mac
brew services stop redis
brew uninstall redis
rm -rf /opt/homebrew/var/db/redis ~/.rediscli_history

# Uninstall Linux (host)
sudo apt purge -y redis-server redis-tools
sudo rm -rf /var/lib/redis /var/log/redis
```
