FROM node:20

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies for build)
# Remove --silent flag to see progress
RUN npm ci --legacy-peer-deps && npm cache clean --force

# Copy application code
COPY . .

# Build the application
RUN npm run build

EXPOSE 3000
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

CMD ["npm", "run", "start"]
