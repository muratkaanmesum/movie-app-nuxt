#!/bin/bash
# Comprehensive Deployment Script
# Usage:
#   ./scripts/deploy.sh                                    # Local deployment
#   ./scripts/deploy.sh --ec2 IP KEY_FILE [USER]          # Deploy to EC2
#   ./scripts/deploy.sh --local-build                     # Build locally first (faster)
#   ./scripts/deploy.sh --setup-ssl domain.com email@domain.com
#   ./scripts/deploy.sh --timeout 1800                     # Set build timeout
#
# Examples:
#   ./scripts/deploy.sh --ec2 16.16.198.187 ~/.ssh/my-key.pem ubuntu
#   ./scripts/deploy.sh --ec2 16.16.198.187 ~/.ssh/id_rsa ubuntu
#   ./scripts/deploy.sh --ec2 16.16.198.187 /path/to/key.pem ubuntu

set -e

# Configuration
BUILD_TIMEOUT=${BUILD_TIMEOUT:-1800}  # 30 minutes default
LOCAL_BUILD=false
DEPLOY_TO_EC2=false
EC2_IP=""
EC2_KEY=""
EC2_USER="ubuntu"
SSL_DOMAIN=""
SSL_EMAIL=""
BUILD_LOG="build.log"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ec2)
            DEPLOY_TO_EC2=true
            EC2_IP="$2"
            EC2_KEY="$3"
            EC2_USER="${4:-ubuntu}"
            shift 4
            ;;
        --local-build)
            LOCAL_BUILD=true
            shift
            ;;
        --setup-ssl)
            SSL_DOMAIN="$2"
            SSL_EMAIL="$3"
            shift 3
            ;;
        --timeout)
            BUILD_TIMEOUT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--ec2 IP KEY_FILE [USER]] [--local-build] [--setup-ssl domain.com email@domain.com] [--timeout seconds]"
            exit 1
            ;;
    esac
done

echo "🚀 Starting deployment..."

# Function: Check and start Docker
check_docker() {
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
}

