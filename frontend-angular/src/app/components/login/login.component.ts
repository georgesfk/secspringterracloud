import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  loading = false;
  submitted = false;
  error = '';
  returnUrl: string;

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute
  ) {
    // Redirect to dashboard if already logged in
    if (this.authService.isAuthenticated()) {
      this.router.navigate(['/dashboard']);
    }

    this.loginForm = this.formBuilder.group({
      usernameOrEmail: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    // Get return url from route parameters or default to '/'
    this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/dashboard';
  }

  // Convenience getter for easy access to form fields
  get f() { return this.loginForm.controls; }

  onSubmit() {
    this.submitted = true;
    this.error = '';

    // Stop if form is invalid
    if (this.loginForm.invalid) {
      return;
    }

    this.loading = true;

    this.authService.login(
      this.f.usernameOrEmail.value,
      this.f.password.value
    ).subscribe({
      next: (response) => {
        console.log('✅ Login successful:', response.username);
        this.router.navigate([this.returnUrl]);
      },
      error: (error) => {
        console.error('❌ Login failed:', error);
        this.error = error.error?.message || 'Login failed. Please try again.';
        this.loading = false;
      }
    });
  }

  /**
   * Navigate to registration page
   */
  navigateToRegister() {
    this.router.navigate(['/register']);
  }

  /**
   * Check security status
   */
  checkSecurityStatus() {
    this.authService.getSecurityStatus().subscribe({
      next: (status) => {
        console.log('🔒 Security Status:', status);
        alert('Security Status: All systems operational!\n' + 
              'JWT: ' + status.jwt_authentication + '\n' +
              'Spring Security: ' + status.spring_security);
      },
      error: (error) => {
        console.error('Security check failed:', error);
      }
    });
  }
}
