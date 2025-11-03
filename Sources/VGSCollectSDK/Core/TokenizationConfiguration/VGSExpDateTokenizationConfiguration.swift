//
//  VGSExpDateTokenizationConfiguration.swift
//

import Foundation

/// `VGSExpDateTokenizationParameters` - parameters required for tokenization api.
///
/// Summary:
/// Defines how card expiration date input (FieldType `.expDate`) is tokenized when using Vault tokenization or alias creation APIs.
///
/// Properties:
/// - `storage`: Vault storage type. Persistent by default to allow alias reuse server-side.
/// - `format`: Alias format applied to the expiration value. Default `.UUID` creates opaque aliases.
///
/// Usage:
/// ```swift
/// var params = VGSExpDateTokenizationParameters()
/// params.format = VGSVaultAliasFormat.UUID.rawValue // or FPE / numeric-preserving format
/// let expCfg = VGSExpDateTokenizationConfiguration(collector: collector, fieldName: "card_exp")
/// expCfg.tokenizationParameters = params
/// expField.configuration = expCfg
/// ```
///
/// Notes:
/// - Format affects alias representation only, not validation or formatting in the UI.
/// - Keep raw MM/YY or MM/YYYY formatting logic in `formatPattern` and date validation via rules (`VGSValidationRuleCardExpirationDate`).
public struct VGSExpDateTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public let storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alias format.
    /// Defines transformation applied to raw expiration date when creating an alias. Default: `.UUID`.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// `VGSExpDateTokenizationConfiguration` - textfield configuration for textfield with type `.expDate`, required for work with tokenization api.
/// Assign to `VGSExpDateTextField` (or generic `VGSTextField`) before user input to enable expiration date tokenization.
///
/// Summary:
/// Specialized configuration enabling tokenization, optional date picker input source, and raw-to-formatted expiration date conversion (short/long year) prior to submission.
///
/// Behavior:
/// - Forces `type` to `.expDate`.
/// - Provides `tokenizationParameters` consumed by tokenization / alias APIs.
/// - Supports picker-based entry via `inputSource = .datePicker` and format conversion using `inputDateFormat` / `outputDateFormat`.
/// - Allows serialization into structured components through `serializers` before alias creation.
///
/// Usage:
/// ```swift
/// let expCfg = VGSExpDateTokenizationConfiguration(collector: collector, fieldName: "card_exp")
/// expCfg.inputSource = .datePicker
/// expCfg.inputDateFormat = .shortYear
/// expCfg.outputDateFormat = .longYear
/// expCfg.tokenizationParameters.format = VGSVaultAliasFormat.UUID.rawValue
/// expCfg.serializers = [ExpDateFormatSerializer.month("exp_month"), ExpDateFormatSerializer.year("exp_year")] // example serializers
/// expField.configuration = expCfg
/// ```
///
/// Customization Notes:
/// - Set format conversion & serializers before assigning configuration to field for consistent initial UI.
/// - Use serializers only when you need extra separated alias fields (month/year) beyond the single expiration alias.
/// - Validation rules can be overridden with a custom `VGSValidationRuleSet` if business constraints differ (e.g. extended future range).
///
/// Security:
/// - Treat expiration dates as sensitive.
public final class VGSExpDateTokenizationConfiguration: VGSConfiguration, VGSExpDateConfigurationProtocol, @preconcurrency VGSTextFieldTokenizationConfigurationProtocol, VGSFormatSerializableProtocol {
  
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
extension VGSExpDateTokenizationConfiguration: @preconcurrency VGSTextFormatConvertable {
    
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
