package com.secureplatform.service;

import com.secureplatform.model.ERole;
import com.secureplatform.model.Role;
import com.secureplatform.model.User;
import com.secureplatform.repository.RoleRepository;
import com.secureplatform.repository.UserRepository;
import com.secureplatform.security.JwtTokenProvider;
import com.secureplatform.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;

/**
 * Authentication Service
 * Handles login, registration, and JWT token management
 */
@Service
public class AuthService {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Autowired
    private UserService userService;

    @Autowired
    private RoleRepository roleRepository;

    public JwtResponse authenticateUser(String usernameOrEmail, String password) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(usernameOrEmail, password));

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String jwt = tokenProvider.generateToken(authentication);
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        User user = userService.findById(userPrincipal.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Update last login
        userService.updateLastLogin(user.getId(), "127.0.0.1"); // In real app, get from request

        List<String> roles = userPrincipal.getAuthorities().stream()
                .map(item -> item.getAuthority())
                .toList();

        return new JwtResponse(jwt, userPrincipal.getId(), userPrincipal.getUsername(), 
                             userPrincipal.getEmail(), roles);
    }

    public JwtResponse registerUser(String username, String email, String password, Set<String> strRoles) {
        if (userService.findByUsername(username).isPresent()) {
            throw new RuntimeException("Username is already taken!");
        }

        if (userService.findByEmail(email).isPresent()) {
            throw new RuntimeException("Email is already in use!");
        }

        User user = userService.createUser(username, email, password, strRoles);

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(username, password));

        String jwt = tokenProvider.generateToken(authentication);

        List<String> roles = user.getRoles().stream()
                .map(role -> "ROLE_" + role.getName().name())
                .toList();

        return new JwtResponse(jwt, user.getId(), user.getUsername(), user.getEmail(), roles);
    }

    public JwtResponse refreshToken(String refreshToken) {
        if (tokenProvider.validateToken(refreshToken)) {
            Long userId = tokenProvider.getUserIdFromToken(refreshToken);
            User user = userService.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            String newJwt = tokenProvider.generateTokenFromUserId(userId);

            List<String> roles = user.getRoles().stream()
                    .map(role -> "ROLE_" + role.getName().name())
                    .toList();

            return new JwtResponse(newJwt, user.getId(), user.getUsername(), user.getEmail(), roles);
        }

        throw new RuntimeException("Invalid refresh token");
    }

    // Inner class for JWT response
    public static class JwtResponse {
        private String accessToken;
        private String tokenType = "Bearer";
        private Long id;
        private String username;
        private String email;
        private List<String> roles;

        public JwtResponse(String accessToken, Long id, String username, String email, List<String> roles) {
            this.accessToken = accessToken;
            this.id = id;
            this.username = username;
            this.email = email;
            this.roles = roles;
        }

        // Getters
        public String getAccessToken() { return accessToken; }
        public String getTokenType() { return tokenType; }
        public Long getId() { return id; }
        public String getUsername() { return username; }
        public String getEmail() { return email; }
        public List<String> getRoles() { return roles; }
    }
}
