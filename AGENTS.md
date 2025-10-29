# AGENTS.md

Authoritative Integration & Maintenance Guide for Autonomous Agents

Scope
- Use this file as the ONLY high-level instruction source when adding, updating, or testing VGS Collect iOS SDK (`VGSCollectSDK`) usage in a downstream app.
- Contain ONLY public, non-deprecated APIs (verified via source grep; deprecated signatures and deprecated masked text field methods MUST NOT be referenced or generated).
- Emphasis: security, correctness, determinism, reproducibility.

Success Criteria for Any Agent Task
1. Sensitive data (PAN, CVC, SSN, files) NEVER logged, persisted, or leaked to analytics.
2. All fields validated (`state.isValid`) before submission.
3. Network submission surfaces aliases/tokens only to the app layer.
4. File uploads always followed by `collector.cleanFiles()` after success.
5. APIs used exist in current public surface & are not deprecated.
6. Version pins updated intentionally with a migration note & tests green.

---
## 1. Core Concepts (Mental Model)
- `VGSCollect` orchestrates secure collection & submission to a VGS Vault you own (identified by vault ID + environment / data region).
- UI inputs (`VGSTextField`, `VGSCardTextField`) never expose raw values outside controlled SDK memory; you interact through configuration + state snapshots.
- Field `state` drives UI (validity, emptiness, metadata like last4, brand) – do not persist raw input.
- Submissions can be performed via closure, async/await, or Combine publisher APIs returning success/failure with alias JSON.

---
## 2. Public Building Blocks (Summary Table)
(Do NOT assume additional behavior outside listed intents.)
- `VGSCollect`: register fields, submit data/files, observe states, manage headers, cleanup files.
- `VGSTextField`: generic configurable secure text field.
- `VGSCardTextField`: adds automatic card brand detection & icon handling (for `.cardNumber`).
- `VGSConfiguration`: binds a field to `fieldName`, semantic `type`, formatting & validation rules.
- `VGSTextFieldState` (+ specialized states e.g. `VGSCardState`): read-only snapshot for UI logic.
- `VGSFilePickerConfiguration` + `VGSFilePickerController`: secure file selection pipeline.
- `VGSBlinkCardController` (+ its delegate): card scanning (BlinkCard module) – preferred scanning path.
- Validation Rule Types (examples): `VGSValidationRuleLength`, `VGSValidationRuleLengthMatch`, (others similarly shaped) aggregated in `VGSValidationRuleSet` conforming to `VGSValidationRuleProtocol`.
- `VGSAnalyticsClient`: toggle analytics collection.
- `VGSCollectLogger`: adjust log verbosity (ensure `.none` in production if required).

Exclude: Any symbol marked `@available(*, deprecated, ...)` in sources.

---
## 2A. FieldType Reference & Capabilities
Purpose: choose correct `FieldType` to obtain built-in formatting & validation. Each case sets defaults (pattern, divider, keyboardType, validation rule set, optional metadata & sensitivity).

Notation: P=Formatting Pattern, D=Divider, Val=Default Validation Rules (names), Meta=Metadata via state, Scan=Supported by BlinkCard scan mapping, Icon=Built-in Icon Support, Sens.=Sensitive (tokenized priority).

FieldType none
- Use: generic text (no formatting/validation by default)
- P: ""  D: ""  Val: (none)  Meta: basic flags only  Scan: No  Icon: No  Sens.: No

FieldType cardNumber
- Use: PAN input with brand detection & Luhn
- P: "#### #### #### ####" (expands brand-specifically internally)  D: space
- Val: `VGSValidationRulePaymentCard`
- Meta: `VGSCardState` (`bin`, `last4`, `cardBrand`)
- Scan: Yes (BlinkCard `.cardNumber`)
- Icon: Yes via `VGSCardTextField`
- Sens.: Yes

FieldType expDate
- Use: Card expiry (MM/YY or MM/YYYY with pattern override)
- P: `##/##` (shortYear)  D: `/`
- Val: `VGSValidationRulePattern`, `VGSValidationRuleCardExpirationDate`
- Meta: basic validity; no brand data
- Scan: Yes (BlinkCard `.expirationDate`)
- Icon: No (handled inside card number field only)
- Sens.: No

