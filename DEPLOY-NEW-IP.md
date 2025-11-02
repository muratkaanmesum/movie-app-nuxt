# Deploy to New EC2 IP: 16.16.198.187

## Quick Deploy

Deploy to your new EC2 instance:

```bash
./scripts/deploy.sh --ec2 16.16.198.187 ~/.ssh/your-key.pem ubuntu
```

## Important: SSL Certificate

Since you have a **new IP address**, you need to regenerate the SSL certificate with the new IP.

The deploy script will automatically:
- ✅ Detect the new IP
- ✅ Generate SSL certificate with the new IP (CN=16.16.198.187)
- ✅ Set up nginx with the new certificate

## Manual SSL Certificate Regeneration (if needed)

If the automatic generation doesn't work, SSH in and regenerate manually:

```bash
# SSH into your new EC2 instance
ssh -i ~/.ssh/your-key.pem ubuntu@16.16.198.187
cd ~/movie-app-nuxt

# Get your EC2 IP (should show 16.16.198.187)
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "EC2 IP: $EC2_IP"

# Remove old certificates
rm -f nginx/ssl/cert.pem nginx/ssl/key.pem

# Generate new certificate with new IP
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/ssl/key.pem \
    -out nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$EC2_IP"

# Set permissions
chmod 644 nginx/ssl/cert.pem
chmod 600 nginx/ssl/key.pem

# Restart nginx
docker-compose restart nginx

# Verify
openssl x509 -in nginx/ssl/cert.pem -noout -subject
# Should show: subject=CN = 16.16.198.187
```

## Update Security Group

Make sure your EC2 security group allows:
- ✅ Port 22 (SSH) from your IP
- ✅ Port 80 (HTTP) from anywhere (0.0.0.0/0)
- ✅ Port 443 (HTTPS) from anywhere (0.0.0.0/0)

## Verify Deployment

After deployment:

```bash
# Test HTTP (should redirect to HTTPS)
curl -I http://16.16.198.187

# Test HTTPS (should work with cert warning)
curl -k -I https://16.16.198.187

# In browser
# Visit: https://16.16.198.187
# Click "Advanced" → "Proceed to site" (normal for self-signed cert)
```

## Health Check

Use the health check script:

```bash
./scripts/check-deployment.sh 16.16.198.187 ~/.ssh/your-key.pem ubuntu
```

## Troubleshooting

### If you get 526 error:
- The SSL certificate CN doesn't match the new IP
- Regenerate certificate with the new IP (see above)

### If you can't connect:
- Check security group allows SSH from your IP
- Verify instance is running
- Check SSH key is correct

### If app doesn't load:
- Check containers are running: `docker-compose ps`
- Check logs: `docker-compose logs`
- Verify nginx config: `docker exec nginx-proxy nginx -t`

