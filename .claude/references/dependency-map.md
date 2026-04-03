# vgs-collect-ios-private Dependency Map

## Project Structure

iOS SDK (Swift 5.9, iOS 13+) for secure data collection, tokenization, and submission.
Distributed via both SwiftPM and CocoaPods. Three library targets:

| Target | Role |
|--------|------|
| `VGSCollectSDK` (Core) | Main SDK — text fields, validation, networking, card scanning UI |
| `VGSCardIOCollector` | Card.io camera-scan integration (depends on CardIOSDK) |
| `VGSBlinkCardCollector` | BlinkCard camera-scan integration (depends on BlinkCard/MBBlinkCard) |

Test target: `FrameworkTests` (unit tests for core SDK).

## Dependency Categories

### Always Low Risk (Auto-merge Candidates)

| Pattern | Example | Reason |
|---------|---------|--------|
| CI tooling / shared workflows | `cicd-shared`, GitHub Actions versions | CI-only, no runtime impact on SDK |
| Build/lint tools | SwiftLint, yamllint | Build-time only, no shipped code |
| Test-only dependencies | Test infrastructure updates | Test scope only, not shipped |

### Needs Quick Review

| Pattern | Example | Reason | Expected Test Coverage |
|---------|---------|--------|----------------------|
| CardIOSDK patch/minor | `CardIOSDK-iOS` (currently 5.5.7) | VGS-owned fork, camera-scan only | `VGSCardIOCollectorTests`, demo app UI tests |
| CocoaPods spec metadata | `VGSCollectSDK.podspec` version bumps | Packaging only | CI pod lint |

### Needs Deep Review

| Pattern | Example | Reason | Expected Test Coverage |
|---------|---------|--------|----------------------|
| BlinkCard SDK | `blinkcard-swift-package` / `MBBlinkCard` (currently 2.12.0) | Third-party native binary (Microblink), camera + ML model, security-sensitive | `FrameworkTests`, demo app manual verification |
| BlinkCard major version | Any 3.x bump | API-breaking, likely requires code changes in `VGSBlinkCardCollector` | Full integration test pass |
| CardIOSDK major version | Any 6.x bump | API-breaking for `VGSCardIOCollector` | `VGSCardIOCollectorTests` + demo app |
| iOS deployment target changes | `Package.swift` platform bump | Affects all downstream consumers | CI matrix across simulators |

## Renovate Configuration

Minimal configuration — `renovate.json` contains only the schema reference with no
custom extends, labels, grouping, or automerge rules. Renovate will use its default
preset (`config:base`).

Notable implications:
- No `renovate` label is auto-applied — label must be added manually or via a
  separate Renovate `packageRules` update for the workflow trigger to fire on PR creation
- No automerge configured — all PRs require manual merge
- No grouping — each dependency updated in its own PR
