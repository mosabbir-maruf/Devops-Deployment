# PostgreSQL

## What Is PostgreSQL?

PostgreSQL is a powerful open-source relational SQL database.

Common uses:

- web applications
- APIs
- SaaS platforms
- analytics
- production backend systems

---

# PostgreSQL Concepts

## Database

Container for tables/data.

---

## Table

Stores rows and columns.

---

## Row

Single record inside table.

---

## Primary Key

Unique identifier for records.

---

## Index

Improves query performance.

---

# Install PostgreSQL

## Install PostgreSQL

```bash
sudo apt install postgresql postgresql-contrib -y
```

Installs PostgreSQL server and additional tools.

---

# Verify Installation

## Check PostgreSQL Version

```bash
psql --version
```

Displays PostgreSQL version.

---

## Check PostgreSQL Status

```bash
sudo systemctl status postgresql
```

Checks if PostgreSQL is running.

---

# Start / Stop PostgreSQL

## Start PostgreSQL

```bash
sudo systemctl start postgresql
```

Starts PostgreSQL service.

---

## Restart PostgreSQL

```bash
sudo systemctl restart postgresql
```

Restarts PostgreSQL service.

---

## Stop PostgreSQL

```bash
sudo systemctl stop postgresql
```

Stops PostgreSQL service.

---

## Enable PostgreSQL On Boot

```bash
sudo systemctl enable postgresql
```

Starts PostgreSQL automatically after reboot.

---

# PostgreSQL Default User

PostgreSQL creates default system user:

```txt
postgres
```

---

# Access PostgreSQL Shell

## Login As postgres User

```bash
sudo -u postgres psql
```

Opens PostgreSQL shell.

---

# Database Management

## Show Databases

```sql
\l
```

Displays databases.

---

## Create Database

```sql
CREATE DATABASE mydatabase;
```

Creates database.

---

## Delete Database

```sql
DROP DATABASE mydatabase;
```

Deletes database.

Use carefully.

---

## Connect Database

```sql
\c mydatabase
```

Switches database.

---

# User Management

## Create User

```sql
CREATE USER myuser WITH PASSWORD 'STRONG_PASSWORD';
```

Creates PostgreSQL user.

---

## Grant Database Access

```sql
GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;
```

Gives database access.

---

## Change User Password

```sql
ALTER USER myuser WITH PASSWORD 'NEW_PASSWORD';
```

Updates user password.

---

## Delete User

```sql
DROP USER myuser;
```

Deletes PostgreSQL user.

---

# Table Management

