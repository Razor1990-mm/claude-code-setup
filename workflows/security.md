---
name: security
description: Run security checklist on code changes
---

Run a security audit on the specified code or recent changes.

**Usage:** `/security` or `/security src/routes/`

## Checklist

### Authentication & Authorization

<!-- CUSTOMIZE: Adapt to your auth patterns (Bearer tokens, OAuth, API keys, webhook signatures, etc.) -->
- [ ] All protected endpoints require valid credentials?
- [ ] Webhook endpoints verify signatures (e.g., HMAC-SHA256)?
- [ ] Missing env vars return 500 (fail-closed), not silent bypass?
- [ ] Auth failures return 401/403 without leaking token existence?

### Data Handling

- [ ] No secrets logged (auth headers, tokens, passwords)?
- [ ] PII handled appropriately (masked, redacted)?
- [ ] Input validated before use?
- [ ] Output encoded/escaped properly?

### SQL/Database

<!-- CUSTOMIZE: Adapt to your ORM (Prisma, Drizzle, TypeORM, raw SQL, etc.) -->
- [ ] Using parameterized queries (not raw SQL with string concatenation)?
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
- [ ] Middleware order correct for auth chain?

## Output Format

```
## Security Audit Results

### PASS
- Authentication: Credentials required on all protected endpoints
- SQL Injection: Parameterized queries used
- Logging: No secrets in log output

### FAIL
- **Missing auth check** (HIGH)
  File: src/routes/api.ts:45
  Issue: Endpoint missing auth middleware
  Fix: Add auth middleware before controller

- **Sensitive data logged** (MEDIUM)
  File: src/controllers/webhook.ts:23
  Issue: Request body logged including potential PII
  Fix: Use redact() helper or remove log

### WARNINGS
- Consider adding rate limiting to public endpoints
```

## Severity Levels

- **HIGH** — Direct security vulnerability, fix immediately
- **MEDIUM** — Potential issue, fix before production
- **LOW** — Best practice violation, fix when convenient
