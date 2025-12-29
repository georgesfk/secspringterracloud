package com.secureplatform.model;

/**
 * Enumeration of user roles
 * Defines the available user roles in the system
 */
public enum ERole {
    ROLE_USER("Standard user with basic access"),
    ROLE_ADMIN("Administrator with full system access"),
    ROLE_MODERATOR("Moderator with content management privileges");

    private final String description;

    ERole(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
