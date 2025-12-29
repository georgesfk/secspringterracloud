import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean> | Promise<boolean> | boolean {
    
    // Check if user is authenticated
    if (this.authService.isAuthenticated()) {
      // Validate session security
      if (this.authService.validateSession()) {
        // Check role-based access if required
        const requiredRoles = route.data['roles'] as Array<string>;
        if (requiredRoles && requiredRoles.length > 0) {
          const hasRequiredRole = requiredRoles.some(role => this.authService.hasRole(role));
          if (!hasRequiredRole) {
            console.warn('🛡️ Access denied - insufficient role permissions');
            this.router.navigate(['/unauthorized']);
            return false;
          }
        }
        return true;
      }
    }

    // User is not authenticated, redirect to login
    console.log('🔒 Authentication required - redirecting to login');
    this.router.navigate(['/login'], { queryParams: { returnUrl: state.url } });
    return false;
  }
}
