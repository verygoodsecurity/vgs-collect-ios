---
name: collect-ios-release-docs
description: Use when changing versions, packaging metadata, CI workflows, migration notes, or contributor docs to keep release and documentation consistency.
---

# collect-ios-release-docs

## When to use

- Release preparation for a new SDK version.
- Changes under `.github/workflows/**`.
- Changes to `Package.swift`, `Package.resolved`, `VGSCollectSDK.podspec`, `VGSCollectSDK-checksum.txt`, `VGSCollectSDK.xcodeproj/project.pbxproj`, or version constants.
- Changes to `README.md`, `MIGRATING.md`, `AGENTS.md`, and agent routing docs.
- Changes to feature artifact workflow under `.specs/features/**`.

## Branch preflight (required for feature work)

- Base branch must be `canary` and up to date before creating a feature branch.
- Feature branch naming template: `feature/DEVX-<ticket-number>/<short-description>`.

Recommended commands:
```bash
git fetch origin
git checkout canary
git pull --ff-only origin canary
git checkout -b feature/DEVX-1234/short-description
```

## Required release order (hard requirements)

1. Ensure `canary` is up to date with remote.
2. Merge `main` into `canary`.
3. Update `MIGRATING.md` if migration impact exists.
4. Update `AGENTS.md` if integration/maintenance guidance changed.
5. Bump SDK version in `AGENTS.md` header (`**SDK Version: x.y.z**`).
6. Bump podspec version in `VGSCollectSDK.podspec` (`spec.version`).
7. Bump `Utils.vgsCollectVersion` in `Sources/VGSCollectSDK/Utils/Extensions/Utils.swift`.
8. Bump SDK version in project/package metadata where required (same version target as podspec).
9. Regenerate API docs with `jazzy`; update `.jazzy.yaml` only if doc structure must change.
10. Build XCFramework artifacts:
   - Remove local `build/` folder first.
   - Run `VGSCollectSDK_XCFramework` scheme from `VGSCollectSDK.xcodeproj`.
   - Confirm `build/VGSCollectSDK.xcframework` and `build/VGSCollectSDK.xcframework.zip` are generated.
   - Confirm `VGSCollectSDK-checksum.txt` is refreshed by build flow.
11. If XCFramework build fails, inspect `VGSCollectSDK_XCFramework` target `Build Phases > Run Script`.
12. Create release PR from `canary` to `main` with title exactly `Public release <version>`.
13. Fill release PR using repository PR template `.github/PULL_REQUEST_TEMPLATE.md`.
14. Commit and merge; `build/` remains ignored and should not be committed.
15. Create release tag exactly matching podspec version and attach `VGSCollectSDK.xcframework.zip` to release notes.
16. Use release notes sections:
    - `## What’s new`
    - `## Changes & Updates`
    - `## Fixes`

## Required invariants

- Version values are synchronized across `AGENTS.md`, podspec, project/package metadata, and `Utils.vgsCollectVersion`.
- Workflow commands remain deterministic and auditable.
- Release preparation runs on updated `canary` with `main` merged into `canary` before PR creation.
- Feature branches follow `feature/DEVX-<ticket-number>/<short-description>` and originate from updated `canary`.
- For `feature/DEVX-*` branches, required artifacts exist and stay updated:
  - `.specs/features/<ticket>/intake.md`
  - `.specs/features/<ticket>/execution.md`
- CI job names remain present in `.github/workflows/ci-tests.yaml`:
  - `build-and-test-sdk`
  - `build-and-ui-test-demo-app`
- Public docs remain aligned with non-deprecated API behavior.
- Release tag value equals `spec.version` in `VGSCollectSDK.podspec`.

## Verification commands

```bash
rg -n "SDK Version:" AGENTS.md
rg -n "spec.version" VGSCollectSDK.podspec
rg -n "vgsCollectVersion" Sources/VGSCollectSDK/Utils/Extensions/Utils.swift
rg -n "MARKETING_VERSION|CURRENT_PROJECT_VERSION" VGSCollectSDK.xcodeproj/project.pbxproj -S
bash scripts/check_feature_artifacts.sh
rg -n "build-and-test-sdk:|build-and-ui-test-demo-app:" .github/workflows/ci-tests.yaml -S
git fetch origin
git checkout canary
git pull --ff-only origin canary
git merge --no-ff origin/main
test -f .github/PULL_REQUEST_TEMPLATE.md
gh pr create --base main --head canary --title "Public release <version>" --body-file .github/PULL_REQUEST_TEMPLATE.md
jazzy
rm -rf build
xcodebuild -project VGSCollectSDK.xcodeproj -scheme VGSCollectSDK_XCFramework build
ls -la build | rg -n "VGSCollectSDK.xcframework|VGSCollectSDK.xcframework.zip"
test -s VGSCollectSDK-checksum.txt
python3 scripts/check_mental_model_sync.py
```

## Done criteria

- All hard requirements are completed in order.
- Version and packaging values are consistent across all required files.
- API docs were regenerated with `jazzy`.
- XCFramework zip and checksum were refreshed successfully.
- Release PR exists from `canary` to `main` with title `Public release <version>` and uses PR template.
- Feature artifact workflow check passes where required.
- Required CI jobs (`build-and-test-sdk`, `build-and-ui-test-demo-app`) are still declared.
- Release tag/version alignment and release-notes template requirements are met.
- CI workflow updates are minimal and reproducible.
- Docs and agent routing guidance are synchronized.
