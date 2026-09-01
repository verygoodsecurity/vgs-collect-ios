# VGS Collect iOS Contributor Guide

## Scope and Authority

This file is for internal contributors and coding agents changing this repository. It covers repository architecture, implementation constraints, development workflow, testing, security review, and commit preparation.

- Read the repository root `AGENTS.md` first when changing SDK behavior, public API, examples, or integration guidance. It is the source of truth for customer-facing SDK invariants.
- Use this file for repository mechanics and internal contribution rules.
- Read `ARCHITECTURE.md`, `SECURITY.md`, and the most specific instructions for the files being changed before implementation.
- Use a relevant repository or machine-installed skill when one matches the work.
- If contributor guidance conflicts with a customer security invariant in root `AGENTS.md`, the stricter security rule wins.
- Keep internal implementation and maintenance details here or in other contributor-only files. Do not move them into customer-facing `README.md` or public `skills/` references.

## Contributor Mental Model

VGS Collect iOS is an iOS SDK for collecting, validating, and securely submitting sensitive values. The application configures SDK-owned fields and observes state metadata; it must not receive raw PAN, CVC, SSN, or file contents from those fields.

The primary runtime flow is:

```text
Application UI
  -> VGS field configuration and SDK-owned input
  -> formatting, validation, and state snapshots
  -> collector request mapping
  -> proxy, Vault, or CMP API client
  -> categorical response or aliases/tokens returned to the app
```

Core invariants:

- `VGSCollect` owns field registration, request assembly, submission, tokenization, and CMP operations.
- `VGSTextField` and its specializations retain raw sensitive input inside SDK-controlled memory. App-facing behavior should use configuration and state.
- Semantic field types drive default formatting and validation. Do not bypass them without a documented product requirement and tests.
- Validation remains in place before any submit, tokenize, alias, create-card, or update-card operation.
- File selection and upload remain SDK-controlled; successful uploads are followed by `cleanFiles()`.
- Scanner modules map scanned values into existing secure fields. They must not introduce a second raw-data path into app state, logs, analytics, or persistence.
- Closure, async/await, and Combine variants are parallel public surfaces. A behavioral change to one must be checked against the others.
- Analytics, logging, errors, and debug tooling are data-exfiltration boundaries and require privacy review.

## Project Structure

| Path | Responsibility |
| --- | --- |
| `Sources/VGSCollectSDK/Core/Collector/` | Main collector, field registration, request mapping, proxy/Vault/CMP operations |
| `Sources/VGSCollectSDK/Core/API/` | API clients, host validation, response and transport behavior |
| `Sources/VGSCollectSDK/Core/Analytics/` | SDK analytics and event construction |
| `Sources/VGSCollectSDK/Core/TokenizationConfiguration/` | Vault tokenization and alias configuration types |
| `Sources/VGSCollectSDK/Core/VGSPaymentCards/` | Card-brand models, detection metadata, and card rules |
| `Sources/VGSCollectSDK/UIElements/Text Field/` | UIKit and SwiftUI secure fields, state, masks, formatting, validation |
| `Sources/VGSCollectSDK/UIElements/FilePicker/` | Secure file selection and attachment lifecycle |
| `Sources/VGSCollectSDK/Utils/Loggers/` | Logging facade, formatting, and network diagnostics |
| `Sources/VGSBlinkCardCollector/` | Preferred BlinkCard scanner integration |
| `Sources/VGSCardIOCollector/` | Legacy CardIO integration; maintain compatibility, do not use for new scanner features |
| `Tests/FrameworkTests/` | Core SDK, API, state, validation, tokenization, mapping, file, and BlinkCard tests |
| `VGSCardIOCollectorTests/` | CardIO-specific compatibility tests |
| `demoapp/` | Manual integration examples and UI tests; not an alternate implementation of SDK behavior |
| `Package.swift` | Swift Package Manager products, dependencies, resources, and minimum platform |
| `VGSCollectSDK.podspec` | CocoaPods packaging and release version |
| `skills/vgs-collect-ios-guide/` | Public AI integration skill; must reflect shipped public behavior |
| `docs/` | Generated API documentation; update through the documented generator workflow |
| `.github/workflows/` | CI, security, skill validation, review automation, and public mirroring |

