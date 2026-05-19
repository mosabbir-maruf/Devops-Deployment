# Linux Basics

## What Is Linux?

Linux is an open-source operating system widely used for:

- VPS servers
- cloud infrastructure
- backend systems
- DevOps workflows
- Docker containers
- hosting applications

---

# Current Directory

## Show Current Directory

```bash
pwd
```

Displays the current working directory.

---

# File & Folder Navigation

## List Files & Folders

```bash
ls
```

Shows files and folders.

---

## List Detailed Files

```bash
ls -la
```

Shows detailed files, permissions and hidden files.

---

## Change Directory

```bash
cd folder-name
```

Moves into another directory.

---

## Go Back One Directory

```bash
cd ..
```

Moves back one folder.

---

## Go To Home Directory

```bash
cd ~
```

Moves to the home directory.

---

## Go To Root Directory

```bash
cd /
```

Moves to the Linux root directory.

---

# Create & Remove Files/Folders

## Create Folder

```bash
mkdir folder-name
```

Creates a new folder.

---

## Create Nested Folder

```bash
mkdir -p folder/subfolder
```

Creates nested folders.

---

## Create Empty File

```bash
touch file.txt
```

Creates an empty file.

---

## Remove File

```bash
rm file.txt
```

Deletes a file.

---

## Remove Folder

```bash
rm -r folder-name
```

Deletes a folder recursively.

---

## Force Remove Folder

```bash
rm -rf folder-name
```

Force deletes folder recursively.

Use carefully.

---

# Copy & Move

## Copy File

```bash
cp source.txt destination.txt
```

Copies files.

---

## Copy Folder

```bash
cp -r folder1 folder2
```

Copies folders recursively.

---

## Move / Rename File

```bash
mv old.txt new.txt
```

Moves or renames files.

---

# View File Content

## Show File Content

```bash
cat file.txt
```

Displays file content.

---

## Read Long Files

```bash
less file.txt
```

Reads long files page by page.

Press:

- `q` → quit
- `space` → next page

---

## Show First Lines

```bash
head file.txt
```

Displays first lines of file.

---

## Show Last Lines

```bash
tail file.txt
```

Displays last lines of file.

---

## Live File Monitoring

```bash
tail -f file.txt
```

Monitors file changes live.

Useful for logs.

---

# Nano Editor

## Open Nano

```bash
nano file.txt
```

Opens file inside Nano editor.

---

## Save File

```txt
Ctrl + O
```

Saves the file.

---

## Confirm Save

```txt
Enter
```

Confirms filename.

---

## Exit Nano

```txt
Ctrl + X
```

Exits Nano editor.

---

# File Permissions

## Change Permissions

```bash
chmod 700 file-or-folder
```

Changes file/folder permissions.

---

## Add Execute Permission

```bash
chmod +x script.sh
```

Makes file executable.

---

## Change Ownership

```bash
chown user:user file-or-folder
```

Changes file/folder ownership.

---

# Sudo

## Run As Administrator

```bash
sudo command
```

Runs command with administrator privileges.

---

# Search & Find

## Find File

```bash
find / -name file.txt
```

Searches for files.

---

## Search Text Inside Files

```bash
grep "text" file.txt
```

Searches text inside file.

---

## Recursive Search

```bash
grep -r "text" folder-name
```

Searches recursively inside folders.

---

# Download Files

## Download Using wget

```bash
wget URL
```

Downloads files from internet.

---

## Download Using curl

```bash
curl -O URL
```

Downloads files using curl.

---

# Archive & Compression

## Create ZIP Archive

```bash
zip -r archive.zip folder-name
```

Creates zip archive.

---

## Extract ZIP Archive

```bash
unzip archive.zip
```

Extracts zip archive.

---

## Create tar.gz Archive

```bash
tar -czvf archive.tar.gz folder-name
```

Creates compressed tar archive.

---

## Extract tar.gz Archive

```bash
tar -xzvf archive.tar.gz
```

Extracts compressed tar archive.

---

# System Information

## Show Logged-in User

```bash
whoami
```

Displays current username.

---

## Show Linux Distribution

```bash
cat /etc/os-release
```

Displays Linux distribution information.

---

## Show System Info

```bash
uname -a
```

Displays Linux kernel/system information.

---

## Show Disk Usage

```bash
df -h
```

Displays disk storage usage.

---

## Show Folder Size

```bash
du -sh folder-name
```

Displays folder size.

---

## Show RAM Usage

```bash
free -h
```

Displays memory usage.

---

## Show CPU Information

```bash
lscpu
```

Displays CPU information.

---

# Process Management

## Show Running Processes

```bash
ps aux
```

Displays running processes.

---

## Real-time Process Monitor

```bash
htop
```

Shows real-time CPU/RAM usage.

Install htop:

```bash
sudo apt install htop -y
```

---

## Kill Process

```bash
kill PROCESS_ID
```

Stops a running process.

---

## Force Kill Process

```bash
kill -9 PROCESS_ID
```

Force stops process.

Use carefully.

---

# Network Commands

## Check IP Address

```bash
ip a
```

Displays network interfaces and IP addresses.

---

## Check Open Ports

```bash
ss -tulpn
```

Displays open ports and services.

---

## Ping Server

```bash
ping google.com
```

Tests network connectivity.

---

## Test Port Connectivity

```bash
nc -zv SERVER_IP PORT
```

Checks if port is reachable.

---

# Package Management

## Update Packages

```bash
sudo apt update
```

Refreshes package lists.

---

## Upgrade Packages

```bash
sudo apt upgrade -y
```

Installs package updates.

---

## Install Package

```bash
sudo apt install package-name
```

Installs software packages.

---

## Remove Package

```bash
sudo apt remove package-name
```

Removes installed packages.

---

## Search Package

```bash
apt search package-name
```

Searches available packages.

---

# Service Management

## Start Service

```bash
sudo systemctl start service-name
```

Starts service.

---

## Stop Service

```bash
sudo systemctl stop service-name
```

Stops service.

---

## Restart Service

```bash
sudo systemctl restart service-name
```

Restarts service.

---

## Check Service Status

```bash
sudo systemctl status service-name
```

Displays service status.

---

## Enable Service On Boot

```bash
sudo systemctl enable service-name
```

Starts service automatically on boot.

---

# Logs

## View System Logs

```bash
journalctl
```

Displays system logs.

---

## View Service Logs

```bash
journalctl -u service-name
```

Displays service logs.

---

## Live Log Monitoring

```bash
journalctl -f
```

Streams logs live.

---

# Restart & Shutdown

## Reboot Server

```bash
reboot
```

Restarts the server.

---

## Shutdown Server

```bash
shutdown now
```

Turns off the server immediately.

---

# Linux Security Basics

- Avoid using root user directly
- Keep packages updated
- Use strong passwords
- Use SSH keys instead of passwords
- Configure firewall
- Remove unused packages
- Monitor open ports/services
- Backup important data regularly

---

# Recommended Linux Workflow

1. Update system
2. Create non-root user
3. Configure SSH security
4. Setup firewall
5. Install required software
6. Monitor logs/services
7. Keep system updated
8. Backup important data