package com.secureplatform.config;

import com.secureplatform.model.ERole;
import com.secureplatform.model.Role;
import com.secureplatform.model.User;
import com.secureplatform.repository.RoleRepository;
import com.secureplatform.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

/**
 * Data Initializer
 * Creates default roles and users for the system
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        initializeRoles();
        initializeDefaultUsers();
    }

    private void initializeRoles() {
        // Create default roles
        Role userRole = new Role(ERole.ROLE_USER, "Standard user with basic access");
        Role adminRole = new Role(ERole.ROLE_ADMIN, "Administrator with full system access");
        Role modRole = new Role(ERole.ROLE_MODERATOR, "Moderator with content management privileges");

        roleRepository.save(userRole);
        roleRepository.save(adminRole);
        roleRepository.save(modRole);

        System.out.println("✅ Default roles initialized successfully");
    }

    private void initializeDefaultUsers() {
        // Create admin user
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User("admin", "admin@secureplatform.com", "Admin123!");
            admin.setPassword(passwordEncoder.encode("Admin123!"));
            
            Set<Role> adminRoles = new HashSet<>();
            adminRoles.add(roleRepository.findByName(ERole.ROLE_ADMIN).orElseThrow());
            admin.setRoles(adminRoles);
            admin.setEnabled(true);
            admin.setAccountNonExpired(true);
            admin.setAccountNonLocked(true);
            admin.setCredentialsNonExpired(true);
            
            userRepository.save(admin);
            System.out.println("✅ Admin user created: admin/Admin123!");
        }

        // Create test user
        if (!userRepository.existsByUsername("user")) {
            User user = new User("user", "user@secureplatform.com", "User123!");
            user.setPassword(passwordEncoder.encode("User123!"));
            
            Set<Role> userRoles = new HashSet<>();
            userRoles.add(roleRepository.findByName(ERole.ROLE_USER).orElseThrow());
            user.setRoles(userRoles);
            user.setEnabled(true);
            user.setAccountNonExpired(true);
            user.setAccountNonLocked(true);
            user.setCredentialsNonExpired(true);
            
            userRepository.save(user);
            System.out.println("✅ Test user created: user/User123!");
        }

        // Create moderator user
        if (!userRepository.existsByUsername("moderator")) {
            User moderator = new User("moderator", "moderator@secureplatform.com", "Moderator123!");
            moderator.setPassword(passwordEncoder.encode("Moderator123!"));
            
            Set<Role> modRoles = new HashSet<>();
            modRoles.add(roleRepository.findByName(ERole.ROLE_MODERATOR).orElseThrow());
            moderator.setRoles(modRoles);
            moderator.setEnabled(true);
            moderator.setAccountNonExpired(true);
            moderator.setAccountNonLocked(true);
            moderator.setCredentialsNonExpired(true);
            
            userRepository.save(moderator);
            System.out.println("✅ Moderator user created: moderator/Moderator123!");
        }

        System.out.println("✅ Default users initialized successfully");
    }
}
