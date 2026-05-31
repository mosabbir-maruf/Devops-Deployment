# Git, GitHub & CI/CD

## Table Of Contents

### Fundamentals

1. [What Is Git](#1-what-is-git)
2. [GitHub In Production](#2-github-in-production)
3. [Production CI/CD Architecture](#3-production-cicd-architecture)
4. [Production Repository Structure](#4-production-repository-structure)
5. [Git Workflow Overview](#5-git-workflow-overview)

### Installation

6. [Install Git On Mac](#6-install-git-on-mac)
7. [Install Git On Linux](#7-install-git-on-linux)
8. [Install Git In Docker (CI)](#8-install-git-in-docker-ci)
9. [Verify Git Installation](#9-verify-git-installation)

### Configuration

10. [Configure Git Identity](#10-configure-git-identity)
11. [GitHub SSH Authentication](#11-github-ssh-authentication)
12. [Verified Commits (SSH Signing)](#12-verified-commits-ssh-signing)
13. [GitHub Repository Setup](#13-github-repository-setup)
14. [Branch Strategy](#14-branch-strategy)
15. [gitignore And Secrets](#15-gitignore-and-secrets)

### Development Workflow

16. [Daily Git Workflow](#16-daily-git-workflow)
17. [Branches And Pull Requests](#17-branches-and-pull-requests)
18. [Git Tags And Releases](#18-git-tags-and-releases)
19. [Development Best Practices](#19-development-best-practices)

### Production Workflow

20. [GitHub Actions Overview](#20-github-actions-overview)
21. [CI Workflow (Test And Build)](#21-ci-workflow-test-and-build)
22. [CD Workflow (Docker Hub Deploy)](#22-cd-workflow-docker-hub-deploy)
23. [SSH Deploy To VPS](#23-ssh-deploy-to-vps)
24. [Full Production Pipeline](#24-full-production-pipeline)
25. [Coolify GitHub Integration](#25-coolify-github-integration)
26. [Production CI/CD Checklist](#26-production-cicd-checklist)

### Security Best Practices

27. [GitHub Security Rules](#27-github-security-rules)
28. [GitHub Secrets Management](#28-github-secrets-management)
29. [Branch Protection](#29-branch-protection)
30. [Security Checklist](#30-security-checklist)

### Monitoring And Logging

31. [GitHub Actions Logs](#31-github-actions-logs)
32. [Deployment Verification](#32-deployment-verification)
33. [Workflow Status Monitoring](#33-workflow-status-monitoring)
34. [Debugging Failed Workflows](#34-debugging-failed-workflows)

### Backup And Restore

35. [Repository Backup Strategy](#35-repository-backup-strategy)
36. [Rollback Via Git](#36-rollback-via-git)
37. [Recovery Workflow](#37-recovery-workflow)

### Troubleshooting

38. [Authentication Failed](#38-authentication-failed)
39. [Merge Conflicts](#39-merge-conflicts)
40. [Workflow Not Running](#40-workflow-not-running)
41. [Build Failed In CI](#41-build-failed-in-ci)
42. [SSH Deploy Failed](#42-ssh-deploy-failed)
43. [Docker Push Failed](#43-docker-push-failed)

### Cleanup And Uninstall

44. [Remove Local Git Repository (Mac / Linux)](#44-remove-local-git-repository-mac--linux)
45. [Remove GitHub Remote And Credentials](#45-remove-github-remote-and-credentials)
46. [Uninstall Git On Mac](#46-uninstall-git-on-mac)
47. [Uninstall Git On Linux](#47-uninstall-git-on-linux)
48. [Remove GitHub Actions Workflows](#48-remove-github-actions-workflows)
49. [Log And Cache Cleanup](#49-log-and-cache-cleanup)
50. [Verification After Removal](#50-verification-after-removal)

### Production Workflows

51. [Recommended Production Workflow](#51-recommended-production-workflow)
52. [Modern Workflow](#52-modern-workflow)
53. [Real-World Workflow](#53-real-world-workflow)
54. [Final Production Checklist](#54-final-production-checklist)

---

# 1. What Is Git

Git is a distributed version control system that tracks code changes, enables collaboration, and powers CI/CD pipelines.

Production use cases:

* source of truth for all application code
* collaboration via branches and pull requests
* trigger automated builds and deployments
* rollback to any previous commit or tag

Every production deployment starts with a Git push to GitHub.

---

# 2. GitHub In Production

GitHub hosts your repository and runs CI/CD via GitHub Actions.

```txt
Local code (Mac)
↓
git push
↓
GitHub (main branch)
↓
GitHub Actions (test → build → deploy)
↓
Docker Hub (images)
↓
VPS (docker compose up -d)
↓
Users
```

GitHub is the single source of truth — never edit production files directly on the VPS.

---

# 3. Production CI/CD Architecture

```txt
Developer (Mac)
↓
git push → GitHub
↓
GitHub Actions
  ├── job: test (npm ci, npm test)
  ├── job: build-push (docker build → Docker Hub)
  └── job: deploy (SSH → docker compose pull/up)
↓
VPS
↓
Docker Compose (frontend, backend, postgres, redis, nginx)
↓
Cloudflare → Nginx → Users
```

Alternative:

```txt
git push → GitHub → Coolify webhook → Docker build on VPS → Users
```

See `05-coolify.md` for Coolify path. **Docker Compose + GitHub Actions** is the recommended primary path.

---

# 4. Production Repository Structure

```txt
myapp/
├── .github/
│   └── workflows/
│       ├── ci.yml           # test on PR
│       └── deploy.yml       # deploy on main push
├── apps/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   └── src/
│   └── backend/
│       ├── Dockerfile
│       ├── .dockerignore
│       └── src/
├── nginx/
│   └── default.conf
├── docker-compose.prod.yml
├── docker-compose.dev.yml
├── .env.example
├── .gitignore
└── README.md
```

Never in Git:

```txt
.env
node_modules/
dist/
*.log
nginx/ssl/key.pem
```

---

# 5. Git Workflow Overview

```txt
main          → production (protected, auto-deploys)
staging       → pre-production testing (optional)
feature/*     → development branches
fix/*         → bug fixes
```

Daily cycle:

```txt
git checkout -b feature/new-api
# develop and test locally
git add . && git commit -m "feat: add endpoint"
git push origin feature/new-api
# open Pull Request → review → merge to main
# GitHub Actions deploys automatically
```

---

# 6. Install Git On Mac

## Xcode Command Line Tools (Built-In)

```bash
git --version
# If not installed:
xcode-select --install
```

## Homebrew (Latest Version)

```bash
brew install git
git --version
```

Expected: `git version 2.x`

---

# 7. Install Git On Linux

## Ubuntu / Debian

```bash
sudo apt update
sudo apt install git -y
git --version
```

## Configure Package Cache Cleanup After Install

```bash
sudo apt autoremove -y
```

---

# 8. Install Git In Docker (CI)

GitHub Actions runners include Git pre-installed. For custom Docker CI images:

```dockerfile
FROM node:24-slim
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
```

Production CI uses GitHub-hosted runners — no local Git install needed on VPS for deploy.

---

# 9. Verify Git Installation

## Mac

```bash
git --version
which git
git config --list
```

## Linux

```bash
git --version
which git
git config --global --list
```

## Test Repository

```bash
mkdir ~/git-test && cd ~/git-test
git init
git status
rm -rf ~/git-test
```

---

# 10. Configure Git Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "123456+username@users.noreply.github.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

Use GitHub noreply email for privacy:

```txt
GitHub → Settings → Emails → Keep my email addresses private
→ Copy: 123456+username@users.noreply.github.com
```

## View Config

```bash
git config --list
git config user.email
```

---

# 11. GitHub SSH Authentication

See `02-ssh-guide.md` for full SSH key guide.

## Generate GitHub Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "github-access"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## macOS Keychain Persistence

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Add to `~/.ssh/config`:

```txt
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
```

## Add Key To GitHub

```bash
pbcopy < ~/.ssh/id_ed25519.pub    # Mac
# Linux: xclip -selection clipboard < ~/.ssh/id_ed25519.pub
```

```txt
GitHub → Settings → SSH and GPG Keys → New SSH Key
Title: MacBook GitHub Access
Key type: Authentication Key
Key: paste public key
```

## Test Connection

```bash
ssh -T git@github.com
```

Expected:

```txt
Hi username! You've successfully authenticated...
```

---

# 12. Verified Commits (SSH Signing)

Cryptographically sign commits to show **Verified** badge on GitHub.

## Add Signing Key To GitHub

```txt
GitHub → Settings → SSH and GPG Keys → New SSH Key
Title: MacBook Signing
Key type: Signing Key
Key: paste same id_ed25519.pub
```

## Configure Git Signing

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

## Verify

```bash
git commit -m "test: verified commit"
git push
```

GitHub shows **Verified** badge next to the commit.

---

# 13. GitHub Repository Setup

## Create Repository

```txt
GitHub → New Repository
Name: myapp
Visibility: Private (recommended for production)
Initialize: no README (if pushing existing project)
```

## Connect Local Project

```bash
cd ~/Projects/myapp
git init
git add .
git commit -m "initial production setup"
git branch -M main
git remote add origin git@github.com:username/myapp.git
git push -u origin main
```

## Verify Remote

```bash
git remote -v
```

Expected:

```txt
origin  git@github.com:username/myapp.git (fetch)
origin  git@github.com:username/myapp.git (push)
```

---

# 14. Branch Strategy

## Production Branches

```txt
main       → auto-deploys to production
staging    → deploys to staging VPS (optional)
feature/*  → no auto-deploy, PR required
```

## Create Feature Branch

```bash
git checkout -b feature/user-auth
git push -u origin feature/user-auth
```

## Merge Via Pull Request

```txt
GitHub → Pull Requests → New PR
feature/user-auth → main
Review → Merge (squash or merge commit)
GitHub Actions deploys on merge to main
```

Protect `main` — see section 29.

---

# 15. gitignore And Secrets

## .gitignore

```txt
# Secrets
.env
.env.local
.env.production
*.pem
*.key

# Dependencies
node_modules/

# Build output
dist/
build/
.next/
coverage/

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml
```

## .env.example (Commit This)

```env
NODE_ENV=production
DATABASE_URL=
REDIS_URL=
JWT_SECRET=
PORT=5000
```

## Verify Before Push

```bash
git status
git diff --cached
# Ensure no .env or secrets staged
```

✓ Good:

* `.env.example` in Git, `.env` excluded
* pre-push habit: check `git status`

✗ Avoid:

* committing `.env`, API keys, private keys
* `git add .` without reviewing staged files

---

# 16. Daily Git Workflow

```bash
# Start of day
git pull origin main

# During development
git checkout -b feature/my-feature
# ... make changes, test locally with Docker Compose ...
git add .
git commit -m "feat: describe change"
git push -u origin feature/my-feature

# After PR merged
git checkout main
git pull origin main
git branch -d feature/my-feature
```

## Commit Message Format

```txt
feat: add user registration endpoint
fix: resolve session expiry bug
chore: update dependencies
docs: update API documentation
ci: fix deploy workflow
```

---

# 17. Branches And Pull Requests

## Open Pull Request

```txt
GitHub → Pull Requests → New Pull Request
base: main ← compare: feature/my-feature
Add description, link issue if applicable
Request review (if team)
Merge when CI passes
```

## Resolve Merge Conflict

```bash
git checkout main
git pull origin main
git checkout feature/my-feature
git merge main
# Fix conflicts in files
git add .
git commit -m "fix: resolve merge conflict"
git push
```

## Delete Branch After Merge

```txt
GitHub → Pull Request → Delete branch
```

```bash
git branch -d feature/my-feature
git push origin --delete feature/my-feature
```

---

# 18. Git Tags And Releases

Tags mark production releases for rollback.

## Create Tag

```bash
git tag -a v1.0.0 -m "Production release v1.0.0"
git push origin v1.0.0
```

## List Tags

```bash
git tag
git show v1.0.0
```

## Rollback To Tag

```bash
git checkout v1.0.0
# Or deploy specific tag in CI:
export TAG=v1.0.0
docker compose up -d
```

Use tags with Docker image tags for reproducible rollbacks.

---

# 19. Development Best Practices

✓ Good:

* small, focused commits
* feature branches + PRs to main
* signed commits
* test locally before push
* `.env.example` always updated when adding env vars

✗ Avoid:

* committing directly to main without review
* large unreviewed commits
* `git push --force` to main
* secrets in commit history

---

# 20. GitHub Actions Overview

Workflow files live in:

```txt
.github/workflows/
```

Triggers:

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

GitHub Actions runs on GitHub-hosted Ubuntu runners — free tier: 2,000 minutes/month for private repos.

---

# 21. CI Workflow (Test And Build)

## .github/workflows/ci.yml

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 24
          cache: npm
          cache-dependency-path: apps/backend/package-lock.json

      - name: Install dependencies
        run: npm ci
        working-directory: apps/backend

      - name: Run tests
        run: npm test
        working-directory: apps/backend

      - name: Build
        run: npm run build
        working-directory: apps/backend
```

Runs on every PR and push — blocks broken code from reaching production.

---

# 22. CD Workflow (Docker Hub Deploy)

## .github/workflows/deploy.yml

```yaml
name: Deploy Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 24
          cache: npm
          cache-dependency-path: apps/backend/package-lock.json
      - run: npm ci
        working-directory: apps/backend
      - run: npm test
        working-directory: apps/backend

  build-push:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - uses: docker/build-push-action@v6
        with:
          context: apps/backend
          push: true
          tags: |
            youruser/myapp-backend:${{ github.sha }}
            youruser/myapp-backend:latest

      - uses: docker/build-push-action@v6
        with:
          context: apps/frontend
          push: true
          tags: |
            youruser/myapp-frontend:${{ github.sha }}
            youruser/myapp-frontend:latest

  deploy:
    needs: build-push
    runs-on: ubuntu-latest
    steps:
      - uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          port: ${{ secrets.SERVER_SSH_PORT }}
          script: |
            cd /var/www/myapp
            export TAG=${{ github.sha }}
            docker compose -f docker-compose.prod.yml pull
            docker compose -f docker-compose.prod.yml up -d --remove-orphans
            docker compose -f docker-compose.prod.yml exec -T backend npx prisma migrate deploy
            docker compose ps
            docker image prune -f
```

✓ Good:

* test before build
* immutable image tagged with commit SHA
* migrate database after deploy

✗ Avoid:

* `git pull && npm install && pm2 restart` on VPS (legacy)
* deploying without tests passing

---

# 23. SSH Deploy To VPS

Uses dedicated deploy key — see `02-ssh-guide.md`.

## Add Deploy Key To VPS

```bash
# On Mac — generate CI key
ssh-keygen -t ed25519 -f ~/.ssh/ci_deploy_ed25519 -C "ci-deploy"

# On VPS — add public key
echo "CI_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## GitHub Secrets

```txt
GitHub → Repository → Settings → Secrets and variables → Actions
```

Required secrets:

```txt
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
SERVER_IP
SERVER_USER
SERVER_SSH_KEY       # private key content (ci_deploy_ed25519)
SERVER_SSH_PORT      # 1182
```

Never commit secrets to the repository.

---

# 24. Full Production Pipeline

```txt
1. Developer pushes to feature branch
2. Opens PR → CI runs tests
3. PR reviewed and merged to main
4. GitHub Actions on main:
   a. Run tests
   b. Build Docker images
   c. Push to Docker Hub (tag: commit SHA + latest)
   d. SSH to VPS
   e. docker compose pull && up -d
   f. Run database migrations
   g. Prune old images
5. Verify: curl https://api.yourdomain.com/health
6. Monitor logs for 15 minutes
```

---

# 25. Coolify GitHub Integration

Alternative to manual GitHub Actions deploy:

```txt
git push → GitHub webhook → Coolify → Docker build → deploy
```

Setup:

```txt
Coolify → Settings → Sources → GitHub App → Authorize
Coolify → New Resource → Application → Select repo → Deploy
```

See `05-coolify.md`. Use when you prefer GUI over writing workflow YAML.

Both approaches are production-valid — choose one per project.

---

# 26. Production CI/CD Checklist

```txt
✓ CI runs tests on every PR
✓ Deploy only on main branch push
✓ Docker images tagged with commit SHA
✓ GitHub Secrets configured (no secrets in repo)
✓ SSH deploy key dedicated (not personal key)
✓ Database migrations run after deploy
✓ Health check verified post-deploy
✓ Rollback tag strategy defined
```

---

# 27. GitHub Security Rules

✓ Good:

* private repository for production apps
* SSH key authentication (not HTTPS password)
* signed commits
* branch protection on main
* GitHub Secrets for all credentials
* 2FA on GitHub account
* dependabot enabled for security updates

✗ Avoid:

* personal access tokens in repository
* shared GitHub accounts
* force push to main
* secrets in workflow YAML plaintext

---

# 28. GitHub Secrets Management

## Repository Secrets

```txt
Settings → Secrets and variables → Actions → New repository secret
```

## Organization Secrets (Teams)

```txt
Organization → Settings → Secrets and variables → Actions
```

## Rotate Secrets

```txt
1. Generate new secret value
2. Update GitHub Secret
3. Re-run deploy workflow
4. Verify app works
5. Revoke old secret/token
```

## Docker Hub Token

```txt
Docker Hub → Account Settings → Security → New Access Token
→ Add as DOCKERHUB_TOKEN secret
```

Never log secrets in workflow output — GitHub auto-masks known secrets.

---

# 29. Branch Protection

```txt
GitHub → Repository → Settings → Branches → Add rule
Branch name pattern: main
```

Enable:

```txt
✓ Require a pull request before merging
✓ Require status checks to pass (CI workflow)
✓ Require branches to be up to date
✓ Do not allow bypassing the above settings
✗ Allow force pushes (keep disabled)
✗ Allow deletions (keep disabled)
```

Prevents accidental direct pushes to production branch.

---

# 30. Security Checklist

```txt
✓ 2FA on GitHub account
✓ SSH keys for auth (not passwords)
✓ Signed commits enabled
✓ .env in .gitignore
✓ branch protection on main
✓ GitHub Secrets for CI/CD credentials
✓ private repository
✓ dependabot security alerts enabled
```

---

# 31. GitHub Actions Logs

View workflow runs:

```txt
GitHub → Actions → Select workflow → Select run → View logs
```

Download logs:

```txt
Run page → ... → Download log archive
```

Re-run failed jobs:

```txt
Run page → Re-run failed jobs
```

---

# 32. Deployment Verification

Add verification step to deploy workflow:

```yaml
- name: Verify deployment
  run: |
    sleep 15
    curl -f https://api.yourdomain.com/health
```

Manual verification after deploy:

```bash
curl -f https://api.yourdomain.com/health
ssh vps-prod "cd /var/www/myapp && docker compose ps"
```

---

# 33. Workflow Status Monitoring

## GitHub Notifications

```txt
GitHub → Settings → Notifications → Actions
Enable email on workflow failures
```

## Status Badge In README

```markdown
![CI](https://github.com/username/myapp/actions/workflows/deploy.yml/badge.svg)
```

## Check From CLI

```bash
gh run list --repo username/myapp
gh run view RUN_ID --log
```

Requires [GitHub CLI](https://cli.github.com/): `brew install gh`

---

# 34. Debugging Failed Workflows

```txt
1. GitHub → Actions → failed run → expand failed step
2. Read error message
3. Reproduce locally:
   npm ci && npm test
   docker build -t test apps/backend
4. Fix code → commit → push (re-triggers workflow)
5. Or: Re-run failed jobs after fix
```

Common log locations:

```txt
test step     → npm test output
build step    → docker build output
deploy step   → SSH script output
```

---

# 35. Repository Backup Strategy

```txt
Layer 1: GitHub (primary — cloud hosted)
Layer 2: Local clone on Mac (git clone)
Layer 3: Docker Hub (built images)
Layer 4: VPS config backup (.env, compose files)
```

GitHub provides repository redundancy — also maintain local clone:

```bash
git clone git@github.com:username/myapp.git ~/Backups/myapp-mirror
```

---

# 36. Rollback Via Git

## Revert Bad Commit

```bash
git revert BAD_COMMIT_SHA
git push origin main
# CI/CD redeploys previous working state
```

## Deploy Specific Tag

```bash
git checkout v1.0.0
export TAG=v1.0.0
# Trigger deploy workflow manually or SSH:
ssh vps-prod "cd /var/www/myapp && export TAG=v1.0.0 && docker compose up -d"
```

## Rollback Docker Image Directly

```bash
ssh vps-prod
cd /var/www/myapp
export TAG=PREVIOUS_SHA
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

See `10-project-deployment.md` for full rollback guide.

---

# 37. Recovery Workflow

## Accidental Force Push To Main

```txt
1. git reflog (find last good commit)
2. git reset --hard GOOD_SHA
3. git push --force-with-lease origin main
   (only if branch protection allows, or via admin)
4. Verify CI/CD redeploys
```

## Lost Local Changes

```bash
git stash list
git stash pop
git reflog
```

## Compromised GitHub Token

```txt
1. Revoke token immediately (GitHub/Docker Hub)
2. Rotate all GitHub Secrets
3. Rotate VPS deploy key
4. Review git log for unauthorized commits
5. Re-deploy from known good SHA
```

---

# 38. Authentication Failed

## Symptoms

```txt
Permission denied (publickey)
fatal: Could not read from remote repository
```

## Fix

```bash
ssh -T git@github.com
ssh-add ~/.ssh/id_ed25519
git remote -v    # should be git@github.com:... not https://
```

Ensure SSH key added to GitHub → Settings → SSH Keys.

See `02-ssh-guide.md` section 44.

---

# 39. Merge Conflicts

```bash
git status                     # shows conflicted files
# Edit files — remove <<<<<<< ======= >>>>>>> markers
git add .
git commit -m "fix: resolve merge conflict"
git push
```

Prevent with frequent `git pull origin main` on feature branches.

---

# 40. Workflow Not Running

Checklist:

```txt
✓ File in .github/workflows/ (not .github/workflow/)
✓ YAML syntax valid (indentation, no tabs)
✓ Branch trigger matches (push to main)
✓ Workflow enabled (Actions tab not disabled)
✓ GitHub Actions enabled for repository
```

Validate YAML:

```bash
# Install actionlint
brew install actionlint
actionlint .github/workflows/deploy.yml
```

---

# 41. Build Failed In CI

Common causes:

```txt
npm ci fails         → lock file out of sync, run npm install locally and commit lock file
npm test fails       → fix tests locally first
docker build fails   → test: docker build -t test apps/backend
missing secret       → add to GitHub Secrets
wrong node version   → match local Node 24
```

```bash
# Reproduce locally
cd apps/backend
npm ci
npm test
npm run build
docker build -t test .
```

---

# 42. SSH Deploy Failed

```bash
# Test SSH manually
ssh -i ~/.ssh/ci_deploy_ed25519 -p 1182 mosabbir@SERVER_IP

# Check GitHub Secret SERVER_SSH_KEY (full private key including headers)
# Check VPS authorized_keys contains matching public key
# Check UFW allows SSH port
# Check docker group membership for deploy user
```

See `02-ssh-guide.md` for full SSH troubleshooting.

---

# 43. Docker Push Failed

```txt
denied: requested access to the resource is denied
```

Fix:

```txt
✓ DOCKERHUB_USERNAME secret correct
✓ DOCKERHUB_TOKEN secret valid (not password)
✓ Image name matches Docker Hub username
✓ Token has Read & Write permissions
```

```bash
docker login
docker push youruser/myapp-backend:test
```

---

# 44. Remove Local Git Repository (Mac / Linux)

Remove Git tracking but keep files:

```bash
cd ~/Projects/myapp
rm -rf .git
```

Remove entire project:

```bash
rm -rf ~/Projects/myapp
```

## Remove Git Credentials From Cache

```bash
# Mac
git credential-osxkeychain erase
# Paste: host=github.com → Enter twice

# Linux
git config --global --unset credential.helper
rm -f ~/.git-credentials
```

---

# 45. Remove GitHub Remote And Credentials

## Remove Remote

```bash
git remote remove origin
git remote -v    # should show nothing
```

## Remove Deploy Key From VPS

```bash
ssh vps-prod
nano ~/.ssh/authorized_keys
# Remove CI deploy key line
```

## Revoke GitHub Secrets

```txt
GitHub → Settings → Secrets → Delete each secret
```

## Revoke SSH Key On GitHub

```txt
GitHub → Settings → SSH and GPG Keys → Delete key
```

## Revoke Docker Hub Token

```txt
Docker Hub → Account Settings → Security → Delete token
```

---

# 46. Uninstall Git On Mac

## Homebrew Install

```bash
brew uninstall git
brew cleanup
```

## Xcode CLI Tools (Do Not Remove Unless Necessary)

Git from Xcode CLI tools cannot be easily removed — Homebrew git takes precedence when installed.

## Remove Git Config

```bash
rm -f ~/.gitconfig
rm -f ~/.gitignore_global
```

## Verify

```bash
which git
git --version 2>&1
```

---

# 47. Uninstall Git On Linux

```bash
sudo apt purge -y git
sudo apt autoremove -y
sudo apt autoclean
rm -f ~/.gitconfig
rm -f ~/.git-credentials
```

## Verify

```bash
which git
git --version 2>&1
dpkg -l | grep git
```

Note: removing git on VPS is unusual — git is not required on VPS for Docker-based deploy.

---

# 48. Remove GitHub Actions Workflows

## Delete Workflow Files

```bash
git rm .github/workflows/deploy.yml
git rm .github/workflows/ci.yml
git commit -m "chore: remove CI/CD workflows"
git push origin main
```

## Disable Actions For Repository

```txt
GitHub → Settings → Actions → General → Disable actions
```

## Clean Up GitHub Secrets

```txt
Settings → Secrets and variables → Actions → Delete all
```

---

# 49. Log And Cache Cleanup

## Local Git Cache

```bash
git gc --prune=now
git remote prune origin
rm -rf .git/objects/pack/*.keep
```

## GitHub Actions Cache

```txt
GitHub → Actions → Caches → Delete caches
```

Or via CLI:

```bash
gh cache list --repo username/myapp
gh cache delete CACHE_ID --repo username/myapp
```

## Remove Stale Branches

```bash
git branch -a
git push origin --delete old-feature-branch
git remote prune origin
git branch -d old-feature-branch
```

## Mac

```bash
rm -rf ~/Library/Caches/com.github.GitHubClient 2>/dev/null
brew cleanup
```

## Linux

```bash
rm -f ~/.git-credentials
rm -f ~/.gitconfig
```

---

# 50. Verification After Removal

## Local (Mac / Linux)

```bash
git remote -v 2>&1
ls .git 2>&1
which git
cat ~/.gitconfig 2>&1
ssh -T git@github.com 2>&1
```

## GitHub

```txt
Repository → Actions → no workflows listed (if deleted)
Settings → Secrets → empty
Settings → SSH Keys → key removed (if revoked)
```

## VPS

```bash
grep "ci-deploy" ~/.ssh/authorized_keys 2>&1
docker compose ps
```

## Cleanup Checklist

✓ Good:

* workflow files removed or disabled
* GitHub Secrets deleted
* deploy key removed from VPS authorized_keys
* Docker Hub token revoked
* local `.git` removed if decommissioning project

---

# 51. Recommended Production Workflow

```txt
1. Configure Git + GitHub SSH key
2. Enable signed commits
3. Create private GitHub repo
4. Add .gitignore and .env.example
5. Write CI workflow (test on PR)
6. Write CD workflow (build → push → SSH deploy)
7. Configure GitHub Secrets
8. Enable branch protection on main
9. Push to main → verify auto-deploy
10. Monitor Actions logs post-deploy
```

---

# 52. Modern Workflow

```txt
Developer (Mac)
↓
git push → GitHub (main)
↓
GitHub Actions
  test → build → push Docker Hub
↓
SSH → VPS
↓
docker compose pull && up -d
↓
Nginx → Cloudflare → Users
```

---

# 53. Real-World Workflow

Example: SaaS with GitHub Actions + Hetzner VPS.

## One-Time Setup

```bash
# Mac
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "github"
ssh-keygen -t ed25519 -f ~/.ssh/ci_deploy_ed25519 -C "ci-deploy"
# Add keys to GitHub + VPS
# Add secrets to GitHub
# Create .github/workflows/deploy.yml
git push origin main
```

## Daily Development

```bash
git checkout -b feature/billing
# develop + test locally
git commit -m "feat: add billing endpoint"
git push origin feature/billing
# Open PR → CI passes → merge
# GitHub Actions auto-deploys to production
curl -f https://api.myapp.com/health
```

## Rollback

```bash
git revert BAD_SHA && git push origin main
# Or: ssh vps-prod "export TAG=GOOD_SHA && docker compose up -d"
```

---

# 54. Final Production Checklist

## Git And GitHub

✓ SSH authentication configured
✓ signed commits enabled
✓ private repository
✓ branch protection on main
✓ `.env` in `.gitignore`

## CI/CD

✓ tests run on every PR
✓ Docker images built and pushed on main
✓ images tagged with commit SHA
✓ SSH deploy to VPS via GitHub Actions
✓ database migrations in deploy script
✓ health check after deploy

## Secrets

✓ all credentials in GitHub Secrets
✓ dedicated CI deploy SSH key
✓ Docker Hub access token (not password)
✓ no secrets in git history

## Full Pipeline

```txt
Developer → GitHub → GitHub Actions → Docker Hub → VPS → Cloudflare → Users
```

✓ Good:

* immutable Docker deploys
* automated testing before production
* rollback via git revert or image tag

✗ Avoid:

* PM2 + git pull deploy (legacy)
* secrets in repository
* force push to main
* skip CI on production deploys

---

## Git & CI/CD Quick Commands Cheat Sheet

```bash
# Setup
git config --global user.name "Name"
git config --global user.email "123456+user@users.noreply.github.com"
ssh -T git@github.com

# Daily
git pull origin main
git checkout -b feature/name
git add . && git commit -m "feat: description"
git push -u origin feature/name

# Tags
git tag -a v1.0.0 -m "release"
git push origin v1.0.0

# Rollback
git revert HEAD
git push origin main

# Debug
git status
git log --oneline -10
git remote -v
actionlint .github/workflows/deploy.yml

# Cleanup
git remote remove origin
rm -rf .git
rm -f ~/.gitconfig
brew uninstall git          # Mac
sudo apt purge -y git       # Linux
```
