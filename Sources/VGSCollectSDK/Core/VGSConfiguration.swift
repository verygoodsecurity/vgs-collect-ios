//
//  VGSModel.swift
//  VGSCollectSDK
//

import Foundation
#if os(iOS)
import UIKit
#endif

internal protocol VGSBaseConfigurationProtocol {
    
    var vgsCollector: VGSCollect? { get }
    
    var fieldName: String { get }
}

internal protocol VGSTextFieldConfigurationProtocol: VGSBaseConfigurationProtocol {
    
    var validationRules: VGSValidationRuleSet? { get }
  
    var isRequired: Bool { get }
    
    var isRequiredValidOnly: Bool { get }
    
    var type: FieldType { get }
    
    var formatPattern: String? { get set }
    
    var keyboardType: UIKeyboardType? { get set }
    
    var returnKeyType: UIReturnKeyType? { get set }
    
    var keyboardAppearance: UIKeyboardAppearance? { get set }
    
    var textContentType: UITextContentType? { get set }
}

/// A configuration object that defines semantic meaning, formatting and validation rules for an attached `VGSTextField`.
///
/// Summary:
/// Configure how a secure text field should behave (data type, keyboard, formatting, validation, and submission key) when collecting sensitive data for VGS vault submission.
///
/// Responsibilities:
/// - Declares the vault JSON key (`fieldName`) used during submission.
/// - Specifies field semantic `type` (e.g. card number, CVC) that drives built–in formatting & validation defaults.
/// - Holds optional custom validation rules and formatting pattern overrides.
/// - Provides UI hints (keyboard type, return key, content type, appearance) without directly altering UI until bound.
///
/// Security:
/// - `fieldName` is a logical alias only; never place raw secrets or PII in the name itself.
/// - Formatting (masking/spacing) is purely cosmetic and does NOT sanitize or truncate the raw secure value transmitted to the vault.
///
/// Usage:
/// 1. Instantiate with a `VGSCollect` instance and unique `fieldName`.
/// 2. Adjust optional properties (e.g. `isRequired`, `validationRules`, `formatPattern`).
/// 3. Assign the configuration to a `VGSTextField` before user input begins.
///
/// Invariants / Preconditions:
/// - `fieldName` should be non-empty and unique per collector to avoid ambiguous payload keys. (Not currently enforced at runtime.)
/// - Changing properties after the field has begun editing may not retroactively re-validate already entered content.
public class VGSConfiguration: VGSTextFieldConfigurationProtocol {
    
    // MARK: - Attributes
    
    /// Collect form (owner) associated with this configuration.
    ///
    /// Side Effects: None on assignment (set only in initializer).
    /// Lifetime: Weak to avoid retain cycles with `VGSTextField` & collector.
    public private(set) weak var vgsCollector: VGSCollect?
  
    /// Semantic field type driving built-in behavior (formatting, validation defaults, keyboard suggestions).
    ///
    /// Default: `.none` (generic text input). Update before binding to a text field for consistent behavior.
    public var type: FieldType = .none
    
    /// Vault JSON key that the collected value will map to upon submission.
    ///
    /// Invariants: Should be stable, URL-safe, and unique within a single collector; collisions cause overwriting in the outgoing body.
    /// Security: Never embed real secrets; treat as a metadata label only.
    public let fieldName: String
    
    /// Indicates that the field must contain a non-empty value for form submission to be considered valid.
    ///
    /// Validation: Checked during collector validation. Empty required fields produce an error list.
    public var isRequired: Bool = false
    
    /// Indicates that if the user provides any value, it must pass validation rules.
    ///
    /// Use Case: Optional fields like second address line or promo code that should not contain invalid data when filled.
    public var isRequiredValidOnly: Bool = false
    
    /// Optional visual formatting pattern (e.g. "#### #### #### ####" for card numbers).
    ///
    /// Behavior: Applied purely at UI layer for readability. Raw value is still captured unformatted.
    public var formatPattern: String? {
            didSet {
                logWarningForFormatPatternIfNeeded()
            }
        }
    
    /// Replacement divider string used when serializing formatted input back to a raw value.
    /// Example: A phone pattern with spaces might be collapsed or replaced with `divider` value during serialization.
    public var divider: String?
    
    /// Preferred `UITextContentType` override used to enhance autofill & keyboard heuristics.
    ///
    /// Auto-Assignment: If not explicitly set, the owning text field may assign a sensible default based on `type`.
    /// Tracking: `isTextContentTypeSet` indicates whether a custom value has been provided.
    public var textContentType: UITextContentType? {
        didSet { isTextContentTypeSet = true }
    }
    internal var isTextContentTypeSet = false

    /// Keyboard layout preference; if nil, a type-specific default (e.g. numeric) might be applied by the UI component.
    public var keyboardType: UIKeyboardType?
    
    /// Return key style suggestion; does not enforce submission logic itself.
    public var returnKeyType: UIReturnKeyType?
    
    /// Keyboard appearance preference (e.g. dark). Default is system/host app standard when nil.
    public var keyboardAppearance: UIKeyboardAppearance?
  
    /// A composite of validation rules executed against the raw (unformatted) value to update field validity state.
    ///
    /// Security: Pure evaluation; does not log or persist sensitive values.
    public var validationRules: VGSValidationRuleSet?

    /// Maximum allowed raw input length (excluding formatting separators).
    ///
    /// Enforcement: Additional user input is rejected or ignored beyond this limit.
    public var maxInputLength: Int? {
            didSet {
                logWarningForFormatPatternIfNeeded()
            }
        }

    /// Emits a warning log if both `formatPattern` and `maxInputLength` are set, signalling potential conflicting constraints.
    ///
    /// Side Effects: Sends a `.warning` level `VGSLogEvent`. No behavioral modifications occur.
    internal func logWarningForFormatPatternIfNeeded() {
            if !formatPattern.isNilOrEmpty && maxInputLength != nil {
                let message = "Format pattern (\(formatPattern ?? "")) and maxInputLength (\(maxInputLength ?? 0)) can conflict when both are in use!"
                let event = VGSLogEvent(level: .warning, text: message, severityLevel: .warning)
                VGSCollectLogger.shared.forwardLogEvent(event)
            }
        }
           
    // MARK: - Initialization
    
    /// Designated initializer.
    ///
    /// Parameters:
    /// - vgs: Owning `VGSCollect` instance that will manage submission.
    /// - fieldName: Vault JSON key for the eventual secure submission payload.
    ///
    /// Preconditions: `fieldName` should be non-empty (not enforced).
    public init(collector vgs: VGSCollect, fieldName: String) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
    }
}