### Change Routing

- Collector, submission, tokenization, CMP, field, or validation behavior: change `Sources/VGSCollectSDK/` and add focused `FrameworkTests` coverage.
- Logging, analytics, error mapping, or privacy manifest: review the entire emitted data shape, not only the changed line.
- File picker or scanner behavior: keep the integration module isolated and test mapping plus cleanup paths.
- Public API or documented behavior: update tests, source documentation, `README.md`, `MIGRATING.md` when applicable, root `AGENTS.md`, and the public skill in the same change.
- Dependency or platform changes: check both `Package.swift` and `VGSCollectSDK.podspec`, affected scanner modules, CI, README compatibility claims, and migration notes.
- Demo-only behavior: avoid changing core SDK code unless the demo exposed a real SDK defect.

## Security and Privacy Rules

### Data Classification

Treat the following as sensitive:

- PAN, CVC, SSN, passwords, bank account and routing values, dates of birth, and raw file contents.
- Authorization headers, access tokens, OAuth credentials, client secrets, scanner license keys, and other credentials.
- Production or customer vault IDs, route IDs, hostnames, request payloads, response bodies, and identifiers that reveal customer configuration.
- Field state descriptions, errors, fixtures, screenshots, recordings, test artifacts, or console output that can contain any of the above.

Safe-by-default telemetry is limited to allowlisted categorical metadata such as operation name, SDK version, status class, duration, validation result, card brand, and last four digits when the source contract explicitly permits them.

### Non-Negotiable Rules

- Never commit, upload, paste into a PR, or send to analytics any real customer or production sensitive data.
- Never persist raw secure-field values or files outside the SDK-controlled lifecycle.
- Never add analytics fields from arbitrary request bodies, response bodies, headers, errors, or field state descriptions.
- Never emit authorization values, secrets, license keys, or full sensitive values outside an explicitly enabled, local Debug diagnostic session that uses synthetic values and disposable test credentials. This exception is only for inspecting the exact request and response and must be disabled before commit.
- Keep production logging minimal and opt-in diagnostics disabled by default.
- User-facing errors must remain categorical and must not expose raw backend payloads.
- Use synthetic test data only in tests and local sandbox runs. Test card numbers belong in non-production test/demo contexts and must not be mistaken for authorization to log real data.
- Report suspected vulnerabilities privately according to `SECURITY.md`; do not open a public issue or PR containing exploit details.

## Runtime Logging and the Pre-Commit Boundary

Debuggability is required, but runtime investigation and committed observability have different standards.

### Temporary Local Diagnostics

Contributors may add temporary logs or enable `VGSCollectLogger` while reproducing a problem when all of these conditions hold:

- The run uses a sandbox or mocked endpoint, synthetic secure-field values, and disposable test credentials only.
- No production/customer credentials, vaults, routes, hostnames, files, or traffic are involved.
- Console output stays local and is not copied into tickets, prompts, CI artifacts, screenshots, or shared recordings without sanitization.
- Network debugging is enabled only for the active debug session. It must show the exact request URL, method, headers, and body plus the exact response status, headers, and body without masking values; inspect the test setup before enabling `isNetworkDebugEnabled`.
- Temporary logging is narrowly scoped, clearly identifiable, and removed before staging.

When exact payload inspection is necessary, use the explicitly enabled local logger or a debugger breakpoint. Disable diagnostics immediately after the investigation and verify they remain disabled before staging or committing.

### Rules for Committed Logging

Before commit, the standard becomes stricter:

