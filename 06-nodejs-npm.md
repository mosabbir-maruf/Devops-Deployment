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

# 1. Node.js Installation Approaches

There are two common ways to use Node.js on a VPS:

---

## Global Node.js Installation

Node.js is installed directly on the VPS operating system.

Best for:

- learning Node.js
- local scripts
- simple VPS apps
- PM2 deployments
- development environments

---

## Docker-Based Node.js

Node.js runs inside Docker containers.

Best for:

- production deployments
- isolated environments
- scalable applications
- version management
- microservices
- modern DevOps workflows

Recommended for modern production deployments.

---

# 2. Install Node.js Globally

## Update Packages

```bash
sudo apt update
```

Refreshes Ubuntu package lists.

---

## Install Node.js LTS Repository

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
```

Adds NodeSource Node.js LTS repository.

---

## Install Node.js

```bash
sudo apt install -y nodejs
```

Installs latest LTS version of:

- Node.js
- npm

---

# 3. Verify Node.js Installation

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

# 4. Package Managers

## npm

Default Node.js package manager.

Installed automatically with Node.js.

---

## Install pnpm

```bash
npm install -g pnpm
```

Installs pnpm package manager.

Benefits:

- faster installs
- lower disk usage
- efficient dependency storage

---

## Install Yarn

```bash
npm install -g yarn
```

Installs Yarn package manager.

Alternative to npm.

---

# 5. Create Node.js Project

## Create Project Folder

```bash
mkdir my-node-app
```

Creates Node.js project folder.

---

## Enter Project Folder

```bash
cd my-node-app
```

Moves into the project directory.

---

## Initialize package.json

```bash
npm init -y
```

Creates `package.json` automatically.

---

# 6. package.json

`package.json` contains:

- dependencies
- scripts
- project metadata
- versions
- package information

Example:

```json
{
  "name": "my-node-app",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js"
  }
}
```

---

# 7. Create Basic Node.js App

## Create index.js

```bash
nano index.js
```

Creates application entry file.

---

## Basic Node.js Server

```javascript
const http = require("http");

const server = http.createServer((req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/plain",
  });

  res.end("Node.js server running!");
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

Basic Node.js HTTP server example.

---

## Save File

```txt
Ctrl + O
Enter
Ctrl + X
```

Saves file.

---

# 8. Run Node.js App

## Run Application

```bash
node index.js
```

Runs Node.js application.

---

## Verify In Browser

Open:

```txt
http://YOUR_PUBLIC_IP:3000
```

Should display:

```txt
Node.js server running!
```

---

## Stop Application

```txt
Ctrl + C
```

Stops the Node.js application.

---

# 9. Install Packages

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

# 10. Remove Packages

## Remove Package

```bash
npm uninstall package-name
```

Removes package.

---

# 11. npm Scripts

## Run npm Script

```bash
npm run script-name
```

Runs scripts from `package.json`.

---

## Example package.json Scripts

```json
"scripts": {
  "dev": "node index.js",
  "start": "node index.js"
}
```

---

# 12. Environment Variables

Environment variables store sensitive or configurable values.

---

## Example .env File

```txt
PORT=3000
NODE_ENV=production
DATABASE_URL=your_database_url
JWT_SECRET=your_secret
```

---

## .env Security

Never push `.env` files to GitHub.

Add to `.gitignore`:

```txt
.env
```

---

# 13. node_modules

`node_modules` contains installed dependencies.

Recommended:

- never push `node_modules` to GitHub

Add to `.gitignore`:

```txt
node_modules
```

---

# 14. package-lock.json

`package-lock.json` locks exact dependency versions.

Benefits:

- consistent installs
- reproducible builds
- safer deployments

Recommended:

- always keep `package-lock.json`

---

# 15. Install Dependencies

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

# 16. npm Security & Maintenance

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

# 17. Useful npm Commands

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

# 18. Build Applications

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

# 19. Production Process Manager (PM2)

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

# 20. PM2 Auto Start On Server Reboot

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

# 21. Node.js Monitoring

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

# 22. Node.js Security Basics

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

# 23. Docker + Node.js

## Why Docker For Node.js?

Docker provides:

- isolated environments
- easier deployments
- version consistency
- cleaner production workflows
- easier scaling

Recommended for production deployments.

---

## Create Docker Project Folder

```bash
mkdir docker-node-app
```

Creates Docker Node.js project folder.

---

## Enter Project Folder

```bash
cd docker-node-app
```

Moves into project directory.

---

## Create package.json

```bash
npm init -y
```

Creates Node.js project configuration.

---

## Install Express

```bash
npm install express
```

Installs Express framework.

---

## Create index.js

```bash
nano index.js
```

Creates Node.js application file.

---

## Basic Express App

```javascript
const express = require("express");

const app = express();

app.get("/", (req, res) => {
  res.send("Docker Node.js App Running!");
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

Basic Express application example.

---

## Save File

```txt
Ctrl + O
Enter
Ctrl + X
```

Saves file.

---

## Create Dockerfile

```bash
nano Dockerfile
```

Creates Dockerfile.

---

## Example Node.js Dockerfile

```dockerfile
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

Production-ready basic Node.js Dockerfile.

---

## Add Start Script

Open:

```bash
nano package.json
```

Add:

```json
"scripts": {
  "start": "node index.js"
}
```

---

## Build Docker Image

```bash
docker build -t node-app .
```

Builds Docker image.

---

## Run Docker Container

```bash
docker run -d \
  --name node-app \
  -p 3000:3000 \
  --restart unless-stopped \
  node-app
```

Runs Node.js Docker container.

---

## Verify Running Container

```bash
docker ps
```

Checks running containers.

---

## Verify In Browser

Open:

```txt
http://YOUR_PUBLIC_IP:3000
```

Should display:

```txt
Docker Node.js App Running!
```

---

# 24. Common Node.js Issues

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

## Docker Container Logs

```bash
docker logs CONTAINER_ID
```

Displays Docker container logs.

---

# 25. Performance Tips

- Use PM2 in production
- Use Docker for isolated deployments
- Remove unused dependencies
- Keep Node.js updated
- Use caching when needed
- Monitor RAM/CPU usage
- Use production builds
- Avoid blocking operations
- Use restart policies
- Monitor logs regularly

---

# 26. Recommended Production Workflow

1. Install Docker
2. Install Node.js (optional for local development)
3. Create Node.js project
4. Configure environment variables
5. Build Docker image
6. Run Docker container
7. Configure reverse proxy
8. Configure SSL
9. Monitor logs/processes
10. Configure backups
11. Keep dependencies updated
12. Use Docker Compose for multi-service apps