package com.example;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

@RestController
@CrossOrigin(origins = "*")
public class DemoController {

    @GetMapping("/api/hello")
    public String hello() {
        return "Hello from Secure DevSecOps Cloud Platform!";
    }

    @GetMapping("/api/health")
    public String health() {
        return "OK - Application is healthy and secure";
    }

    @GetMapping("/api/security")
    public String security() {
        return "Security Status: All DevSecOps checks passed!";
    }
}

