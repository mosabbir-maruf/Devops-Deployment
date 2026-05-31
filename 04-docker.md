# Docker

## Table Of Contents

### Fundamentals

1. [What Is Docker](#1-what-is-docker)
2. [Docker Concepts](#2-docker-concepts)
3. [Development Workflow vs Production Workflow](#3-development-workflow-vs-production-workflow)
4. [Development Workflow](#4-development-workflow)
5. [Production Workflow](#5-production-workflow)
6. [Immutable Infrastructure Concept](#6-immutable-infrastructure-concept)
7. [Docker Image vs Container](#7-docker-image-vs-container)
8. [Stateless vs Stateful Services](#8-stateless-vs-stateful-services)

### Installation

9. [Install Docker On Linux](#9-install-docker-on-linux)
10. [Install Docker On Mac](#10-install-docker-on-mac)
11. [Verify Docker Installation](#11-verify-docker-installation)

### Core Components

12. [Docker Images](#12-docker-images)
13. [Docker Containers](#13-docker-containers)
14. [Docker Volumes](#14-docker-volumes)
15. [Bind Mounts](#15-bind-mounts)
16. [Docker Networks](#16-docker-networks)

### Dockerfile

17. [Dockerfile](#17-dockerfile)
18. [Docker Ignore](#18-docker-ignore)
19. [Build Docker Images](#19-build-docker-images)

### Docker Compose

20. [Docker Compose](#20-docker-compose)
21. [Docker Compose Commands](#21-docker-compose-commands)
22. [Production Docker Compose Structure](#22-production-docker-compose-structure)
23. [Health Checks](#23-health-checks)

### Development Workflow

24. [Development Containers](#24-development-containers)
25. [Hot Reload Workflow](#25-hot-reload-workflow)
26. [Development Best Practices](#26-development-best-practices)

### Production Workflow

27. [Production Containers](#27-production-containers)
28. [Production Deployment Workflow](#28-production-deployment-workflow)
29. [Frontend Backend Database Architecture](#29-frontend-backend-database-architecture)
30. [Docker With Nginx](#30-docker-with-nginx)
31. [Docker With Cloudflare](#31-docker-with-cloudflare)

### Registry

32. [Docker Hub](#32-docker-hub)
33. [Push Images](#33-push-images)
34. [Pull Images](#34-pull-images)

### Logs Monitoring Debugging

35. [Container Logs](#35-container-logs)
36. [Docker Compose Logs](#36-docker-compose-logs)
37. [Docker Exec](#37-docker-exec)
38. [Docker Inspect](#38-docker-inspect)
39. [Docker Monitoring](#39-docker-monitoring)
40. [Docker Debugging](#40-docker-debugging)

### Security

41. [Docker Security Best Practices](#41-docker-security-best-practices)
42. [Environment Variables](#42-environment-variables)
43. [Secrets Management](#43-secrets-management)

### Cleanup

44. [Docker Cleanup](#44-docker-cleanup)
45. [Uninstall Docker On Linux](#45-uninstall-docker-on-linux)
46. [Uninstall Docker On Mac](#46-uninstall-docker-on-mac)
47. [Remove Docker Desktop](#47-remove-docker-desktop)
48. [Full Cleanup Verification](#48-full-cleanup-verification)

### VPS Deployment

49. [VPS Docker Workflow](#49-vps-docker-workflow)
50. [Deployment Commands](#50-deployment-commands-legacy)
51. [Rollback Workflow](#51-rollback-workflow)

### Reference

52. [Docker Service Commands](#52-docker-service-commands)
53. [Docker Quick Commands Cheat Sheet](#53-docker-quick-commands-cheat-sheet)
54. [Common Docker Issues](#54-common-docker-issues)
55. [Real World Docker Learning Path](#55-real-world-docker-learning-path)

# 1. What Is Docker

Docker is a container platform used to package, distribute and run applications in isolated environments called containers.

Docker allows applications to run consistently across:

* local machines
* development environments
* staging servers
* production servers

Benefits:

* consistent environments
* easy deployments
* lightweight virtualization
* portable applications
* scalable infrastructure
* simplified dependency management
* CI/CD integration
* production-ready workflows

---

# 2. Docker Concepts

Understanding these concepts is essential before using Docker in production.

---

## Container

A container is a lightweight isolated runtime environment.

Containers contain:

* application code
* runtime
* dependencies
* required libraries

Containers are created from Docker images.

---

## Image

An image is an immutable template used to create containers.

Examples:

```txt
node:24-slim
nginx:alpine
ubuntu:24.04
postgres:17
redis:8
```

Think of an image as:

```txt
Blueprint
↓
Container
```

---

## Volume

Volumes provide persistent storage.

Data remains available even if containers are removed.

Common use cases:

* PostgreSQL data
* MongoDB data
* Redis persistence
* uploaded files
* application storage

Example:

```txt
Container Deleted
↓
Volume Remains
↓
Data Preserved
```

---

## Bind Mount

A bind mount maps a host directory directly into a container.

Commonly used during development.

Example:

```txt
Local Folder
↓
Container Folder
```

Example:

```bash
-v $(PWD):/app
```

---

## Network

Docker networks allow containers to communicate securely.

Examples:

```txt
Frontend
↓
Backend
```

```txt
Backend
↓
Database
```

```txt
Backend
↓
Redis
```

Containers on the same Docker network can communicate using service names.

Example:

```txt
frontend
↓
backend:5000
```

---

# 3. Development Workflow vs Production Workflow

One of the most important Docker concepts:

```txt
Development Workflow
≠
Production Workflow
```

Many beginners accidentally use development practices in production.

Avoid this.

---

# 4. Development Workflow

Development focuses on:

* fast iteration
* rapid testing
* hot reload
* local debugging

Recommended workflow:

```txt
Bind Mount
+
npm run dev
+
Hot Reload
```

---

## Development Example

```txt
Code Change
↓
Save File
↓
Container Detects Change
↓
Application Reloads
```

No image rebuild required.

---

## Development Best Practices

Use:

* bind mounts
* hot reload
* development servers
* temporary containers

Examples:

```txt
Next.js
React
Node.js
Vite
NestJS
```

---

## Development Anti-Patterns

Avoid:

```txt
Rebuild Image
↓
Restart Container
↓
Every Code Change
```

This slows development significantly.

---

# 5. Production Workflow

Production focuses on:

* stability
* reproducibility
* predictability
* automation

Recommended workflow:

```txt
New Code
↓
Build New Image
↓
Deploy New Container
↓
Remove Old Container
```

---

## Production Rules

Production containers should be:

```txt
Immutable
Portable
Predictable
Reproducible
```

---

## Production Anti-Patterns

Never:

```txt
SSH Into Container
↓
Modify Files
↓
Save Changes
```

Never:

```txt
Use Bind Mounts For Application Code
```

Never:

```txt
Manually Edit Running Containers
```

---

# 6. Immutable Infrastructure Concept

Production containers should never be modified manually.

Instead:

```txt
Change Source Code
↓
Commit Changes
↓
Build New Image
↓
Deploy New Container
```

Benefits:

* consistency
* rollback safety
* automation
* easier scaling
* easier deployments

---

# 7. Docker Image vs Container

Relationship:

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

Image = blueprint.

Examples:

```txt
nginx:alpine
node:24-slim
postgres:17
```

Images are:

```txt
Read Only
Immutable
Reusable
```

---

## Container

Container = running instance of an image.

Example:

```txt
Image
↓
Multiple Containers
```

One image can create many containers.

---

# 8. Stateless vs Stateful Services

Understanding this concept is critical for production deployments.

---

## Stateless Services

Stateless containers can be recreated safely.

Examples:

* frontend
* backend APIs
* nginx
* worker services

Workflow:

```txt
Container Deleted
↓
Container Recreated
↓
No Data Loss
```

---

## Stateful Services

Stateful containers require persistent storage.

Examples:

* PostgreSQL
* MongoDB
* Redis
* MinIO

Workflow:

```txt
Container Deleted
↓
Volume Remains
↓
Data Preserved
```

---

## Production Rule

Use volumes for:

```txt
Databases
Uploads
Persistent Data
```

Do not use volumes for:

```txt
Application Source Code
```

Production application code should come from images.

---

# Local Development vs Production Summary

## Development

```txt
Bind Mount
+
Hot Reload
+
npm run dev
```

---

## Production

```txt
Build Image
↓
Deploy Container
↓
Replace Old Container
```

This is the workflow used in modern Docker-based production environments.
# 9. Install Docker On Linux

## Supported Distributions

Recommended:

* Ubuntu LTS
* Debian

Production examples in this guide use Ubuntu.

---

## Remove Old Docker Packages

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

Removes old Docker packages if present.

---

## Update System

```bash
sudo apt update

sudo apt upgrade -y
```

---

## Install Required Packages

```bash
sudo apt install -y \
ca-certificates \
curl \
gnupg \
lsb-release
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
sudo gpg --dearmor \
-o /etc/apt/keyrings/docker.gpg
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

## Update Package Index

```bash
sudo apt update
```

---

## Install Docker Engine

```bash
sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin
```

Installs:

* Docker Engine
* Docker CLI
* Docker Compose
* Docker Buildx
* containerd

---

## Enable Docker On Boot

```bash
sudo systemctl enable docker
```

---

## Start Docker

```bash
sudo systemctl start docker
```

---

## Verify Service

```bash
sudo systemctl status docker
```

Expected:

```txt id="v5nm4l"
active (running)
```

---

## Add User To Docker Group

```bash
sudo usermod -aG docker $USER
```

Allows Docker commands without sudo.

---

## Apply Group Changes

Option 1:

```bash
exit
```

Logout and login again.

---

Option 2:

```bash
newgrp docker
```

Applies group changes immediately.

---

## Verify Docker Group

```bash
groups
```

Should contain:

```txt id="s1c4q7"
docker
```

---

# 10. Install Docker On Mac

## Recommended Method

Install Docker Desktop.

Docker Desktop includes:

* Docker Engine
* Docker Compose
* Buildx
* Docker CLI
* Docker Extensions

---

## Install Using Homebrew

```bash
brew install --cask docker
```

---

## Start Docker Desktop

Open:

```txt id="0x5k4f"
Applications
↓
Docker
```

Wait until Docker is running.

---

## Verify Docker Desktop

```bash
docker info
```

---

## Verify Docker Version

```bash
docker --version
```

---

## Verify Compose

```bash
docker compose version
```

---

# Apple Silicon (M Series Macs)

Supported:

```txt id="6l9ybd"
M1
M2
M3
M4
```

Docker Desktop automatically uses ARM64 images when available.

---

## Verify Architecture

```bash
uname -m
```

Expected:

```txt id="s36j8t"
arm64
```

---

## Recommended Images

Prefer:

```txt id="vfd6nt"
node:24-slim
nginx:alpine
postgres:17
redis:8
```

Avoid old x86-only images.

---

# Docker Desktop Settings

## Recommended Resources

For Mac Mini M4:

### Development

```txt id="iqfr1r"
CPU: 2-4

Memory: 4GB-8GB

Disk: Default
```

---

### Production-Like Testing

```txt id="m4j6u2"
CPU: 4

Memory: 8GB
```

---

## Open Settings

```txt id="4bg0yf"
Docker Desktop
↓
Settings
↓
Resources
```

---

# Docker Desktop Best Practices

## Open When Needed

Recommended workflow:

```txt id="q1g60h"
Start Docker Desktop
↓
Use Docker
↓
Stop Docker Desktop
```

---

## Close When Not Using Docker

If not working with containers:

```txt id="8i6myl"
Close Docker Desktop
```

Saves RAM and CPU resources.

---

# 11. Verify Docker Installation

## Verify Docker Version

```bash
docker --version
```

Example:

```txt id="89e1v3"
Docker version 28.x.x
```

---

## Verify Compose Version

```bash
docker compose version
```

---

## Verify Buildx

```bash
docker buildx version
```

---

## Verify Docker Info

```bash
docker info
```

Displays:

* Docker Engine
* Storage Driver
* CPU
* Memory
* Runtime Information

---

## Test Docker

```bash
docker run hello-world
```

Expected:

```txt id="c1zbhn"
Hello from Docker!
```

---

## Verify Running Containers

```bash
docker ps
```

---

## Verify Images

```bash
docker images
```

---

## Verify Networks

```bash
docker network ls
```

---

## Verify Volumes

```bash
docker volume ls
```

---

# Verify Docker Service

## Linux

```bash
sudo systemctl status docker
```

---

## Mac

```bash
docker info
```

If Docker Desktop is not running:

```txt id="ylqvrx"
Cannot connect to the Docker daemon
```

Start Docker Desktop and try again.

---

# Install Verification Checklist

```txt id="6ccrx7"
✓ Docker Installed

✓ Docker Compose Installed

✓ Docker Buildx Installed

✓ Docker Service Running

✓ Docker Group Configured

✓ hello-world Container Working

✓ Images Accessible

✓ Networks Accessible

✓ Volumes Accessible
```
# 12. Docker Images

Images are immutable templates used to create containers.

Think of an image as:

```txt
Source Code
↓
Dockerfile
↓
Docker Image
↓
Docker Container
```

---

## View Images

```bash
docker images
```

---

## Pull Image

```bash
docker pull nginx:alpine
```

Downloads image from Docker Hub.

---

## Pull Specific Version

```bash
docker pull node:24-slim
```

Recommended for production.

Avoid:

```txt
latest
```

when possible.

---

## Search Images

```bash
docker search nginx
```

---

## Remove Image

```bash
docker rmi IMAGE_ID
```

---

## Remove Multiple Images

```bash
docker rmi IMAGE1 IMAGE2 IMAGE3
```

---

## Remove Unused Images

```bash
docker image prune -a
```

---

## Inspect Image

```bash
docker inspect IMAGE_ID
```

---

## Image Tags

Example:

```txt
node:24-slim

IMAGE:TAG
```

---

## Production Best Practice

Use explicit versions.

Good:

```txt
node:24-slim
postgres:17
redis:8
nginx:alpine
```

Avoid:

```txt
node:latest
postgres:latest
```

---

# 13. Docker Containers

Containers are running instances of images.

Example:

```txt
Image
↓
Container
↓
Running Application
```

---

## Run Container

```bash
docker run nginx
```

Runs in foreground.

---

## Detached Mode

```bash
docker run -d nginx
```

Runs in background.

---

## Name Container

```bash
docker run -d \
--name nginx-server \
nginx
```

---

## List Running Containers

```bash
docker ps
```

---

## List All Containers

```bash
docker ps -a
```

---

## Stop Container

```bash
docker stop CONTAINER_ID
```

---

## Start Container

```bash
docker start CONTAINER_ID
```

---

## Restart Container

```bash
docker restart CONTAINER_ID
```

---

## Remove Container

```bash
docker rm CONTAINER_ID
```

---

## Force Remove Container

```bash
docker rm -f CONTAINER_ID
```

---

## Production Restart Policy

```bash
docker run -d \
--restart unless-stopped \
nginx
```

Recommended for production.

---

# 14. Docker Volumes

Volumes provide persistent storage.

Used for:

* PostgreSQL
* MongoDB
* Redis
* uploads
* user data

---

## Why Volumes Matter

Without volumes:

```txt
Container Deleted
↓
Data Lost
```

With volumes:

```txt
Container Deleted
↓
Volume Remains
↓
Data Preserved
```

---

## Create Volume

```bash
docker volume create postgres-data
```

---

## List Volumes

```bash
docker volume ls
```

---

## Inspect Volume

```bash
docker volume inspect postgres-data
```

---

## Remove Volume

```bash
docker volume rm postgres-data
```

---

## PostgreSQL Example

```bash
docker run -d \
--name postgres \
-v postgres-data:/var/lib/postgresql/data \
postgres:17
```

---

## MongoDB Example

```bash
docker run -d \
--name mongo \
-v mongo-data:/data/db \
mongo
```

---

## Production Rule

Use volumes for:

```txt
Database Data
User Uploads
Persistent Storage
```

---

## Do Not Use Volumes For

```txt
Application Source Code
```

Production code should come from images.

---

# 15. Bind Mounts

Bind mounts connect local folders directly to containers.

Best used during development.

---

## Bind Mount Example

```bash
-v $(PWD):/app
```

Meaning:

```txt
Local Project
↓
Container /app
```

---

## Development Workflow

```txt
Code Change
↓
Save File
↓
Container Sees Change
↓
Hot Reload
```

---

## Node.js Development Example

```bash
docker run --rm -it \
-v $(PWD):/app \
-w /app \
node:24-slim \
sh
```

---

## Benefits

* hot reload
* fast development
* no rebuild required
* easier debugging

---

## Production Rule

Development:

```txt
Bind Mount
✓
```

Production:

```txt
Bind Mount
✗
```

---

## Production Alternative

```txt
Source Code
↓
Build Image
↓
Deploy Container
```

---

# Named Volume vs Bind Mount

## Named Volume

Managed by Docker.

```txt
Docker
↓
Volume
↓
Container
```

Example:

```bash
-v postgres-data:/var/lib/postgresql/data
```

---

## Bind Mount

Managed by host system.

```txt
Host Folder
↓
Container
```

Example:

```bash
-v $(PWD):/app
```

---

## Best Practice

Development:

```txt
Bind Mount
```

Production:

```txt
Named Volume
```

---

# 16. Docker Networks

Networks allow containers to communicate.

Example:

```txt
Frontend
↓
Backend
↓
Database
```

---

## List Networks

```bash
docker network ls
```

---

## Create Network

```bash
docker network create app-network
```

---

## Inspect Network

```bash
docker network inspect app-network
```

---

## Remove Network

```bash
docker network rm app-network
```

---

# Custom Bridge Network

Recommended for production.

Create:

```bash
docker network create app-network
```

Run containers:

```bash
docker run -d \
--network app-network \
--name backend \
backend-image
```

---

```bash
docker run -d \
--network app-network \
--name frontend \
frontend-image
```

---

# Service Communication

Containers can communicate using names.

Example:

```txt
frontend
↓
backend:5000
```

---

```txt
backend
↓
postgres:5432
```

---

## Docker Compose Network

Compose automatically creates a network.

Example:

```yaml
services:
  frontend:
    image: frontend

  backend:
    image: backend
```

Communication:

```txt
frontend
↓
backend
```

No IP addresses required.

---

# Network Types

## Bridge

Default network.

Most common.

Recommended.

---

## Host

Container uses host network directly.

Rarely needed.

---

## None

No networking.

Used for isolated workloads.

---

# Production Networking Rules

Use:

```txt
Custom Bridge Networks
Service Names
Internal Communication
```

Avoid:

```txt
Hardcoded IP Addresses
```

Expose publicly only:

```txt
80
443
```

Keep:

```txt
3000
5000
5432
6379
27017
```

internal whenever possible.

---

# Images Containers Volumes Networks Summary

```txt
Dockerfile
↓
Image
↓
Container
↓
Network
↓
Volume
```

Production Flow:

```txt
Image
↓
Container
↓
Network
↓
Volume
↓
Application
```
# 17. Dockerfile

A Dockerfile is a set of instructions used to build Docker images.

Workflow:

```txt
Source Code
↓
Dockerfile
↓
Docker Image
↓
Docker Container
```

---

## Create Dockerfile

```bash
nano Dockerfile
```

---

## Basic Node.js Dockerfile

```dockerfile
FROM node:24-slim

WORKDIR /app

ENV NODE_ENV=development

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

---

## Dockerfile Instructions

### FROM

Defines base image.

```dockerfile
FROM node:24-slim
```

---

### WORKDIR

Sets working directory.

```dockerfile
WORKDIR /app
```

---

### COPY

Copies files.

```dockerfile
COPY . .
```

---

### RUN

Executes commands during build.

```dockerfile
RUN npm install
```

---

### EXPOSE

Documents container port.

```dockerfile
EXPOSE 3000
```

---

### CMD

Default startup command.

```dockerfile
CMD ["npm", "run", "start"]
```

---

# 18. Docker Ignore

## Why Use .dockerignore?

Prevents unnecessary files from entering images.

Benefits:

* smaller images
* faster builds
* better security
* less build context

---

## Create File

```bash
nano .dockerignore
```

---

## Node.js Example

```txt
node_modules

.next

dist

coverage

.git

.github

.env

.env.*

Dockerfile

README.md
```

---

## Production Rule

Always ignore:

```txt
.env
.git
node_modules
```

Never send secrets into images.

---

# 19. Build Docker Images

## Build Image

```bash
docker build -t myapp .
```

Meaning:

```txt
Image Name:
myapp

Build Context:
Current Directory
```

---

## Tagged Build

```bash
docker build -t myapp:1.0.0 .
```

---

## Latest Tag

```bash
docker build -t myapp:latest .
```

---

## Verify Images

```bash
docker images
```

---

## Build Without Cache

```bash
docker build --no-cache -t myapp .
```

Useful when debugging builds.

---

## Build Specific Dockerfile

```bash
docker build \
-f Dockerfile.prod \
-t myapp .
```

---

# Multi-Stage Builds

Multi-stage builds create smaller production images.

Recommended for production.

---

## Why Use Multi-Stage Builds?

Benefits:

* smaller images
* faster deployments
* reduced attack surface
* cleaner builds

---

## Traditional Build

```txt
Build Tools
+
Source Code
+
Dependencies
↓
Final Image
```

Large image.

---

## Multi-Stage Build

```txt
Build Stage
↓
Compiled Output
↓
Production Stage
```

Smaller image.

---

# Production Node.js Dockerfile (Best Practices)

## Multi-Stage Example

```dockerfile
# Build Stage
FROM node:24-slim AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

# Production Stage
FROM node:24-slim

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./

RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist

USER node

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

Recommended production pattern with multi-stage build and non-root user.

---

# Development Dockerfile

Development focuses on hot reload.

Example:

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

# Development vs Production Dockerfile

## Development

```txt
npm install
npm run dev
Bind Mount
Hot Reload
```

---

## Production

```txt
npm ci
Build App
Immutable Image
No Bind Mount
```

---

# Build Optimization

## Copy Package Files First

Good:

```dockerfile
COPY package*.json ./

RUN npm ci

COPY . .
```

---

Why?

Docker cache reuse.

Faster builds.

---

## Use npm ci

Production:

```dockerfile
RUN npm ci
```

Preferred over:

```dockerfile
RUN npm install
```

Benefits:

* reproducible installs
* faster builds
* lockfile consistency

---

# Image Size Optimization

Use:

```txt
node:24-slim
```

Instead of:

```txt
node:24
```

---

Use:

```txt
nginx:alpine
```

Instead of:

```txt
nginx
```

---

Benefits:

* smaller images
* faster pulls
* less storage
* faster deployments

---

# Build Workflow

## Development

```txt
Code Change
↓
Save
↓
Hot Reload
```

No rebuild required.

---

## Production

```txt
Code Change
↓
Build Image
↓
Deploy Container
↓
Replace Old Container
```

---

# Dockerfile Best Practices

Always:

```txt
✓ Use Explicit Versions

✓ Use .dockerignore

✓ Use npm ci

✓ Use Multi-Stage Builds

✓ Use Small Base Images

✓ Keep Images Immutable

✓ Separate Dev And Prod Workflows
```

Avoid:

```txt
✗ latest Tags

✗ Secrets In Images

✗ .env Inside Images

✗ Editing Containers Manually

✗ Huge Base Images

✗ Using Development Dockerfiles In Production
```
# 20. Docker Compose

Docker Compose is used to manage multiple containers as a single application stack.

Common services:

* frontend
* backend
* database
* redis
* nginx

---

## Why Use Docker Compose?

Without Compose:

```txt id="gph73z"
docker run ...
docker run ...
docker run ...
docker run ...
```

Many commands.

Hard to manage.

---

With Compose:

```txt id="h3vv4x"
docker compose up -d
```

Entire stack starts.

---

# Create Compose File

## Create File

```bash id="c2tkp6"
nano docker-compose.yml
```

---

## Minimal Example

```yaml id="4sz8d9"
services:
  app:
    image: nginx

    ports:
      - "3000:80"
```

---

# 21. Docker Compose Commands

## Start Stack

```bash id="quzl5f"
docker compose up -d
```

---

## Stop Stack

```bash id="y9cnix"
docker compose down
```

---

## Restart Stack

```bash id="z5rr4j"
docker compose restart
```

---

## View Containers

```bash id="g50v7k"
docker compose ps
```

---

## View Logs

```bash id="h16lb6"
docker compose logs
```

---

## Follow Logs

```bash id="tvh0v8"
docker compose logs -f
```

---

## Rebuild Images

```bash id="kvtjhl"
docker compose build
```

---

## Build Without Cache

```bash id="hspg8n"
docker compose build --no-cache
```

---

## Pull New Images

```bash id="p5wqhp"
docker compose pull
```

---

## Recreate Containers

```bash id="sv6b5m"
docker compose up -d --force-recreate
```

---

# 22. Production Docker Compose Structure

## Recommended Project Structure

```txt id="18v6x4"
project/
├── docker-compose.yml
├── .env
├── frontend/
├── backend/
├── nginx/
└── database/
```

---

## Production Architecture

```txt id="qod1od"
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
Database
↓
Redis
```

---

## Recommended Services

```txt id="k8rjmd"
frontend
backend
postgres
redis
nginx
```

---

# Environment Variables

## Create .env

```bash id="4m6h2j"
nano .env
```

---

## Example

```env id="f8rj53"
NODE_ENV=production

PORT=3000

DATABASE_URL=postgres://user:pass@postgres:5432/app

REDIS_URL=redis://redis:6379
```

---

## Load Environment Variables

```yaml id="sk7z8e"
services:
  backend:
    env_file:
      - .env
```

---

## Production Rules

Never commit:

```txt id="k1zkz6"
.env
.env.production
.env.local
```

---

## Git Ignore

```gitignore id="r6g5q7"
.env
.env.*
```

---

# 23. Health Checks

Health checks allow Docker to determine whether a service is healthy.

Recommended for production.

---

## Backend Health Check

```yaml id="vbbm4k"
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s
```

---

## PostgreSQL Health Check

```yaml id="u4p2z5"
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 30s
  timeout: 10s
  retries: 5
```

---

## Redis Health Check

```yaml id="9llj67"
healthcheck:
  test: ["CMD", "redis-cli", "ping"]
  interval: 30s
  timeout: 10s
  retries: 5
```

---

# Production Compose Example

## Frontend + Backend + PostgreSQL + Redis

```yaml id="p5zkal"
services:

  frontend:
    build: ./frontend

    restart: unless-stopped

    expose:
      - "3000"

  backend:
    build: ./backend

    restart: unless-stopped

    expose:
      - "5000"

    env_file:
      - .env

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:17

    restart: unless-stopped

    environment:
      POSTGRES_DB: app
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: secret

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5

    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:8

    restart: unless-stopped

    volumes:
      - redis-data:/data

    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    depends_on:
      - frontend
      - backend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  postgres-data:
  redis-data:
```

---

# Service Communication

Containers communicate using service names.

Example:

```txt id="ecm6ld"
frontend
↓
backend:5000
```

---

```txt id="z8qgo6"
backend
↓
postgres:5432
```

---

```txt id="0j8jlh"
backend
↓
redis:6379
```

---

No IP addresses required.

---

# depends_on

Controls startup order.

Example:

```yaml id="s6qnd0"
backend:
  depends_on:
    - postgres
    - redis
```

---

## Important

`depends_on`:

```txt id="eh5zvw"
Starts First
```

It does NOT guarantee:

```txt id="n3v2xg"
Database Ready
```

Use health checks for that.

---

# Restart Policies

## Recommended Production Policy

```yaml id="0n6lk2"
restart: unless-stopped
```

Automatically restarts containers.

---

## Available Policies

```txt id="b9fyz3"
no

always

unless-stopped

on-failure
```

---

## Production Recommendation

```txt id="0h3q9s"
unless-stopped
```

---

# Compose Volumes

## Persistent Database Storage

```yaml id="11ojdz"
volumes:
  - postgres-data:/var/lib/postgresql/data
```

---

## Redis Persistence

```yaml id="2fzyf4"
volumes:
  - redis-data:/data
```

---

## Production Rule

Use volumes for:

```txt id="8tbx1j"
PostgreSQL

MongoDB

Redis

User Uploads
```

---

# Development vs Production Compose

## Development

```txt id="24h9sp"
Bind Mounts

Hot Reload

npm run dev
```

---

## Production

```txt id="9fvafm"
Images

Named Volumes

Restart Policies

Health Checks
```

---

# Production Compose Best Practices

Always:

```txt id="gfvp4g"
✓ Use restart: unless-stopped

✓ Use health checks

✓ Use named volumes

✓ Use service names

✓ Use .env files

✓ Use explicit image versions

✓ Separate development and production configs
```

Avoid:

```txt id="5om4j9"
✗ Hardcoded IPs

✗ latest tags

✗ Public databases

✗ Secrets in compose files

✗ Bind mounts in production

✗ Manual container modifications
```
# 24. Development Containers

Development containers are optimized for:

* rapid development
* hot reload
* debugging
* local testing

Development containers are different from production containers.

---

## Development Goals

Focus on:

```txt id="nwxbrf"
Fast Iteration
↓
Hot Reload
↓
Instant Feedback
```

---

## Recommended Development Stack

```txt id="1fhj29"
Docker
+
Bind Mount
+
npm run dev
+
Hot Reload
```

---

## Development Workflow

```txt id="nzwmxh"
Code Change
↓
Save File
↓
Container Detects Change
↓
Application Reloads
↓
Browser Updates
```

No image rebuild required.

---

# 25. Hot Reload Workflow

Hot reload automatically reloads the application when files change.

---

## Traditional Workflow

```txt id="o2ml6h"
Edit Code
↓
Build Image
↓
Restart Container
↓
Test
```

Slow.

---

## Docker Development Workflow

```txt id="jlwmkv"
Edit Code
↓
Save File
↓
Hot Reload
↓
Test
```

Fast.

---

# Bind Mount Workflow

## Example

```bash id="7mspfw"
-v $(PWD):/app
```

---

## How It Works

```txt id="a80go3"
Local Project
↓
Mounted Into Container
↓
Files Stay Synced
```

---

## Benefits

```txt id="v0hfpz"
✓ Instant Updates

✓ No Rebuild

✓ Faster Development

✓ Easier Debugging
```

---

# Node.js Development Container

## Run Development Container

```bash id="1t5kfx"
docker run --rm -it \
--name node-dev \
-p 3000:3000 \
-v $(PWD):/app \
-w /app \
node:24-slim \
sh
```

---

## Install Dependencies

```bash id="vtx7pk"
npm install
```

---

## Start Development Server

```bash id="kymr2q"
npm run dev
```

---

## Development Workflow

```txt id="g41r11"
Local File Change
↓
Container Receives Change
↓
Node Dev Server Reloads
```

---

# Next.js Development Container

## Run Next.js Container

```bash id="2ddm0c"
docker run --rm -it \
--name nextjs-dev \
-p 3000:3000 \
-v $(PWD):/app \
-w /app \
node:24-slim \
sh
```

---

## Install Dependencies

```bash id="y8z3rw"
npm install
```

---

## Start Next.js

```bash id="a2tn9p"
npm run dev
```

---

## Access Application

```txt id="yl5q1l"
http://localhost:3000
```

---

# Docker Compose Development Example

## Project Structure

```txt id="4h8cbd"
project/
├── docker-compose.yml
├── Dockerfile
├── package.json
└── src/
```

---

## Development Compose

```yaml id="0mjl0x"
services:

  app:
    image: node:24-slim

    working_dir: /app

    command: npm run dev

    ports:
      - "3000:3000"

    volumes:
      - .:/app

    stdin_open: true

    tty: true
```

---

## Start Development Stack

```bash id="4hbd0h"
docker compose up
```

---

## Stop Development Stack

```bash id="m3n52e"
docker compose down
```

---

# Node Modules Strategy

## Common Problem

```txt id="c0hlfj"
Local node_modules
↓
Container node_modules
↓
Conflicts
```

---

## Recommended Approach

Add:

```txt id="2z84o2"
node_modules
```

to:

```txt id="s3sk6t"
.dockerignore
```

---

## Better Development Volume Setup

```yaml id="kq0l4v"
volumes:
  - .:/app
  - /app/node_modules
```

Prevents host/container dependency conflicts.

---

# Development Environment Variables

## Local Environment File

```txt id="ijzlqv"
.env.local
```

---

## Example

```env id="pt92k0"
NODE_ENV=development

PORT=3000

API_URL=http://localhost:5000
```

---

## Compose Usage

```yaml id="x5d79h"
env_file:
  - .env.local
```

---

# Docker Desktop Workflow (Mac)

## Start Docker Desktop

Open:

```txt id="y1cjlwm"
Applications
↓
Docker
```

Wait until Docker starts.

---

## Verify Docker

```bash id="fjlwm8"
docker info
```

---

## Start Development Stack

```bash id="0r8fh6"
docker compose up
```

---

## Work Normally

```txt id="2g7v87"
Edit Code
↓
Save File
↓
Hot Reload
```

---

## Stop Stack

```bash id="t0j4tm"
docker compose down
```

---

## Close Docker Desktop

If Docker is no longer needed:

```txt id="s3dxvy"
Stop Containers
↓
Close Docker Desktop
```

Saves RAM and CPU.

---

# 26. Development Best Practices

Always:

```txt id="8g2bti"
✓ Use Bind Mounts

✓ Use Hot Reload

✓ Use npm run dev

✓ Use Docker Compose

✓ Use Development Environment Files

✓ Keep Containers Temporary

✓ Use --rm For One-Off Containers
```

---

Avoid:

```txt id="o0t6js"
✗ Rebuilding Images After Every Change

✗ Production Dockerfiles For Development

✗ Manually Copying Files Into Containers

✗ Storing Secrets In Source Code

✗ Running Databases Without Volumes
```

---

# Development Workflow Summary

```txt id="rk3dx8"
Write Code
↓
Save File
↓
Bind Mount Sync
↓
Hot Reload
↓
Browser Updates
```

Recommended Development Stack:

```txt id="q5r9nn"
Docker
+
Compose
+
Bind Mounts
+
Hot Reload
+
npm run dev
```
# 27. Production Containers

Production containers are optimized for:

* stability
* reliability
* scalability
* repeatability

Production containers should be:

```txt id="h8v4rc"
Immutable
Portable
Predictable
Reproducible
```

---

## Production Philosophy

Never modify running containers.

Wrong:

```txt id="q43zpc"
SSH
↓
Container
↓
Edit Files
```

---

Correct:

```txt id="swd4ee"
Change Source Code
↓
Build New Image
↓
Deploy New Container
```

---

# 28. Production Deployment Workflow

Recommended workflow:

```txt id="q3iw3u"
Code Changes
↓
Git Commit
↓
Git Push
↓
Pull On VPS
↓
Build Images
↓
Deploy Containers
↓
Verify Health
```

---

## Typical Deployment Commands

### Pull Latest Code

```bash id="wvrdkr"
git pull origin main
```

---

### Build Images

```bash id="6fcqya"
docker compose build
```

---

### Deploy

```bash id="w7g55y"
docker compose up -d
```

---

### Verify Containers

```bash id="9mryc0"
docker ps
```

---

### Verify Logs

```bash id="ppfkfp"
docker compose logs -f
```

---

# 29. Frontend Backend Database Architecture

## Recommended Architecture

```txt id="xzwhyt"
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
PostgreSQL
↓
Redis
```

---

## Public Services

Expose publicly:

```txt id="g6d9f0"
80
443
```

Only.

---

## Internal Services

Keep private:

```txt id="0ng2cl"
3000
5000
5432
6379
27017
```

---

# Production Project Structure

## Recommended Layout

```txt id="w8d0cw"
project/
├── docker-compose.yml
├── .env
├── frontend/
├── backend/
├── nginx/
│
├── postgres/
│
└── redis/
```

---

# 30. Docker With Nginx

Nginx should be the only public entry point.

---

## Production Flow

```txt id="w99dgs"
User
↓
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
```

---

## Why Use Nginx?

Benefits:

* HTTPS
* reverse proxy
* domain routing
* security headers
* Cloudflare integration
* hide backend services

---

## Recommended Nginx Structure

```txt id="3v7ow0"
project/
├── docker-compose.yml
└── nginx/
    ├── default.conf
    └── ssl/
        ├── cert.pem
        └── key.pem
```

Never commit:

```txt
cert.pem
key.pem
.env
```

---

## Docker Compose Example

```yaml id="sblh6g"
services:

  frontend:
    build: ./frontend

    expose:
      - "3000"

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  backend:
    build: ./backend

    expose:
      - "5000"

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  nginx:
    image: nginx:alpine

    restart: unless-stopped

    depends_on:
      - frontend
      - backend

    ports:
      - "80:80"
      - "443:443"

    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## Why Use expose Instead Of ports?

Production:

Good:

```yaml id="0wodso"
expose:
  - "3000"
```

---

Bad:

```yaml id="frhm6f"
ports:
  - "3000:3000"
```

---

Reason:

```txt id="2lm4cv"
Service Internal
↓
Only Nginx Can Reach It
```

---

# 31. Docker With Cloudflare

Recommended production setup.

---

## Traffic Flow

```txt id="5ut9ao"
User
↓
Cloudflare
↓
Nginx
↓
Application
```

---

## Benefits

```txt id="lt7h1m"
HTTPS

DDoS Protection

Caching

Rate Limiting

Bot Protection

Hide Origin Server
```

---

## SSL Mode

Recommended:

```txt id="cv8nv9"
Full (Strict)
```

---

Avoid:

```txt id="a9f5lz"
Flexible
```

---

# Production Update Workflow (Legacy)

## Deploy New Version

```txt id="v6u39w"
Git Pull
↓
Build New Image
↓
Deploy New Container
↓
Remove Old Container
```

---

# 50. Deployment Commands (Legacy)

```bash id="dtx2vc"
git pull origin main
```

```bash id="fx8eez"
docker compose build
```

```bash id="0kbgj9"
docker compose up -d
```

---

# Production Rules

Always:

```txt id="6e3xct"
✓ Use Docker Compose

✓ Use Nginx

✓ Use Cloudflare

✓ Use HTTPS

✓ Use restart: unless-stopped

✓ Use Named Volumes

✓ Use Explicit Versions

✓ Use Environment Variables

✓ Keep Databases Private

✓ Use Health Checks

✓ Monitor Logs
```

---

# Production Workflow Summary

```txt id="4n6yqq"
Local Development
↓
GitHub
↓
VPS
↓
Docker Compose
↓
Nginx
↓
Cloudflare
↓
Users
```

This is the recommended production workflow for modern Docker-based applications.
# 32. Docker Hub

Docker Hub is a container image registry.

Used for:

* storing images
* sharing images
* pulling images on servers
* CI/CD deployments
* production image distribution

---

## Docker Hub Workflow

```txt id="7nzxw5"
Source Code
↓
Build Image
↓
Push To Docker Hub
↓
VPS Pulls Image
↓
Deploy Container
```

---

## Why Use Docker Hub?

Benefits:

```txt id="odm1up"
Central Image Storage

Version Control

Easy Deployments

CI/CD Integration

Multi-Server Deployments
```

---

# Create Docker Hub Account

## Sign Up

Create account:

```txt id="r9zvll"
hub.docker.com
```

---

## Verify Username

Example:

```txt id="j18h7g"
mosabbir
```

Used for image naming.

---

# Login To Docker Hub

## Login

```bash id="qkx9b4"
docker login
```

---

## Example

```txt id="z64pf2"
Username: your-username

Password: ********
```

---

## Verify Login

```bash id="q7ex5s"
docker info
```

Look for:

```txt id="z3n5nq"
Username
```

---

# Image Tagging

Before pushing an image:

```txt id="pp43kh"
Local Image
↓
Tag Image
↓
Push Image
```

---

## View Images

```bash id="4q9kqt"
docker images
```

---

## Tag Image

```bash id="h6bgx8"
docker tag myapp:latest \
your-username/myapp:latest
```

---

## Version Tag

```bash id="j2v9j0"
docker tag myapp:latest \
your-username/myapp:v1.0.0
```

---

## Recommended Tagging Strategy

Use:

```txt id="ijb84y"
v1.0.0

v1.0.1

v1.1.0

v2.0.0
```

---

Avoid:

```txt id="zz10a5"
latest only
```

---

# 33. Push Images

## Push Latest

```bash id="lknygo"
docker push your-username/myapp:latest
```

---

## Push Version

```bash id="y7d4rq"
docker push your-username/myapp:v1.0.0
```

---

## Push Multiple Tags

```bash id="k4mq5j"
docker push your-username/myapp:latest

docker push your-username/myapp:v1.0.0
```

---

# 34. Pull Images

## Pull Latest

```bash id="t2jlwm"
docker pull your-username/myapp:latest
```

---

## Pull Specific Version

```bash id="vplvkt"
docker pull your-username/myapp:v1.0.0
```

---

## Verify Images

```bash id="r1crq6"
docker images
```

---

# VPS Deployment Using Docker Hub

## Traditional Deployment

```txt id="36ggs9"
Git Pull
↓
Build Image On VPS
↓
Deploy
```

---

## Registry Deployment

```txt id="ebh8em"
Build Image Locally
↓
Push To Docker Hub
↓
Pull Image On VPS
↓
Deploy
```

---

## Pull On VPS

```bash id="1njjpk"
docker pull your-username/myapp:v1.0.0
```

---

## Run Container

```bash id="1sv5k9"
docker run -d \
--name myapp \
your-username/myapp:v1.0.0
```

---

# Docker Compose With Docker Hub

## Example

```yaml id="2mcnwr"
services:

  frontend:
    image: your-username/frontend:v1.0.0

  backend:
    image: your-username/backend:v1.0.0
```

---

## Deploy

```bash id="vmp8ht"
docker compose up -d
```

---

## Update Images

```bash id="v8ig0k"
docker compose pull
```

---

```bash id="a4uhwv"
docker compose up -d
```

---

# Private Repositories

## Private Images

Docker Hub supports:

```txt id="f5c0ii"
Public Repositories

Private Repositories
```

---

## Login On VPS

```bash id="5gyn2j"
docker login
```

Required for private repositories.

---

# Production Versioning Strategy

## Recommended

```txt id="k7b2n3"
frontend:v1.0.0

frontend:v1.0.1

frontend:v1.1.0

backend:v1.0.0

backend:v1.1.0
```

---

## Avoid

```txt id="j8jrdn"
latest
latest
latest
```

---

Reason:

```txt id="3js7cx"
Difficult Rollbacks

Difficult Debugging

Unpredictable Deployments
```

---

# Rollback Using Tags

## Deploy Previous Version

```bash id="t4w5eb"
docker pull your-username/myapp:v1.0.0
```

---

```bash id="bfx3wr"
docker compose up -d
```

---

## Rollback Workflow

```txt id="rhz88j"
Current Version
↓
Issue Found
↓
Pull Older Version
↓
Redeploy
```

---

# GitHub Actions CI/CD Workflow

## Recommended Production Flow

```txt id="s9zyji"
Code Change
↓
Git Push
↓
GitHub Actions
↓
Build Docker Image
↓
Push To Docker Hub
↓
VPS Pulls Image
↓
Deploy
```

---

## Why This Is Better

Benefits:

```txt id="ygj3iz"
Faster Deployments

Consistent Images

Version Control

Easy Rollbacks

Automated Releases
```

---

# Docker Hub Best Practices

Always:

```txt id="4gc9wu"
✓ Use Explicit Version Tags

✓ Keep Images Small

✓ Use Multi-Stage Builds

✓ Push Production Images

✓ Use Private Repositories When Needed

✓ Scan Images For Vulnerabilities

✓ Keep Old Versions For Rollbacks
```

---

Avoid:

```txt id="r4k3jv"
✗ latest Everywhere

✗ Huge Images

✗ Secrets Inside Images

✗ Manual Production Builds

✗ Deleting All Old Versions
```

---

# Docker Registry Workflow Summary

```txt id="2jkp5g"
Local Development
↓
Build Image
↓
Tag Image
↓
Push To Docker Hub
↓
Pull On VPS
↓
Deploy With Compose
↓
Nginx
↓
Cloudflare
↓
Users
```
# 35. Container Logs

Logs are the first place to check when debugging containers.

---

## View Container Logs

```bash id="v8n4wp"
docker logs CONTAINER_ID
```

Example:

```bash id="k8l52g"
docker logs backend
```

---

## Follow Logs

```bash id="a3v4yw"
docker logs -f CONTAINER_ID
```

Example:

```bash id="n6l1df"
docker logs -f backend
```

Streams logs in real-time.

---

## Last 100 Logs

```bash id="rv0q2u"
docker logs --tail 100 CONTAINER_ID
```

---

## Last 500 Logs

```bash id="s7bqma"
docker logs --tail 500 CONTAINER_ID
```

---

## Show Timestamps

```bash id="8jxyb5"
docker logs -t CONTAINER_ID
```

---

## Last 30 Minutes

```bash id="t66yd8"
docker logs --since 30m CONTAINER_ID
```

---

## Last 1 Hour

```bash id="8mp9xe"
docker logs --since 1h CONTAINER_ID
```

---

# 36. Docker Compose Logs

## View All Logs

```bash id="nksvxn"
docker compose logs
```

---

## Follow All Logs

```bash id="4mjjlwm"
docker compose logs -f
```

---

## Last 100 Logs

```bash id="fcjlwm7"
docker compose logs --tail=100
```

---

## Specific Service

```bash id="cjlwm72"
docker compose logs backend
```

---

## Follow Specific Service

```bash id="jlwm733"
docker compose logs -f backend
```

---

## Timestamps

```bash id="jlwm744"
docker compose logs -t
```

---

# 37. Docker Exec

Used to run commands inside running containers.

---

## Open Shell

Linux Alpine-based images:

```bash id="4u3p6n"
docker exec -it CONTAINER_ID sh
```

---

Debian/Ubuntu-based images:

```bash id="4axjlwm"
docker exec -it CONTAINER_ID bash
```

---

Example:

```bash id="jlwm844"
docker exec -it backend sh
```

---

## Run Single Command

```bash id="jlwm955"
docker exec backend ls
```

---

## Check Environment Variables

```bash id="jlwm066"
docker exec backend env
```

---

## Check Working Directory

```bash id="jlwm177"
docker exec backend pwd
```

---

## Check Running Processes

```bash id="jlwm288"
docker exec backend ps aux
```

---

## Test Internal Connectivity

```bash id="jlwm399"
docker exec backend ping postgres
```

---

# 38. Docker Inspect

Inspect shows low-level container information.

---

## Inspect Container

```bash id="jlwm400"
docker inspect CONTAINER_ID
```

---

## Inspect Specific Container

```bash id="jlwm511"
docker inspect backend
```

---

## Get Container IP

```bash id="jlwm622"
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' backend
```

---

## Get Restart Policy

```bash id="jlwm733"
docker inspect backend
```

Look for:

```txt id="jlwm844"
RestartPolicy
```

---

## Inspect Volume

```bash id="jlwm955"
docker volume inspect postgres-data
```

---

## Inspect Network

```bash id="jlwm066"
docker network inspect app-network
```

---

# 39. Docker Monitoring

Monitoring helps identify:

* CPU bottlenecks
* memory issues
* disk usage
* container health

---

## Container Resource Usage

```bash id="jlwm177"
docker stats
```

Shows:

```txt id="jlwm288"
CPU
Memory
Network
Disk I/O
```

---

## Specific Container

```bash id="jlwm399"
docker stats backend
```

---

## Disk Usage

```bash id="jlwm400"
docker system df
```

Shows:

```txt id="jlwm511"
Images
Containers
Volumes
Build Cache
```

---

## Detailed Disk Usage

```bash id="jlwm622"
docker system df -v
```

---

## Check Volume Usage

```bash id="jlwm733"
docker volume ls
```

---

## Check Image Size

```bash id="jlwm844"
docker images
```

---

# 40. Docker Debugging

## Check Running Containers

```bash id="jlwm955"
docker ps
```

---

## Check All Containers

```bash id="jlwm066"
docker ps -a
```

---

## Check Exit Status

```bash id="jlwm177"
docker ps -a
```

Look for:

```txt id="jlwm288"
Exited (1)

Exited (137)

Exited (143)
```

---

## Validate Compose File

```bash id="jlwm399"
docker compose config
```

---

## Check Container Health

```bash id="jlwm400"
docker ps
```

Look for:

```txt id="jlwm511"
healthy

unhealthy
```

---

## Verify Service Reachability

Example:

```bash id="jlwm622"
docker exec backend curl http://postgres:5432
```

---

## Verify Network

```bash id="jlwm733"
docker network ls
```

---

## Verify Compose Network

```bash id="jlwm844"
docker network inspect PROJECT_default
```

---

## Verify Mounted Volumes

```bash id="jlwm955"
docker inspect backend
```

Look for:

```txt id="jlwm066"
Mounts
```

---

# Common Debug Workflow

## Application Not Responding

```txt id="jlwm177"
docker ps
↓
docker logs
↓
docker exec
↓
Fix Issue
```

---

## Database Connection Failed

```txt id="jlwm288"
Check Logs
↓
Check Network
↓
Check Environment Variables
↓
Verify Database Container
```

---

## Container Keeps Restarting

Check:

```bash id="jlwm399"
docker logs CONTAINER_ID
```

Then:

```bash id="jlwm400"
docker inspect CONTAINER_ID
```

Look for:

```txt id="jlwm511"
Exit Code
```

---

## Port Not Accessible

Check:

```bash id="jlwm622"
docker ps
```

Verify:

```txt id="jlwm733"
PORTS
```

Example:

```txt id="jlwm844"
0.0.0.0:3000->3000/tcp
```

---

## Compose Service Cannot Reach Another Service

Verify:

```bash id="jlwm955"
docker network inspect PROJECT_default
```

Ensure both services exist on the same network.

---

# Production Monitoring Checklist

Always monitor:

```txt id="jlwm066"
✓ Container Health

✓ Logs

✓ CPU Usage

✓ Memory Usage

✓ Restart Count

✓ Volume Usage

✓ Image Size

✓ Network Connectivity

✓ Database Health

✓ Disk Space
```

---

# Troubleshooting Workflow Summary

```txt id="jlwm177"
Problem
↓
docker ps
↓
docker logs
↓
docker exec
↓
docker inspect
↓
docker stats
↓
Fix
```

Production debugging should always start with:

```bash id="jlwm288"
docker ps

docker logs

docker compose logs
```

before making any changes.
# 41. Docker Security Best Practices

Docker security is a production requirement, not an optional feature.

Goals:

* reduce attack surface
* protect secrets
* isolate services
* prevent privilege escalation
* improve container safety

---

# 42. Environment Variables

Environment variables are the recommended way to pass configuration into containers.

---

## Example

```env id="n2m8xw"
NODE_ENV=production

PORT=3000

DATABASE_URL=postgres://user:pass@postgres:5432/app

REDIS_URL=redis://redis:6379
```

---

## Use In Compose

```yaml id="z5w1np"
services:

  backend:

    env_file:
      - .env
```

---

## Access In Node.js

```javascript id="g4n7qe"
process.env.DATABASE_URL
```

---

## Production Rule

Store:

```txt id="k9s3tv"
Database URLs

API Keys

JWT Secrets

Redis URLs

Third-Party Credentials
```

inside environment variables.

---

## Never Commit

```txt id="x2r4dh"
.env

.env.local

.env.production
```

---

## Git Ignore

```gitignore id="v6f8pu"
.env
.env.*
```

---

# 43. Secrets Management

Secrets should never be hardcoded.

---

## Wrong

```javascript id="q7m2ka"
const apiKey = "super-secret-key";
```

---

## Correct

```javascript id="r8u3lg"
const apiKey = process.env.API_KEY;
```

---

## Wrong

```yaml id="s4z6tn"
environment:
  API_KEY: super-secret-key
```

---

## Better

```yaml id="y9j1cf"
env_file:
  - .env
```

---

# Production Secret Flow

```txt id="f3m9vq"
.env
↓
Docker Compose
↓
Container
↓
Application
```

---

# Non-Root Containers

Avoid running containers as root.

---

## Why?

Root inside containers increases risk.

Potential issues:

* privilege escalation
* container escape impact
* accidental system changes

---

## Create User

Example:

```dockerfile id="b5w2nx"
RUN useradd -m appuser
```

---

## Switch User

```dockerfile id="c7r8kp"
USER appuser
```

---

## Example

```dockerfile id="d1v4hs"
FROM node:24-slim

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN useradd -m appuser

USER appuser

CMD ["node", "dist/index.js"]
```

---

# Read-Only Mounts

Use read-only mounts whenever files should not be modified.

---

## Example

```yaml id="h8n6rt"
volumes:
  - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
```

---

## SSL Example

```yaml id="j2f9qp"
volumes:
  - ./nginx/ssl:/etc/nginx/ssl:ro
```

---

## Why?

Benefits:

```txt id="m4t7zb"
Prevents Accidental Changes

Improves Security

Reduces Risk
```

---

# Container Isolation

Containers should communicate only when necessary.

---

## Good

```txt id="r6k3dy"
Frontend
↓
Backend
```

---

```txt id="p7n5wj"
Backend
↓
Database
```

---

## Bad

```txt id="t8v2cx"
Everything
↓
Everything
```

---

# Port Exposure Rules

Only expose services that users need.

---

## Public

```txt id="u3m7kn"
80

443
```

---

## Private

```txt id="v9c4ra"
3000

5000

5432

6379

27017
```

---

## Production Example

Good:

```yaml id="w5d8lu"
expose:
  - "5000"
```

---

Bad:

```yaml id="x1r6he"
ports:
  - "5000:5000"
```

---

# Image Security

Use trusted images.

---

## Recommended

```txt id="y8n4sq"
node:24-slim

nginx:alpine

postgres:17

redis:8
```

---

## Avoid

```txt id="z7m2pb"
Unknown Images

Unmaintained Images

Random Community Images
```

---

# Keep Images Updated

## Pull Latest Security Updates

```bash id="a6r9tw"
docker compose pull
```

---

## Rebuild

```bash id="b3w7ny"
docker compose build
```

---

## Redeploy

```bash id="c8q5md"
docker compose up -d
```

---

# Image Vulnerability Scanning

## Docker Scout

```bash id="d4t8kj"
docker scout quickview
```

---

## Scan Image

```bash id="e7m3rv"
docker scout cves IMAGE_NAME
```

---

# Resource Limits

Prevent containers from consuming all resources.

---

## Compose Example

```yaml id="f1v9zp"
services:

  backend:

    mem_limit: 512m

    cpus: "1.0"
```

---

## Benefits

```txt id="g6k4wu"
Predictable Resource Usage

Better Stability

Prevents Runaway Processes
```

---

# Restart Policies

Production containers should restart automatically.

---

## Recommended

```yaml id="h3q7ny"
restart: unless-stopped
```

---

## Avoid

```txt id="i9v2dr"
No Restart Policy
```

---

# Database Security

Never expose databases publicly.

---

## Bad

```yaml id="j4m8cp"
ports:
  - "5432:5432"
```

---

## Good

```yaml id="k7r1tv"
expose:
  - "5432"
```

---

# Security Headers

Handled by Nginx.

Recommended:

```txt id="l2v6qs"
X-Frame-Options

X-Content-Type-Options

Referrer-Policy
```

---

# Backup Strategy

Always back up:

```txt id="m5k8zx"
Database Volumes

Uploads

Configuration Files

SSL Certificates
```

---

# Production Security Checklist

Always:

```txt id="n8q3hw"
✓ Use HTTPS

✓ Use Cloudflare

✓ Use Environment Variables

✓ Use Non-Root Containers

✓ Use Read-Only Mounts

✓ Use Health Checks

✓ Use Restart Policies

✓ Keep Images Updated

✓ Use Trusted Images

✓ Back Up Volumes

✓ Keep Databases Private
```

---

Avoid:

```txt id="o4m7rv"
✗ Hardcoded Secrets

✗ Root Containers

✗ Public Databases

✗ Random Images

✗ Secrets In Git

✗ Modifying Production Containers

✗ Exposing Internal Services
```

---

# Security Workflow Summary

```txt id="p9t2wx"
Cloudflare
↓
Nginx
↓
Frontend
↓
Backend
↓
Database
```

Security Layers:

```txt id="q6m8hz"
Cloudflare

HTTPS

Nginx

Docker Networks

Environment Variables

Container Isolation

Private Databases
```

These practices form the baseline security model for modern Docker-based production deployments.
# 44. Docker Cleanup

Docker accumulates:

* stopped containers
* unused images
* dangling images
* unused networks
* unused volumes
* build cache

Regular cleanup is recommended.

---

# Remove Stopped Containers

## View Containers

```bash id="f2q9mk"
docker ps -a
```

---

## Remove Specific Container

```bash id="v7n3tp"
docker rm CONTAINER_ID
```

---

## Remove All Stopped Containers

```bash id="c4r8hj"
docker container prune
```

---

# Remove Images

## View Images

```bash id="w5k2zd"
docker images
```

---

## Remove Specific Image

```bash id="m8t4qx"
docker rmi IMAGE_ID
```

---

## Remove Unused Images

```bash id="g1n7cw"
docker image prune -a
```

---

# Remove Volumes

## View Volumes

```bash id="p3v6ry"
docker volume ls
```

---

## Remove Specific Volume

```bash id="h9q2mb"
docker volume rm VOLUME_NAME
```

---

## Remove Unused Volumes

```bash id="k4z8tj"
docker volume prune
```

---

# Remove Networks

## View Networks

```bash id="d7m5qx"
docker network ls
```

---

## Remove Specific Network

```bash id="x2n8fw"
docker network rm NETWORK_NAME
```

---

## Remove Unused Networks

```bash id="b6t4zc"
docker network prune
```

---

# Remove Build Cache

## View Builder Cache

```bash id="q8m3hr"
docker builder prune
```

---

## Remove All Build Cache

```bash id="s5v9kt"
docker builder prune -a
```

---

# Docker System Cleanup

## Remove Everything Unused

```bash id="r2k6mw"
docker system prune -a
```

Removes:

```txt id="a4v8jq"
Unused Containers

Unused Images

Unused Networks

Build Cache
```

---

## Remove Everything Including Volumes

```bash id="n7m4tx"
docker system prune -a --volumes
```

Removes:

```txt id="j3w8rp"
Unused Containers

Unused Images

Unused Networks

Unused Volumes

Build Cache
```

---

# Docker Disk Usage

## Check Usage

```bash id="u6q2mh"
docker system df
```

---

## Detailed Usage

```bash id="z5n8kr"
docker system df -v
```

---

# 45. Uninstall Docker On Linux

## Stop Docker

```bash id="p8m4qt"
sudo systemctl stop docker
```

---

## Disable Docker

```bash id="v2k7mw"
sudo systemctl disable docker
```

---

## Remove Docker Packages

Ubuntu / Debian:

```bash id="x9n3qt"
sudo apt purge -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin
```

---

## Remove Dependencies

```bash id="m6v8rp"
sudo apt autoremove -y
```

---

## Remove Package Cache

```bash id="k2w5mh"
sudo apt autoclean
```

---

# Remove Docker Data (Linux)

## Remove Docker Storage

```bash id="q7m2xt"
sudo rm -rf /var/lib/docker
```

---

## Remove Containerd Storage

```bash id="f3v8kr"
sudo rm -rf /var/lib/containerd
```

---

## Remove Docker Config

```bash id="r5m9qw"
sudo rm -rf /etc/docker
```

---

## Remove Docker Runtime Files

```bash id="w8n4tx"
sudo rm -rf /run/docker
```

---

## Remove User Docker Config

```bash id="b4q7mk"
rm -rf ~/.docker
```

---

# Verify Docker Removal (Linux)

## Verify Binary

```bash id="t9m2qx"
which docker
```

Expected:

```txt id="c7v4kr"
No output
```

---

## Verify Service

```bash id="j3n8qt"
systemctl status docker
```

Expected:

```txt id="g6m2rw"
Unit docker.service could not be found
```

---

# 46. Uninstall Docker On Mac

## Quit Docker Desktop

```txt id="m5q8tx"
Docker Desktop
↓
Quit Docker Desktop
```

---

## Stop Running Containers

```bash id="x4v7kr"
docker ps
```

---

```bash id="q8m2tx"
docker stop $(docker ps -aq)
```

---

# 47. Remove Docker Desktop

## Homebrew Install

```bash id="k5v9qw"
brew uninstall --cask docker
```

---

## Verify Removal

```bash id="p7m4kr"
which docker
```

---

# Remove Docker Desktop Leftovers (Mac)

## Remove Docker Configuration

```bash id="n2v8qt"
rm -rf ~/.docker
```

---

## Remove Docker Desktop Data

```bash id="b8m3qw"
rm -rf ~/Library/Containers/com.docker.docker
```

---

## Remove Docker Support Files

```bash id="r4v7tx"
rm -rf ~/Library/Application\ Support/Docker*
```

---

## Remove Docker Group Containers

```bash id="y6m2kr"
rm -rf ~/Library/Group\ Containers/group.com.docker
```

---

## Remove Docker Logs

```bash id="c3v8qw"
rm -rf ~/Library/Logs/Docker*
```

---

## Remove Docker Preferences

```bash id="w7m4tx"
rm -rf ~/Library/Preferences/com.docker.docker.plist
```

---

## Remove Docker Cache

```bash id="k8v2qr"
rm -rf ~/Library/Caches/com.docker.docker
```

---

# Full Docker Desktop Cleanup (Mac)

## Remove Everything

```bash id="m9q5tx"
rm -rf ~/.docker

rm -rf ~/Library/Containers/com.docker.docker

rm -rf ~/Library/Application\ Support/Docker*

rm -rf ~/Library/Group\ Containers/group.com.docker

rm -rf ~/Library/Logs/Docker*

rm -rf ~/Library/Caches/com.docker.docker

rm -rf ~/Library/Preferences/com.docker.docker.plist
```

---

# Verify Removal (Mac)

## Check Binary

```bash id="v4m8kr"
which docker
```

---

## Check Docker Context

```bash id="r2q7tx"
docker context ls
```

Should fail if Docker is fully removed.

---

# 48. Full Cleanup Verification

## Containers

```bash id="t5m2qw"
docker ps -a
```

Should show:

```txt id="n8v4kr"
No containers
```

---

## Images

```bash id="m3q7tx"
docker images
```

Should show:

```txt id="p6v8qw"
No images
```

---

## Volumes

```bash id="x5m2kr"
docker volume ls
```

Should show:

```txt id="c8q4tx"
No volumes
```

---

## Networks

```bash id="w2v7qr"
docker network ls
```

Only default networks should remain.

---

## Disk Usage

```bash id="r8m4tx"
docker system df
```

Should be near zero.

---

# Cleanup Checklist

```txt id="y3q8kr"
✓ Containers Removed

✓ Images Removed

✓ Volumes Removed

✓ Networks Removed

✓ Build Cache Removed

✓ Docker Desktop Removed

✓ Linux Docker Removed

✓ Containerd Removed

✓ User Config Removed

✓ Docker Logs Removed

✓ Docker Cache Removed

✓ Leftover Files Removed
```
# 49. VPS Docker Workflow

This is the recommended production workflow.

Architecture:

```txt id="h1w8zr"
Mac
↓
GitHub
↓
VPS
↓
Docker Compose
↓
Nginx
↓
Cloudflare
↓
Users
```

---

# Development Workflow

## Local Development

```txt id="e3k7vx"
Code
↓
Docker Compose
↓
Test
↓
Commit
```

---

## Push To GitHub

```bash id="m9w2qt"
git add .

git commit -m "update"

git push origin main
```

---

# VPS Deployment Workflow

## Connect To VPS

```bash id="n4k8rx"
ssh user@SERVER_IP
```

---

## Enter Project

```bash id="v7q3mw"
cd project
```

---

## Pull Latest Code

```bash id="x2m9kr"
git pull origin main
```

---

## Build Images

```bash id="p6w4tx"
docker compose build
```

---

## Deploy Containers

```bash id="j8q2mv"
docker compose up -d
```

---

## Verify Containers

```bash id="r5m7kw"
docker ps
```

---

## Verify Logs

```bash id="t3q9vx"
docker compose logs -f
```

---

# Production Update Workflow (Legacy)

## Standard Deployment

```txt id="c7m4qr"
Code Change
↓
Git Push
↓
SSH VPS
↓
Git Pull
↓
Build
↓
Deploy
```

---

## Commands

```bash id="y8v2kw"
git pull origin main

docker compose build

docker compose up -d
```

---

# Image-Based Deployment Workflow

Useful when using Docker Hub.

---

## Local Machine

Build:

```bash id="m2q7vx"
docker build -t myapp:v1.0.0 .
```

---

Tag:

```bash id="k4w9zr"
docker tag myapp:v1.0.0 username/myapp:v1.0.0
```

---

Push:

```bash id="n7m3qt"
docker push username/myapp:v1.0.0
```

---

## VPS

Pull:

```bash id="x5v8kw"
docker pull username/myapp:v1.0.0
```

---

Deploy:

```bash id="r2q4vx"
docker compose up -d
```

---

# 51. Rollback Workflow

Rollbacks should be simple.

---

## Current Version

```txt id="j9w3kr"
v1.0.2
```

---

## Previous Version

```txt id="m6q8vx"
v1.0.1
```

---

## Rollback

Update image tag:

```yaml id="p4v7kw"
image: username/myapp:v1.0.1
```

---

Deploy:

```bash id="y2m9zr"
docker compose up -d
```

---

## Rollback Flow

```txt id="n8q4vx"
New Version
↓
Issue Found
↓
Previous Version
↓
Deploy
```

---

# 52. Docker Service Commands

## Start Docker

Linux:

```bash id="r7v2kw"
sudo systemctl start docker
```

---

## Stop Docker

Linux:

```bash id="k3m8vx"
sudo systemctl stop docker
```

---

## Restart Docker

Linux:

```bash id="p9q4zr"
sudo systemctl restart docker
```

---

## Status

Linux:

```bash id="x6v7kw"
sudo systemctl status docker
```

---

## Enable On Boot

```bash id="m4q8vx"
sudo systemctl enable docker
```

---

## Disable On Boot

```bash id="n2v9zr"
sudo systemctl disable docker
```

---

# 53. Docker Quick Commands Cheat Sheet

## Containers

Running:

```bash id="t8q4kw"
docker ps
```

---

All:

```bash id="w3m7vx"
docker ps -a
```

---

Stop:

```bash id="y6q2zr"
docker stop CONTAINER_ID
```

---

Start:

```bash id="k8v4kw"
docker start CONTAINER_ID
```

---

Restart:

```bash id="m5q7vx"
docker restart CONTAINER_ID
```

---

Remove:

```bash id="n9v2zr"
docker rm CONTAINER_ID
```

---

# Images

List:

```bash id="r4q8kw"
docker images
```

---

Pull:

```bash id="x7m3vx"
docker pull IMAGE
```

---

Build:

```bash id="t2q9zr"
docker build -t IMAGE .
```

---

Remove:

```bash id="p8v4kw"
docker rmi IMAGE_ID
```

---

# Volumes

List:

```bash id="m3q7zr"
docker volume ls
```

---

Inspect:

```bash id="w8v2kw"
docker volume inspect VOLUME_NAME
```

---

Remove:

```bash id="k5m9vx"
docker volume rm VOLUME_NAME
```

---

# Networks

List:

```bash id="r9q4zr"
docker network ls
```

---

Inspect:

```bash id="y4v8kw"
docker network inspect NETWORK_NAME
```

---

# Logs

Container:

```bash id="m7q2vx"
docker logs -f CONTAINER_ID
```

---

Compose:

```bash id="p4v9zr"
docker compose logs -f
```

---

# Exec

Shell:

```bash id="w2q8kw"
docker exec -it CONTAINER_ID sh
```

---

Command:

```bash id="x8m4vx"
docker exec CONTAINER_ID ls
```

---

# Compose

Start:

```bash id="n5q7zr"
docker compose up -d
```

---

Stop:

```bash id="k2v9kw"
docker compose down
```

---

Restart:

```bash id="m8q4vx"
docker compose restart
```

---

Build:

```bash id="r3v7zr"
docker compose build
```

---

# 54. Common Docker Issues

## Cannot Connect To Docker Daemon

Error:

```txt id="c2m8kw"
Cannot connect to the Docker daemon
```

---

Linux Fix:

```bash id="p7q4vx"
sudo systemctl start docker
```

---

Mac Fix:

```txt id="w4v9zr"
Start Docker Desktop
```

---

## Permission Denied

Fix:

```bash id="k9q2kw"
sudo usermod -aG docker $USER
```

---

Apply:

```bash id="m4v8vx"
newgrp docker
```

---

## Port Already In Use

Check:

```bash id="r8q3zr"
sudo ss -tulpn
```

---

Mac:

```bash id="y5v7kw"
lsof -i :3000
```

---

## Container Restart Loop

Check:

```bash id="p2q9vx"
docker logs CONTAINER_ID
```

---

Inspect:

```bash id="w7v4zr"
docker inspect CONTAINER_ID
```

---

## Build Failed

Rebuild:

```bash id="k4q8kw"
docker build --no-cache -t IMAGE .
```

---

## Compose Issues

Validate:

```bash id="m9v3vx"
docker compose config
```

---

## No Disk Space

Check:

```bash id="r5q7zr"
docker system df
```

---

Cleanup:

```bash id="x2v8kw"
docker system prune -a --volumes
```

---

# 55. Real World Docker Learning Path

```txt id="n6q4vx"
Docker Basics
↓
Images
↓
Containers
↓
Volumes
↓
Networks
↓
Dockerfile
↓
Docker Compose
↓
Development Workflow
↓
Production Workflow
↓
Nginx Reverse Proxy
↓
Cloudflare
↓
Docker Hub
↓
CI/CD
↓
Monitoring
↓
Kubernetes
```

---

# Final Production Workflow

```txt id="z8v2zr"
Mac Mini
↓
Docker Development
↓
GitHub
↓
VPS
↓
Docker Compose
↓
Nginx
↓
Cloudflare
↓
Users
```

This is the recommended modern Docker workflow for personal projects, SaaS applications, client projects, and production deployments.
