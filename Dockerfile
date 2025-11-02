# Multi-stage Dockerfile with builder pattern
# Stage 1: Builder (install dependencies and build)
FROM node:20 AS builder

WORKDIR /app

# Copy package files (including package-lock.json if it exists)
COPY package*.json ./

# Install all dependencies (including devDependencies for build)
# Don't set NODE_ENV=production yet, so devDependencies are installed
RUN npm install --legacy-peer-deps && \
    npm cache clean --force

# Verify @nuxtjs/tailwindcss is installed
RUN npm list @nuxtjs/tailwindcss || npm install @nuxtjs/tailwindcss --legacy-peer-deps --save-dev

# Copy application code
COPY . .

# Set build-time environment variables (after dependencies are installed)
ENV NODE_ENV=production
ENV NITRO_PRESET=node-server

# Build the application with verbose output
# Nitro build can take 2-5 minutes depending on app size
RUN npm run build || (echo "Build failed. Check logs above." && exit 1)

# Stage 2: Production (smaller image with only runtime dependencies)
FROM node:20-alpine AS production

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production --legacy-peer-deps && \
    npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /app/.output ./.output

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
