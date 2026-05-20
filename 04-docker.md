.# Docker

# What Is Docker?

Docker is a container platform used to package, distribute and run applications in isolated environments called containers.

Docker helps developers create consistent development and production environments.

Benefits:

- Consistent environments
- Easy deployments
- Lightweight virtualization
- Faster setup
- Portable applications
- Production-ready workflows
- Simplified application management
- Better scalability
- Easier CI/CD integration

---

# Docker Concepts

## Container

A lightweight isolated runtime environment used to run applications.

Containers are created from Docker images.

---

## Image

A reusable immutable template used to create containers.

Example:

```txt
node:24-slim
nginx
ubuntu
```

---

## Volume

Persistent Docker-managed storage used for containers.

Used for:

- databases
- uploads
- application data
- persistent storage

---

## Bind Mount

Maps a local host folder directly into a container.

Commonly used during development.

Example:

```txt
Local Project Folder
↓
Mounted Into Container
```

Example:

```bash
-v $(PWD):/app
```

---

## Network

Allows communication between containers and services.

Example:

- frontend ↔ backend
- backend ↔ database

---

# Development Workflow vs Production Workflow

One of the most important Docker concepts:

```txt
Development Workflow
≠
Production Workflow
```

---

# Development Workflow

During development:

- code changes frequently
- fast iteration is important
- hot reload is required

Best practice:

```txt
Bind Mount
+
npm run dev
+
Hot Reload
```

Development containers are usually temporary.

---

## Development Best Practices

Use:

- bind mounts
- hot reload
- dev servers
- temporary containers

Avoid:

- rebuilding images after every code change

---

# Production Workflow

Production containers should be:

```txt
Immutable
Predictable
Portable
Stable
```

Best practice:

```txt
New Code
↓
Build New Image
↓
Deploy New Container
↓
Remove Old Container
```

Production containers should not use bind mounts.

---

# Immutable Infrastructure Concept

Production containers should never be manually modified.

Instead:

```txt
Change Source Code
↓
Build New Image
↓
Deploy New Container
```

This ensures:

- consistency
- rollback safety
- scalability
- automation reliability

---

# Docker Image vs Container

```txt
Dockerfile
↓
Build Image
↓
Run Container
↓
Application Running
```

---

## Image

Blueprint/template.

---

## Container

Running instance created from an image.

---

# Stateless vs Stateful Services

## Stateless Services

Can be safely recreated anytime.

Examples:

- frontend
- backend API
- nginx

---

## Stateful Services

Require persistent storage.

Examples:

- PostgreSQL
- MongoDB
- Redis

Usually require Docker volumes.

---

# 1. Install Docker

## Remove Old Docker Packages

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

---

## Update Packages

```bash
sudo apt update
```

---

## Install Required Packages

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

---

## Create Docker GPG Directory

```bash
sudo mkdir -p /etc/apt/keyrings
```

---

## Add Docker GPG Key

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

---

## Add Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

## Update Packages Again

```bash
sudo apt update
```

---

## Install Docker Engine

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Installs:

- Docker Engine
- Docker CLI
- Buildx
- Compose Plugin
- containerd

---

## Enable Docker On Boot

```bash
sudo systemctl enable docker
```

---

## Start Docker Service

```bash
sudo systemctl start docker
```

---

## Verify Docker Service

```bash
sudo systemctl status docker
```

Should show:

```txt
active (running)
```

---

## Add User To Docker Group

```bash
sudo usermod -aG docker $USER
```

Allows Docker commands without sudo.

---

## Restart Session

```bash
exit
```

Logout/login again.

---

# 2. Verify Docker Installation

## Check Docker Version

```bash
docker --version
```

---

## Check Compose Version

```bash
docker compose version
```

---

## Test Docker

```bash
docker run hello-world
```

Should display:

```txt
Hello from Docker!
```

---

# 3. Basic Docker Commands

## Running Containers

```bash
docker ps
```

---

## All Containers

```bash
docker ps -a
```

---

## Docker Images

```bash
docker images
```

---

## Docker Volumes

```bash
docker volume ls
```

---

## Docker Networks

```bash
docker network ls
```

---

# 4. Docker Images

## Pull Image

```bash
docker pull nginx
```

---

## Remove Image

```bash
docker rmi IMAGE_ID
```

---

## Remove Unused Images

```bash
docker image prune -a
```

---

# 5. Dockerfile & Image Building

## Create Project Folder

```bash
mkdir myapp
```

---

## Enter Folder

```bash
cd myapp
```

---

## Create Dockerfile

```bash
nano Dockerfile
```

---

## Example Dockerfile

```dockerfile
FROM node:24-slim

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

---

# .dockerignore

## Create .dockerignore

```bash
nano .dockerignore
```

---

## Example .dockerignore

```txt
node_modules
dist
.git
.env
Dockerfile
README.md
```

Prevents unnecessary files from being copied into Docker images.

Improves:

- build speed
- security
- image size

---

## Build Docker Image

```bash
docker build -t myapp .
```

Meaning:

```txt
Build image:
myapp

