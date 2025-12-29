package com.secureplatform;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Main Spring Boot Application for Secure Platform
 * Features: JWT Auth, Spring Security, Actuator, DevSecOps Integration
 */
@SpringBootApplication
@EnableMethodSecurity(prePostEnabled = true)
@EnableTransactionManagement
public class SecurePlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(SecurePlatformApplication.class, args);
    }
}
