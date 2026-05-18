# Docker

# What Is Docker?

Docker is a container platform used to package and run applications in isolated environments called containers.

Benefits:

- Easy deployment
- Consistent environments
- Lightweight virtualization
- Fast setup
- Portable applications

---

# Install Docker

## Install Docker

```bash
curl -fsSL https://get.docker.com | sudo bash
```

Installs Docker using the official installation script.

---

## Add User To Docker Group

```bash
sudo usermod -aG docker $USER
```

Allows running Docker without sudo.

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

## Check Docker Service

```bash
sudo systemctl status docker
```

Checks if Docker service is running.

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

# Docker Images

## Pull Docker Image

```bash
docker pull nginx
```

Downloads Docker image from Docker Hub.

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
docker run -d nginx
```

Runs container in detached mode.

---

## Run Container With Port Mapping

```bash
docker run -d -p 3000:3000 nginx
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

# Execute Commands Inside Container

## Open Container Shell

```bash
docker exec -it CONTAINER_ID bash
```

Opens interactive bash shell inside container.

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

# Docker Cleanup

## Remove Unused Containers

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

## Remove Everything Unused

```bash
docker system prune -a
```

Deletes unused Docker resources.

---

# Docker Security Basics

- Avoid exposing unnecessary ports
- Use trusted Docker images
- Keep Docker updated
- Remove unused containers/images
- Avoid running containers as root
- Use environment variables for secrets
- Do not expose databases publicly unless necessary

---

# Useful Docker Workflow

1. Install Docker
2. Verify Docker installation
3. Pull image
4. Run container
5. Map ports
6. Check logs
7. Restart container if needed
8. Clean unused resources
