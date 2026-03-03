---
name: collect-ios-core-change
description: Use when changing collector, submission, tokenization, text-field behavior, or validation rules in VGS Collect iOS. Applies SDK invariants and verification checks.
---

# collect-ios-core-change

## When to use

- Changes under `Sources/VGSCollectSDK/Core/**`.
- Changes under `Sources/VGSCollectSDK/UIElements/Text Field/**`.
- Changes to validation rules, field types, state behavior, or submission payload mapping.

## Required invariants

- No raw PAN/CVC/SSN/file content in logs, analytics, persistence, or error payloads.
- Validate required fields before submit (`state.isValid`).
- App boundary remains alias/token oriented.
- Use only public, non-deprecated APIs in changed code paths.
- Keep environment selection explicit and safe (`.sandbox` vs `.live`).

## Verification commands

```bash
rg -n "deprecated" Sources/VGSCollectSDK Tests demoapp
rg -n "print\\(|NSLog|logger\\.(debug|info|warning|error).*([0-9]{13,19}|cvc|ssn|pan)" Sources Tests demoapp -S
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -testPlan FrameworkTests
```

## Done criteria

- Behavior and validation changes are covered by deterministic tests.
- No sensitive raw-value exposure in diagnostics.
- Submission response handling remains alias/token based.
- Reviewer can map changes to integration constraints in `AGENTS.md`.
