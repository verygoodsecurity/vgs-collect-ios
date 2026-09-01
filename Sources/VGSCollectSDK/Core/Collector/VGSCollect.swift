//
//  VGSForm.swift
//  VGSCollectSDK
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// A collector object that registers secure input fields (`VGSTextField`) and submits their data/files to a VGS Vault.
///
/// Summary:
/// Provides the orchestration layer for secure data collection: field registration, state observation, JSON/body construction, vault/network submission, tokenization/alias creation and file lifecycle management.
///
/// Responsibilities:
/// - Registers text fields automatically when a `VGSConfiguration` referencing this collector is assigned.
/// - Observes editing state via `observeFieldState` (focused field) and `observeStates` (all fields snapshot).
/// - Submits values with `sendData` / `sendFile` (closure, async/await, Combine variants).
/// - Performs tokenization (`tokenizeData`) and alias creation (`createAliases`), plus card creation via CMP (`createCard`).
/// - Cleans up attached files after successful upload (`cleanFiles`).
///
/// Security:
/// - Never logs or exposes raw sensitive values through public APIs.
/// - Avoid adding PII or secrets to `customHeaders` & `fieldName` values; use them strictly for routing/auth metadata.
/// - Internal storage is transient and cleared/replaced as input changes; persistence is the caller's responsibility (and should only store aliases).
///
/// Usage:
/// 1. Initialize with vault id & environment: `let collector = VGSCollect(id: vaultId, environment: .sandbox)`.
/// 2. Create a `VGSConfiguration` per field and assign to each `VGSTextField` (registration happens automatically).
/// 3. Optionally set observation closures for validation/UI updates.
/// 4. Validate all required fields (`state.isValid`) before calling a submit method.
/// 5. Parse response aliases/tokens; discard raw user input from UI components.
/// 6. After file submission success, call `cleanFiles()`.
///
/// Invariants / Preconditions:
/// - `id` must be a non-empty vault identifier.
/// - All required fields should be valid before invoking submission APIs.
/// - Only one logical file should be attached when calling `sendFile`.
/// - For alias creation (`createAliases`), appropriate authentication must be provided in `customHeaders`.
/// - UI access (field state collection) occurs on the main thread; ensure you invoke async calls from the main actor when updating UI.
///
/// See also:
/// - `VGSConfiguration` (per-field setup)
/// - `VGSCollectRequestOptions` (JSON mapping policy)
/// - `VGSValidationRuleSet` (custom validation)
@MainActor public class VGSCollect: @MainActor VGSCardAttributesLookupService {
    internal let proxyAPIClient: ProxyAPIClient
    internal let cmpAPIClient: CMPAPIClient
    internal let storage = Storage()
    internal let regionalEnvironment: String
    internal let tenantId: String

    /// :nodoc: Form analytics details.
    internal(set) public var formAnalyticsDetails: VGSFormAnanlyticsDetails
  
    /// Max file size limit by proxy. Is static and can't be changed!
    internal let maxFileSizeInternalLimitInBytes = 24_000_000
    /// Unique form identifier.
    internal let formId = UUID().uuidString

    /// Form name supplied to `session(with:)`.
    ///
    /// CMP includes this value as `_formId` for session-created cards. Direct
    /// collectors leave it unset.
    internal var sessionFormId: String?

    /// Remote config-driven list of card attributes requested by the form config.
    /// If empty, card attributes lookup should not be triggered.
    internal var includedCardAttributes: [String] = []

    /// Shared cache for bearer JWT used by card lookup and tokenless card management requests.
    ///
    /// Note: explicit-token card requests do not store provided tokens.
    internal let jwtTokenCache = JWTTokenCache()
  
    /// Dedicated URL session for card attributes lookup requests.
    /// Kept injectable for deterministic tests.
    internal var cardAttributesLookupURLSession = URLSession(configuration: .ephemeral)

    // MARK: Custom HTTP Headers
    
    /// A dictionary of custom HTTP header key-value pairs applied to all subsequent network submissions initiated by this collector.
    ///
    /// Purpose:
    /// Provide route-specific auth tokens (e.g. Bearer JWT), idempotency or correlation identifiers.
    ///
    /// Security:
    /// - Never include raw PAN/CVC/SSN or other sensitive user input.
    public var customHeaders: [String: String]? {
        didSet {
            if customHeaders != oldValue {
                proxyAPIClient.setCustomHeaders(headers: customHeaders)
            }
        }
    }
    
    // MARK: Observe VGSTextField states
    
