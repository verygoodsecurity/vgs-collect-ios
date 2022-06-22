//
//  VGSExpDateTokenizationConfiguration.swift
//

import Foundation

/// `VGSExpDateTokenizationParameters` - parameters required for tokenization api.
public struct VGSExpDateTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public let storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// `VGSExpDateTokenizationConfiguration` - textfield configuration for textfield with type `.expDate`, required for work with tokenization api.
public class VGSExpDateTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSExpDateTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSExpDateTokenizationParameters()

  /// `FieldType.expDate` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .expDate }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationPatameters
  }
}
