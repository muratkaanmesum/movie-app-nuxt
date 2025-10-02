FROM node:20

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production --legacy-peer-deps --silent && npm cache clean --force

COPY . .
RUN npm run build

EXPOSE 3000
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

CMD ["npm", "run", "start"]
