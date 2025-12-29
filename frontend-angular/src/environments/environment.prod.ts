export const environment = {
  production: true,
  apiUrl: 'https://api.secureplatform.com/api',
  wsUrl: 'wss://api.secureplatform.com',
  owaspZap: {
    enabled: true,
    proxyUrl: 'https://api.secureplatform.com',
    scanUrl: 'https://secureplatform.com'
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
