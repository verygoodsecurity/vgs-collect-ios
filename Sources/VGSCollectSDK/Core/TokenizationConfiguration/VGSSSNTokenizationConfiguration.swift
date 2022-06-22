//
//  VGSSSNTokenizationConfiguration.swift
//  VGSCollectSDK
//


import Foundation

/// `VGSSSNTokenizationParameters` - parameters required for tokenization api.
public struct VGSSSNTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public let storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue

}

/// `VGSSSNTokenizationConfiguration` - textfield configuration for textfield with type `.ssn`, required for work with tokenization api.
public class VGSSSNTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSSSNTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSSSNTokenizationParameters()

  /// `FieldType.ssn` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .ssn }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationPatameters
  }
}
