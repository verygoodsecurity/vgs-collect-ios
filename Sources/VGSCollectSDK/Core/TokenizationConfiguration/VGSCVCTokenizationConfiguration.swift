//
//  VGSCVCTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCVCTokenizationParameters` - parameters required for tokenization api.
///
/// Summary:
/// Defines how CVC input is tokenized when using Vault tokenization APIs.
///
/// Properties:
/// - `storage`: Vault storage type. Defaults to volatile (`VOLATILE`) to avoid persisting raw token beyond session scope.
/// - `format`: Alias format applied to the tokenized value. Default is `NUM_LENGTH_PRESERVING` (keeps length characteristics without exposing original digits).
///
/// Usage:
/// ```swift
/// var params = VGSCVCTokenizationParameters()
/// params.format = VGSVaultAliasFormat.NUM_LENGTH_PRESERVING.rawValue // or other supported format
/// let cfg = VGSCVCTokenizationConfiguration(collector: collector, fieldName: "card_cvc")
/// cfg.tokenizationParameters = params
/// cvcField.configuration = cfg
/// ```
///
/// Notes:
/// - Choose volatile storage for high-sensitivity short-lived values like CVC.
/// - Format changes affect alias representation only, not validation rules.
public struct VGSCVCTokenizationParameters: VGSTokenizationParametersProtocol {
   
    /// Vault storage type.
    public let storage: String = VGSVaultStorageType.VOLATILE.rawValue
  
    /// Data alias format.
    public var format: String = VGSVaultAliasFormat.NUM_LENGTH_PRESERVING.rawValue
}

/// `VGSCVCTokenizationConfiguration` - textfield configuration for textfield with type `.cvc`, required for work with tokenization api.
///
/// Summary:
/// Specialized configuration subclass for CVC fields enabling tokenization when submitting via Vault API methods (e.g. `tokenizeData`, `createAliases`).
///
/// Behavior:
/// - Forces `type` to `.cvc` (override ignores external setter attempts).
/// - Supplies `tokenizationParameters` used to build tokenization request body.
/// - Inherits formatting & validation from `VGSConfiguration`; defaults still apply unless overridden.
///
/// Usage:
/// ```swift
/// let cvcCfg = VGSCVCTokenizationConfiguration(collector: collector, fieldName: "card_cvc")
/// // Optional: adjust alias format
/// cvcCfg.tokenizationParameters.format = VGSVaultAliasFormat.FPE_SIX_T_FOUR.rawValue
/// cvcField.configuration = cvcCfg
/// ```
///
/// Customization Notes:
/// - Modify `tokenizationParameters.format` before assigning configuration to the field.
/// - Validation rules can still be overridden via `validationRules` if needed.
/// - Storage should remain volatile for CVC (do not switch to persistent unless explicit compliance requirements dictate).
///
/// Security:
/// - Tokenization reduces exposure of raw CVC; never log raw input even with tokenization enabled.
public class VGSCVCTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {

  /// `VGSCVCTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationParameters = VGSCVCTokenizationParameters()
  
  /// `FieldType.cvc` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .cvc }
    set {}
  }
    
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationParameters
  }
}
