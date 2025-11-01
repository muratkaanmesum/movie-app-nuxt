# Troubleshooting Deployment Issues

## npm ci Hangs or Takes Too Long

If `npm ci` hangs during Docker build, try these solutions:

### 1. Check Network Connection

```bash
# Test npm registry connectivity
npm ping

# If ping fails, try clearing npm cache
npm cache clean --force
```

### 2. Use npm install Instead

If `npm ci` continues to hang, you can temporarily switch to `npm install`:

Edit `Dockerfile`:
```dockerfile
# Change from:
RUN npm ci --legacy-peer-deps && npm cache clean --force

# To:
RUN npm install --legacy-peer-deps && npm cache clean --force
```

### 3. Increase Docker Resources

If Docker doesn't have enough resources, npm install can hang:

- **macOS**: Docker Desktop → Settings → Resources
  - Increase Memory to at least 4GB
  - Increase CPU to at least 2 cores
  - Increase Disk image size if needed

### 4. Build with Verbose Output

See what's happening during build:

```bash
docker-compose build --progress=plain --no-cache
```

### 5. Check npm Registry Mirror

If you're behind a firewall or have slow connection, try using a registry mirror:

Edit `Dockerfile` to add before npm install:
```dockerfile
RUN npm config set registry https://registry.npmjs.org/
# Or use a mirror:
# RUN npm config set registry https://registry.npmmirror.com/
```

### 6. Use BuildKit with Better Caching

Enable BuildKit for better build performance:

```bash
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
docker-compose build
```

### 7. Manual Build Steps

If all else fails, build step by step:

```bash
# Build only the npm install step
docker build --target builder -t movie-app-builder .

# Or run npm install interactively
docker run -it --rm -v $(pwd):/app -w /app node:20 bash
npm install --legacy-peer-deps
exit

# Then build normally
docker-compose build
```

## Common Issues

### "Cannot connect to npm registry"

**Solution:**
```bash
# Check if you're behind a corporate proxy
npm config get proxy
npm config get https-proxy

# Set proxy if needed
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

### "ENOSPC: no space left on device"

**Solution:**
```bash
# Check disk space
df -h

# Clean Docker system
docker system prune -a --volumes

# Check Docker disk usage
docker system df
```

### "Error: EACCES: permission denied"

**Solution:**
```bash
# Fix npm permissions (if running locally)
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules

# Or in Dockerfile, use proper user
# Add before npm commands:
RUN chown -R node:node /app
USER node
```

## Faster Builds

### Use Multi-Stage Build

Use the optimized Dockerfile:

```bash
# Copy optimized Dockerfile
cp Dockerfile.optimized Dockerfile

# Or update docker-compose.yml to use it
# services:
#   movie-app:
#     build:
#       context: .
#       dockerfile: Dockerfile.optimized
```

### Enable Build Cache

```bash
# Build with cache
docker-compose build

# Or rebuild without cache
docker-compose build --no-cache
```

### Use .dockerignore

Make sure `.dockerignore` is properly configured to exclude:
- `node_modules` (will be installed in container)
- `.git` directory
- Build artifacts
- Documentation files

## Check Build Progress

```bash
# Build with progress
docker-compose build --progress=plain

# Watch build logs in real-time
docker-compose build 2>&1 | tee build.log

# Check Docker build logs
docker logs <container-id>
```

## Alternative: Build Locally, Copy to Container

If npm install continues to fail in Docker:

```bash
# Build locally first
npm install
npm run build

# Then copy to Docker (modify Dockerfile to skip build)
# Or use a volume mount for development
```

## Get Help

If issues persist:

1. Check Docker logs: `docker-compose logs`
2. Check npm logs: `npm config list`
3. Try building a minimal test image:
   ```dockerfile
   FROM node:20
   RUN npm install -g npm@latest
   RUN npm ping
   ```