FieldType date
- Use: Generic date (custom ranges)
- P: default from `VGSDateFormat` (e.g. `##/##/####` depending config)  D: `/`
- Val: `VGSValidationRulePattern`, `VGSValidationRuleDateRange`
- Meta: basic validity
- Scan: No
- Icon: No  Sens.: No

FieldType cvc
- Use: Card security code (3 or 4 digits brand dependent)
- P: `####` (allows up to 4 digits)  D: ""
- Val: `VGSValidationRulePattern`, `VGSValidationRuleLengthMatch([3,4])`
- Meta: length & validity only
- Scan: Yes (BlinkCard `.cvc`)
- Icon: Yes (use `VGSCVCTextField` for contextual CVC helper image)
- Sens.: Yes

FieldType cardHolderName
- Use: Alphanumeric cardholder name
- P: none (no masking)  D: ""
- Val: `VGSValidationRulePattern`
- Meta: validity, length
- Scan: Yes (BlinkCard `.name`)
- Icon: No  Sens.: No

FieldType ssn
- Use: US Social Security Number
- P: `###-##-####`  D: `-`
- Val: `VGSValidationRulePattern`
- Meta: may expose last4 via specialized state (`VGSSSNState`) if available
- Scan: No  Icon: No  Sens.: (Treat as sensitive in app logic even if `sensitive` flag false; never log.)

Sensitive Flag (SDK internal): `cardNumber`, `cvc` return true (restrict tokenization bypass). Treat SSN as sensitive operationally even if not flagged.

Capability Highlights
- Brand Detection: cardNumber (drives cvc length expectations & icons)
- Adaptive CVC Length: cvc field via combined rules & brand info from card field
- Metadata Objects: `VGSCardState`, `VGSSSNState`
- Customizable Pattern Override: expDate (switch to long year `##/####`), date (custom pattern), others not recommended to override except for UI spacing.

---
## 2B. Custom Payment Card Brands
Supported Brands: The SDK ships predefined editable models (e.g. visa, masterCard, amex, discover, unionpay, jcb, elo, visaElectron, maestro, forbrugsforeningen, dankort, hipercard, dinersClub). You can adjust their public model properties (e.g. `formatPattern`, length arrays) if business rules require, or fine‑tune fallback via `VGSPaymentCards.unknown`.

Editable Models: Mutating a shipped brand’s model changes detection & formatting for that brand globally. Keep regex specific and maintain checksum correctness (normally `.luhn`).

Custom Brand: Create a `VGSCustomPaymentCardModel` when a brand is not covered. Append it to `VGSPaymentCards.cutomPaymentCardModels` (order matters—first regex match wins). Optionally define a restricted set with `VGSPaymentCards.validCardBrands = [/* models in desired order */]` to override the default + custom merge.

Minimal Example:
```
let myCard = VGSCustomPaymentCardModel(
  name: "mycard",
  regex: "^(7777\\d{12})$",
  formatPattern: "#### #### #### ####",
  cardNumberLengths: [16],
  cvcLengths: [3],
  checkSumAlgorithm: .luhn,
  brandIcon: UIImage(named: "mycard_icon")
)
VGSPaymentCards.cutomPaymentCardModels.append(myCard)
```
Guidelines (short):
- Anchor regex (`^...$`), avoid broad patterns.
- Place specific custom models earlier if overlap possible.
- Never log full PAN; only brand + last4.
- Test detection positive & a near‑miss negative.

