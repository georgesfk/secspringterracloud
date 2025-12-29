package com.secureplatform.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Test Security Configuration
 * Provides test user details for unit testing
 */
@TestConfiguration
public class TestSecurityConfig {

    @Bean
    @Primary
    public UserDetailsService userDetailsService() {
        return new TestUserDetailsService();
    }

    private static class TestUserDetailsService implements UserDetailsService {
        
        @Override
        public User loadUserByUsername(String username) throws UsernameNotFoundException {
            if ("testuser".equals(username)) {
                return User.withUsername("testuser")
                        .password("password")
                        .authorities(getAuthorities("ROLE_USER"))
                        .build();
            } else if ("admin".equals(username)) {
                return User.withUsername("admin")
                        .password("password")
                        .authorities(getAuthorities("ROLE_ADMIN"))
                        .build();
            }
            throw new UsernameNotFoundException("User not found");
        }

        private Collection<? extends GrantedAuthority> getAuthorities(String... roles) {
            return Arrays.stream(roles)
                    .map(role -> new SimpleGrantedAuthority(role))
                    .collect(Collectors.toList());
        }
    }
}
