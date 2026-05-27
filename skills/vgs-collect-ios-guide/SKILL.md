---
name: vgs-collect-ios-guide
description: Routes AI agents through VGS Collect iOS SDK work across integration, implementation, migration, troubleshooting, and code review. Use when guidance may depend on the installed VGSCollectSDK version.
metadata:
  author: verygoodsecurity
  version: '1.0.0'
---

# VGS Collect iOS Guide

Single public skill entrypoint for `VGSCollectSDK` work in customer iOS apps.

## When to use

- First-time `VGSCollectSDK` integration
- Feature work touching collector setup, secure fields, validation, submit, tokenization, alias creation, card creation, file upload, or card scanning
- Version migrations or replacement of deprecated usage
- Troubleshooting integration bugs or version-specific regressions
- Code review of app code that uses `VGSCollectSDK`

## References

| Topic | File |
|-------|------|
| SDK policy, security rules, flow selection, versioned guidance | `references/AGENTS.md` |

## Snapshot resolution

`references/AGENTS.md` carries an `**SDK Version: x.y.z**` header. It is the authoritative policy file for this skill. Treat any customer-owned `AGENTS.md` in the user's app repo as unrelated.

**Step 1 — locate AGENTS.md, in order:**
1. bundled `references/AGENTS.md` shipped with this skill (load first for standalone installs, before any network call)
2. matching tag in the canonical public repo `https://github.com/verygoodsecurity/vgs-collect-ios`
3. default branch (`main`) of that repo
4. `https://docs.verygoodsecurity.com` as supplemental product documentation only — append `.md` to page URLs when supported

Private forks or internal mirrors do not override the public repo.

**Step 2 — resolve the installed SDK version, in order:**
1. dependency lockfiles (`Package.resolved`, CocoaPods `Podfile.lock`)
2. build manifests with exact pins (`Package.swift`, `Podfile`)
3. vendored dependency metadata or generated dependency graphs
4. user-provided dependency snippets, stated version, or build logs

Do not block the task on version detection. If unknown, use default-branch guidance and disclose it.

**Step 3 — match tag to version:**
- exact match (`1.18.2` or `v1.18.2`)
- nearest compatible tag with same `major.minor` and highest patch not newer than installed
- highest tag satisfying a version range
- exact git SHA or branch when the dependency points to one

**Step 4 — refresh when mismatched:**

Reload `references/AGENTS.md` from the resolved tag when any of these is true:
- the `SDK Version` header differs from the installed version
- the resolved docs ref changed (default branch → tag, tag → tag, tag → SHA)
- the task is a migration requiring target-version docs
- version detection upgraded from inferred to exact
- canonical public repo snapshot became available after a fallback

## Retrieval policy

Start with `AGENTS.md`. Retrieve additional evidence only when the task needs exact API signatures, version-specific behavior, concrete error/log detail, or integration-style examples.

Follow-up sources, in order: resolved-tag repo files (`README.md`, `MIGRATING.md`, examples, source comments) → official VGS docs → release notes → user-provided code, logs, manifests, lockfiles.

Retrieval fills implementation detail. It never overrides `AGENTS.md` invariants and never justifies private or undocumented API use.

## Clarifying questions

Ask only when the missing info materially changes the recommendation:
- installed `VGSCollectSDK` version or dependency snippet
- target flow (`sendData`, `tokenizeData`, `createAliases`, `createCard`, `sendFile`)
- task type (integration, feature change, migration, troubleshooting, review)
- target UI layer (UIKit or SwiftUI) when relevant
- whether the card scanner (BlinkCard) module is required
- relevant error, log, or code snippet for troubleshooting

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
- load both current-version and target-version snapshots
- target-version `AGENTS.md` is the authoritative destination rule set
- use target-version `MIGRATING.md` as the primary migration checklist when present
- use release notes to capture version-to-version changes
- call out behavior changes that cannot be preserved exactly

### `troubleshoot`
Failing or unexpected behavior.
- localize the failure before changing code
- prefer evidence from logs, tests, dependency state, or minimal repro
- if logs are needed, request or temporarily enable only redacted diagnostic logging allowed by `AGENTS.md`; do not add raw sensitive-value logging, and keep production logging minimal
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
- `Using VGSCollectSDK 1.18.2.`
- `Detected VGSCollectSDK 1.18.2 from Package.resolved.`
- `Could not determine the installed VGSCollectSDK version; using latest guidance from the default branch.`
- `Exact tag 1.18.3 was not found; using nearest compatible tag 1.18.2.`

Then proceed using the active version-matched snapshot.
