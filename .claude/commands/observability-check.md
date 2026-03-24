---
description: Validate logging, analytics, or error mapping changes for privacy-safe observability
---

You are reviewing changes to logging, analytics, or error mapping in VGSCollectSDK.

## Scope

Changes under:
- `Sources/VGSCollectSDK/Core/Analytics/**`
- `Sources/VGSCollectSDK/Utils/Loggers/**`
- Error surfaces under `Sources/VGSCollectSDK/Core/API/**` or related public error mapping

## Invariants

- Logs and analytics NEVER include raw PAN/CVC/SSN/file payloads, vault IDs, or license keys
- User-facing errors remain categorical (validation, server, timeout/offline) without raw backend payload leakage
- Production logging defaults remain minimal
- Analytics opt-out behavior remains intact

## Verification

```bash
rg -n "logger|analytics|error" Sources/VGSCollectSDK -S
rg -n "vault|license|pan|cvc|ssn|card_number|raw" Sources/VGSCollectSDK/Utils/Loggers Sources/VGSCollectSDK/Core/Analytics -S
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' -testPlan FrameworkTests
```

## Done criteria

- Changed observability code preserves redaction policy
- Error mapping remains privacy-safe and integration-compatible
- Tests or assertions cover modified logging/analytics behavior
