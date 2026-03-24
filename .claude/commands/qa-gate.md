---
description: Run QA gate — test coverage, security/privacy invariants, and release safety checks
---

You are acting as the QA gate for changes to VGSCollectSDK.

## Context bootstrap

1. Read `ARCHITECTURE.md` for file path mapping.
2. Read `.codex/agents/MENTAL_MODEL.md` for behavioral contracts and regression checks.

## Checks to perform

### Privacy & security scan
```bash
rg -n "print\(|NSLog|logger\.(debug|info|warning|error).*([0-9]{13,19}|cvc|ssn|pan)" Sources Tests demoapp -S
rg -n "vault|license|pan|cvc|ssn|card_number|raw" Sources/VGSCollectSDK/Utils/Loggers Sources/VGSCollectSDK/Core/Analytics -S
```

### File upload cleanup contract
```bash
rg -n "cleanFiles\(" Sources Tests demoapp
```

### Deprecated API usage
```bash
rg -n "deprecated" Sources/VGSCollectSDK Tests demoapp
```

### Unit tests
```bash
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' -testPlan FrameworkTests
```

### CI job presence
```bash
rg -n "build-and-test-sdk:|build-and-ui-test-demo-app:" .github/workflows/ci-tests.yaml -S
```

### Release/workflow check (only if versioning/packaging files changed)
```bash
rg -n "SDK Version:" AGENTS.md
rg -n "spec.version" VGSCollectSDK.podspec
rg -n "vgsCollectVersion" Sources/VGSCollectSDK/Utils/Extensions/Utils.swift
```

## Flow boundary check
Verify no cross-contamination of initializers, configs, or auth surfaces:
- `session(with:)` used only in CMP context
- `authHandler` used only for CMP (`createCard`, card-attributes lookup)
- `customHeaders` used only for Vault proxy and alias routes
- CMP helper configs (`.makeXxx`) not used in Vault proxy or tokenization paths

## Doc alignment check (if public flow guidance changed)
```bash
python3 scripts/check_mental_model_sync.py
```
Ensure `AGENTS.md`, `README.md`, and `.codex/agents/MENTAL_MODEL.md` are updated together.

## High-risk regression checks

1. CMP docs still show `session(with:)` as the only CMP initializer
2. Card number Luhn validity toggles `state.isValid` correctly
3. Past expiration date is invalid
4. Submission success returns alias/token payloads
5. File upload success triggers `collector.cleanFiles()`
6. Scanner delegate mapping targets expected text fields
7. Async and Combine paths remain non-blocking for UI
8. SwiftUI, Combine, and async wrappers documented as wrappers over UIKit core

Report results with pass/fail for each check category.
