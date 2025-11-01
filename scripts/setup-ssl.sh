#!/bin/bash
# SSL Certificate Setup Script

set -e

DOMAIN="${1:-localhost}"
EMAIL="${2:-admin@${DOMAIN}}"

echo "Setting up SSL for domain: $DOMAIN"

# Create SSL directory if it doesn't exist
mkdir -p nginx/ssl

if [ "$DOMAIN" = "localhost" ]; then
    echo "Generating self-signed certificate for localhost..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/key.pem \
        -out nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    
    echo "Self-signed certificate created!"
    echo "For production, use Let's Encrypt with a real domain."
else
    echo "Requesting Let's Encrypt certificate for $DOMAIN..."
    
    # Make sure nginx is stopped
    docker-compose down || true
    
    # Get certificate
    sudo certbot certonly --standalone \
        -d "$DOMAIN" \
        -d "www.$DOMAIN" \
        --email "$EMAIL" \
        --agree-tos \
        --non-interactive
    
    # Copy certificates
    sudo cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" nginx/ssl/cert.pem
    sudo cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" nginx/ssl/key.pem
    
    # Set permissions
    sudo chmod 644 nginx/ssl/cert.pem
    sudo chmod 600 nginx/ssl/key.pem
    sudo chown $USER:$USER nginx/ssl/*.pem || true
    
    echo "Certificate installed successfully!"
    echo "Setting up auto-renewal..."
    
    # Add renewal script to crontab
    (crontab -l 2>/dev/null; echo "0 0,12 * * * certbot renew --quiet --deploy-hook 'docker-compose restart nginx'") | crontab -
    
    echo "SSL setup complete!"
fi

