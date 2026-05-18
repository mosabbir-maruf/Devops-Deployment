# VPS Deployment & Security Notes

## SSH Key Setup (Mac)

### Generate SSH Key

```bash
ssh-keygen -t ed25519
```

Generates a secure SSH public/private key pair.

---

### View Public SSH Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Shows the public SSH key for copying.

---

# VPS Login & Update

### SSH Login

```bash
ssh root@YOUR_PUBLIC_IP
```

Connects to the VPS server using SSH.

---

### Update Ubuntu

```bash
apt update && apt upgrade -y
```

Updates Ubuntu packages and installs security updates.

---

### Reboot VPS

```bash
reboot
```

Restarts the server with updated kernel/system.

---

# Create Admin User

### Create New User

```bash
adduser mosabbir
```

Creates a new Linux user.

---

### Give Sudo Access

```bash
usermod -aG sudo mosabbir
```

Gives admin/sudo privileges to the user.

---

# SSH Key Setup For New User

### Copy SSH Config

```bash
rsync --archive --chown=mosabbir:mosabbir ~/.ssh /home/mosabbir
```

Copies root SSH setup to the new user.

---

# Fix SSH Permissions

### Create SSH Folder

```bash
mkdir -p /home/mosabbir/.ssh
```

Creates SSH directory for the user.

---

### Copy Authorized Keys

```bash
cp ~/.ssh/authorized_keys /home/mosabbir/.ssh/
```

Copies allowed SSH public keys.

---

### Set Ownership

```bash
chown -R mosabbir:mosabbir /home/mosabbir/.ssh
```

Sets correct ownership for SSH folder/files.

---

### Secure SSH Folder

```bash
chmod 700 /home/mosabbir/.ssh
```

Makes SSH folder private and secure.

---

### Secure authorized_keys

```bash
chmod 600 /home/mosabbir/.ssh/authorized_keys
```

Secures authorized SSH key file permissions.

---

# Firewall Setup (UFW)

### Allow SSH

```bash
sudo ufw allow OpenSSH
```

Allows SSH access through firewall.

---

### Enable Firewall

```bash
sudo ufw enable
```

Activates UFW firewall.

---

### Check Firewall Status

```bash
sudo ufw status
```

Displays firewall rules and status.

---

# Install Fail2Ban

### Install

```bash
sudo apt install fail2ban -y
```

Installs brute-force attack protection.

---

### Enable

```bash
sudo systemctl enable fail2ban
```

Enables Fail2Ban on server startup.

---

### Start

```bash
sudo systemctl start fail2ban
```

Starts Fail2Ban service.

---

### Check Status

```bash
sudo systemctl status fail2ban
```

Checks if Fail2Ban is running.

---

# SSH Hardening

### Open SSH Config

```bash
sudo nano /etc/ssh/sshd_config
```

---

### Use These Settings

```txt
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
KbdInteractiveAuthentication no
UsePAM yes
X11Forwarding no
AuthenticationMethods publickey
AllowUsers mosabbir
Port 1182
```

---

# Allow Custom SSH Port

```bash
sudo ufw allow 1182/tcp
```

Allows the new SSH port through firewall.

---

# Save & Exit Nano

### Save File

```txt
Ctrl + O
```

### Confirm Save

```txt
Enter
```

### Exit Nano

```txt
Ctrl + X
```

---

# Restart SSH

```bash
sudo systemctl restart ssh
```

Applies new SSH configuration.

---

# SSH Login With Custom Port

```bash
ssh -p 1182 mosabbir@YOUR_PUBLIC_IP
```

Connects securely using custom SSH port.

---

# Current Security Stack

- SSH Key Authentication
- Root Login Disabled
- Password Login Disabled
- Custom SSH Port
- UFW Firewall
- Fail2Ban Protection
- Non-root Admin User
- Public Key Authentication Only
