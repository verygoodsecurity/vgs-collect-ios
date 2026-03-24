---
description: Validate a core SDK change (collector, submission, tokenization, text-field, or validation) against invariants
---

You are reviewing or implementing a core change to VGSCollectSDK.

## Context bootstrap

1. Read `ARCHITECTURE.md` to map scope to file paths.
2. Read `.codex/agents/MENTAL_MODEL.md` for behavioral contracts.
3. Read `AGENTS.md` sections relevant to the affected flow (CMP, Vault proxy, or Tokenization).

## Scope

Changes under:
- `Sources/VGSCollectSDK/Core/**`
- `Sources/VGSCollectSDK/UIElements/Text Field/**`
- Validation rules, field types, state behavior, or submission payload mapping

## Invariants to enforce

- No raw PAN/CVC/SSN/file content in logs, analytics, persistence, or error payloads
- Validate required fields before submit (`state.isValid`)
- App boundary remains alias/token oriented
- Use only public, non-deprecated APIs
- Environment selection stays explicit (`.sandbox` vs `.live`, not user-derived at runtime)
- `session(with:)` remains CMP-only; `authHandler` remains CMP-specific
- Flow boundaries preserved: do not mix initializers, config families, or auth surfaces across CMP, Vault proxy, and tokenization
- If public flow guidance changes, update `AGENTS.md`, `README.md`, and `.codex/agents/MENTAL_MODEL.md` in the same change

## Verification

Run these checks:

```bash
rg -n "deprecated" Sources/VGSCollectSDK Tests demoapp
rg -n "print\(|NSLog|logger\.(debug|info|warning|error).*([0-9]{13,19}|cvc|ssn|pan)" Sources Tests demoapp -S
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -testPlan FrameworkTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'
```

## Done criteria

- Behavior/validation changes covered by deterministic tests
- No sensitive raw-value exposure in diagnostics
- Submission response handling remains alias/token based
- Changes map to integration constraints in `AGENTS.md`