    /// Closure invoked on every editing event for the currently focused `VGSTextField`.
    ///
    /// Purpose:
    /// Supply real-time, field-specific validation feedback or UI updates (e.g. show/hide error label).
    ///
    /// Behavior:
    /// - Called after input changes or focus transitions.
    /// - Provides access to `textField.state` for validation and metadata (e.g. card brand via cast to `VGSCardState`).
    ///
    /// Usage:
    /// ```swift
    /// collector.observeFieldState = { tf in
    ///   if !tf.state.isValid { /* highlight */ }
    /// }
    /// ```
    public var observeFieldState: ((_ textField: VGSTextField) -> Void)?
    
    /// Closure invoked on every editing event with a snapshot array of all registered `VGSTextField` instances.
    ///
    /// Purpose:
    /// Evaluate aggregate form validity or enable/disable a submit button.
    ///
    /// Behavior:
    /// - Each field's `.state` reflects latest formatting & validation outcome.
    ///
    /// Usage:
    /// ```swift
    /// collector.observeStates = { fields in
    ///   submitButton.isEnabled = fields.allSatisfy { $0.state.isValid }
    /// }
    /// ```
    public var observeStates: ((_ form: [VGSTextField]) -> Void)?
  
    // MARK: Get Registered VGSTextFields
    
    /// All text fields currently registered with this collector.
    ///
    /// Registration:
    /// Occurs automatically when a `VGSConfiguration` whose `collector` is this instance is assigned to a `VGSTextField`.
    ///
    /// Usage:
    /// ```swift
    /// let allValid = collector.textFields.allSatisfy { $0.state.isValid }
    /// ```
    ///
    /// Notes:
    /// Treat as read-only snapshot; use unsubscribe APIs to remove fields cleanly.
    public var textFields: [VGSTextField] {
      return storage.textFields
    }
  
    // MARK: - Initialization
    
    init(id: String,
         environment: String,
         hostname: String? = nil,
         shouldTrackCollectInit: Bool) {
      self.tenantId = id
      self.regionalEnvironment = environment
      self.formAnalyticsDetails = VGSFormAnanlyticsDetails.init(formId: formId, tenantId: tenantId, environment: regionalEnvironment)
      self.proxyAPIClient = ProxyAPIClient(tenantId: id, regionalEnvironment: environment, hostname: hostname, formAnalyticsDetails: formAnalyticsDetails)
      self.cmpAPIClient = CMPAPIClient(environment: environment, formAnalyticsDetails: formAnalyticsDetails)
      guard shouldTrackCollectInit else { return }
        VGSAnalyticsClient.shared.trackFormEvent(
          self.formAnalyticsDetails,
          type: .collectInit,
          status: .success,
          extraData: Self.createCollectInitExtraData()
        )
    }

    /// Creates a collector bound to a specific vault environment string.
    ///
    /// Parameters:
    /// - id: Non-empty vault identifier.
    /// - environment: Environment string (e.g. "sandbox", "live", "live-eu1").
    /// - hostname: Optional custom hostname override (nil uses default vault routing).
    ///
    /// Preconditions:
    /// - `id` should be valid; empty values will lead to failing upstream requests.
    ///
    /// Behavior:
    /// - Initializes a collector for direct vault-based usage.
    /// - Tracks a `CollectInit` analytics event with `formType=create`.
    ///
    /// Usage:
    /// ```swift
    /// let collector = VGSCollect(id: vaultId, environment: "sandbox")
    /// ```
    /// Prefer the convenience initializer for typed environment + region when possible.
    public convenience init(id: String, environment: String, hostname: String? = nil) {
      self.init(id: id, environment: environment, hostname: hostname, shouldTrackCollectInit: true)
    }
  
    /// Convenience initializer composing a regional environment string.
    ///
    /// Parameters:
    /// - id: Vault identifier.
    /// - environment: Enumerated environment (`.sandbox` or `.live`).
    /// - dataRegion: Optional region segment (e.g. "eu1") appended to environment.
    /// - hostname: Optional custom hostname.
    ///
    /// Usage:
    /// ```swift
    /// let collector = VGSCollect(id: vaultId, environment: .live, dataRegion: "eu1")
    /// ```
    public convenience init(id: String, environment: Environment = .sandbox, dataRegion: String? = nil, hostname: String? = nil) {
      let env = Self.generateRegionalEnvironmentString(environment, region: dataRegion)
      self.init(id: id, environment: env, hostname: hostname)
    }
    
    // MARK: - Async Factory

