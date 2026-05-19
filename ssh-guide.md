````md id="m8q2vx"
# SSH Guide

## What Is SSH?

SSH (Secure Shell) is a secure protocol used to remotely connect and manage servers.

Example:

```bash
ssh user@SERVER_IP
```

---

# SSH Key Authentication

SSH uses a public/private key system for secure authentication.

## Public Key

- Can be shared
- Stored on the server
- Used to verify identity

---

## Private Key

- Must stay secret
- Stored on your computer
- Used to securely authenticate

Never share private SSH keys.

---

# Generate SSH Key

## Generate SSH Key

```bash
ssh-keygen -t ed25519
```

Generates a secure SSH public/private key pair using the Ed25519 algorithm.

---

## Generate SSH Key With Label

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Adds label/comment to SSH key.

Useful for:

- GitHub
- VPS identification
- work/personal separation

---

## Generate Custom SSH Key Name

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_key
```

Creates SSH key with custom filename.

Useful for managing multiple SSH keys.

---

# About `-t ed25519`

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

## Alternative RSA Key

```bash
ssh-keygen -t rsa -b 4096
```

Generates strong RSA SSH key.

Ed25519 is still recommended for modern systems.

---

# Default SSH Key Locations

## Private Key

```txt
~/.ssh/id_ed25519
```

---

## Public Key

```txt
~/.ssh/id_ed25519.pub
```

---

# View Public SSH Key

## Show Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Shows the public SSH key for copying.

---

## Copy Public Key (macOS)

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

Copies SSH public key directly to clipboard on macOS.

---

# SSH Login

## Default SSH Port

```bash
ssh user@SERVER_IP
```

Uses default SSH port 22.

---

## Custom SSH Port

```bash
ssh -p 1182 user@SERVER_IP
```

Connects using a custom SSH port.

---

# SSH Passphrase

A passphrase adds extra protection to your private SSH key.

Benefits:

- Extra security layer
- Protects private key if device is compromised
- Recommended for personal/dev machines

---

# SSH Agent

## Start SSH Agent

```bash
eval "$(ssh-agent -s)"
```

Starts SSH authentication agent.

---

## Add SSH Key To Agent

```bash
ssh-add ~/.ssh/id_ed25519
```

Loads SSH key into SSH agent.

Benefits:

- avoids entering passphrase repeatedly
- easier GitHub/VPS workflow

---

# SSH Config File

## SSH Config Location

```txt
~/.ssh/config
```

Used for:

- custom host names
- custom ports
- easier SSH login
- multiple servers

---

# Example SSH Config

```txt
Host myvps
    HostName YOUR_SERVER_IP
    User mosabbir
    Port 1182
```

After this, login becomes:

```bash
ssh myvps
```

---

# SSH Connection Multiplexing

Useful for faster repeated SSH connections.

## Example Config

```txt
Host *
  ControlMaster auto
  ControlPath ~/.ssh/control-%r@%h:%p
  ControlPersist 10m
```

Reuses existing SSH connections for better performance.

---

# SSH Known Hosts

## Known Hosts File

```txt
~/.ssh/known_hosts
```

Stores trusted server fingerprints.

Helps prevent man-in-the-middle attacks.

---

## Remove Old Known Host

```bash
ssh-keygen -R SERVER_IP
```

Removes outdated SSH fingerprints.

Useful after VPS reinstall/redeployment.

---

# SSH File Permissions

## Secure SSH Folder

```bash
chmod 700 ~/.ssh
```

Makes SSH folder private.

---

## Secure Private Key

```bash
chmod 600 ~/.ssh/id_ed25519
```

Protects private SSH key permissions.

---

## Secure SSH Config File

```bash
chmod 600 ~/.ssh/config
```

Protects SSH config file permissions.

---

# Copy SSH Key To Server

## Automatically Copy SSH Key

```bash
ssh-copy-id user@SERVER_IP
```

Automatically copies SSH public key to server.

---

# SSH Tunneling

## Create SSH Tunnel

```bash
ssh -L 3000:localhost:3000 user@SERVER_IP
```

Creates secure SSH tunnel.

Useful for:

- private dashboards
- local-only services
- MongoDB access
- admin panels

---

# SSH Port Testing

## Test SSH Port

```bash
nc -zv SERVER_IP 1182
```

Checks if SSH port is reachable/open.

---

# Common SSH Errors

## Permission Denied (publickey)

Possible reasons:

- wrong SSH key
- wrong permissions
- public key not added
- wrong username
- wrong port

---

## Connection Timed Out

Possible reasons:

- firewall blocking port
- VPS offline
- wrong IP
- SSH service stopped

---

## Host Key Verification Failed

Possible reasons:

- VPS reinstalled
- changed SSH fingerprint
- old known_hosts entry

Fix:

```bash
ssh-keygen -R SERVER_IP
```

---

# SSH Debugging

## Debug SSH Connection

```bash
ssh -v user@SERVER_IP
```

Displays detailed SSH connection logs.

Useful for troubleshooting.

---

## Extra Verbose Debugging

```bash
ssh -vvv user@SERVER_IP
```

Displays advanced SSH debugging logs.

---

# Useful SSH Commands

## Restart SSH

```bash
sudo systemctl restart ssh
```

Restarts SSH service.

---

## Check SSH Status

```bash
sudo systemctl status ssh
```

Checks if SSH service is running.

---

## Show Current SSH Port

```bash
sudo grep Port /etc/ssh/sshd_config
```

Displays configured SSH port.

---

## Check Active SSH Connections

```bash
who
```

Displays active logged-in users.

---

# Secure Copy (SCP)

## Copy File To VPS

```bash
scp file.txt user@SERVER_IP:/home/user
```

Transfers file securely to server.

---

## Copy File From VPS

```bash
scp user@SERVER_IP:/home/user/file.txt .
```

Downloads file from server.

---

## Copy Folder To VPS

```bash
scp -r project-folder user@SERVER_IP:/home/user
```

Transfers folder recursively.

---

# GitHub SSH Authentication

GitHub can use SSH keys for secure Git authentication.

## Test GitHub SSH Authentication

```bash
ssh -T git@github.com
```

Tests GitHub SSH authentication.

---

## Clone Repository Using SSH

```bash
git clone git@github.com:username/repo.git
```

Clones GitHub repository securely using SSH.

Benefits:

- no password required
- more secure
- easier Git workflow

---

# SSH Security Best Practices

- Never share private SSH keys
- Use passphrase protection
- Use custom SSH ports
- Disable password authentication
- Use non-root users
- Backup SSH keys securely
- Rotate keys if compromised
- Keep SSH updated
- Remove unused SSH keys
- Avoid public exposure of sensitive services

---

# Recommended SSH Workflow

1. Generate SSH key
2. Copy public key to server
3. Start SSH agent
4. Add SSH key to agent
5. Configure SSH config file
6. Connect securely using SSH
7. Disable password login
8. Use custom SSH port
9. Use public key authentication only
10. Backup SSH keys securely
````
