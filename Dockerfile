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

# Step 2: Use nginx:alpine and node for both frontend and backend
FROM node:16-alpine

# Install nginx
RUN apk add --no-cache nginx

# Copy the built React app
COPY --from=build /app/build /usr/share/nginx/html

# Copy the backend server
COPY src/server.js /app/
COPY package.json /app/

# Set working directory
WORKDIR /app

# Install production dependencies only
RUN npm install express cors axios --force

# Copy the nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports
EXPOSE 80 3001

# Start both nginx and node server
CMD ["sh", "-c", "nginx && node server.js"]