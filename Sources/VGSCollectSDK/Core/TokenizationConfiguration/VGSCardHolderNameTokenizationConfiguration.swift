//
//  VGSCardHolderNameTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCardHolderNameTokenizationParameters` - parameters required for tokenization api.
public struct VGSCardHolderNameTokenizationParameters: VGSTokenizationParametersProtocol {
    
    /// An Array of data classifiers.
    public var classifiers: [String] = []

    /// Valut storage type.
    public let storage: String = VGSVaultStorageType.PERSISTANT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
  
    /// Defines if data should be tokenized.
    public var shouldTokenize: Bool = true
}

/// `VGSCardHolderNameTokenizationConfiguration` - textfield configuration for textfield with type `.cardHolderName`, required for work with tokenization api.
public class VGSCardHolderNameTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSCardHolderNameTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSCardHolderNameTokenizationParameters()

  override public var type: FieldType {
    get { return .cardHolderName }
    set {}
  }
  
  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationPatameters
  }
}
