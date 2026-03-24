---
description: Validate file picker/upload or card scanner integration changes (BlinkCard/CardIO)
---

You are reviewing changes to file upload or card scanner integrations.

## Scope

Changes under:
- `Sources/VGSCollectSDK/UIElements/FilePicker/**`
- `Sources/VGSCollectSDK/Integrations/CardScanners/**`
- `Sources/VGSBlinkCardCollector/**`
- `Sources/VGSCardIOCollector/**`

## Invariants

- Successful file upload path retains `collector.cleanFiles()`
- Scanner mapping is deterministic for card number, expiration date, CVC, and cardholder name
- SwiftPM scanner usage keeps explicit `import VGSBlinkCardCollector` where required
- No captured image/document raw content in logs or analytics

## Verification

```bash
rg -n "cleanFiles\(" Sources Tests demoapp
rg -n "VGSBlinkCardCollector" Sources demoapp Tests
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' -testPlan FrameworkTests
xcodebuild test -project demoapp/demoapp.xcodeproj -scheme demoappUITests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'
```

## Done criteria

- Upload success path verifies cleanup behavior
- Scanner mapping has positive and failure-path coverage
- No privacy regression in scanner/file logs