---
## 4. Field Setup & Configuration Pattern
Canonical card form snippet (UIKit):
```
let collector = VGSCollect(id: vaultId, environment: .sandbox)

let cardField = VGSCardTextField()
let cardCfg = VGSConfiguration(collector: collector, fieldName: "card_number")
cardCfg.type = .cardNumber
cardCfg.isRequiredValidOnly = true
cardField.configuration = cardCfg

let nameField = VGSTextField()
let nameCfg = VGSConfiguration(collector: collector, fieldName: "card_holder")
nameCfg.type = .name
nameField.configuration = nameCfg

let expField = VGSTextField()
let expCfg = VGSConfiguration(collector: collector, fieldName: "exp_date")
expCfg.type = .expDate
expCfg.formatPattern = "##/##" // MM/YY
expCfg.divider = "/"
expCfg.isRequiredValidOnly = true
expField.configuration = expCfg

let cvcField = VGSTextField()
let cvcCfg = VGSConfiguration(collector: collector, fieldName: "cvc")
cvcCfg.type = .cvc
cvcCfg.isRequiredValidOnly = true
cvcField.configuration = cvcCfg
```
Additional Text Field Variants
- Use `VGSCardTextField` for `.cardNumber` to obtain brand detection & dynamic formatting.
- Optionally use `VGSCVCTextField` (subclass of `VGSTextField`) for `.cvc` to show a brand-specific helper icon. Key public properties:
  - `cvcIconLocation` (.left/.right, default .right)
  - `cvcIconSize: CGSize` (default 45x45)
  - `cvcIconViewIsAccessibilityElement: Bool`
  - `cvcIconAccessibilityHint: String` (no sensitive data)
  - `cvcIconSource: (VGSPaymentCards.CardBrand) -> UIImage?` (custom icons; return nil for default)
Usage (swap for basic CVC field):
```
let cvcField = VGSCVCTextField()
let cvcCfg = VGSConfiguration(collector: collector, fieldName: "cvc")
cvcCfg.type = .cvc
cvcField.configuration = cvcCfg
cvcField.cvcIconLocation = .left
cvcField.cvcIconAccessibilityHint = "CVC help icon"
```
Behavior: Icon updates automatically when card brand changes (do not hardcode brand logic). Validation for `.cvc` type already enforces 3/4 length.
Rules for Agents:
- Always assign `configuration` before relying on `state`.
- Never mutate internal validation arrays directly; use a `VGSValidationRuleSet`.
- Use semantic field types (`.cardNumber`, `.expDate`, `.cvc`, `.name`, etc.) for built-in validation.

Edge Cases to Handle:
- Empty required fields → disable submit.
- Expiration date in past or malformed → mark invalid.
- Luhn failure for card number → invalid; keep formatting intact.
- Concurrent submissions → serialize (ignore new requests until prior completes or explicitly allow via app logic).

---
## 5. Observing & Using Field State
Delegate-based observation (UIKit example):
```
extension ViewController: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    let valid = textField.state.isValid
    textField.borderColor = valid ? .systemGray : .systemRed
    if let cardState = textField.state as? VGSCardState, cardState.isValid {
      // Safe redacted logging pattern
      logger.info("Card brand=\(cardState.cardBrand.stringValue) last4=\(cardState.last4)")
    }
  }
}
```
Never log full PAN / CVC / SSN / raw file contents.

---
## 6. Submission APIs
Validation Gate:
```
let fields = [cardField, nameField, expField, cvcField]
guard fields.allSatisfy({ $0.state.isValid }) else { return }
```
Closure Variant:
```
collector.sendData(path: "/post", extraData: ["customKey": "value"]) { response in
  switch response {
  case .success(_, let data, _): /* parse alias JSON */
  case .failure(let status, let data, _, let error): /* map status → user msg */
  }
}
```
Async/Await (iOS 15+):
```
let response = await collector.sendData(path: "/post")
```
Combine:
```
collector.sendDataPublisher(path: "/post")
  .sink { response in /* handle */ }
  .store(in: &cancellables)
```
Request Options (mapping policies): supply `VGSCollectRequestOptions(fieldNameMappingPolicy: ...)` for nested / array semantics. Use only documented policies (e.g. flat JSON, nested with array merge/overwrite).

---
## 6A. Validation Rule Catalogue
All rules conform to `VGSValidationRuleProtocol` and can be composed in a `VGSValidationRuleSet` (order typically not critical; all evaluate). Prefer built-in defaults for standard field types; override only when product requirement differs.

Rule: VGSValidationRulePaymentCard
- Purpose: Full card number structure & Luhn validation for supported brands.
- Typical Use: Auto-applied for `.cardNumber` (avoid duplicating manually).

Rule: VGSValidationRuleCardExpirationDate
- Purpose: Ensures date not in the past & month within 01–12.
- Applied: Included by default for `.expDate`.

Rule: VGSValidationRuleDateRange
- Purpose: Enforces generic date within acceptable range (implementation-defined). Use with `.date` types.

