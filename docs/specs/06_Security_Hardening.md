# KerjaFlow Security Hardening Specification

**Authentication • Data Protection • Infrastructure • Compliance**

Version 1.0 — December 2025

**🔒 CONFIDENTIAL — Security Team Only**

---

## PART 1: AUTHENTICATION SECURITY

### 1.1 Password Policy

| Requirement | Configuration |
|-------------|---------------|
| Minimum Length | 8 characters |
| Complexity | At least 1 uppercase, 1 lowercase, 1 number |
| Special Characters | Recommended but not required |
| Password History | Cannot reuse last 5 passwords |
| Maximum Age | 90 days (configurable per company) |
| Breach Check | Check against HaveIBeenPwned API on creation |
| Storage | bcrypt with cost factor 12 |

### 1.2 Account Lockout Policy

| Setting | Value |
|---------|-------|
| Failed Attempts Threshold | 5 consecutive failures |
| Lockout Duration | 15 minutes (progressive: 15 → 30 → 60 min) |
| Counter Reset | After successful login |
| Admin Override | HR_MANAGER or ADMIN can unlock immediately |
| Notification | Email user on lockout; alert security on 3+ lockouts/hour |

### 1.3 PIN Security

| Setting | Value |
|---------|-------|
| PIN Length | Exactly 6 digits |
| Disallowed PINs | Sequential (123456), repeated (111111), birth year patterns |
| Storage | bcrypt with cost factor 10 |
| Failed Attempts | 5 failures → require password re-authentication |
| Verification Token Lifetime | 5 minutes (for sensitive operations) |

### 1.4 JWT Token Security

| Setting | Value |
|---------|-------|
| Algorithm | RS256 (RSA with SHA-256) |
| Access Token Lifetime | 24 hours |
| Refresh Token Lifetime | 7 days |
| Token Storage (Mobile) | flutter_secure_storage (Keychain/EncryptedSharedPrefs) |
| Signing Key Rotation | Annual, with 24-hour overlap period |
| Token Revocation | Blacklist in Redis with TTL matching token expiry |
| Claims Validation | Validate exp, iat, iss, aud on every request |

**Token Payload (Minimal Claims):**
```json
{
  "sub": "123",
  "emp": "456",
  "cid": "1",
  "role": "EMPLOYEE",
  "iss": "kerjaflow",
  "aud": "kerjaflow-mobile",
  "iat": 1703059200,
  "exp": 1703145600
}
```

---

## PART 2: DATA PROTECTION

### 2.1 Data Classification

| Level | Description | Examples |
|-------|-------------|----------|
| RESTRICTED | Highest sensitivity, access strictly controlled | Passwords, PINs, bank accounts, IC numbers |
| CONFIDENTIAL | Business-sensitive, role-based access | Salaries, payslips, EPF numbers, medical records |
| INTERNAL | Company-wide access within organization | Employee names, departments, job titles |
| PUBLIC | No restrictions | Company name, public holidays |

### 2.2 Encryption Standards

| Data State | Method | Configuration |
|------------|--------|---------------|
| In Transit | TLS 1.3 | HTTPS only, HSTS enabled, no TLS < 1.2 |
| At Rest (Database) | AES-256 | PostgreSQL native encryption / AWS RDS encryption |
| At Rest (Files) | AES-256 | S3 server-side encryption (SSE-S3 or SSE-KMS) |
| At Rest (Mobile) | Platform native | Keychain (iOS), EncryptedSharedPreferences (Android) |
| Backups | AES-256 | Encrypted before upload to S3 |

### 2.3 Sensitive Field Handling

| Field | Storage | API Response | Logging |
|-------|---------|--------------|---------|
| password_hash | Hashed (bcrypt) | Never returned | Never log |
| pin_hash | Hashed (bcrypt) | Never returned | Never log |
| ic_no | Plain (indexed) | Masked: ****1234 | Masked |
| bank_account_no | Plain | Masked: ****5678 | Masked |
| tax_no | Plain | Full (authorized roles only) | Masked |
| salary amounts | Plain | Full (PIN required) | Never log |

### 2.4 Data Retention

| Data Type | Retention Period | Disposal Method |
|-----------|------------------|-----------------|
| Active employee records | Employment + 7 years | Soft delete, then purge |
| Payslips | 7 years (statutory) | Archive to cold storage |
| Leave requests | 7 years | Archive to cold storage |
| Audit logs | 7 years (statutory) | Archive to Glacier |
| Session logs | 90 days | Auto-delete |
| Application logs | 30 days | Auto-delete |
| Uploaded documents | Employment + 7 years | Secure delete from S3 |

---

## PART 3: API SECURITY

### 3.1 Input Validation

All API inputs must be validated:
- **Type validation:** Enforce expected data types
- **Length validation:** Maximum string lengths enforced
- **Format validation:** Regex patterns for emails, phone numbers, etc.
- **Range validation:** Numeric bounds checked
- **Enum validation:** Only allowed values accepted
- **SQL injection prevention:** Parameterized queries only
- **XSS prevention:** Sanitize all user-generated content

### 3.2 Rate Limiting Configuration

