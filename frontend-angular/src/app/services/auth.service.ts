import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, throwError } from 'rxjs';
import { map, tap, catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { environment } from '../../environments/environment';
import { JwtResponse, LoginRequest, SignUpRequest, MessageResponse } from '../models/user.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private currentUserSubject: BehaviorSubject<JwtResponse | null>;
  public currentUser: Observable<JwtResponse | null>;

  constructor(
    private http: HttpClient,
    private router: Router
  ) {
    this.currentUserSubject = new BehaviorSubject<JwtResponse | null>(
      this.getUserFromStorage()
    );
    this.currentUser = this.currentUserSubject.asObservable();
  }

  public get currentUserValue(): JwtResponse | null {
    return this.currentUserSubject.value;
  }

  /**
   * Authenticate user with JWT token
   */
  login(usernameOrEmail: string, password: string): Observable<JwtResponse> {
    const loginRequest: LoginRequest = {
      usernameOrEmail: usernameOrEmail,
      password: password
    };

    return this.http.post<JwtResponse>(`${environment.apiUrl}/auth/login`, loginRequest)
      .pipe(
        tap(response => {
          if (response.accessToken) {
            this.storeUser(response);
            this.currentUserSubject.next(response);
          }
        }),
        catchError(error => {
          console.error('Login error:', error);
          return throwError(() => error);
        })
      );
  }

  /**
   * Register new user
   */
  register(username: string, email: string, password: string, role: string[] = ['user']): Observable<JwtResponse> {
    const signUpRequest: SignUpRequest = {
      username: username,
      email: email,
      password: password,
      role: role
    };

    return this.http.post<JwtResponse>(`${environment.apiUrl}/auth/register`, signUpRequest)
      .pipe(
        tap(response => {
          if (response.accessToken) {
            this.storeUser(response);
            this.currentUserSubject.next(response);
          }
        }),
        catchError(error => {
          console.error('Registration error:', error);
          return throwError(() => error);
        })
      );
  }

  /**
   * Refresh JWT token
   */
  refreshToken(refreshToken: string): Observable<JwtResponse> {
    return this.http.post<JwtResponse>(`${environment.apiUrl}/auth/refresh`, { refreshToken })
      .pipe(
        tap(response => {
          if (response.accessToken) {
            this.storeUser(response);
            this.currentUserSubject.next(response);
          }
        }),
        catchError(error => {
          console.error('Token refresh error:', error);
          this.logout();
          return throwError(() => error);
        })
      );
  }

  /**
   * Logout user and clear session
   */
  logout(): void {
    // Remove user from local storage
    localStorage.removeItem(environment.security.jwtTokenKey);
    localStorage.removeItem(environment.security.refreshTokenKey);
    
    // Update current user subject
    this.currentUserSubject.next(null);
    
    // Redirect to login
    this.router.navigate(['/login']);
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated(): boolean {
    const user = this.currentUserValue;
    return user !== null && user.accessToken !== null;
  }

  /**
   * Check if user has specific role
   */
  hasRole(role: string): boolean {
    const user = this.currentUserValue;
    return user?.roles?.includes(role) || false;
  }

  /**
   * Check if user is admin
   */
  isAdmin(): boolean {
    return this.hasRole('ROLE_ADMIN');
  }

  /**
   * Check if user is moderator
   */
  isModerator(): boolean {
    return this.hasRole('ROLE_MODERATOR') || this.isAdmin();
  }

  /**
   * Get JWT token from storage
   */
  getToken(): string | null {
    const user = this.getUserFromStorage();
    return user?.accessToken || null;
  }

  /**
   * Check if token is expired
   */
  isTokenExpired(token?: string): boolean {
    const jwtToken = token || this.getToken();
    if (!jwtToken) return true;

    try {
      const payload = JSON.parse(atob(jwtToken.split('.')[1]));
      const expiry = payload.exp;
      return (Math.floor((new Date).getTime() / 1000)) >= expiry;
    } catch (e) {
      return true;
    }
  }

  /**
   * Store user in local storage
   */
  private storeUser(user: JwtResponse): void {
    localStorage.setItem(environment.security.jwtTokenKey, user.accessToken);
    // Store refresh token if available (implement in backend if needed)
    if (user.refreshToken) {
      localStorage.setItem(environment.security.refreshTokenKey, user.refreshToken);
    }
  }

  /**
   * Get user from local storage
   */
  private getUserFromStorage(): JwtResponse | null {
    try {
      const token = localStorage.getItem(environment.security.jwtTokenKey);
      if (token && !this.isTokenExpired(token)) {
        const payload = JSON.parse(atob(token.split('.')[1]));
        return {
          accessToken: token,
          tokenType: 'Bearer',
          id: payload.id,
          username: payload.sub,
          email: payload.email,
          roles: payload.roles || []
        };
      }
    } catch (e) {
      console.error('Error parsing stored token:', e);
      this.logout();
    }
    return null;
  }

  /**
   * Get current user info
   */
  getCurrentUser(): Observable<any> {
    return this.http.get(`${environment.apiUrl}/users/me`);
  }

  /**
   * Security features for DevSecOps
   */

  /**
   * Enable OWASP ZAP integration
   */
  enableOWASPZAP(): void {
    // Set up proxy configuration for OWASP ZAP
    if (environment.owaspZap.enabled) {
      console.log('🔒 OWASP ZAP integration enabled');
      // Additional proxy setup can be added here
    }
  }

  /**
   * Check security status
   */
  getSecurityStatus(): Observable<any> {
    return this.http.get(`${environment.apiUrl}/security/status`);
  }

  /**
   * Get OWASP ZAP integration status
   */
  getOWASPZapStatus(): Observable<any> {
    return this.http.get(`${environment.apiUrl}/security/scan/owasp-zap`);
  }

  /**
   * Validate session security
   */
  validateSession(): boolean {
    const user = this.currentUserValue;
    if (!user) return false;

    // Check for suspicious activity (DevSecOps)
    const lastActivity = localStorage.getItem('lastActivity');
    const currentTime = new Date().getTime();
    
    if (lastActivity) {
      const inactiveTime = currentTime - parseInt(lastActivity);
      if (inactiveTime > environment.security.sessionTimeout) {
        console.warn('🛡️ Session timeout - forcing logout');
        this.logout();
        return false;
      }
    }
    
    localStorage.setItem('lastActivity', currentTime.toString());
    return true;
  }
}
