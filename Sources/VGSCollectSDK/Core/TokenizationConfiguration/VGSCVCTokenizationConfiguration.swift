//
//  VGSCVCTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCVCTokenizationParameters` - parameters required for tokenization api.
public struct VGSCVCTokenizationParameters: VGSTokenizationParametersProtocol {
    
    /// An Array of data classifiers.
    public var classifiers: [String] = []
  
    /// Valut storage type.
    public let storage: String = VGSVaultStorageType.VALOTILE.rawValue
  
    /// Data alies format.
    public let format: String = VGSVaultAliasFormat.NUM_LENGTH_PRESERVING.rawValue
  
    /// Defines if data should be tokenized.
    public let shouldTokenize: Bool = true
  
}

/// `VGSCVCTokenizationConfiguration` - textfield configuration for textfield with type `.cvc`, required for work with tokenization api.
public class VGSCVCTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {

  /// `VGSCVCTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSCVCTokenizationParameters()
  
  override public var type: FieldType {
    get { return .cvc }
    set {}
  }
    
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationPatameters
  }
}
