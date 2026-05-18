# Linux Basics

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

# System Information

## Show Logged-in User

```bash
whoami
```

Displays current username.

---

## Show System Info

```bash
uname -a
```

Displays Linux system information.

---

## Show Disk Usage

```bash
df -h
```

Displays disk storage usage.

---

## Show RAM Usage

```bash
free -h
```

Displays memory usage.

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

---

## Kill Process

```bash
kill PROCESS_ID
```

Stops a running process.

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
