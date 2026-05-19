# Troubleshooting Guide

## Why Troubleshooting Matters

Production systems can fail due to:

- wrong configuration
- dependency issues
- server overload
- DNS problems
- SSL issues
- deployment failures
- database crashes

Good troubleshooting helps quickly identify and fix problems.

---

# Basic Troubleshooting Workflow

Recommended order:

1. Check logs
2. Check service status
3. Check ports
4. Check firewall
5. Check DNS/domain
6. Check resource usage
7. Restart services if needed

---

# Check System Resources

## Check RAM Usage

```bash
free -h
```

Displays memory usage.

---

## Check CPU Usage

```bash
htop
```

Displays live CPU/RAM usage.

Install if missing:

```bash
sudo apt install htop -y
```

---

## Check Disk Usage

```bash
df -h
```

Displays storage usage.

---

# Check Running Processes

## Show Running Processes

```bash
ps aux
```

Displays running processes.

---

# Check Open Ports

## Show Open Ports

```bash
sudo ss -tulpn
```

Displays active ports/services.

---

# SSH Issues

## SSH Connection Refused

Possible reasons:

- SSH service stopped
- wrong port
- firewall blocked

Check:

```bash
sudo systemctl status ssh
```

---

## Permission Denied (publickey)

Possible reasons:

- wrong SSH key
- wrong permissions
- missing public key

Fix permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

## SSH Port Not Reachable

Check firewall:

```bash
sudo ufw status
```

---

# Nginx Issues

## Nginx Config Error

Check config:

```bash
sudo nginx -t
```

---

## Restart Nginx

```bash
sudo systemctl restart nginx
```

---

## 502 Bad Gateway

Possible reasons:

- backend app stopped
- wrong port
- Docker container stopped

---

## Nginx Logs

### Access Logs

```bash
sudo tail -f /var/log/nginx/access.log
```

---

### Error Logs

```bash
sudo tail -f /var/log/nginx/error.log
```

---

# Docker Issues

## Docker Service Not Running

Check:

```bash
sudo systemctl status docker
```

---

## Restart Docker

```bash
sudo systemctl restart docker
```

---

## Container Crashing

Check logs:

```bash
docker logs CONTAINER_ID
```

---

## Port Already In Use

Check:

```bash
sudo ss -tulpn
```

---

## Docker Disk Usage Too High

Check:

```bash
docker system df
```

---

## Clean Docker Resources

```bash
docker system prune -a
```

Deletes unused Docker resources.

Use carefully.

---

# Docker Compose Issues

## Restart Compose Services

```bash
docker compose restart
```

---

## Rebuild Containers

```bash
docker compose up -d --build
```

Rebuilds containers.

---

## Compose Logs

```bash
docker compose logs
```

Displays Docker Compose logs.

---

# PM2 Issues

## PM2 App Crashed

Check logs:

```bash
pm2 logs
```

---

## Restart PM2 App

```bash
pm2 restart APP_NAME
```

---

## Check Running Apps

```bash
pm2 list
```

---

# Node.js Issues

## Dependency Problems

Delete old dependencies:

```bash
rm -rf node_modules package-lock.json
```

Reinstall:

```bash
npm install
```

---

## npm Permission Errors

Fix:

```bash
sudo chown -R $USER:$USER ~/.npm
```

---

## Application Not Starting

Check:

- `.env`
- ports
- logs
- Node.js version

---

# MongoDB Issues

## MongoDB Not Starting

Check:

```bash
sudo systemctl status mongod
```

---

## MongoDB Logs

```bash
sudo journalctl -u mongod
```

---

## Authentication Failed

Possible reasons:

- wrong password
- auth disabled
- wrong auth database

---

## MongoDB Port Check

```bash
sudo ss -tulpn | grep 27017
```

---

# PostgreSQL Issues

## PostgreSQL Not Starting

Check:

```bash
sudo systemctl status postgresql
```

---

## PostgreSQL Logs

```bash
sudo tail -f /var/log/postgresql/postgresql-*.log
```

---

## Too Many Connections

Check active connections:

```sql
SELECT * FROM pg_stat_activity;
```

---

# Redis Issues

## Redis Not Running

Check:

```bash
sudo systemctl status redis-server
```

---

## Redis Memory Usage

```bash
redis-cli INFO memory
```

---

## Redis Authentication Failed

Possible reasons:

- wrong password
- AUTH missing
- config issue

---

# DNS & Domain Issues

## DNS Not Resolving

Check:

```bash
nslookup example.com
```

---

## Domain Not Pointing To VPS

Check:

- DNS records
- nameservers
- propagation

---

## HTTPS Not Working

Check:

- SSL config
- Cloudflare SSL mode
- reverse proxy
- certbot status

---

# Cloudflare Issues

## Cloudflare 522 Error

Possible reasons:

- VPS offline
- blocked firewall
- backend not responding

---

## Cloudflare SSL Loop

Usually caused by:

- wrong SSL mode
- incorrect HTTPS redirect setup

Recommended:

```txt
Full (Strict)
```

---

# Firewall Issues

## Check UFW Status

```bash
sudo ufw status
```

---

## Allow Port

```bash
sudo ufw allow 3000/tcp
```

---

## Deny Port

```bash
sudo ufw deny 3000/tcp
```

---

# Fail2Ban Issues

## Check Fail2Ban Status

```bash
sudo fail2ban-client status
```

---

## Check SSH Jail

```bash
sudo fail2ban-client status sshd
```

---

# Database Connection Issues

Possible reasons:

- database service stopped
- wrong credentials
- firewall restrictions
- wrong connection URL

---

# Check Environment Variables

## View Environment File

```bash
cat .env
```

Never expose secrets publicly.

---

# Check Internet Connectivity

## Ping Test

```bash
ping google.com
```

---

# Check Public IP

```bash
curl ifconfig.me
```

---

# Restart Common Services

## Restart SSH

```bash
sudo systemctl restart ssh
```

---

## Restart Nginx

```bash
sudo systemctl restart nginx
```

---

## Restart Docker

```bash
sudo systemctl restart docker
```

---

## Restart MongoDB

```bash
sudo systemctl restart mongod
```

---

## Restart PostgreSQL

```bash
sudo systemctl restart postgresql
```

---

## Restart Redis

```bash
sudo systemctl restart redis-server
```

---

# Check Logs Quickly

## System Logs

```bash
journalctl -xe
```

---

## Live Logs

```bash
journalctl -f
```

---

# Emergency Recovery Tips

If production app fails:

1. Check logs
2. Check server resources
3. Restart app/container
4. Rollback latest deployment
5. Restore backups if needed

---

# Production Troubleshooting Best Practices

- Always check logs first
- Keep backups before changes
- Monitor resource usage
- Avoid random config changes
- Test changes carefully
- Use staging environment if possible
- Keep deployment rollback strategy ready

---

# Recommended Troubleshooting Workflow

1. Identify issue
2. Check logs
3. Check services
4. Check ports/firewall
5. Check DNS/domain
6. Check resources
7. Apply fix
8. Restart services if needed
9. Verify application health
10. Monitor system after fix