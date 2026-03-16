---
name: feedback-no-mocks
description: Integration tests must hit real database, not mocks — prior incident with mock/prod divergence
type: feedback
---

Don't mock the database in integration tests. We got burned last quarter when mocked tests passed but the prod migration failed. Mocks and prod diverged silently.

Rule: All integration tests use a real test database. Unit tests can mock external services (HTTP clients, message queues) but never the database layer.
