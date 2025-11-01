#!/bin/bash
# Quick Deployment Script for EC2

set -e

echo "🚀 Starting deployment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    echo ""
    echo "💡 To start Docker:"
    
    # Detect OS and provide specific instructions
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "   macOS: Open Docker Desktop from Applications, or run:"
        echo "   open -a Docker"
        echo ""
        echo "   After starting Docker Desktop, wait a few seconds and try again."
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux (EC2)
        echo "   Linux: Start Docker service with:"
        echo "   sudo systemctl start docker"
        echo ""
        echo "   Or install Docker if not installed:"
        echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
        echo "   sudo sh get-docker.sh"
    else
        echo "   Please start Docker Desktop or Docker service for your OS"
    fi
    
    echo ""
    echo "   Verify Docker is running with: docker ps"
    echo ""
    read -p "Would you like to try starting Docker now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "🚀 Attempting to start Docker Desktop..."
            open -a Docker
            echo "⏳ Waiting for Docker to start (this may take 10-20 seconds)..."
            for i in {1..30}; do
                if docker info > /dev/null 2>&1; then
                    echo "✅ Docker is now running!"
                    break
                fi
                sleep 1
                echo -n "."
            done
            echo ""
            
            if ! docker info > /dev/null 2>&1; then
                echo "❌ Docker did not start. Please start Docker Desktop manually and try again."
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "🚀 Attempting to start Docker service..."
            if sudo systemctl start docker 2>/dev/null; then
                echo "✅ Docker service started!"
                sleep 2
            else
                echo "❌ Failed to start Docker. You may need to install Docker first."
                echo "   Run: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
                exit 1
            fi
        fi
    else
        exit 1
    fi
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

echo "🔨 Building Docker images (this may take a few minutes)..."
echo "   Note: npm install step may take time depending on your connection"
echo ""

# Build with progress output (remove --quiet to see build progress)
docker-compose build --progress=plain

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Common issues:"
    echo "   - Network issues: npm cannot download packages"
    echo "   - Disk space: Check available disk space"
    echo "   - Memory: Docker may need more memory"
    echo ""
    echo "Try running with verbose output:"
    echo "   docker-compose build --progress=plain --no-cache"
    exit 1
fi

echo "🚀 Starting services..."
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

