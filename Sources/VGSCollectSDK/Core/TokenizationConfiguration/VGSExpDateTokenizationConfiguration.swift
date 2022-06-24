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
public final class VGSExpDateTokenizationConfiguration: VGSConfiguration, VGSExpDateConfigurationProtocol, VGSTextFieldTokenizationConfigurationProtocol {
  
  // MARK: - Attributes
  /// `FieldType.expDate` type of `VGSTextField`tokenization  configuration.
  override public var type: FieldType {
    get { return .expDate }
    set {}
  }
  
  // MARK: - VGSExpDateConfigurationProtocol
  /// Input Source type. Default is `VGSTextFieldInputSource.datePicker`.
  public var inputSource: VGSTextFieldInputSource = .datePicker
  
  /// Input date format to convert.
  public var inputDateFormat: VGSCardExpDateFormat?
  
  /// Output date format.
  public var outputDateFormat: VGSCardExpDateFormat?
  
  // MARK: - VGSTokenizationParametersProtocol
  /// `VGSExpDateTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSExpDateTokenizationParameters()

  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationPatameters
  }
}
