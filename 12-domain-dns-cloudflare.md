# Domain, DNS & Cloudflare

## What Is A Domain?

A domain is the public address used to access websites/applications.

Examples:

```txt
example.com
api.example.com
app.example.com
```

---

# What Is DNS?

DNS (Domain Name System) converts domain names into server IP addresses.

Example:

```txt
example.com → 123.123.123.123
```

---

# What Is Cloudflare?

Cloudflare is a CDN, DNS and security platform.

Used for:

- DNS management
- SSL/HTTPS
- DDoS protection
- caching
- WAF (Web Application Firewall)
- proxy protection

---

# Buy A Domain

Popular domain providers:

- Namecheap
- Porkbun
- Cloudflare Registrar
- GoDaddy

---

# Connect Domain To Cloudflare

## Add Site

Inside Cloudflare:

1. Add domain
2. Select free/pro plan
3. Copy Cloudflare nameservers

---

# Update Nameservers

Inside domain provider dashboard:

Replace old nameservers with Cloudflare nameservers.

Example:

```txt
ns1.cloudflare.com
ns2.cloudflare.com
```

---

# DNS Records

## A Record

Points domain/subdomain to VPS IP.

Example:

```txt
Type: A
Name: @
Value: YOUR_SERVER_IP
```

---

## Subdomain Record

Example:

```txt
Type: A
Name: api
Value: YOUR_SERVER_IP
```

Creates:

```txt
api.example.com
```

---

## WWW Record

Example:

```txt
Type: CNAME
Name: www
Target: example.com
```

Creates:

```txt
www.example.com
```

---

# Common DNS Record Types

## A Record

Maps domain → IPv4 address.

---

## AAAA Record

Maps domain → IPv6 address.

---

## CNAME Record

Maps one domain → another domain.

---

## TXT Record

Used for:

- verification
- email security
- SPF/DKIM/DMARC

---

## MX Record

Used for email services.

---

# DNS Propagation

DNS changes may take time.

Usually:

```txt
5 minutes → 24 hours
```

---

# Check DNS Propagation

Useful tools:

- dnschecker.org
- dig command
- nslookup command

---

# Check DNS Using dig

## Install dig

```bash
sudo apt install dnsutils -y
```

---

## Check Domain IP

```bash
dig example.com
```

Displays DNS information.

---

# Check DNS Using nslookup

```bash
nslookup example.com
```

Displays DNS resolution.

---

# Cloudflare Proxy

## Orange Cloud

```txt
Proxied
```

Enables:

- Cloudflare CDN
- DDoS protection
- IP hiding
- caching

---

## Gray Cloud

```txt
DNS Only
```

Disables Cloudflare proxy.

---

# Recommended Proxy Usage

Use proxy for:

- websites
- APIs
- frontend apps

Avoid proxy for:

- SSH
- database ports
- internal services

---

# SSL / HTTPS

## What Is HTTPS?

HTTPS encrypts traffic between users and server.

Required for:

- security
- SEO
- browser trust
- production applications

---

# Cloudflare SSL Modes

## Flexible

Cloudflare HTTPS → server HTTP.

Not recommended for production.

---

## Full

Cloudflare HTTPS → server HTTPS.

Recommended.

---

## Full (Strict)

Uses valid SSL certificate on server.

Best production option.

---

# Recommended SSL Mode

Use:

```txt
Full (Strict)
```

---

# Automatic HTTPS Redirect

Inside Cloudflare:

```txt
SSL/TLS → Edge Certificates → Always Use HTTPS
```

Automatically redirects HTTP → HTTPS.

---

# Cloudflare Cache

Cloudflare can cache:

- images
- static files
- frontend assets

Benefits:

- faster loading
- lower server usage
- better performance

---

# Cloudflare Security Features

## DDoS Protection

Protects against traffic attacks.

---

## WAF (Web Application Firewall)

Blocks malicious traffic.

---

## Bot Protection

Blocks suspicious bots/crawlers.

---

## Rate Limiting

Limits repeated requests.

Useful for:

- login endpoints
- APIs
- auth routes

---

# Hide Server IP

Using Cloudflare proxy hides VPS IP from public users.

Improves security.

---

# Common Domain Setup Workflow

1. Buy domain
2. Add domain to Cloudflare
3. Update nameservers
4. Configure DNS records
5. Wait for propagation
6. Enable HTTPS
7. Configure proxy/WAF
8. Deploy application

---

# Multiple Subdomains

Example setup:

```txt
example.com
api.example.com
admin.example.com
cdn.example.com
```

All can point to same VPS using reverse proxy.

---

# Reverse Proxy Support

Used with:

- Nginx
- Traefik
- Coolify
- Caddy

Allows multiple apps on same VPS.

---

# Domain Security Best Practices

- Enable HTTPS
- Use Cloudflare proxy
- Hide VPS IP when possible
- Enable WAF
- Use strong Cloudflare password
- Enable 2FA on Cloudflare account
- Avoid exposing databases publicly
- Monitor DNS records regularly

---

# Cloudflare Performance Tips

- Enable caching
- Compress assets
- Use CDN proxy
- Optimize images
- Use HTTP/2 and HTTP/3
- Cache static frontend files

---

# Common DNS Issues

## Domain Not Working

Check:

- nameservers
- DNS records
- VPS IP
- propagation status

---

## HTTPS Not Working

Check:

- SSL mode
- DNS proxy enabled
- reverse proxy config
- server SSL certificate

---

## Cloudflare 522 Error

Possible reasons:

- VPS offline
- firewall blocking Cloudflare
- reverse proxy issue

---

## DNS_PROBE_FINISHED_NXDOMAIN

Possible reasons:

- wrong DNS record
- propagation incomplete
- wrong nameservers

---

# Useful Commands

## Check Public IP

```bash
curl ifconfig.me
```

Displays public VPS IP.

---

## Ping Domain

```bash
ping example.com
```

Checks connectivity.

---

## Check HTTPS Headers

```bash
curl -I https://example.com
```

Displays HTTP headers.

---

# Recommended Production Workflow

1. Buy domain
2. Add domain to Cloudflare
3. Configure nameservers
4. Add DNS records
5. Enable Cloudflare proxy
6. Configure reverse proxy
7. Enable HTTPS
8. Configure WAF/security
9. Test domain access
10. Monitor DNS/security regularly