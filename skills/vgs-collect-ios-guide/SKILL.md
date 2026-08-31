---
name: vgs-collect-ios-guide
description: Routes AI agents through VGS Collect iOS SDK work across integration, implementation, migration, troubleshooting, and code review. Use when guidance may depend on the installed VGSCollectSDK version.
metadata:
  author: verygoodsecurity
  version: '1.0.2'
---

# VGS Collect iOS Guide

Single public skill entrypoint for `VGSCollectSDK` work in customer iOS apps.

## When to use

- First-time `VGSCollectSDK` integration
- Feature work touching collector setup, secure fields, validation, submit, tokenization, alias creation, card creation or update, file upload, or card scanning
- Version migrations or replacement of deprecated usage
- Troubleshooting integration bugs or version-specific regressions
- Code review of app code that uses `VGSCollectSDK`

## References

| Topic | File |
|-------|------|
| SDK policy, security rules, flow selection, versioned guidance | `references/AGENTS.md` |

## Bundled snapshot and version freshness

`references/AGENTS.md` carries an `**SDK Version: x.y.z**` header. It is the only instruction snapshot bundled with this skill. Load it completely and do not download, execute, or reload agent instructions from repositories, tags, CDNs, documentation sites, or other runtime URLs.

Resolve the installed SDK version, in order:
1. dependency lockfiles (`Package.resolved`, CocoaPods `Podfile.lock`)
2. build manifests with exact pins (`Package.swift`, `Podfile`)
3. vendored dependency metadata or generated dependency graphs
4. user-provided dependency snippets, stated version, or build logs

Compare it with the bundled snapshot version:
- If they match, use the bundled guidance.
- If they differ, say that the installed skill covers a different SDK version and may be outdated. Do not fetch replacement instructions or silently reinstall the skill.
- Show the user these commands and ask them to update the skill before relying on version-sensitive guidance:

```bash
npx skills check
npx skills update
```

The update CLI may print a source-specific refresh command for installations that cannot be updated in place. The user should run that command themselves. Continue only with clearly version-independent guidance, label version-sensitive claims as unverified, or wait for the refreshed skill.

If the SDK version cannot be determined, disclose that the bundled snapshot version is being used; do not claim it is the latest available version.

## Retrieval policy

Use the bundled `AGENTS.md`, files already present in the user's project or installed dependency, and materials the user directly provides. Do not retrieve remote code, documentation, release notes, or instruction files at runtime.

If local evidence is insufficient to confirm an exact API or version-sensitive behavior, state what is unverified and ask the user to update the skill or provide the relevant source. Local evidence never overrides `AGENTS.md` invariants and never justifies private or undocumented API use.

## Clarifying questions

Ask only when the missing info materially changes the recommendation:
- installed `VGSCollectSDK` version or dependency snippet
- target flow (`sendData`, `tokenizeData`, `createAliases`, `createCard`, `updateCard`, `sendFile`)
- task type (integration, feature change, migration, troubleshooting, review)
- target UI layer (UIKit or SwiftUI) when relevant
- whether the card scanner (BlinkCard) module is required
- relevant error, log, or code snippet for troubleshooting

BlinkCard scanner default:
- For v3000.0.1 guidance, route users to Swift Package Manager with `VGSBlinkCardCollector`; the SwiftPM package declares iOS 16 because package platform floors are package-wide, BlinkCard v3000 requires a Swift tools 6.0-capable toolchain such as Xcode 26.2 or newer, and the scanner is not available as a CocoaPods subspec.
- Preserve the existing VGS wrapper APIs (`VGSBlinkCardController`, delegate mapping, and `VGSBlinkCardControllerRepresentable`) unless the user explicitly asks for raw BlinkCard integration.

## Routing

Choose one primary mode. In every mode: apply the collection-flow rules from `AGENTS.md` before generating output, prefer the smallest documented public API surface, and include tests or checks required by `AGENTS.md`.

### `integrate`
First-time SDK adoption.
- confirm SDK is not already present
- pick the supported installation method (Swift Package Manager, XCFramework) for the resolved version and the customer's project setup
- establish baseline collector setup and prerequisites

### `implement`
Add or change supported functionality.
- implement in the customer's app context, not a generic snippet
- generate code with explicit validation and error handling
- use placeholders only for secrets, identifiers, endpoints, and env values the user has not supplied

### `migrate`
Move between versions or replace deprecated behavior.
- compare the current and target versions with the bundled snapshot version
- if either version needs guidance not covered by the bundle, show the skill update commands and mark version-sensitive migration steps unverified until the skill is refreshed
- use a locally available `MIGRATING.md` and user-provided release notes when present
- call out behavior changes that cannot be preserved exactly

### `troubleshoot`
Failing or unexpected behavior.
- localize the failure before changing code
- prefer evidence from logs, tests, dependency state, or minimal repro
- if logs are needed, follow the resolved `AGENTS.md` debug-logging policy: verbose SDK diagnostics require a Debug build and explicit runtime opt-in, use only synthetic secure-field values, redact credentials, stay out of analytics and remote collectors, and remain disabled in Release/production
- distinguish confirmed cause from likely cause and workaround

### `review`
Patch, PR, or design review.
- review against the resolved version's `AGENTS.md` and public APIs
- prioritize correctness, safety, compatibility, missing tests
- flag private, deprecated, insecure, or version-incompatible behavior
- say explicitly when reviewed code appears to target a different version

A task may have a secondary mode, but the primary mode controls planning and output.

## Output contract

Begin every response by stating which version the guidance is based on, using one of:
- `Using bundled VGSCollectSDK 1.20.0 guidance.`
- `Detected VGSCollectSDK 1.20.0 from Package.resolved; it matches the bundled guidance.`
- `Detected VGSCollectSDK 1.21.0, but this skill bundles 1.20.0 guidance and may be outdated. Run npx skills check, then npx skills update.`
- `Could not determine the installed VGSCollectSDK version; using the bundled 1.20.0 snapshot without claiming it is latest.`

Then proceed within the bundled snapshot and version-freshness rules above.
