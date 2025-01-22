# Step 1: Use Node.js as the base image to build the React app
FROM node:16-alpine AS build
# Set the working directory
WORKDIR /app
# Copy package.json and package-lock.json
COPY package.json package-lock.json ./
# Install dependencies
RUN npm install --force
# Copy the rest of the application code
COPY . .
# Build the React app for production
RUN npm run build

# Step 2: Use Alpine as base image
FROM alpine:3.19

# Install Node.js and nginx
RUN apk add --no-cache \
    nodejs \
    npm \
    nginx

# Copy the built React app
COPY --from=build /app/build /usr/share/nginx/html

# Create app directory for backend
WORKDIR /app
# Copy the backend server
COPY src/server.js ./
COPY package.json ./

# Install production dependencies only
RUN npm install express cors axios --production --force && \
    # Remove npm after installing dependencies to reduce image size
    apk del npm && \
    # Clear npm cache
    rm -rf /root/.npm

# Copy the nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Create nginx run directory
RUN mkdir -p /run/nginx

# Expose ports
EXPOSE 80 3001

# Create startup script in a specific location and make it executable
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'nginx' >> /app/start.sh && \
    echo 'node /app/server.js' >> /app/start.sh && \
    chmod +x /app/start.sh

# Start both nginx and node server using the full path
CMD ["/app/start.sh"]