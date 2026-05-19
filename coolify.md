# Coolify

## What Is Coolify?

Coolify is a self-hosted deployment platform used to deploy and manage applications, databases and services on your own VPS.

Benefits:

- Self-hosted
- Easy deployments
- GitHub integration
- Automatic SSL
- Docker-based
- Multiple app management
- No monthly hosting platform fees

---

# How Coolify Works

Coolify uses:

- Docker containers
- Reverse proxy
- automatic SSL
- Git integrations
- deployment pipelines

Coolify automatically manages deployments on your VPS.

---

# Requirements

Before installing Coolify:

- VPS with Ubuntu
- Docker installed
- Minimum 2GB RAM recommended
- Open internet access
- Non-root user recommended

---

# Install Docker First

Coolify requires Docker.

Verify Docker installation:

```bash
docker --version
```

---

# Install Coolify

## Install Coolify

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

Installs Coolify using the official installation script.

---

# Verify Coolify Installation

## Check Running Containers

```bash
docker ps
```

Shows Coolify related Docker containers.

---

## Check Coolify Logs

```bash
docker logs coolify
```

Displays Coolify container logs.

---

## Check Docker Service

```bash
sudo systemctl status docker
```

Checks Docker service status.

---

# Access Coolify Dashboard

Open in browser:

```txt
http://YOUR_SERVER_IP:8000
```

Used for accessing Coolify dashboard.

---

# Initial Coolify Setup

After opening dashboard:

- Create admin account
- Set strong password
- Configure server
- Connect GitHub/GitLab if needed

---

# Coolify Dashboard Features

Coolify supports:

- applications
- databases
- Docker services
- environment variables
- domains
- SSL
- GitHub deployments
- backups
- monitoring

---

# GitHub Integration

Coolify can connect directly with GitHub repositories.

Benefits:

- Auto deployments
- Push-to-deploy
- Easy updates
- CI/CD workflow

---

# Deploy Application

Basic deployment workflow:

1. Connect GitHub repository
2. Select branch
3. Configure build settings
4. Add environment variables
5. Configure domain
6. Deploy application

---

# Environment Variables

Coolify supports `.env` variables for applications.

Examples:

```txt
NODE_ENV=production
PORT=3000
DATABASE_URL=your_database_url
JWT_SECRET=your_secret
```

Never expose secrets publicly.

---

# Domain Setup

Inside Coolify:

- Add custom domain
- Configure DNS records
- Enable SSL
- Deploy application

---

# SSL / HTTPS

Coolify automatically supports:

- HTTPS
- SSL certificates
- Automatic certificate renewal

---

# Databases In Coolify

Coolify supports databases like:

- MongoDB
- PostgreSQL
- MySQL
- Redis

Can be deployed directly from dashboard.

---

# Coolify Updates

## Update Coolify

```bash
coolify update
```

Updates Coolify to latest version.

---

# Restart Coolify

## Restart Coolify Containers

```bash
docker restart coolify
```

Restarts Coolify container.

---

# Coolify Services

Coolify uses Docker containers for:

- Applications
- Databases
- Reverse proxy
- SSL
- Background workers

---

# Monitor Coolify Containers

## Check Resource Usage

```bash
docker stats
```

Displays CPU/RAM usage for containers.

---

## Check Docker Logs

```bash
docker logs CONTAINER_ID
```

Displays container logs.

---

## Check Coolify Containers

```bash
docker ps
```

Displays Coolify related containers.

---

# Coolify Backup Ideas

Recommended:

- VPS snapshots
- Database backups
- GitHub repository backups
- Environment variable backups
- Docker volume backups

---

# Coolify Security

- Use strong admin password
- Keep Coolify updated
- Do not expose unnecessary ports
- Use Cloudflare for extra protection
- Use environment variables for secrets
- Restrict database public access
- Monitor VPS resources regularly
- Avoid exposing admin services publicly
- Backup important data regularly

---

# Coolify Performance Tips

- Use VPS with enough RAM
- Remove unused containers
- Monitor Docker resource usage
- Avoid running unnecessary services
- Restart failed containers
- Use SSD storage if possible

---

# Common Coolify Issues

## Application Not Starting

Check:

```bash
docker logs CONTAINER_ID
```

---

## SSL Not Working

Check:

- domain DNS records
- port 80/443 access
- Cloudflare SSL settings

---

## Deployment Failed

Check:

- GitHub permissions
- environment variables
- Docker build logs
- application port configuration

---

# Recommended Production Practices

- Use GitHub private repositories if needed
- Store secrets in environment variables
- Keep VPS updated
- Use backups regularly
- Use Cloudflare protection
- Monitor logs frequently
- Remove unused deployments
- Avoid public database exposure

---

# Useful Coolify Workflow

1. Install Docker
2. Install Coolify
3. Open dashboard
4. Create admin account
5. Connect GitHub
6. Add project
7. Configure environment variables
8. Configure build settings
9. Add domain
10. Enable SSL
11. Deploy application
12. Monitor containers/logs
13. Configure backups