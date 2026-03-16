# Agent Organization

Specialized agents forming an engineering team. Each agent is a **single-purpose persona** — identity only, no duplicated patterns or code examples. All patterns inherited from your project's main instructions + `rules/`.

---

## Org Chart

```
                    CEO (User / Founder)
                         │
                    ┌────┴────┐
                    │   CTO   │  opus — strategic decisions, dispatch, process enforcement
                    └────┬────┘
          ┌──────────┬───┴───┬──────────┬──────────┐
          │          │       │          │          │
    Backend Lead  Frontend  QA Eng   Security   DevOps
      (opus)      Lead    (sonnet)    Eng      Eng
                (sonnet)             (opus)   (sonnet)
```

## Agent Summary

| Agent | Model | Purpose | Blocking Power |
|-------|-------|---------|----------------|
| **CTO** | opus | Orchestrate, architect, delegate, enforce process | Rejects work without TDD proof |
| **Backend Lead** | opus | Domain logic, TDD, database, observability | None (escalates to CTO) |
| **Frontend Lead** | sonnet | UI components, design system, accessibility | None (escalates to CTO) |
| **QA Eng** | sonnet | Quality gates, TDD verification, test generation | Blocks commit on gate failure |
| **Security Eng** | opus | Auth review, multi-tenancy, PII, OWASP | Blocks PR on P0 findings |
| **DevOps Eng** | sonnet | Cost review, deployment, infrastructure | Blocks PR on P0 resource issues |

## Model Selection Rationale

| Agent | Model | Rationale |
|-------|-------|-----------|
| CTO | opus | Architecture decisions, strategic trade-offs |
| Backend Lead | opus | Domain logic, transaction design, business rules |
| Security Eng | opus | Judgment calls on vulnerabilities, auth patterns |
| Frontend Lead | sonnet | Pattern-following UI implementation |
| QA Eng | sonnet | Test generation follows established patterns |
| DevOps Eng | sonnet | Procedural infrastructure/cost checks |
| Plan agents | opus | Architecture design (always pass `model: "opus"`) |
| Codex spawners | sonnet | Mechanical: compose prompt, run Codex, show output. No reasoning needed. |
| Composite skills | sonnet | Orchestration: invoke sub-skills sequentially. No reasoning needed. |

Agent frontmatter (`model:` field in agent .md files) sets the default.

**Skill model rule:** If the AI's job is just to compose a prompt and run an external tool (Codex CLI), or orchestrate sub-skills, use sonnet. Reserve opus for skills requiring independent judgment (grill, staff-review, test-gen).

## When to Spawn Which Agent

| Situation | Spawn |
|-----------|-------|
| Feature request, sprint slice, "build X" | CTO first (MANDATORY) |
| Domain/API implementation (from CTO work order) | Backend Lead |
| UI/component implementation (from CTO work order) | Frontend Lead |
| Test generation, quality gates, pre-commit | QA Eng |
| Security review, pre-PR audit | Security Eng |
| Cost review, deployment | DevOps Eng |
| Codebase exploration (read-only) | `Task(subagent_type="Explore")` |

## Phase Flow

```
Phase 0: Strategic Debate
  CEO ↔ CTO — clarify scope, pick approach

Phase 1: Task Start
  CTO → reads codebase → creates work orders → delegates

Phase 1.5: Plan Review
  CTO → /staff-review (Claude: complexity, scope, patterns)
  CTO → /codex-cto (Codex: feasibility against real code, invariants)

Phase 2: Development
  Backend/Frontend Lead → TDD (invoke /tdd-workflow) → implement

Phase 2.5: Implementation Review
  CTO → /codex-cto review (Codex: plan adherence, test quality)
  Security Eng → auto /check-tenancy on domain changes
  QA Eng → /test-gen for test cases

Phase 3: Verification
  QA Eng → quality gates → /commit

Phase 4: Pre-PR
  Security Eng → /grill + /audit
  DevOps Eng → /cost (if applicable)
  CTO → reviews, creates PR
```

## Context Flow

Agents inherit your project's main instructions + all `rules/` files automatically. Agent `.md` files contain **identity only** — persona, responsibilities, boundaries, skills, escalation.

CTO injects **specific context** via Task() prompts: work order details, relevant files, constraints. Specialists don't need 400-line system prompts because shared rules are inherited.

```
Project instructions (always loaded)
  + rules/security.md (loaded when touching routes/middleware)
  + rules/testing.md (loaded when touching test files)
  + rules/code-patterns.md (always loaded)
  + rules/workflow.md (always loaded)
  + Agent .md file (~30-55 lines of identity)
  + CTO's Task() prompt (targeted context for this specific work)
```

## Skill → Agent Mapping

<!-- CUSTOMIZE: Update skill names to match your project's workflow files -->

| Skill | Primary Agent | Auto-Triggered? |
|-------|--------------|-----------------|
| `/tdd-workflow` | Backend Lead, Frontend Lead | No — invoked during RED phase |
| `/test-gen` | QA Eng | Auto-suggested on domain edits without test file |
| `/check-tenancy` | Security Eng | Auto on domain file edits |
| `/security` | Security Eng | Auto on auth file edits |
| `/review` | QA Eng / CTO | Before PR creation |
| `/grill` | Security Eng | Pre-PR adversarial review |
| `/audit` | Security Eng / CTO | Pre-PR compliance check |
| `/staff-review` | CTO | Auto before plan finalization |
| `/codex-cto` | CTO (via Codex) | Auto before plan finalization (alongside /staff-review) |
| `/codex-cto review` | CTO (via Codex) | After implementation, risk-based |
| `/sprint-closeout` | CTO | End of sprint, before merge |

## Key Rules

1. **CTO first for features** — Never implement features directly. CTO creates work orders.
2. **TDD required** — Every specialist invokes `/tdd-workflow` for RED phase. No exceptions.
3. **Skills via Skill tool** — Never manually replicate what a skill does.
4. **Existing tests are sacred** — Never modify tests to make code pass. Report as BLOCKER.
5. **Scope boundaries** — Only touch files listed in work order. Report blockers for others.
