# Node.js & npm

## Table Of Contents

### Fundamentals

1. [What Is Node.js](#1-what-is-nodejs)
2. [What Is npm](#2-what-is-npm)
3. [Production Architecture](#3-production-architecture)
4. [Production Folder Structure](#4-production-folder-structure)
5. [Docker-First vs Global Install](#5-docker-first-vs-global-install)

### Installation

6. [Install Node.js On Mac](#6-install-nodejs-on-mac)
7. [Install Node.js On Linux (Global)](#7-install-nodejs-on-linux-global)
8. [Install Node.js In Docker](#8-install-nodejs-in-docker)
9. [Verify Node.js Installation](#9-verify-nodejs-installation)

### Configuration

10. [package.json](#10-packagejson)
11. [package-lock.json](#11-package-lockjson)
12. [Environment Variables](#12-environment-variables)
13. [node_modules And .gitignore](#13-node_modules-and-gitignore)
14. [npm Scripts](#14-npm-scripts)
15. [Package Managers (npm, pnpm, yarn)](#15-package-managers-npm-pnpm-yarn)

### Development Workflow

16. [Create Node.js Project](#16-create-nodejs-project)
17. [Install And Remove Packages](#17-install-and-remove-packages)
18. [Run Development Server](#18-run-development-server)
19. [Development Dockerfile](#19-development-dockerfile)
20. [Development Docker Compose](#20-development-docker-compose)
21. [Development Best Practices](#21-development-best-practices)

### Production Workflow

22. [Production Dockerfile (Multi-Stage)](#22-production-dockerfile-multi-stage)
23. [Production Docker Compose](#23-production-docker-compose)
24. [Build And Deploy Workflow](#24-build-and-deploy-workflow)
25. [Nginx And Cloudflare Integration](#25-nginx-and-cloudflare-integration)
26. [CI/CD With GitHub Actions](#26-cicd-with-github-actions)
27. [Rollback Workflow](#27-rollback-workflow)
28. [Production Node.js Checklist](#28-production-nodejs-checklist)

### Security Best Practices

29. [npm Audit And Dependencies](#29-npm-audit-and-dependencies)
30. [Environment Variable Security](#30-environment-variable-security)
31. [Runtime Security](#31-runtime-security)
32. [Security Checklist](#32-security-checklist)

### Monitoring And Logging

33. [Application Logs](#33-application-logs)
34. [Docker Container Logs](#34-docker-container-logs)
35. [Process And Resource Monitoring](#35-process-and-resource-monitoring)
36. [Health Checks](#36-health-checks)
37. [Debugging](#37-debugging)

### Backup And Restore

38. [Backup Strategy](#38-backup-strategy)
39. [Backup Commands](#39-backup-commands)
40. [Restore Workflow](#40-restore-workflow)

### Troubleshooting

41. [Permission Denied / EACCES](#41-permission-denied--eacces)
42. [Port Already In Use](#42-port-already-in-use)
43. [Dependency Issues](#43-dependency-issues)
44. [Build Failures](#44-build-failures)
45. [Container Restart Loops](#45-container-restart-loops)
46. [SSL And DNS Issues](#46-ssl-and-dns-issues)

### Cleanup And Uninstall

47. [Remove node_modules And Project Cache (Mac)](#47-remove-node_modules-and-project-cache-mac)
48. [Remove node_modules And Project Cache (Linux)](#48-remove-node_modules-and-project-cache-linux)
49. [Remove Node.js Dev Container (Mac / Docker Desktop)](#49-remove-nodejs-dev-container-mac--docker-desktop)
50. [Uninstall Node.js On Mac](#50-uninstall-nodejs-on-mac)
51. [Uninstall Node.js On Linux](#51-uninstall-nodejs-on-linux)
52. [Remove Node.js Docker Images](#52-remove-nodejs-docker-images)
53. [Log Cleanup](#53-log-cleanup)
54. [Cache And Leftover Files](#54-cache-and-leftover-files)
55. [Verification After Removal](#55-verification-after-removal)

### Legacy: Global Node.js + PM2

56. [PM2 Process Manager (Legacy)](#56-pm2-process-manager-legacy)
57. [When To Avoid PM2 In Production](#57-when-to-avoid-pm2-in-production)

### Production Workflows

58. [Recommended Production Workflow](#58-recommended-production-workflow)
59. [Modern Workflow](#59-modern-workflow)
60. [Real-World Workflow](#60-real-world-workflow)
61. [Final Production Checklist](#61-final-production-checklist)

---

# 1. What Is Node.js

Node.js is a JavaScript runtime used to build backend APIs, full-stack apps, and CLI tools.

Production use cases:

* REST/GraphQL APIs (Express, Fastify, NestJS)
* full-stack frameworks (Next.js, Nuxt)
* real-time apps (WebSockets)
* background workers and microservices

Recommended version: **Node.js 24 LTS** (or current LTS).

---

# 2. What Is npm

npm (Node Package Manager) installs and manages JavaScript dependencies.

Used for:

* installing packages (`npm install express`)
* running scripts (`npm run build`)
* locking dependency versions (`package-lock.json`)
* publishing packages

Comes bundled with Node.js. Use `npm ci` in production builds for reproducible installs.

---

# 3. Production Architecture

```txt
User
↓
Cloudflare
↓
Nginx
↓
Frontend (Next.js / React)
↓
Backend (Node.js API)
↓
PostgreSQL
↓
Redis
```

Node.js runs inside Docker containers — not directly on the VPS host.

```txt
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
VPS
↓
docker compose up -d
↓
Node.js Container
```

---

# 4. Production Folder Structure

## Monorepo (Full Stack)

```txt
myapp/
├── apps/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src/
│   └── backend/
│       ├── Dockerfile
│       ├── package.json
│       ├── src/
│       │   ├── index.js
│       │   ├── routes/
│       │   └── middleware/
│       └── tests/
├── docker-compose.yml
├── docker-compose.prod.yml
├── docker-compose.dev.yml
├── .env.example
├── .dockerignore
└── .github/
    └── workflows/
        └── deploy.yml
```

## Single Backend API

```txt
api/
├── Dockerfile
├── .dockerignore
├── .env.example
├── package.json
├── package-lock.json
├── src/
│   ├── index.js
│   ├── routes/
│   └── config/
└── tests/
```

## VPS Deployment Path

```txt
/var/www/myapp/
├── docker-compose.prod.yml
├── .env
└── nginx/
    └── default.conf
```

---

# 5. Docker-First vs Global Install

| Approach | Use Case |
|----------|----------|
| **Docker (recommended)** | All production deployments |
| **Global + PM2 (legacy)** | Learning, quick scripts, legacy VPS |

Production rule:

```txt
✓ Docker for production
✓ Node.js on Mac for local development
✗ Global Node.js + PM2 for new production projects
```

```txt
Development (Mac)     → Node.js via nvm/fnm OR Docker Compose dev
Production (VPS)      → Docker container only
CI/CD                 → node:24-slim in GitHub Actions or Docker build
```

---

# 6. Install Node.js On Mac

Use a version manager for local development.

## Option A — fnm (Recommended)

```bash
brew install fnm
echo 'eval "$(fnm env)"' >> ~/.zshrc
source ~/.zshrc
fnm install 24
fnm use 24
fnm default 24
```

## Option B — nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.zshrc
nvm install 24
nvm use 24
nvm alias default 24
```

## Verify

```bash
node -v
npm -v
```

Expected:

```txt
v24.x.x
10.x.x
```

---

# 7. Install Node.js On Linux (Global)

For local scripts or legacy PM2 setups only — not recommended for new production.

## NodeSource LTS

```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt install -y nodejs
```

## Verify

```bash
node -v
npm -v
which node
```

## Fix npm Permissions (If Needed)

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

✓ Good:

* global install for utility scripts only

✗ Avoid:

* global Node.js as primary production runtime
* `sudo npm install -g`

---

# 8. Install Node.js In Docker

Production Node.js runs in containers.

## Pull Official Image

```bash
docker pull node:24-slim
```

## Run Interactive Container

```bash
docker run -it --rm node:24-slim bash
node -v
npm -v
exit
```

## Image Variants

```txt
node:24-slim     → production (smallest, recommended)
node:24-alpine   → minimal Alpine-based
node:24          → full Debian (larger, has more tools)
node:24-bullseye → specific Debian version
```

Production preference: `node:24-slim`.

---

# 9. Verify Node.js Installation

## Mac

```bash
node -v && npm -v
which node
```

## Linux (Global)

```bash
node -v && npm -v
which node
npm list -g --depth=0
```

## Docker

```bash
docker run --rm node:24-slim node -v
docker run --rm node:24-slim npm -v
```

## Project

```bash
cd ~/Projects/myapp/apps/backend
node -v
npm ci
npm run build
```

---

# 10. package.json

Central config file for every Node.js project.

## Initialize

```bash
npm init -y
```

## Production Example

```json
{
  "name": "myapp-api",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "node --watch src/index.js",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "node --test",
    "lint": "eslint src/"
  },
  "engines": {
    "node": ">=24.0.0"
  },
  "dependencies": {
    "express": "^5.0.0",
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
```

Key fields:

```txt
scripts     → npm run dev / build / start
engines     → required Node.js version
dependencies → production packages
devDependencies → build/test tools only
private: true → prevents accidental npm publish
```

---

# 11. package-lock.json

Locks exact dependency versions for reproducible builds.

```txt
package.json       → version ranges (^5.0.0)
package-lock.json  → exact versions (5.0.1)
```

## Rules

```txt
✓ Always commit package-lock.json
✓ Use npm ci in Docker/production builds
✗ Delete package-lock.json in production projects
✗ Use npm install in CI (use npm ci)
```

## npm ci vs npm install

```bash
npm ci          # Production/CI — exact lock file, fails if out of sync
npm install     # Development — may update lock file
```

---

# 12. Environment Variables

## .env File (Local / Server)

```env
NODE_ENV=production
PORT=5000
DATABASE_URL=postgresql://user:pass@postgres:5432/mydb
REDIS_URL=redis://redis:6379
JWT_SECRET=your-long-random-secret
```

## .env.example (Commit To Git)

```env
NODE_ENV=development
PORT=5000
DATABASE_URL=
REDIS_URL=
JWT_SECRET=
```

## Load In Node.js

```javascript
import "dotenv/config";

const port = process.env.PORT || 5000;
```

## Docker Compose

```yaml
services:
  backend:
    env_file:
      - .env
    environment:
      - NODE_ENV=production
```

✓ Good:

* `.env` on server only, `chmod 600`
* `.env.example` documents required vars

✗ Avoid:

* committing `.env` to GitHub
* hardcoding secrets in source code

---

# 13. node_modules And .gitignore

## .gitignore

```txt
node_modules/
.env
.env.local
dist/
coverage/
*.log
.DS_Store
```

## Rules

```txt
✓ node_modules in .gitignore always
✓ Docker builds run npm ci (installs inside container)
✗ Commit node_modules to Git
✗ Copy node_modules into Docker image from host
```

---

# 14. npm Scripts

## Run Scripts

```bash
npm run dev
npm run build
npm run start
npm test
```

## Common Production Scripts

```json
"scripts": {
  "dev": "node --watch src/index.js",
  "build": "tsc --project tsconfig.json",
  "start": "node dist/index.js",
  "start:prod": "NODE_ENV=production node dist/index.js"
}
```

Dockerfile uses:

```dockerfile
CMD ["npm", "start"]
# or directly:
CMD ["node", "dist/index.js"]
```

---

# 15. Package Managers (npm, pnpm, yarn)

## npm (Default — Recommended)

```bash
npm install express
npm ci
```

## pnpm (Faster, Monorepos)

```bash
npm install -g pnpm
pnpm install
pnpm run build
```

## yarn

```bash
npm install -g yarn
yarn install
yarn build
```

Production recommendation: **npm** with `package-lock.json` and `npm ci` — widest CI/CD compatibility.

Pick one per project. Do not mix lock files.

---

# 16. Create Node.js Project

## Local (Mac)

```bash
mkdir myapp-api && cd myapp-api
npm init -y
npm install express dotenv
mkdir src
touch src/index.js
```

## Basic Express App

```javascript
import express from "express";

const app = express();
const port = process.env.PORT || 5000;

app.get("/", (req, res) => res.json({ message: "API running" }));
app.get("/health", (req, res) => res.json({ status: "ok" }));

app.listen(port, () => console.log(`Server on port ${port}`));
```

## package.json Update

```json
{
  "type": "module",
  "scripts": {
    "dev": "node --watch src/index.js",
    "start": "node src/index.js"
  }
}
```

---

# 17. Install And Remove Packages

## Install Production Dependency

```bash
npm install express
npm install pg redis
```

## Install Dev Dependency

```bash
npm install -D typescript eslint
```

## Install Exact Version

```bash
npm install express@5.0.0
```

## Remove Package

```bash
npm uninstall express
```

## Install All From Lock File

```bash
npm ci
```

## Production Only

```bash
npm ci --omit=dev
```

---

# 18. Run Development Server

## Local (Mac)

```bash
npm run dev
```

## With Environment File

```bash
cp .env.example .env
npm run dev
```

## Verify

```bash
curl http://localhost:5000/health
```

## Stop

```txt
Ctrl + C
```

---

# 19. Development Dockerfile

```dockerfile
FROM node:24-slim

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "run", "dev"]
```

Used with bind mount for hot reload — development only.

---

# 20. Development Docker Compose

```yaml
services:
  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile.dev
    ports:
      - "5000:5000"
    volumes:
      - ./apps/backend/src:/app/src
      - ./apps/backend/package.json:/app/package.json
    env_file:
      - ./apps/backend/.env
    command: npm run dev

  postgres:
    image: postgres:17
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_dev:/var/lib/postgresql/data

  redis:
    image: redis:8-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_dev:
```

## Start Dev Stack

```bash
docker compose -f docker-compose.dev.yml up -d
docker compose logs -f backend
```

---

# 21. Development Best Practices

✓ Good:

* `npm run dev` with hot reload locally
* Docker Compose for local full stack
* `.env.example` in Git
* same Node.js version as production (24 LTS)

✗ Avoid:

* developing directly on production VPS
* different Node versions local vs production
* skipping `package-lock.json`

---

# 22. Production Dockerfile (Multi-Stage)

```dockerfile
# Build stage
FROM node:24-slim AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:24-slim

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist

USER node

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD node -e "fetch('http://localhost:5000/health').then(r=>process.exit(r.ok?0:1))"

CMD ["node", "dist/index.js"]
```

## .dockerignore

```txt
node_modules
.env
.env.*
.git
*.log
coverage
dist
README.md
```

---

# 23. Production Docker Compose

```yaml
services:
  backend:
    image: youruser/myapp-backend:${TAG:-latest}
    restart: unless-stopped
    env_file:
      - .env
    networks:
      - app-network
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started

  frontend:
    image: youruser/myapp-frontend:${TAG:-latest}
    restart: unless-stopped
    networks:
      - app-network

  postgres:
    image: postgres:17
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
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
    volumes:
      - ./nginx:/etc/nginx/conf.d:ro
    networks:
      - app-network
    depends_on:
      - backend
      - frontend

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
```

---

# 24. Build And Deploy Workflow

## Build Image Locally

```bash
docker build -t youruser/myapp-backend:latest -f apps/backend/Dockerfile apps/backend
```

## Push To Docker Hub

```bash
docker login
docker push youruser/myapp-backend:latest
```

## Deploy On VPS

```bash
ssh vps-prod
cd /var/www/myapp
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
docker compose ps
curl -f http://localhost:5000/health
```

## Full Deploy Flow

```txt
Code change
↓
git push origin main
↓
GitHub Actions: test → build → push image
↓
SSH to VPS → docker compose pull → up -d
↓
Health check passes
```

---

# 25. Nginx And Cloudflare Integration

```txt
User
↓
Cloudflare
↓
Nginx (:443)
↓
Backend Node.js (:5000 internal)
```

## Nginx Config Snippet

```nginx
upstream backend {
    server backend:5000;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Node.js listens on internal port only — not exposed publicly.

See `11-nginx-reverse-proxy.md` for full Nginx setup.

---

# 26. CI/CD With GitHub Actions

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 24
          cache: npm
          cache-dependency-path: apps/backend/package-lock.json
      - run: npm ci
        working-directory: apps/backend
      - run: npm test
        working-directory: apps/backend

  build-push:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: apps/backend
          push: true
          tags: youruser/myapp-backend:latest

  deploy:
    needs: build-push
    runs-on: ubuntu-latest
    steps:
      - uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          port: ${{ secrets.SERVER_SSH_PORT }}
          script: |
            cd /var/www/myapp
            docker compose -f docker-compose.prod.yml pull backend
            docker compose -f docker-compose.prod.yml up -d backend
            docker compose ps
```

---

# 27. Rollback Workflow

## Tag-Based Rollback

```bash
ssh vps-prod
cd /var/www/myapp
export TAG=v1.2.3
docker compose -f docker-compose.prod.yml up -d backend
docker compose ps
curl -f http://localhost:5000/health
```

## GitHub Actions Rollback

Push previous git tag or revert commit → CI rebuilds and deploys.

## Backup Before Deploy

```bash
docker tag youruser/myapp-backend:latest youruser/myapp-backend:rollback
```

---

# 28. Production Node.js Checklist

✓ Good:

* Node.js 24 LTS in Docker
* multi-stage Dockerfile
* `npm ci --omit=dev` in production stage
* non-root `USER node`
* health check endpoint
* `.env` not in Git
* Nginx reverse proxy

✗ Avoid:

* global Node.js + PM2 for new projects
* `node:latest` in production
* running as root in container
* exposing Node.js port publicly

---

# 29. npm Audit And Dependencies

## Audit

```bash
npm audit
npm audit --production
```

## Fix

```bash
npm audit fix
```

Use `--force` only after reviewing breaking changes:

```bash
npm audit fix --force
```

## Check Outdated

```bash
npm outdated
```

## Update (Development)

```bash
npm update
npm install package@latest
```

Schedule monthly dependency reviews in production projects.

✓ Good:

* regular `npm audit` in CI
* pin major dependencies
* minimal dependency count

✗ Avoid:

* ignoring critical CVEs
* unnecessary packages

---

# 30. Environment Variable Security

✓ Good:

* secrets in `.env` on server / Coolify / GitHub Secrets
* `chmod 600 .env`
* validate required env vars on startup
* different secrets per environment

✗ Avoid:

* secrets in `package.json`
* secrets in Dockerfile `ENV`
* logging env vars at startup

## Startup Validation

```javascript
const required = ["DATABASE_URL", "JWT_SECRET", "PORT"];
for (const key of required) {
  if (!process.env[key]) throw new Error(`Missing env: ${key}`);
}
```

---

# 31. Runtime Security

✓ Good:

* run as non-root user in Docker
* input validation on all API endpoints
* rate limiting (express-rate-limit)
* helmet.js for HTTP headers
* HTTPS only in production
* CORS restricted to known domains

✗ Avoid:

* `eval()` on user input
* exposing stack traces in production
* running as root in container

---

# 32. Security Checklist

✓ Good:

* `npm audit` clean (or documented exceptions)
* `.env` not in Git
* non-root container user
* HTTPS via Nginx/Cloudflare
* JWT secrets 32+ chars random
* dependencies updated regularly

✗ Avoid:

* hardcoded credentials
* public `/admin` without auth
* disabled CORS on production API

---

# 33. Application Logs

## stdout/stderr (Docker Captures These)

```javascript
console.log("Server started on port", port);
console.error("Database connection failed", err.message);
```

## View Logs

```bash
docker compose logs -f backend
docker compose logs backend --tail=200 --since 1h
```

## Structured Logging (Production)

Use a logging library:

```bash
npm install pino
```

```javascript
import pino from "pino";
const logger = pino({ level: process.env.LOG_LEVEL || "info" });
logger.info({ port }, "Server started");
```

---

# 34. Docker Container Logs

```bash
docker logs CONTAINER_NAME -f
docker logs CONTAINER_NAME --tail=100
docker compose logs -f backend
```

## Export Logs

```bash
docker compose logs backend > backend-$(date +%F).log
```

---

# 35. Process And Resource Monitoring

## Docker Stats

```bash
docker stats backend --no-stream
docker stats --no-stream
```

## Inside Container

```bash
docker compose exec backend node -e "console.log(process.memoryUsage())"
```

## VPS Host

```bash
free -h
htop
ps aux | grep node
```

## Open Ports

```bash
sudo ss -tlnp | grep node
docker compose ps
```

---

# 36. Health Checks

## Express Health Endpoint

```javascript
app.get("/health", async (req, res) => {
  try {
    await db.query("SELECT 1");
    res.json({ status: "ok", uptime: process.uptime() });
  } catch (err) {
    res.status(503).json({ status: "error" });
  }
});
```

## Docker Compose Health Check

```yaml
backend:
  healthcheck:
    test: ["CMD", "node", "-e", "fetch('http://localhost:5000/health').then(r=>process.exit(r.ok?0:1))"]
    interval: 30s
    timeout: 5s
    retries: 3
    start_period: 10s
```

## Verify

```bash
curl -f http://localhost:5000/health
curl -f https://api.yourdomain.com/health
```

---

# 37. Debugging

## Verbose Node.js

```bash
node --trace-warnings dist/index.js
NODE_DEBUG=http node dist/index.js
```

## Docker Exec

```bash
docker compose exec backend sh
docker compose exec backend node -v
docker compose exec backend env
```

## Check Config

```bash
docker compose config
docker inspect backend | grep -A10 Env
```

## Network Debug

```bash
docker compose exec backend nc -zv postgres 5432
docker compose exec backend ping -c 2 redis
curl -v http://localhost:5000/health
```

---

# 38. Backup Strategy

```txt
1. GitHub repo (source code)
2. Docker images tagged in registry
3. PostgreSQL daily dumps
4. .env backed up securely (encrypted)
5. Docker volumes backed up weekly
```

Node.js app itself is stateless — backup the database and config, not the container.

---

# 39. Backup Commands

## Database

```bash
docker compose exec postgres pg_dump -U postgres mydb > ~/backups/mydb-$(date +%F).sql
```

## Config

```bash
tar -czvf ~/backups/node-config-$(date +%F).tar.gz \
  /var/www/myapp/.env \
  /var/www/myapp/docker-compose.prod.yml
```

## Copy To Mac

```bash
scp vps-prod:~/backups/mydb-*.sql ./backups/
```

---

# 40. Restore Workflow

## Restore Database

```bash
cat ~/backups/mydb-YYYY-MM-DD.sql | docker compose exec -T postgres psql -U postgres mydb
```

## Redeploy App

```bash
cd /var/www/myapp
export TAG=latest
docker compose -f docker-compose.prod.yml up -d backend
curl -f http://localhost:5000/health
```

---

# 41. Permission Denied / EACCES

## npm EACCES On Mac/Linux

```bash
sudo chown -R $(whoami) ~/.npm
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
```

## Docker Permission

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## File Permissions

```bash
chmod 755 deploy.sh
sudo chown -R mosabbir:mosabbir /var/www/myapp
```

---

# 42. Port Already In Use

## Find Process

```bash
sudo ss -tlnp | grep :5000
sudo lsof -i :5000
```

## Kill Process

```bash
kill $(lsof -t -i :5000)
```

## Docker Port Conflict

```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
docker compose down
docker compose up -d
```

Change port in `.env`:

```env
PORT=5001
```

---

# 43. Dependency Issues

## Clean Reinstall

```bash
rm -rf node_modules package-lock.json
npm install
```

## Docker Clean Build

```bash
docker compose build --no-cache backend
docker compose up -d backend
```

## Lock File Out of Sync

```bash
npm ci
# If fails: update lock file locally, commit, redeploy
npm install
git add package-lock.json
git commit -m "fix: update lock file"
```

---

# 44. Build Failures

## Common Causes

```txt
TypeScript errors
Missing devDependencies in production stage
npm ci fails (lock file mismatch)
Out of disk space during Docker build
Wrong Node.js version
```

## Diagnose

```bash
npm run build          # locally first
docker build --progress=plain -t test .
df -h
docker system df
```

## Fix Disk Space

```bash
docker system prune -f
docker builder prune -f
```

---

# 45. Container Restart Loops

## Diagnose

```bash
docker compose ps
docker compose logs backend --tail=50
docker inspect backend --format='{{.State.RestartCount}}'
```

## Common Causes

```txt
Missing DATABASE_URL
App crashes on boot
Wrong CMD in Dockerfile
Port binding conflict
OOM killed (out of memory)
```

## Fix

```bash
docker compose logs backend 2>&1 | tail -30
docker compose exec backend env
# Fix .env → docker compose up -d backend
```

---

# 46. SSL And DNS Issues

## Verify API Reachable

```bash
curl -I http://api.yourdomain.com/health
curl -I https://api.yourdomain.com/health
dig api.yourdomain.com +short
```

## Common Fixes

```txt
Cloudflare SSL → Full (strict)
Nginx proxy_pass points to backend:5000
Backend listens on 0.0.0.0 not 127.0.0.1 inside container
UFW allows 80/443
```

```javascript
// Listen on all interfaces inside container
app.listen(port, "0.0.0.0", () => console.log(`Port ${port}`));
```

---

# 47. Remove node_modules And Project Cache (Mac)

## Remove Project Dependencies

```bash
cd ~/Projects/myapp
rm -rf node_modules
rm -rf apps/*/node_modules
rm -f package-lock.json   # only if regenerating — usually keep
```

## Clear npm Cache

```bash
npm cache clean --force
npm cache verify
rm -rf ~/.npm/_cacache
rm -rf ~/.npm/_logs
```

## Remove Build Output

```bash
rm -rf dist
rm -rf .next
rm -rf build
rm -rf coverage
```

## Remove Global Packages

```bash
npm list -g --depth=0
npm uninstall -g pm2 nodemon ts-node
```

## Remove PM2 Data (If Used)

```bash
pm2 kill
rm -rf ~/.pm2
```

---

# 48. Remove node_modules And Project Cache (Linux)

## Remove Project Dependencies

```bash
cd /var/www/myapp
rm -rf node_modules
rm -rf dist build .next coverage
```

## Clear npm Cache

```bash
npm cache clean --force
rm -rf ~/.npm
rm -rf ~/.npm/_cacache
rm -rf ~/.npm/_logs
sudo chown -R $(whoami) ~/.npm
```

## Remove PM2 Data (Legacy Host Install)

```bash
pm2 kill
npm uninstall -g pm2
rm -rf ~/.pm2
```

## Remove Global Node Modules

```bash
sudo rm -rf /usr/local/lib/node_modules
sudo rm -rf ~/.npm-global
```

---

# 49. Remove Node.js Dev Container (Mac / Docker Desktop)

## Stop Dev Stack

```bash
cd ~/Projects/myapp
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml down -v
```

## Remove Dev Containers And Images

```bash
docker ps -a | grep -E 'backend|frontend|node'
docker rm -f CONTAINER_NAME
docker rmi node:24-slim
docker rmi youruser/myapp-backend:dev
docker image prune -f
```

## Verify (Mac)

```bash
docker ps -a | grep node
docker volume ls | grep myapp
nc -zv localhost 5000
```

Expected: no dev containers, app port closed.

---

# 50. Uninstall Node.js On Mac

## Stop Version Manager Services

```bash
# fnm — no service to stop
# nvm — no service to stop
brew services stop node 2>/dev/null
```

## Uninstall fnm

```bash
fnm uninstall 24
brew uninstall fnm
# Remove from ~/.zshrc:
# eval "$(fnm env)"
```

## Uninstall nvm

```bash
nvm deactivate
nvm uninstall 24
rm -rf ~/.nvm
# Remove nvm lines from ~/.zshrc
```

## Uninstall Homebrew Node

```bash
brew uninstall node
brew uninstall node@24 2>/dev/null
brew cleanup
brew autoremove
```

## Remove Mac Data Directories

```bash
rm -rf ~/.npm
rm -rf ~/.npm-global
rm -rf ~/.node-gyp
rm -rf ~/.node_repl_history
rm -rf ~/node_modules
rm -rf ~/.pm2
rm -rf ~/.yarn
rm -rf ~/.pnpm-store
rm -rf ~/Library/Caches/node-gyp
rm -rf ~/Library/Caches/Yarn
```

## Verify (Mac)

```bash
which node
which npm
which nvm
which fnm
node -v 2>&1
brew list | grep node
ls ~/.nvm 2>&1
```

Expected: commands not found, no node packages in brew.

---

# 51. Uninstall Node.js On Linux

## NodeSource Install

```bash
sudo systemctl stop pm2-root 2>/dev/null
sudo apt purge -y nodejs
sudo apt autoremove -y
sudo apt autoclean
```

## Remove Global Modules And Cache

```bash
sudo rm -rf /usr/local/lib/node_modules
sudo rm -rf /usr/local/bin/npm
sudo rm -rf /usr/local/bin/npx
sudo rm -rf /usr/local/bin/node
sudo rm -rf ~/.npm
sudo rm -rf ~/.npm-global
sudo rm -rf ~/.node-gyp
```

## Remove PM2 (Legacy)

```bash
pm2 kill
npm uninstall -g pm2
sudo rm -rf ~/.pm2
sudo rm -rf /root/.pm2
```

## Remove NodeSource Repository

```bash
sudo rm -f /etc/apt/sources.list.d/nodesource.list
sudo rm -f /etc/apt/keyrings/nodesource.gpg
```

## Verify (Linux)

```bash
which node
which npm
which pm2
node -v 2>&1
dpkg -l | grep nodejs
```

Expected: commands not found, package not installed.

---

# 52. Remove Node.js Docker Images

## Remove App Containers (Linux / VPS)

```bash
cd /var/www/myapp
docker compose down
docker compose down --rmi all
docker compose down -v    # DESTROYS volumes — backup first
```

## Remove Node Images

```bash
docker rmi node:24-slim
docker rmi node:24-alpine
docker rmi youruser/myapp-backend:latest
docker rmi youruser/myapp-frontend:latest
docker image prune -a -f
```

## Remove Build Cache

```bash
docker builder prune -a -f
```

## Verify

```bash
docker images | grep -E 'node|myapp'
docker ps -a | grep -E 'backend|frontend'
```

---

# 53. Log Cleanup

## Application Logs (Docker)

```bash
docker compose logs backend > ~/logs/backend-final.log 2>&1
truncate -s 0 $(docker inspect --format='{{.LogPath}}' BACKEND_CONTAINER)

# Or configure in compose:
# logging:
#   driver: json-file
#   options:
#     max-size: "10m"
#     max-file: "3"
```

## PM2 Logs (Legacy Host Install)

```bash
pm2 flush
rm -rf ~/.pm2/logs/*
sudo rm -rf /root/.pm2/logs/*
```

## npm Debug Logs

```bash
rm -rf ~/.npm/_logs
rm -f ~/Projects/myapp/npm-debug.log*
rm -f ~/Projects/myapp/yarn-error.log*
```

## Project Log Files

```bash
cd ~/Projects/myapp
rm -f *.log
rm -rf logs/
rm -f apps/*/logs/*.log
```

## Mac

```bash
rm -rf ~/Library/Logs/npm
rm -rf ~/Library/Caches/node-gyp
rm -f ~/.node_repl_history
```

## Linux (VPS)

```bash
sudo journalctl --vacuum-time=14d
rm -rf ~/logs/*.log
```

---

# 54. Cache And Leftover Files

## npm Cache (Mac / Linux)

```bash
npm cache clean --force
rm -rf ~/.npm/_cacache
rm -rf ~/.npm/_logs
npm cache verify
```

## Yarn / pnpm Cache

```bash
yarn cache clean
rm -rf ~/.yarn/cache
pnpm store prune
rm -rf ~/.pnpm-store
rm -rf ~/Library/pnpm  # Mac
```

## node-gyp Build Cache

```bash
rm -rf ~/.node-gyp
rm -rf ~/Library/Caches/node-gyp   # Mac
```

## Docker Cache (Mac / Linux)

```bash
docker builder prune -f
docker builder prune -a -f
docker image prune -a -f
docker system prune -f
```

## Project Leftovers

```bash
cd ~/Projects/myapp
rm -rf node_modules
rm -rf dist build .next coverage
rm -rf .turbo
rm -f .eslintcache
rm -rf tmp/
```

## Mac Leftovers

```bash
rm -rf ~/.npm ~/.npm-global ~/.node-gyp ~/.pm2 ~/.yarn ~/.pnpm-store
rm -rf ~/Library/Caches/node-gyp
rm -rf ~/Library/Caches/Yarn
rm -rf ~/Library/Caches/pnpm
brew cleanup
```

## Linux Leftovers

```bash
rm -rf ~/.npm ~/.npm-global ~/.node-gyp ~/.pm2
sudo rm -rf /usr/local/lib/node_modules
sudo rm -rf /root/.npm /root/.pm2
sudo apt autoremove -y
sudo apt autoclean
```

## Orphan Docker Volumes And Networks

```bash
docker volume ls | grep myapp
docker network ls | grep myapp
docker volume prune -f    # backup first
docker network prune -f
```

---

# 55. Verification After Removal

## Mac

```bash
which node npm npx pm2 fnm nvm
node -v 2>&1
brew list | grep node
ls ~/.nvm 2>&1
ls ~/.npm 2>&1
docker ps -a | grep node
docker images | grep node
```

Expected: commands not found, no brew node packages, cache dirs gone.

## Linux (Global Install)

```bash
which node npm pm2
node -v 2>&1
dpkg -l | grep nodejs
ls ~/.npm 2>&1
ls ~/.pm2 2>&1
```

Expected: commands not found, package absent.

## Docker (Mac / Linux)

```bash
docker images | grep -E 'node|myapp'
docker ps -a | grep -E 'backend|frontend'
docker volume ls | grep myapp
curl http://localhost:5000/health 2>&1
```

Expected: no node/app images (if removed), no running containers, health check fails.

## Project Directory

```bash
cd ~/Projects/myapp
ls node_modules 2>&1
ls dist 2>&1
npm cache verify
```

## Cleanup Checklist

✓ Good:

* node_modules removed from projects
* npm/yarn/pnpm cache cleared
* version manager uninstalled (fnm/nvm)
* Docker images and build cache pruned
* PM2 data removed (if legacy install)
* log files exported then deleted

✗ Avoid:

* `docker compose down -v` without database backup
* deleting `package-lock.json` unless intentionally regenerating

---

# 56. PM2 Process Manager (Legacy)

PM2 runs Node.js directly on the VPS host — legacy approach only.

## Install

```bash
npm install -g pm2
```

## Start App

```bash
pm2 start src/index.js --name myapp
pm2 list
pm2 logs myapp
pm2 restart myapp
pm2 stop myapp
pm2 delete myapp
```

## Auto-Start On Reboot

```bash
pm2 save
pm2 startup
```

Use only for existing PM2 deployments. New projects use Docker.

---

# 57. When To Avoid PM2 In Production

✓ Use Docker instead:

* reproducible builds
* easy rollback via image tags
* isolation from host OS
* consistent with frontend/database containers
* CI/CD integration

✗ PM2 drawbacks:

* Node.js version tied to host
* no container isolation
* harder multi-service orchestration
* manual dependency management on VPS

---

# 58. Recommended Production Workflow

```txt
1. Develop locally (Mac + Docker Compose dev)
2. Node.js 24 LTS, npm ci, package-lock.json committed
3. Multi-stage Dockerfile with non-root user
4. GitHub Actions: test → build → push image
5. VPS: docker compose pull && up -d
6. Nginx reverse proxy + Cloudflare SSL
7. Health checks + log monitoring
8. Database backups daily
```

---

# 59. Modern Workflow

```txt
Developer (Mac)
↓
Local Docker Compose (dev)
↓
GitHub Push
↓
GitHub Actions (test + build)
↓
Docker Hub
↓
SSH → VPS
↓
docker compose up -d
↓
Nginx
↓
Cloudflare
↓
Users
```

Alternative with Coolify:

```txt
Developer → GitHub Push → Coolify → Docker → Users
```

---

# 60. Real-World Workflow

Example: Express API + Next.js frontend on Hetzner VPS.

## Project Setup

```bash
# Mac
mkdir myapp && cd myapp
# Create apps/backend, apps/frontend
# Add Dockerfiles, docker-compose.prod.yml
git init && git remote add origin git@github.com:user/myapp.git
git push origin main
```

## VPS Deploy

```bash
ssh vps-prod
mkdir -p /var/www/myapp
# Copy docker-compose.prod.yml + .env
docker compose -f docker-compose.prod.yml up -d
curl -f http://localhost:5000/health
```

## CI/CD (Every Push)

```txt
GitHub Actions runs tests
Builds backend + frontend images
Pushes to Docker Hub
SSH deploys to VPS
```

## Weekly Maintenance

```bash
ssh vps-prod
docker compose ps
docker compose logs backend --tail=20
npm audit  # run in CI, review report
df -h && free -h
```

---

# 61. Final Production Checklist

## Code And Dependencies

✓ Node.js 24 LTS
✓ package-lock.json committed
✓ npm audit reviewed
✓ `.env.example` in Git, `.env` excluded

## Docker

✓ Multi-stage Dockerfile
✓ `npm ci --omit=dev` in production stage
✓ non-root USER node
✓ HEALTHCHECK defined
✓ .dockerignore configured

## Infrastructure

✓ Nginx reverse proxy
✓ Cloudflare SSL
✓ health endpoint responding
✓ database backups scheduled
✓ CI/CD pipeline working

✗ Global Node.js on VPS for production
✗ PM2 for new projects
✗ node:latest image tag
✗ secrets in Git

## Full Stack

```txt
Developer
↓
GitHub
↓
GitHub Actions
↓
Docker Hub
↓
VPS (Docker Compose)
↓
Node.js Container
↓
Nginx
↓
Cloudflare
↓
Users
```

---

## Node.js Quick Commands Cheat Sheet

```bash
# Versions
node -v && npm -v

# Project
npm ci
npm run dev
npm run build
npm start

# Packages
npm install express
npm install -D typescript
npm uninstall express
npm audit

# Docker
docker build -t myapp-backend .
docker compose up -d
docker compose logs -f backend
docker compose exec backend sh

# Deploy (VPS)
ssh vps-prod
cd /var/www/myapp
docker compose pull && docker compose up -d
curl -f http://localhost:5000/health

# Cleanup (Mac)
rm -rf node_modules dist .next ~/.npm ~/.pm2
npm cache clean --force
brew uninstall node fnm
docker compose -f docker-compose.dev.yml down -v

# Cleanup (Linux)
sudo apt purge -y nodejs && sudo apt autoremove -y
rm -rf ~/.npm ~/.pm2 /usr/local/lib/node_modules

# Cleanup (Docker)
docker compose down -v    # backup DBs first
docker image prune -a -f
docker builder prune -a -f
```
