---
name: collect-ios-file-scanner
description: Use when changing file picker/upload or card scanner integrations in VGS Collect iOS, including BlinkCard/CardIO mapping and cleanup paths.
---

# collect-ios-file-scanner

## When to use

- Changes under `Sources/VGSCollectSDK/UIElements/FilePicker/**`.
- Changes under `Sources/VGSCollectSDK/Integrations/CardScanners/**`.
- Changes under `Sources/VGSBlinkCardCollector/**`, `Sources/VGSCardIOCollector/**`, `VGSCardIOCollector/**`, or related tests.

## Required invariants

- Successful file upload path retains `collector.cleanFiles()`.
- Scanner mapping remains deterministic for card number, expiration date, CVC, and cardholder name.
- SwiftPM scanner usage keeps explicit `import VGSBlinkCardCollector` where required.
- No captured image/document raw content in logs or analytics.

## Verification commands

```bash
rg -n "cleanFiles\(" Sources Tests demoapp
rg -n "VGSBlinkCardCollector" Sources demoapp Tests
xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -testPlan FrameworkTests
xcodebuild test -project demoapp/demoapp.xcodeproj -scheme demoappUITests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'
```

## Done criteria

- Upload success path verifies cleanup behavior.
- Scanner mapping behavior has positive and failure-path coverage.
- No privacy regression in scanner/file logs.
