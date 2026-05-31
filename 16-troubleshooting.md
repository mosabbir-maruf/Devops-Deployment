# Troubleshooting Guide

## Table Of Contents

### Fundamentals

1. [Why Troubleshooting Matters](#1-why-troubleshooting-matters)
2. [Production Debug Architecture](#2-production-debug-architecture)
3. [Standard Debug Workflow](#3-standard-debug-workflow)
4. [Emergency Response Order](#4-emergency-response-order)

### System Resources

5. [Check RAM And CPU](#5-check-ram-and-cpu)
6. [Check Disk And Inodes](#6-check-disk-and-inodes)
7. [High Resource Usage Fixes](#7-high-resource-usage-fixes)

### SSH Issues

8. [SSH Connection Refused](#8-ssh-connection-refused)
9. [Permission Denied (publickey)](#9-permission-denied-publickey)
10. [SSH Port Not Reachable](#10-ssh-port-not-reachable)
11. [Locked Out Of VPS](#11-locked-out-of-vps)

### Docker Issues

12. [Docker Service Not Running](#12-docker-service-not-running)
13. [Container Crashing](#13-container-crashing)
14. [Port Already In Use](#14-port-already-in-use)
15. [Docker Disk Full](#15-docker-disk-full)
16. [Container Cannot Connect To Database](#16-container-cannot-connect-to-database)

### Docker Compose Issues

17. [Compose Services Not Starting](#17-compose-services-not-starting)
18. [Compose Logs And Debug](#18-compose-logs-and-debug)
19. [Rebuild And Rollback](#19-rebuild-and-rollback)

### Nginx Issues

20. [Nginx Config Error](#20-nginx-config-error)
21. [502 Bad Gateway](#21-502-bad-gateway)
22. [504 Gateway Timeout](#22-504-gateway-timeout)
23. [SSL / HTTPS Errors](#23-ssl--https-errors)

### Application Issues

24. [App Not Starting](#24-app-not-starting)
25. [Health Check Failing](#25-health-check-failing)
26. [Environment Variable Issues](#26-environment-variable-issues)
27. [Node.js / npm Issues (Dev)](#27-nodejs--npm-issues-dev)

### Database Issues

28. [PostgreSQL Not Starting](#28-postgresql-not-starting)
29. [PostgreSQL Connection Errors](#29-postgresql-connection-errors)
30. [MongoDB Not Starting](#30-mongodb-not-starting)
31. [MongoDB Authentication Failed](#31-mongodb-authentication-failed)
32. [Redis Not Running](#32-redis-not-running)
33. [Redis Memory / Auth Issues](#33-redis-memory--auth-issues)

### DNS And Domain Issues

34. [DNS Not Resolving](#34-dns-not-resolving)
35. [Domain Not Pointing To VPS](#35-domain-not-pointing-to-vps)
36. [HTTPS Not Working](#36-https-not-working)

### Cloudflare Issues

37. [Cloudflare 522 Error](#37-cloudflare-522-error)
38. [Cloudflare SSL Loop](#38-cloudflare-ssl-loop)
39. [Cloudflare 525 / 526 SSL Errors](#39-cloudflare-525--526-ssl-errors)

### Firewall And Security

40. [UFW Blocking Traffic](#40-ufw-blocking-traffic)
41. [Fail2Ban Locked You Out](#41-fail2ban-locked-you-out)
42. [Unexpected Open Ports](#42-unexpected-open-ports)

### CI/CD And Deployment Issues

43. [GitHub Actions Deploy Failed](#43-github-actions-deploy-failed)
44. [Docker Hub Pull Failed](#44-docker-hub-pull-failed)
45. [Post-Deploy App Broken](#45-post-deploy-app-broken)

### Network And Connectivity

46. [No Internet On VPS](#46-no-internet-on-vps)
47. [Cannot Reach Backend Port](#47-cannot-reach-backend-port)
48. [Database Port Exposed Publicly](#48-database-port-exposed-publicly)

### Log Analysis

49. [Find Errors Fast](#49-find-errors-fast)
50. [Common Log Locations](#50-common-log-locations)

### Recovery

51. [Emergency Recovery Steps](#51-emergency-recovery-steps)
52. [Rollback Deployment](#52-rollback-deployment)
53. [Restore From Backup](#53-restore-from-backup)

### Best Practices

54. [Troubleshooting Rules](#54-troubleshooting-rules)
55. [Production Troubleshooting Checklist](#55-production-troubleshooting-checklist)

### Production Workflows

56. [Recommended Workflow](#56-recommended-workflow)
57. [Modern Workflow](#57-modern-workflow)
58. [Real-World Workflow](#58-real-world-workflow)
59. [Final Production Checklist](#59-final-production-checklist)

---

# 1. Why Troubleshooting Matters

Production failures cost uptime and user trust. A consistent debug order saves minutes when every minute counts.

Common failure causes:

* wrong `.env` or Docker network
* container crash loop
* disk full
* DNS / Cloudflare misconfiguration
* database connection refused
* failed CI/CD deploy

---

# 2. Production Debug Architecture

```txt
User reports issue
↓
External check: curl https://yourdomain.com/health
↓
Cloudflare dashboard: errors, SSL mode
↓
SSH vps-prod
↓
docker compose ps → logs → stats
↓
Fix root cause → redeploy → verify
```

Never restart randomly without checking logs first.

---

# 3. Standard Debug Workflow

```txt
1. Reproduce (curl / browser / user report)
2. Check logs (docker compose logs)
3. Check service status (docker compose ps)
4. Check ports (ss -tulpn)
5. Check firewall (ufw status)
6. Check DNS (dig yourdomain.com)
7. Check resources (df -h, free -h)
8. Apply fix
9. Verify health endpoint
10. Monitor 15 minutes post-fix
```

---

# 4. Emergency Response Order

Site down — run in 60 seconds:

```bash
ssh vps-prod
cd /var/www/myapp
docker compose ps
curl -sf http://localhost:5000/health || echo FAIL
docker compose logs backend --tail=30
df -h / && free -h
```

If backend down:

```bash
docker compose up -d backend
docker compose logs backend --tail=20
```

If still down → rollback (section 52) or restore backup (section 53).

---

# 5. Check RAM And CPU

```bash
free -h
htop
docker stats --no-stream
ps aux --sort=-%mem | head -10
```

---

# 6. Check Disk And Inodes

```bash
df -h
df -i
docker system df
du -sh /var/lib/docker ~/backups /var/log
```

---

# 7. High Resource Usage Fixes

```bash
# Disk emergency
docker system prune -f
sudo journalctl --vacuum-time=7d
find ~/backups -maxdepth 1 -type d -mtime +14 -exec rm -rf {} \;

# Memory — restart leaky container
docker compose restart backend

# CPU — check traffic / infinite loop
docker compose logs backend --tail=100
```

---

# 8. SSH Connection Refused

```bash
# From Mac — test port
nc -zv SERVER_IP 1182

# On VPS (via provider console if SSH blocked)
sudo systemctl status ssh
sudo systemctl start ssh
sudo ufw allow 1182/tcp
```

Causes: wrong port, SSH stopped, UFW blocked, Fail2Ban banned your IP.

---

# 9. Permission Denied (publickey)

```bash
# Mac
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
ssh -v vps-prod

# VPS (via console)
chmod 700 /home/mosabbir/.ssh
chmod 600 /home/mosabbir/.ssh/authorized_keys
chown -R mosabbir:mosabbir /home/mosabbir/.ssh
```

See `02-ssh-guide.md` for full SSH setup.

---

# 10. SSH Port Not Reachable

```bash
sudo ufw status
sudo ufw allow 1182/tcp
sudo ss -tlnp | grep ssh
```

Check VPS provider firewall / security group too.

---

# 11. Locked Out Of VPS

1. Use provider web console (VNC / serial)
2. Login as root or sudo user
3. Fix UFW / Fail2Ban / SSH config
4. Unban IP: `sudo fail2ban-client set sshd unbanip YOUR_IP`

---

# 12. Docker Service Not Running

```bash
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
docker ps
```

If fails:

```bash
sudo journalctl -u docker --since "10 min ago"
```

---

# 13. Container Crashing

```bash
docker compose ps -a
docker compose logs backend --tail=100
docker inspect backend --format='{{json .State}}' | jq
```

Common causes:

* missing env var
* wrong DB connection string
* port conflict
* out of memory (OOM killed)

```bash
docker compose logs backend 2>&1 | grep -i "error\|fatal\|killed"
```

---

# 14. Port Already In Use

```bash
sudo ss -tulpn | grep :5000
sudo lsof -i :5000
```

Fix: stop conflicting process or change port in `docker-compose.yml`.

---

# 15. Docker Disk Full

```bash
docker system df
df -h /var/lib/docker
```

```bash
docker image prune -a -f
docker container prune -f
docker volume prune -f   # CAREFUL — only unused volumes
docker system prune -a -f  # CAREFUL — removes unused images
```

---

# 16. Container Cannot Connect To Database

```bash
# From backend container
docker compose exec backend sh -c 'nc -zv postgres 5432'
docker compose exec backend printenv | grep DATABASE

# From postgres container
docker compose exec postgres pg_isready -U admin
```

Fix connection string — use service name `postgres`, not `localhost`:

```txt
DATABASE_URL=postgresql://admin:PASSWORD@postgres:5432/myapp
```

---

# 17. Compose Services Not Starting

```bash
cd /var/www/myapp
docker compose config    # validate YAML
docker compose up -d
docker compose ps -a
docker compose logs
```

```bash
# Recreate containers
docker compose down
docker compose up -d --force-recreate
```

---

# 18. Compose Logs And Debug

```bash
docker compose logs -f
docker compose logs backend postgres redis --tail=50
docker compose logs --since 30m
```

Follow specific service:

```bash
docker compose logs -f backend
```

---

# 19. Rebuild And Rollback

Rebuild:

```bash
docker compose up -d --build
docker compose pull && docker compose up -d
```

Rollback image tag:

```bash
# Edit docker-compose.yml → previous image tag
docker compose pull backend
docker compose up -d backend
```

---

# 20. Nginx Config Error

```bash
docker compose exec nginx nginx -t
# or host:
sudo nginx -t
```

Fix config, then:

```bash
docker compose exec nginx nginx -s reload
# or:
sudo systemctl reload nginx
```

---

# 21. 502 Bad Gateway

Backend not responding to Nginx.

```bash
docker compose ps backend
curl -v http://localhost:5000/health
docker compose logs backend --tail=50
docker compose logs nginx --tail=20
```

Fixes:

* start backend: `docker compose up -d backend`
* fix wrong upstream port in nginx config
* check backend crash loop in logs

---

# 22. 504 Gateway Timeout

Backend too slow or hung.

```bash
docker stats backend --no-stream
docker compose logs backend --tail=100
```

Fixes: increase Nginx `proxy_read_timeout`, fix slow DB query, scale VPS.

---

# 23. SSL / HTTPS Errors

```bash
curl -vI https://yourdomain.com
sudo certbot certificates
docker compose logs nginx | grep -i ssl
```

Cloudflare: set SSL mode to **Full (strict)**. See `12-domain-dns-cloudflare.md`.

---

# 24. App Not Starting

Checklist:

```bash
docker compose exec backend printenv | grep -E 'NODE|DATABASE|REDIS'
docker compose logs backend --tail=50
docker compose exec backend node -v
```

Common: missing `.env`, wrong `PORT`, DB not ready.

Wait for DB:

```yaml
depends_on:
  postgres:
    condition: service_healthy
```

---

# 25. Health Check Failing

```bash
curl -v http://localhost:5000/health
docker compose exec backend wget -qO- http://localhost:5000/health
```

Implement `/health` returning 200. Check route exists and DB connection optional or handled.

---

# 26. Environment Variable Issues

```bash
cat /var/www/myapp/.env
docker compose exec backend printenv | sort
docker compose config | grep -A2 environment
```

After `.env` change:

```bash
docker compose down && docker compose up -d
```

---

# 27. Node.js / npm Issues (Dev)

Mac local dev:

```bash
rm -rf node_modules package-lock.json
npm install
node -v   # match production version
npm run build
```

Permission fix:

```bash
sudo chown -R $USER:$USER ~/.npm
```

See `06-nodejs-npm.md`.

---

# 28. PostgreSQL Not Starting

```bash
docker compose ps postgres
docker compose logs postgres --tail=50
docker compose exec postgres pg_isready -U admin
```

Host install (legacy):

```bash
sudo systemctl status postgresql
sudo journalctl -u postgresql --since "1 hour ago"
```

See `08-postgresql.md`.

---

# 29. PostgreSQL Connection Errors

```bash
docker compose exec postgres psql -U admin -d myapp -c "SELECT 1;"
docker compose exec postgres psql -U admin -c "SELECT count(*) FROM pg_stat_activity;"
```

Errors:

* `connection refused` → container down or wrong host
* `password authentication failed` → wrong credentials in `.env`
* `too many connections` → restart backend, reduce pool size

---

# 30. MongoDB Not Starting

```bash
docker compose ps mongodb
docker compose logs mongodb --tail=50
docker compose exec mongodb mongosh --eval "db.adminCommand('ping')"
```

See `07-mongodb.md`.

---

# 31. MongoDB Authentication Failed

```bash
docker compose exec mongodb mongosh -u admin -p PASSWORD --authenticationDatabase admin
```

Check `MONGO_URI` in `.env`:

```txt
mongodb://admin:PASSWORD@mongodb:27017/myapp?authSource=admin
```

---

# 32. Redis Not Running

```bash
docker compose ps redis
docker compose exec redis redis-cli -a PASSWORD ping
docker compose logs redis --tail=30
```

---

# 33. Redis Memory / Auth Issues

```bash
docker compose exec redis redis-cli -a PASSWORD INFO memory
docker compose exec redis redis-cli -a PASSWORD CONFIG GET maxmemory
```

`NOAUTH` → add `-a PASSWORD` or fix `requirepass` in compose.

See `09-redis.md`.

---

# 34. DNS Not Resolving

```bash
dig yourdomain.com +short
dig api.yourdomain.com +short
nslookup yourdomain.com
```

Mac:

```bash
dscacheutil -flushcache
```

Wait for propagation (up to 48h, usually minutes with Cloudflare).

---

# 35. Domain Not Pointing To VPS

```bash
curl ifconfig.me          # VPS public IP
dig yourdomain.com +short # should match
```

Check Cloudflare A record → VPS IP, proxy orange cloud on.

See `12-domain-dns-cloudflare.md`.

---

# 36. HTTPS Not Working

```bash
curl -vI https://yourdomain.com
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com </dev/null 2>/dev/null | openssl x509 -noout -dates
```

Checklist:

* Cloudflare SSL: Full (strict)
* Origin cert or Let's Encrypt valid
* Nginx listening 443
* UFW allows 443

---

# 37. Cloudflare 522 Error

Origin server not responding.

```bash
ssh vps-prod
docker compose ps
curl -I http://localhost
sudo ufw status
```

Fixes: start Nginx/app, allow Cloudflare IPs if blocking, check VPS online.

---

# 38. Cloudflare SSL Loop

Caused by HTTP/HTTPS redirect mismatch.

Fix:

```txt
Cloudflare SSL mode → Full (strict)
Nginx → listen 443 ssl
Do not redirect HTTPS → HTTP
```

See `12-domain-dns-cloudflare.md` section on SSL.

---

# 39. Cloudflare 525 / 526 SSL Errors

525: no valid SSL on origin
526: invalid origin cert

```bash
# Install/regenerate origin cert or Let's Encrypt
sudo certbot certificates
docker compose exec nginx nginx -t
```

Upload Cloudflare Origin Certificate to Nginx if using origin cert.

---

# 40. UFW Blocking Traffic

```bash
sudo ufw status verbose
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 1182/tcp
```

Do **not** open 5432, 6379, 27017 publicly.

---

# 41. Fail2Ban Locked You Out

Via provider console:

```bash
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip YOUR_IP
```

Whitelist your IP in Fail2Ban config if needed.

---

# 42. Unexpected Open Ports

```bash
sudo ss -tulpn | grep LISTEN
sudo ufw status
```

Only 80, 443, SSH port should be public. Close DB ports immediately.

---

# 43. GitHub Actions Deploy Failed

Check GitHub Actions logs for:

* SSH key permission denied → fix `SSH_PRIVATE_KEY` secret
* Docker Hub login failed → fix `DOCKERHUB_TOKEN`
* Health check failed post-deploy → check app logs on VPS

```bash
ssh vps-prod
docker compose logs backend --tail=50
```

See `13-git-github-ci-cd.md`.

---

# 44. Docker Hub Pull Failed

```bash
docker login
docker pull myuser/myapp:latest
docker compose pull
docker compose up -d
```

Rate limit: use authenticated pull or GitHub Container Registry.

---

# 45. Post-Deploy App Broken

```bash
docker compose ps
docker compose logs backend --tail=50
curl -f http://localhost:5000/health

# Rollback
# Edit compose to previous image tag
docker compose pull && docker compose up -d
```

Always backup before deploy (`15-backup-snapshots.md`).

---

# 46. No Internet On VPS

```bash
ping -c 4 8.8.8.8
ping -c 4 google.com
cat /etc/resolv.conf
```

DNS issue vs network issue. Check provider status page.

---

# 47. Cannot Reach Backend Port

```bash
# On VPS
curl http://localhost:5000/health
sudo ss -tlnp | grep 5000

# Backend should NOT be public — Nginx proxies only
# Do not ufw allow 5000 publicly
```

---

# 48. Database Port Exposed Publicly

```bash
sudo ss -tulpn | grep -E '5432|6379|27017'
sudo ufw deny 5432
sudo ufw deny 6379
sudo ufw deny 27017
```

Remove `ports:` mapping from compose for DB services — use internal network only.

---

# 49. Find Errors Fast

```bash
docker compose logs --since 1h 2>&1 | grep -iE 'error|fatal|exception|killed|denied'
sudo journalctl -p err --since today
sudo tail -100 /var/log/auth.log
sudo tail -50 /var/log/nginx/error.log
```

---

# 50. Common Log Locations

| Service | Location |
|---------|----------|
| Docker Compose | `docker compose logs SERVICE` |
| System | `journalctl -xe` |
| SSH auth | `/var/log/auth.log` |
| Nginx (host) | `/var/log/nginx/error.log` |
| Nginx (Docker) | `docker compose logs nginx` |
| PostgreSQL | `docker compose logs postgres` |
| Cron | `/var/log/syslog` |

---

# 51. Emergency Recovery Steps

```txt
1. Confirm outage (curl + Uptime Kuma)
2. SSH to VPS (or provider console)
3. docker compose ps + logs
4. Restart failed service: docker compose up -d SERVICE
5. If deploy caused it → rollback image tag
6. If data corrupted → restore from backup
7. Verify health endpoint
8. Post-mortem: document cause + fix
```

---

# 52. Rollback Deployment

```bash
cd /var/www/myapp
nano docker-compose.yml
# image: myuser/myapp:sha-abc123  (previous working tag)

docker compose pull backend
docker compose up -d backend
curl -f http://localhost:5000/health
```

GitHub Actions: re-run workflow on previous commit or push revert.

---

# 53. Restore From Backup

```bash
# Stop app
docker compose stop backend

# Restore PostgreSQL
gunzip -c ~/backups/latest/postgres-myapp.sql.gz | \
  docker compose exec -T postgres psql -U admin -d myapp

# Start app
docker compose start backend
```

Full procedure: `15-backup-snapshots.md`.

---

# 54. Troubleshooting Rules

✓ Good:

* check logs before restarting
* one change at a time
* backup before risky fixes
* test on staging when possible

✗ Avoid:

* random `reboot` without diagnosis
* editing production `.env` without backup
* `docker system prune -a` without checking
* opening DB ports to fix connection issues

---

# 55. Production Troubleshooting Checklist

```txt
□ Issue reproduced?
□ Logs checked?
□ docker compose ps all Up?
□ Health endpoint OK?
□ Disk/RAM OK?
□ DNS/Cloudflare OK?
□ UFW correct?
□ Fix applied + verified?
□ Monitored 15 min post-fix?
```

---

# 56. Recommended Workflow

```txt
1. Learn standard debug order (section 3)
2. Bookmark log commands
3. Set up health endpoints
4. Configure Uptime Kuma alerts
5. Document runbook for your stack
6. Test rollback procedure once
7. Test backup restore once
```

---

# 57. Modern Workflow

```txt
Alert (Uptime Kuma / user)
→ curl health endpoint
→ ssh vps-prod
→ docker compose logs backend --tail=50
→ fix or rollback
→ verify + monitor
```

---

# 58. Real-World Workflow

```bash
# 502 reported
ssh vps-prod 'cd /var/www/myapp && docker compose ps && docker compose logs backend --tail=30'

# Backend Exit 1 — missing env
ssh vps-prod 'grep DATABASE /var/www/myapp/.env && docker compose up -d backend'

# Verify
curl -f https://api.yourdomain.com/health
```

---

# 59. Final Production Checklist

✓ Debug workflow documented
✓ Health endpoints implemented
✓ Rollback procedure tested
✓ Backup restore tested
✓ Fail2Ban unban procedure known
✓ Provider console access saved
✓ Cloudflare SSL mode correct

---

## Troubleshooting Quick Reference

```bash
# 60-second diagnosis
ssh vps-prod "cd /var/www/myapp && docker compose ps && curl -sf http://localhost:5000/health; docker compose logs backend --tail=20; df -h /; free -h"

# 502 fix
docker compose up -d backend && docker compose logs backend --tail=20

# Disk full
docker system prune -f && journalctl --vacuum-time=7d

# DB connection
docker compose exec backend nc -zv postgres 5432

# Rollback
# Change image tag → docker compose pull && docker compose up -d

# DNS
dig yourdomain.com +short && curl ifconfig.me
```