Rule: VGSValidationRulePattern
- Purpose: Regex pattern enforcement (characters, structure). Provide sanitized error key string.

Rule: VGSValidationRuleLength
- Purpose: Min/max length enforcement of raw (unformatted) input.

Rule: VGSValidationRuleLengthMatch
- Purpose: Input length must match one of provided lengths (e.g. CVC 3 or 4).

Building a Custom Rule Set Example (Name must be 2–40 chars alpha-numeric plus limited punctuation):
```
var rs = VGSValidationRuleSet()
rs.add(rule: VGSValidationRulePattern(pattern: "^([a-zA-Z0-9\\ \\,.\\-\']{2,40})$", error: "name_pattern"))
config.validationRules = rs
```
Augmenting Expiration Date to Accept Long Year:
```
expCfg.formatPattern = "##/####"
// Default rules already validate; no extra unless business-specific constraint.
```
When Overriding Defaults
- Provide explicit rules set (`config.validationRules = newSet`) – this REPLACES defaults. Ensure you re-add any necessary card/date rules if you replace them.
- Validate test coverage for each added rule (positive & negative cases).

Error Surface Strategy
- Use error identifiers (e.g., "length", "pattern") for mapping to localized strings; never inject raw user input into error messages.

---
## 7. File Upload Pipeline
Setup:
```
let pickerCfg = VGSFilePickerConfiguration(collector: collector, fieldName: "secret_doc", fileSource: .photoLibrary)
let filePicker = VGSFilePickerController(configuration: pickerCfg)
filePicker.presentFilePicker(on: self, animated: true)
```
On success: dismiss → call `sendFile` → on `.success` call `collector.cleanFiles()`.
On cancel/error: dismiss only (no cleanup needed unless previously attached file state must be cleared).
Max total file size enforced internally (rejects oversize gracefully—react by showing user message).

---
## 8. Card Scanning (BlinkCard)
Initialization:
```
let scanController = VGSBlinkCardController(licenseKey: blinkKey, delegate: self) { code in
  // License error handling (no sensitive data)
}
```
Present:
```
scanController.presentCardScanner(on: self, animated: true, modalPresentationStyle: .fullScreen, completion: nil)
```
Delegate mapping returns the appropriate `VGSTextField` for each `VGSBlinkCardDataType` case (e.g. `.cardNumber`, `.expirationDate`, `.cvc`, `.name`). Always include `NSCameraUsageDescription` in Info.plist.

---
## 9. SwiftUI Usage
Pattern:
- Wrap SDK fields with provided SwiftUI representables (ensure they do not leak raw text to `@State`).
- Maintain a `@StateObject` ViewModel holding: collector instance, configuration objects, derived validity booleans.
Async Submit Example:
```
@MainActor func submit() async {
  guard isFormValid else { return }
  let response = await collector.sendData(path: "/post")
  // map response to UI state
}
```
Never store user-entered raw sensitive strings in ViewModel properties.

---
## 10. Analytics & Privacy
Opt out if mandated:
```
VGSAnalyticsClient.shared.shouldCollectAnalytics = false
```
Do not modify analytics payload structure. Toggle only.

---
## 11. Logging & Redaction Policy
Allowed: brand, last4, validity flags, aggregate counts, error categories (e.g. timeout, validationFailure).
Forbidden: full PAN, full CVC, full SSN, unredacted file content, license keys, vault ID in user-visible error messages.
Ensure production logger level minimal (`.none` or equivalent). Strip `print` statements in CI if containing patterns of 13–19 digits (add automated regex scan).

---
## 12. Error Handling Guidelines
Map response categories:
- 4xx (client / validation): Highlight invalid fields, show corrective UI message.
- 5xx (server / transient): Offer retry, no immediate resubmit loop.
- Timeout / Network offline: Show offline indicator, allow manual retry.
Never surface raw backend debugging payload to user.

---
## 13. Security & Secrets
- Vault ID & scanning license keys injected (XCConfig / environment) – never hardcode production identifiers in source.
- Precondition: `precondition(!vaultId.isEmpty)` before initialization.
- Do not serialize `state` objects to disk.
- Call `cleanFiles()` post successful upload.

