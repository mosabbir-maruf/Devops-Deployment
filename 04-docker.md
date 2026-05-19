# Docker

## What Is Docker?

Docker is a container platform used to package and run applications in isolated environments called containers.

Benefits:

- Easy deployment
- Consistent environments
- Lightweight virtualization
- Fast setup
- Portable applications
- Production-ready workflows
- Simplified application management

---

# Docker Concepts

## Container

A lightweight isolated environment used to run applications.

---

## Image

A reusable template used to create containers.

---

## Volume

Persistent storage for Docker containers.

---

## Network

Allows communication between containers/services.

---

# Install Docker

## Remove Old Docker Packages

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

Removes old/outdated Docker packages if they exist.

---

## Update Packages

```bash
sudo apt update
```

Refreshes Ubuntu package lists.

---

## Install Required Packages

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

Installs required dependencies for Docker repository setup.

---

## Create Docker GPG Directory

```bash
sudo mkdir -p /etc/apt/keyrings
```

Creates Docker key storage directory.

---

## Add Docker GPG Key

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Adds official Docker security key.

---

## Add Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Adds official Docker repository.

---

## Update Packages Again

```bash
sudo apt update
```

Refreshes package lists including Docker repository.

---

## Install Docker Engine

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Installs:

- Docker Engine
- Docker CLI
- containerd
- Docker Buildx
- Docker Compose plugin

---

## Enable Docker On Boot

```bash
sudo systemctl enable docker
```

Starts Docker automatically on server boot.

---

## Start Docker Service

```bash
sudo systemctl start docker
```

Starts Docker service.

---

## Check Docker Service

```bash
sudo systemctl status docker
```

Checks whether Docker is running correctly.

Should show:

```txt
active (running)
```

---

## Add User To Docker Group

```bash
sudo usermod -aG docker $USER
```

Allows running Docker commands without sudo.

---

## Restart Session

```bash
exit
```

Logout after Docker group changes.

Login again after exiting.

---

# Verify Docker Installation

## Check Docker Version

```bash
docker --version
```

Displays installed Docker version.

---

## Check Docker Compose Version

```bash
docker compose version
```

Displays Docker Compose version.

---

## Test Docker Installation

```bash
docker run hello-world
```

Tests whether Docker is working correctly.

Should display:

```txt
Hello from Docker!
```

---

# Basic Docker Commands

## Check Running Containers

```bash
docker ps
```

Shows running containers.

---

## Check All Containers

```bash
docker ps -a
```

Shows all containers.

---

## Check Docker Images

```bash
docker images
```

Displays downloaded Docker images.

---

## Check Docker Volumes

```bash
docker volume ls
```

Displays Docker volumes.

---

## Check Docker Networks

```bash
docker network ls
```

Displays Docker networks.

---

# Docker Images

## Pull Docker Image

```bash
docker pull nginx
```

Downloads Docker image from Docker Hub.

---

## Build Docker Image

```bash
docker build -t myapp .
```

Builds Docker image from Dockerfile.

---

## Remove Docker Image

```bash
docker rmi IMAGE_ID
```

Deletes Docker image.

---

# Docker Containers

## Run Container

```bash
docker run nginx
```

Runs a container.

---

## Run Container In Background

```bash
docker run -d --name nginx-server --restart unless-stopped nginx
```

Runs container in detached mode with automatic restart policy.

---

## Run Container With Name

```bash
docker run -d --name myapp nginx
```

Runs container with custom name.

---

## Run Container With Port Mapping

```bash
docker run -d --name myapp -p 3000:3000 --restart unless-stopped nginx
```

Maps VPS port to container port.

Format:

```txt
HOST_PORT:CONTAINER_PORT
```

---

## Run Container With Volume

```bash
docker run -d -v myvolume:/app/data nginx
```

Mounts persistent Docker volume.

---

## Stop Container

```bash
docker stop CONTAINER_ID
```

Stops a running container.

---

## Start Container

```bash
docker start CONTAINER_ID
```

Starts a stopped container.

---

## Restart Container

```bash
docker restart CONTAINER_ID
```

Restarts a container.

---

## Remove Container

```bash
docker rm CONTAINER_ID
```

Deletes a container.

---

## Force Remove Container

```bash
docker rm -f CONTAINER_ID
```

Force removes container.

---

# Docker Restart Policies

## Restart Container Automatically

```bash
docker run -d --restart unless-stopped nginx
```

Automatically restarts containers:

- after VPS reboot
- after Docker restart
- after unexpected crashes

Recommended for production containers.

---

## Restart Policy Types

```txt
no
→ No automatic restart

always
→ Always restart container

unless-stopped
→ Restart unless manually stopped

on-failure
→ Restart only if container exits with errors
```

