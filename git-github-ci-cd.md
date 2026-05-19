# Git, GitHub & CI/CD

## What Is Git?

Git is a distributed version control system used to track code changes.

Used for:

- source control
- collaboration
- deployment workflows
- rollback/history
- CI/CD pipelines

---

# What Is GitHub?

GitHub is a cloud platform used to host Git repositories.

Used for:

- code hosting
- collaboration
- pull requests
- CI/CD
- project management
- deployment automation

---

# Install Git

## Install Git

```bash
sudo apt install git -y
```

Installs Git.

---

# Verify Git Installation

## Check Git Version

```bash
git --version
```

Displays installed Git version.

---

# Configure Git

## Set Git Username

```bash
git config --global user.name "Your Name"
```

Sets global Git username.

---

## Set Git Email

```bash
git config --global user.email "you@example.com"
```

Sets global Git email.

---

## View Git Config

```bash
git config --list
```

Displays Git configuration.

---

# Generate GitHub SSH Key

## Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Creates secure SSH key.

---

## Show Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Displays public SSH key.

---

# Add SSH Key To GitHub

GitHub → Settings → SSH and GPG Keys → New SSH Key

Paste your public SSH key.

---

# Test GitHub SSH Connection

## Test SSH Authentication

```bash
ssh -T git@github.com
```

Tests GitHub SSH authentication.

---

# Create Git Repository

## Initialize Git

```bash
git init
```

Creates Git repository.

---

# Git Status

## Check Git Status

```bash
git status
```

Displays changed/untracked files.

---

# Git Add

## Add Single File

```bash
git add file.txt
```

Stages file for commit.

---

## Add All Files

```bash
git add .
```

Stages all changes.

---

# Git Commit

## Create Commit

```bash
git commit -m "Initial commit"
```

Creates Git commit.

---

# Git Branches

## Show Branches

```bash
git branch
```

Displays branches.

---

## Create Branch

```bash
git branch branch-name
```

Creates new branch.

---

## Switch Branch

```bash
git checkout branch-name
```

Switches branch.

---

## Create & Switch Branch

```bash
git checkout -b branch-name
```

Creates and switches branch.

---

# Git Remote Repository

## Add GitHub Repository

```bash
git remote add origin git@github.com:username/repository.git
```

Connects local project to GitHub.

---

## Show Git Remotes

```bash
git remote -v
```

Displays connected repositories.

---

# Push Code To GitHub

## Push Main Branch

```bash
git push -u origin main
```

Pushes code to GitHub.

---

## Push Existing Changes

```bash
git push
```

Pushes latest commits.

---

# Pull Changes

## Pull Latest Changes

```bash
git pull
```

Downloads latest repository changes.

---

# Clone Repository

## Clone GitHub Repository

```bash
git clone git@github.com:username/repository.git
```

Downloads repository locally.

---

# Git Ignore

## Create .gitignore

```bash
nano .gitignore
```

Creates ignore file.

---

# Recommended .gitignore

```txt
node_modules
.env
dist
build
.next
coverage
```

Prevents sensitive/unnecessary files from being pushed.

---

# Git Logs

## Show Commit History

```bash
git log
```

Displays commit history.

---

## Compact Commit History

```bash
git log --oneline
```

Displays compact commit history.

---

# Undo Changes

## Unstage File

```bash
git restore --staged file.txt
```

Removes staged changes.

---

## Discard File Changes

```bash
git restore file.txt
```

Discards local file changes.

---

# Git Reset

## Soft Reset

```bash
git reset --soft HEAD~1
```

Removes last commit but keeps changes.

---

## Hard Reset

```bash
git reset --hard HEAD~1
```

Deletes last commit and changes.

Use carefully.

---

# Git Stash

## Save Temporary Changes

```bash
git stash
```

Temporarily saves changes.

---

## Restore Stash

```bash
git stash pop
```

Restores stashed changes.

---

# Git Tags

## Create Tag

```bash
git tag v1.0.0
```

Creates release tag.

---

## Push Tags

```bash
git push --tags
```

Pushes tags to GitHub.

---

# GitHub Security Basics

- Never push `.env`
- Never push secrets/API keys
- Use SSH authentication
- Use private repos if needed
- Use branch protection for production
- Review commits before pushing

---

# GitHub Actions (CI/CD)

## What Is CI/CD?

CI/CD means:

- Continuous Integration
- Continuous Deployment

Used for:

- automatic testing
- automatic builds
- automatic deployments

---

# GitHub Actions Location

```txt
.github/workflows/
```

Stores GitHub Actions workflow files.

---

# Basic GitHub Actions Workflow

## Example Workflow

```yaml
name: Node.js CI

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install Dependencies
        run: npm install

      - name: Run Build
        run: npm run build
```

Basic CI workflow for Node.js.

---

# Auto Deploy Using GitHub Actions

## Example VPS Deployment Workflow

```yaml
name: Deploy VPS

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /var/www/app
            git pull
            npm install
            npm run build
            pm2 restart app
```

Deploys application automatically after GitHub push.

---

# GitHub Secrets

Used for secure environment variables in GitHub Actions.

Examples:

- SERVER_IP
- SERVER_USER
- SERVER_SSH_KEY
- DATABASE_URL
- API_KEYS

GitHub:
Settings → Secrets and variables → Actions

---

# CI/CD Best Practices

- Never expose secrets publicly
- Use GitHub Secrets
- Use separate production/staging branches
- Test before deploying
- Use automated builds
- Monitor deployment logs
- Keep workflows simple initially

---

# Production Deployment Workflow

Recommended flow:

1. Develop locally
2. Commit changes
3. Push to GitHub
4. GitHub Actions runs
5. Build/test application
6. Deploy to VPS
7. Restart services
8. Monitor logs

---

# Common Git Issues

## Authentication Failed

Possible reasons:

- wrong SSH key
- SSH key not added to GitHub
- wrong remote URL

---

## Merge Conflict

Happens when:

- same file edited in multiple places

Fix manually before commit.

---

## Detached HEAD

Check branch:

```bash
git branch
```

---

# Common CI/CD Issues

## Workflow Not Running

Check:

- workflow location
- YAML syntax
- branch trigger

---

## SSH Deployment Failed

Check:

- VPS IP
- SSH key
- firewall
- user permissions

---

## Build Failed

Check:

- missing dependencies
- environment variables
- package versions

---

# Recommended Git Workflow

1. Initialize Git repository
2. Configure GitHub SSH authentication
3. Create GitHub repository
4. Connect remote repository
5. Push project
6. Configure .gitignore
7. Setup GitHub Actions
8. Configure deployment secrets
9. Automate deployments
10. Monitor deployment logs