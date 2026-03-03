# Template Rules

Enforces template usage for structured deliverables.

## Specs (Primary Planning Artifact)

Before starting any feature, hardening, or refactor work, MUST:
1. Write a spec using the sprint spec template (`templates/sprint-spec.md`)
2. Save spec to `specs/<name>.md`
3. Validate the spec against the real codebase before implementing

## Work Orders

Before creating any work order or delegation to a specialist agent, MUST:
1. Read `templates/work-order.md`
2. Follow the template structure exactly
3. Include all REQUIRED sections (Requirements, Must-Cover Invariants, Files You May Touch, Proof Commands)

Incomplete work orders missing required sections MUST be rejected by reviewers.

## Sprint Specs

Before creating or updating any sprint spec:
1. Read `templates/sprint-spec.md`
2. Follow the template structure, hard caps, and checklist
3. Include a TL;DR block (exactly 10 lines)

**PRD Policy:** Standalone PRDs are reserved for multi-sprint strategic features only. Sprint-scoped work uses the Sprint Spec format — no separate PRD or tech spec.

## Sprint Close-Out

Before closing a sprint, verify all items in the Sprint Close-Out Gate checklist from `templates/sprint-spec.md`.
