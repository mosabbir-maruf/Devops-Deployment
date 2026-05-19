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

# Node.js Installation Approaches

There are two common ways to use Node.js on a VPS.

Choose ONE workflow depending on your use case.

---

## Option 1 → Global Node.js Installation

Node.js is installed directly on the VPS operating system.

Best for:

- learning Node.js
- local development
- PM2 deployments
- simple VPS apps
- running scripts directly

Go to:

```md
[Global Node.js Workflow](#global-nodejs-workflow)
```

---

## Option 2 → Docker-Based Node.js

Node.js runs inside Docker containers.

Best for:

- production deployments
- isolated environments
- scalable applications
- version consistency
- microservices
- modern DevOps workflows

Recommended for production deployments.

Go to:

```md
[Docker-Based Node.js Workflow](#docker-based-nodejs-workflow)
```

---

# Global Node.js Workflow

# 1. Install Node.js Globally

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

# 2. Verify Global Installation

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

# 3. Package Managers

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

# 4. Create Node.js Project

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

# 5. package.json

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

# 6. Create Basic Node.js App

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

# 7. Run Node.js App

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

# 8. Install Packages

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

# 9. Remove Packages

## Remove Package

```bash
npm uninstall package-name
```

Removes package.

---

# 10. npm Scripts

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

# 11. Environment Variables

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

# 12. node_modules

`node_modules` contains installed dependencies.

Recommended:

- never push `node_modules` to GitHub

Add to `.gitignore`:

```txt
node_modules
```

---

# 13. package-lock.json

`package-lock.json` locks exact dependency versions.

Benefits:

- consistent installs
- reproducible builds
- safer deployments

Recommended:

- always keep `package-lock.json`

---

# 14. Install Dependencies

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

# 15. npm Security & Maintenance

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

# 16. Useful npm Commands

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

# 17. Build Applications

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

# 18. Production Process Manager (PM2)

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

# 19. PM2 Auto Start On Server Reboot

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

# 20. Node.js Monitoring

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

# 21. Node.js Security Basics

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

# Docker-Based Node.js Workflow

# 1. Pull Node.js Docker Image

## Download Node.js Docker Image

```bash
docker pull node:20
```

Downloads official Node.js Docker image.

---

## Verify Downloaded Images

```bash
docker images
```

Should show:

```txt
node:20
```

---

# 2. Run Temporary Node.js Container

## Start Interactive Node.js Container

```bash
docker run -it node:20 bash
```

Starts temporary interactive Node.js container.

Useful for:

- testing Node.js
- testing npm
- temporary development
- quick experiments

---

## Check Node.js Version

```bash
node -v
```

Displays Node.js version inside Docker container.

---

## Check npm Version

```bash
npm -v
```

Displays npm version inside Docker container.

---

## Exit Container

```bash
exit
```

Stops and exits temporary container.

---

# 3. Create Docker-Based Node.js Project

## Create Project Folder

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

## Initialize Node.js Project

```bash
npm init -y
```

Creates `package.json`.

---

## Install Express

```bash
npm install express
```

Installs Express framework.

---

# 4. Create Node.js App

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

# 5. Create Dockerfile

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

## Save Dockerfile

```txt
Ctrl + O
Enter
Ctrl + X
```

Saves Dockerfile.

---

# 6. Configure package.json

## Open package.json

```bash
nano package.json
```

---

## Add Start Script

```json
"scripts": {
  "start": "node index.js"
}
```

---

## Save package.json

```txt
Ctrl + O
Enter
Ctrl + X
```

Saves package.json.

---

# 7. Build Docker Image

## Build Node.js Docker Image

```bash
docker build -t node-app .
```

Builds Docker image.

---

## Verify Docker Images

```bash
docker images
```

Displays Docker images.

---

# 8. Run Docker Container

## Run Node.js Docker Container

```bash
docker run -d \
  --name node-app \
  -p 3000:3000 \
  --restart unless-stopped \
  node-app
```

Runs Node.js Docker container in background.

---

## Verify Running Containers

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

# 9. Docker Container Management

## View Container Logs

```bash
docker logs node-app
```

Displays container logs.

---

## Live Container Logs

```bash
docker logs -f node-app
```

Streams live container logs.

---

## Restart Container

```bash
docker restart node-app
```

Restarts container.

---

## Stop Container

```bash
docker stop node-app
```

Stops container.

---

## Start Container Again

```bash
docker start node-app
```

Starts stopped container.

---

## Remove Container

```bash
docker rm -f node-app
```

Deletes container.

---

# 10. Docker-Based Production Best Practices

- Use Docker for production deployments
- Use restart policies
- Use environment variables
- Use Docker volumes for persistent storage
- Keep Docker images updated
- Avoid running containers as root
- Monitor logs regularly
- Use reverse proxy in production
- Use HTTPS/SSL
- Use Docker Compose for multi-service apps

---

# 11. Common Node.js Issues

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

# 12. Performance Tips

- Use PM2 for global Node.js deployments
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

# 13. Recommended Production Workflow

## Global Node.js Workflow

1. Install Node.js
2. Create project
3. Configure environment variables
4. Install PM2
5. Run application with PM2
6. Configure reverse proxy
7. Configure SSL
8. Monitor logs/processes
9. Configure backups

---

## Docker-Based Workflow

1. Install Docker
2. Create Node.js project
3. Create Dockerfile
4. Build Docker image
5. Run Docker container
6. Configure reverse proxy
7. Configure SSL
8. Monitor container logs
9. Configure backups
10. Use Docker Compose for multi-service apps.