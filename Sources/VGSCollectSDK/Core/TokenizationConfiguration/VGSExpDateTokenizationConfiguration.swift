//
//  VGSExpDateTokenizationConfiguration.swift
//

import Foundation

/// `VGSExpDateTokenizationParameters` - parameters required for tokenization api.
public struct VGSExpDateTokenizationParameters: VGSTokenizationParametersProtocol {
    
    /// An Array of data classifiers.
    public var classifiers: [String] = []

    /// Valut storage type.
    public let storage: String = VGSVaultStorageType.PERSISTANT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
  
    /// Defines if data should be tokenized.
    public var shouldTokenize: Bool = true
}

/// `VGSExpDateTokenizationConfiguration` - textfield configuration for textfield with type `.expDate`, required for work with tokenization api.
public class VGSExpDateTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSExpDateTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSExpDateTokenizationParameters()

  override public var type: FieldType {
    get { return .expDate }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationPatameters
  }
}
