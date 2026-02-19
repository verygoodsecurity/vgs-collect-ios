# .github Agents AGENTS Entry

This file is the contributor-agent entrypoint for maintenance work in this repo.

## Authority

Contributor workflow authority:
- `.github/agents/README.md`
- `.github/agents/*.md`

Integration behavior contract reference:
- `../../AGENTS.md` (consumer/integration guidance)

Contributors should not use `../../AGENTS.md` as the primary workflow playbook.
Use it to preserve consumer-facing behavior, validation, and security constraints.

If contributor guidance in `.github/agents/*` conflicts with integration behavior constraints, preserve the constraints and update contributor docs.

## Required Entry Workflow

1. Read `.github/agents/MENTAL_MODEL.md` before routing or implementing behavior changes.
2. Route non-trivial work through `.github/agents/feature-orchestrator.md`.
3. Engage required collaborators for touched domains (fields, submission, scanner/files, tests, security, docs).
4. For public behavior changes, update contributor docs and integration guidance in the same change.

## Integration Constraints That Always Win

- No raw sensitive data (PAN/CVC/SSN/files) in logs, analytics, persistence, or user-visible diagnostics.
- App-facing responses stay alias/token oriented.
- Validation gating before submission remains intact (`state.isValid` contract).
- Successful file upload paths preserve `collector.cleanFiles()` cleanup.
- New code paths use public, non-deprecated APIs only.
- Environment selection remains explicit and safe (`.sandbox` vs `.live`, not user-derived at runtime).

## Use-Case Routing Map

- Core collector/submission contracts: `.github/agents/sdk-core-submission.md`
- Field semantics, masks, and validation rules: `.github/agents/text-fields-validation.md`
- File picker and scanner flows: `.github/agents/file-scanner-integrations.md`
- Logging/analytics/error surfaces: `.github/agents/observability-errors.md`
- Security/privacy gate review: `.github/agents/security-privacy-review.md`
- Test coverage expectations: `.github/agents/tests-qa.md`
- Public guidance and agent-doc sync: `.github/agents/docs-agents-sync.md`

## Sync Expectations

- Keep `.github/agents/MENTAL_MODEL.md` aligned with `../../AGENTS.md` for integration contracts and use-case behavior.
- If workflow ownership or routing boundaries change, update `.github/agents/README.md` and related `.github/agents/*.md` files in the same PR.
