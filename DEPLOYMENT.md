# EC2 Deployment Guide

This guide will walk you through deploying your Nuxt movie app to AWS EC2 with nginx and HTTPS.

## Prerequisites

- AWS account
- AWS CLI configured (or AWS Console access)
- Domain name (optional, but recommended for Let's Encrypt SSL)
- SSH key pair for EC2 access

## Step 1: Create EC2 Instance

### Option A: Using AWS Console

1. Go to EC2 Dashboard → Launch Instance
2. Choose an AMI (Ubuntu 22.04 LTS recommended)
3. Select instance type (t2.micro or t3.small for testing)
4. Configure security group:
   - SSH (22) from your IP
   - HTTP (80) from anywhere (0.0.0.0/0)
   - HTTPS (443) from anywhere (0.0.0.0/0)
5. Select or create a key pair
6. Launch instance

### Option B: Using AWS CLI

```bash
# Create security group
aws ec2 create-security-group \
  --group-name movie-app-sg \
  --description "Security group for movie app"

# Get security group ID (replace with actual ID)
SG_ID=$(aws ec2 describe-security-groups \
  --group-names movie-app-sg \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

# Allow SSH from your IP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr YOUR_IP/32

# Allow HTTP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Allow HTTPS
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Launch instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.small \
  --key-name your-key-pair \
  --security-group-ids $SG_ID \
  --user-data file://ec2-user-data.sh
```

## Step 2: Connect to EC2 Instance

```bash
ssh -i your-key-pair.pem ubuntu@YOUR_EC2_IP
```

## Step 3: Install Docker and Docker Compose

```bash
# Update system
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in for group changes to take effect
exit
```

## Step 4: Deploy Application

```bash
# Clone your repository or transfer files
git clone YOUR_REPO_URL
cd movie-app-nuxt

# Or use SCP to transfer files
# scp -i your-key-pair.pem -r ./movie-app-nuxt ubuntu@YOUR_EC2_IP:~/

# Set environment variables
export NUXT_PUBLIC_TMDB_API_KEY=your_api_key_here

# For production with SSL, create SSL directory
mkdir -p nginx/ssl

# Copy your SSL certificates (if you have them)
# Or use self-signed certificates for testing
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

## Step 5: Setup SSL with Let's Encrypt (Recommended)

### Install Certbot

```bash
# Install certbot
sudo apt-get install certbot

# Stop nginx temporarily (if running)
docker-compose down

# Get certificate (replace with your domain)
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Copy certificates to nginx directory
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem nginx/ssl/key.pem
sudo chmod 644 nginx/ssl/cert.pem
sudo chmod 600 nginx/ssl/key.pem
```

### Auto-renewal

```bash
# Add to crontab
sudo crontab -e

# Add this line (runs renewal check twice daily)
0 0,12 * * * certbot renew --quiet && docker-compose restart nginx
```

## Step 6: Update Nginx Config for Your Domain

Edit `nginx/nginx.conf` and replace `server_name _;` with your domain:

```nginx
server_name yourdomain.com www.yourdomain.com;
```

## Step 7: Start Services

```bash
# Build and start containers
docker-compose up -d --build

# Check logs
docker-compose logs -f

# Verify services are running
docker-compose ps
```

## Step 8: Verify Deployment

- Visit `http://YOUR_EC2_IP` (should redirect to HTTPS)
- Visit `https://YOUR_EC2_IP` (or your domain)
- Check nginx logs: `docker-compose logs nginx`
- Check app logs: `docker-compose logs movie-app`

## Troubleshooting

### Check if ports are open
```bash
sudo netstat -tlnp | grep -E ':(80|443)'
```

### Check security group rules
```bash
aws ec2 describe-security-groups --group-names movie-app-sg
```

### View nginx configuration
```bash
docker exec nginx-proxy cat /etc/nginx/conf.d/default.conf
```

### Restart services
```bash
docker-compose restart
# Or
docker-compose down && docker-compose up -d
```

## Security Best Practices

1. **Use a firewall (UFW)**:
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **Keep system updated**:
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```

3. **Use environment variables** for secrets (never commit API keys)

4. **Set up CloudWatch monitoring** for your EC2 instance

5. **Enable AWS CloudWatch alarms** for instance health

6. **Use AWS Systems Manager** for secure access instead of SSH if possible

## Cost Optimization

- Use EC2 Spot Instances for non-production environments
- Set up auto-scaling if needed
- Monitor instance usage and resize accordingly
- Consider using AWS Elastic Beanstalk or ECS for easier management

