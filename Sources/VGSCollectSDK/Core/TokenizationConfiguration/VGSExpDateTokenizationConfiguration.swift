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
    var result = [String: Any]()
    for serializer in serializers {
      if let serializer = serializer as? VGSExpDateSeparateSerializer {
        /// remove dividers
        var dateDigitsString = content.digits

        /// get output date format, if not set - use default
        let outputDateFormat = outputFormat ?? .shortYear
        /// check output date components length
        let outputMonthDigits = outputDateFormat.monthCharacters
        let outputYearDigits = outputDateFormat.yearCharacters

        let mth: String
        let year: String
        if outputDateFormat.isYearFirst {
          /// take month digitis
          year = String(dateDigitsString.prefix(outputYearDigits))
          /// remove month digits
          dateDigitsString = String(dateDigitsString.dropFirst(outputYearDigits))
          /// take year digitis
          mth = String(dateDigitsString.prefix(outputMonthDigits))
        } else {
          /// take month digitis
          mth = String(dateDigitsString.prefix(outputMonthDigits))
          /// remove month digits
          dateDigitsString = String(dateDigitsString.dropFirst(outputMonthDigits))
          /// take year digitis
          year = String(dateDigitsString.prefix(outputYearDigits))
        }

        /// set result for specific fieldnames
        result[serializer.monthFieldName] = mth
        result[serializer.yearFieldName] = year
      }
    }
    return result
  }

  /// Returns if Content should be Serialized
  internal var shouldSerialize: Bool {
    return !serializers.isEmpty
  }
}

/// Implement `FormatConvertable` protocol.
extension VGSExpDateTokenizationConfiguration: FormatConvertable {

  internal var outputFormat: VGSCardExpDateFormat? {
    return outputDateFormat
  }

  internal var inputFormat: VGSCardExpDateFormat? {
    return inputDateFormat
  }

  internal var convertor: TextFormatConvertor {
    return ExpDateFormatConvertor()
  }
}