- Remove temporary `print`, `debugPrint`, `dump`, `NSLog`, `os_log`, and equivalent statements.
- Do not commit unconditional or ad hoc logs of request or response bodies, unfiltered headers, secure field state descriptions, file metadata that identifies content, or raw error payloads. The reusable network diagnostic path is the exception: it may log the exact request and response only behind explicit runtime opt-in that is disabled by default.
- New persistent SDK log events must use `VGSCollectLogger`, remain categorical, and have an explicit privacy-safe allowlist of values. Exact request and response output belongs only in the reusable network diagnostic path.
- New analytics events must be deterministic, schema-reviewed, and free of user-entered or backend-provided free-form values.
- Demo logging must model safe customer behavior. Remove temporary logging before commit. A deliberate network-diagnostics example may enable the runtime opt-in inside `#if DEBUG`; Release builds must not enable it.
- Network debugging must remain disabled by default in the SDK and disabled in shipping app configurations. The SDK logger remains build-configuration agnostic; integrating apps own the `#if DEBUG` boundary around enablement.
- Tests should assert the SDK's disabled-by-default behavior and the integrating app's Debug-only enablement when logging changes. Analytics, telemetry, crash reporting, and persistent logs must still exclude sensitive values.

Run a focused pre-commit scan over changed Swift files and inspect every match:

```bash
git diff -- '*.swift' | rg -n 'print\(|debugPrint\(|dump\(|NSLog|os_log|logger|logRequest|logResponse|analytics'
git diff --cached --check
```

Pattern scans are review aids, not proof of safety. Inspect the actual data flow and values.

## Implementation Standards

- Use public, non-deprecated APIs for customer-facing code and examples.
- Preserve source compatibility unless the task explicitly includes a breaking change and migration plan.
- Keep changes in the narrowest responsible module. Avoid opportunistic refactors.
- Maintain `@MainActor` and concurrency boundaries. UI state updates occur on the main actor; network work must not block it.
- Keep closure, async/await, and Combine behavior and error mapping aligned.
- Keep field configuration one-time and deterministic; do not repeatedly rebind fields as a state-management shortcut.
- Do not access secure field internals through reflection or expose raw values through new public API.
- Do not reimplement tokenization, encryption, scanner extraction, or file handling outside the existing SDK boundaries.
- Use typed error categories and stable identifiers. Do not build errors from unsanitized user or backend text.
- Fix typos in files you touch, but do not reformat unrelated files or generated output.
- Add focused regression tests for every behavior change, including negative and edge cases.

## Test and Validation Matrix

Use the smallest relevant checks while iterating, then run the full affected gate before finalizing.

### Core SDK

Use the CI command shape with an installed simulator:

```bash
xcodebuild test \
  -project VGSCollectSDK.xcodeproj \
  -scheme FrameworkTests \
  -destination 'platform=iOS Simulator,name=<installed simulator>' \
  -parallel-testing-enabled NO \
  -testPlan FrameworkTests \
  CODE_SIGN_IDENTITY='' \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

For a focused iteration, add `-only-testing:<test-target>/<test-suite>` and report exactly what ran.

### Demo UI

Run for UI wiring, accessibility, scanner presentation, or demo-flow changes:

```bash
xcodebuild test \
  -project demoapp/demoapp.xcodeproj \
  -scheme demoappUITests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=<installed simulator>' \
  -parallel-testing-enabled NO
