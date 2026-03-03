# .codex Agents AGENTS Entry

This file is the contributor-agent entrypoint for maintenance work in this repo.

## Authority

Contributor workflow authority:
- `.codex/agents/README.md`
- `.codex/agents/*.toml`
- `.codex/skills/*/SKILL.md`

Integration behavior contract reference:
- `../../AGENTS.md` (consumer/integration guidance)

Contributors should not use `../../AGENTS.md` as the primary workflow playbook.
Use it to preserve consumer-facing behavior, validation, and security constraints.

If contributor guidance in `.codex/agents/*` conflicts with integration behavior constraints, preserve the constraints and update contributor docs.

## Required Entry Workflow

1. Ensure branch preflight:
   - Start from up-to-date `canary`.
   - Create feature branch as `feature/DEVX-<ticket-number>/<short-description>`.
2. Run mandatory context bootstrap before any symbol search:
   - Read `ARCHITECTURE.md`.
   - Read `.codex/agents/MENTAL_MODEL.md`.
   - Read only relevant `.codex/skills/*/SKILL.md` for the task scope.
3. Route non-trivial work through `.codex/agents/feature-orchestrator.toml`.
4. For `feature/DEVX-*` branches, create and maintain required artifacts under `.specs/features/<ticket>/` using `.codex/skills/collect-ios-feature-artifacts/SKILL.md`.
5. Use relevant `.codex/skills/*` workflow checklists before introducing subagents.
6. Engage `.codex/agents/tests-qa.toml` for behavior-sensitive changes.
7. For public behavior changes, update contributor docs and integration guidance in the same change.

## Integration Constraints That Always Win

- No raw sensitive data (PAN/CVC/SSN/files) in logs, analytics, persistence, or user-visible diagnostics.
- App-facing responses stay alias/token oriented.
- Validation gating before submission remains intact (`state.isValid` contract).
- Successful file upload paths preserve `collector.cleanFiles()` cleanup.
- New code paths use public, non-deprecated APIs only.
- Environment selection remains explicit and safe (`.sandbox` vs `.live`, not user-derived at runtime).

## Skill-Based Routing Map

- Core collector and submission changes:
  - `.codex/skills/collect-ios-core-change/SKILL.md`
- Text fields and validation behavior:
  - `.codex/skills/collect-ios-core-change/SKILL.md`
- File picker and scanner flows:
  - `.codex/skills/collect-ios-file-scanner/SKILL.md`
- Logging, analytics, and error privacy behavior:
  - `.codex/skills/collect-ios-observability-privacy/SKILL.md`
- Release, version, CI, and docs consistency:
  - `.codex/skills/collect-ios-release-docs/SKILL.md`
- Feature artifact workflow:
  - `.codex/skills/collect-ios-feature-artifacts/SKILL.md`

## Sync Expectations

- Keep `.codex/agents/MENTAL_MODEL.md` aligned with `../../AGENTS.md` for integration contracts and use-case behavior.
- `.github/agents` is generated from `.codex/agents` via `scripts/sync_agents_mirror.py`; do not hand-edit generated files.
