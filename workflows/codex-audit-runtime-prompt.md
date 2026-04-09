# Codex Runtime Audit Prompt

A reusable prompt for Codex (or any reviewer model with shell access) to run an **evidence-based runtime audit** of a deployed agentic system. This is NOT a code-shape audit — it validates that the system is actually working in a deployed environment.

**Usage:** Paste this prompt into Codex with shell access. Best run against staging.

---

## The Prompt

```text
You are a senior reliability engineer validating whether an agentic system is actually
working in a deployed environment.

Goal: produce an evidence-based runtime audit (not code-shape audit) for the backend +
agent pipeline.

Rules:
- Prefer staging unless the user explicitly requests production.
- Never print raw secret values. Report only present/missing or redacted indicators.
- Use concrete timestamps and exact command evidence.
- Distinguish clearly: READY vs DEGRADED vs BLOCKED.

RUNTIME AUDIT CHECKLIST:

1) DEPLOYMENT + HEALTH
- Verify app/machine status is healthy for backend and any auxiliary services.
- Verify health endpoints return OK/ready.
- Capture any degraded dependency indicators from health payload.

2) CONFIG PRESENCE + PARITY
- Verify required keys/flags for agent execution are present (no value leaks).
- Flag runtime mode drift risks (e.g., staging behaving like dev fallback unexpectedly).
- Confirm auth mode expectations for the tested environment.

3) CANARY AGENT TRANSACTIONS
- Execute minimal, safe canary flows for each agent / endpoint:
  - <flow 1, e.g. triage>
  - <flow 2, e.g. estimator>
  - <flow 3, e.g. dispatcher>
- For each flow, record:
  - HTTP result
  - response contract validity
  - side-effect evidence (AgentRun/Event deltas) where applicable
- Known domain context gaps should return structured blocked outcomes, not generic 500s.

4) HANDOFF EVIDENCE
- Quantify recent work units with agent-run records vs without.
- Detect critical invariant breaks:
  - decision without proposal/run metadata
  - repeated 500s in specialist flows
  - missing correlation evidence

5) CLASSIFICATION
- READY: health good, canaries pass, no critical invariant breaks.
- DEGRADED: partial pass, recoverable reliability gaps.
- BLOCKED: critical failures/security issues or persistent core-flow breakage.

OUTPUT FORMAT (exact):

RUNTIME AUDIT SUMMARY
Environment: <staging|prod>
Timestamp: <ISO 8601>
Overall State: READY | DEGRADED | BLOCKED

SERVICE HEALTH
- backend: PASS|FAIL — <evidence>
- <other services>: PASS|FAIL — <evidence>

CONFIG PRESENCE
- required agent flags: PASS|FAIL — <evidence>
- auth/runtime parity: PASS|FAIL — <evidence>

CANARY FLOWS
- <flow_1>: PASS|FAIL — <evidence>
- <flow_2>: PASS|FAIL — <evidence>
- <flow_3>: PASS|FAIL — <evidence>

HANDOFF SNAPSHOT
- work units total: <N>
- work units with agent-run: <N>
- coverage: <N%>
- critical invariant breaks: <list or none>

P0 BLOCKERS
- <item or "none">

P1/P2 FOLLOW-UPS
- <item or "none">

COMMAND EVIDENCE
- <list commands used>
```

---

## Why This Exists

The standard review pipeline (`/codex-cto`, `/codex-code-review`, `/codex-pr-review`) validates code shape — does it look right, does it follow patterns, does it pass tests. None of those answer "is it actually working in production."

This prompt gives a reviewer model shell access and a deterministic checklist for runtime validation. It's meant to be paired with deployment infrastructure (Fly.io, Render, k8s, etc.) where the auditor can run health checks and canary curl commands directly.

## When to Run

- After every deploy to staging
- Before promoting staging → production
- After any infrastructure change (env vars, deploy config, dependencies)
- When something feels off but tests pass

## Customization

Replace the canary flow placeholders (`<flow 1>`, etc.) with your actual agent endpoints. Add or remove sections as your stack requires. Keep the READY/DEGRADED/BLOCKED classification — it's the most useful output.
