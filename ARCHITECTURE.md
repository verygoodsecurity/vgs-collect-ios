# Architecture

## Repo Identity

- Purpose: iOS SDK for secure collection, validation, tokenization, and submission of sensitive data to VGS Vault.
- Primary language/tooling: Swift, Xcode, Swift Package Manager, CocoaPods, XCTest.

## Authoritative Guidance Pointers

- Integration guidance: `vgs-collect-ios/AGENTS.md`
- Contributor workflow entry: `vgs-collect-ios/.codex/agents/AGENTS.md`
- Maintenance routing: `vgs-collect-ios/.codex/agents/README.md`
- Contributor mental model: `vgs-collect-ios/.codex/agents/MENTAL_MODEL.md`
- Maintenance agents source of truth: `vgs-collect-ios/.codex/agents/*.toml`
- Copilot instructions: NOT FOUND
- Repo docs: `vgs-collect-ios/README.md`, `vgs-collect-ios/MIGRATING.md`, `vgs-collect-ios/SECURITY.md`

## Maintenance Agent Map

- Entry point coordinator: `vgs-collect-ios/.codex/agents/feature-orchestrator.toml`
- QA/security gate: `vgs-collect-ios/.codex/agents/tests-qa.toml`
- Domain workflow skills:
  - `vgs-collect-ios/.codex/skills/collect-ios-core-change/SKILL.md`
  - `vgs-collect-ios/.codex/skills/collect-ios-file-scanner/SKILL.md`
  - `vgs-collect-ios/.codex/skills/collect-ios-observability-privacy/SKILL.md`
  - `vgs-collect-ios/.codex/skills/collect-ios-release-docs/SKILL.md`
  - `vgs-collect-ios/.codex/skills/collect-ios-feature-artifacts/SKILL.md`

## Context Bootstrap Rule

- Start technical work by reading this file (`ARCHITECTURE.md`) to map scope to concrete paths.
- Then read `.codex/agents/MENTAL_MODEL.md` and relevant skill files.
- Only after that, run targeted path-scoped symbol searches.

## Source Structure Overview (Evidence)

- Package and public target definition: `vgs-collect-ios/Package.swift`
- SDK sources root: `vgs-collect-ios/Sources/VGSCollectSDK/`
- Collector orchestration: `vgs-collect-ios/Sources/VGSCollectSDK/Core/Collector/VGSCollect.swift`
- Network submission: `vgs-collect-ios/Sources/VGSCollectSDK/Core/Collector/VGSCollect+network.swift`
- API client layer: `vgs-collect-ios/Sources/VGSCollectSDK/Core/API/ProxyAPIClient.swift`
- Field configuration model: `vgs-collect-ios/Sources/VGSCollectSDK/Core/VGSConfiguration.swift`
- Text input components: `vgs-collect-ios/Sources/VGSCollectSDK/UIElements/Text Field/VGSTextField.swift`
- Card input specialization: `vgs-collect-ios/Sources/VGSCollectSDK/UIElements/Text Field/VGSCardTextField.swift`
- CVC specialization: `vgs-collect-ios/Sources/VGSCollectSDK/UIElements/Text Field/VGSCVCTextField.swift`
- File picker flow: `vgs-collect-ios/Sources/VGSCollectSDK/UIElements/FilePicker/VGSFilePickerController.swift`
- BlinkCard integration module: `vgs-collect-ios/Sources/VGSBlinkCardCollector/VGSBlinkCardController.swift`
- CardIO module sources: `vgs-collect-ios/VGSCardIOCollector/`
- Unit tests: `vgs-collect-ios/Tests/`
- Demo app: `vgs-collect-ios/demoapp/`

## Public API Entry Points

- SDK module boundary: `vgs-collect-ios/Sources/VGSCollectSDK/VGSCollectSDK.h`
- Main collector API: `vgs-collect-ios/Sources/VGSCollectSDK/Core/Collector/VGSCollect.swift`
- Public UI element APIs:
  - `vgs-collect-ios/Sources/VGSCollectSDK/UIElements/Text Field/VGSTextField.swift`
  - `vgs-collect-ios/Sources/VGSCollectSDK/UIElements/Text Field/VGSCardTextField.swift`
  - `vgs-collect-ios/Sources/VGSCollectSDK/UIElements/Text Field/VGSCVCTextField.swift`

## Error Model Locations

- Canonical error type: `vgs-collect-ios/Sources/VGSCollectSDK/Core/VGSError.swift`
- Error metadata: `vgs-collect-ios/Sources/VGSCollectSDK/Core/VGSErrorInfo.swift`
- Error keys: `vgs-collect-ios/Sources/VGSCollectSDK/Core/VGSErrorInfoKey.swift`
- HTTP response model: `vgs-collect-ios/Sources/VGSCollectSDK/Core/API/VGSResponse.swift`

## Analytics and Logging Locations

- Analytics client: `vgs-collect-ios/Sources/VGSCollectSDK/Core/Analytics/VGSAnalyticsClient.swift`
- Logging facade: `vgs-collect-ios/Sources/VGSCollectSDK/Utils/Loggers/VGSCollectLogger.swift`
- Request logger: `vgs-collect-ios/Sources/VGSCollectSDK/Utils/Loggers/VGSCollectRequestLogger.swift`
- Privacy manifest: `vgs-collect-ios/Sources/VGSCollectSDK/PrivacyInfo.xcprivacy`

## Build/Test Command Discovery (Evidence)

- CI workflow source: `vgs-collect-ios/.github/workflows/ci-tests.yaml`
- Unit tests command shape (CI): `xcodebuild test -project VGSCollectSDK.xcodeproj -scheme FrameworkTests -testPlan FrameworkTests`
- Demo UI tests command shape (CI): `xcodebuild test -project demoapp/demoapp.xcodeproj -scheme demoappUITests`
- Swift package definition: `vgs-collect-ios/Package.swift`
- Podspec packaging metadata: `vgs-collect-ios/VGSCollectSDK.podspec`

## Patterns and Conventions

- Collector-centric architecture: `VGSCollect` coordinates field registration, validation, request mapping, and submission.
- UI elements encapsulate secure input behavior; caller logic reads state snapshots instead of raw values.
- Validation and formatting are type-driven at field configuration boundaries.
- Logging and analytics are explicit components with privacy constraints applied at SDK boundaries.
- Scanner and file-picker integrations remain modular and isolated from core collector logic.
