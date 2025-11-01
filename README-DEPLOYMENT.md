# Quick Deployment Guide

## 🚀 Quick Start

### 1. Create EC2 Instance

**Via AWS Console:**
- Launch EC2 instance (Ubuntu 22.04 LTS)
- Create security group with rules:
  - Port 22 (SSH) - from your IP
  - Port 80 (HTTP) - from anywhere
  - Port 443 (HTTPS) - from anywhere
- Select/create key pair
- Launch instance

**Or use AWS CLI:**
```bash
# Create security group
aws ec2 create-security-group \
  --group-name movie-app-sg \
  --description "Movie app security group"

# Allow ports (replace SG_ID with actual group ID)
aws ec2 authorize-security-group-ingress \
  --group-id YOUR_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress \
  --group-id YOUR_SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress \
  --group-id YOUR_SG_ID --protocol tcp --port 22 --cidr YOUR_IP/32

# Launch instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.small \
  --key-name your-key-pair \
  --security-group-ids YOUR_SG_ID \
  --user-data file://ec2-user-data.sh
```

### 2. Connect and Deploy

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Clone your repository
git clone YOUR_REPO_URL
cd movie-app-nuxt

# Set environment variable
export NUXT_PUBLIC_TMDB_API_KEY=your_api_key

# Run deployment script
./scripts/deploy.sh

# Or manually:
docker-compose up -d --build
```

### 3. Setup SSL (Production)

For production with a domain:

```bash
# Setup Let's Encrypt SSL
./scripts/setup-ssl.sh yourdomain.com your@email.com

# Update nginx config with your domain
# Edit nginx/nginx.conf and replace server_name
```

For testing (self-signed cert):
```bash
# Already included in deploy.sh, or run:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

### 4. Verify

- Visit `http://YOUR_EC2_IP` (should redirect to HTTPS)
- Visit `https://YOUR_EC2_IP` (or your domain)

## 📝 Configuration Files Created

- `nginx/nginx.conf` - nginx reverse proxy configuration
- `nginx/Dockerfile` - nginx container image
- `docker-compose.yml` - Updated with nginx service
- `DEPLOYMENT.md` - Detailed deployment guide
- `ec2-user-data.sh` - EC2 initialization script
- `scripts/setup-ssl.sh` - SSL certificate setup
- `scripts/deploy.sh` - Quick deployment script
- `aws-security-group.json` - Security group template

## 🔒 Security Notes

1. **Firewall**: EC2 security group handles external access
2. **SSL**: Use Let's Encrypt for production (free SSL certificates)
3. **Secrets**: Never commit API keys - use environment variables
4. **Access**: Consider restricting SSH (port 22) to your IP only

## 🐛 Troubleshooting

```bash
# Check logs
docker-compose logs -f

# Check nginx specifically
docker-compose logs nginx

# Restart services
docker-compose restart

# Rebuild and restart
docker-compose down && docker-compose up -d --build
```

For detailed troubleshooting, see [DEPLOYMENT.md](./DEPLOYMENT.md).

