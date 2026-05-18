# SSH Guide

# What Is SSH?

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

## Private Key

- Must stay secret
- Stored on your computer
- Used to securely authenticate

---

# Generate SSH Key

```bash
ssh-keygen -t ed25519
```

Generates a secure SSH public/private key pair using the Ed25519 algorithm.

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

# Default SSH Key Locations

## Private Key

```txt
~/.ssh/id_ed25519
```

## Public Key

```txt
~/.ssh/id_ed25519.pub
```

---

# View Public SSH Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Shows the public SSH key for copying.

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

# SSH Config File

SSH configuration file location:

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

# GitHub SSH Authentication

GitHub can use SSH keys for secure Git authentication.

Example:

```bash
git clone git@github.com:username/repo.git
```

Benefits:

- no password required
- more secure
- easier Git workflow

---

# Recommended SSH Workflow

1. Generate SSH key
2. Copy public key to server
3. Connect securely using SSH
4. Disable password login
5. Use custom SSH port
6. Use public key authentication only
