# Node.js & npm

# What Is Node.js?

Node.js is a JavaScript runtime used to run JavaScript outside the browser.

Common uses:

- Backend servers
- APIs
- Full-stack applications
- Real-time apps
- Automation tools

---

# What Is npm?

npm (Node Package Manager) is used to install and manage JavaScript packages.

---

# Install Node.js

## Install Node.js LTS

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

Installs latest LTS version of Node.js and npm.

---

# Verify Installation

## Check Node.js Version

```bash
node -v
```

Displays installed Node.js version.

---

## Check npm Version

```bash
npm -v
```

Displays installed npm version.

---

# Package Managers

## npm

Default Node.js package manager.

---

## pnpm

Fast and disk-efficient package manager.

Install pnpm:

```bash
npm install -g pnpm
```

---

## Yarn

Alternative package manager.

Install Yarn:

```bash
npm install -g yarn
```

---

# Create Node.js Project

## Initialize Project

```bash
npm init -y
```

Creates `package.json` automatically.

---

# Install Packages

## Install Dependency

```bash
npm install package-name
```

Installs package locally.

---

## Install Global Package

```bash
npm install -g package-name
```

Installs package globally.

---

# Run Node.js App

## Run JavaScript File

```bash
node index.js
```

Runs Node.js application.

---

# Production Process Manager (PM2)

## Install PM2

```bash
npm install -g pm2
```

Installs PM2 process manager.

---

## Start Application

```bash
pm2 start index.js
```

Runs application in background.

---

## Show Running Apps

```bash
pm2 list
```

Displays running PM2 applications.

---

## Restart App

```bash
pm2 restart APP_NAME
```

Restarts application.

---

## Stop App

```bash
pm2 stop APP_NAME
```

Stops application.

---

## Delete App

```bash
pm2 delete APP_NAME
```

Removes application from PM2.

---

# PM2 Auto Start On Server Reboot

## Save PM2 Processes

```bash
pm2 save
```

Saves current PM2 processes.

---

## Enable PM2 Startup

```bash
pm2 startup
```

Enables automatic startup after reboot.

---

# Environment Variables

Environment variables store sensitive or configurable values.

Example `.env` file:

```txt
PORT=3000
NODE_ENV=production
DATABASE_URL=your_database_url
JWT_SECRET=your_secret
```

---

# npm Security & Maintenance

## Check Security Vulnerabilities

```bash
npm audit
```

Scans dependencies for known security vulnerabilities.

---

## Automatically Fix Vulnerabilities

```bash
npm audit fix
```

Attempts to automatically fix vulnerable packages.

---

## Force Fix Vulnerabilities

```bash
npm audit fix --force
```

Forces major dependency updates to fix vulnerabilities.

Use carefully in production projects.

---

## Check Outdated Packages

```bash
npm outdated
```

Displays outdated dependencies.

---

## Update Packages

```bash
npm update
```

Updates installed dependencies.

---

## Install Only Production Dependencies

```bash
npm install --production
```

Installs only production packages.

Useful for VPS deployments.

---

# package-lock.json

`package-lock.json` locks exact dependency versions.

Benefits:

- consistent installs
- reproducible builds
- safer deployments

Recommended:
- Always keep `package-lock.json`

---

# node_modules

`node_modules` contains installed dependencies.

Recommended:
- Do not push `node_modules` to GitHub

Add to `.gitignore`:

```txt
node_modules
```

---

# .env Security

Never push `.env` files to GitHub.

Add to `.gitignore`:

```txt
.env
```

---

# Node.js Security Basics

- Never expose `.env` files
- Use strong secrets/passwords
- Keep dependencies updated
- Avoid unnecessary packages
- Validate user input
- Use HTTPS in production
- Do not run apps as root

---

# Useful npm Commands

## Install Dependencies

```bash
npm install
```

Installs project dependencies.

---

## Remove Package

```bash
npm uninstall package-name
```

Removes package.

---

## Update Packages

```bash
npm update
```

Updates installed packages.

---

# Useful Workflow

1. Install Node.js
2. Create project
3. Install dependencies
4. Configure environment variables
5. Run application
6. Use PM2 for production
7. Run npm audit
8. Monitor logs/processes
