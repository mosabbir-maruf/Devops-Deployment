# Initial VPS Security Setup

First guide in the series. Harden a fresh Ubuntu VPS before installing Docker, databases, or deploying applications.

**Mac** = generate SSH keys and connect from your workstation. **Linux VPS** = all server-side steps run on the VPS.

Related guides after this: `02-ssh-guide.md`, `04-docker.md`, `11-nginx-reverse-proxy.md`, `10-project-deployment.md`.

---

## Table Of Contents

### Overview

- [What This Guide Covers](#what-this-guide-covers)
- [Recommended Order Of Operations](#recommended-order-of-operations)
- [Production Security Architecture](#production-security-architecture)

### SSH Keys (Mac)

1. [Generate SSH Key (Mac)](#1-generate-ssh-key-mac)

### Initial VPS Access

2. [Connect To VPS](#2-connect-to-vps)
3. [Update Ubuntu](#3-update-ubuntu)
4. [Reboot VPS](#4-reboot-vps)

### User And SSH Setup (VPS)

5. [Create New Admin User](#5-create-new-admin-user)
6. [Setup SSH For New User](#6-setup-ssh-for-new-user)
7. [Fix SSH Permissions](#7-fix-ssh-permissions)

### Firewall And Fail2Ban (VPS)

8. [Setup Firewall (UFW)](#8-setup-firewall-ufw)
9. [Install Fail2Ban](#9-install-fail2ban)

### SSH Hardening (VPS)

10. [SSH Security Hardening](#10-ssh-security-hardening)
11. [Allow Custom SSH Port](#11-allow-custom-ssh-port)
12. [Remove Old SSH Port Rule](#12-remove-old-ssh-port-rule)
13. [Save & Exit Nano](#13-save--exit-nano)
14. [Verify SSH Config Before Restart](#14-verify-ssh-config-before-restart)
15. [Restart SSH](#15-restart-ssh)
16. [Verify SSH Service](#16-verify-ssh-service)
17. [Login Using Custom SSH Port](#17-login-using-custom-ssh-port)

### Mac SSH Config And Verification

18. [Create SSH Shortcut Alias In Your Mac (Recommended)](#18-create-ssh-shortcut-alias-in-your-mac-recommended)
19. [Verify Firewall](#19-verify-firewall)
20. [Recommended SSH File Structure (Mac)](#20-recommended-ssh-file-structure-mac)

### Best Practices And Checklist

21. [SSH Security Best Practices](#21-ssh-security-best-practices)
22. [Final Security Checklist](#22-final-security-checklist)

### Next Steps

- [After Initial Setup](#after-initial-setup)

---

## What This Guide Covers

Initial VPS security setup for a fresh Ubuntu server:

- Generate separate SSH keys on Mac (GitHub + VPS)
- Create non-root admin user with sudo
- Configure UFW firewall
- Install Fail2Ban
- Harden SSH (disable root, disable passwords, custom port)
- Create Mac SSH alias for daily access

Complete this guide **before** installing Docker or deploying apps.

---

## Recommended Order Of Operations

```txt
1. Generate VPS SSH key on Mac
2. First login as root
3. Update Ubuntu + reboot
4. Create admin user + authorized_keys
5. Enable UFW + Fail2Ban
6. Harden sshd_config (custom port, key-only)
7. Verify config → restart SSH
8. Login with new user + custom port
9. Configure ~/.ssh/config alias on Mac
10. Run final security checklist
```

---

## Production Security Architecture

```txt
Mac (~/.ssh/vps_ed25519)
↓ SSH port 1182 (key only)
↓
UFW (allow 1182, 80, 443 only)
↓
Fail2Ban (block brute-force)
↓
Non-root user (mosabbir + sudo)
↓
Ready for Docker + deployment guides
```

---

# 1. Generate SSH Key (Mac)

## Optional GitHub SSH Key Setup

If you already have a working GitHub SSH setup on your Mac, you can skip the GitHub SSH key section and only create the dedicated VPS SSH key.

Recommended:

- Keep existing GitHub SSH key if already configured
- Create a separate SSH key only for VPS access
- Use dedicated SSH keys for different services/environments

Example:

```txt
Existing GitHub SSH Key
→ ~/.ssh/id_ed25519

Dedicated VPS SSH Key
→ ~/.ssh/vps_ed25519
```

This provides:

- cleaner SSH management
- better security separation
- safer production workflows
- easier key rotation/revocation

---

## Generate GitHub SSH Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "github-access"
```

Generates a dedicated SSH key for GitHub authentication and verified commits.

---

## Generate VPS SSH Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/vps_ed25519 -C "vps-access"
```

Generates a separate SSH key dedicated only for VPS access.

Recommended for:

- better security separation
- easier key management
- safer production workflows
- independent key rotation/revocation

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

## About `-f`

```txt
-f
→ Means file/path
```

Examples:

```txt
~/.ssh/id_ed25519
→ GitHub SSH key

~/.ssh/vps_ed25519
→ VPS SSH key
```

Allows using multiple SSH keys for different services.

---

## About `-C`

```txt
-C
→ Means comment/label
```

Used only as an identifier for the key.

Examples:

```txt
github-access
vps-access
macbook-key
production-server
```

Does not affect authentication/security.

---

## View GitHub Public SSH Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Displays GitHub public SSH key.

---

## View VPS Public SSH Key

```bash
cat ~/.ssh/vps_ed25519.pub
```

Displays VPS public SSH key.

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
sudo apt update && sudo apt upgrade -y
```

Updates Ubuntu packages and installs security updates.

---

# 4. Reboot VPS

## Restart Server

```bash
sudo reboot
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
sudo adduser mosabbir
```

Creates a new Linux user.

---

## Give Sudo Access

```bash
usermod -aG sudo mosabbir
```

Gives administrator/sudo privileges.

---

# 6. Setup SSH For New User

## Create SSH Folder

```bash
sudo mkdir -p /home/mosabbir/.ssh
```

Creates SSH directory for the new user.

---

## Verify Current User

```bash
whoami
```

Should print `root` at this point in the setup.

This confirms you're logged in as root before copying SSH keys to the new user.

---

## Copy VPS Public Key (Option 1 – Copy From Root)

```bash
sudo cp /home/ubuntu/.ssh/authorized_keys /home/mosabbir/.ssh/
```

Copies the authorized_keys file from the root user to the new admin user.

This is faster if root SSH access is already configured.

---

## Copy VPS Public Key (Option 2 – Manual Paste)

```bash
sudo nano /home/mosabbir/.ssh/authorized_keys
```

Opens authorized_keys file.

Paste the full contents of:

```bash
cat ~/.ssh/vps_ed25519.pub
```

inside the file.

This allows VPS login using the dedicated VPS SSH key.

---

# 7. Fix SSH Permissions

## Set Ownership

```bash
sudo chown -R mosabbir:mosabbir /home/mosabbir/.ssh
```

Sets correct ownership for SSH files.

---

## Secure SSH Folder

```bash
sudo chmod 700 /home/mosabbir/.ssh
```

Makes SSH folder private and secure.

---

## Secure Authorized Keys

```bash
sudo chmod 600 /home/mosabbir/.ssh/authorized_keys
```

Protects authorized_keys file permissions.

---

# 8. Setup Firewall (UFW)

## Allow OpenSSH

```bash
sudo ufw allow OpenSSH
```

Temporarily allows default SSH port 22.

Useful before changing to a custom SSH port.

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

PubkeyAuthentication yes
→ Enables SSH public key authentication.

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

# 12. Remove Old SSH Port Rule

## Remove OpenSSH Rule

```bash
sudo ufw delete allow OpenSSH
```

Removes default SSH port 22 firewall rule after confirming the custom port works properly.

Recommended for additional security.

---

# 13. Save & Exit Nano

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

# 14. Verify SSH Config Before Restart

## Check SSH Config Syntax

```bash
sudo sshd -t
```

Checks for SSH configuration errors before restarting SSH service.

Highly recommended to avoid accidental SSH lockouts.

No output usually means the configuration is valid.

---

# 15. Restart SSH

## Restart SSH Service

```bash
sudo systemctl restart ssh
```

Applies new SSH configuration.

---

# 16. Verify SSH Service

## Check SSH Status

```bash
sudo systemctl status ssh
```

Checks whether the SSH service is running correctly.

Should show:

```txt
active (running)
```

---

## SSH Socket Issue (Important)

### Problem

After changing `Port 1182` inside `/etc/ssh/sshd_config`, SSH may still continue listening on port 22.

```bash
ssh -p 1182 mosabbir@YOUR_PUBLIC_IP
```

returns `Connection refused`, even though:

```bash
sudo grep "^Port" /etc/ssh/sshd_config
```

shows `Port 1182`.

### Root Cause

Some systems use `ssh.socket` (socket activation) instead of allowing sshd to bind directly. When `ssh.socket` is active, it ignores the `Port` setting in `sshd_config` and always listens on port 22.

Check if `ssh.socket` is running on your system:

```bash
sudo systemctl status ssh.socket
```

If the output shows `ssh.socket` is **active** and listening on port 22:

```txt
Listen: 0.0.0.0:22
Listen: [::]:22
```

then `ssh.socket` is overriding your custom SSH port.

If the command returns `Unit ssh.socket could not be found` or shows **inactive**/**dead**, this issue does **not** apply to your system — skip this section.

### Fix

Disable socket activation:

```bash
sudo systemctl disable --now ssh.socket
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

Verify:

```bash
sudo ss -tulpn | grep ssh
```

Expected:

```txt
0.0.0.0:1182
[::]:1182
```

### Verify Before Closing Current Session

Open a **new terminal** on your Mac:

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

Only close the existing SSH session after confirming the new port works.

### Troubleshooting Commands

Check configured port:

```bash
sudo grep "^Port" /etc/ssh/sshd_config
```

Check SSH service:

```bash
sudo systemctl status ssh
```

Check socket activation:

```bash
sudo systemctl status ssh.socket
```

Check listening ports:

```bash
sudo ss -tulpn | grep ssh
```

---

# 17. Login Using Custom SSH Port

## Secure SSH Login

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

Connects securely using:

- custom SSH port
- dedicated VPS SSH key
- non-root admin user

---

# 18. Create SSH Shortcut Alias In Your Mac (Recommended)

## Open SSH Config

```bash
nano ~/.ssh/config
```

Opens the SSH client configuration file used for SSH shortcuts/aliases.

---

## Add VPS Shortcut

```txt
Host vps
    HostName YOUR_PUBLIC_IP
    User mosabbir
    Port 1182
    IdentityFile ~/.ssh/vps_ed25519
```

Creates a simplified SSH shortcut for easier future VPS logins.

---

## About Each Option

```txt
Host vps
```

The shortcut/alias name used for future SSH logins.

Example:

```bash
ssh vps
```

You can replace `vps` with any custom name you prefer.

---

```txt
HostName YOUR_PUBLIC_IP
```

Your VPS public IP address.

Example:

```txt
HostName 123.123.123.123
```

---

```txt
User mosabbir
```

The Linux username used for SSH login.

Example:

```txt
User mosabbir
```

---

```txt
Port 1182
```

Your custom SSH port configured inside `sshd_config`.

Example:

```txt
Port 1182
```

---

```txt
IdentityFile ~/.ssh/vps_ed25519
```

The SSH private key used for VPS authentication.

Example:

```txt
IdentityFile ~/.ssh/vps_ed25519
```

---

## Save SSH Config

```txt
Ctrl + O
Enter
Ctrl + X
```

Saves SSH config file.

---

## Connect Using Alias

```bash
ssh vps
```

Allows connecting to the VPS without typing the full SSH command every time.

Recommended for daily VPS workflows.

---

# 19. Verify Firewall

## Check Firewall Rules

```bash
sudo ufw status
```

Should show:

```txt
1182/tcp ALLOW
```

and default SSH port removed if configured.

---

# 20. Recommended SSH File Structure (Mac)

```txt
~/.ssh/
├── config
├── id_ed25519
├── id_ed25519.pub
├── vps_ed25519
├── vps_ed25519.pub
├── known_hosts
```

Recommended separation:

```txt
id_ed25519
→ GitHub SSH key

vps_ed25519
→ VPS SSH key
```

---

# 21. SSH Security Best Practices

Recommended:

- Use separate SSH keys for GitHub and VPS
- Never share private SSH keys
- Disable password authentication
- Disable root login
- Use custom SSH ports
- Use non-root admin users
- Keep Ubuntu updated
- Use UFW firewall
- Use Fail2Ban protection
- Use SSH aliases for easier workflows
- Test SSH config before restarting SSH
- Keep backups of important SSH keys

---

# 22. Final Security Checklist

- SSH Key Authentication Enabled
- Separate GitHub & VPS SSH Keys Configured
- Root Login Disabled
- Password Login Disabled
- Custom SSH Port Enabled
- UFW Firewall Enabled
- Fail2Ban Protection Enabled
- Non-root Admin User Configured
- Public Key Authentication Only
- SSH Hardening Applied
- SSH Config Syntax Verified
- Dedicated VPS SSH Key Configured
- SSH Alias Workflow Configured

---

## After Initial Setup

Once the final security checklist passes, continue with:

| Step | Guide |
|------|-------|
| Advanced SSH workflows | `02-ssh-guide.md` |
| Linux basics on VPS | `03-linux-basics.md` |
| Install Docker | `04-docker.md` |
| Deploy applications | `10-project-deployment.md` |
| Nginx reverse proxy | `11-nginx-reverse-proxy.md` |
| Domain + Cloudflare | `12-domain-dns-cloudflare.md` |

Quick verify everything still works:

```bash
ssh vps
sudo ufw status
sudo fail2ban-client status
sudo systemctl status ssh
```
