import { Component, OnInit } from '@angular/core';
import { AuthService } from './services/auth.service';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  title = 'Secure Platform';
  currentUser: any = null;
  isAuthenticated = false;

  constructor(
    private authService: AuthService,
    private router: Router
  ) {
    // Subscribe to authentication state changes
    this.authService.currentUser.subscribe(user => {
      this.currentUser = user;
      this.isAuthenticated = !!user;
    });
  }

  ngOnInit(): void {
    // Track navigation for security monitoring
    this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        console.log(`🔒 Navigation: ${event.urlAfterRedirects}`);
      });

    // Enable OWASP ZAP integration if configured
    if (this.authService.currentUserValue) {
      this.authService.enableOWASPZAP();
    }

    // Validate session periodically
    setInterval(() => {
      if (this.isAuthenticated) {
        this.authService.validateSession();
      }
    }, 60000); // Check every minute
  }

  /**
   * Logout user
   */
  logout(): void {
    console.log('🔒 User logout initiated');
    this.authService.logout();
  }

  /**
   * Check if current user has admin role
   */
  isAdmin(): boolean {
    return this.authService.isAdmin();
  }

  /**
   * Check if current user has moderator role
   */
  isModerator(): boolean {
    return this.authService.isModerator();
  }

  /**
   * Get current user's display name
   */
  getCurrentUserName(): string {
    return this.currentUser?.username || 'User';
  }

  /**
   * Get current user's email
   */
  getCurrentUserEmail(): string {
    return this.currentUser?.email || '';
  }

  /**
   * Navigation items for the application
   */
  getNavigationItems() {
    const items = [
      { path: '/dashboard', label: 'Dashboard', icon: 'dashboard', requiresAuth: true },
      { path: '/security', label: 'Security', icon: 'security', requiresAuth: true },
      { path: '/devsecops', label: 'DevSecOps', icon: 'build', requiresAuth: true }
    ];

    // Add admin-only items
    if (this.isAdmin()) {
      items.push(
        { path: '/admin', label: 'Admin', icon: 'admin_panel_settings', requiresAuth: true },
        { path: '/users', label: 'Users', icon: 'people', requiresAuth: true }
      );
    }

    return items.filter(item => !item.requiresAuth || this.isAuthenticated);
  }
}