    /// Asynchronously configures and initializes a VGSCollect instance.
    ///
    /// This method:
    /// 1. Validates the provided form name.
    /// 2. Loads the Form Configuration from the backend.
    /// 3. Applies remote configuration, or caller-provided inline configuration when the remote configuration is unavailable.
    /// 4. Returns an initialized `VGSCollect` instance.
    ///
    /// Behavior:
    /// - Valid remote configuration takes precedence over inline configuration.
    /// - A remote configuration failure is reported through `onError`; `completion` still receives a usable collector configured from the inline fallback when available.
    /// - Invalid form names remain terminal and are returned through `completion` as failures.
    ///
    /// Error Mapping:
    /// - Invalid form name format returns `VGSErrorType.invalidFormConfiguration` with key `VGSSDKErrorInvalidFormConfiguration`.
    /// - Configuration URL, network, empty body, decoding, and non-2xx failures are delivered to `onError` and do not prevent collector creation.
    ///
    /// - Parameters:
    ///   - form: The unique Form Name.
    ///   - vaultId: Vault identifier.
    ///   - environment: The environment (e.g., "sandbox", "live").
    ///   - dataRegion: Optional data region appended to the environment string.
    ///   - configuration: Optional inline Form Configuration `config` object used only when remote configuration cannot be loaded.
    ///   - onError: Optional callback for remote configuration loading errors.
    ///   - completion: A closure returning `VGSCollectSessionResponse`.
    ///
    /// Usage:
    /// ```swift
    /// VGSCollect.session(with: formId, vaultId: vaultId, environment: .sandbox, dataRegion: nil) { result in
    ///   switch result {
    ///   case .success(let collector):
    ///     self.collector = collector
    ///   case .failure(_, _, _, let error):
    ///     self.errorText = error?.localizedDescription
    ///   }
    /// }
    /// ```
    public static func session(with form: String,
                               vaultId: String,
                               environment: Environment = .sandbox,
                               dataRegion: String? = nil,
                               completion: @escaping (VGSCollectSessionResponse) -> Void) {
      session(
        with: form,
        vaultId: vaultId,
        environment: environment,
        dataRegion: dataRegion,
        configuration: nil,
        onError: nil,
        completion: completion
      )
    }

    /// Initializes a session collector with an optional inline fallback Form Configuration.
    ///
    /// Remote configuration takes precedence. If it cannot be loaded, `onError`
    /// receives the load error and the collector uses `configuration` when supplied.
    public static func session(with form: String,
                               vaultId: String,
                               environment: Environment = .sandbox,
                               dataRegion: String? = nil,
                               configuration: [String: Any]?,
                               onError: ((Error) -> Void)? = nil,
                               completion: @escaping (VGSCollectSessionResponse) -> Void) {

            // 1. Validate Form Format
            guard validateFormId(form) else {
              let message = "Invalid Form NAME Format."
              let event = VGSLogEvent(level: .warning, text: "Invalid Form Name format: \(form)", severityLevel: .error)
              VGSCollectLogger.shared.forwardLogEvent(event)

              let error = VGSError(type: .invalidFormConfiguration,
                                   userInfo: VGSErrorInfo(key: VGSSDKErrorInvalidFormConfiguration,
                                                          description: message,
                                                          extraInfo: [:]))
              completion(.failure(error.code, nil, nil, error))
              return
            }

            let regionalEnvironment = generateRegionalEnvironmentString(environment, region: dataRegion)
            let fallbackConfiguration = decodeInlineFormConfiguration(configuration)

            func makeCollector(config: VGSFormConfigurationData.Config?) -> VGSCollect {
              let collector = VGSCollect(
                id: vaultId,
                environment: regionalEnvironment,
                shouldTrackCollectInit: false
              )
              collector.sessionFormId = form
              collector.includedCardAttributes = resolveIncludedCardAttributes(from: config)
              return collector
            }

            // 2. Fetch Configuration
            loadConfiguration(for: form, vaultId: vaultId) { configResult in
                switch configResult {
                case .success(let configData):
                    let collector = makeCollector(config: configData.config.config)
                    VGSAnalyticsClient.shared.trackFormEvent(
                      collector.formAnalyticsDetails,
                      type: .collectInit,
                      status: .success,
                      extraData: sessionCollectInitExtraData(metrics: configData.metrics)
                    )
                    completion(.success(collector))

                case .failure(let error):
                    if let sessionConfigError = error as? VGSFormConfigurationLoadError {
                      onError?(sessionConfigError)
                      let collector = makeCollector(config: fallbackConfiguration?.config)
                      VGSAnalyticsClient.shared.trackFormEvent(
                        collector.formAnalyticsDetails,
                        type: .collectInit,
                        status: .success,
                        extraData: sessionCollectInitExtraData(metrics: sessionConfigError.metrics)
                      )
                      completion(.success(collector))
                      return
                    }
                    onError?(error)
                    let collector = makeCollector(config: fallbackConfiguration?.config)
                    completion(.success(collector))
                }
            }
        }


    // MARK: - Manage VGSTextFields
    
