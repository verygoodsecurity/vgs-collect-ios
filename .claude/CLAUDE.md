# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository

VGSCollectSDK — iOS SDK (Swift, UIKit-first) for secure collection, validation, tokenization, alias creation, and submission of sensitive data (PAN, CVC, SSN, files) to VGS surfaces. Sensitive data never leaves the SDK boundary in raw form.

## Build & Test

```bash
# Unit tests
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' -testPlan FrameworkTests

# Single test class (replace class name as needed)
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' -testPlan FrameworkTests \
  -only-testing:FrameworkTests/VGSTextFieldTests

# Demo app UI tests
xcodebuild test -project demoapp/demoapp.xcodeproj -scheme demoappUITests \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'
```

Lint: SwiftLint (`.swiftlint.yml`). CI: `.github/workflows/ci-tests.yaml` (macOS-15, Xcode 26.1.1).

## Context Bootstrap

Before making changes, read in order:
1. `ARCHITECTURE.md` — file paths, subsystem map, public API entry points
2. `.codex/agents/MENTAL_MODEL.md` — behavioral contracts and flow-specific preservation rules
3. `AGENTS.md` — authoritative integration guide (flow selection, auth, field configs, privacy, pre-merge checklist)

For contributor workflow routing, see `.codex/agents/AGENTS.md` (contributor-agent entrypoint) and `.codex/agents/README.md`.

## Three Flow Families

Do not mix initializers, config families, or auth surfaces across flows.

| Flow | Initializer | Config Family | Auth Surface | Submit APIs |
|---|---|---|---|---|
| **CMP** | `VGSCollect.session(with:...)` | `.makeXxx` helpers | `authHandler` | `createCard`, `updateCard` |
| **Vault Proxy** | `VGSCollect(id:...)` | `VGSConfiguration` | `customHeaders` | `sendData`, `sendFile` |
| **Tokenization** | `VGSCollect(id:...)` | `VGS*TokenizationConfiguration` | `customHeaders` | `tokenizeData`, `createAliases` |

- `session(with:)` is CMP-only. Do not use for Vault proxy or tokenization.
- `authHandler` is CMP-specific (tokenless `createCard` + card-attributes lookup).
- `customHeaders` is for Vault proxy and alias routes.
- SwiftUI, Combine, and async/await are wrapper surfaces over UIKit core — not independent implementations.

## Security Invariants

- Raw sensitive data (PAN, CVC, SSN) NEVER logged, persisted, or exposed via public APIs
- UI reads `VGSTextField.state` snapshots — never raw values
- All fields validated (`state.isValid`) before submission
- Network responses return aliases/tokens only
- File uploads followed by `collector.cleanFiles()` after success
- Analytics/logging must not include sensitive field content
- Environment selection stays explicit (`.sandbox` vs `.live`, never user-derived at runtime)

## Branching

Feature branches from `canary`: `feature/DEVX-<ticket>/<short-description>` (kebab-case).
`feature/DEVX-*` branches require `.specs/features/<ticket>/intake.md` and `execution.md` (CI-enforced via `scripts/check_feature_artifacts.sh`).

## Doc Alignment Rule

When public flow guidance changes, update all three in the same change:
- Root `AGENTS.md`
- Root `README.md`
- `.codex/agents/MENTAL_MODEL.md`

Validate with `python3 scripts/check_mental_model_sync.py`.

## Maintenance Agent System

`.codex/agents/` is the only agent-doc source of truth. `.codex/skills/` has domain workflow skills. Entry point: `feature-orchestrator.toml`. Run `tests-qa.toml` for behavior, privacy, or public-doc changes.

## Claude Code Commands

Slash commands in `.claude/commands/` mirror `.codex/skills/` for Claude Code:
- `/core-change` — validate collector, submission, text-field, or validation changes
- `/qa-gate` — full QA gate (tests, privacy scan, regression checks)
- `/observability-check` — logging/analytics/error privacy review
- `/file-scanner-check` — file upload + card scanner integration review
- `/feature-artifacts` — create/update `.specs/features/<ticket>/` artifacts
- `/release-check` — version sync, docs, CI, packaging validation
