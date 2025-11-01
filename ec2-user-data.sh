#!/bin/bash
# EC2 User Data Script - Runs on first boot

# Update system
apt-get update -y

# Install prerequisites
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Certbot for SSL
apt-get install -y certbot

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Enable Docker service
systemctl enable docker
systemctl start docker

# Install UFW firewall
apt-get install -y ufw
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Log completion
echo "EC2 initialization complete" >> /var/log/user-data.log

