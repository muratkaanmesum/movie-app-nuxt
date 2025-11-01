# Deploy to EC2 Instance: 13.62.54.14

## Quick Deployment

### Option 1: Automated Script (Recommended)

```bash
# Make script executable
chmod +x scripts/deploy-to-ec2.sh

# Deploy (replace with your key file path)
./scripts/deploy-to-ec2.sh 13.62.54.14 ~/.ssh/your-key.pem ubuntu

# Or use default IP (already set to 13.62.54.14)
./scripts/deploy-to-ec2.sh
```

### Option 2: Manual Deployment

#### 1. Verify Security Group

Make sure your EC2 security group allows:
- **Port 22 (SSH)** - from your IP
- **Port 80 (HTTP)** - from anywhere (0.0.0.0/0)
- **Port 443 (HTTPS)** - from anywhere (0.0.0.0/0)

Check in AWS Console:
- EC2 → Instances → Select instance → Security → Security Groups
- Edit inbound rules if needed

#### 2. Connect to Instance

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@13.62.54.14
```

#### 3. Install Prerequisites (if not already installed)

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in for group changes
exit
```

Reconnect:
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@13.62.54.14
```

#### 4. Transfer Files to EC2

From your local machine:

```bash
# Using rsync (recommended)
rsync -avz --progress \
    -e "ssh -i ~/.ssh/your-key.pem" \
    --exclude 'node_modules' \
    --exclude '.git' \
    --exclude '.output' \
    --exclude '.nuxt' \
    ./ ubuntu@13.62.54.14:~/movie-app-nuxt/

# Or using SCP
scp -i ~/.ssh/your-key.pem -r \
    --exclude 'node_modules' \
    --exclude '.git' \
    ./ ubuntu@13.62.54.14:~/movie-app-nuxt/
```

#### 5. Deploy on EC2

SSH into instance and run:

```bash
cd ~/movie-app-nuxt

# Set environment variable
export NUXT_PUBLIC_TMDB_API_KEY=your_api_key_here

# Create SSL directory
mkdir -p nginx/ssl

# Generate self-signed certificate (for testing)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/ssl/key.pem \
    -out nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Start services
docker-compose up -d --build

# Check status
docker-compose ps
docker-compose logs -f
```

## Verify Deployment

After deployment, verify:

1. **HTTP redirect**:
   ```bash
   curl -I http://13.62.54.14
   # Should return 301 redirect to HTTPS
   ```

2. **HTTPS access**:
   ```bash
   curl -k https://13.62.54.14
   # Should return your app HTML
   ```

3. **Browser access**:
   - Visit: `http://13.62.54.14` (should redirect to HTTPS)
   - Visit: `https://13.62.54.14` (may show security warning with self-signed cert)

## Setup Production SSL (Let's Encrypt)

If you have a domain pointing to this IP:

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@13.62.54.14
cd ~/movie-app-nuxt

# Setup SSL with Let's Encrypt
./scripts/setup-ssl.sh yourdomain.com your@email.com

# Update nginx config with your domain
# Edit nginx/nginx.conf and replace server_name
```

## Troubleshooting

### Cannot connect via SSH
- Check security group allows port 22 from your IP
- Verify instance is running
- Check key file permissions: `chmod 400 ~/.ssh/your-key.pem`

### Services not starting
```bash
# Check logs
docker-compose logs

# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker
```

### Port not accessible
- Verify security group rules (ports 80 and 443)
- Check firewall on instance:
  ```bash
  sudo ufw status
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  ```

### View service logs
```bash
docker-compose logs -f nginx
docker-compose logs -f movie-app
```

### Restart services
```bash
docker-compose restart
# Or
docker-compose down && docker-compose up -d
```

## Quick Commands

```bash
# SSH into instance
ssh -i ~/.ssh/your-key.pem ubuntu@13.62.54.14

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Rebuild and restart
docker-compose down && docker-compose up -d --build

# Check running containers
docker ps

# Check nginx config
docker exec nginx-proxy nginx -t
```

## Access Your App

Once deployed, your app will be available at:
- **HTTP**: http://13.62.54.14 (redirects to HTTPS)
- **HTTPS**: https://13.62.54.14

For production, configure your domain DNS to point to this IP and set up Let's Encrypt SSL.

