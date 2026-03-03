---
name: collect-ios-observability-privacy
description: Use when changing logging, analytics, or error mapping in VGS Collect iOS to enforce redaction and privacy-safe observability.
---

# collect-ios-observability-privacy

## When to use

- Changes under `Sources/VGSCollectSDK/Core/Analytics/**`.
- Changes under `Sources/VGSCollectSDK/Utils/Loggers/**`.
- Error-surface changes under `Sources/VGSCollectSDK/Core/API/**` or related public error mapping.

## Required invariants

- Logs and analytics never include raw PAN/CVC/SSN/file payloads, vault IDs, or license keys.
- User-facing errors remain categorical (validation, server, timeout/offline) without raw backend payload leakage.
- Production logging defaults remain minimal.
- Analytics opt-out behavior remains intact.

## Verification commands

```bash
rg -n "logger|analytics|error" Sources/VGSCollectSDK -S
rg -n "vault|license|pan|cvc|ssn|card_number|raw" Sources/VGSCollectSDK/Utils/Loggers Sources/VGSCollectSDK/Core/Analytics -S
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -testPlan FrameworkTests
```

## Done criteria

- Changed observability code preserves redaction policy.
- Error mapping remains privacy-safe and integration-compatible.
- Tests or assertions cover modified logging/analytics behavior.
