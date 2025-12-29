# 🐳 Multi-stage Dockerfile for Secure DevSecOps Cloud Platform
# Build and deploy both frontend and backend components

# Stage 1: Build Angular Frontend
FROM node:18-alpine AS frontend-build

WORKDIR /app/frontend

# Copy package files
COPY frontend-angular/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy frontend source
COPY frontend-angular/ .

# Build Angular application
RUN npm run build --prod

# Stage 2: Build Spring Boot Backend
FROM maven:3.9.4-openjdk-17 AS backend-build

WORKDIR /app

# Copy pom file
COPY backend-springboot/pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY backend-springboot/ .

# Build application
RUN mvn clean package -DskipTests

# Stage 3: Runtime Environment
FROM openjdk:17-jdk-alpine

# Install necessary packages for production
RUN apk add --no-cache \
    curl \
    bash \
    nginx \
    && rm -rf /var/cache/apk/*

# Create application user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p logs temp static && \
    chown -R appuser:appgroup /app

# Copy backend jar from build stage
COPY --from=backend-build /app/target/*.jar app.jar

# Copy built frontend from build stage
COPY --from=frontend-build /app/frontend/dist/ /app/static/

# Configure nginx for serving static files
COPY nginx.conf /etc/nginx/nginx.conf

# Switch to non-root user
USER appuser

# Expose ports
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Start application
CMD ["java", "-jar", "app.jar"]

# 🛡️ Security Labels
LABEL maintainer="Secure DevSecOps Cloud Team" \
      version="1.0.0" \
      description="Secure DevSecOps Cloud Platform with built-in security" \
      security.scan="enabled" \
      compliance="OWASP" \
      devsecops="true"

# Metadata
LABEL org.opencontainers.image.title="Secure DevSecOps Cloud Platform" \
      org.opencontainers.image.description="Full-stack DevSecOps platform with integrated security" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="DevSecOps Team" \
      org.opencontainers.image.licenses="MIT"

