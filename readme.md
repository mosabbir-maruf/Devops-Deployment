# DevOps Deployment

Production-ready DevOps, VPS deployment, Docker, Coolify, Linux security and self-hosting documentation by **Mosabbir Maruf**.

Designed for:

- beginners learning DevOps
- developers deploying real projects
- production VPS hosting
- self-hosted infrastructure
- Docker-based workflows
- full-stack application deployment

---

# Documentation Structure

## VPS & Security

### `initial-vps-security-setup.md`

Production-ready initial VPS setup guide.

Includes:

- Ubuntu VPS setup
- system updates
- sudo user creation
- SSH hardening
- custom SSH port
- Fail2Ban
- firewall configuration
- automatic security updates
- swap setup
- VPS security best practices

---

### `ssh-guide.md`

Complete SSH workflow and security guide.

Includes:

- SSH keys
- Ed25519 keys
- SSH agent
- SSH config
- SSH permissions
- SCP
- SSH debugging
- GitHub SSH authentication
- SSH security best practices

---

### `linux-basics.md`

Essential Linux commands and server basics.

Includes:

- Linux navigation
- file management
- permissions
- package management
- monitoring commands
- networking basics
- services/logs
- compression/archives
- Linux security basics

---

## Docker & Containers

### `docker.md`

Complete Docker production workflow.

Includes:

- Docker installation
- containers
- images
- volumes
- Docker Compose
- Docker networking
- Docker security
- monitoring
- cleanup
- production workflows

---

### `coolify.md`

Self-hosted Coolify deployment platform guide.

Includes:

- Coolify installation
- GitHub integration
- deployments
- domains & SSL
- environment variables
- Docker integration
- monitoring
- backups
- Coolify security best practices

---

## Backend & Runtime

### `nodejs-npm.md`

Production Node.js and npm setup guide.

Includes:

- Node.js installation
- npm / pnpm / yarn
- package management
- PM2
- environment variables
- npm security
- production builds
- monitoring
- deployment workflows

---

## Databases

### `mongodb.md`

Production MongoDB setup and security guide.

Includes:

- MongoDB installation
- authentication
- bindIp security
- backups & restore
- Docker MongoDB
- indexes
- monitoring
- MongoDB production practices

---

### `postgresql.md`

Production PostgreSQL setup guide.

Includes:

- PostgreSQL installation
- users/databases
- SQL basics
- authentication
- pg_hba.conf
- backups
- Docker PostgreSQL
- indexing
- monitoring
- PostgreSQL security

---

### `redis.md`

Redis caching and queue system guide.

Includes:

- Redis installation
- persistence
- Redis security
- password protection
- Docker Redis
- monitoring
- caching workflows
- Redis production practices

---

## Deployment & Infrastructure

### `project-deployment.md`

Production deployment workflows.

Includes:

- VPS deployments
- Docker deployments
- Coolify deployments
- PM2 workflows
- environment variables
- production builds
- HTTPS setup
- rollback basics
- deployment monitoring

---

### `nginx-reverse-proxy.md`

Nginx reverse proxy and SSL guide.

Includes:

- reverse proxy setup
- multiple app routing
- HTTPS/SSL
- Let's Encrypt
- WebSocket support
- security headers
- rate limiting
- Nginx monitoring
- production best practices

---

### `domain-dns-cloudflare.md`

Domain, DNS and Cloudflare setup guide.

Includes:

- domain setup
- DNS records
- Cloudflare configuration
- HTTPS/SSL
- CDN & proxy
- WAF basics
- DNS troubleshooting
- production security practices

---

## Git & CI/CD

### `git-github-ci-cd.md`

Git, GitHub and CI/CD workflow guide.

Includes:

- Git basics
- GitHub SSH authentication
- Git workflows
- GitHub Actions
- automated deployments
- CI/CD pipelines
- GitHub secrets
- production deployment automation

---

## Monitoring & Maintenance

### `server-monitoring.md`

Server monitoring and resource tracking guide.

Includes:

- CPU/RAM monitoring
- disk monitoring
- Docker monitoring
- PM2 monitoring
- database monitoring
- logs
- uptime monitoring
- monitoring tools
- security monitoring

---

### `backup-snapshots.md`

Production backup and recovery guide.

Includes:

- VPS snapshots
- MongoDB backups
- PostgreSQL backups
- Redis backups
- Docker volume backups
- cron automation
- disaster recovery workflows
- backup security practices

---

### `troubleshooting.md`

Common VPS and deployment troubleshooting guide.

Includes:

- SSH issues
- Docker issues
- PM2 issues
- Nginx issues
- DNS problems
- SSL problems
- database troubleshooting
- deployment recovery workflows

---

### `useful-commands.md`

Quick reusable DevOps command reference.

Includes:

- Linux commands
- Docker commands
- Git commands
- PM2 commands
- MongoDB commands
- PostgreSQL commands
- Redis commands
- monitoring commands
- deployment commands

---

# Goals

This repository focuses on:

- secure VPS setup
- production-ready deployments
- Docker-based workflows
- self-hosted infrastructure
- Coolify hosting
- practical DevOps learning
- deployment automation
- Linux server management
- backend infrastructure
- real-world production workflows

---

# Recommended Learning Path

Suggested order:

1. `initial-vps-security-setup.md`
2. `ssh-guide.md`
3. `linux-basics.md`
4. `docker.md`
5. `coolify.md`
6. `nodejs-npm.md`
7. `mongodb.md`
8. `postgresql.md`
9. `redis.md`
10. `project-deployment.md`
11. `nginx-reverse-proxy.md`
12. `domain-dns-cloudflare.md`
13. `git-github-ci-cd.md`
14. `server-monitoring.md`
15. `backup-snapshots.md`
16. `troubleshooting.md`
17. `useful-commands.md`

---

# Production Notes

Recommended for production use:

- keep servers updated
- use SSH keys only
- use HTTPS everywhere
- monitor logs/resources regularly
- backup databases frequently
- avoid exposing databases publicly
- use environment variables for secrets
- monitor Docker resource usage
- configure firewall properly

---

# Repository Goals

This repository is designed so developers can:

- learn DevOps practically
- deploy production applications
- understand VPS workflows
- manage Linux servers
- self-host applications
- secure infrastructure properly
- automate deployments
- monitor production systems
- troubleshoot real-world issues

---

# Author

Created and maintained by **Mosabbir Maruf**

GitHub:
```txt
https://github.com/mosabbir-maruf
```

---

# License

This repository is licensed under the MIT License.