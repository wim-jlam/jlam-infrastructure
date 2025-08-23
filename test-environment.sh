#!/bin/bash

# ============================================
# JLAM Platform - Environment Test Script
# ============================================
# Tests both HTTP and HTTPS environments
# Usage: ./test-environment.sh [local|https]
# ============================================

set -e

MODE=${1:-https}

echo "🧪 Testing JLAM Platform Environment - Mode: $MODE"
echo "=================================================="

# Test function
test_endpoint() {
    local url=$1
    local expected_code=$2
    local name=$3
    local extra_args=${4:-""}
    
    echo -n "Testing $name... "
    
    if [[ "$url" == https* ]]; then
        # For HTTPS, extract domain and use Host header
        domain=$(echo $url | sed 's|https://||' | cut -d'/' -f1)
        response=$(curl -k -H "Host: $domain" https://localhost $extra_args -s -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
    else
        response=$(curl $url $extra_args -s -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
    fi
    
    if [[ "$response" == "$expected_code" ]]; then
        echo "✅ ($response)"
        return 0
    else
        echo "❌ ($response, expected $expected_code)"
        return 1
    fi
}

echo ""
echo "🔍 Testing Core Services:"
echo "========================"

if [ "$MODE" = "https" ]; then
    # HTTPS Tests
    test_endpoint "https://jlam.nl" "200" "Landing Page (HTTPS)"
    test_endpoint "https://app.jlam.nl" "200" "App Page (HTTPS)"
    test_endpoint "https://monitor.jlam.nl" "302" "Grafana (HTTPS)"
    test_endpoint "https://auth.jlam.nl" "302" "Authentik (HTTPS)"
else
    # HTTP Tests  
    test_endpoint "http://jlam.localhost" "200" "Landing Page (HTTP)"
    test_endpoint "http://app.localhost" "200" "App Page (HTTP)"
    test_endpoint "http://monitor.localhost" "302" "Grafana (HTTP)"
    test_endpoint "http://auth.localhost" "302" "Authentik (HTTP)"
fi

echo ""
echo "🔍 Testing Infrastructure:"
echo "========================="

# Infrastructure tests (always localhost)
test_endpoint "http://localhost:8080/dashboard/" "200" "Traefik Dashboard"
test_endpoint "http://localhost:3002" "302" "Grafana Direct" 

echo ""
echo "🔍 Testing Database Connections:"
echo "==============================="

# Test database
if nc -z localhost 5434 2>/dev/null; then
    echo "PostgreSQL (port 5434)... ✅"
else
    echo "PostgreSQL (port 5434)... ❌"
fi

if nc -z localhost 6381 2>/dev/null; then
    echo "Redis (port 6381)... ✅" 
else
    echo "Redis (port 6381)... ❌"
fi

echo ""
echo "📊 Container Status:"
echo "==================="

if [ "$MODE" = "https" ]; then
    docker-compose -f docker-compose.https-local.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
else
    docker-compose -f docker-compose.local.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
fi

echo ""
if [ "$MODE" = "https" ]; then
    echo "🌐 HTTPS Access (add to /etc/hosts):"
    echo "===================================="
    echo "127.0.0.1 jlam.nl app.jlam.nl auth.jlam.nl monitor.jlam.nl"
    echo ""
    echo "Then access:"
    echo "• https://jlam.nl - Landing Page"
    echo "• https://app.jlam.nl - App Platform"
    echo "• https://auth.jlam.nl - Authentik SSO"
    echo "• https://monitor.jlam.nl - Grafana"
    echo "• http://localhost:8080/dashboard/ - Traefik Dashboard"
else
    echo "🌐 HTTP Access:"
    echo "=============="
    echo "• http://jlam.localhost - Landing Page"
    echo "• http://app.localhost - App Platform"
    echo "• http://auth.localhost - Authentik SSO"
    echo "• http://monitor.localhost - Grafana"
    echo "• http://localhost:8080/dashboard/ - Traefik Dashboard"
fi

echo ""
echo "✅ Environment test complete!"