Pre-Commit CI Checklist Additions:
1. Build (Debug + Release).
2. Tests (unit + any UI/integration mocks) green.
3. Lint/format passes.
4. Regex scan for sensitive patterns (PAN-like digits, etc.).
5. Verify no deprecated API usage (grep for `deprecated` markers not allowed in new codepaths except inside SDK dependency sources).

---
## 14. Testing Strategy (Minimum Set Agents Must Maintain)
1. Validation: card number valid/invalid (Luhn) toggles `state.isValid`.
2. Expiration date past month invalid.
3. Submission success returns alias fields (mocked network or integration environment with sanitized test data).
4. File upload test: attach -> send -> assert cleanup invoked.
5. BlinkCard delegate mapping returns expected field references (if scanning included).
6. Async & Combine submission tests (ensure no main-thread blocking).
All tests must avoid real PANs; use test numbers like `4111111111111111` only in non-production test targets.

---
## 15. Performance & Concurrency Guidelines
- Create configurations once (e.g. `viewDidLoad` / SwiftUI `init`).
- Avoid re-binding configuration objects repeatedly.
- Submissions are internally asynchronous; UI updates must execute on main actor.
- Prevent multiple simultaneous overlapping submissions unless explicitly required (track a submission in-flight flag).

---
## 16. Typical Agent Task Recipes
Add Card Form:
1. Instantiate `VGSCollect` with pinned environment.
2. Configure fields (card, name, exp, cvc) with correct types.
3. Observe changes → enable submit when all valid.
4. Submit via chosen API variant; parse aliases; clear UI if needed.

Add File Upload:
1. Add picker configuration & controller.
2. Present selection UI.
3. On pick, send file -> on success `cleanFiles()`.

Add BlinkCard Scan:
1. Add BlinkCard module dependency.
2. Initialize controller with license key + delegate.
3. Present scanner; map scanned types to existing fields.

Add Custom Validation Rule (length or pattern example):
```
var rules = VGSValidationRuleSet()
rules.add(rule: VGSValidationRuleLength(min: 2, max: 40, error: "name_length"))
config.validationRules = rules
```

---
## 17. Upgrade & Migration Flow
1. Change version pin.
2. Build + run tests.
3. Review release notes for API additions/removals.
4. Update affected code (avoid deprecated replacements if still available; choose newest non-deprecated path).
5. Update this file only if public usage guidance changes.

---
## 18. Non-Goals (What Agents Must Not Attempt)
- Re-implement tokenization or encryption around SDK fields.
- Access or reflect private/internal properties through reflection.
- Modify files inside the SDK dependency to change behavior.
- Integrate unapproved scanning frameworks beyond supported BlinkCard module.

---
## 19. Pre-Merge Security Review Checklist
[ ] No logs of sensitive raw values.
[ ] No deprecated API references added.
[ ] All validation gates present before submissions.
[ ] File uploads followed by cleanup.
[ ] Secrets injected, not hardcoded.
[ ] Tests cover new code paths affecting sensitive data.

---
## 20. Glossary
- Vault ID: Identifier for your VGS secure storage.
- Alias / Token: Non-sensitive substitute returned after submission.
- PAN: Primary Account Number (card number).
- CVC: Card security code.
- BIN: Leading digits identifying issuer.
- State: Snapshot object describing field validity/metadata.
- BlinkCard: Supported VGS scanning solution.

---
## 21. Quick Reference Snippets
Async Submit:
```
@MainActor func submit() async {
  guard formValid else { return }
  let resp = await collector.sendData(path: "/post")
  // handle resp
}
```
Combine Submit:
```
collector.sendDataPublisher(path: "/post")
  .sink { resp in /* map */ }
  .store(in: &cancellables)
```
File Upload:
```
collector.sendFile(path: "/post") { result in
  if case .success = result { collector.cleanFiles() }
}
```
Redacted Card Log:
```
if let s = field.state as? VGSCardState, s.isValid {
  logger.info("brand=\(s.cardBrand.stringValue) last4=\(s.last4)")
}
```

---
## 22. Final Rule for Agents
If uncertain between two approaches, choose the one that:
1. Uses fewer APIs.
2. Avoids storing or exposing raw sensitive data.
3. Prefers non-deprecated, documented public surface.

Escalate (via comments / PR note) only when a required behavior is impossible without private or deprecated API access.

End of AGENTS.md
