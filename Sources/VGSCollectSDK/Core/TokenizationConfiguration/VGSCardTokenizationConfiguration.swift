//
//  VGSCardTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCardTokenizationParameters` - parameters required for tokenization api.
public struct VGSCardTokenizationParameters: VGSTokenizationParametersProtocol {
    /// Valut storage type.
    public let storage: String = VGSVaultStorageType.PERSISTANT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.FPE_SIX_T_FOUR.rawValue
}

/// `VGSCardTokenizationConfiguration` - textfield configuration for textfield with type `.cardNumber`, required for work with tokenization api.
public class VGSCardTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  // `VGSCardTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSCardTokenizationParameters()

  override public var type: FieldType {
    get { return .cardNumber }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol = VGSCardTokenizationParameters()
}
