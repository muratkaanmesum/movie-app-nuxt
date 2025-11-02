FROM node:20

WORKDIR /app

# Set build-time environment variables
ENV NODE_ENV=production
ENV NITRO_PRESET=node-server

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies for build)
# Remove --silent flag to see progress
RUN npm ci --legacy-peer-deps && npm cache clean --force

# Copy application code
COPY . .

# Build the application with verbose output
# Nitro build can take 2-5 minutes depending on app size
RUN npm run build || (echo "Build failed. Check logs above." && exit 1)

EXPOSE 3000
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

CMD ["npm", "run", "start"]
