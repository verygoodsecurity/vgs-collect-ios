# demoapp

`demoapp` is a sample app with end-to-end use-case examples for `VGSCollectSDK` integrations.

## Current Integration Model

- The app is built from `demoapp/demoapp.xcodeproj` (not an `.xcworkspace`).
- Dependencies are resolved with Swift Package Manager.
- The project uses a **local package reference** to repository root (`..`), so demo builds against local SDK sources by default.
- Linked local package products:
  - `VGSCollectSDK`
  - `VGSBlinkCardCollector`
  - `VGSCardIOCollector`

## Demo Flows (from `Main.storyboard`)

- Collect Payment Cards Data
- Customize Payment Cards
- Collect Social Security Number
- Create Card (CMP demo)
- Tokenize Card Data (Vault API v1)
- Create Card Aliases (Vault API v2)
- Collect Custom Data
- Collect Date Data
- Collect+Combine
- Collect Files
- Collect ApplePay Data
- Collect Card Data in SwiftUI

## Configuration

Primary runtime config is in `demoapp/demoapp/AppCollectorConfiguration.swift`:

- `vaultId`
- `tokenizationVaultId`
- `environment` (`.sandbox` by default)
- `blinkCardLicenseKey` (optional, required for scanner actions)

Also note these flow-specific placeholders:

- `demoapp/demoapp/UseCases/CreateCardViewController.swift`:
  - `jwtToken = "<your_cpm_jwtToken>"`
- `demoapp/demoapp/UseCases/CreateCardAliasesViewController.swift`:
  - `authToken = "<your_authentication_token>"`
- `demoapp/demoapp/UseCases/CollectApplePayDataViewController.swift`:
  - `paymentRequest.merchantIdentifier = "<merchant-id>"`
- `demoapp/demoapp/UseCases/CustomPaymentCardsViewController.swift`:
  - Initializes collector with placeholder hostname `"blablabla.com"` (update for real testing).

## Build and Run

From repository root:

```bash
xcodebuild -resolvePackageDependencies \
  -project demoapp/demoapp.xcodeproj \
  -scheme demoapp

xcodebuild build \
  -project demoapp/demoapp.xcodeproj \
  -scheme demoapp \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'
```

Or open in Xcode:

```bash
open demoapp/demoapp.xcodeproj
```

## UI Tests

UITests set launch argument `VGSCollectDemoAppUITests`.  
On app startup, `UITestsMockedDataProvider` reads `demoapp/demoapp/UITestsMockedData.plist` and injects:

- `vaultID`
- `tokenization_vaultId`

Populate test data before running UI tests:

```bash
plutil -replace vaultID -string "<vault_id>" demoapp/demoapp/UITestsMockedData.plist
plutil -replace tokenization_vaultId -string "<tokenization_vault_id>" demoapp/demoapp/UITestsMockedData.plist
```

Run tests:

```bash
xcodebuild -resolvePackageDependencies \
  -project demoapp/demoapp.xcodeproj \
  -scheme demoappUITests

xcodebuild test \
  -project demoapp/demoapp.xcodeproj \
  -scheme demoappUITests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'
```

## Local SDK Change Validation

Because the demo project points to local package path `..`, changes under:

- `Sources/VGSCollectSDK`
- `Sources/VGSBlinkCardCollector`
- `Sources/VGSCardIOCollector`

are picked up directly by `demoapp` after rebuild/retest, without `pod install`.

## Notes

- Debug logging is enabled in `demoapp/demoapp/AppDelegate.swift` for `DEBUG` builds.
- Some flows require additional backend setup and valid credentials; otherwise `/post` requests will fail with 4xx responses.
- Apple Pay flow requires a real device and valid merchant configuration.
