# 🚀 JLAM Platform - Clean Development Environment

**Clean, essential-only setup for local development and testing**

## 📁 Directory Structure

```
jlam-platform/
├── app/                           # Application content
│   └── index.html                # Landing page
├── config/                       # Configuration files
│   ├── ssl/                      # SSL certificates (production)
│   │   ├── certificate.crt       # SSL certificate
│   │   ├── certificate.key       # SSL private key
│   │   └── cabundle.crt          # Certificate authority bundle
│   └── tls.yml                   # Traefik TLS configuration (v3 compatible)
├── docker-compose.local.yml      # HTTP development stack
├── docker-compose.https-local.yml # HTTPS development stack (production SSL)
├── start.sh                      # Simple startup script
└── README.md                     # This file
```

## 🎯 Quick Start

### HTTP Development (Simple)
```bash
./start.sh local
```
- Accessible at: http://jlam.localhost, http://app.localhost, http://auth.localhost
- Traefik Dashboard: http://localhost:8080

### HTTPS Development (Production SSL)
```bash
./start.sh https
```
- Accessible at: https://jlam.nl, https://app.jlam.nl, https://auth.jlam.nl
- Requires hosts file: `127.0.0.1 jlam.nl app.jlam.nl auth.jlam.nl monitor.jlam.nl`

## 🔧 Services Included

- **Traefik v3.0** - Reverse proxy with SSL termination
- **Authentik 2024.8** - SSO/Identity management
- **PostgreSQL 15** - Database
- **Redis 7** - Caching
- **Prometheus** - Metrics collection
- **Grafana** - Monitoring dashboards

## 📊 Database Connections

**Local Development:**
- PostgreSQL: localhost:5433 (HTTP mode) / localhost:5434 (HTTPS mode)
- Redis: localhost:6380 (HTTP mode) / localhost:6381 (HTTPS mode)

**Credentials:**
- Database: `jlam_dev` / User: `jlam_user` / Password: `dev_password_123`
- Redis Password: `dev_redis_pass`

## ✅ What We Fixed

This clean setup resolves the critical issues that killed 76+ servers:
- ❌ **sslStrategies removed** - Traefik v2 syntax that doesn't work in v3
- ✅ **Correct double underscores** - `AUTHENTIK_COOKIE__SECURE` not `AUTHENTIK_COOKIE_SECURE`
- ✅ **Production SSL certificates** - Real certificates, not self-signed or Let's Encrypt
- ✅ **Clean directory structure** - No redundant files or deployment history
- ✅ **Working local environment** - Test everything before production

## 🎯 Development Workflow

1. **Local Testing**: Use `./start.sh local` for rapid development
2. **SSL Testing**: Use `./start.sh https` to test with production SSL
3. **Production Deploy**: Copy exact working configuration to cloud deployment

This approach follows the **DevOps best practice**: Local → Staging → Production

**Mission: "Van ziekenzorg naar gezondheidszorg" 🏥 → ❤️**