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

# MongoDB Version

## Check MongoDB Version

```bash
mongod --version
```

Displays installed MongoDB server version.

---

## Check Mongo Shell Version

```bash
mongosh --version
```

Displays installed MongoDB shell version.

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

## Stop MongoDB Service

```bash
sudo systemctl stop mongod
```

Stops MongoDB service.

---

## Restart MongoDB Service

```bash
sudo systemctl restart mongod
```

Restarts MongoDB service.

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

# MongoDB Databases

## Show Databases

```javascript
show dbs
```

Displays all databases.

---

## Create / Switch Database

```javascript
use mydatabase
```

Creates or switches database.

---

## Show Collections

```javascript
show collections
```

Displays collections inside current database.

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

# Enable Remote Access (Only If Needed)

```yaml
net:
  bindIp: 0.0.0.0
```

Allows external connections.

Only use with:

- firewall protection
- IP restrictions
- authentication enabled
- trusted servers only

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

# Delete Database

## Remove Current Database

```javascript
db.dropDatabase()
```

Deletes current database.

Use carefully.

---

# MongoDB File Locations

## MongoDB Config File

```txt
/etc/mongod.conf
```

Main MongoDB configuration file.

---

## MongoDB Storage Location

```txt
/var/lib/mongodb
```

Default MongoDB database storage location.

---

## MongoDB Logs Location

```txt
/var/log/mongodb
```

Default MongoDB logs location.

---

# MongoDB Disk Usage

## Check Database Storage Usage

```bash
du -sh /var/lib/mongodb
```

Displays MongoDB disk usage.

---

# MongoDB Indexes

## Create Index

```javascript
db.users.createIndex({ email: 1 })
```

Improves query performance.

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

## Check Live Resource Usage

```bash
docker stats
```

Displays live CPU/RAM usage.

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

# MongoDB Docker Security

- Never expose port `27017` publicly unless necessary
- Use strong passwords
- Use persistent Docker volumes
- Restrict firewall access
- Keep MongoDB updated
- Enable authentication

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

# Recommended MongoDB Production Workflow

1. Install MongoDB
2. Start MongoDB service
3. Create admin user
4. Enable authentication
5. Restrict public access
6. Configure firewall
7. Setup backups
8. Monitor logs/resources
9. Create indexes
10. Keep MongoDB updated
