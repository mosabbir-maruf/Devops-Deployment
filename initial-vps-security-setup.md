# Initial VPS Security Setup

# 1. Generate SSH Key (Mac)

## Generate SSH Key

```bash
ssh-keygen -t ed25519
```

Generates a secure SSH public/private key pair using the modern Ed25519 algorithm.

---

## About `-t ed25519`

```txt
-t
→ Means "type"

ed25519
→ Modern SSH key algorithm/type
```

Why use Ed25519?

- More secure
- Faster
- Smaller keys
- Modern OpenSSH standard
- Recommended over older RSA keys

---

## View Public SSH Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Shows the public SSH key for copying.

---

# 2. Connect To VPS

## SSH Login

```bash
ssh root@YOUR_PUBLIC_IP
```

Connects to the VPS server using SSH.

---

# 3. Update Ubuntu

## Update Packages

```bash
apt update && apt upgrade -y
```

Updates Ubuntu packages and installs security updates.

---

# 4. Reboot VPS

## Restart Server

```bash
reboot
```

Restarts the server with updated kernel/system.

Reconnect after reboot:

```bash
ssh root@YOUR_PUBLIC_IP
```

---

# 5. Create New Admin User

## Create User

```bash
adduser mosabbir
```

Creates a new Linux user.

---

## Give Sudo Access

```bash
usermod -aG sudo mosabbir
```

Gives administrator/sudo privileges.

---

# 6. Copy SSH Setup To New User

## Copy SSH Files

```bash
rsync --archive --chown=mosabbir:mosabbir ~/.ssh /home/mosabbir
```

Copies root SSH setup to the new user.

---

# 7. Fix SSH Permissions

## Create SSH Folder

```bash
mkdir -p /home/mosabbir/.ssh
```

Creates SSH directory.

---

## Copy Authorized Keys

```bash
cp ~/.ssh/authorized_keys /home/mosabbir/.ssh/
```

Copies authorized SSH public keys.

---

## Set Ownership

```bash
chown -R mosabbir:mosabbir /home/mosabbir/.ssh
```

Sets correct ownership for SSH files.

---

## Secure SSH Folder

```bash
chmod 700 /home/mosabbir/.ssh
```

Makes SSH folder private and secure.

---

## Secure Authorized Keys

```bash
chmod 600 /home/mosabbir/.ssh/authorized_keys
```

Protects authorized_keys file permissions.

---

# 8. Setup Firewall (UFW)

## Allow SSH

```bash
sudo ufw allow OpenSSH
```

Allows SSH access through firewall.

---

## Enable Firewall

```bash
sudo ufw enable
```

Activates UFW firewall.

---

## Check Firewall Status

```bash
sudo ufw status
```

Displays firewall rules and status.

---

# 9. Install Fail2Ban

## Install Fail2Ban

```bash
sudo apt install fail2ban -y
```

Installs brute-force attack protection.

---

## Enable Fail2Ban

```bash
sudo systemctl enable fail2ban
```

Starts Fail2Ban automatically on server boot.

---

## Start Fail2Ban

```bash
sudo systemctl start fail2ban
```

Starts Fail2Ban service.

---

## Check Fail2Ban Status

```bash
sudo systemctl status fail2ban
```

Checks if Fail2Ban is running.

---

# 10. SSH Security Hardening

## Open SSH Config

```bash
sudo nano /etc/ssh/sshd_config
```

Opens SSH configuration file.

---

## Use These Settings

```txt
PermitRootLogin no
→ Disables direct root SSH login.

PasswordAuthentication no
→ Disables password-based SSH login.

PermitEmptyPasswords no
→ Blocks empty password logins.

KbdInteractiveAuthentication no
→ Disables interactive keyboard authentication.

UsePAM yes
→ Keeps PAM authentication/session support enabled.

X11Forwarding no
→ Disables GUI/X11 forwarding.

AuthenticationMethods publickey
→ Allows only SSH key authentication.

AllowUsers mosabbir
→ Allows SSH login only for the specified user.

Port 1182
→ Changes default SSH port 22 to a custom port.
```

---

# 11. Allow Custom SSH Port

## Allow Port 1182

```bash
sudo ufw allow 1182/tcp
```

Allows custom SSH port through firewall.

---

# 12. Save & Exit Nano

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

# 13. Restart SSH

## Restart SSH Service

```bash
sudo systemctl restart ssh
```

Applies new SSH configuration.

---

# 14. Login Using Custom SSH Port

## Secure SSH Login

```bash
ssh -p 1182 mosabbir@YOUR_PUBLIC_IP
```

Connects securely using custom SSH port.

---

# 15. Verify Firewall

## Check Firewall Rules

```bash
sudo ufw status
```

Should show:

```txt
1182/tcp ALLOW
```

---

# 16. Final Security Checklist

- SSH Key Authentication Enabled
- Root Login Disabled
- Password Login Disabled
- Custom SSH Port Enabled
- UFW Firewall Enabled
- Fail2Ban Protection Enabled
- Non-root Admin User Configured
- Public Key Authentication Only
- SSH Hardening Applied
