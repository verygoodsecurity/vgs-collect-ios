# iOS SDK Mental Model (Contributor-Facing)

This is an internal contributor guide describing how customers use `VGSCollectSDK` so maintenance changes preserve integration behavior.

## Authority and Conflict Resolution

- `../../AGENTS.md` is the canonical integration policy used by consumer/integration agents.
- This file is a contributor-oriented summary of that policy and must not introduce new integration rules.
- If any statement here differs from `../../AGENTS.md`, follow `../../AGENTS.md` and update this file.

## Customer Integration Flow

1. App creates `VGSCollect` with vault id and explicit environment.
2. App configures secure fields (`VGSTextField`, `VGSCardTextField`, optional scanner/file components) using `VGSConfiguration`.
3. SDK owns raw sensitive input handling; app reads field state snapshots for validity and metadata.
4. App validates fields before submission/tokenization.
5. App submits via collector APIs and receives alias/token response payloads.
6. For file upload flows, app calls `collector.cleanFiles()` after successful upload.

## Submission Family Selection

- `VGSCollect(id:environment:)` is shared setup, not a substitute for choosing a submission family.
- Integrators may submit through `sendData`, `tokenizeData`, `createAliases`, `createCard`, or `sendFile` depending on the product flow.
- Generic card-entry prompts are not enough to assume `createCard`; explicit CMP or card-management intent is required.
- Non-card fields such as SSN, password, routing number, or generic identifiers must not drift into card-management APIs.
- When the intended submission family is ambiguous, contributor-facing guidance should preserve a clarification step instead of guessing.

## Primary Customer Use Cases to Preserve

- Card form tokenization:
  - Typical fields are card number, cardholder name, expiration date, and CVC with semantic field types.
  - Integrators gate submission with `state.isValid` across all required fields.
  - Submission is used through closure, async/await, or Combine APIs and should remain behaviorally equivalent.
- File upload:
  - Integrators present `VGSFilePickerController`, upload with `sendFile`, and clean temporary files with `collector.cleanFiles()` after success.
  - This success cleanup path is a hard integration contract.
- Card scanning:
  - Integrators wire `VGSBlinkCardController` delegate mapping for card number, expiration date, CVC, and cardholder name.
  - SwiftPM setups require explicit `import VGSBlinkCardCollector` where scanner symbols are used.
- SwiftUI integration:
  - Integrators use wrapper views/view models and should never have to store raw PAN/CVC/SSN in `@State` or persisted app state.
- Validation customization:
  - Integrators may replace default rule sets with `VGSValidationRuleSet`; replacement must continue to allow required built-in constraints for the use case.

## Behavioral Contracts Contributors Must Keep Intact

- Environment safety:
  - Non-empty vault id precondition remains expected.
  - `.sandbox`/`.live` selection remains explicit and not user-derived at runtime.
- Field semantics:
  - Field configuration must occur before state-driven logic is relied on.
  - Semantic field types continue to provide expected formatting/validation behavior (for example PAN Luhn and expiration date validity checks).
  - Replacing `validationRules` continues to replace defaults (not merge implicitly).
- Privacy and observability:
  - Logging/analytics surfaces remain redacted and category-oriented.
  - User-facing errors remain mapped to safe categories (validation, transient server, timeout/offline) instead of raw backend internals.
- Concurrency and responsiveness:
  - Submission APIs stay asynchronous and UI-safe.
  - Integrator patterns that serialize in-flight submits should not regress due to SDK behavior changes.

## Non-Negotiable Integration Invariants

- No raw PAN/CVC/SSN/file content leaks to logs, analytics, or app persistence.
- Public API behavior remains predictable and non-deprecated.
- Contributor changes must keep integrations on public, non-deprecated APIs.
- Validation gates remain in place before submit/tokenize.
- App-facing outputs remain alias/token oriented.
- Environment/config selection remains explicit and safe.

## What Contributors Must Preserve

- Existing public usage patterns in `../../AGENTS.md` and integration examples.
- Error semantics that integrators already map in app code.
- Field type semantics (formatting, validation, metadata expectations).
- Scanner and file picker behavior contracts where used by integration samples.

## Change Review Checklist

1. Can a current integrator use the same setup flow unchanged?
2. Did any error code/message contract effectively change?
3. Did any validation rule behavior or timing change?
4. Could this change expose sensitive values at any app boundary?
5. Are test and demo expectations still aligned with customer setup?

## Minimum High-Risk Regression Checks

1. Card number Luhn validity toggles `state.isValid` correctly.
2. Expiration date in past is invalid.
3. Submission success still returns alias/token payloads to the app boundary.
4. File upload success path still triggers `collector.cleanFiles()`.
5. Scanner delegate mapping still targets the expected text fields.
6. Async and Combine submission paths remain non-blocking for UI flows.

## Source-of-Truth Pointers

- Integration policy: `../../AGENTS.md`
- Implementation map: `ARCHITECTURE.md`
- Maintenance routing: `.codex/agents/README.md`
