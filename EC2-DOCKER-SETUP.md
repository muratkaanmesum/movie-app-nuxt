# Starting Docker on EC2 Instance

## Quick Start

### Option 1: Install and Start Docker (First Time)

If Docker is not installed on your EC2 instance:

```bash
# SSH into your EC2 instance
ssh -i ~/.ssh/your-key.pem ubuntu@13.62.54.14

# Run the setup script
cd ~/movie-app-nuxt
chmod +x scripts/start-docker-ec2.sh
./scripts/start-docker-ec2.sh
```

### Option 2: Manual Installation

```bash
# Update system
sudo apt-get update -y

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (run without sudo)
sudo usermod -aG docker $USER

# Logout and login again, or run:
newgrp docker
```

### Option 3: Just Start Docker (If Already Installed)

```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker

# Verify Docker is running
docker ps
```

## Common Docker Commands on EC2

### Start/Stop/Status

```bash
# Start Docker
sudo systemctl start docker

# Stop Docker
sudo systemctl stop docker

# Restart Docker
sudo systemctl restart docker

# Check Docker status
sudo systemctl status docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Disable Docker auto-start
sudo systemctl disable docker
```

### Verify Docker is Running

```bash
# Test Docker
docker --version
docker ps

# Get Docker info
docker info

# If you see errors, try with sudo
sudo docker ps
```

### Install Docker Compose

```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

## Troubleshooting

### Permission Denied Error

If you get "permission denied" when running `docker ps`:

```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# Logout and login again, or:
newgrp docker

# Verify
groups  # Should show 'docker' in the list
```

### Docker Service Won't Start

```bash
# Check Docker logs
sudo journalctl -u docker.service

# Check Docker daemon
sudo dockerd --debug

# Restart Docker service
sudo systemctl restart docker
```

### Cannot Connect to Docker Daemon

```bash
# Make sure Docker is running
sudo systemctl start docker

# Check Docker socket
ls -la /var/run/docker.sock

# Fix permissions if needed
sudo chmod 666 /var/run/docker.sock
```

### Check Docker Installation

```bash
# Check if Docker is installed
which docker
docker --version

# Check Docker service status
sudo systemctl is-active docker
sudo systemctl is-enabled docker
```

## Quick Reference

```bash
# ============================================
# INSTALL DOCKER
# ============================================
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# ============================================
# START DOCKER
# ============================================
sudo systemctl start docker
sudo systemctl enable docker

# ============================================
# VERIFY DOCKER
# ============================================
docker --version
docker ps

# ============================================
# DOCKER COMPOSE
# ============================================
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## After Docker is Running

Once Docker is started, you can deploy your app:

```bash
cd ~/movie-app-nuxt

# Set environment variable
export NUXT_PUBLIC_TMDB_API_KEY=your_api_key

# Start your services
docker-compose up -d --build

# Check logs
docker-compose logs -f

# Check status
docker-compose ps
```

## System Info

To check your EC2 system:

```bash
# Check OS
cat /etc/os-release

# Check architecture
uname -m

# Check if systemd is available
systemctl --version
```

