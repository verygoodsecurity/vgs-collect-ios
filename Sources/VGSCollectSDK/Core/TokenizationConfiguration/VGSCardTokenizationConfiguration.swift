//
//  VGSCardTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCardNumberTokenizationParameters` - parameters required for tokenization API.
///
/// Summary:
/// Defines how primary account number (PAN) input (FieldType `.cardNumber`) is transformed into an alias for Vault tokenization / alias creation APIs.
///
/// Properties:
/// - `storage`: Vault storage type. Uses `.PERSISTENT` by default to enable downstream reuse in PCI compliant flows (e.g. recurring billing).
/// - `format`: Alias format. Default `FPE_SIX_T_FOUR` preserves first six (BIN) + last four digits while protecting the middle digits.
///
/// Usage:
/// ```swift
/// var cardParams = VGSCardNumberTokenizationParameters()
/// cardParams.format = VGSVaultAliasFormat.FPE_SIX_T_FOUR.rawValue // or a fully opaque format e.g. UUID
/// let cardCfg = VGSCardNumberTokenizationConfiguration(collector: collector, fieldName: "card_number")
/// cardCfg.tokenizationParameters = cardParams
/// cardField.configuration = cardCfg
/// ```
///
/// Notes:
/// - Choose a fully opaque format (e.g. `UUID`) when BIN + last4 are not required in client logic.
/// - Format affects alias output only; validation (length, Luhn) controlled via rules / field type.
public struct VGSCardNumberTokenizationParameters: VGSTokenizationParametersProtocol {
    /// Vault storage type.
    /// Card numbers typically require future re-use (e.g. replay with PCI compliant workflows) so `.PERSISTENT` is used.
    public let storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alias format.
    /// Uses a length-preserving format with first six and last four digits exposed (`FPE_SIX_T_FOUR`) to support BIN + last4 business logic while keeping middle digits protected.
    public var format: String = VGSVaultAliasFormat.FPE_SIX_T_FOUR.rawValue
}

/// `VGSCardNumberTokenizationConfiguration` - configuration for a text field collecting card numbers (`.cardNumber`). Required for tokenization API usage.
///
/// Summary:
/// Specialized configuration enabling PAN tokenization while retaining dynamic brand-driven formatting and validation inherited from `VGSConfiguration`.
///
/// Behavior:
/// - Forces `type` to `.cardNumber`.
/// - Supplies `tokenizationParameters` consumed by tokenization / alias APIs.
///
/// Usage:
/// ```swift
/// let cardCfg = VGSCardNumberTokenizationConfiguration(collector: collector, fieldName: "card_number")
/// cardCfg.tokenizationParameters.format = VGSVaultAliasFormat.FPE_SIX_T_FOUR.rawValue
/// cardField.configuration = cardCfg
/// // Later submit
/// collector.createAliases { response in /* handle */ }
/// ```
///
/// Customization Notes:
/// - Override `tokenizationParameters.format` before attaching to the field to avoid mid-edit alias policy changes.
/// - For fully opaque tokens choose `VGSVaultAliasFormat.UUID.rawValue`.
/// - Validation rules can be replaced with a custom `VGSValidationRuleSet` if business logic restricts brands or lengths.
///
/// Security:
/// - Never log raw PAN; rely on card state (`last4`, brand) for limited display needs.
public class VGSCardNumberTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSCardNumberTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationParameters = VGSCardNumberTokenizationParameters()

  /// `FieldType.cardNumber` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .cardNumber }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol = VGSCardNumberTokenizationParameters()
}
