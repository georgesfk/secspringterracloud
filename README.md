# 🛡️ Secure Fullstack DevSecOps Cloud Platform

A comprehensive, production-ready full-stack application with integrated DevSecOps practices, containerization, Kubernetes deployment, and multi-cloud infrastructure support.

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Development](#-development)
- [Security](#-security)
- [Deployment](#-deployment)
- [Infrastructure](#-infrastructure)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring](#-monitoring)
- [Contributing](#-contributing)

## 🌟 Overview

This project demonstrates a complete DevSecOps implementation with:

- **Frontend**: Angular with JWT authentication and security hardening
- **Backend**: Spring Boot with Spring Security, JWT, and comprehensive security controls
- **Containerization**: Multi-stage Docker builds with security best practices
- **Orchestration**: Kubernetes with RBAC, NetworkPolicies, and security contexts
- **Infrastructure**: Terraform IaC for both AWS EKS and Google Cloud GKE
- **Security**: Integrated SAST, DAST, container scanning, and secrets management
- **CI/CD**: GitHub Actions with comprehensive security scanning and automated deployment

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Angular SPA   │    │  Spring Boot    │    │   PostgreSQL    │
│   (Port 4200)   │◄──►│   (Port 8080)   │◄──►│   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Nginx       │    │   Redis Cache   │    │  Cloud Storage  │
│   (Port 80)     │    │   (Port 6379)   │    │      S3/GCS     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Kubernetes     │    │  Load Balancer  │    │   Monitoring    │
│   (EKS/GKE)     │    │   (ALB/CLB)     │    │ (Prometheus)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## ✨ Features

### 🔐 Security Features
- **Authentication & Authorization**: JWT-based with Spring Security
- **API Security**: Rate limiting, CORS, CSRF protection
- **Container Security**: Non-root execution, minimal images, vulnerability scanning
- **Network Security**: Kubernetes NetworkPolicies, service mesh ready
- **Secrets Management**: External Secrets Operator, cloud-native secret stores
- **Input Validation**: Comprehensive validation and sanitization
- **Security Headers**: CSP, HSTS, X-Frame-Options, and more

### 🛠️ DevOps Features
- **Infrastructure as Code**: Terraform for AWS EKS and Google Cloud GKE
- **Container Orchestration**: Kubernetes with advanced security configurations
- **CI/CD Pipeline**: GitHub Actions with automated testing and deployment
- **Monitoring**: Prometheus metrics, health checks, logging
- **Auto-scaling**: Horizontal and vertical pod autoscaling
- **Service Mesh**: Ready for Istio or Linkerd integration

### 🚀 Performance Features
- **Caching**: Redis integration for session and data caching
- **CDN Ready**: Static asset optimization and CDN integration
- **Database Optimization**: Connection pooling and query optimization
- **Load Balancing**: Multi-instance deployment with health checks
- **Resource Management**: CPU and memory limits with resource quotas

## 🚀 Quick Start

### Prerequisites

- **Development**:
  - Java 17+
  - Node.js 18+
  - Angular CLI
  - Docker & Docker Compose

- **Production**:
  - Kubernetes cluster (EKS/GKE)
  - Terraform
  - kubectl
  - Helm (optional)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd secure-fullstack-devsecops-cloud
   ```

2. **Backend Setup**
   ```bash
   cd backend-springboot
   ./mvnw spring-boot:run
   ```

3. **Frontend Setup**
   ```bash
   cd frontend-angular
   npm install
   ng serve
   ```

4. **Access the application**
   - Frontend: http://localhost:4200
   - Backend API: http://localhost:8080
   - API Documentation: http://localhost:8080/v3/api-docs

### Docker Deployment

1. **Build and run with Docker Compose**
   ```bash
   docker-compose up --build
   ```

2. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080

### Kubernetes Deployment

1. **Deploy to Kubernetes**
   ```bash
   kubectl apply -f backend-deployment.yaml
   kubectl apply -f frontend-deployment.yaml
   kubectl apply -f rbac.yaml
   kubectl apply -f networkpolicy.yaml
   ```

2. **Verify deployment**
   ```bash
   kubectl get pods
   kubectl get services
   ```

## 🛠️ Development

### Backend Development

**Technology Stack**:
- Spring Boot 3.2.0
- Spring Security with JWT
- Spring Data JPA
- PostgreSQL
- Redis
- Spring Actuator

**Key Components**:
- `DemoController.java`: Simplified REST endpoints
- `application.yml`: Environment-specific configuration
- Security configuration with JWT authentication
- Comprehensive validation and error handling

**Running Tests**:
```bash
cd backend-springboot
./mvnw test
```

**API Endpoints**:
- `GET /api/hello` - Basic health check
- `GET /api/health` - Detailed health status
- `GET /api/security` - Security status check

### Frontend Development

**Technology Stack**:
- Angular 16+
- Angular Material
- TypeScript
- SCSS
- RxJS for reactive programming

**Key Components**:
- Authentication service with JWT handling
- HTTP interceptors for automatic token management
- Route guards for protected routes
- Material Design UI components

**Running Tests**:
```bash
cd frontend-angular
ng test
```

**Building for Production**:
```bash
ng build --prod
```

## 🔒 Security

### Security Scanning Tools

- **SAST**: Semgrep with custom rules
- **Secrets Detection**: Gitleaks
- **DAST**: OWASP ZAP integration
- **Container Scanning**: Trivy
- **Dependency Scanning**: OWASP Dependency Check

### Running Security Scans

```bash
# Secrets detection
gitleaks detect --source .

# SAST scanning
semgrep --config=.security-configs/semgrep-rules.yml .

# Container scanning
trivy fs .

# OWASP ZAP (requires running application)
zap-baseline.py -t http://localhost:8080
```

### Security Features

1. **Authentication & Authorization**
   - JWT-based stateless authentication
   - Role-based access control (RBAC)
   - Session management with Redis

2. **API Security**
   - Rate limiting (100 requests/minute)
   - CORS configuration
   - Input validation and sanitization
   - SQL injection prevention

3. **Container Security**
   - Non-root user execution
   - Minimal base images
   - Security context constraints
   - Read-only file systems

4. **Network Security**
   - Kubernetes NetworkPolicies
   - Service mesh integration ready
   - TLS/SSL termination at ingress

## ☁️ Infrastructure

### AWS EKS Deployment

1. **Configure Terraform variables**
   ```bash
   cd terraform/aws
   cp variables.tf.example variables.tf
   # Edit variables.tf with your AWS configuration
   ```

2. **Initialize and apply Terraform**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name secure-devsecops-cloud-eks-dev
   ```

### Google Cloud GKE Deployment

1. **Configure Terraform variables**
   ```bash
   cd terraform/gcp
   cp variables.tf.example variables.tf
   # Edit variables.tf with your GCP configuration
   ```

2. **Initialize and apply Terraform**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Configure kubectl**
   ```bash
   gcloud container clusters get-credentials secure-devsecops-cloud-gke-dev --region us-central1
   ```

### Infrastructure Features

- **Multi-Cloud Support**: AWS EKS and Google Cloud GKE
- **High Availability**: Multi-zone deployment
- **Auto-scaling**: Cluster and pod autoscaling
- **Security**: Private clusters, encryption at rest
- **Monitoring**: Integrated cloud monitoring
- **Cost Optimization**: Spot instances and resource optimization

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The CI/CD pipeline includes:

1. **Code Quality Checks**
   - Code formatting and linting
   - Unit and integration tests
   - Code coverage reports

2. **Security Scanning**
   - Gitleaks for secret detection
   - Semgrep for SAST analysis
   - Trivy for container vulnerability scanning
   - OWASP ZAP for DAST testing

3. **Build and Deploy**
   - Docker image building and scanning
   - Kubernetes deployment
   - Infrastructure provisioning with Terraform
   - Health checks and smoke tests

### Pipeline Configuration

```yaml
# .github/workflows/devsecops.yml
name: DevSecOps Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2
      - name: Run Semgrep
        uses: semgrep/semgrep-action@v1
      - name: Run Trivy
        uses: aquasecurity/trivy-action@master

  build-and-deploy:
    needs: security-scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker Image
        run: docker build -t secure-app .
      - name: Deploy to Kubernetes
        run: kubectl apply -f k8s/
```

## 📊 Monitoring

### Application Monitoring

- **Health Checks**: Spring Boot Actuator endpoints
- **Metrics**: Prometheus-compatible metrics
- **Logging**: Structured logging with correlation IDs
- **Tracing**: OpenTelemetry integration ready

### Infrastructure Monitoring

- **Cluster Monitoring**: Kubernetes cluster health
- **Resource Monitoring**: CPU, memory, and storage usage
- **Security Monitoring**: Audit logs and security events
- **Cost Monitoring**: Cloud cost tracking and optimization

### Access Monitoring

```bash
# Application health
curl http://localhost:8080/actuator/health

# Prometheus metrics
curl http://localhost:8080/actuator/prometheus

# Kubernetes cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

## 🧪 Testing

### Test Types

1. **Unit Tests**: Component and service testing
2. **Integration Tests**: API endpoint testing
3. **Security Tests**: Authentication and authorization testing
4. **Performance Tests**: Load and stress testing
5. **Container Tests**: Docker image security testing

### Running Tests

```bash
# Backend tests
cd backend-springboot
./mvnw test

# Frontend tests
cd frontend-angular
ng test

# Security tests
./scripts/security-scan.sh

# Performance tests
k6 run scripts/performance-test.js
```

## 📝 Configuration

### Environment Variables

**Backend Configuration**:
```yaml
# application.yml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
  redis:
    host: ${REDIS_HOST}
    password: ${REDIS_PASSWORD}

jwt:
  secret: ${JWT_SECRET}
  expiration: ${JWT_EXPIRATION}
```

**Frontend Configuration**:
```typescript
// environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080',
  jwtTokenKey: 'auth_token'
};
```

## 🔧 Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Find process using port 8080
   lsof -i :8080
   
   # Kill the process
   kill -9 <PID>
   ```

2. **Docker Build Failures**
   ```bash
   # Clear Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker build --no-cache -t secure-app .
   ```

3. **Kubernetes Deployment Issues**
   ```bash
   # Check pod status
   kubectl describe pod <pod-name>
   
   # Check logs
   kubectl logs <pod-name>
   
   # Check events
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

4. **Database Connection Issues**
   ```bash
   # Test database connectivity
   telnet <database-host> 5432
   
   # Check database credentials
   echo $DATABASE_URL
   ```

## 📚 Documentation

### Additional Resources

- [Security Best Practices](./docs/SECURITY.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)
- [API Documentation](./docs/API.md)
- [Monitoring Guide](./docs/MONITORING.md)
- [Troubleshooting Guide](./docs/TROUBLESHOOTING.md)

### External Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Spring Security Reference](https://docs.spring.io/spring-security/reference/)
- [Angular Security Guide](https://angular.io/guide/security)

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Run security scans**
   ```bash
   ./scripts/security-scan.sh
   ```
5. **Run tests**
   ```bash
   ./scripts/run-tests.sh
   ```
6. **Commit your changes**
   ```bash
   git commit -m "Add your feature description"
   ```
7. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
8. **Create a Pull Request**

### Contribution Guidelines

- Follow the existing code style and conventions
- Write comprehensive tests for new features
- Ensure all security scans pass
- Update documentation for any changes
- Use semantic commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Support

For questions, issues, or contributions:

- **Issues**: [GitHub Issues](https://github.com/your-org/secure-fullstack-devsecops-cloud/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/secure-fullstack-devsecops-cloud/discussions)
- **Security**: [Security Policy](SECURITY.md)

## 🏆 Acknowledgments

- [Spring Security](https://spring.io/projects/spring-security) for robust security framework
- [Angular](https://angular.io/) for the frontend framework
- [Kubernetes](https://kubernetes.io/) for container orchestration
- [Terraform](https://terraform.io/) for infrastructure as code
- [OWASP](https://owasp.org/) for security guidelines and tools

---

**Built with ❤️ using DevSecOps best practices**

*This project demonstrates enterprise-grade security, scalability, and reliability in modern cloud-native applications.*

# secspringterracloud
