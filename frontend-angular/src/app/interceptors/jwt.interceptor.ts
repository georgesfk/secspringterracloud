import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { environment } from '../../environments/environment';

@Injectable()
export class JwtInterceptor implements HttpInterceptor {

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    // Get JWT token from auth service
    const token = this.authService.getToken();
    
    // Add authorization header with JWT token if available
    if (token && !this.authService.isTokenExpired(token)) {
      request = request.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`
        }
      });
    }

    // Add security headers for DevSecOps
    request = request.clone({
      setHeaders: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY'
      }
    });

    return next.handle(request).pipe(
      catchError((error: HttpErrorResponse) => {
        // Handle 401 Unauthorized responses
        if (error.status === 401) {
          // Token is invalid or expired
          this.authService.logout();
          this.router.navigate(['/login']);
        }
        
        // Handle 403 Forbidden responses
        if (error.status === 403) {
          console.warn('🛡️ Access forbidden - insufficient permissions');
        }

        // Log security-related errors for DevSecOps monitoring
        if (error.status >= 400 && error.status < 500) {
          console.warn(`🔒 Security Event: ${error.status} - ${error.message}`);
        }

        return throwError(() => error);
      })
    );
  }
}
