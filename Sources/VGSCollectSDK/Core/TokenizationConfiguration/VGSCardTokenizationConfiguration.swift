//
//  VGSCardTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCardTokenizationParameters` - parameters required for tokenization api.
public struct VGSCardNumberTokenizationParameters: VGSTokenizationParametersProtocol {
    /// Vault storage type.
    public let storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.FPE_SIX_T_FOUR.rawValue
}

/// `VGSCardTokenizationConfiguration` - textfield configuration for textfield with type `.cardNumber`, required for work with tokenization api.
public class VGSCardNumberTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSCardTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationParameters = VGSCardNumberTokenizationParameters()

  /// `FieldType.cardNumber` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .cardNumber }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol = VGSCardNumberTokenizationParameters()
}
