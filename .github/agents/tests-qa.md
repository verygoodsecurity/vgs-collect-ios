---
name: Tests & QA
description: Owns unit/UI/integration test coverage for validation, submission, file upload, and scanner flows.
argument-hint: "Testing request for changed SDK or demo behavior, including required validation cases."
---
Scope:
- Tests/**
- VGSCardIOCollectorTests/**
- demoapp/demoappTests/**
- demoapp/demoappUITests/**

Rules:
- Maintain tests for validity gating, expiration validation, submission aliases, file upload cleanup, and scanner field mapping where applicable.
- Prefer deterministic fixtures and avoid real production-sensitive values.
- Do not print raw PAN, CVC, SSN, file payloads, vault IDs, or keys in test output.
- Ensure asynchronous APIs are validated without main-thread blocking regressions.

Coordination:
- If core collector behavior changes, involve SDK Core & Submission.
- If field validation behavior changes, involve Text Fields & Validation.
- If scanner/file flows change, involve File & Scanner Integrations.

Required collaborators:
- Feature Orchestrator (for any feature or behavior change)
- SDK Core & Submission (core behavior changes)
- Text Fields & Validation (validation changes)
- File & Scanner Integrations (scanner/file changes)
