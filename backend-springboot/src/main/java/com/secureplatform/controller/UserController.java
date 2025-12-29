package com.secureplatform.controller;

import com.secureplatform.model.User;
import com.secureplatform.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * User Controller
 * Handles user management endpoints
 */
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/me")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<?> getCurrentUser(@RequestParam(required = false) Long userId) {
        try {
            Optional<User> user;
            if (userId != null) {
                user = userService.findById(userId);
            } else {
                // In real app, get from SecurityContext
                return ResponseEntity.badRequest().body("User ID required");
            }

            if (user.isPresent()) {
                User currentUser = user.get();
                return ResponseEntity.ok(new UserSummary(
                    currentUser.getId(),
                    currentUser.getUsername(),
                    currentUser.getEmail(),
                    currentUser.getLastLoginAt(),
                    currentUser.getFailedLoginAttempts()
                ));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthController.MessageResponse("Error: " + e.getMessage()));
        }
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String search) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<User> users;

            if (search != null && !search.trim().isEmpty()) {
                users = userService.getUserRepository().findByUsernameContainingOrEmailContaining(search, pageable);
            } else {
                users = userService.getUserRepository().findAll(pageable);
            }

            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthController.MessageResponse("Error: " + e.getMessage()));
        }
    }

    @GetMapping("/active")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getActiveUsers() {
        try {
            List<User> activeUsers = userService.getUserRepository().findAllActiveUsers();
            return ResponseEntity.ok(activeUsers);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthController.MessageResponse("Error: " + e.getMessage()));
        }
    }

    @GetMapping("/security")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getUsersWithSecurityIssues() {
        try {
            List<User> usersWithIssues = userService.getUserRepository().findUsersWithFailedLoginAttempts();
            return ResponseEntity.ok(usersWithIssues);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthController.MessageResponse("Error: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateUser(
            @PathVariable Long id,
            @RequestBody UserUpdateRequest request) {
        try {
            User updatedUser = userService.updateUser(id, request.getUsername(), request.getEmail());
            return ResponseEntity.ok(new UserSummary(
                updatedUser.getId(),
                updatedUser.getUsername(),
                updatedUser.getEmail(),
                updatedUser.getLastLoginAt(),
                updatedUser.getFailedLoginAttempts()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthController.MessageResponse("Error: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok(new AuthController.MessageResponse("User deleted successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthController.MessageResponse("Error: " + e.getMessage()));
        }
    }

    // DTO for user summary
    public static class UserSummary {
        private Long id;
        private String username;
        private String email;
        private java.time.LocalDateTime lastLoginAt;
        private Integer failedLoginAttempts;

        public UserSummary() {}

        public UserSummary(Long id, String username, String email, java.time.LocalDateTime lastLoginAt, Integer failedLoginAttempts) {
            this.id = id;
            this.username = username;
            this.email = email;
            this.lastLoginAt = lastLoginAt;
            this.failedLoginAttempts = failedLoginAttempts;
        }

        // Getters
        public Long getId() { return id; }
        public String getUsername() { return username; }
        public String getEmail() { return email; }
        public java.time.LocalDateTime getLastLoginAt() { return lastLoginAt; }
        public Integer getFailedLoginAttempts() { return failedLoginAttempts; }
    }

    // DTO for user update
    public static class UserUpdateRequest {
        private String username;
        private String email;

        public UserUpdateRequest() {}

        public UserUpdateRequest(String username, String email) {
            this.username = username;
            this.email = email;
        }

        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
    }
}
