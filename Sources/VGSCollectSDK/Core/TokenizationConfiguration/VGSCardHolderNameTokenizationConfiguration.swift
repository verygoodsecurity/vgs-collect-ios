//
//  VGSCardHolderNameTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCardHolderNameTokenizationParameters` - parameters required for tokenization api.
public struct VGSCardHolderNameTokenizationParameters: VGSTokenizationParametersProtocol {
    /// Vault storage type.
    /// Defines how long the alias persists. Use `PERSISTENT` for values you must reference later.
    public var storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alias format.
    /// Specifies transformation applied to original input. For cardholder name a UUID format provides a non-reversible token.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// `VGSCardHolderNameTokenizationConfiguration` - textfield configuration for textfield with type `.cardHolderName`, required for work with tokenization api.
///
/// Usage:
/// 1. Initialize with your `VGSCollect` instance and a `fieldName` (JSON key for outbound payload).
/// 2. Assign to a `VGSTextField` before user begins editing.
/// 3. Call `tokenizeData(routeId:)` or `createAliases(routeId:)` on the collector; the response JSON will include generated alias(es).
///
/// Notes:
/// - Customize `tokenizationParameters.format` if you need different alias semantics.
/// - Never include real PII inside `fieldName`; it is only a logical key.
public class VGSCardHolderNameTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
// swiftlint:disable:previous type_name

  /// `VGSCardHolderNameTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationParameters = VGSCardHolderNameTokenizationParameters()

  /// `FieldType.cardHolderName` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .cardHolderName }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationParameters
  }
}
