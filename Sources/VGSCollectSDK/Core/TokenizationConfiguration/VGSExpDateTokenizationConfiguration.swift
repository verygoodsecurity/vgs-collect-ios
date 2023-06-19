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
public final class VGSExpDateTokenizationConfiguration: VGSConfiguration, VGSExpDateConfigurationProtocol, VGSTextFieldTokenizationConfigurationProtocol, VGSFormatSerializableProtocol {
  
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
  public var tokenizationParameters = VGSExpDateTokenizationParameters()

  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationParameters
  }

  // MARK: - VGSFormatSerializableProtocol
  /// Output date format.
  public var serializers: [VGSFormatSerializerProtocol] = []

  // MARK: - `VGSExpDateConfiguration` implementation
  /// Serialize Expiration Date
  internal func serialize(_ content: String) -> [String: Any] {
    return ExpDateFormatConvertor.serialize(content, serializers: serializers, outputFormat: outputDateFormat)
  }

  /// Returns if Content should be Serialized
  internal var shouldSerialize: Bool {
    return !serializers.isEmpty
  }
}

/// Implement `TextFormatConvertable` protocol.
extension VGSExpDateTokenizationConfiguration: VGSTextFormatConvertable {
    
    var inputFormat: InputConvertableFormat? {
        return inputDateFormat
    }
    
    var outputFormat: OutputConvertableFormat? {
        return outputDateFormat
    }

    internal var convertor: TextFormatConvertor {
        return ExpDateFormatConvertor()
    }
}
