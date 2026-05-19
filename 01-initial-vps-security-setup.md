# Initial VPS Security Setup

# 1. Generate SSH Key (Mac)

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

# 6. Setup SSH For New User

## Create SSH Folder

```bash
mkdir -p /home/mosabbir/.ssh
```

Creates SSH directory for the new user.

---

## Copy VPS Public Key

```bash
nano /home/mosabbir/.ssh/authorized_keys
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

# 18. Create SSH Shortcut Alias (Recommended)

## Open SSH Config

```bash
nano ~/.ssh/config
```

Creates SSH client shortcuts/aliases.

---

## Add VPS Shortcut

```txt
Host vps
    HostName YOUR_PUBLIC_IP
    User mosabbir
    Port 1182
    IdentityFile ~/.ssh/vps_ed25519
```

Allows simplified SSH login commands.

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

Simplified SSH login command using the configured alias.

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
- SSH Alias Workflow Configured.