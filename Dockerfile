FROM node:20

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

EXPOSE 3000
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

CMD ["npm", "run", "start"]