| Endpoint | Limit | Window | Scope |
|----------|-------|--------|-------|
| POST /auth/login | 10 requests | 1 minute | Per IP |
| POST /auth/password/forgot | 3 requests | 1 hour | Per email |
| POST /auth/pin/verify | 5 requests | 5 minutes | Per user |
| POST /documents | 10 requests | 1 minute | Per user |
| GET /payslips/{id}/pdf | 20 requests | 1 hour | Per user |
| General API | 60 requests | 1 minute | Per user |

### 3.3 Security Headers

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

### 3.4 CORS Policy

```python
CORS_CONFIG = {
    "allow_origins": [
        "https://app.kerjaflow.my",
        "https://admin.kerjaflow.my"
    ],
    "allow_methods": ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    "allow_headers": ["Authorization", "Content-Type", "X-Verification-Token"],
    "expose_headers": ["X-RateLimit-Limit", "X-RateLimit-Remaining"],
    "max_age": 86400,
    "allow_credentials": false
}
```

---

## PART 4: INFRASTRUCTURE SECURITY

### 4.1 Network Security

| Setting | Configuration |
|---------|---------------|
| VPC Configuration | Private subnets for database, public subnets for load balancer only |
| Security Groups | Whitelist-based; only required ports open |
| Database Access | Only from application servers, no public internet access |
| SSH Access | Bastion host only, key-based auth, no password auth |
| WAF | AWS WAF with OWASP Core Rule Set |
| DDoS Protection | AWS Shield Standard (Shield Advanced for production) |

### 4.2 Server Hardening Checklist

1. ☐ Disable root SSH login
2. ☐ Use SSH key authentication only
3. ☐ Configure fail2ban for brute force protection
4. ☐ Enable automatic security updates
5. ☐ Remove unnecessary packages and services
6. ☐ Configure firewall (ufw/iptables)
7. ☐ Enable audit logging (auditd)
8. ☐ Configure log rotation
9. ☐ Set file permissions (principle of least privilege)
10. ☐ Enable SELinux/AppArmor

### 4.3 Database Security

| Setting | Configuration |
|---------|---------------|
| Connection Encryption | SSL/TLS required for all connections |
| Authentication | Password + SSL certificate verification |
| User Privileges | Application user: SELECT, INSERT, UPDATE, DELETE only |
| Migration User | Separate user with schema modification privileges |
| Backup Encryption | AES-256 encryption for all backups |
| Query Logging | Log slow queries (> 1s) for performance analysis |

### 4.4 Secret Management

- Use AWS Secrets Manager or HashiCorp Vault
- Never commit secrets to version control
- Rotate secrets on schedule
- Use IAM roles instead of static credentials where possible
- Encrypt environment variables in CI/CD
- Audit secret access in CloudTrail

---

## PART 5: MOBILE APP SECURITY

### 5.1 Secure Storage

| Platform | Storage Mechanism | Data Stored |
|----------|-------------------|-------------|
| iOS | Keychain Services | Tokens, PIN verification status |
| Android | EncryptedSharedPreferences | Tokens, PIN verification status |
| Both | SQLite with SQLCipher | Cached data (encrypted at rest) |

### 5.2 Certificate Pinning

Implement certificate pinning to prevent MITM attacks:

```dart
// Flutter implementation using dio
final dio = Dio();
(dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
    (client) {
  client.badCertificateCallback =
      (cert, host, port) => _validateCertificate(cert);
  return client;
};
```

### 5.3 App Integrity Checks

- **Root/Jailbreak Detection:** Warn users, log for security monitoring
- **Debugger Detection:** Prevent debugging in release builds
- **Tamper Detection:** Verify app signature on startup
- **Screenshot Prevention:** Disable screenshots on sensitive screens (payslip)
- **Clipboard Clearing:** Clear clipboard after pasting sensitive data

---

## PART 6: COMPLIANCE & AUDIT

### 6.1 Malaysian Regulatory Compliance

| Regulation | Compliance Measures |
|------------|---------------------|
| PDPA 2010 | Consent management, data subject rights, breach notification |
| Employment Act 1955 | Payslip retention 7 years, employee record keeping |
| Income Tax Act | EA/PCB records retention, audit trail for salary data |
| EPF Act 1991 | EPF contribution records, employer registration |
| SOCSO Act 1969 | SOCSO contribution records |

### 6.2 Audit Trail Requirements

All sensitive operations must be logged in kf_audit_log:

| Category | Actions |
|----------|---------|
| User Authentication | Login, logout, password change, PIN setup |
| Data Access | Payslip view, document download, report generation |
| Data Modification | Employee create/update, leave approve/reject, payslip import |
| Admin Actions | User role change, account lock/unlock, configuration change |
| Security Events | Failed login, account lockout, suspicious activity |

### 6.3 Security Review Schedule

| Review Type | Frequency | Responsible |
|-------------|-----------|-------------|
| Vulnerability Scan | Weekly (automated) | DevOps |
| Penetration Test | Annual (third-party) | Security Team |
| Dependency Audit | Monthly | Development Team |
| Access Review | Quarterly | HR + IT |
| Backup Test | Monthly | DevOps |
| Security Training | Annual | All Staff |

---

*— End of Security Hardening Specification —*

**🔒 This document contains security-sensitive information. Handle accordingly.**
