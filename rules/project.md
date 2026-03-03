# Project Instructions

<!-- CUSTOMIZE: This is the main project-level agent config. Copy into your agent's project config location (see wiring/ guides). Fill in all CUSTOMIZE sections. -->

## What is This Project?

<!-- CUSTOMIZE: 1-3 sentences describing your project -->

## Project Structure

<!-- CUSTOMIZE: Your directory layout -->
```
project/
├── src/              # Application source
├── tests/            # Test files
├── docs/             # Documentation
└── ...
```

**Current sprint:** See `docs/sprints/` for active work context.

---

## System Architecture

<!-- CUSTOMIZE: Describe your core data flows -->

**Core flows:**
- **Inbound**: <!-- How requests enter the system -->
- **Processing**: <!-- How requests are processed -->
- **Output**: <!-- What the system produces -->

---

## Architecture: Thin Controllers, Fat Domain

**THE RULE:** Controllers do ONE thing: translate HTTP <-> domain calls. All business logic lives in your domain layer.

Controllers: parse request, call ONE domain function, map result to HTTP response. No ORM queries. No business logic. No if/else decisions.

---

## Core Principles

### 1. Domain Boundary (Strict)
Only the domain layer imports the ORM/database client. Domain files without tests are a red flag.

### 2. Idempotency (Everything Retries)
Webhooks retry. API calls may duplicate. Use unique constraints and handle duplicate key errors gracefully. See `rules/code-patterns.md`.

### 3. Multi-Tenancy (Org-Scoped)
<!-- CUSTOMIZE: Remove this section if you don't have multi-tenancy -->
Every query must be org-filtered. Fetching by ID alone = cross-tenant vulnerability.

### 4. Append-Only Audit Trail
Event and audit log tables are append-only. Never UPDATE or DELETE in application code.

### 5. Fail-Closed Auth
Missing credentials = 500 (config error), not silent bypass. Invalid credentials = 401/403.

### Engineering Filters

Every engineering decision passes three filters:
1. **10x scale** — Would we build this the same way at 10x current load?
2. **Series A audit** — Would a senior engineer at a top-tier company approve this?
3. **Simplest correct solution** — Not simplest hack — simplest *correct* solution.

**Scope:** "Not building X" = fine. "Building X but cutting corners" = NOT fine.

---

## Security

<!-- CUSTOMIZE: Fill in your actual auth methods -->

### Authentication Patterns
| Endpoint Type | Auth Method | Failure |
|---------------|-------------|---------|
| `/api/internal/*` | Bearer token | 401/500 |
| `/api/webhook/*` | Signature verification | 403/500 |
| `/api/public/*` | Session/JWT | 401/500 |

### Middleware Order (Critical)
<!-- CUSTOMIZE: Your actual middleware stacks -->
| Route | Order |
|-------|-------|
| `/api/internal/*` | bearerAuth -> rateLimit -> json -> controller |
| `/api/webhook/*` | rawBody -> signatureVerify -> controller |
| `/api/public/*` | session -> json -> controller |

### Logging & PII
- **Never log:** Tokens, secrets, auth headers, full phone numbers, addresses
- **Always include:** Request IDs, entity IDs, correlation IDs for traceability
- See `rules/security.md` for full observability contract.

---

## Guardrails

<!-- CUSTOMIZE: Your approved infrastructure -->

**Approved architecture:** <!-- e.g., "2 services, 1 database (PostgreSQL), 1 platform (AWS)" -->

**Do NOT introduce without approval:** Queues, cron jobs, Redis, message buses, new databases, new microservices, new deployment platforms.

---

## Workflow: Spec-Driven Development

```
spec → validate spec → implement

implement (guided by spec)
  → commit freely at logical boundaries
  → lint + typecheck + tests on commit
  → repeat

PR (when ready):
  → push + create PR
  → code review (automated or manual)
  → fix findings → re-review
  → merge
```

See `rules/workflow.md` for the detailed flow.

### Definition of Done

<!-- CUSTOMIZE: Your actual commands -->
- [ ] Linting passes
- [ ] Type checking passes
- [ ] All tests pass
- [ ] DB tests pass (if schema changed)
- [ ] Every new/modified domain file has a test file
- [ ] Never modify existing tests — fix the code, not the tests

---

## Agent Behavior

### Role
The AI agent is an implementation assistant, not the final authority. Code must be understandable and reviewable by a human.

### When to Stop and Ask
Architecture changes beyond guardrails. New dependencies. Ambiguous requirements. Anything that might break existing behavior.

---

## Git

### Branch Naming
<!-- CUSTOMIZE: Your conventions -->
```
feature/short-description    # New features
fix/issue-description        # Bug fixes
refactor/what-changed        # Code improvements
sprint-N/slice-name          # Sprint work
```

### Commits
```
type: short description

- What changed
- Why
```
Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

---

## Where to Find Details

<!-- CUSTOMIZE: Your actual file locations -->
| What | Where |
|------|-------|
| Current sprint context | `docs/sprints/` |
| Schema & models | <!-- e.g., prisma/schema.prisma --> |
| Code patterns | `rules/code-patterns.md` |
| Security rules | `rules/security.md` |
| Testing rules | `rules/testing.md` |
| Workflow | `rules/workflow.md` |
| Sprint spec template | `templates/sprint-spec.md` |
