# iOS Maintenance Agent Router

Internal maintenance routing for repository contributors and coding agents.
This file is maintenance-only and is not part of customer integration guidance.

## Entry Point

- Start with `feature-orchestrator.toml` for any non-trivial change.
- Before routing implementation, read `MENTAL_MODEL.md` to align with customer integration behavior.

## Context Bootstrap (Mandatory)

Before searching symbols/functions/classes:

1. Read `ARCHITECTURE.md` to identify the relevant subsystem and concrete file paths.
2. Read `.codex/agents/MENTAL_MODEL.md` for integration behavior constraints.
3. Read only the relevant skill file(s) under `.codex/skills/*/SKILL.md`.
4. Run targeted file/path-scoped searches based on steps 1-3.

Do not start with broad/random identifier hunts across the repository.

## Branching Standard

- Start every feature from an up-to-date `canary` branch.
- Branch naming template: `feature/DEVX-<ticket-number>/<short-description>`.
- Prefer kebab-case for `<short-description>` (underscore is tolerated for existing workflows).
- Keep one feature scope per branch.

Recommended command flow:
```bash
git fetch origin
git checkout canary
git pull --ff-only origin canary
git checkout -b feature/DEVX-1234/short-description
```

## Capability Map

- Coordination and decomposition:
  - `feature-orchestrator.toml`
- QA and invariant gate:
  - `tests-qa.toml`
- Domain workflows (skills-first):
  - `.codex/skills/collect-ios-core-change/`
  - `.codex/skills/collect-ios-file-scanner/`
  - `.codex/skills/collect-ios-observability-privacy/`
  - `.codex/skills/collect-ios-release-docs/`
  - `.codex/skills/collect-ios-feature-artifacts/`

## Operating Policy

1. Skills first.
2. Direct execution second.
3. Multi-agent last.
4. Spawn workers only for large, parallelizable, isolated tasks with non-overlapping ownership.
5. Run `tests-qa.toml` gate for behavior, privacy/security, release/workflow, or public-behavior documentation changes.
6. For `feature/DEVX-*` branches, keep required artifacts:
   - `.specs/features/<ticket>/intake.md`
   - `.specs/features/<ticket>/execution.md`
7. CI enforces feature artifact presence via `bash scripts/check_feature_artifacts.sh`.

## CI Jobs

- Source of truth: `.github/workflows/ci-tests.yaml`
- Required jobs:
  - `build-and-test-sdk` (SDK build + framework tests)
  - `build-and-ui-test-demo-app` (demo app build + UI tests)
- Keep job names stable unless intentionally migrating CI structure; update this section and related skills/agent checks in the same change.

## Agent Docs Source Of Truth

- `.codex/agents` is authoritative.
- Keep contributor routing docs only in `.codex/agents`.
- Do not create, regenerate, or update a `.github/agents` mirror.

## Stewardship

- Any maintainer changing routing boundaries must update this file and related `.codex/agents` files in the same change.
- Keep `mental-model-sync.json` aligned and pass `python3 scripts/check_mental_model_sync.py` when integration behavior guidance changes.