Using:
current directory (.)
```

---

## Tagged Build

```bash
docker build -t myapp:latest .
```

---

## Verify Images

```bash
docker images
```

---

# 6. Docker Containers

## Run Container

```bash
docker run nginx
```

Foreground mode.

---

## Detached Container

```bash
docker run -d --name nginx-server nginx
```

Background mode.

---

## Run Container With Port Mapping

```bash
docker run -d \
--name myapp \
-p 3000:80 \
myapp
```

Meaning:

```txt
HOST_PORT:CONTAINER_PORT
```

Example:

```txt
localhost:3000
↓
container:80
```

---

## Production Style Container

```bash
docker run --rm -it \
--name myapp-prod \
-p 3000:3000 \
myapp
```

---

# Development Container Workflow

## Best Practice Development Command

```bash
docker run --rm -it \
--name myapp-dev \
-p 3000:3000 \
-v $(PWD):/app \
-w /app \
node:24-slim \
sh -c "npm install && npm run dev"
```

---

# Why This Development Workflow Is Best

Benefits:

- live reload
- fast iteration
- no rebuild every change
- local development speed
- isolated runtime environment

---

# How Bind Mount Works

```bash
-v $(PWD):/app
```

Meaning:

```txt
Local Project Folder
↓
Mounted Into Container /app
```

Local code changes instantly reflect inside the container.

---

# Why `--rm` Is Important

```bash
--rm
```

Meaning:

```txt
Container auto deletes after stopping
```

Prevents stopped container buildup.

Best practice for development containers.

---

# Stop Container

```bash
docker stop CONTAINER_ID
```

---

# Start Container

```bash
docker start CONTAINER_ID
```

---

# Restart Container

```bash
docker restart CONTAINER_ID
```

---

# Remove Container

```bash
docker rm CONTAINER_ID
```

---

# Force Remove Container

```bash
docker rm -f CONTAINER_ID
```

---

# Container Logs

## Show Logs

```bash
docker logs CONTAINER_ID
```

---

## Live Logs

```bash
docker logs -f CONTAINER_ID
```

---

# Execute Commands Inside Container

## Open Shell

```bash
docker exec -it CONTAINER_ID sh
```

Meaning:

```txt
Open interactive shell inside running container
```

---

## Run Command Inside Container

```bash
docker exec CONTAINER_ID ls
```

---

# Docker Volumes

## Create Volume

```bash
docker volume create my-volume
```

---

## Inspect Volume

```bash
docker volume inspect my-volume
```

---

## Persistent Nginx Example

```bash
docker run -d \
--name nginx-server \
-p 8080:80 \
-v nginx-data:/usr/share/nginx/html \
nginx
```

---

# Named Volume Example

```bash
-v my-volume:/app/data
```

Meaning:

```txt
Docker Managed Volume
↓
Mounted Into Container
```

---

# 7. Docker Compose

## What Is Docker Compose?

Used to manage multiple services together.

Examples:

- frontend
- backend
- database
- redis
- nginx

---

## docker-compose.yml Example

```yaml
services:
  app:
    image: nginx
    ports:
      - "3000:80"
```

---

## Start Compose

```bash
docker compose up -d
```

---

## Stop Compose

```bash
docker compose down
```

---

## Restart Compose

```bash
docker compose restart
```

---

## Compose Logs

```bash
docker compose logs -f
```

---

# 8. Docker Networks

## Create Network

```bash
docker network create mynetwork
```

---

## Inspect Network

```bash
docker network inspect mynetwork
```

---

# 9. Docker Security Best Practices

- Use official images
- Avoid exposing unnecessary ports
- Do not expose databases publicly
- Use environment variables for secrets
- Remove unused images/containers
- Keep Docker updated
- Use restart policies
- Avoid running containers as root
- Backup important volumes
- Monitor resources regularly

---

# 10. Docker Monitoring

## Resource Usage

```bash
docker stats
```

---

## Disk Usage

```bash
docker system df
```

---

# 11. Docker Cleanup

## Remove Stopped Containers

```bash
docker container prune
```

---

## Remove Unused Images

```bash
docker image prune -a
```

---

## Remove Unused Volumes

```bash
docker volume prune
```

---

## Remove Unused Networks

```bash
docker network prune
```

---

## Remove Everything Unused

```bash
docker system prune -a
```

---

# 12. Docker Service Commands

## Restart Docker

```bash
sudo systemctl restart docker
```

---

## Stop Docker

```bash
sudo systemctl stop docker
```

---

## Docker Service Logs

```bash
journalctl -u docker -f
```

---

# 13. Useful Docker Development Workflow

```txt
Write Code
↓
Save File
↓
Hot Reload
↓
Browser Updates Automatically
```

---

# Development Workflow

```txt
Bind Mount
+
npm run dev
+
Hot Reload
```

---

# Production Workflow

```txt
Build Immutable Image
↓
Deploy New Container
↓
Remove Old Container
```

---

# CI/CD Workflow

```txt
GitHub Push
↓
GitHub Actions
↓
Build Docker Image
↓
Push To Registry
↓
Deploy New Container
```

---

# Docker Hub

Docker Hub is a container image registry.

Used to:

- store images
- distribute images
- pull images on servers
- use CI/CD workflows

---

# Common Docker Issues

## Dockerfile Not Found

Ensure:

```txt
Dockerfile
```

exists inside current directory.

---

## Port Already In Use

Check:

```bash
sudo ss -tulpn
```

---

## Permission Denied

Fix:

```bash
sudo usermod -aG docker $USER
```

Logout/login again.

---

## Invalid Reference Format

Usually caused by incorrect Docker command formatting.

Example wrong:

```bash
docker run \ --name app
```

Correct:

```bash
docker run \
--name app
```

---

## Docker Build Requires 1 Argument

Wrong:

```bash
docker build -t myapp
```

Correct:

```bash
docker build -t myapp .
```

`.` means current directory.

---

# Real-World Docker Learning Path

```txt
Development Workflow
↓
Docker Basics
↓
Containers & Images
↓
Volumes & Networks
↓
Reverse Proxy
↓
Docker Compose
↓
CI/CD
↓
Production Deployment
↓
Container Orchestration
↓
Kubernetes
```