#!/bin/bash
# Check deployment health

set -e

EC2_IP="${1:-16.16.198.187}"
KEY_FILE="${2:-~/.ssh/your-key.pem}"
SSH_USER="${3:-ubuntu}"

echo "🔍 Checking deployment health..."
echo ""

if [ -z "$1" ] && [ "$EC2_IP" = "16.16.198.187" ]; then
    echo "Using default IP: $EC2_IP"
    echo "Usage: $0 [EC2_IP] [KEY_FILE] [SSH_USER]"
    echo "Example: $0 16.16.198.187 ~/.ssh/key.pem ubuntu"
    echo ""
fi

# Check if containers are running
echo "📋 Checking Docker containers..."
ssh -i "$KEY_FILE" "$SSH_USER@$EC2_IP" << EOF
    cd ~/movie-app-nuxt
    
    echo "Container Status:"
    docker-compose ps
    
    echo ""
    echo "Container Logs (last 20 lines):"
    docker-compose logs --tail=20
    
    echo ""
    echo "SSL Certificate Check:"
    if [ -f "nginx/ssl/cert.pem" ]; then
        echo "✅ Certificate exists"
        openssl x509 -in nginx/ssl/cert.pem -text -noout 2>/dev/null | grep -E "(Subject:|Issuer:|Not After)" || echo "⚠️  Certificate may be invalid"
    else
        echo "❌ Certificate not found"
    fi
    
    echo ""
    echo "Nginx Configuration Test:"
    docker exec nginx-proxy nginx -t 2>&1 || echo "⚠️  Nginx config error"
    
    echo ""
    echo "Checking if app is accessible:"
    curl -k -I https://localhost 2>&1 | head -5 || echo "⚠️  Cannot connect to app"
EOF

echo ""
echo "🌐 Testing from outside:"
echo "HTTP:"
curl -I "http://$EC2_IP" 2>&1 | head -5 || echo "❌ HTTP not accessible"

echo ""
echo "HTTPS:"
curl -k -I "https://$EC2_IP" 2>&1 | head -5 || echo "❌ HTTPS not accessible (this is normal with self-signed cert)"

echo ""
echo "✅ Health check complete!"