```

### Additional Checks

- CardIO changes: run `VGSCardIOCollectorTests` in addition to core tests.
- Public skill changes: run the validation defined in `.github/workflows/validate-skills.yml`.
- Contributor/agent guidance changes: run `python3 scripts/check_mental_model_sync.py` when its retained files are present and applicable; otherwise report the stale or missing prerequisite instead of claiming success.
- DEVX feature branches matching `feature/DEVX-<ticket>/<slug>`: run `scripts/check_feature_artifacts.sh` and maintain required `.specs/features/<ticket>/` artifacts.
- All changes: run `git diff --check` and inspect `git status --short` so unrelated files are not staged.

Do not claim a CI, device, scanner, live service, CocoaPods publication, or public mirror result from a local unit-test pass. Report each validation boundary separately.

## Documentation and Release Consistency

- Root `AGENTS.md` and `skills/vgs-collect-ios-guide/references/AGENTS.md` are the same canonical public integration policy through a symlink; do not replace the link with a divergent copy.
- Keep customer-facing docs limited to public behavior, supported setup, and safe examples.
- Update `MIGRATING.md` when consumers must change code or deployment/toolchain requirements.
- Keep version and compatibility claims aligned across `VGSCollectSDK.podspec`, root `AGENTS.md`, `README.md`, `MIGRATING.md`, package metadata, generated docs, and the public skill.
- Do not hand-edit generated API documentation when a generator-owned workflow applies.
- Release tags are outside normal feature work. Do not create or push a tag, publish a pod/package, or trigger a public release without explicit authorization and release validation.

## Git, Branch, and Commit Rules

- Inspect `git status --short --branch` before editing and before finalizing.
- Preserve unrelated modified and untracked files. Stage explicit paths only.
- Fetching remote refs does not authorize merging, rebasing, force-pushing, or rewriting another contributor's work.
- Follow the repository branch convention for ticketed work: `feature/DEVX-<ticket-number>/<short-description>`.
- Create signed commits only.
- Keep each commit focused and buildable. Generated documentation or metadata required by the same API change may remain in that commit.
- Use an imperative, concise subject. Target 50 characters and do not exceed 72 unless a ticket or package name makes that impractical. Do not end it with a period.
- Prefer a ticket prefix when work has a DEVX ticket; otherwise use `<type>: <summary>` or `<type>(<scope>): <summary>`. Supported types are `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`, `ci`, `build`, `release`, and `revert`.
- Use `BREAKING CHANGE:` in the footer for an intentional public API break and include the migration path.
- Do not add AI attribution or generated-by/co-author trailers unless explicitly requested.
- Do not include secrets, customer identifiers, raw logs, or sensitive payload examples in commit messages or PR descriptions.

### Commit Subject Templates

```text
DEVX-1234: add card attribute lookup validation
fix: redact authorization headers from request diagnostics
feat(collector): add async card update support
test: cover expired card validation
docs: clarify BlinkCard SwiftPM requirements
ci: pin workflow action digests
build: update minimum iOS deployment target
release: prepare public release X.Y.Z
```

### Commit Body Template

Use a body when the reason, risk, migration, or validation is not obvious:

```text
DEVX-1234: concise imperative summary

Why:
- Explain the user or SDK problem.

What:
- Describe the behavior and boundaries changed.

Security:
- State the sensitive-data and logging impact, or "No sensitive-data impact."

Validation:
- List exact tests and checks run.
```

## Pull Request Checklist

Before opening or updating a PR:

- [ ] The diff is limited to the requested behavior and required synchronized artifacts.
- [ ] Public API and compatibility impact are described.
- [ ] Tests cover success, failure, and privacy-sensitive paths where applicable.
- [ ] Temporary diagnostics are removed and committed logs are privacy-safe.
- [ ] No secrets, production/customer identifiers, raw payloads, or real sensitive data appear in the diff or PR text.
- [ ] `README.md`, `MIGRATING.md`, root `AGENTS.md`, public skills, generated docs, and release metadata were updated when required.
- [ ] Exact local validation is reported; unverified CI, live service, publication, and mirror status remain explicitly pending.
- [ ] Only intended files are staged, and the commit is signed.

## Final Contributor Rule

When uncertain, choose the design that keeps raw sensitive data inside existing SDK-controlled boundaries, emits less data, changes fewer modules, preserves public compatibility, and is easiest to verify with focused tests. Escalate when the requested behavior would require private API access, weaken validation, expose raw values, or broaden logging/analytics collection.
