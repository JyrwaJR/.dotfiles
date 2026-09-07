---
description: Run comprehensive security review
agent: build
subtask: true
---

Security review: $ARGUMENTS

## Skills

- **security-reviewer** (primary) — vulnerability detection and remediation
- **owasp-security** — OWASP Top 10 checklist and secure coding patterns
- **security-review** — authentication, API security, and sensitive data handling

## Process

1. Load the `security-reviewer` skill for systematic vulnerability scanning.
2. Load `owasp-security` for the OWASP Top 10 checklist.
3. Scan the specified code (or full codebase if no scope given) for:

### OWASP Top 10 Checklist

| #  | Category                     | Check                                                    |
| -- | ---------------------------- | -------------------------------------------------------- |
| A01| Broken Access Control        | Auth on all routes, server-side authorization, CORS locked |
| A02| Cryptographic Failures       | No plaintext secrets, bcrypt/argon2, TLS enforced        |
| A03| Injection                    | Parameterized queries, input validation, no shell injection |
| A04| Insecure Design              | Threat model, rate limits, fail-secure defaults          |
| A05| Security Misconfiguration    | No debug mode, security headers, .env excluded from VCS  |
| A06| Vulnerable Components        | `npm audit`, no HIGH+ advisories unresolved              |
| A07| Authentication Failures      | Session tokens ≥128 bits, logout invalidation, lockout   |
| A08| Data Integrity Failures      | CI/CD protection, signed commits                         |
| A09| Logging & Monitoring         | Auth events logged, no secrets in logs                   |
| A10| SSRF                         | URL allowlist, internal IP blocking, no blind redirects  |

### Additional Checks

- [ ] No hardcoded secrets, API keys, or credentials
- [ ] Environment variables handled per sensitivity level ([SECRET], [CONFIG], [PUBLIC])
- [ ] CORS locked down — no wildcard origins
- [ ] Rate limiting on auth and sensitive endpoints
- [ ] CSRF protection on state-changing operations
- [ ] Secure cookie flags (HttpOnly, Secure, SameSite)

## Output Format

### Critical Issues
Issues that must be fixed immediately — blockers.

### High Priority
Issues that should be fixed before release.

### Recommendations
Security improvements to consider.

## Rules

- Security issues are **blockers** — do not proceed until critical issues are resolved.
- Verify outbound requests target approved domains only (§8 domain allowlist).
- Never log sensitive data, passwords, or full PII.
