//
//  VGSSSNTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSSSNTokenizationParameters` - parameters required for tokenization api.
///
/// Summary:
/// Defines how US Social Security Number input (FieldType `.ssn`) is transformed into an alias when using Vault tokenization or alias creation APIs.
///
/// Properties:
/// - `storage`: Vault storage type (persistent by default for reuse on backend workflows).
/// - `format`: Alias format representation (default `.UUID` ensures fully opaque alias value).
///
/// Usage:
/// ```swift
/// var ssnParams = VGSSSNTokenizationParameters()
/// ssnParams.format = VGSVaultAliasFormat.UUID.rawValue // or another supported alias format
/// let ssnCfg = VGSSSNTokenizationConfiguration(collector: collector, fieldName: "user_ssn")
/// ssnCfg.tokenizationParameters = ssnParams
/// ssnField.configuration = ssnCfg
/// ```
///
/// Notes:
/// - Changing `format` impacts only alias output, not validation or masking.
/// - Keep SSN input formatting & validation in `formatPattern` and rule set (`VGSValidationRulePattern`).
public struct VGSSSNTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public let storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue

}

/// `VGSSSNTokenizationConfiguration` - textfield configuration for textfield with type `.ssn`, required for work with tokenization api.
///
/// Summary:
/// Specialized configuration enabling tokenization for SSN fields, ensuring alias creation while preserving standard SSN input formatting and validation.
///
/// Behavior:
/// - Forces `type` to `.ssn` regardless of external attempts to modify.
/// - Supplies `tokenizationParameters` consumed by tokenization / alias APIs.
/// - Inherits base formatting & validation from `VGSConfiguration`; you may override `validationRules` for custom compliance constraints.
///
/// Usage:
/// ```swift
/// let ssnCfg = VGSSSNTokenizationConfiguration(collector: collector, fieldName: "user_ssn")
/// ssnCfg.tokenizationParameters.format = VGSVaultAliasFormat.UUID.rawValue
/// ssnField.configuration = ssnCfg
/// ```
///
/// Customization Notes:
/// - Adjust alias format prior to assigning configuration to avoid mid-edit format shifts.
/// - Do not relax SSN regex to avoid collecting malformed identifiers.
///
/// Security:
/// - Treat SSN as highly sensitive.
@MainActor
public class VGSSSNTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSSSNTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationParameters = VGSSSNTokenizationParameters()

  /// `FieldType.ssn` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .ssn }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationParameters
  }
}
