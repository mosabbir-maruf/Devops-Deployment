# Redis

## What Is Redis?

Redis is an in-memory data store used for:

- caching
- sessions
- queues
- pub/sub
- rate limiting
- real-time applications

Redis is extremely fast because data is stored in memory (RAM).

---

# Common Redis Use Cases

- API caching
- authentication sessions
- JWT blacklist
- queues/jobs
- Socket.IO adapter
- rate limiting
- temporary storage

---

# Install Redis

## Install Redis

```bash
sudo apt install redis-server -y
```

Installs Redis server.

---

# Verify Redis Installation

## Check Redis Version

```bash
redis-server --version
```

Displays installed Redis version.

---

## Check Redis Status

```bash
sudo systemctl status redis-server
```

Checks if Redis is running.

---

# Start / Stop Redis

## Start Redis

```bash
sudo systemctl start redis-server
```

Starts Redis service.

---

## Restart Redis

```bash
sudo systemctl restart redis-server
```

Restarts Redis service.

---

## Stop Redis

```bash
sudo systemctl stop redis-server
```

Stops Redis service.

---

## Enable Redis On Boot

```bash
sudo systemctl enable redis-server
```

Starts Redis automatically after reboot.

---

# Redis CLI

## Open Redis CLI

```bash
redis-cli
```

Opens Redis shell.

---

# Basic Redis Commands

## Set Value

```bash
SET username "mosabbir"
```

Stores value.

---

## Get Value

```bash
GET username
```

Retrieves stored value.

---

## Delete Key

```bash
DEL username
```

Deletes key.

---

## Check Existing Keys

```bash
KEYS *
```

Displays all keys.

Avoid in large production databases.

---

## Check Key Existence

```bash
EXISTS username
```

Checks if key exists.

---

# Expiration / TTL

## Set Expiry

```bash
EXPIRE username 60
```

Expires key after 60 seconds.

---

## Check TTL

```bash
TTL username
```

Displays remaining expiration time.

---

# Redis Data Types

Redis supports:

- strings
- lists
- sets
- hashes
- sorted sets

---

# Hash Example

## Create Hash

```bash
HSET user name "Mosabbir"
```

Stores hash field.

---

## Get Hash Value

```bash
HGET user name
```

Retrieves hash field.

---

# Redis Persistence

Redis can persist data to disk.

---

# Redis Config File

## Redis Configuration

```txt
/etc/redis/redis.conf
```

Main Redis config file.

---

# Enable Persistence

## RDB Snapshotting

Inside `redis.conf`:

```txt
save 60 1000
```

Creates snapshot after changes.

---

# Append Only File (AOF)

## Enable AOF

Inside `redis.conf`:

```txt
appendonly yes
```

Improves persistence reliability.

---

# Redis Security

## Set Redis Password

Inside `redis.conf`:

```txt
requirepass STRONG_PASSWORD
```

Protects Redis with password.

---

# Restrict Public Access

## Bind To Localhost

Inside `redis.conf`:

```txt
bind 127.0.0.1
```

Restricts Redis to local server only.

Recommended for production.

---

# Disable Dangerous Commands

Inside `redis.conf`:

```txt
rename-command FLUSHALL ""
rename-command FLUSHDB ""
```

Disables dangerous commands.

---

# Restart Redis After Config Changes

## Restart Redis

```bash
sudo systemctl restart redis-server
```

Applies Redis config changes.

---

# Login With Password

## Authenticate Redis

```bash
AUTH STRONG_PASSWORD
```

Authenticates Redis session.

---

# Redis Firewall Security

## Block Public Redis Port

```bash
sudo ufw deny 6379
```

Blocks public Redis access.

---

## Check Redis Port

```bash
sudo ss -tulpn | grep 6379
```

Displays Redis port usage.

---

# Redis Monitoring

## Redis Information

```bash
INFO
```

Displays Redis statistics/info.

---

## Check Memory Usage

```bash
INFO memory
```

Displays memory usage.

---

## Monitor Commands Live

```bash
MONITOR
```

Streams Redis commands live.

Use carefully in production.

---

# Redis Logs

## Redis Logs Location

```txt
/var/log/redis/redis-server.log
```

Redis log file location.

---

## View Redis Logs

```bash
sudo tail -f /var/log/redis/redis-server.log
```

Streams Redis logs live.

---

# Redis Backup

## Backup Redis Database

```bash
cp /var/lib/redis/dump.rdb backup.rdb
```

Creates Redis backup.

---

# Redis Docker Example

## Run Redis Container

```bash
docker run -d \
--name redis \
-p 6379:6379 \
redis
```

Runs Redis container.

---

# Redis Docker With Password

## Secure Redis Docker Container

```bash
docker run -d \
--name redis \
-p 6379:6379 \
redis redis-server --requirepass STRONG_PASSWORD
```

Runs password-protected Redis container.

---

# Redis Volume Persistence

## Persistent Redis Data

```bash
docker run -d \
--name redis \
-v redis_data:/data \
redis redis-server --appendonly yes
```

Stores Redis data persistently.

---

# Redis Resource Monitoring

## Live Container Usage

```bash
docker stats
```

Displays CPU/RAM usage.

---

## Check Redis Memory

```bash
redis-cli INFO memory
```

Displays Redis memory statistics.

---

# Redis Pub/Sub

Redis supports real-time publish/subscribe messaging.

Used for:

- chats
- notifications
- Socket.IO scaling
- real-time systems

---

# Redis Queue Systems

Popular queue libraries:

- BullMQ
- Bee-Queue
- Agenda

Used for:

- background jobs
- email queues
- scheduled tasks

---

# Redis Security Best Practices

- Never expose Redis publicly
- Use strong passwords
- Restrict firewall access
- Bind Redis to localhost
- Disable dangerous commands
- Keep Redis updated
- Monitor memory usage
- Backup Redis regularly

---

# Redis Performance Tips

- Use expiration/TTL for temporary data
- Avoid storing huge objects
- Monitor RAM usage
- Use persistence carefully
- Remove unused keys
- Use Redis primarily for caching/temporary data

---

# Common Redis Issues

## Redis Connection Refused

Check:

```bash
sudo systemctl status redis-server
```

---

## Redis High Memory Usage

Check:

```bash
redis-cli INFO memory
```

---

## Redis Authentication Failed

Possible reasons:

- wrong password
- missing AUTH command
- wrong config

---

## Redis Port Already In Use

Check:

```bash
sudo ss -tulpn | grep 6379
```

---

# Recommended Production Workflow

1. Install Redis
2. Enable persistence
3. Set Redis password
4. Restrict public access
5. Configure firewall
6. Restart Redis
7. Monitor memory usage
8. Configure backups
9. Keep Redis updated
10. Monitor logs/resources