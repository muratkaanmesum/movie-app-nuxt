# Fix 526 "Invalid SSL Certificate" Error

## What is Error 526?

The **526 error** means "Invalid SSL Certificate" - nginx or your browser/Cloudflare is rejecting the SSL certificate.

## Common Causes

1. **Self-signed certificate** - Browsers/Cloudflare reject self-signed certs
2. **Certificate CN mismatch** - Certificate Common Name doesn't match your domain/IP
3. **Missing certificates** - SSL certs not found or not accessible
4. **Cloudflare in front** - Cloudflare requires valid certificates

## Quick Fixes

### Fix 1: Regenerate Certificate with Correct IP

SSH into your EC2 instance and regenerate the certificate with your EC2 IP:

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@13.62.54.14
cd ~/movie-app-nuxt

# Get your EC2 IP
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "EC2 IP: $EC2_IP"

# Remove old certificates
rm -f nginx/ssl/cert.pem nginx/ssl/key.pem

# Generate new certificate with correct IP
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/ssl/key.pem \
    -out nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$EC2_IP"

# Set permissions
chmod 644 nginx/ssl/cert.pem
chmod 600 nginx/ssl/key.pem

# Restart nginx
docker-compose restart nginx
```

### Fix 2: Check Certificate Validity

```bash
# On EC2
cd ~/movie-app-nuxt
openssl x509 -in nginx/ssl/cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not After)"

# Should show:
# Subject: CN=13.62.54.14 (your EC2 IP)
# Issuer: CN=13.62.54.14
```

### Fix 3: Verify nginx Can Read Certificates

```bash
# On EC2
docker exec nginx-proxy ls -la /etc/nginx/ssl/

# Should show cert.pem and key.pem
```

### Fix 4: Test nginx Configuration

```bash
# On EC2
docker exec nginx-proxy nginx -t

# Should show: "test is successful"
```

### Fix 5: Check Container Logs

```bash
# On EC2
docker-compose logs nginx | tail -50
docker-compose logs movie-app | tail -50

# Look for SSL errors or connection issues
```

### Fix 6: Test Direct Access

```bash
# Test HTTP (should redirect)
curl -I http://13.62.54.14

# Test HTTPS (should work but show cert warning)
curl -k -I https://13.62.54.14
```

### Fix 7: If Using Cloudflare

**Important**: If you're using Cloudflare in front of your EC2:

1. **Disable Cloudflare SSL** - Set SSL mode to "Flexible" or "Full (strict)"
2. **Use Let's Encrypt** - Get a real certificate instead of self-signed
3. **Or disable HTTPS** - Use HTTP only behind Cloudflare

## Step-by-Step Fix

### Option A: Regenerate SSL Certificate (Recommended)

```bash
# 1. SSH into EC2
ssh -i ~/.ssh/your-key.pem ubuntu@13.62.54.14

# 2. Go to project directory
cd ~/movie-app-nuxt

# 3. Get EC2 IP
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Using IP: $EC2_IP"

# 4. Remove old certificates
rm -f nginx/ssl/*.pem

# 5. Generate new certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/ssl/key.pem \
    -out nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$EC2_IP"

# 6. Set permissions
chmod 644 nginx/ssl/cert.pem
chmod 600 nginx/ssl/key.pem

# 7. Restart services
docker-compose restart nginx

# 8. Test
curl -k -I https://$EC2_IP
```

### Option B: Use Let's Encrypt (Production)

If you have a domain pointing to your EC2 IP:

```bash
# On EC2
cd ~/movie-app-nuxt

# Install certbot if not installed
sudo apt-get update
sudo apt-get install -y certbot

# Get certificate (replace with your domain)
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem nginx/ssl/key.pem

# Set permissions
sudo chmod 644 nginx/ssl/cert.pem
sudo chmod 600 nginx/ssl/key.pem
sudo chown $USER:$USER nginx/ssl/*.pem

# Restart nginx
docker-compose restart nginx
```

### Option C: Disable HTTPS Temporarily (Testing)

If you just want to test, you can temporarily disable HTTPS:

Edit `nginx/nginx.conf` and comment out the HTTPS server block, or use HTTP only.

## Verify Fix

After applying fixes:

```bash
# Test HTTP
curl -I http://13.62.54.14
# Should show: 301 redirect to HTTPS

# Test HTTPS
curl -k -I https://13.62.54.14
# Should show: 200 OK (with self-signed cert warning)

# In browser
# Visit: https://13.62.54.14
# Click "Advanced" → "Proceed to site" (for self-signed cert)
```

## Common Issues

### Issue: "certificate signed by unknown authority"

**Solution**: This is normal for self-signed certificates. In browser:

1. Click "Advanced"
2. Click "Proceed to site"

### Issue: Certificate doesn't match domain

**Solution**: Regenerate certificate with correct IP or domain name in CN field.

### Issue: Cloudflare 526 error

**Solution**:

1. Go to Cloudflare → SSL/TLS settings
2. Set SSL mode to "Full" or "Full (strict)"
3. Or use Let's Encrypt certificate

### Issue: nginx can't find certificates

**Solution**:

1. Check certificates exist: `ls -la nginx/ssl/`
2. Check permissions: `chmod 644 nginx/ssl/cert.pem`
3. Check docker volume mount in `docker-compose.yml`

## Use the Health Check Script

I've created a health check script to diagnose issues:

```bash
./scripts/check-deployment.sh 13.62.54.14 ~/.ssh/your-key.pem ubuntu
```

This will check:

- Container status
- SSL certificates
- Nginx configuration
- App accessibility

## Still Having Issues?

1. **Check logs**:

   ```bash
   docker-compose logs nginx
   docker-compose logs movie-app
   ```

2. **Verify services are running**:

   ```bash
   docker-compose ps
   ```

3. **Test nginx config**:

   ```bash
   docker exec nginx-proxy nginx -t
   ```

4. **Check SSL certificate**:
   ```bash
   openssl x509 -in nginx/ssl/cert.pem -text -noout
   ```
