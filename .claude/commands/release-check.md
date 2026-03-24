---
description: Validate release preparation — version sync, docs, CI, and packaging metadata
---

You are verifying release readiness for VGSCollectSDK.

## Version sync check

All version values must match across:
```bash
rg -n "SDK Version:" AGENTS.md
rg -n "spec.version" VGSCollectSDK.podspec
rg -n "vgsCollectVersion" Sources/VGSCollectSDK/Utils/Extensions/Utils.swift
rg -n "MARKETING_VERSION|CURRENT_PROJECT_VERSION" VGSCollectSDK.xcodeproj/project.pbxproj -S
```

## CI jobs present
```bash
rg -n "build-and-test-sdk:|build-and-ui-test-demo-app:" .github/workflows/ci-tests.yaml -S
```

## Feature artifacts (if on feature branch)
```bash
bash scripts/check_feature_artifacts.sh
```

## Mental model sync
```bash
python3 scripts/check_mental_model_sync.py
```

## Release order (hard requirements)

1. `canary` up to date, `main` merged into `canary`
2. Update `MIGRATING.md` if migration impact
3. Update `AGENTS.md` if guidance changed; bump SDK version header
4. Bump podspec version, `Utils.vgsCollectVersion`, project metadata
5. Regenerate docs with `jazzy`
6. Build XCFramework via `VGSCollectSDK_XCFramework` scheme
7. Create release PR from `canary` to `main`: title `Public release <version>`
8. Tag matches podspec version; attach xcframework zip to release

Report version alignment and any discrepancies found.
