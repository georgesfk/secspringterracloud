export interface User {
  id: number;
  username: string;
  email: string;
  lastLoginAt?: Date;
  failedLoginAttempts?: number;
  roles: Role[];
}

export interface Role {
  id: number;
  name: string;
  description: string;
}

export interface JwtResponse {
  accessToken: string;
  tokenType: string;
  id: number;
  username: string;
  email: string;
  roles: string[];
  refreshToken?: string;
}

export interface LoginRequest {
  usernameOrEmail: string;
  password: string;
}

export interface SignUpRequest {
  username: string;
  email: string;
  password: string;
  role: string[];
}

export interface MessageResponse {
  message: string;
}

export interface SecurityStatus {
  jwt_authentication: string;
  spring_security: string;
  cors: string;
  password_encoding: string;
  role_based_access: string;
  rate_limiting: string;
  owasp_compliance: string;
}

export interface OWASPZapStatus {
  status: string;
  endpoints: string[];
  security_headers: string;
  xss_protection: string;
  csrf_protection: string;
  recommended_zap_config: string;
}
