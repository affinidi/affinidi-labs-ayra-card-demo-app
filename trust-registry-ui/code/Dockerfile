# Use Node.js 18 Alpine as the base image for smaller size
FROM node:18-alpine AS base

# Set working directory
WORKDIR /app

# Install necessary system dependencies for building native modules
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Development stage
FROM base AS development
# Install all dependencies including dev dependencies
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Build stage
FROM base AS build
# Install all dependencies for building
RUN npm ci
COPY . .
# Build the TypeScript application and copy assets
RUN npm run build

# Production stage
FROM node:18-alpine AS production

WORKDIR /app

# Install wget for health checks
RUN apk add --no-cache wget

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy built application from build stage (includes views and public)
COPY --from=build /app/dist ./dist

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Change ownership of the app directory
RUN chown -R appuser:appgroup /app
USER appuser

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]