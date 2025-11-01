FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create directories for SSL certificates and certbot
RUN mkdir -p /etc/nginx/ssl /var/www/certbot /var/log/nginx

# Expose ports
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

