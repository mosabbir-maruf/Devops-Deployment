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
17. [SSH Socket Issue](#ssh-socket-issue-important)
18. [Login Using Custom SSH Port](#18-login-using-custom-ssh-port)

### Mac SSH Config And Verification

19. [Create SSH Shortcut Alias In Your Mac (Recommended)](#19-create-ssh-shortcut-alias-in-your-mac-recommended)
20. [Verify Firewall](#20-verify-firewall)

### VPS Firewall & Fail2Ban Notes

21. [Important Firewall Note For Web Servers](#21-important-firewall-note-for-web-servers)

### Mac SSH (Continued)

22. [Recommended SSH File Structure (Mac)](#22-recommended-ssh-file-structure-mac)

### Swap File Setup

23. [Swap File Setup](#23-swap-file-setup)

### Best Practices And Checklist

24. [SSH Security Best Practices](#24-ssh-security-best-practices)
25. [Final Security Checklist](#25-final-security-checklist)

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

## Verify Fail2Ban Jails

```bash
sudo fail2ban-client status
```

Expected output:

```txt
Status
|- Number of jail: ...
`- Jail list: ...
```

Confirms Fail2Ban is actively monitoring SSH for brute-force attacks.

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

> **Note:** If `ssh.socket` is active on your system, this restart may not apply the port change. Proceed to the SSH Socket Issue section below to check and fix this.

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

### ⚠️ Warning

Disabling `ssh.socket` without ensuring `ssh.service` is enabled for automatic startup may cause **complete SSH lockout after reboot**. The fix below handles both steps correctly.

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

### Check

```bash
sudo systemctl status ssh.socket
```

| If you see | Then |
|---|---|
| `Listen: 0.0.0.0:22` + `Listen: [::]:22` (active) | `ssh.socket` is overriding your port — apply the **Fix** below |
| `Unit ssh.socket could not be found` or **inactive**/**dead** | This issue does **not** apply to your system — **skip this section** |

### Fix

Disable socket activation, explicitly enable the SSH service for automatic startup after reboot, then restart:

```bash
sudo systemctl disable --now ssh.socket
sudo systemctl enable ssh
sudo systemctl restart ssh
```

### Verify Fix

Check that SSH service is enabled for automatic startup:

```bash
systemctl is-enabled ssh
```

Expected:

```txt
enabled
```

Check that SSH service is running:

```bash
sudo systemctl status ssh
```

Expected:

```txt
active (running)
```

Check that SSH is listening on the custom port:

```bash
sudo ss -tulpn | grep ssh
```

Expected output:

```txt
0.0.0.0:1182
[::]:1182
```

### Verify Before Closing Current Session

Open a **new terminal** on your Mac to test the new port:

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

Only close the existing SSH session after confirming the new port works.

### Reboot Validation (Mandatory)

After confirming the fix works in the current session, validate that SSH survives a reboot:

```bash
sudo reboot
```

Wait for the server to come back, then reconnect:

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

After reconnecting, verify everything survived the reboot:

```bash
systemctl is-enabled ssh
sudo systemctl status ssh
sudo ss -tulpn | grep ssh
```

All three checks should show the same results as the **Verify Fix** step above. If any check fails, do not close the current session and troubleshoot before rebooting again.

### Troubleshooting Commands

```bash
sudo grep "^Port" /etc/ssh/sshd_config   # Check configured port
systemctl is-enabled ssh                   # Check SSH auto-start
sudo systemctl status ssh                  # Check SSH service
sudo systemctl status ssh.socket           # Check socket activation
sudo ss -tulpn | grep ssh                  # Check listening ports
```

---

# 18. Login Using Custom SSH Port

## Secure SSH Login

```bash
ssh -i ~/.ssh/vps_ed25519 -p 1182 mosabbir@YOUR_PUBLIC_IP
```

Connects securely using:

- custom SSH port
- dedicated VPS SSH key
- non-root admin user

---

# 19. Create SSH Shortcut Alias In Your Mac (Recommended)

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

# 20. Verify Firewall

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

# 21. Important Firewall Note For Web Servers

After completing SSH hardening, your firewall may only allow:

```txt
1182/tcp ALLOW
```

This is sufficient for SSH access only.

If you plan to use Coolify, Docker, Nginx, websites, APIs, or Let's Encrypt SSL, you must also allow HTTP and HTTPS:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Verify:

```bash
sudo ufw status numbered
```

Expected:

```txt
Status: active

1182/tcp ALLOW
80/tcp   ALLOW
443/tcp  ALLOW
```

### Why?

Port 80 (HTTP):

```txt
- Website access
- HTTP traffic
- Let's Encrypt SSL validation
```

Port 443 (HTTPS):

```txt
- Secure HTTPS traffic
- SSL certificates
- Production websites
```

Without these ports, websites won't load, Nginx/Coolify won't be reachable, and SSL certificate issuance may fail.

---

## Delete Firewall Rules

Only use this section if you need to remove a firewall rule.

View rules with numbers:

```bash
sudo ufw status numbered
```

Delete a rule by its number:

```bash
sudo ufw delete <RULE_NUMBER>
```

Example:

```bash
sudo ufw status numbered
```

```txt
Status: active

     To                         Action      From
--  ---                         ------      ----
[ 1] 1182/tcp                   ALLOW IN    Anywhere
[ 2] 80/tcp                     ALLOW IN    Anywhere
[ 3] 443/tcp                    ALLOW IN    Anywhere
```

```bash
sudo ufw delete 3
```

Deletes rule number 3 (443/tcp).

You can also delete by service/port name:

```bash
sudo ufw delete allow 80/tcp
```

---

# 22. Recommended SSH File Structure (Mac)

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

# 23. Swap File Setup

## Check Current Swap Status

```bash
free -h
swapon --show
```

Expected:

```txt
               total        used        free      shared  buff/cache   available
Mem:           7.8Gi       456Mi       7.1Gi       4.0Mi       453Mi       7.3Gi
Swap:             0B          0B          0B
```

Shows current memory and swap usage. No existing swap is expected on a fresh VPS.

---

## Create Swap File

```bash
sudo fallocate -l 8G /swapfile
ls -lh /swapfile
```

Expected:

```txt
-rw-r--r-- 1 root root 8.0G Jun 13 07:57 /swapfile
```

Creates an 8GB swap file.

---

## Secure Swap File

```bash
sudo chmod 600 /swapfile
ls -lh /swapfile
```

Expected:

```txt
-rw------- 1 root root 8.0G Jun 13 07:57 /swapfile
```

Restricts swap file access to root only (security best practice).

---

## Format As Swap

```bash
sudo mkswap /swapfile
```

Expected:

```txt
Setting up swapspace version 1, size = 8 GiB (8589930496 bytes)
no label, UUID=f90af7af-ca89-45cd-ad59-54e96bc638e2
```

Formats the file as a Linux swap area.

---

## Enable Swap

```bash
sudo swapon /swapfile
```

## Confirm Swap Is Active

```bash
free -h
swapon --show
```

Expected:

```txt
               total        used        free      shared  buff/cache   available
Mem:           7.8Gi       462Mi       7.1Gi       4.0Mi       455Mi       7.3Gi
Swap:          8.0Gi          0B       8.0Gi
NAME      TYPE SIZE USED PRIO
/swapfile file   8G   0B   -2
```

Verifies swap is enabled and active.

---

## Make Swap Permanent

Add to `/etc/fstab` so swap persists across reboots:

```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Expected output:

```txt
/swapfile none swap sw 0 0
```

Verify:

```bash
cat /etc/fstab
```

Expected output (last line):

```txt
LABEL=cloudimg-rootfs   /        ext4   discard,commit=30,errors=remount-ro     0 1
LABEL=BOOT      /boot   ext4    defaults        0 2
LABEL=UEFI      /boot/efi       vfat    umask=0077      0 1
/swapfile none swap sw 0 0
```

---

## Production Swappiness

Check current swappiness value (default is usually 60):

```bash
cat /proc/sys/vm/swappiness
```

Expected:

```txt
60
```

Set swappiness to 10 (only swap when RAM is 90% full — better for performance):

```bash
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl --system
```

Expected output:

```txt
vm.swappiness=10
* Applying /usr/lib/sysctl.d/10-apparmor.conf ...
* Applying /etc/sysctl.d/10-bufferbloat.conf ...
* Applying /etc/sysctl.d/10-console-messages.conf ...
* Applying /etc/sysctl.d/10-ipv6-privacy.conf ...
* Applying /etc/sysctl.d/10-kernel-hardening.conf ...
* Applying /etc/sysctl.d/10-magic-sysrq.conf ...
* Applying /etc/sysctl.d/10-map-count.conf ...
* Applying /etc/sysctl.d/10-network-security.conf ...
* Applying /etc/sysctl.d/10-ptrace.conf ...
* Applying /etc/sysctl.d/10-zeropage.conf ...
* Applying /usr/lib/sysctl.d/50-pid-max.conf ...
* Applying /etc/sysctl.d/99-cloudimg-ipv6.conf ...
* Applying /usr/lib/sysctl.d/99-protect-links.conf ...
* Applying /etc/sysctl.d/99-swappiness.conf ...
* Applying /etc/sysctl.d/99-sysctl.conf ...
* Applying /etc/sysctl.conf ...
vm.swappiness = 10
```

Verify:

```bash
cat /proc/sys/vm/swappiness
```

Expected:

```txt
10
```

---

## Final Test

Reboot the server:

```bash
sudo reboot
```

After the server reboots, reconnect and verify swap:

```bash
free -h
swapon --show
```

Expected:

```txt
NAME       TYPE SIZE USED PRIO
/swapfile  file   8G   0B   -2
```

While connected, also verify SSH survived the reboot:

```bash
systemctl is-enabled ssh
sudo systemctl status ssh
sudo ss -tulpn | grep ssh
```

All checks should confirm SSH is enabled, running, and listening on the custom port.

Confirms swap and SSH are both working correctly after reboot.

---

# 24. SSH Security Best Practices

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

# 25. Final Security Checklist

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

## Final Security Verification

Run these commands to confirm everything is working:

```bash
ssh -p 1182 mosabbir@YOUR_PUBLIC_IP   # SSH with custom port
sudo ufw status                        # Firewall rules
sudo fail2ban-client status            # Fail2Ban jails
sudo systemctl status ssh              # SSH service
```
