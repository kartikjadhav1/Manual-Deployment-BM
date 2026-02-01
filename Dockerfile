
FROM nginx:alpine

# Copy application files to nginx html directory
COPY /bm2/index.html /usr/share/nginx/html/
COPY /bm2/style.css /usr/share/nginx/html/
COPY /bm2/script.js /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
