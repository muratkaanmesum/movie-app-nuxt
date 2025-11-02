#!/bin/bash
# Set TMDB API Key on EC2

set -e

EC2_IP="${1:-16.16.198.187}"
KEY_FILE="${2}"
SSH_USER="${3:-ubuntu}"
API_KEY="${4}"

if [ -z "$API_KEY" ]; then
    echo "❌ TMDB API Key is required"
    echo ""
    echo "Usage: $0 [EC2_IP] [KEY_FILE] [SSH_USER] [API_KEY]"
    echo ""
    echo "Example:"
    echo "  $0 16.16.198.187 ~/.ssh/key.pem ubuntu your_tmdb_api_key_here"
    echo ""
    echo "Or if you're already on EC2:"
    echo "  export NUXT_PUBLIC_TMDB_API_KEY=your_api_key"
    echo "  docker-compose restart movie-app"
    exit 1
fi

if [ -n "$KEY_FILE" ]; then
    # Expand tilde in key path
    KEY_FILE=$(eval echo "$KEY_FILE")
    
    if [ ! -f "$KEY_FILE" ]; then
        echo "❌ SSH key file not found: $KEY_FILE"
        exit 1
    fi
    
    echo "🔑 Setting TMDB API Key on EC2..."
    echo "   Instance: $EC2_IP"
    echo "   Key: $KEY_FILE"
    echo ""
    
    # Set API key via SSH
    ssh -i "$KEY_FILE" "$SSH_USER@$EC2_IP" << EOF
        cd ~/movie-app-nuxt
        
        # Export API key for docker-compose
        export NUXT_PUBLIC_TMDB_API_KEY=$API_KEY
        
        # Update docker-compose.yml or use environment variable
        echo "✅ Setting NUXT_PUBLIC_TMDB_API_KEY=$API_KEY"
        
        # Restart the app with new API key
        docker-compose down
        NUXT_PUBLIC_TMDB_API_KEY=$API_KEY docker-compose up -d
        
        # Verify
        echo ""
        echo "✅ API key set! Restarting services..."
        sleep 5
        
        # Check if services are running
        docker-compose ps
EOF
else
    echo "🔑 Setting TMDB API Key locally..."
    echo ""
    echo "If you're already on EC2, run:"
    echo ""
    echo "  export NUXT_PUBLIC_TMDB_API_KEY=$API_KEY"
    echo "  cd ~/movie-app-nuxt"
    echo "  docker-compose down"
    echo "  NUXT_PUBLIC_TMDB_API_KEY=$API_KEY docker-compose up -d"
    echo ""
fi

echo ""
echo "✅ API key configuration complete!"
echo ""
echo "💡 To make it permanent, edit docker-compose.yml or set it in environment:"
echo "   export NUXT_PUBLIC_TMDB_API_KEY=$API_KEY"

