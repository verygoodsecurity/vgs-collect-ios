//
//  VGSCVCTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCVCTokenizationParameters` - parameters required for tokenization api.
public struct VGSCVCTokenizationParameters: VGSTokenizationParametersProtocol {
   
    /// Vault storage type.
    public let storage: String = VGSVaultStorageType.VOLATILE.rawValue
  
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.NUM_LENGTH_PRESERVING.rawValue
}

/// `VGSCVCTokenizationConfiguration` - textfield configuration for textfield with type `.cvc`, required for work with tokenization api.
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
