# Security Rules

Auth patterns, PII handling, observability contract, and fail-closed design.

## Observability Contract

**Goal:** Every production incident debuggable via logs + events/audit, without leaking secrets/PII.

### What to use when
- **Logs**: operational breadcrumbs + failures (why/where it failed)
- **Events**: append-only narrative timeline ("what happened"), small payloads
- **Audit logs**: append-only state diffs ("what changed"), minimal before/after

### Required correlation fields (include as many as available)
<!-- CUSTOMIZE: Your actual correlation IDs -->
- `orgId` (or tenant identifier)
- `correlationId` (request ID, session ID, or external reference)
- Entity IDs relevant to the operation

### Structured log shape
```
// Use structured logging — no string concatenation
logger.info("ActionExecutionStarted", {
  orgId,
  correlationId,
  entityId,
  status: "IN_PROGRESS",
});
```

### Redaction rules (strict)
- Never log tokens/secrets/auth headers/OTP codes/JWTs
- Never log full phone numbers — mask to last 4 digits
- Never log addresses — use `[redacted-address]`
- Event payloads: keep small, never include secrets/PII

## Severity Classification

| Severity | Definition | Action |
|----------|------------|--------|
| **P0** | Auth bypass, cross-tenant leak, secrets in logs, data loss | **BLOCK PR** — fix before merge |
| **P1** | Weak validation, missing timeouts, PII exposure risk | **SHOULD FIX** — merge with mitigation plan |
| **P2** | Code smell, minor improvements | **NICE TO HAVE** — defer to backlog |

## Fail-Closed Auth Patterns

```typescript
// WRONG: Silent bypass on missing credentials
if (!token) return next(); // Attacker skips auth entirely

// CORRECT: Fail-closed — missing = 401
if (!token) return res.status(401).json({ error: "Missing authorization header" });

// CORRECT: Config error = 500, not silent bypass
if (!process.env.JWT_SECRET) throw new Error("JWT_SECRET not configured");
```

## PII Redaction Utilities

<!-- CUSTOMIZE: Adapt to your language -->
```typescript
// Phone: mask to last 4 digits
function maskPhone(phone: string): string {
  return phone.slice(-4).padStart(phone.length, '*');
  // +15551234567 → *******4567
}

// Address: never log, use placeholder
// [redacted-address]
```

## Security Review Checklist

When reviewing code for security:

1. **Multi-tenancy:** Every query includes tenant filter?
2. **Auth:** Fail-closed, no silent bypass on missing credentials?
3. **Middleware order:** Auth before business logic?
4. **PII:** No tokens/phones/addresses in logs?
5. **Injection:** Input sanitized at system boundaries?
6. **Access control:** Authorization checks before mutations?
7. **Error responses:** No stack traces or sensitive data to client?
