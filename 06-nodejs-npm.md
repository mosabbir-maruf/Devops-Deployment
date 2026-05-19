# Node.js & npm

## What Is Node.js?

Node.js is a JavaScript runtime used to run JavaScript outside the browser.

Common uses:

- Backend servers
- APIs
- Full-stack applications
- Real-time apps
- Automation tools
- CLI tools
- Microservices

---

# What Is npm?

npm (Node Package Manager) is used to install and manage JavaScript packages.

Used for:

- installing packages
- dependency management
- scripts
- project setup
- publishing packages

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

# package.json

`package.json` contains:

- dependencies
- scripts
- project metadata
- versions
- package information

---

# Install Packages

## Install Dependency

```bash
npm install package-name
```

Installs package locally.

---

## Install Dev Dependency

```bash
npm install -D package-name
```

Installs development dependency.

---

## Install Global Package

```bash
npm install -g package-name
```

Installs package globally.

---

# Remove Packages

## Remove Package

```bash
npm uninstall package-name
```

Removes package.

---

# Run Node.js App

## Run JavaScript File

```bash
node index.js
```

Runs Node.js application.

---

# npm Scripts

## Run npm Script

```bash
npm run script-name
```

Runs scripts from `package.json`.

---

# Example package.json Scripts

```json
"scripts": {
  "dev": "node index.js",
  "start": "node index.js"
}
```

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

# .env Security

Never push `.env` files to GitHub.

Add to `.gitignore`:

```txt
.env
```

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

# package-lock.json

`package-lock.json` locks exact dependency versions.

Benefits:

- consistent installs
- reproducible builds
- safer deployments

Recommended:
- Always keep `package-lock.json`

---

# Install Dependencies

## Install Project Dependencies

```bash
npm install
```

Installs dependencies from `package.json`.

---

## Install Only Production Dependencies

```bash
npm install --production
```

Installs only production packages.

Useful for VPS deployments.

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

# Useful npm Commands

## List Installed Packages

```bash
npm list
```

Displays installed packages.

---

## Clear npm Cache

```bash
npm cache clean --force
```

Clears npm cache.

---

## Check npm Cache

```bash
npm cache verify
```

Verifies npm cache integrity.

---

# Build Applications

## Build Production App

```bash
npm run build
```

Builds production application.

Common in frameworks like:

- Next.js
- React
- Vue
- Nuxt

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

## Start App With Name

```bash
pm2 start index.js --name myapp
```

Starts application with custom name.

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

## Monitor PM2 Processes

```bash
pm2 monit
```

Displays real-time monitoring dashboard.

---

## View PM2 Logs

```bash
pm2 logs
```

Displays application logs.

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

# Node.js Monitoring

## Check Running Node Processes

```bash
ps aux | grep node
```

Displays running Node.js processes.

---

## Check Open Ports

```bash
sudo ss -tulpn
```

Displays open ports/services.

---

## Monitor Server Resources

```bash
htop
```

Displays live CPU/RAM usage.

---

# Node.js Security Basics

- Never expose `.env` files
- Use strong secrets/passwords
- Keep dependencies updated
- Avoid unnecessary packages
- Validate user input
- Use HTTPS in production
- Do not run apps as root
- Store secrets securely
- Avoid exposing internal APIs publicly

---

# Docker + Node.js

## Example Dockerfile

```dockerfile
FROM node:20

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
```

Basic Node.js Docker setup.

---

# Common Node.js Issues

## Port Already In Use

Check ports:

```bash
sudo ss -tulpn
```

---

## Dependency Issues

Delete old dependencies:

```bash
rm -rf node_modules package-lock.json
```

Reinstall:

```bash
npm install
```

---

## Permission Errors

Fix npm permissions:

```bash
sudo chown -R $USER:$USER ~/.npm
```

---

## Application Crashing

Check logs:

```bash
pm2 logs
```

---

# Performance Tips

- Use PM2 in production
- Remove unused dependencies
- Keep Node.js updated
- Use caching when needed
- Monitor RAM/CPU usage
- Use production builds
- Avoid blocking operations

---

# Recommended Production Workflow

1. Install Node.js
2. Create project
3. Initialize package.json
4. Install dependencies
5. Configure environment variables
6. Build production app
7. Run application with PM2
8. Monitor logs/processes
9. Run npm audit regularly
10. Keep dependencies updated
11. Configure backups