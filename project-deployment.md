# Project Deployment

## What Is Deployment?

Deployment means making an application live and accessible on the internet.

Common deployment targets:

- VPS
- Docker
- Coolify
- Cloud platforms
- Kubernetes

---

# Recommended Production Stack

Example stack:

- Ubuntu VPS
- Docker
- Coolify
- Node.js
- MongoDB/PostgreSQL
- Nginx
- Cloudflare

---

# Basic Deployment Workflow

1. Build application
2. Push code to GitHub
3. Configure VPS
4. Configure environment variables
5. Deploy application
6. Configure domain
7. Enable HTTPS
8. Monitor logs/resources

---

# Prepare VPS

Before deployment:

- VPS secured
- Docker installed
- Coolify installed
- Firewall configured
- Domain ready
- GitHub repository ready

---

# Project Structure

Example Node.js project:

```txt
project/
├── src/
├── package.json
├── package-lock.json
├── Dockerfile
├── .dockerignore
├── .env
```

---

# Environment Variables

## Example `.env`

```txt
NODE_ENV=production
PORT=3000
DATABASE_URL=your_database_url
JWT_SECRET=your_secret
```

---

# .env Security

Never push `.env` to GitHub.

Add to `.gitignore`:

```txt
.env
```

---

# Production Build

## Install Dependencies

```bash
npm install
```

Installs project dependencies.

---

## Build Application

```bash
npm run build
```

Builds production application.

---

# Start Production App

## Start App

```bash
npm start
```

Starts production application.

---

# Production Process Manager (PM2)

## Install PM2

```bash
npm install -g pm2
```

Installs PM2 process manager.

---

## Start Application

```bash
pm2 start index.js --name myapp
```

Runs app in background.

---

## Monitor PM2

```bash
pm2 monit
```

Displays real-time monitoring.

---

## View Logs

```bash
pm2 logs
```

Displays application logs.

---

## Save PM2 Processes

```bash
pm2 save
```

Saves processes for reboot persistence.

---

## Enable PM2 Startup

```bash
pm2 startup
```

Enables auto-start after reboot.

---

# Docker Deployment

## Example Dockerfile

```dockerfile
FROM node:20

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
```

---

# Build Docker Image

## Build Image

```bash
docker build -t myapp .
```

Builds Docker image.

---

# Run Docker Container

## Run Container

```bash
docker run -d \
--name myapp \
-p 3000:3000 \
--env-file .env \
myapp
```

Runs production container.

---

# Docker Compose Deployment

## Example docker-compose.yml

```yaml
services:
  app:
    build: .
    container_name: myapp
    restart: always
    ports:
      - "3000:3000"
    env_file:
      - .env
```

---

## Start Docker Compose

```bash
docker compose up -d
```

Starts services in background.

---

## Restart Docker Compose

```bash
docker compose restart
```

Restarts services.

---

## Stop Docker Compose

```bash
docker compose down
```

Stops services.

---

# Coolify Deployment

## Connect GitHub Repository

Inside Coolify:

1. Add new project
2. Connect GitHub repository
3. Select branch
4. Configure environment variables
5. Configure build settings
6. Deploy app

---

# Coolify Environment Variables

Example:

```txt
NODE_ENV=production
DATABASE_URL=your_database_url
JWT_SECRET=your_secret
```

---

# Domain Configuration

## Add Domain

Inside deployment platform:

- Add domain
- Configure DNS
- Enable SSL

---

# DNS Configuration

## Example A Record

```txt
Type: A
Host: @
Value: YOUR_SERVER_IP
```

Points domain to VPS.

---

# HTTPS / SSL

Production applications should always use HTTPS.

Options:

- Coolify automatic SSL
- Nginx + Let's Encrypt
- Cloudflare SSL

---

# Reverse Proxy

Common reverse proxies:

- Nginx
- Traefik
- Caddy

Used for:

- SSL
- routing
- multiple applications
- load balancing

---

# Deployment Monitoring

## Check Docker Containers

```bash
docker ps
```

Displays running containers.

---

## Check Docker Logs

```bash
docker logs CONTAINER_ID
```

Displays container logs.

---

## Live Docker Logs

```bash
docker logs -f CONTAINER_ID
```

Streams logs live.

---

## Check PM2 Processes

```bash
pm2 list
```

Displays running PM2 apps.

---

## Check Server Resources

```bash
htop
```

Displays CPU/RAM usage.

---

# Deployment Updates

## Pull Latest Code

```bash
git pull
```

Downloads latest changes.

---

## Rebuild Docker Image

```bash
docker compose up -d --build
```

Rebuilds updated containers.

---

## Restart PM2 App

```bash
pm2 restart myapp
```

Restarts application.

---

# Rollback Basics

If deployment fails:

- rollback to previous commit
- rebuild application
- restart services
- restore backup if needed

---

# GitHub Actions Deployment

## Example Auto Deploy Workflow

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /var/www/app
            git pull
            docker compose up -d --build
```

---

# Deployment Security

- Never expose `.env`
- Use strong secrets
- Use HTTPS
- Keep dependencies updated
- Restrict database public access
- Use firewall protection
- Monitor logs regularly
- Keep Docker/images updated
- Avoid unnecessary open ports

---

# Deployment Performance Tips

- Use production builds
- Remove unused containers/images
- Use caching when possible
- Monitor RAM/CPU usage
- Compress frontend assets
- Use CDN/Cloudflare
- Use SSD storage

---

# Common Deployment Issues

## Port Already In Use

Check:

```bash
sudo ss -tulpn
```

---

## Container Not Starting

Check:

```bash
docker logs CONTAINER_ID
```

---

## Build Failed

Possible reasons:

- missing environment variables
- dependency issues
- wrong Node.js version

---

## Domain Not Working

Check:

- DNS records
- firewall
- reverse proxy
- SSL configuration

---

## HTTPS Not Working

Check:

- SSL certificates
- Cloudflare settings
- reverse proxy configuration

---

# Backup Recommendations

Important backups:

- VPS snapshots
- databases
- Docker volumes
- `.env` files
- GitHub repositories

---

# Recommended Production Workflow

1. Prepare VPS
2. Secure VPS
3. Install Docker/Coolify
4. Configure GitHub repository
5. Configure environment variables
6. Build application
7. Deploy application
8. Configure domain
9. Enable HTTPS
10. Monitor logs/resources
11. Configure backups
12. Keep system updated