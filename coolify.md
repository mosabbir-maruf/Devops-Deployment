# Coolify

# What Is Coolify?

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

# Requirements

Before installing Coolify:

- VPS with Ubuntu
- Docker installed
- Minimum 2GB RAM recommended
- Open internet access
- Non-root user recommended

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

# Coolify Update

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

# GitHub Integration

Coolify can connect directly with GitHub repositories.

Benefits:

- Auto deployments
- Push-to-deploy
- Easy updates
- CI/CD workflow

---

# Environment Variables

Coolify supports `.env` variables for applications.

Examples:

```txt
NODE_ENV=production
PORT=3000
DATABASE_URL=your_database_url
```

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

# Coolify Security

- Use strong admin password
- Keep Coolify updated
- Do not expose unnecessary ports
- Use Cloudflare for extra protection
- Use environment variables for secrets
- Restrict database public access
- Monitor VPS resources regularly

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

# Coolify Backup Ideas

Recommended:

- VPS snapshots
- Database backups
- GitHub repository backups
- Environment variable backups

---

# Common Coolify Workflow

1. Install Docker
2. Install Coolify
3. Open dashboard
4. Create admin account
5. Connect GitHub
6. Add project
7. Configure environment variables
8. Add domain
9. Deploy application
10. Monitor containers/logs