    /// Returns the first registered field matching a given `fieldName`.
    ///
    /// Parameter:
    /// - fieldName: The JSON key assigned in its `VGSConfiguration`.
    ///
    /// Returns:
    /// - `VGSTextField?` found or `nil` if no match.
    ///
    /// Usage:
    /// ```swift
    /// if let cardField = collector.getTextField(fieldName: "card_number"), cardField.state.isValid { /* ... */ }
    /// ```
    public func getTextField(fieldName: String) -> VGSTextField? {
        return storage.textFields.first(where: { $0.fieldName == fieldName })
    }
  
    /// Unregisters a single text field from this collector.
    ///
    /// Parameter:
    /// - textField: Field instance to detach.
    ///
    /// Effects:
    /// - Field is excluded from future submissions and observation callbacks.
    ///
    /// Usage:
    /// ```swift
    /// collector.unsubscribeTextField(nameField)
    /// ```
    public func unsubscribeTextField(_ textField: VGSTextField) {
      self.unregisterTextFields(textField: [textField])
    }
  
    /// Unregisters multiple text fields.
    ///
    /// Parameter:
    /// - textFields: Array of field instances to detach.
    ///
    /// Usage:
    /// ```swift
    /// collector.unsubscribeTextFields([cardField, expField])
    /// ```
    public func unsubscribeTextFields(_ textFields: [VGSTextField]) {
      self.unregisterTextFields(textField: textFields)
    }
  
    /// Unregisters all currently registered text fields.
    ///
    /// Purpose:
    /// Simplify form teardown (e.g. view controller disappearing) to prevent accidental resubmission.
    ///
    /// Usage:
    /// ```swift
    /// collector.unsubscribeAllTextFields()
    /// ```
    public func unsubscribeAllTextFields() {
      self.unregisterAllTextFields()
    }
  
    // MARK: - Manage Files
  
    /// Detaches all selected/attached files from this collector.
    ///
    /// Purpose:
    /// Free ephemeral memory and avoid unintended re-use of stale file data after successful upload or cancellation.
    ///
    /// Behavior:
    /// Safe to call multiple times; subsequent invocations are no-ops once files are cleared.
    ///
    /// Usage:
    /// ```swift
    /// collector.sendFile(path: "/post") { resp in
    ///   if case .success = resp { collector.cleanFiles() }
    /// }
    /// ```
    public func cleanFiles() {
      self.unregisterAllFiles()
    }
    
    
    // MARK: - Card Attributes Lookup Callbacks
        
    /// Callback invoked immediately before the SDK starts the asynchronous card attributes lookup.
    ///
    /// Triggered when the user types the 11th digit in a field with `configuration.type = .cardNumber`.
    /// Use this to update your UI state (e.g., disable submit button, show spinner).
    public var willBeginCardAttributesLookup: (() -> Void)?
    
    /// Callback invoked when attributes are successfully parsed from a successful lookup response.
    ///
    /// Use this convenience callback to populate UI with bank logos, card type labels, etc.
    /// For raw response bytes, use `cardAttributesLookupResponse`.
    /// - Parameter attributes: Parsed lookup payload object.
    public var didRetrieveCardAttributes: (([String: Any]) -> Void)?

    /// Callback invoked when the lookup request completes.
    ///
    /// Use this when you need the raw HTTP response data for both success and failure cases.
    /// - Parameter response: Raw lookup response result.
    public var cardAttributesLookupResponse: ((VGSCardAttributesLookupResponse) -> Void)?
    
    /// Callback invoked when the attributes lookup fails.
    ///
    /// Follows the same payload shape as `VGSResponse.failure(code, data, response, error)`.
    public var didFailToRetrieveCardAttributes: ((Int, Data?, URLResponse?, Error?) -> Void)?
    
    /// Callback to request a fresh JWT token for VGS API authentication.
    ///
    /// The SDK calls this when it needs to authenticate the lookup request.
    /// You must call the provided `completion` block with your token or an error.
    public var authHandler: ((_ completion: @escaping (Result<String, Error>) -> Void) -> Void)?
    
    // MARK: - Card Attributes Lookup State

    /// Internal state for card attributes lookup orchestration.
    /// Stored directly on the collector (no Objective-C associated objects).
    internal struct CardAttributesLookupContext {
      /// Last 11-digit prefix we decided should be looked up for the current input session.
      var requestedDigits11: String?
      /// Currently in-flight request 11-digit prefix.
      var inFlightDigits11: String?
      /// Lookup start time used for analytics latency tracking.
      var startedAt: Date?
    }

    internal var cardAttributesLookupContext = CardAttributesLookupContext(requestedDigits11: nil, inFlightDigits11: nil, startedAt: nil)
}
