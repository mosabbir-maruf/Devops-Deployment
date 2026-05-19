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

# 1. Install Docker

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

# 2. Verify Docker Installation

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

# 3. Basic Docker Commands

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

# 4. Docker Images

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

Builds Docker image from a Dockerfile inside the current directory.

Requires a valid:

```txt
Dockerfile
```

inside the current folder.

---

## Remove Docker Image

```bash
docker rmi IMAGE_ID
```

Deletes Docker image.

---

# 5. Dockerfile Example

## Create Project Folder

```bash
mkdir myapp
```

Creates project folder.

---

## Enter Project Folder

```bash
cd myapp
```

Moves into the project directory.

---

## Create Dockerfile

```bash
nano Dockerfile
```

Creates Dockerfile.

---

## Basic Dockerfile

```dockerfile
FROM nginx
```

Basic Nginx Dockerfile example.

---

## Save Dockerfile

```txt
Ctrl + O
Enter
Ctrl + X
```

Saves Dockerfile.

---

## Build Docker Image

```bash
docker build -t myapp .
```

Builds custom Docker image named:

```txt
myapp
```

---

## Verify Docker Images

```bash
docker images
```

Displays built Docker images.

---

# 6. Docker Containers

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

# 7. Docker Volumes

## What Is A Docker Volume?

Docker volumes provide persistent storage for containers.

Volumes keep data safe even if:

- containers are removed
- containers restart
- Docker restarts
- VPS reboots

Recommended for:

- databases
- uploads
- application data
- production deployments

---

## Create Docker Volume

```bash
docker volume create nginx-data
```

Creates a Docker volume named `nginx-data`.

---

## Check Docker Volumes

```bash
docker volume ls
```

Displays available Docker volumes.

Should show:

```txt
nginx-data
```

---

## Inspect Docker Volume

```bash
docker volume inspect nginx-data
```

Displays detailed Docker volume information.

---

## Stop Existing Container

```bash
docker stop nginx-server
```

Stops the currently running Nginx container.

---

## Remove Existing Container

```bash
docker rm nginx-server
```

Deletes the old container before recreating it with a persistent volume.

---

## Run Nginx With Persistent Volume

```bash
docker run -d \
  --name nginx-server \
  -p 8080:80 \
  --restart unless-stopped \
  -v nginx-data:/usr/share/nginx/html \
  nginx
```

Runs Nginx container with:

- persistent Docker volume
- automatic restart policy
- public port mapping

---

## About Volume Mounting

```txt
-v nginx-data:/usr/share/nginx/html
```

Meaning:

```txt
Docker Volume:
nginx-data

Mounted Inside Container:
 /usr/share/nginx/html
```

This container path stores Nginx website files.

---

## Verify Running Container

```bash
docker ps
```

Checks whether the new Nginx container is running correctly.

---

## Verify In Browser

```txt
http://YOUR_PUBLIC_IP:8080
```

Should display:

```txt
Welcome to nginx!
```

---

## Remove Unused Volumes

```bash
docker volume prune
```

Deletes unused Docker volumes.

Use carefully in production environments.

---

## Remove Specific Volume

```bash
docker volume rm nginx-data
```

Deletes a specific Docker volume.

---

## Check Docker Disk Usage

```bash
docker system df
```

Displays Docker storage usage including:

- images
- containers
- volumes
- build cache

---

# 8. Docker Restart Policies

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

# 9. Docker Logs

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

# 10. Execute Commands Inside Container

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

# 11. Docker Compose

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

# 12. Docker Networks

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

# 13. Docker Security

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

# 14. Useful Docker Service Commands

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

# 15. Docker Cleanup

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

# 16. Docker Monitoring

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

# 17. Example Docker Compose File

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

# 18. Docker Security Best Practices

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

# 19. Common Docker Issues

## Dockerfile Not Found

Possible reason:

- Dockerfile does not exist in current directory

Fix:

```bash
nano Dockerfile
```

Then create a valid Dockerfile before running:

```bash
docker build -t myapp .
```

---

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

# 20. Useful Docker Workflow

1. Install Docker
2. Verify Docker installation
3. Pull/build image
4. Create Dockerfile
5. Build Docker image
6. Create Docker volume
7. Run container
8. Map ports
9. Check logs
10. Monitor resources
11. Configure backups
12. Clean unused resources
13. Use restart policies
14. Monitor Docker service