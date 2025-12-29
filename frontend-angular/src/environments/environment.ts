export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api',
  wsUrl: 'ws://localhost:8080',
  owaspZap: {
    enabled: true,
    proxyUrl: 'http://localhost:8080',
    scanUrl: 'http://localhost:4200'
  },
  security: {
    jwtTokenKey: 'secure_platform_token',
    refreshTokenKey: 'secure_platform_refresh_token',
    sessionTimeout: 30 * 60 * 1000, // 30 minutes
    maxFailedAttempts: 5
  },
  devsecops: {
    gitleaks: {
      enabled: true,
      preCommitHook: true
    },
    semgrep: {
      enabled: true,
      rulesPath: '/security-configs/semgrep-rules.yml'
    },
    trivy: {
      enabled: true,
      scanImages: true
    },
    owaspZap: {
      enabled: true,
      passiveScan: true,
      activeScan: true
    }
  }
};
