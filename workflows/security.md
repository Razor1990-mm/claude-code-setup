# Workflow: Security Audit

Run a security-focused review on specified code or recent changes.

## Checklist

### Authentication & Authorization
<!-- CUSTOMIZE: Adapt to your auth patterns -->
- [ ] All protected endpoints require valid credentials?
- [ ] Signature verification on webhook endpoints?
- [ ] Missing env vars return 500 (fail-closed), not silent bypass?
- [ ] Auth failures return 401/403 without leaking information?

### Data Handling
- [ ] No secrets logged (auth headers, tokens, passwords)?
- [ ] PII handled appropriately (masked, redacted)?
- [ ] Input validated before use?
- [ ] Output encoded/escaped properly?

### Database
- [ ] Using parameterized queries (not raw SQL)?
- [ ] No dynamic table/column names from user input?
- [ ] Unique constraints used for idempotency?

### OWASP Top 10 (abridged)
- [ ] **Injection** — SQL, command, NoSQL safe?
- [ ] **Broken Auth** — Sessions, tokens handled correctly?
- [ ] **Sensitive Data Exposure** — Encryption, logging safe?
- [ ] **Broken Access Control** — Authorization checked?
- [ ] **Security Misconfiguration** — Defaults changed, headers set?
- [ ] **XSS** — Output escaped (if frontend)?
- [ ] **Insecure Deserialization** — JSON parsing safe?
- [ ] **Vulnerable Components** — Dependencies up to date?
- [ ] **Insufficient Logging** — Security events logged?

### Project-Specific
<!-- CUSTOMIZE: Your project's security specifics -->
- [ ] Rate limiting applied to public endpoints?
- [ ] Correlation IDs included in logs for tracing?
- [ ] Middleware order correct for auth?

## Output Format

```
## Security Audit Results

### PASS
- <what passed>

### FAIL
- **Issue** (severity)
  File: path:line
  Fix: Action

### WARNINGS
- <potential issues>
```

## Severity Levels

- **HIGH** — Direct security vulnerability, fix immediately
- **MEDIUM** — Potential issue, fix before production
- **LOW** — Best practice violation, fix when convenient