## Create Table

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT UNIQUE
);
```

Creates table.

---

## Show Tables

```sql
\dt
```

Displays tables.

---

## Insert Data

```sql
INSERT INTO users (name, email)
VALUES ('Mosabbir', 'test@example.com');
```

Inserts row into table.

---

## Read Data

```sql
SELECT * FROM users;
```

Displays table data.

---

## Delete Data

```sql
DELETE FROM users WHERE id = 1;
```

Deletes row.

---

# PostgreSQL Config Files

## Main Config

```txt
/etc/postgresql/
```

Stores PostgreSQL configuration.

---

## PostgreSQL Config File

```txt
postgresql.conf
```

Main PostgreSQL config file.

---

## Authentication Config

```txt
pg_hba.conf
```

Controls authentication access.

---

# Enable Remote Access

## Edit PostgreSQL Config

```bash
sudo nano /etc/postgresql/*/main/postgresql.conf
```

---

## Change Listen Address

```txt
listen_addresses = '*'
```

Allows external connections.

---

# Configure Authentication

## Edit pg_hba.conf

```bash
sudo nano /etc/postgresql/*/main/pg_hba.conf
```

---

## Example Remote Access Rule

```txt
host    all    all    YOUR_IP/32    md5
```

Allows trusted IP access only.

---

# Restart PostgreSQL

## Apply Config Changes

```bash
sudo systemctl restart postgresql
```

Restarts PostgreSQL.

---

# PostgreSQL Security

## Restrict Public Access

Use firewall rules.

---

## Allow Trusted IP Only

```bash
sudo ufw allow from YOUR_IP to any port 5432
```

Allows trusted access.

---

## Block Public Access

```bash
sudo ufw deny 5432
```

Blocks public PostgreSQL access.

---

## Check PostgreSQL Port

```bash
sudo ss -tulpn | grep 5432
```

Displays PostgreSQL port usage.

---

# PostgreSQL Backup

## Backup Database

```bash
pg_dump mydatabase > backup.sql
```

Creates database backup.

---

## Restore Database

```bash
psql mydatabase < backup.sql
```

Restores backup.

---

# Backup All Databases

## Full PostgreSQL Backup

```bash
pg_dumpall > all-databases.sql
```

Backs up all databases/users.

---

# PostgreSQL Logs

## PostgreSQL Logs Location

```txt
/var/log/postgresql/
```

Stores PostgreSQL logs.

---

## Monitor Logs

```bash
sudo tail -f /var/log/postgresql/postgresql-*.log
```

Streams PostgreSQL logs live.

---

# PostgreSQL Monitoring

## Show Active Connections

```sql
SELECT * FROM pg_stat_activity;
```

Displays active connections.

---

## Show Database Sizes

```sql
SELECT datname, pg_size_pretty(pg_database_size(datname))
FROM pg_database;
```

Displays database sizes.

---

## Show Table Sizes

```sql
SELECT
  relname AS table_name,
  pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
```

Displays table sizes.

---

# PostgreSQL Indexes

## Create Index

```sql
CREATE INDEX idx_users_email ON users(email);
```

Improves query performance.

---

## Show Indexes

```sql
\di
```

Displays indexes.

---

# PostgreSQL Docker Example

## Run PostgreSQL Container

```bash
docker run -d \
--name postgres \
-p 5432:5432 \
-e POSTGRES_USER=admin \
-e POSTGRES_PASSWORD=STRONG_PASSWORD \
-e POSTGRES_DB=mydatabase \
-v postgres_data:/var/lib/postgresql/data \
postgres
```

Runs PostgreSQL container with persistent storage.

---

# PostgreSQL Volume Persistence

```txt
-v postgres_data:/var/lib/postgresql/data
```

Keeps database data persistent.

---

# PostgreSQL Connection URL

Example:

```txt
postgresql://USER:PASSWORD@HOST:5432/DATABASE
```

Used in backend applications.

---

# PostgreSQL GUI Tools

Popular PostgreSQL GUIs:

- pgAdmin
- TablePlus
- DBeaver
- DataGrip

---

# PostgreSQL Security Best Practices

- Use strong passwords
- Restrict public access
- Use firewall protection
- Backup databases regularly
- Keep PostgreSQL updated
- Monitor logs regularly
- Limit remote access
- Use SSL in production if possible
- Remove unused users/databases

---

# PostgreSQL Performance Tips

- Create indexes for frequently queried columns
- Monitor slow queries
- Remove unused indexes
- Monitor storage usage
- Use SSD storage
- Keep backups regularly
- Monitor active connections

---

# Common PostgreSQL Issues

## PostgreSQL Not Starting

Check:

```bash
sudo systemctl status postgresql
```

---

## Authentication Failed

Possible reasons:

- wrong password
- pg_hba.conf issue
- wrong username

---

## Port Already In Use

Check:

```bash
sudo ss -tulpn | grep 5432
```

---

## Too Many Connections

Check active connections:

```sql
SELECT * FROM pg_stat_activity;
```

---

## Disk Full

Check:

```bash
df -h
```

---

# Recommended Production Workflow

1. Install PostgreSQL
2. Create database/user
3. Configure authentication
4. Restrict public access
5. Configure firewall
6. Enable backups
7. Create indexes
8. Monitor logs/resources
9. Monitor storage usage
10. Keep PostgreSQL updated
11. Backup databases regularly