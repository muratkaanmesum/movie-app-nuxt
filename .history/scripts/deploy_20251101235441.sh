#!/bin/bash
# Quick Deployment Script for EC2

set -e

echo "🚀 Starting deployment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if SSL certificates exist
if [ ! -f "nginx/ssl/cert.pem" ] || [ ! -f "nginx/ssl/key.pem" ]; then
    echo "⚠️  SSL certificates not found!"
    echo "Generating self-signed certificate for testing..."
    mkdir -p nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/key.pem \
        -out nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo "✅ Self-signed certificate created"
    echo "💡 For production, use: ./scripts/setup-ssl.sh yourdomain.com"
fi

# Build and start services
echo "📦 Building and starting services..."
docker-compose down 2>/dev/null || true
docker-compose build
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 5

# Check service health
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "📋 Service Status:"
    docker-compose ps
    echo ""
    echo "🌐 Your app should be available at:"
    echo "   HTTP:  http://$(curl -s ifconfig.me || echo 'YOUR_EC2_IP')"
    echo "   HTTPS: https://$(curl -s ifconfig.me || echo 'YOUR_EC2_IP')"
    echo ""
    echo "📊 View logs with: docker-compose logs -f"
else
    echo "❌ Some services failed to start. Check logs:"
    docker-compose logs
    exit 1
fi

