# MongoDB

# What Is MongoDB?

MongoDB is a NoSQL document database used to store application data in JSON-like documents.

Common uses:

- Web applications
- APIs
- Real-time apps
- Full-stack applications

---

# Install MongoDB

## Import MongoDB GPG Key

```bash
curl -fsSL https://pgp.mongodb.com/server-8.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
--dearmor
```

Adds official MongoDB security key.

---

## Add MongoDB Repository

```bash
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
```

Adds official MongoDB repository.

---

## Update Packages

```bash
sudo apt update
```

Refreshes package lists.

---

## Install MongoDB

```bash
sudo apt install -y mongodb-org
```

Installs MongoDB server.

---

# Start MongoDB

## Enable MongoDB

```bash
sudo systemctl enable mongod
```

Starts MongoDB automatically on reboot.

---

## Start MongoDB Service

```bash
sudo systemctl start mongod
```

Starts MongoDB service.

---

## Check MongoDB Status

```bash
sudo systemctl status mongod
```

Checks if MongoDB is running.

---

# MongoDB Shell

## Open Mongo Shell

```bash
mongosh
```

Opens MongoDB shell.

---

# Create Database User

## Switch To Admin Database

```javascript
use admin
```

---

## Create Admin User

```javascript
db.createUser({
  user: "admin",
  pwd: "STRONG_PASSWORD",
  roles: [ { role: "root", db: "admin" } ]
})
```

Creates MongoDB administrator user.

---

# Enable MongoDB Authentication

## Open MongoDB Config

```bash
sudo nano /etc/mongod.conf
```

---

## Add Security Section

```yaml
security:
  authorization: enabled
```

Enables MongoDB authentication.

---

# Restrict Public Access

## Configure bindIp

Inside `mongod.conf`:

```yaml
net:
  bindIp: 127.0.0.1
```

Restricts MongoDB access to local server only.

Recommended for security.

---

# Restart MongoDB

## Restart MongoDB Service

```bash
sudo systemctl restart mongod
```

Applies MongoDB configuration changes.

---

# Login With Authentication

```bash
mongosh -u admin -p --authenticationDatabase admin
```

Logs into MongoDB securely.

---

# MongoDB Firewall Security

## Block Public MongoDB Access

```bash
sudo ufw deny 27017
```

Blocks public MongoDB access.

---

## Check MongoDB Port

```bash
sudo ss -tulpn | grep 27017
```

Checks MongoDB port usage.

---

# MongoDB Backup

## Create Backup

```bash
mongodump --out backup-folder
```

Creates MongoDB backup.

---

## Restore Backup

```bash
mongorestore backup-folder
```

Restores MongoDB backup.

---

# MongoDB Export & Import

## Export Collection

```bash
mongoexport
```

Exports MongoDB data.

---

## Import Collection

```bash
mongoimport
```

Imports MongoDB data.

---

# Docker MongoDB Example

## Run MongoDB Container

```bash
docker run -d \
--name mongodb \
-p 27017:27017 \
-v mongodb_data:/data/db \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=STRONG_PASSWORD \
mongo
```

Runs MongoDB using Docker with persistent storage.

---

# Docker Volume Persistence

```txt
-v mongodb_data:/data/db
```

Keeps database data even if container is removed.

---

# MongoDB Monitoring

## Check MongoDB Logs

```bash
sudo journalctl -u mongod
```

Displays MongoDB logs.

---

## Check MongoDB Resource Usage

```bash
docker stats
```

Displays live container resource usage.

---

# MongoDB Compass

MongoDB Compass is the official GUI for MongoDB.

Used for:

- viewing databases
- collections
- documents
- queries
- indexes

---

# MongoDB Security Best Practices

- Use strong passwords
- Enable authentication
- Restrict public access
- Keep MongoDB updated
- Use regular backups
- Avoid exposing database publicly
- Monitor logs regularly
- Use firewall protection
- Store secrets securely

---

# Useful MongoDB Workflow

1. Install MongoDB
2. Start MongoDB service
3. Create admin user
4. Enable authentication
5. Restrict public access
6. Restart MongoDB
7. Configure backups
8. Monitor logs and usage
