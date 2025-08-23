#!/bin/bash

# ============================================
# JLAM Platform - Simple Startup Script
# ============================================
# Starts local development environment
# Usage: ./start.sh [local|https]
# ============================================

set -e

MODE=${1:-local}

echo "🚀 Starting JLAM Platform - Mode: $MODE"
echo "======================================"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Create necessary directories
mkdir -p logs/traefik

# Select compose file based on mode
if [ "$MODE" = "https" ]; then
    COMPOSE_FILE="docker-compose.https-local.yml"
    echo "🔒 Using HTTPS mode with production SSL certificates"
else
    COMPOSE_FILE="docker-compose.local.yml"
    echo "🌐 Using local HTTP mode"
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f $COMPOSE_FILE down --remove-orphans

# Create network if needed
if ! docker network ls | grep -q "jlam-"; then
    echo "🌐 Creating Docker network..."
    if [ "$MODE" = "https" ]; then
        docker network create jlam-https-local 2>/dev/null || true
    else
        docker network create jlam-local 2>/dev/null || true
    fi
fi

# Start services
echo "🏗️  Starting services..."
docker-compose -f $COMPOSE_FILE up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 10

# Show status
echo ""
echo "📊 Service Status:"
echo "=================="
docker-compose -f $COMPOSE_FILE ps

echo ""
if [ "$MODE" = "https" ]; then
    echo "🎯 HTTPS Development URLs:"
    echo "========================="
    echo "🏠 Landing Page:      https://jlam.nl"
    echo "🚀 App Platform:      https://app.jlam.nl" 
    echo "🔐 Authentik SSO:     https://auth.jlam.nl"
    echo "📊 Traefik Dashboard: http://localhost:8080"
    echo "📈 Grafana Monitor:   https://monitor.jlam.nl"
    echo ""
    echo "⚠️  Add to /etc/hosts:"
    echo "127.0.0.1 jlam.nl app.jlam.nl auth.jlam.nl monitor.jlam.nl"
else
    echo "🎯 Local HTTP Development URLs:"
    echo "==============================="
    echo "🏠 Landing Page:      http://jlam.localhost"
    echo "🚀 App Platform:      http://app.localhost" 
    echo "🔐 Authentik SSO:     http://auth.localhost"
    echo "📊 Traefik Dashboard: http://localhost:8080"
    echo "📈 Grafana Monitor:   http://localhost:3005"
fi

echo ""
echo "✅ Environment ready!"