---

# Docker Logs

## Show Logs

```bash
docker logs CONTAINER_ID
```

Displays container logs.

---

## Live Logs

```bash
docker logs -f CONTAINER_ID
```

Streams live container logs.

---

## Show Last Logs

```bash
docker logs --tail 100 CONTAINER_ID
```

Displays last 100 log lines.

---

# Execute Commands Inside Container

## Open Container Shell

```bash
docker exec -it CONTAINER_ID bash
```

Opens interactive bash shell inside container.

---

## Run Command Inside Container

```bash
docker exec CONTAINER_ID ls
```

Runs command inside container.

---

# Docker Compose

## Check Docker Compose Version

```bash
docker compose version
```

Displays Docker Compose version.

---

## Start Docker Compose

```bash
docker compose up -d
```

Starts services in background.

---

## Stop Docker Compose

```bash
docker compose down
```

Stops Docker Compose services.

---

## Restart Docker Compose

```bash
docker compose restart
```

Restarts Docker Compose services.

---

## View Docker Compose Logs

```bash
docker compose logs
```

Displays Docker Compose logs.

---

## Live Docker Compose Logs

```bash
docker compose logs -f
```

Streams Docker Compose logs live.

---

# Docker Volumes

## Create Volume

```bash
docker volume create myvolume
```

Creates Docker volume.

---

## Inspect Volume

```bash
docker volume inspect myvolume
```

Displays Docker volume details.

---

# Docker Networks

## Create Network

```bash
docker network create mynetwork
```

Creates Docker network.

---

## Inspect Network

```bash
docker network inspect mynetwork
```

Displays Docker network details.

---

# Docker Security

## Check Open Ports

```bash
docker port CONTAINER_ID
```

Displays exposed container ports.

---

## Inspect Container Details

```bash
docker inspect CONTAINER_ID
```

Shows detailed container configuration and security information.

---

## Check Container Resource Usage

```bash
docker stats
```

Displays live CPU, RAM and network usage.

---

## Check Docker Service Logs

```bash
journalctl -u docker
```

Displays Docker service logs.

---

## Scan Image Vulnerabilities

```bash
docker scout quickview IMAGE_NAME
```

Checks Docker image vulnerabilities.

Requires Docker Scout support.

---

# Useful Docker Service Commands

## Restart Docker Service

```bash
sudo systemctl restart docker
```

Restarts Docker service.

---

## Stop Docker Service

```bash
sudo systemctl stop docker
```

Stops Docker service.

---

## View Docker Service Logs

```bash
journalctl -u docker -f
```

Streams live Docker service logs.

---

# Docker Cleanup

## Remove Stopped Containers

```bash
docker container prune
```

Deletes unused containers.

---

## Remove Unused Images

```bash
docker image prune -a
```

Deletes unused Docker images.

---

## Remove Unused Volumes

```bash
docker volume prune
```

Deletes unused Docker volumes.

---

## Remove Unused Networks

```bash
docker network prune
```

Deletes unused Docker networks.

---

## Remove Everything Unused

```bash
docker system prune -a
```

Deletes unused Docker resources.

---

# Docker Monitoring

## Check Resource Usage

```bash
docker stats
```

Displays live container resource usage.

---

## Check Disk Usage

```bash
docker system df
```

Displays Docker disk usage.

---

# Dockerfile Example

## Basic Dockerfile

```dockerfile
FROM node:20

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
```

Basic Node.js Dockerfile example.

---

# Example Docker Compose File

## docker-compose.yml

```yaml
services:
  app:
    image: nginx
    ports:
      - "3000:80"
```

Basic Docker Compose example.

---

# Docker Security Best Practices

- Avoid exposing unnecessary ports
- Do not expose databases publicly
- Use official Docker images
- Keep Docker updated
- Remove unused containers/images
- Avoid running containers as root
- Use environment variables for secrets
- Use strong passwords for databases/services
- Monitor container resource usage
- Use persistent volumes for important data
- Backup Docker volumes regularly
- Use restart policies for production containers

---

# Common Docker Issues

## Port Already In Use

Possible reason:

- another service/container already using port

Check ports:

```bash
sudo ss -tulpn
```

---

## Container Keeps Restarting

Check logs:

```bash
docker logs CONTAINER_ID
```

---

## Docker Permission Denied

Fix:

```bash
sudo usermod -aG docker $USER
```

Then logout/login again.

---

# Useful Docker Workflow

1. Install Docker
2. Verify Docker installation
3. Pull/build image
4. Create Docker volume
5. Run container
6. Map ports
7. Check logs
8. Monitor resources
9. Configure backups
10. Clean unused resources
11. Use restart policies
12. Monitor Docker service