# Function: Setup SSL certificates
setup_ssl() {
    mkdir -p nginx/ssl
    
    if [ -z "$SSL_DOMAIN" ] || [ "$SSL_DOMAIN" = "localhost" ]; then
        echo "🔒 Generating self-signed certificate for testing..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout nginx/ssl/key.pem \
            -out nginx/ssl/cert.pem \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" 2>/dev/null || \
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout nginx/ssl/key.pem \
            -out nginx/ssl/cert.pem \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
        sudo chown -R $USER:$USER nginx/ssl/ 2>/dev/null || true
        echo "✅ Self-signed certificate created"
        echo "💡 For production, use: ./scripts/deploy.sh --setup-ssl yourdomain.com your@email.com"
    else
        echo "🔒 Requesting Let's Encrypt certificate for $SSL_DOMAIN..."
        
        # Make sure nginx is stopped
        docker-compose down 2>/dev/null || true
        
        # Check if certbot is installed
        if ! command -v certbot &> /dev/null; then
            echo "📦 Installing certbot..."
            if [[ "$OSTYPE" == "darwin"* ]]; then
                brew install certbot || echo "Please install certbot manually: brew install certbot"
            else
                sudo apt-get update -y && sudo apt-get install -y certbot || \
                sudo yum install -y certbot || echo "Please install certbot manually"
            fi
        fi
        
        # Get certificate
        sudo certbot certonly --standalone \
            -d "$SSL_DOMAIN" \
            -d "www.$SSL_DOMAIN" \
            --email "${SSL_EMAIL:-admin@$SSL_DOMAIN}" \
            --agree-tos \
            --non-interactive || {
            echo "❌ Failed to get Let's Encrypt certificate"
            echo "   Make sure domain points to this server and ports 80/443 are open"
            exit 1
        }
        
        # Copy certificates
        sudo cp "/etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem" nginx/ssl/cert.pem
        sudo cp "/etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem" nginx/ssl/key.pem
        
        # Set permissions
        sudo chmod 644 nginx/ssl/cert.pem
        sudo chmod 600 nginx/ssl/key.pem
        sudo chown $USER:$USER nginx/ssl/*.pem 2>/dev/null || true
        
        echo "✅ Certificate installed successfully!"
        echo "🔄 Setting up auto-renewal..."
        
        # Add renewal script to crontab
        (crontab -l 2>/dev/null | grep -v "certbot renew"; \
         echo "0 0,12 * * * certbot renew --quiet --deploy-hook 'cd $PWD && docker-compose restart nginx'") | crontab -
        
        echo "✅ SSL setup complete!"
    fi
}

# Function: Build locally first
build_locally() {
    echo "🔨 Building Nuxt app locally first..."
    echo "   This avoids slow Docker builds and lets you see progress"
    echo ""
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing dependencies..."
        npm install --legacy-peer-deps
    fi
    
    # Build locally
    echo "🔨 Building Nuxt app..."
    npm run build
    
    if [ $? -ne 0 ]; then
        echo "❌ Local build failed. Fix errors before deploying."
        exit 1
    fi
    
    echo ""
    echo "✅ Local build completed!"
    echo ""
}

# Function: Build Docker images
build_docker() {
    echo "📦 Building and starting services..."
    docker-compose down 2>/dev/null || true
    
    echo "🔨 Building Docker images (this may take a few minutes)..."
    echo "   Note: npm install step may take time depending on your connection"
    echo "   Note: Nuxt Nitro build can take 2-5 minutes (this is normal)"
    echo ""
    
    # Enable BuildKit for better caching and progress
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    
    # Build based on local build option or if .output exists
    if [ "$LOCAL_BUILD" = true ] || [ -d ".output" ]; then
        echo "🐳 Building Docker image with pre-built app..."
        # Use fallback Dockerfile if .output exists
        if [ -d ".output" ]; then
            echo "✅ Found pre-built .output, using fallback Dockerfile..."
            docker build -f Dockerfile.fallback -t movie-app-nuxt-movie-app:latest . || {
                echo "⚠️  Fallback build failed, trying full build..."
                docker-compose build --progress=plain --no-cache
            }
        fi
    else
        # Build with progress output and optional timeout
        echo "⏳ Building (watching for progress)..."
        
        if command -v timeout &> /dev/null; then
            echo "   ⏱️  Timeout: ${BUILD_TIMEOUT}s ($(($BUILD_TIMEOUT / 60)) minutes)"
            timeout $BUILD_TIMEOUT docker-compose build --progress=plain 2>&1 | tee $BUILD_LOG | while IFS= read -r line; do
                echo "$line"
                # Show progress if build seems stuck
                if [[ "$line" == *"[nitro]"* ]] || [[ "$line" == *"Building"* ]]; then
                    echo "   ⚡ Build in progress... (this step can take 2-5 minutes)"
                fi
            done
            BUILD_EXIT=${PIPESTATUS[0]}
            
            if [ $BUILD_EXIT -eq 124 ]; then
                echo ""
                echo "❌ Build timed out after $BUILD_TIMEOUT seconds"
                echo "   The Nuxt Nitro build step can be slow."
                echo "   Try: ./scripts/deploy.sh --local-build"
                rm -f $BUILD_LOG
                exit 1
            elif [ $BUILD_EXIT -ne 0 ]; then
                BUILD_EXIT=1
            else
                BUILD_EXIT=0
                rm -f $BUILD_LOG
            fi
        else
            docker-compose build --progress=plain 2>&1 | while IFS= read -r line; do
                echo "$line"
                # Show progress if build seems stuck
                if [[ "$line" == *"[nitro]"* ]] || [[ "$line" == *"Building"* ]]; then
                    echo "   ⚡ Build in progress... (this step can take 2-5 minutes)"
                fi
            done
            BUILD_EXIT=${PIPESTATUS[0]}
        fi
        
        if [ ${BUILD_EXIT:-1} -ne 0 ]; then
            echo ""
            echo "⚠️  Full build failed, checking for fallback..."
            
            # Try fallback if .output exists or can be built locally
            if [ -d ".output" ]; then
                echo "✅ Found pre-built .output, trying fallback Dockerfile..."
                if docker build -f Dockerfile.fallback -t movie-app-nuxt-movie-app:latest .; then
                    echo "✅ Fallback build succeeded!"
                    echo "SUCCESS" > /tmp/deploy_status
                else
                    echo "❌ Fallback build also failed"
                    echo "FAILED" > /tmp/deploy_status
                fi
            else
                echo "❌ Build failed. Common issues:"
                echo "   - Network issues: npm cannot download packages"
                echo "   - Disk space: Check available disk space"
                echo "   - Memory: Docker may need more memory (increase in Docker Desktop)"
                echo "   - Timeout: Nuxt build took too long"
                echo ""
                echo "💡 Troubleshooting:"
                echo "   1. Build locally first: npm install && npm run build"
                echo "   2. Then deploy: ./scripts/deploy.sh (will use pre-built .output)"
                echo "   3. Or try: ./scripts/deploy.sh --local-build"
                echo "   4. Or increase timeout: ./scripts/deploy.sh --timeout 3600"
                rm -f $BUILD_LOG
                echo "FAILED" > /tmp/deploy_status
            fi
        else
            echo "SUCCESS" > /tmp/deploy_status
        fi
    fi
}

# Function: Start services
start_services() {
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
        echo "   HTTP:  http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_EC2_IP')"
        echo "   HTTPS: https://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_EC2_IP')"
        echo ""
        echo "📊 View logs with: docker-compose logs -f"
    else
        echo "❌ Some services failed to start. Check logs:"
        docker-compose logs
        exit 1
    fi
}

# Function: Deploy to EC2
deploy_to_ec2() {
    echo "🚀 Deploying to EC2 instance: $EC2_IP"
    echo "   SSH Key: $EC2_KEY"
    echo "   User: $EC2_USER"
    echo ""
    
    # Validate inputs
    if [ -z "$EC2_IP" ] || [ -z "$EC2_KEY" ]; then
        echo "❌ EC2 IP and SSH key are required for EC2 deployment"
        echo "   Usage: ./scripts/deploy.sh --ec2 IP KEY_FILE [USER]"
        exit 1
    fi
    
    # Expand tilde in key path
    EC2_KEY=$(eval echo "$EC2_KEY")
    
    # Check if key file exists
    if [ ! -f "$EC2_KEY" ]; then
        echo "❌ SSH key file not found: $EC2_KEY"
        echo ""
        echo "💡 Make sure to provide the correct path to your SSH key:"
        echo "   ./scripts/deploy.sh --ec2 16.16.198.187 ~/.ssh/your-actual-key.pem ubuntu"
        echo ""
        echo "   Common locations:"
        echo "   - ~/.ssh/id_rsa"
        echo "   - ~/.ssh/your-key-name.pem"
        echo "   - ~/.ssh/ec2-key.pem"
        echo ""
        echo "   Or use full path:"
        echo "   ./scripts/deploy.sh --ec2 16.16.198.187 /path/to/your-key.pem ubuntu"
        exit 1
    fi
    
    # Verify key file permissions
    KEY_PERMS=$(stat -c "%a" "$EC2_KEY" 2>/dev/null || stat -f "%OLp" "$EC2_KEY" 2>/dev/null || echo "")
    if [ "$KEY_PERMS" != "400" ] && [ "$KEY_PERMS" != "600" ]; then
        echo "⚠️  Warning: SSH key permissions should be 400 or 600"
        echo "   Current: $KEY_PERMS"
        echo "   Fix with: chmod 400 $EC2_KEY"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Test SSH connection
    echo "🔌 Testing SSH connection..."
    if ! ssh -i "$EC2_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'Connection successful'" 2>/dev/null; then
        echo "❌ Cannot connect to EC2 instance"
        echo "   Make sure:"
        echo "   1. Instance is running"
        echo "   2. Security group allows SSH (port 22) from your IP"
        echo "   3. SSH key is correct"
        exit 1
    fi
    
    echo "✅ Connection successful!"
    echo ""
    
    # Transfer files
    echo "📦 Transferring files to EC2..."
    rsync -avz --progress \
        -e "ssh -i $EC2_KEY" \
        --exclude 'node_modules' \
        --exclude '.git' \
        --exclude '.output' \
        --exclude '.nuxt' \
        --exclude '.env' \
        --exclude '.env.*' \
        --exclude 'nginx/ssl/*.pem' \
        --exclude '.DS_Store' \
        --include 'package-lock.json' \
        ./ "$EC2_USER@$EC2_IP:~/movie-app-nuxt/"
    
    echo "✅ Files transferred!"
    echo ""
    
    # Deploy on EC2
    echo "🚀 Running deployment on EC2..."
    ssh -i "$EC2_KEY" "$EC2_USER@$EC2_IP" << EOF
        cd ~/movie-app-nuxt
        
        # Check if Docker is installed
        if ! command -v docker &> /dev/null; then
            echo "📦 Installing Docker..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker \$USER
            newgrp docker || true
        fi
        
        # Check if Docker Compose is installed
        if ! command -v docker-compose &> /dev/null; then
            echo "📦 Installing Docker Compose..."
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi
        
        # Start Docker if not running
        if ! docker info > /dev/null 2>&1; then
            echo "🚀 Starting Docker service..."
            sudo systemctl start docker
            sudo systemctl enable docker
        fi
        
        # Create SSL directory if it doesn't exist
        mkdir -p nginx/ssl
        
        # Generate self-signed certificate if it doesn't exist
        if [ ! -f "nginx/ssl/cert.pem" ] || [ ! -f "nginx/ssl/key.pem" ]; then
            echo "🔒 Generating self-signed certificate..."
            # Use EC2 public IP or hostname in certificate
            EC2_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "$EC2_IP")
            echo "   Using IP: \$EC2_IP"
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout nginx/ssl/key.pem \
                -out nginx/ssl/cert.pem \
                -subj "/C=US/ST=State/L=City/O=Organization/CN=\$EC2_IP" 2>/dev/null || \
            sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout nginx/ssl/key.pem \
                -out nginx/ssl/cert.pem \
                -subj "/C=US/ST=State/L=City/O=Organization/CN=\$EC2_IP"
            sudo chown -R \$USER:\$USER nginx/ssl/ 2>/dev/null || true
            
            # Verify certificates were created
            if [ -f "nginx/ssl/cert.pem" ] && [ -f "nginx/ssl/key.pem" ]; then
                echo "✅ SSL certificates created successfully"
                # Set correct permissions
                chmod 644 nginx/ssl/cert.pem
                chmod 600 nginx/ssl/key.pem
                # Verify certificate
                openssl x509 -in nginx/ssl/cert.pem -noout -subject 2>/dev/null || echo "⚠️  Certificate created but may be invalid"
            else
                echo "❌ Failed to create SSL certificates"
            fi
        else
            echo "✅ SSL certificates already exist"
            # Verify certificate validity
            CERT_SUBJECT=\$(openssl x509 -in nginx/ssl/cert.pem -noout -subject 2>/dev/null | grep -o "CN=[^,]*" || echo "invalid")
            echo "   Certificate: \$CERT_SUBJECT"
            if ! openssl x509 -in nginx/ssl/cert.pem -noout -checkend 0 2>/dev/null; then
                echo "⚠️  Certificate expired or invalid, regenerating..."
                rm -f nginx/ssl/*.pem
                # Regenerate
                EC2_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "$EC2_IP")
                openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                    -keyout nginx/ssl/key.pem \
                    -out nginx/ssl/cert.pem \
                    -subj "/C=US/ST=State/L=City/O=Organization/CN=\$EC2_IP"
                chmod 644 nginx/ssl/cert.pem
                chmod 600 nginx/ssl/key.pem
            fi
        fi
        
        # Deploy
        echo "🚀 Starting services..."
        export NUXT_PUBLIC_TMDB_API_KEY=\${NUXT_PUBLIC_TMDB_API_KEY:-your_tmdb_api_key_here}
        docker-compose down 2>/dev/null || true
        
        # Ensure package-lock.json exists before building
        if [ ! -f "package-lock.json" ]; then
            echo "📦 Generating package-lock.json..."
            npm install --legacy-peer-deps --package-lock-only
        fi
        
        # Verify dependencies are correct
        echo "📋 Verifying dependencies..."
        npm list --depth=0 2>/dev/null | grep -E "(tailwindcss|@nuxt)" || echo "Note: Running in Docker will install dependencies"
        
        echo "🔨 Building Docker images..."
        
        # Check if .output exists (pre-built locally)
        if [ -d ".output" ]; then
            echo "✅ Found pre-built .output directory, using fallback Dockerfile..."
            # Use fallback Dockerfile that doesn't need to build
            if docker build -f Dockerfile.fallback -t movie-app-nuxt-movie-app:latest .; then
                echo "✅ Fallback build succeeded!"
            else
                echo "⚠️  Fallback build failed, trying full build..."
                docker-compose build --progress=plain --no-cache --pull || {
                    echo "❌ All builds failed"
                    exit 1
                }
            fi
        else
            echo "🔨 Building from source (this may take 2-5 minutes)..."
            # Build without cache to ensure fresh install
            if ! docker-compose build --progress=plain --no-cache --pull; then
                echo "❌ Full build failed. Trying to build locally first..."
                echo "   Building locally to create .output..."
                npm install --legacy-peer-deps && npm run build && \
                docker build -f Dockerfile.fallback -t movie-app-nuxt-movie-app:latest . || {
                    echo "❌ All builds failed. Manual steps:"
                    echo "   1. npm install --legacy-peer-deps"
                    echo "   2. npm run build"
                    echo "   3. Deploy again"
                    exit 1
                }
            fi
        fi
        
        echo "🚀 Starting services..."
        docker-compose up -d
        
        echo "⏳ Waiting for services to start..."
        sleep 10
        
        # Check status
        docker-compose ps
        
        echo ""
        echo "✅ Deployment on EC2 complete!"
        echo "🌐 Your app should be available at:"
        echo "   HTTP:  http://$EC2_IP (redirects to HTTPS)"
        echo "   HTTPS: https://$EC2_IP"
        echo ""
        echo "⚠️  Note: Browser will show security warning for self-signed certificate"
        echo "   Click 'Advanced' → 'Proceed to site' to access"
        echo ""
        echo "📊 View logs: docker-compose logs -f"
EOF
    
    echo ""
    echo "✅ Deployment to EC2 complete!"
    echo ""
    echo "🌐 Your app is available at:"
    echo "   HTTP:  http://$EC2_IP (redirects to HTTPS)"
    echo "   HTTPS: https://$EC2_IP"
}

# Main execution
if [ "$DEPLOY_TO_EC2" = true ]; then
    # EC2 deployment
    deploy_to_ec2
else
    # Local deployment
    check_docker

    # Setup SSL if requested or if certificates don't exist
    if [ -n "$SSL_DOMAIN" ]; then
        setup_ssl
    elif [ ! -f "nginx/ssl/cert.pem" ] || [ ! -f "nginx/ssl/key.pem" ]; then
        echo "⚠️  SSL certificates not found!"
        setup_ssl
    fi

    # Build locally if requested
    if [ "$LOCAL_BUILD" = true ]; then
        build_locally
    fi

    # Build Docker images
    build_docker

    # Check build status
    if [ -f /tmp/deploy_status ] && [ "$(cat /tmp/deploy_status)" = "FAILED" ]; then
        rm -f /tmp/deploy_status
        exit 1
    fi
    rm -f /tmp/deploy_status

    # Start services
    start_services

    echo ""
    echo "✅ Deployment complete!"
fi
