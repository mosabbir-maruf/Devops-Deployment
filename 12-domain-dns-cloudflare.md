# Domain, DNS & Cloudflare

## Table Of Contents

### Fundamentals

1. [What Is A Domain](#1-what-is-a-domain)
2. [DNS In Production](#2-dns-in-production)
3. [Production Architecture](#3-production-architecture)
4. [Production DNS Structure](#4-production-dns-structure)
5. [Cloudflare In The Production Stack](#5-cloudflare-in-the-production-stack)

### Setup

6. [Buy A Domain](#6-buy-a-domain)
7. [Add Domain To Cloudflare](#7-add-domain-to-cloudflare)
8. [Update Nameservers](#8-update-nameservers)
9. [Verify Domain Setup](#9-verify-domain-setup)

### Installation

10. [Install DNS Tools On Linux](#10-install-dns-tools-on-linux)
11. [Install DNS Tools On Mac](#11-install-dns-tools-on-mac)
12. [Verify DNS Tools Installation](#12-verify-dns-tools-installation)

### Configuration

13. [DNS Records (Production)](#13-dns-records-production)
14. [Cloudflare Proxy (Orange vs Gray Cloud)](#14-cloudflare-proxy-orange-vs-gray-cloud)
15. [SSL TLS Configuration](#15-ssl-tls-configuration)
16. [Cloudflare Origin Certificate](#16-cloudflare-origin-certificate)
17. [Multiple Subdomains And Apps](#17-multiple-subdomains-and-apps)
18. [Email DNS Records (Optional)](#18-email-dns-records-optional)

### Development Workflow

19. [Local Development With Domains](#19-local-development-with-domains)
20. [Staging Subdomain Setup](#20-staging-subdomain-setup)
21. [Development Best Practices](#21-development-best-practices)

### Production Workflow

22. [Full Domain Setup Workflow](#22-full-domain-setup-workflow)
23. [Cloudflare With Nginx And Docker](#23-cloudflare-with-nginx-and-docker)
24. [Cloudflare With Coolify](#24-cloudflare-with-coolify)
25. [HTTPS And Redirect Configuration](#25-https-and-redirect-configuration)
26. [Production DNS Checklist](#26-production-dns-checklist)

### Security Best Practices

27. [Cloudflare Security Features](#27-cloudflare-security-features)
28. [Hide VPS IP](#28-hide-vps-ip)
29. [WAF And Rate Limiting](#29-waf-and-rate-limiting)
30. [Security Checklist](#30-security-checklist)

### Monitoring And Logging

31. [DNS Propagation Monitoring](#31-dns-propagation-monitoring)
32. [Cloudflare Analytics](#32-cloudflare-analytics)
33. [SSL Verification](#33-ssl-verification)
34. [Health Checks](#34-health-checks)
35. [Debugging DNS And SSL](#35-debugging-dns-and-ssl)

### Backup And Restore

36. [Backup DNS Configuration](#36-backup-dns-configuration)
37. [Export And Restore DNS Records](#37-export-and-restore-dns-records)
38. [Recovery Workflow](#38-recovery-workflow)

### Troubleshooting

39. [Domain Not Resolving](#39-domain-not-resolving)
40. [HTTPS Not Working](#40-https-not-working)
41. [Cloudflare 521 And 522 Errors](#41-cloudflare-521-and-522-errors)
42. [SSL Certificate Errors](#42-ssl-certificate-errors)
43. [DNS Propagation Issues](#43-dns-propagation-issues)
44. [Wrong IP Or NXDOMAIN](#44-wrong-ip-or-nxdomain)

### Cleanup And Uninstall

45. [Remove DNS Records](#45-remove-dns-records)
46. [Remove Domain From Cloudflare](#46-remove-domain-from-cloudflare)
47. [Revert Nameservers](#47-revert-nameservers)
48. [Clean Up On Mac And Linux](#48-clean-up-on-mac-and-linux)
49. [Log And Cache Cleanup](#49-log-and-cache-cleanup)
50. [Verification After Removal](#50-verification-after-removal)

### Production Workflows

51. [Recommended Production Workflow](#51-recommended-production-workflow)
52. [Modern Workflow](#52-modern-workflow)
53. [Real-World Workflow](#53-real-world-workflow)
54. [Final Production Checklist](#54-final-production-checklist)

---

# 1. What Is A Domain

A domain is the public address users type to reach your application.

Production examples:

```txt
yourdomain.com           → main site / frontend
api.yourdomain.com       → backend API
staging.yourdomain.com   → staging environment
coolify.yourdomain.com   → Coolify dashboard
```

Domains are managed via a registrar and DNS is typically managed by **Cloudflare** in production.

---

# 2. DNS In Production

DNS maps domain names to your VPS IP address.

```txt
yourdomain.com  →  A record  → 203.0.113.10 (VPS IP)
api.yourdomain.com → A record → 203.0.113.10
```

Cloudflare sits between users and your VPS:

```txt
User types yourdomain.com
↓
DNS resolves (Cloudflare)
↓
Cloudflare proxy (CDN + WAF + SSL)
↓
Your VPS (Nginx :443)
↓
Docker containers
```

SSH and database ports never go through Cloudflare — HTTP/HTTPS only.

---

# 3. Production Architecture

```txt
User
↓
Cloudflare (DNS + SSL + WAF + CDN)
↓
Nginx (:443 on VPS)
↓
Frontend Container (:3000 internal)
↓
Backend Container (:5000 internal)
↓
PostgreSQL + Redis (internal only)
```

DNS layer:

```txt
yourdomain.com      → Cloudflare → VPS → Nginx → frontend
api.yourdomain.com  → Cloudflare → VPS → Nginx → backend
```

Admin access (not via domain):

```txt
Developer → SSH (custom port) → VPS
```

---

# 4. Production DNS Structure

## Typical SaaS Setup

```txt
Type    Name       Content          Proxy
A       @          YOUR_VPS_IP      Proxied (orange)
A       www        YOUR_VPS_IP      Proxied
A       api        YOUR_VPS_IP      Proxied
A       staging    STAGING_VPS_IP   Proxied
A       coolify    YOUR_VPS_IP      DNS only (grey) — or restrict access
TXT     @          SPF/DKIM         DNS only — if email configured
```

## Multi-App VPS

```txt
app1.yourdomain.com   → VPS IP → Nginx → app1 container
app2.yourdomain.com   → VPS IP → Nginx → app2 container
api.yourdomain.com    → VPS IP → Nginx → backend
```

All subdomains can share one VPS IP — Nginx routes by `server_name`.

---

# 5. Cloudflare In The Production Stack

Cloudflare provides:

| Feature | Production Use |
|---------|----------------|
| DNS | Manage all records |
| SSL | HTTPS for users |
| CDN | Cache static assets |
| WAF | Block malicious requests |
| DDoS | Automatic protection |
| Analytics | Traffic monitoring |

Free plan is sufficient for most personal and SaaS projects.

✓ Good:

* Cloudflare for all public web traffic
* Full (strict) SSL mode

✗ Avoid:

* Flexible SSL (HTTP to origin)
* exposing VPS IP unnecessarily
* proxying SSH or database ports

---

# 6. Buy A Domain

Recommended registrars:

| Registrar | Notes |
|-----------|-------|
| Cloudflare Registrar | At-cost pricing, easy integration |
| Namecheap | Popular, affordable |
| Porkbun | Clean UI, good pricing |

## Purchase Checklist

```txt
✓ Choose .com or relevant TLD
✓ Enable domain privacy (WHOIS protection)
✓ Auto-renew enabled
✓ 2FA on registrar account
```

Example: register `myapp.com` for your SaaS product.

---

# 7. Add Domain To Cloudflare

## Steps

```txt
1. cloudflare.com → Sign up / Log in
2. Add a Site → enter yourdomain.com
3. Select Free plan
4. Cloudflare scans existing DNS records
5. Copy assigned nameservers:
   ada.ns.cloudflare.com
   bob.ns.cloudflare.com
```

## Enable 2FA

```txt
Cloudflare → My Profile → Authentication → Two-Factor Authentication
```

Required for production accounts.

---

# 8. Update Nameservers

At your domain registrar (Namecheap, etc.):

```txt
Domain → Nameservers → Custom DNS
Replace with Cloudflare nameservers
Save
```

Cloudflare dashboard shows **Active** when nameservers propagate (minutes to 48 hours).

## Verify Nameservers

```bash
dig NS yourdomain.com +short
```

Expected: Cloudflare nameserver hostnames.

---

# 9. Verify Domain Setup

```bash
# Cloudflare dashboard shows "Active"
dig NS yourdomain.com +short
dig yourdomain.com +short
curl ifconfig.me    # compare with A record target
```

Cloudflare → DNS → Records should show imported or manually added records.

---

# 10. Install DNS Tools On Linux

## Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y dnsutils curl
```

## Verify

```bash
dig -v
nslookup -version
curl --version
```

---

# 11. Install DNS Tools On Mac

Built-in on macOS:

```bash
dig -v
nslookup
curl --version
```

Optional:

```bash
brew install bind    # latest dig
brew install httpie  # API testing
```

---

# 12. Verify DNS Tools Installation

## Linux

```bash
dig yourdomain.com +short
nslookup yourdomain.com
curl -I https://yourdomain.com
```

## Mac

```bash
dig api.yourdomain.com +short
curl -I https://yourdomain.com
```

---

# 13. DNS Records (Production)

## A Record — Root Domain

```txt
Type:    A
Name:    @
Content: YOUR_VPS_IP
Proxy:   Proxied (orange cloud)
TTL:     Auto
```

## A Record — API Subdomain

```txt
Type:    A
Name:    api
Content: YOUR_VPS_IP
Proxy:   Proxied
```

## CNAME — WWW

```txt
Type:    CNAME
Name:    www
Target:  yourdomain.com
Proxy:   Proxied
```

## Get VPS Public IP

```bash
ssh vps-prod
curl -4 ifconfig.me
curl -4 icanhazip.com
```

## Record Types Reference

```txt
A       → IPv4 address (most common)
AAAA    → IPv6 address
CNAME   → alias to another domain
TXT     → verification, SPF, DKIM
MX      → email mail servers
```

---

# 14. Cloudflare Proxy (Orange vs Gray Cloud)

## Orange Cloud — Proxied (Recommended For Web)

```txt
User → Cloudflare CDN/WAF → Your VPS
```

Benefits:

* hides VPS IP
* DDoS protection
* CDN caching
* SSL at edge

Use for: `yourdomain.com`, `api.yourdomain.com`, `www`

## Gray Cloud — DNS Only

```txt
User → directly to VPS IP
```

Use for:

* initial SSL certificate setup (Let's Encrypt HTTP challenge)
* `coolify.yourdomain.com` during first setup (optional)
* MX/TXT email records (always DNS only)

✓ Good:

* orange cloud for all public web/API traffic

✗ Avoid:

* orange cloud for SSH, PostgreSQL, Redis, MongoDB

---

# 15. SSL TLS Configuration

## Cloudflare SSL Modes

| Mode | User → CF | CF → Origin | Production |
|------|-----------|-------------|------------|
| Off | HTTP | HTTP | ✗ Never |
| Flexible | HTTPS | HTTP | ✗ Never |
| Full | HTTPS | HTTPS (any cert) | △ Acceptable |
| Full (strict) | HTTPS | HTTPS (valid cert) | ✓ Recommended |

## Set Full (Strict)

```txt
Cloudflare → SSL/TLS → Overview → Full (strict)
```

## Always Use HTTPS

```txt
SSL/TLS → Edge Certificates → Always Use HTTPS → On
```

## Minimum TLS Version

```txt
SSL/TLS → Edge Certificates → Minimum TLS Version → TLS 1.2
```

## Verify

```bash
curl -I https://yourdomain.com
curl -I http://yourdomain.com    # should redirect to HTTPS
```

---

# 16. Cloudflare Origin Certificate

For Full (strict) mode, install a Cloudflare Origin Certificate on Nginx.

## Generate Certificate

```txt
Cloudflare → SSL/TLS → Origin Server → Create Certificate
→ Let Cloudflare generate a private key and CSR
→ Hostnames: yourdomain.com, *.yourdomain.com
→ Validity: 15 years
→ Create
```

Save:

```txt
Origin Certificate  → cert.pem
Private Key         → key.pem
```

## Install On VPS

```bash
ssh vps-prod
mkdir -p /var/www/myapp/nginx/ssl
nano /var/www/myapp/nginx/ssl/cert.pem    # paste certificate
nano /var/www/myapp/nginx/ssl/key.pem     # paste private key
chmod 600 /var/www/myapp/nginx/ssl/key.pem
```

## Nginx Config

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate     /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://frontend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Mount in Docker Compose:

```yaml
nginx:
  volumes:
    - ./nginx/ssl:/etc/nginx/ssl:ro
```

See `11-nginx-reverse-proxy.md` for full Nginx SSL setup.

---

# 17. Multiple Subdomains And Apps

One VPS, multiple apps via Nginx `server_name`:

```nginx
# yourdomain.com → frontend
server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    location / { proxy_pass http://frontend:3000; }
}

# api.yourdomain.com → backend
server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    location / { proxy_pass http://backend:5000; }
}
```

DNS records (all same VPS IP):

```txt
A  @      YOUR_VPS_IP  Proxied
A  api    YOUR_VPS_IP  Proxied
A  www    YOUR_VPS_IP  Proxied
```

Coolify/Traefik handles routing automatically if using Coolify.

---

# 18. Email DNS Records (Optional)

If sending email from your domain (not required for web apps):

```txt
Type: MX    Name: @    Mail server: mail.provider.com
Type: TXT   Name: @    Content: v=spf1 include:provider.com ~all
Type: TXT   Name: _dmarc   Content: v=DMARC1; p=none
```

Email records are always **DNS only** (grey cloud) — never proxied.

---

# 19. Local Development With Domains

Local dev uses `localhost` — not production domain.

```bash
# Mac local dev
curl http://localhost:3000
curl http://localhost:5000/health
```

Optional `/etc/hosts` override for local subdomain testing:

```txt
127.0.0.1  local.myapp.dev
```

```bash
# Mac
sudo nano /etc/hosts
```

Never point production domain A records to `127.0.0.1`.

---

# 20. Staging Subdomain Setup

```txt
Type: A   Name: staging   Content: STAGING_VPS_IP   Proxy: Proxied
```

Workflow:

```txt
Feature branch → deploy to staging.yourdomain.com
Test → merge to main → deploy to yourdomain.com
```

Separate VPS or same VPS with different Nginx `server_name` and compose stack.

---

# 21. Development Best Practices

✓ Good:

* staging subdomain for pre-production testing
* grey cloud during initial cert setup, then orange
* document all DNS records

✗ Avoid:

* testing breaking DNS changes on production domain first
* sharing Cloudflare account without 2FA

---

# 22. Full Domain Setup Workflow

```txt
1. Buy domain
2. Add to Cloudflare (Free plan)
3. Update registrar nameservers
4. Wait for Active status
5. Add A records (@, www, api) → VPS IP, Proxied
6. Set SSL → Full (strict)
7. Enable Always Use HTTPS
8. Create Origin Certificate → install on Nginx
9. Configure Nginx server_name blocks
10. docker compose up -d
11. Verify: curl -I https://yourdomain.com
12. Enable WAF and rate limiting
```

---

# 23. Cloudflare With Nginx And Docker

```txt
User
↓
Cloudflare (SSL termination at edge + origin cert to Nginx)
↓
Nginx container (:443)
↓
frontend / backend containers
```

## UFW On VPS

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
# Do NOT expose 5000, 3000, 5432, 6379 publicly
```

## Allow Cloudflare IPs (Optional Hardening)

Restrict Nginx to Cloudflare IP ranges — see Cloudflare IP list documentation for advanced setups.

---

# 24. Cloudflare With Coolify

Coolify uses Traefik for routing and automatic SSL.

```txt
User → Cloudflare → Traefik (Coolify) → App containers
```

DNS:

```txt
A  app     YOUR_VPS_IP  Proxied
A  api     YOUR_VPS_IP  Proxied
A  coolify YOUR_VPS_IP  DNS only (restrict port 8000 after setup)
```

SSL: Coolify auto-provisions Let's Encrypt — set Cloudflare to **Full (strict)**.

See `05-coolify.md`.

---

# 25. HTTPS And Redirect Configuration

## Cloudflare Level

```txt
SSL/TLS → Edge Certificates:
  ✓ Always Use HTTPS
  ✓ Automatic HTTPS Rewrites
  ✓ Minimum TLS 1.2
```

## Nginx Level

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$host$request_uri;
}
```

## Verify Full Chain

```bash
curl -I http://yourdomain.com     # 301 → HTTPS
curl -I https://yourdomain.com    # 200
curl -I https://api.yourdomain.com/health
```

---

# 26. Production DNS Checklist

```txt
✓ Domain on Cloudflare with Active status
✓ A records point to correct VPS IP
✓ Orange cloud enabled for web/API
✓ SSL Full (strict)
✓ Always Use HTTPS enabled
✓ Origin certificate on Nginx
✓ Nginx server_name matches domains
✓ curl -I https://yourdomain.com returns 200
```

---

# 27. Cloudflare Security Features

## Enable On Free Plan

```txt
Security → Settings:
  ✓ Security Level: Medium
  ✓ Bot Fight Mode: On (if available)
  ✓ Browser Integrity Check: On
```

## Under Attack Mode

Enable temporarily during DDoS:

```txt
Overview → Under Attack Mode → Enable
```

## 2FA On Account

```txt
My Profile → Authentication → 2FA → Enable
```

---

# 28. Hide VPS IP

Orange cloud proxy hides your VPS IP from public DNS lookups.

## Verify IP Hidden

```bash
dig yourdomain.com +short
# Returns Cloudflare proxy IP, not your VPS IP
```

## Prevent IP Leak

```txt
✓ Orange cloud on all web records
✓ Do not expose VPS IP in public GitHub issues/docs
✓ Block direct IP access in Nginx (see 11-nginx-reverse-proxy.md)
✗ Do not send emails revealing origin IP in headers
```

---

# 29. WAF And Rate Limiting

## WAF Managed Rules (Pro plan) / Free Bot Protection

```txt
Security → WAF → Managed rules
```

## Rate Limiting (Free — limited rules)

```txt
Security → WAF → Rate limiting rules
→ Create rule: /api/auth/* → 10 requests/minute per IP
```

Protects login and auth endpoints from brute force.

---

# 30. Security Checklist

✓ Good:

* Cloudflare 2FA enabled
* Full (strict) SSL
* orange cloud for web traffic
* WAF / bot protection enabled
* VPS IP not publicly exposed
* rate limiting on auth endpoints

✗ Avoid:

* Flexible SSL
* grey cloud on production API without reason
* shared Cloudflare account without 2FA

---

# 31. DNS Propagation Monitoring

Propagation time: **5 minutes to 48 hours** (usually under 30 minutes).

## Check Propagation

```bash
dig yourdomain.com +short
dig @1.1.1.1 yourdomain.com +short
dig @8.8.8.8 yourdomain.com +short
nslookup yourdomain.com
```

Online: [dnschecker.org](https://dnschecker.org)

## Monitor Until Active

```bash
watch -n 30 'dig yourdomain.com +short'
```

---

# 32. Cloudflare Analytics

```txt
Cloudflare → Analytics & Logs → Traffic
```

Monitor:

* requests per day
* bandwidth
* threat events blocked
* 4xx/5xx error rates
* top countries

Set up email alerts for unusual traffic spikes.

---

# 33. SSL Verification

```bash
curl -vI https://yourdomain.com 2>&1 | grep -i ssl
curl -vI https://api.yourdomain.com 2>&1 | grep -i "subject\|issuer"
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com < /dev/null 2>/dev/null | openssl x509 -noout -dates
```

Online: [ssllabs.com/ssltest](https://www.ssllabs.com/ssltest/)

Expected: valid certificate, TLS 1.2+, HTTPS redirect working.

---

# 34. Health Checks

After DNS + SSL setup:

```bash
curl -f https://yourdomain.com
curl -f https://api.yourdomain.com/health
curl -I https://yourdomain.com
```

Automated check script:

```bash
#!/bin/bash
DOMAINS=("yourdomain.com" "api.yourdomain.com")
for d in "${DOMAINS[@]}"; do
  curl -sf "https://$d" > /dev/null && echo "OK: $d" || echo "FAIL: $d"
done
```

---

# 35. Debugging DNS And SSL

## DNS Debug

```bash
dig yourdomain.com ANY
dig api.yourdomain.com +trace
host yourdomain.com
```

## SSL Debug

```bash
curl -vI https://yourdomain.com 2>&1 | head -30
docker compose logs nginx --tail=30
```

## Cloudflare Debug

```txt
Cloudflare → DNS → verify records
Cloudflare → SSL/TLS → verify mode Full (strict)
Cloudflare → Overview → check site status Active
```

---

# 36. Backup DNS Configuration

## Export DNS Records

```txt
Cloudflare → DNS → Export (if available)
Or manually document all records in repo:
  docs/dns-records.md
```

## Document In Git (No Secrets)

```markdown
# docs/dns-records.md
| Type | Name | Content        | Proxy   |
|------|------|----------------|---------|
| A    | @    | YOUR_VPS_IP    | Proxied |
| A    | api  | YOUR_VPS_IP    | Proxied |
| CNAME| www  | yourdomain.com | Proxied |
```

## Backup Origin Certificate

```bash
scp vps-prod:/var/www/myapp/nginx/ssl/ ./backups/ssl/
# Store encrypted — contains private key
```

---

# 37. Export And Restore DNS Records

## Restore Records After Accidental Delete

Re-add manually in Cloudflare dashboard using backed-up `docs/dns-records.md`.

## Bulk Import (Cloudflare API — Advanced)

```bash
# Document records, re-create via dashboard for most users
# API: POST /zones/{zone_id}/dns_records
```

## Restore Origin Certificate

```bash
scp ./backups/ssl/cert.pem vps-prod:/var/www/myapp/nginx/ssl/
scp ./backups/ssl/key.pem vps-prod:/var/www/myapp/nginx/ssl/
ssh vps-prod "chmod 600 /var/www/myapp/nginx/ssl/key.pem"
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
```

---

# 38. Recovery Workflow

Domain hijacked or DNS corrupted:

```txt
1. Log into Cloudflare immediately
2. Enable 2FA if not already
3. Review DNS records for unauthorized changes
4. Restore correct A records from backup docs
5. Revoke compromised API tokens
6. Rotate Origin Certificate if key.pem exposed
7. Verify SSL and site access
8. Check Cloudflare audit log for changes
```

VPS IP changed:

```txt
1. Update all A records to new IP
2. Wait for propagation
3. Verify curl -I https://yourdomain.com
```

---

# 39. Domain Not Resolving

## Checklist

```bash
dig NS yourdomain.com +short       # Cloudflare NS?
dig yourdomain.com +short          # correct IP?
curl ifconfig.me                   # VPS IP matches A record?
```

Fixes:

* nameservers not updated at registrar
* A record missing or wrong IP
* propagation still in progress
* domain expired — renew at registrar

---

# 40. HTTPS Not Working

## Checklist

```txt
✓ Cloudflare SSL mode: Full (strict)
✓ Origin certificate installed on Nginx
✓ Nginx listening on 443
✓ UFW allows 443
✓ Always Use HTTPS enabled
```

```bash
curl -vI https://yourdomain.com
docker compose exec nginx nginx -t
sudo ufw status | grep 443
```

---

# 41. Cloudflare 521 And 522 Errors

## Error 521 — Web Server Is Down

Cloudflare cannot connect to origin.

```bash
ssh vps-prod
docker compose ps
sudo ufw status
curl -I http://localhost
```

Fix: start Nginx/containers, open port 443 in UFW.

## Error 522 — Connection Timed Out

Origin not responding in time.

```bash
docker compose logs nginx --tail=30
docker stats --no-stream
free -h
```

Fix: restart stack, check VPS online, verify firewall.

## Error 525 — SSL Handshake Failed

Origin SSL misconfigured.

Fix: install Origin Certificate, set Full (strict), verify Nginx SSL config.

---

# 42. SSL Certificate Errors

## Browser: "Your connection is not private"

```bash
curl -vI https://yourdomain.com 2>&1 | grep -i cert
docker compose exec nginx nginx -t
ls -la /var/www/myapp/nginx/ssl/
```

Fixes:

* expired origin cert → regenerate in Cloudflare
* wrong cert path in Nginx config
* Cloudflare set to Full (strict) but no cert on origin

---

# 43. DNS Propagation Issues

```bash
dig yourdomain.com +short
dig @1.1.1.1 yourdomain.com +short
dig @8.8.8.8 yourdomain.com +short
```

If results differ: propagation in progress — wait up to 48 hours.

Force refresh local DNS cache:

```bash
# Mac
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Linux
sudo systemd-resolve --flush-caches
```

---

# 44. Wrong IP Or NXDOMAIN

## NXDOMAIN — Domain Does Not Exist

```bash
dig yourdomain.com
# status: NXDOMAIN
```

Fix: nameservers not pointing to Cloudflare, or domain not registered.

## Wrong IP Returned

```bash
dig yourdomain.com +short
# Returns old/wrong IP
```

Fix: update A record in Cloudflare, reduce TTL, wait for propagation.

---

# 45. Remove DNS Records

Before decommissioning:

```txt
Cloudflare → DNS → Records → Delete each record:
  @ , www , api , staging , coolify
```

Document what was removed in `docs/dns-records.md`.

---

# 46. Remove Domain From Cloudflare

```txt
Cloudflare → yourdomain.com → Overview
→ Advanced Actions → Remove Site from Cloudflare
```

Warning: removes all DNS, SSL, and WAF configuration for the domain.

Backup records first (section 36).

---

# 47. Revert Nameservers

At domain registrar, change nameservers back from Cloudflare to registrar defaults (or new DNS provider).

```txt
Registrar → Domain → Nameservers → Default / Custom
```

Allow 24–48 hours for propagation.

---

# 48. Clean Up On Mac And Linux

## VPS — Remove SSL Certs

```bash
ssh vps-prod
rm -rf /var/www/myapp/nginx/ssl/
docker compose down nginx
```

## Mac — Remove /etc/hosts Entries

```bash
sudo nano /etc/hosts
# Remove: 127.0.0.1 local.myapp.dev
```

## Mac — Clear DNS Cache

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

## Linux — Clear DNS Cache

```bash
sudo systemd-resolve --flush-caches
```

---

# 49. Log And Cache Cleanup

## Cloudflare

No local logs — audit via Cloudflare dashboard → Audit Log.

## VPS Nginx Logs

```bash
docker compose logs nginx > ~/logs/nginx-final.log 2>&1
docker compose down
```

## Local Debug Files

```bash
rm -f ~/logs/dns-check-*.log
rm -rf ./backups/ssl/   # after encrypted backup elsewhere
```

---

# 50. Verification After Removal

```bash
dig yourdomain.com +short          # no longer points to your VPS (or NXDOMAIN)
curl -I https://yourdomain.com     # should fail or show different site
```

Cloudflare dashboard: domain removed or DNS records empty.

VPS:

```bash
ls /var/www/myapp/nginx/ssl/ 2>&1
docker compose ps nginx
```

## Cleanup Checklist

✓ Good:

* DNS records backed up before deletion
* origin cert removed from VPS
* nameservers reverted if leaving Cloudflare
* domain renewal decision made (keep or let expire)

---

# 51. Recommended Production Workflow

```txt
1. Buy domain → add to Cloudflare
2. Update nameservers → wait for Active
3. Add A records (@, api, www) → VPS IP, Proxied
4. SSL Full (strict) + Always Use HTTPS
5. Origin Certificate → Nginx
6. Deploy Docker Compose stack
7. Verify HTTPS on all subdomains
8. Enable WAF + rate limiting
9. Document DNS records in Git
10. Monitor Cloudflare analytics weekly
```

---

# 52. Modern Workflow

```txt
Developer (Mac)
↓
GitHub Push
↓
GitHub Actions → Docker Hub
↓
SSH → VPS → docker compose up -d
↓
Nginx (:443 + origin cert)
↓
Cloudflare (DNS + SSL + WAF)
↓
Users at https://yourdomain.com
```

---

# 53. Real-World Workflow

Example: SaaS on Hetzner with Cloudflare.

## Day 1 — Domain

```txt
Buy myapp.com → Cloudflare → update NS → Active
A @ → 203.0.113.10 Proxied
A api → 203.0.113.10 Proxied
SSL Full (strict)
```

## Day 2 — Origin SSL + Deploy

```bash
# Generate origin cert in Cloudflare
scp ssl/* vps-prod:/var/www/myapp/nginx/ssl/
ssh vps-prod "cd /var/www/myapp && docker compose up -d"
curl -I https://myapp.com
curl -I https://api.myapp.com/health
```

## Ongoing

```txt
Monitor Cloudflare analytics
Renew domain annually
Rotate origin cert before expiry (15-year cert — set calendar reminder)
```

---

# 54. Final Production Checklist

## Domain And DNS

✓ Domain registered with auto-renew
✓ Cloudflare Active, 2FA enabled
✓ A records correct, Proxied
✓ DNS documented in Git

## SSL

✓ Full (strict) mode
✓ Always Use HTTPS
✓ Origin certificate on Nginx
✓ TLS 1.2 minimum

## Security

✓ VPS IP hidden (orange cloud)
✓ WAF / bot protection enabled
✓ rate limiting on auth endpoints
✓ direct IP access blocked in Nginx

## Verified

```bash
curl -I https://yourdomain.com
curl -f https://api.yourdomain.com/health
dig yourdomain.com +short
```

## Full Stack

```txt
User → Cloudflare → Nginx → Docker → Users
```

---

## Domain & Cloudflare Quick Commands Cheat Sheet

```bash
# VPS IP
curl -4 ifconfig.me

# DNS check
dig yourdomain.com +short
dig api.yourdomain.com +short
dig NS yourdomain.com +short
nslookup yourdomain.com

# HTTPS check
curl -I https://yourdomain.com
curl -I http://yourdomain.com
curl -f https://api.yourdomain.com/health

# SSL details
curl -vI https://yourdomain.com 2>&1 | grep -i ssl

# Propagation
dig @1.1.1.1 yourdomain.com +short
dig @8.8.8.8 yourdomain.com +short

# Mac DNS cache flush
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

# Cleanup VPS SSL
rm -rf /var/www/myapp/nginx/ssl/
```
