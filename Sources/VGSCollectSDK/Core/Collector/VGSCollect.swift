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
@MainActor public class VGSCollect {
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
    /// Usage:
    /// ```swift
    /// let collector = VGSCollect(id: vaultId, environment: "sandbox")
    /// ```
    /// Prefer the convenience initializer for typed environment + region.
    public init(id: String, environment: String, hostname: String? = nil) {
      self.tenantId = id
      self.regionalEnvironment = environment
      self.formAnalyticsDetails = VGSFormAnanlyticsDetails.init(formId: formId, tenantId: tenantId, environment: regionalEnvironment)
      self.proxyAPIClient = ProxyAPIClient(tenantId: id, regionalEnvironment: environment, hostname: hostname, formAnalyticsDetails: formAnalyticsDetails)
      self.cmpAPIClient = CMPAPIClient(environment: environment, formAnalyticsDetails: formAnalyticsDetails)
        VGSAnalyticsClient.shared.trackFormEvent(
          self.formAnalyticsDetails,
          type: .create,
          status: .success
        )
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
}
