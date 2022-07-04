//
//  VGSCardHolderNameTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCardHolderNameTokenizationParameters` - parameters required for tokenization api.
public struct VGSCardHolderNameTokenizationParameters: VGSTokenizationParametersProtocol {
    /// Vault storage type.
    public var storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// `VGSCardHolderNameTokenizationConfiguration` - textfield configuration for textfield with type `.cardHolderName`, required for work with tokenization api.
public class VGSCardHolderNameTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
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
