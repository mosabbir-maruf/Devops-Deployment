# Server Monitoring

## Table Of Contents

### Fundamentals

1. [What Is Server Monitoring](#1-what-is-server-monitoring)
2. [Monitoring In Production](#2-monitoring-in-production)
3. [Production Architecture](#3-production-architecture)
4. [What To Monitor](#4-what-to-monitor)
5. [Alert Thresholds](#5-alert-thresholds)

### Installation

6. [Install Monitoring Tools On Linux (VPS)](#6-install-monitoring-tools-on-linux-vps)
7. [Install Monitoring Tools On Mac](#7-install-monitoring-tools-on-mac)
8. [Install Netdata (Optional Dashboard)](#8-install-netdata-optional-dashboard)
9. [Verify Monitoring Setup](#9-verify-monitoring-setup)

### System Monitoring

10. [CPU And RAM Monitoring](#10-cpu-and-ram-monitoring)
11. [Disk And Inode Monitoring](#11-disk-and-inode-monitoring)
12. [Network And Port Monitoring](#12-network-and-port-monitoring)
13. [Process And Uptime Monitoring](#13-process-and-uptime-monitoring)
14. [System Logs (journalctl)](#14-system-logs-journalctl)

### Docker Monitoring

15. [Container Status And Health](#15-container-status-and-health)
16. [Docker Stats And Resource Usage](#16-docker-stats-and-resource-usage)
17. [Docker Compose Logs](#17-docker-compose-logs)
18. [Docker Disk Usage](#18-docker-disk-usage)

### Service Monitoring

19. [Nginx Monitoring](#19-nginx-monitoring)
20. [PostgreSQL Monitoring](#20-postgresql-monitoring)
21. [Redis Monitoring](#21-redis-monitoring)
22. [MongoDB Monitoring](#22-mongodb-monitoring)
23. [Application Health Checks](#23-application-health-checks)

### Security Monitoring

24. [SSH And Auth Log Monitoring](#24-ssh-and-auth-log-monitoring)
25. [Fail2Ban Monitoring](#25-fail2ban-monitoring)
26. [UFW And Open Port Audits](#26-ufw-and-open-port-audits)

### Production Workflow

27. [Daily Monitoring Routine](#27-daily-monitoring-routine)
28. [Weekly Maintenance Checks](#28-weekly-maintenance-checks)
29. [Automated Monitoring Script](#29-automated-monitoring-script)
30. [Uptime Kuma (External Monitoring)](#30-uptime-kuma-external-monitoring)
31. [Production Monitoring Checklist](#31-production-monitoring-checklist)

### Security Best Practices

32. [Monitoring Security Rules](#32-monitoring-security-rules)
33. [Security Checklist](#33-security-checklist)

### Troubleshooting

34. [High RAM Usage](#34-high-ram-usage)
35. [High CPU Usage](#35-high-cpu-usage)
36. [Disk Full](#36-disk-full)
37. [Container Crashing](#37-container-crashing)
38. [Service Not Running](#38-service-not-running)

### Cleanup And Uninstall

39. [Remove Netdata On Linux](#39-remove-netdata-on-linux)
40. [Remove Glances And Extra Tools](#40-remove-glances-and-extra-tools)
41. [Log Cleanup](#41-log-cleanup)
42. [Cache And Leftover Files](#42-cache-and-leftover-files)
43. [Verification After Removal](#43-verification-after-removal)

### Production Workflows

44. [Recommended Production Workflow](#44-recommended-production-workflow)
45. [Modern Workflow](#45-modern-workflow)
46. [Real-World Workflow](#46-real-world-workflow)
47. [Final Production Checklist](#47-final-production-checklist)

---

# 1. What Is Server Monitoring

Server monitoring tracks VPS health, Docker containers, databases, logs, and application availability.

Production targets:

* CPU, RAM, disk, network
* Docker container health
* application `/health` endpoints
* SSH auth failures
* backup job success

Goal: detect problems before users report them.

---

# 2. Monitoring In Production

```txt
External Monitor (Uptime Kuma / Cloudflare)
↓
VPS Host (CPU, RAM, disk)
↓
Docker Compose (container health)
↓
Application (health endpoints, logs)
↓
Databases (connections, disk, memory)
```

Monitor from two layers:

```txt
Outside  → Is the site reachable? (HTTPS, DNS)
Inside   → Are containers healthy? (docker compose ps, logs)
```

---

# 3. Production Architecture

```txt
Uptime Kuma (optional, separate VPS or Mac)
↓ pings https://yourdomain.com/health

Cloudflare Analytics
↓ traffic, threats, errors

VPS (ssh vps-prod)
↓ docker stats, df -h, journalctl
↓ docker compose logs
↓ fail2ban-client status
```

Daily: SSH + commands. Weekly: full checklist. Optional: Netdata dashboard on VPS.

---

# 4. What To Monitor

| Layer | What | Command |
|-------|------|---------|
| Host | RAM, CPU, disk | `free -h`, `htop`, `df -h` |
| Docker | containers, stats | `docker compose ps`, `docker stats` |
| App | health endpoint | `curl -f https://api.yourdomain.com/health` |
| Nginx | errors, 5xx | `docker compose logs nginx` |
| PostgreSQL | connections, size | `pg_stat_activity`, `pg_database_size` |
| Redis | memory, evictions | `redis-cli INFO memory` |
| Security | SSH failures | `/var/log/auth.log`, Fail2Ban |
| Backups | cron success | `ls ~/backups/`, cron logs |

---

# 5. Alert Thresholds

```txt
RAM  > 85%   → investigate / upgrade VPS
Disk > 85%   → prune Docker images, clean logs
CPU  > 90% sustained → check docker stats, traffic spike
5xx errors   → check backend logs immediately
SSH failures > 10/min → verify Fail2Ban active
Backup missing → check cron, fix script
```

---

# 6. Install Monitoring Tools On Linux (VPS)

```bash
sudo apt update
sudo apt install -y htop glances dnsutils curl jq
```

Optional:

```bash
sudo apt install -y net-tools lm-sensors
```

Verify:

```bash
htop --version
glances --version
```

---

# 7. Install Monitoring Tools On Mac

```bash
brew install htop glances jq
```

Docker Desktop includes container stats in GUI. CLI:

```bash
docker stats
docker compose logs -f
```

Mac monitors local dev — production monitoring runs on VPS via SSH.

---

# 8. Install Netdata (Optional Dashboard)

Real-time web dashboard on VPS (port 19999 — restrict access).

```bash
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
sudo sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry
```

Access via SSH tunnel (do not expose publicly):

```bash
ssh -L 19999:127.0.0.1:19999 vps-prod
# Open http://localhost:19999
```

---

# 9. Verify Monitoring Setup

```bash
ssh vps-prod
free -h && df -h && uptime
docker compose ps
docker stats --no-stream
curl -f http://localhost:5000/health
sudo fail2ban-client status
sudo ufw status
```

All checks should pass before considering monitoring complete.

---

# 10. CPU And RAM Monitoring

```bash
free -h
htop
top -bn1 | head -20
docker stats --no-stream
```

```bash
# Memory breakdown
free -m
cat /proc/meminfo | grep -E 'MemTotal|MemAvailable|Swap'
```

---

# 11. Disk And Inode Monitoring

```bash
df -h
df -i
du -sh /var/lib/docker
du -sh /var/www/myapp
du -sh ~/backups
```

Find large files:

```bash
du -h /var --max-depth=2 2>/dev/null | sort -hr | head -20
docker system df
```

---

# 12. Network And Port Monitoring

```bash
sudo ss -tulpn
sudo ss -tlnp | grep -E ':80|:443|:1182'
nc -zv localhost 80
curl -I http://localhost
ping -c 4 google.com
dig yourdomain.com +short
```

Expected open publicly: 80, 443, SSH custom port only.

---

# 13. Process And Uptime Monitoring

```bash
uptime
who
w
ps aux --sort=-%mem | head -10
ps aux --sort=-%cpu | head -10
```

---

# 14. System Logs (journalctl)

```bash
sudo journalctl --since "1 hour ago"
sudo journalctl -u docker -f
sudo journalctl -u ssh -f
sudo journalctl -p err --since today
```

---

# 15. Container Status And Health

```bash
cd /var/www/myapp
docker compose ps
docker compose ps -a
docker inspect backend --format='{{.State.Health.Status}}'
```

Expected: all services `Up` or `healthy`.

---

# 16. Docker Stats And Resource Usage

```bash
docker stats --no-stream
docker stats backend postgres redis --no-stream
watch -n 5 'docker stats --no-stream'
```

---

# 17. Docker Compose Logs

```bash
docker compose logs -f
docker compose logs backend --tail=100 --since 1h
docker compose logs nginx --tail=50
docker compose logs postgres --tail=30
```

Export:

```bash
docker compose logs > ~/logs/compose-$(date +%F).log 2>&1
```

---

# 18. Docker Disk Usage

```bash
docker system df
docker system df -v
du -sh /var/lib/docker
```

Prune when disk high (careful in production):

```bash
docker image prune -f
docker system prune -f
```

---

# 19. Nginx Monitoring

## Docker Nginx

```bash
docker compose logs nginx -f
docker compose exec nginx nginx -t
curl -I http://localhost
curl -I https://yourdomain.com
```

## Host Nginx

```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
sudo nginx -t
```

Watch for 502/503/504 in access logs.

---

# 20. PostgreSQL Monitoring

```bash
docker compose exec postgres pg_isready -U admin
docker compose exec postgres psql -U admin -d myapp -c "
  SELECT count(*) FROM pg_stat_activity;
  SELECT pg_size_pretty(pg_database_size('myapp'));
"
docker compose logs postgres --tail=30
```

---

# 21. Redis Monitoring

```bash
docker compose exec redis redis-cli -a PASSWORD ping
docker compose exec redis redis-cli -a PASSWORD INFO memory
docker compose exec redis redis-cli -a PASSWORD INFO stats | grep evicted
docker compose logs redis --tail=30
```

---

# 22. MongoDB Monitoring

```bash
docker compose exec mongodb mongosh --eval "db.adminCommand('ping')"
docker compose exec mongodb du -sh /data/db
docker compose logs mongodb --tail=30
```

---

# 23. Application Health Checks

```bash
curl -f http://localhost:5000/health
curl -f https://api.yourdomain.com/health
curl -f https://yourdomain.com
```

Automated:

```bash
#!/bin/bash
curl -sf https://api.yourdomain.com/health > /dev/null && echo "OK" || echo "FAIL"
```

---

# 24. SSH And Auth Log Monitoring

```bash
sudo tail -f /var/log/auth.log
sudo grep "Failed password\|Invalid user" /var/log/auth.log | tail -20
sudo grep "Accepted publickey" /var/log/auth.log | tail -10
sudo journalctl -u ssh --since "1 hour ago"
```

---

# 25. Fail2Ban Monitoring

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client status sshd | grep "Banned IP"
```

---

# 26. UFW And Open Port Audits

```bash
sudo ufw status verbose
sudo ss -tulpn | grep LISTEN
```

Audit monthly — only 80, 443, SSH port should be public.

---

# 27. Daily Monitoring Routine

```bash
ssh vps-prod
cd /var/www/myapp
docker compose ps
curl -sf https://api.yourdomain.com/health && echo OK || echo FAIL
docker compose logs backend --tail=20 --since 24h
df -h / && free -h
sudo fail2ban-client status sshd
ls -lt ~/backups/ | head -5
```

5 minutes daily catches most issues early.

---

# 28. Weekly Maintenance Checks

```bash
ssh vps-prod
sudo apt update && sudo apt upgrade -y
docker system df
docker image prune -f
sudo journalctl --vacuum-time=14d
docker compose ps
curl -f https://yourdomain.com/health
```

---

# 29. Automated Monitoring Script

```bash
nano ~/scripts/monitor.sh
```

```bash
#!/bin/bash
set -euo pipefail
ALERT=""

# Disk
DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
[ "$DISK" -gt 85 ] && ALERT+="DISK:${DISK}% "

# Memory
MEM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
[ "$MEM" -gt 90 ] && ALERT+="MEM:${MEM}% "

# Docker
cd /var/www/myapp
docker compose ps | grep -q "Exit" && ALERT+="CONTAINER_DOWN "

# Health
curl -sf http://localhost:5000/health > /dev/null || ALERT+="HEALTH_FAIL "

if [ -n "$ALERT" ]; then
  echo "ALERT: $ALERT $(date)"
  # Optional: send email or webhook notification
else
  echo "OK $(date)"
fi
```

```bash
chmod +x ~/scripts/monitor.sh
crontab -e
# */15 * * * * /home/mosabbir/scripts/monitor.sh >> /home/mosabbir/logs/monitor.log 2>&1
```

---

# 30. Uptime Kuma (External Monitoring)

Run on separate machine or local Mac — pings your production URLs.

```bash
docker run -d --restart=always \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  --name uptime-kuma \
  louislam/uptime-kuma:1
```

Monitor:

```txt
https://yourdomain.com
https://api.yourdomain.com/health
```

Alerts via Telegram, email, or Slack on downtime.

---

# 31. Production Monitoring Checklist

```txt
✓ docker compose ps — all healthy
✓ health endpoints responding
✓ disk < 85%
✓ RAM < 85%
✓ Fail2Ban active
✓ recent backups exist
✓ no error spikes in logs
✓ Cloudflare analytics normal
```

---

# 32. Monitoring Security Rules

✓ Good:

* Netdata/Uptime Kuma via SSH tunnel only
* monitoring scripts run as non-root
* auth.log reviewed regularly

✗ Avoid:

* exposing Netdata port 19999 publicly
* monitoring dashboards without authentication

---

# 33. Security Checklist

✓ Fail2Ban monitored
✓ SSH auth log reviewed
✓ UFW port audit monthly
✓ no unexpected open ports

---

# 34. High RAM Usage

```bash
free -h
docker stats --no-stream
ps aux --sort=-%mem | head -10
```

Fixes: restart leaky container, upgrade VPS RAM, set Redis `--maxmemory`, reduce container count.

---

# 35. High CPU Usage

```bash
htop
docker stats --no-stream
docker compose logs backend --tail=50
```

Fixes: traffic spike (Cloudflare WAF), infinite loop in app, crypto mining (check auth.log).

---

# 36. Disk Full

```bash
df -h
docker system df
du -sh /var/lib/docker ~/backups /var/log
```

Fixes:

```bash
docker system prune -f
sudo journalctl --vacuum-time=7d
rm ~/backups/old-*
```

---

# 37. Container Crashing

```bash
docker compose ps -a
docker compose logs backend --tail=50
docker inspect backend --format='{{.State.RestartCount}}'
```

Fix root cause in code/config — redeploy, do not patch running container.

---

# 38. Service Not Running

```bash
sudo systemctl status docker
sudo systemctl status ssh
docker compose ps
docker compose up -d
```

---

# 39. Remove Netdata On Linux

```bash
sudo /usr/libexec/netdata-uninstaller.sh --yes
# or:
sudo bash /opt/netdata/bin/uninstall-netdata.sh --yes
sudo rm -rf /opt/netdata /etc/netdata /var/lib/netdata /var/cache/netdata
```

Verify:

```bash
systemctl status netdata
ss -tlnp | grep 19999
```

---

# 40. Remove Glances And Extra Tools

```bash
sudo apt purge -y glances net-tools lm-sensors
sudo apt autoremove -y
```

Mac:

```bash
brew uninstall glances
```

---

# 41. Log Cleanup

```bash
sudo journalctl --vacuum-time=14d
sudo journalctl --vacuum-size=500M
rm -f ~/logs/monitor-*.log
rm -f ~/logs/compose-*.log
truncate -s 0 $(docker inspect --format='{{.LogPath}}' backend) 2>/dev/null
```

---

# 42. Cache And Leftover Files

```bash
rm -rf /var/cache/netdata 2>/dev/null
rm -f ~/scripts/monitor.sh.bak
docker system prune -f
```

---

# 43. Verification After Removal

```bash
which netdata glances
systemctl list-units | grep netdata
ss -tlnp | grep 19999
```

---

# 44. Recommended Production Workflow

```txt
1. Install htop + basic tools on VPS
2. Set up daily SSH monitoring routine
3. Add health check endpoints to app
4. Configure automated monitor.sh cron
5. Optional: Uptime Kuma external pings
6. Optional: Netdata via SSH tunnel
7. Weekly maintenance + log review
8. Monitor backup job success daily
```

---

# 45. Modern Workflow

```txt
Uptime Kuma → pings https://yourdomain.com/health
Cloudflare Analytics → traffic + threats
Developer → ssh vps-prod → docker compose ps + logs
GitHub Actions → post-deploy health curl
```

---

# 46. Real-World Workflow

```bash
# Morning check (2 min)
ssh vps-prod "docker compose ps && curl -sf https://api.myapp.com/health && df -h /"

# Weekly (15 min)
ssh vps-prod "apt upgrade -y && docker system prune -f && journalctl --vacuum-time=14d"

# Alert on failure
# Uptime Kuma → Telegram notification
```

---

# 47. Final Production Checklist

✓ Daily health check automated or manual
✓ Disk/RAM thresholds defined
✓ docker compose ps monitored
✓ Fail2Ban active and checked
✓ backup success verified
✓ external uptime monitor configured
✓ log rotation configured

---

## Server Monitoring Quick Commands

```bash
# Host
free -h && df -h && uptime

# Docker
docker compose ps
docker stats --no-stream
docker compose logs backend --tail=50
docker system df

# Health
curl -f https://api.yourdomain.com/health

# Security
sudo fail2ban-client status sshd
sudo tail -20 /var/log/auth.log

# Disk emergency
docker system prune -f
sudo journalctl --vacuum-time=7d
```
