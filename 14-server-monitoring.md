# Server Monitoring

## What Is Server Monitoring?

Server monitoring means tracking:

- CPU usage
- RAM usage
- disk usage
- network activity
- application health
- logs
- uptime

Helps detect:

- crashes
- high resource usage
- attacks
- downtime
- performance issues

---

# Why Monitoring Matters

Benefits:

- improves stability
- prevents downtime
- detects attacks/issues early
- helps performance optimization
- helps production debugging

---

# Basic System Monitoring

## Check RAM Usage

```bash
free -h
```

Displays memory usage.

---

## Check Disk Usage

```bash
df -h
```

Displays disk storage usage.

---

## Check Folder Size

```bash
du -sh folder-name
```

Displays folder size.

---

## Check CPU Usage

```bash
htop
```

Displays live CPU/RAM monitoring.

Install if missing:

```bash
sudo apt install htop -y
```

---

## Show Running Processes

```bash
ps aux
```

Displays running processes.

---

## Show Top Processes

```bash
top
```

Displays live process usage.

---

# Monitor Open Ports

## Check Open Ports

```bash
sudo ss -tulpn
```

Displays open ports/services.

---

## Check Specific Port

```bash
sudo ss -tulpn | grep 3000
```

Checks specific port.

---

# Monitor Active Connections

## Show Connected Users

```bash
who
```

Displays logged-in users.

---

## Show Network Connections

```bash
netstat -plant
```

Displays network connections.

Install if missing:

```bash
sudo apt install net-tools -y
```

---

# Uptime Monitoring

## Check Server Uptime

```bash
uptime
```

Displays uptime/load average.

---

# Monitor Logs

## System Logs

```bash
journalctl
```

Displays system logs.

---

## Live System Logs

```bash
journalctl -f
```

Streams logs live.

---

## Service Logs

```bash
journalctl -u service-name
```

Displays service logs.

---

# Nginx Monitoring

## Access Logs

```bash
sudo tail -f /var/log/nginx/access.log
```

Displays live Nginx access logs.

---

## Error Logs

```bash
sudo tail -f /var/log/nginx/error.log
```

Displays live Nginx error logs.

---

# Docker Monitoring

## Running Containers

```bash
docker ps
```

Displays running containers.

---

## Container Resource Usage

```bash
docker stats
```

Displays CPU/RAM/network usage.

---

## Container Logs

```bash
docker logs CONTAINER_ID
```

Displays container logs.

---

## Live Docker Logs

```bash
docker logs -f CONTAINER_ID
```

Streams Docker logs live.

---

# PM2 Monitoring

## PM2 Process List

```bash
pm2 list
```

Displays running applications.

---

## PM2 Monitoring Dashboard

```bash
pm2 monit
```

Displays live monitoring dashboard.

---

## PM2 Logs

```bash
pm2 logs
```

Displays application logs.

---

# MongoDB Monitoring

## MongoDB Logs

```bash
sudo journalctl -u mongod
```

Displays MongoDB logs.

---

## MongoDB Live Logs

```bash
sudo journalctl -u mongod -f
```

Streams MongoDB logs live.

---

# PostgreSQL Monitoring

## PostgreSQL Logs

```bash
sudo tail -f /var/log/postgresql/postgresql-*.log
```

Displays PostgreSQL logs.

---

## Active PostgreSQL Connections

```sql
SELECT * FROM pg_stat_activity;
```

Displays active DB connections.

---

# Redis Monitoring

## Redis Memory Usage

```bash
redis-cli INFO memory
```

Displays Redis memory statistics.

---

## Redis Logs

```bash
sudo tail -f /var/log/redis/redis-server.log
```

Displays Redis logs.

---

# Disk Monitoring

## Largest Folders

```bash
du -h / | sort -rh | head -20
```

Displays largest folders/files.

---

## Check Inode Usage

```bash
df -i
```

Displays inode usage.

---

# Network Monitoring

## Ping Test

```bash
ping google.com
```

Tests internet connectivity.

---

## Check DNS Resolution

```bash
nslookup google.com
```

Checks DNS resolution.

---

## Test Port Connectivity

```bash
nc -zv SERVER_IP PORT
```

Tests port connectivity.

---

# Security Monitoring

## Failed SSH Login Attempts

```bash
sudo journalctl -u ssh
```

Displays SSH authentication logs.

---

## Fail2Ban Status

```bash
sudo fail2ban-client status
```

Displays Fail2Ban status.

---

## Check Banned IPs

```bash
sudo fail2ban-client status sshd
```

Displays banned IPs.

---

# Resource Alerts

Important things to monitor:

- high RAM usage
- high CPU usage
- low disk space
- failed services
- unusual traffic spikes
- repeated failed logins

---

# Monitor Server Temperature

## CPU Temperature

```bash
sensors
```

Displays hardware temperatures.

Install if missing:

```bash
sudo apt install lm-sensors -y
```

---

# Automatic Monitoring Tools

Popular monitoring tools:

- Netdata
- Grafana
- Prometheus
- Uptime Kuma
- Glances

---

# Install Glances

## Install Glances

```bash
sudo apt install glances -y
```

Advanced monitoring dashboard.

---

## Run Glances

```bash
glances
```

Displays detailed system monitoring.

---

# Install Netdata

## Install Netdata

```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

Installs real-time monitoring dashboard.

---

# Backup Monitoring

Important backup targets:

- databases
- Docker volumes
- application files
- environment variables
- Nginx configs

Monitor backup success regularly.

---

# Monitoring Best Practices

- Monitor logs daily
- Watch disk usage regularly
- Remove unused Docker images
- Restart crashed services quickly
- Use automatic alerts if possible
- Backup before major changes
- Monitor failed login attempts
- Monitor RAM/CPU spikes

---

# Common Monitoring Issues

## High RAM Usage

Check:

```bash
htop
```

Possible reasons:

- memory leak
- too many containers
- large database usage

---

## High CPU Usage

Check:

```bash
top
```

Possible reasons:

- infinite loops
- attacks
- high traffic
- overloaded services

---

## Disk Full

Check:

```bash
df -h
```

Possible reasons:

- logs growing
- backups
- Docker images
- database storage

---

## Container Crashing

Check:

```bash
docker logs CONTAINER_ID
```

---

## Service Not Running

Check:

```bash
sudo systemctl status service-name
```

---

# Recommended Production Workflow

1. Monitor RAM/CPU usage
2. Monitor disk usage
3. Monitor logs regularly
4. Monitor Docker containers
5. Monitor database resources
6. Monitor failed login attempts
7. Configure backups
8. Remove unused resources
9. Restart failed services quickly
10. Keep monitoring tools updated