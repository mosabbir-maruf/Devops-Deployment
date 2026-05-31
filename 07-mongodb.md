# MongoDB

## Table Of Contents

### Fundamentals

1. [What Is MongoDB](#1-what-is-mongodb)
2. [MongoDB In Production](#2-mongodb-in-production)
3. [Production Architecture](#3-production-architecture)
4. [Production Folder Structure](#4-production-folder-structure)
5. [Docker-First vs Host Install](#5-docker-first-vs-host-install)

### Installation

6. [Install MongoDB With Docker (Recommended)](#6-install-mongodb-with-docker-recommended)
7. [Install MongoDB On Linux (Host)](#7-install-mongodb-on-linux-host)
8. [Install MongoDB Tools On Mac](#8-install-mongodb-tools-on-mac)
9. [Verify MongoDB Installation](#9-verify-mongodb-installation)

### Configuration

10. [Docker Compose Production Setup](#10-docker-compose-production-setup)
11. [Environment Variables](#11-environment-variables)
12. [Create Database And User](#12-create-database-and-user)
13. [Connection Strings](#13-connection-strings)
14. [Authentication And Authorization](#14-authentication-and-authorization)
15. [Indexes](#15-indexes)
16. [Host Configuration (mongod.conf)](#16-host-configuration-mongodconf)

### Development Workflow

17. [Local Development With Docker](#17-local-development-with-docker)
18. [MongoDB Shell (mongosh)](#18-mongodb-shell-mongosh)
19. [MongoDB Compass (Mac)](#19-mongodb-compass-mac)
20. [Development Best Practices](#20-development-best-practices)

### Production Workflow

21. [Production Docker Compose Stack](#21-production-docker-compose-stack)
22. [Deploy With Coolify](#22-deploy-with-coolify)
23. [Backend Integration (Node.js)](#23-backend-integration-nodejs)
24. [Nginx And Cloudflare Integration](#24-nginx-and-cloudflare-integration)
25. [Rollback And Safe Updates](#25-rollback-and-safe-updates)
26. [Production MongoDB Checklist](#26-production-mongodb-checklist)

### Security Best Practices

27. [Network Security](#27-network-security)
28. [Authentication Security](#28-authentication-security)
29. [Firewall Rules](#29-firewall-rules)
30. [Security Checklist](#30-security-checklist)

### Monitoring And Logging

31. [MongoDB Logs](#31-mongodb-logs)
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

40. [MongoDB Not Starting](#40-mongodb-not-starting)
41. [Authentication Failed](#41-authentication-failed)
42. [Port Already In Use](#42-port-already-in-use)
43. [Connection Refused From App](#43-connection-refused-from-app)
44. [High Storage Usage](#44-high-storage-usage)
45. [Container Restart Loops](#45-container-restart-loops)

### Cleanup And Uninstall

46. [Remove MongoDB Docker Container (Linux / VPS)](#46-remove-mongodb-docker-container-linux--vps)
47. [Remove MongoDB Volumes](#47-remove-mongodb-volumes)
48. [Remove MongoDB Dev Container (Mac / Docker Desktop)](#48-remove-mongodb-dev-container-mac--docker-desktop)
49. [Uninstall MongoDB On Mac](#49-uninstall-mongodb-on-mac)
50. [Uninstall MongoDB On Linux (Host)](#50-uninstall-mongodb-on-linux-host)
51. [Log Cleanup](#51-log-cleanup)
52. [Cache And Leftover Files](#52-cache-and-leftover-files)
53. [Verification After Removal](#53-verification-after-removal)

### Production Workflows

54. [Recommended Production Workflow](#54-recommended-production-workflow)
55. [Modern Workflow](#55-modern-workflow)
56. [Real-World Workflow](#56-real-world-workflow)
57. [Final Production Checklist](#57-final-production-checklist)

---

# 1. What Is MongoDB

MongoDB is a NoSQL document database that stores data as JSON-like BSON documents in collections.

Production use cases:

* flexible schema APIs
* content management systems
* real-time analytics
* microservices with document models

Recommended version: **MongoDB 8** via official Docker image `mongo:8`.

---

# 2. MongoDB In Production

In a modern stack, MongoDB runs as a **Docker container** on the VPS — never exposed publicly.

```txt
User
↓
Cloudflare
↓
Nginx
↓
Backend (Node.js)
↓
MongoDB Container (internal network only)
```

MongoDB is never accessed directly by users — only by the backend over the Docker network.

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
MongoDB Container
↓
Redis Container (optional cache)
```

Internal Docker network:

```txt
backend → mongodb:27017
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
MongoDB volume persists data
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
    └── mongodb/
        ├── 2026-06-01/
        └── latest -> 2026-06-01/
```

## Docker Volume (Managed By Docker)

```txt
/var/lib/docker/volumes/myapp_mongodb_data/_data/
└── (MongoDB data files — do not edit manually)
```

## Host Install (Legacy)

```txt
/etc/mongod.conf
/var/lib/mongodb/
/var/log/mongodb/
```

---

# 5. Docker-First vs Host Install

| Approach | Use Case |
|----------|----------|
| **Docker (recommended)** | All production deployments |
| **Host install (legacy)** | Existing bare-metal setups only |
| **Coolify database** | Managed MongoDB from Coolify dashboard |

Production rule:

```txt
✓ MongoDB in Docker container
✓ Persistent Docker volume
✓ Internal Docker network only
✗ Port 27017 exposed publicly
✗ MongoDB installed directly on VPS for new projects
```

---

# 6. Install MongoDB With Docker (Recommended)

## Pull Official Image

```bash
docker pull mongo:8
```

## Run Single Container (Testing)

```bash
docker run -d \
  --name mongodb \
  --restart unless-stopped \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=STRONG_PASSWORD \
  -v mongodb_data:/data/db \
  mongo:8
```

Note: no `-p 27017:27017` — keep MongoDB off the public host in production.

## Verify

```bash
docker ps | grep mongodb
docker logs mongodb --tail=20
docker exec -it mongodb mongosh -u admin -p
```

---

# 7. Install MongoDB On Linux (Host)

Legacy approach — use Docker for new projects.

## Import GPG Key (Ubuntu 24.04)

```bash
curl -fsSL https://pgp.mongodb.com/server-8.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
```

## Add Repository

```bash
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
```

## Install

```bash
sudo apt update
sudo apt install -y mongodb-org
```

## Enable And Start

```bash
sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod
```

---

# 8. Install MongoDB Tools On Mac

Mac is for development access — not running production MongoDB.

## MongoDB Compass (GUI)

Download from [mongodb.com/products/compass](https://www.mongodb.com/products/compass)

## mongosh via Homebrew

```bash
brew tap mongodb/brew
brew install mongodb-community@8.0
brew install mongosh
mongosh --version
```

## Connect To VPS MongoDB Via SSH Tunnel

```bash
ssh -L 27017:127.0.0.1:27017 vps-prod
mongosh mongodb://admin:PASSWORD@localhost:27017
```

---

# 9. Verify MongoDB Installation

## Docker

```bash
docker ps | grep mongo
docker exec mongodb mongosh --eval "db.adminCommand('ping')"
docker exec mongodb mongod --version
```

## Host Install

```bash
mongod --version
mongosh --version
sudo systemctl status mongod
sudo ss -tlnp | grep 27017
```

Expected Docker output:

```txt
{ ok: 1 }
```

---

# 10. Docker Compose Production Setup

```yaml
services:
  mongodb:
    image: mongo:8
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_DB}
    volumes:
      - mongodb_data:/data/db
      - ./mongo-init:/docker-entrypoint-initdb.d:ro
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
    # NO ports section — internal network only

volumes:
  mongodb_data:

networks:
  app-network:
    driver: bridge
```

## Start

```bash
docker compose -f docker-compose.prod.yml up -d mongodb
docker compose ps mongodb
```

---

# 11. Environment Variables

## .env (Server Only)

```env
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=long-random-secret-here
MONGO_DB=myapp
MONGO_USER=myapp_user
MONGO_USER_PASSWORD=another-long-secret
```

## Backend Connection

```env
MONGODB_URI=mongodb://myapp_user:PASSWORD@mongodb:27017/myapp?authSource=myapp
```

## Rules

```txt
✓ Secrets in .env (chmod 600)
✓ Different passwords per environment
✗ Commit .env to GitHub
✗ Hardcode credentials in docker-compose.yml
```

---

# 12. Create Database And User

## Via mongosh (Docker)

```bash
docker exec -it mongodb mongosh -u admin -p
```

```javascript
use myapp

db.createUser({
  user: "myapp_user",
  pwd: "STRONG_APP_PASSWORD",
  roles: [{ role: "readWrite", db: "myapp" }]
})

db.users.insertOne({ name: "test", email: "test@example.com" })
db.users.find()
```

## Init Script (docker-entrypoint-initdb.d/init.js)

```javascript
db = db.getSiblingDB("myapp");

db.createUser({
  user: "myapp_user",
  pwd: "STRONG_APP_PASSWORD",
  roles: [{ role: "readWrite", db: "myapp" }]
});
```

Runs automatically on first container start.

---

# 13. Connection Strings

## Internal (Docker Network — Production)

```txt
mongodb://myapp_user:PASSWORD@mongodb:27017/myapp?authSource=myapp
```

## Local Dev (Docker Compose)

```txt
mongodb://myapp_user:PASSWORD@localhost:27017/myapp?authSource=myapp
```

## With Root User (Admin Tasks Only)

```txt
mongodb://admin:PASSWORD@mongodb:27017/admin
```

## Node.js (Mongoose)

```javascript
import mongoose from "mongoose";

await mongoose.connect(process.env.MONGODB_URI);
```

---

# 14. Authentication And Authorization

## Enable Auth (Host Install)

```bash
sudo nano /etc/mongod.conf
```

```yaml
security:
  authorization: enabled
```

```bash
sudo systemctl restart mongod
```

## Docker

Authentication enabled automatically when `MONGO_INITDB_ROOT_USERNAME` is set.

## Login

```bash
docker exec -it mongodb mongosh -u myapp_user -p --authenticationDatabase myapp
```

✓ Good:

* app user with `readWrite` on one database only
* root user for admin tasks only

✗ Avoid:

* root credentials in application code
* no authentication in production

---

# 15. Indexes

## Create Index

```javascript
db.users.createIndex({ email: 1 }, { unique: true })
db.posts.createIndex({ createdAt: -1 })
db.posts.createIndex({ userId: 1, status: 1 })
```

## List Indexes

```javascript
db.users.getIndexes()
```

## Explain Query

```javascript
db.users.find({ email: "test@example.com" }).explain("executionStats")
```

Create indexes for all frequently queried fields in production.

---

# 16. Host Configuration (mongod.conf)

Host install only — Docker handles config via env vars.

## File Location

```txt
/etc/mongod.conf
```

## Production Settings

```yaml
storage:
  dbPath: /var/lib/mongodb

systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true

net:
  port: 27017
  bindIp: 127.0.0.1

security:
  authorization: enabled
```

```bash
sudo systemctl restart mongod
```

`bindIp: 127.0.0.1` — localhost only. Docker containers use internal network instead.

---

# 17. Local Development With Docker

## docker-compose.dev.yml

```yaml
services:
  mongodb:
    image: mongo:8
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: devpassword
    volumes:
      - mongodb_dev_data:/data/db

volumes:
  mongodb_dev_data:
```

Port exposure is acceptable for **local Mac dev only**.

```bash
docker compose -f docker-compose.dev.yml up -d mongodb
mongosh mongodb://admin:devpassword@localhost:27017
```

---

# 18. MongoDB Shell (mongosh)

## Connect (Docker)

```bash
docker exec -it mongodb mongosh -u admin -p
```

## Common Commands

```javascript
show dbs
use myapp
show collections
db.users.find()
db.users.findOne({ email: "test@example.com" })
db.users.countDocuments()
db.stats()
```

## Delete Database (Careful)

```javascript
use myapp
db.dropDatabase()
```

---

# 19. MongoDB Compass (Mac)

## Connect Via SSH Tunnel

Terminal 1:

```bash
ssh -L 27017:127.0.0.1:27017 vps-prod
```

Compass connection string:

```txt
mongodb://admin:PASSWORD@localhost:27017
```

## Connect To Local Dev

```txt
mongodb://admin:devpassword@localhost:27017
```

✓ Good:

* SSH tunnel for production access
* read-only Compass user for debugging

✗ Avoid:

* exposing MongoDB port publicly for Compass access

---

# 20. Development Best Practices

✓ Good:

* Docker Compose for local MongoDB
* same MongoDB version as production (8)
* seed data scripts in repo
* `.env.example` documents connection vars

✗ Avoid:

* developing against production database
* no authentication in shared dev environments

---

# 21. Production Docker Compose Stack

Full stack with backend:

```yaml
services:
  backend:
    image: youruser/myapp-backend:${TAG:-latest}
    restart: unless-stopped
    env_file:
      - .env
    depends_on:
      mongodb:
        condition: service_healthy
    networks:
      - app-network

  mongodb:
    image: mongo:8
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
    volumes:
      - mongodb_data:/data/db
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 5

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
  mongodb_data:

networks:
  app-network:
```

## Deploy

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml up -d
docker compose ps
```

---

# 22. Deploy With Coolify

Coolify can manage MongoDB as a database resource.

```txt
Coolify → New Resource → Database → MongoDB
→ Set credentials
→ Deploy
→ Copy internal connection string
→ Add to application env vars
```

Connection string in Coolify app settings:

```env
MONGODB_URI=mongodb://user:pass@CONTAINER_NAME:27017/myapp
```

See `05-coolify.md` for full Coolify database setup.

---

# 23. Backend Integration (Node.js)

## Mongoose

```bash
npm install mongoose
```

```javascript
import mongoose from "mongoose";

const connectDB = async () => {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log("MongoDB connected");
};

connectDB().catch((err) => {
  console.error("MongoDB connection failed:", err.message);
  process.exit(1);
});
```

## Native Driver

```bash
npm install mongodb
```

```javascript
import { MongoClient } from "mongodb";

const client = new MongoClient(process.env.MONGODB_URI);
await client.connect();
const db = client.db("myapp");
```

## Verify From Backend Container

```bash
docker compose exec backend node -e "
const { MongoClient } = require('mongodb');
MongoClient.connect(process.env.MONGODB_URI).then(() => console.log('OK')).catch(console.error);
"
```

---

# 24. Nginx And Cloudflare Integration

MongoDB is **not** behind Nginx — it is internal only.

```txt
User → Cloudflare → Nginx → Backend → MongoDB (internal)
```

Cloudflare and Nginx protect the API — MongoDB never faces the public internet.

Verify MongoDB is not publicly reachable:

```bash
nc -zv YOUR_PUBLIC_IP 27017   # Should fail/refused
sudo ufw status | grep 27017  # Should not be allowed
```

---

# 25. Rollback And Safe Updates

## Before MongoDB Upgrade

```bash
# Backup first
docker exec mongodb mongodump --uri="mongodb://admin:PASS@localhost:27017" --out=/tmp/backup
docker cp mongodb:/tmp/backup ~/backups/mongodb-$(date +%F)
```

## Rollback Image Tag

```bash
cd /var/www/myapp
# Pin to previous image in compose or:
docker compose -f docker-compose.prod.yml pull mongodb
docker compose -f docker-compose.prod.yml up -d mongodb
```

## Rollback Data

```bash
docker compose stop backend
docker exec mongodb mongorestore --drop /tmp/backup
docker compose start backend
```

Never upgrade MongoDB major versions without reading release notes and testing backups.

---

# 26. Production MongoDB Checklist

✓ Good:

* MongoDB 8 in Docker
* persistent volume
* authentication enabled
* port 27017 not public
* app-specific user (not root)
* backups scheduled
* health check configured

✗ Avoid:

* public port 27017
* no authentication
* root user in app connection string
* no backups

---

# 27. Network Security

Production network rules:

```txt
✓ MongoDB on internal Docker network
✓ Backend connects via service name (mongodb:27017)
✓ UFW blocks port 27017
✓ SSH tunnel for admin access from Mac

✗ bindIp: 0.0.0.0 without firewall
✗ -p 27017:27017 in production compose
```

## Verify Internal Connectivity

```bash
docker compose exec backend nc -zv mongodb 27017
```

## Verify External Block

```bash
nc -zv YOUR_PUBLIC_IP 27017
sudo ufw deny 27017
```

---

# 28. Authentication Security

✓ Good:

* strong passwords (32+ chars random)
* separate root and app users
* app user scoped to one database
* rotate credentials periodically

✗ Avoid:

* default passwords
* shared credentials across environments
* admin user in application code

---

# 29. Firewall Rules

```bash
sudo ufw deny 27017
sudo ufw status verbose
```

If remote access absolutely required (not recommended):

```bash
sudo ufw allow from YOUR_HOME_IP to any port 27017 proto tcp
```

Prefer SSH tunnel instead:

```bash
ssh -L 27017:127.0.0.1:27017 vps-prod
```

---

# 30. Security Checklist

✓ Good:

* Docker internal network only
* authentication enabled
* UFW denies 27017
* secrets in .env
* regular backups
* MongoDB image updated

✗ Avoid:

* public MongoDB port
* no auth
* credentials in Git

---

# 31. MongoDB Logs

## Docker

```bash
docker logs mongodb -f
docker logs mongodb --tail=100 --since 1h
```

## Host Install

```bash
sudo tail -f /var/log/mongodb/mongod.log
sudo journalctl -u mongod -f
```

## Enable Slow Query Log (Host)

```yaml
# mongod.conf
operationProfiling:
  mode: slowOp
  slowOpThresholdMs: 100
```

---

# 32. Docker Container Logs

```bash
docker compose logs -f mongodb
docker compose logs mongodb --tail=200
```

## Export Logs

```bash
docker logs mongodb > mongodb-$(date +%F).log 2>&1
```

---

# 33. Resource Monitoring

## Disk Usage

```bash
docker system df
docker exec mongodb du -sh /data/db
du -sh /var/lib/docker/volumes/myapp_mongodb_data
df -h
```

## Container Stats

```bash
docker stats mongodb --no-stream
```

## Database Stats (mongosh)

```javascript
db.stats()
db.users.stats()
```

---

# 34. Health Checks

## Docker Compose

```yaml
healthcheck:
  test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 30s
```

## Manual Check

```bash
docker exec mongodb mongosh --eval "db.adminCommand('ping')"
docker compose ps mongodb
```

## From Backend

```bash
docker compose exec backend node -e "
require('mongodb').MongoClient.connect(process.env.MONGODB_URI)
  .then(c => { console.log('OK'); c.close(); })
  .catch(e => { console.error(e); process.exit(1); });
"
```

---

# 35. Debugging

## Connection Debug

```bash
docker compose ps
docker compose exec backend env | grep MONGO
docker compose exec backend nc -zv mongodb 27017
docker logs mongodb --tail=50
```

## Auth Debug

```bash
docker exec -it mongodb mongosh -u myapp_user -p --authenticationDatabase myapp
```

## Inspect Container

```bash
docker inspect mongodb | grep -A10 State
docker volume inspect myapp_mongodb_data
```

---

# 36. Backup Strategy

Production backup layers:

```txt
1. mongodump daily (logical backup)
2. Docker volume snapshot weekly
3. VPS snapshot monthly
4. Offsite copy (S3, another server)
5. Test restore monthly
```

Schedule:

```txt
mongodump  → daily at 2 AM
volume tar → weekly
VPS snap   → before major upgrades
```

See `15-backup-snapshots.md` for full backup guide.

---

# 37. Backup Commands

## mongodump (Docker)

```bash
docker exec mongodb mongodump \
  --uri="mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASSWORD}@localhost:27017" \
  --out=/tmp/backup-$(date +%F)

docker cp mongodb:/tmp/backup-$(date +%F) ~/backups/mongodb/
```

## Single Database

```bash
docker exec mongodb mongodump \
  --uri="mongodb://myapp_user:PASS@localhost:27017/myapp?authSource=myapp" \
  --out=/tmp/myapp-backup
```

## Volume Backup

```bash
docker compose stop mongodb
docker run --rm \
  -v myapp_mongodb_data:/data \
  -v ~/backups:/backup \
  alpine tar -czvf /backup/mongodb-volume-$(date +%F).tar.gz /data
docker compose start mongodb
```

## Export Collection (JSON)

```bash
docker exec mongodb mongoexport \
  --uri="mongodb://myapp_user:PASS@localhost:27017/myapp?authSource=myapp" \
  --collection=users \
  --out=/tmp/users.json

docker cp mongodb:/tmp/users.json ~/backups/
```

## Copy To Mac

```bash
scp -r vps-prod:~/backups/mongodb/ ./backups/
```

---

# 38. Restore Workflow

## mongorestore

```bash
docker cp ~/backups/mongodb/2026-06-01 mongodb:/tmp/restore
docker exec mongodb mongorestore \
  --uri="mongodb://admin:PASS@localhost:27017" \
  --drop /tmp/restore
```

## Restore Single Database

```bash
docker exec mongodb mongorestore \
  --uri="mongodb://admin:PASS@localhost:27017" \
  --nsInclude="myapp.*" \
  /tmp/restore
```

## Restore Volume

```bash
docker compose down mongodb
docker run --rm \
  -v myapp_mongodb_data:/data \
  -v ~/backups:/backup \
  alpine sh -c "rm -rf /data/* && tar -xzvf /backup/mongodb-volume-YYYY-MM-DD.tar.gz -C /"
docker compose up -d mongodb
```

## Verify Restore

```bash
docker exec -it mongodb mongosh -u myapp_user -p --authenticationDatabase myapp
db.users.countDocuments()
```

---

# 39. Recovery Workflow

Complete data loss recovery:

```txt
1. Provision VPS / restore VPS snapshot
2. Install Docker
3. Restore docker-compose.prod.yml + .env
4. Restore mongodb volume OR mongorestore from dump
5. docker compose up -d
6. Verify backend connects
7. Verify data integrity
```

Emergency — container corrupted but volume intact:

```bash
docker compose down mongodb
docker compose up -d mongodb
docker compose logs mongodb
```

---

# 40. MongoDB Not Starting

## Diagnose

```bash
docker compose ps -a
docker logs mongodb --tail=50
docker inspect mongodb | grep -A5 State
```

## Host Install

```bash
sudo systemctl status mongod
sudo journalctl -u mongod --since "10 min ago"
```

## Common Fixes

```txt
Corrupt lock file     → remove /data/db/mongod.lock (careful, backup first)
Out of disk space     → df -h, docker system prune
Wrong permissions     → docker volume permissions
Port conflict         → ss -tlnp | grep 27017
```

```bash
df -h
docker compose down && docker compose up -d mongodb
```

---

# 41. Authentication Failed

## Symptoms

```txt
Authentication failed
MongoServerError: Authentication failed
```

## Fix Checklist

```bash
# Verify credentials in .env
docker compose exec backend env | grep MONGO

# Test login manually
docker exec -it mongodb mongosh -u myapp_user -p --authenticationDatabase myapp

# Check authSource in connection string
# mongodb://user:pass@mongodb:27017/myapp?authSource=myapp
```

Common causes:

* wrong password
* wrong `authSource`
* user not created
* auth not enabled

---

# 42. Port Already In Use

```bash
sudo ss -tlnp | grep 27017
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep 27017
```

## Fix

```bash
docker stop conflicting_container
# or change dev compose port:
# ports: - "27018:27017"
```

---

# 43. Connection Refused From App

## Diagnose

```bash
docker compose exec backend nc -zv mongodb 27017
docker compose ps mongodb
docker network ls
docker network inspect myapp_app-network
```

## Common Causes

```txt
Wrong hostname (use "mongodb" not "localhost" inside containers)
Not on same Docker network
MongoDB container not running
MONGODB_URI typo
```

## Fix Connection String

```env
# Inside Docker — use service name
MONGODB_URI=mongodb://user:pass@mongodb:27017/myapp?authSource=myapp

# NOT localhost inside backend container
```

---

# 44. High Storage Usage

```bash
docker exec mongodb du -sh /data/db
df -h
db.stats()
```

## Find Large Collections

```javascript
db.getCollectionNames().forEach(c => print(c, db[c].stats().size))
```

## Compact (Host / Maintenance Window)

```javascript
db.runCommand({ compact: "users" })
```

Plan disk upgrades before reaching 85% capacity.

---

# 45. Container Restart Loops

```bash
docker compose ps
docker logs mongodb --tail=30
docker inspect mongodb --format='{{.State.RestartCount}}'
```

Common causes:

* out of memory
* corrupt data files
* wrong env vars
* volume permission issues

```bash
docker logs mongodb 2>&1 | tail -20
free -h
```

---

# 46. Remove MongoDB Docker Container (Linux / VPS)

Production MongoDB runs on the VPS via Docker Compose.

## Stop And Remove Container

```bash
cd /var/www/myapp
docker compose stop mongodb
docker compose rm mongodb
```

## Remove Full Stack

```bash
docker compose down
```

Warning: `docker compose down -v` deletes volumes and **all database data**.

## Remove Standalone Container

```bash
docker stop mongodb
docker rm mongodb
```

## Remove Image

```bash
docker rmi mongo:8
```

---

# 47. Remove MongoDB Volumes

## List Volumes

```bash
docker volume ls | grep mongo
```

## Remove Volume (Destroys All Data)

```bash
docker compose down
docker volume rm myapp_mongodb_data
```

## Backup Before Remove

```bash
docker run --rm \
  -v myapp_mongodb_data:/data \
  -v ~/backups:/backup \
  alpine tar -czvf /backup/final-mongodb-backup.tar.gz /data
docker volume rm myapp_mongodb_data
```

✓ Good:

* backup before removing any volume

✗ Avoid:

* `docker volume rm` without backup in production

---

# 48. Remove MongoDB Dev Container (Mac / Docker Desktop)

Local dev MongoDB from `docker-compose.dev.yml` on Mac.

## Stop Dev Stack

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml stop mongodb
docker compose -f docker-compose.dev.yml rm mongodb
```

## Remove Dev Stack And Volume

```bash
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml down -v
```

## Remove Dev Image

```bash
docker rmi mongo:8
docker image prune -f
```

## Verify (Mac)

```bash
docker ps -a | grep mongo
docker volume ls | grep mongo
nc -zv localhost 27017
```

Expected: no dev containers, port 27017 closed.

---

# 49. Uninstall MongoDB On Mac

For Homebrew-installed `mongosh` and `mongodb-community` — not production VPS MongoDB.

## Stop Local MongoDB Service (If Running)

```bash
brew services stop mongodb-community@8.0
```

## Uninstall mongosh And MongoDB Community

```bash
brew uninstall mongosh
brew uninstall mongodb-community@8.0
brew untap mongodb/brew
```

## Uninstall MongoDB Compass (GUI)

```txt
Finder → Applications → MongoDB Compass → Move to Trash
```

Or if installed via Homebrew cask:

```bash
brew uninstall --cask mongodb-compass
```

## Remove Mac Data Directories

```bash
rm -rf ~/data/db
rm -rf /usr/local/var/mongodb
rm -rf /opt/homebrew/var/mongodb
rm -rf ~/.mongodb
rm -rf ~/Library/Caches/mongodb-compass
rm -rf ~/Library/Application\ Support/MongoDB\ Compass
rm -rf ~/Library/Logs/MongoDB
```

## Remove Homebrew Leftovers

```bash
brew cleanup
brew autoremove
```

## Verify (Mac)

```bash
which mongosh
which mongod
mongosh --version 2>&1
brew list | grep mongo
ls ~/Library/Application\ Support/ | grep -i mongo
```

Expected: commands not found, no mongo packages listed.

---

# 50. Uninstall MongoDB On Linux (Host)

Legacy host install only — production should use Docker.

## Stop And Disable Service

```bash
sudo systemctl stop mongod
sudo systemctl disable mongod
```

## Remove Packages

```bash
sudo apt purge -y mongodb-org mongodb-org-database mongodb-org-server \
  mongodb-org-mongos mongodb-org-tools
sudo apt autoremove -y
sudo apt autoclean
```

## Remove Repository And Key

```bash
sudo rm -f /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo rm -f /usr/share/keyrings/mongodb-server-8.0.gpg
```

## Remove Data, Logs, Config

```bash
sudo rm -rf /var/lib/mongodb
sudo rm -rf /var/log/mongodb
sudo rm -f /etc/mongod.conf
sudo rm -rf /tmp/mongodb-*
```

## Verify (Linux Host)

```bash
which mongod
which mongosh
systemctl status mongod
dpkg -l | grep mongo
sudo ss -tlnp | grep 27017
```

Expected: commands not found, service not found, port closed.

---

# 51. Log Cleanup

## Docker Logs (Linux / VPS)

```bash
# Truncate container logs without removing container
truncate -s 0 $(docker inspect --format='{{.LogPath}}' mongodb)

# Or restart with log rotation in compose:
# logging:
#   driver: json-file
#   options:
#     max-size: "10m"
#     max-file: "3"
```

## Docker Compose Log Export Then Clear

```bash
docker logs mongodb > ~/logs/mongodb-final.log 2>&1
docker compose restart mongodb
```

## Host Install Logs (Linux)

```bash
sudo truncate -s 0 /var/log/mongodb/mongod.log
sudo rm -f /var/log/mongodb/mongod.log.*
sudo journalctl --vacuum-time=7d
```

## Mac Logs

```bash
rm -rf ~/Library/Logs/MongoDB
rm -rf ~/Library/Logs/mongodb-compass
rm -rf ~/Library/Application\ Support/MongoDB Compass/Cache
```

## Exported Backup Logs (Safe To Delete)

```bash
rm -f ~/logs/mongodb-*.log
rm -f ~/backups/mongodb/*.log
```

---

# 52. Cache And Leftover Files

## Docker Cache (Linux / Mac)

```bash
docker builder prune -f
docker image prune -f
docker image rm mongo:8
docker system prune -f
```

Remove unused MongoDB volumes (backup first):

```bash
docker volume ls | grep mongo
docker volume prune -f
```

Warning: `docker volume prune` deletes unused volumes permanently.

## Linux Host Leftovers

```bash
sudo rm -rf /var/lib/mongodb
sudo rm -rf /var/log/mongodb
sudo rm -f /etc/mongod.conf
sudo rm -rf /tmp/mongodb-*
sudo apt autoremove -y
sudo apt autoclean
```

## Mac Leftovers

```bash
rm -rf ~/data/db
rm -rf /usr/local/var/mongodb
rm -rf /opt/homebrew/var/mongodb
rm -rf ~/.mongodb
rm -rf ~/Library/Caches/mongodb-compass
rm -rf ~/Library/Application\ Support/MongoDB\ Compass
rm -rf ~/Library/Saved\ Application\ State/com.mongodb.compass.savedState
brew cleanup
```

## Old Backup Files

```bash
ls ~/backups/mongodb/
rm -rf ~/backups/mongodb/2025-*
rm -f ~/backups/mongodb-dump-*.tar.gz
```

## mongosh History And Temp Files

```bash
rm -f ~/.mongosh/mongosh.db
rm -rf ~/.mongosh/snippets
rm -f /tmp/mongodb-*
```

## Orphan Docker Networks

```bash
docker network ls | grep myapp
docker network prune -f
```

---

# 53. Verification After Removal

## Docker (Linux / VPS)

```bash
docker ps -a | grep mongo
docker volume ls | grep mongo
docker images | grep mongo
nc -zv localhost 27017
```

Expected: no containers, no volumes (if removed), no images, port closed.

## Mac

```bash
which mongosh
which mongod
brew list | grep mongo
docker ps -a | grep mongo
docker volume ls | grep mongo
nc -zv localhost 27017
ls ~/Library/Application\ Support/ | grep -i mongo
```

Expected: commands not found, no brew mongo packages, no dev containers, port closed.

## Linux Host

```bash
which mongod
which mongosh
systemctl status mongod
dpkg -l | grep mongo
sudo ss -tlnp | grep 27017
ls /var/lib/mongodb 2>&1
```

Expected: commands not found, service absent, port closed, data directory gone.

## Cleanup Checklist

✓ Good:

* containers removed
* volumes backed up then removed (if intended)
* Mac Homebrew packages uninstalled
* log and cache directories cleared
* port 27017 not listening

✗ Avoid:

* `docker volume prune` without backup
* leaving `mongodb-community` running on Mac after switching to Docker-only dev

---

# 54. Recommended Production Workflow

```txt
1. Add MongoDB to docker-compose.prod.yml
2. Configure auth env vars in .env
3. Create app user via init script
4. Connect backend via internal network
5. Block port 27017 in UFW
6. Schedule daily mongodump backups
7. Monitor disk usage weekly
8. Test restore monthly
```

---

# 55. Modern Workflow

```txt
Developer (Mac)
↓
Local Docker Compose (dev MongoDB)
↓
GitHub Push
↓
GitHub Actions / Coolify
↓
VPS Docker Compose
↓
MongoDB Container (volume persists)
↓
Backend connects internally
```

---

# 56. Real-World Workflow

Example: Node.js API with MongoDB on Hetzner VPS.

## Setup

```bash
ssh vps-prod
cd /var/www/myapp
# docker-compose.prod.yml includes mongodb service
docker compose up -d
docker compose exec mongodb mongosh --eval "db.adminCommand('ping')"
```

## Daily Backup Cron

```bash
crontab -e
```

```cron
0 2 * * * docker exec mongodb mongodump --uri="mongodb://admin:PASS@localhost:27017" --out=/tmp/backup && docker cp mongodb:/tmp/backup /home/mosabbir/backups/mongodb/$(date +\%F)
```

## Access From Mac (Debug)

```bash
ssh -L 27017:127.0.0.1:27017 vps-prod
# Open MongoDB Compass → localhost:27017
```

---

# 57. Final Production Checklist

## MongoDB Container

✓ mongo:8 image
✓ persistent volume
✓ authentication enabled
✓ health check configured
✓ no public port mapping
✓ app user (not root) in backend

## Security

✓ UFW blocks 27017
✓ secrets in .env (chmod 600)
✓ SSH tunnel for admin GUI access

## Operations

✓ daily mongodump backups
✓ restore tested
✓ disk monitoring enabled
✓ indexes on queried fields

## Full Stack

```txt
User → Cloudflare → Nginx → Backend → MongoDB (internal)
```

---

## MongoDB Quick Commands Cheat Sheet

```bash
# Start
docker compose up -d mongodb
docker compose ps mongodb

# Shell
docker exec -it mongodb mongosh -u admin -p

# Health
docker exec mongodb mongosh --eval "db.adminCommand('ping')"

# Logs
docker logs mongodb -f

# Backup
docker exec mongodb mongodump --uri="mongodb://admin:PASS@localhost:27017" --out=/tmp/backup
docker cp mongodb:/tmp/backup ~/backups/

# Restore
docker exec mongodb mongorestore /tmp/backup

# Stats
docker stats mongodb --no-stream
docker exec mongodb du -sh /data/db

# Cleanup (VPS / Docker)
docker compose down        # keeps volume
docker compose down -v     # DESTROYS data
docker volume prune -f     # backup first

# Uninstall Mac (Homebrew)
brew services stop mongodb-community@8.0
brew uninstall mongosh mongodb-community@8.0
brew uninstall --cask mongodb-compass
rm -rf ~/.mongodb ~/Library/Logs/MongoDB ~/Library/Caches/mongodb-compass

# Uninstall Linux (host)
sudo apt purge -y mongodb-org* && sudo apt autoremove -y
sudo rm -rf /var/lib/mongodb /var/log/mongodb
```
