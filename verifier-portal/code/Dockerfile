# Use official Dart SDK image
FROM dart:stable AS build

# Set workdir
WORKDIR /app

# Copy pubspec files first for better layer caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN dart pub get

# Copy source code (exclude .pub-cache and other build artifacts)
COPY . .

# Remove any local .dart_tool directory that might interfere and get dependencies again
RUN rm -rf .dart_tool && dart pub get

# Verify dependencies are properly resolved
RUN dart pub deps

# Precompile the app
RUN dart compile exe bin/server.dart -o bin/server

# Runtime image - use debian slim instead of scratch for user management
FROM debian:stable-slim

# Create a non-root user
RUN groupadd -r dartapp && useradd -r -g dartapp dartapp

# Copy runtime and app from build stage
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/public /app/public

# Create app directory and set ownership
RUN mkdir -p /app && chown -R dartapp:dartapp /app

# Switch to non-root user
USER dartapp
WORKDIR /app

# Expose port (match your server)
EXPOSE 8081
ENTRYPOINT ["/app/bin/server"]
