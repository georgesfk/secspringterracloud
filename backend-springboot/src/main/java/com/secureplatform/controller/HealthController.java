package com.secureplatform.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Health Controller
 * Provides health check endpoints for monitoring and DevSecOps
 */
@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now());
        response.put("service", "Secure Platform Backend");
        response.put("version", "1.0.0");
        response.put("security", "ENABLED");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/security/status")
    public ResponseEntity<Map<String, Object>> securityStatus() {
        Map<String, Object> response = new HashMap<>();
        response.put("jwt_authentication", "ENABLED");
        response.put("spring_security", "ENABLED");
        response.put("cors", "CONFIGURED");
        response.put("password_encoding", "BCRYPT");
        response.put("role_based_access", "ENABLED");
        response.put("rate_limiting", "ENABLED");
        response.put("owasp_compliance", "ACTIVE");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/security/scan/owasp-zap")
    public ResponseEntity<Map<String, Object>> owaspZapIntegration() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "READY_FOR_SCAN");
        response.put("endpoints", new String[]{
            "/api/auth/login",
            "/api/auth/register", 
            "/api/users/me",
            "/api/admin/**"
        });
        response.put("security_headers", "CONFIGURED");
        response.put("xss_protection", "ENABLED");
        response.put("csrf_protection", "ENABLED");
        response.put("recommended_zap_config", "passive_scan_config.xml");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/devsecops/info")
    public ResponseEntity<Map<String, Object>> devSecOpsInfo() {
        Map<String, Object> response = new HashMap<>();
        response.put("framework", "Spring Boot DevSecOps Platform");
        response.put("security_tools", new String[]{
            "JWT Authentication",
            "Spring Security", 
            "Spring Actuator",
            "OWASP ZAP Integration",
            "Semgrep Ready",
            "Gitleaks Ready"
        });
        response.put("ci_cd_integration", "GITHUB_ACTIONS");
        response.put("container_ready", "TRUE");
        response.put("kubernetes_ready", "TRUE");
        response.put("cloud_ready", "AWS_EKS_GCP_GKE");
        
        return ResponseEntity.ok(response);
    }
}
