//
//  VGSDateTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSDateTokenizationParameters` - parameters required for tokenization API
///
/// Summary:
/// Defines how generic date input (FieldType `.date`) is tokenized when using Vault tokenization or alias creation APIs.
///
/// Properties:
/// - `storage`: Vault storage type used for the alias. Defaults to persistent storage — change only if compliance requires ephemeral handling.
/// - `format`: Alias format applied to the date value (default `.UUID`). Does not alter user-visible formatting.
///
/// Usage:
/// ```swift
/// var params = VGSDateTokenizationParameters()
/// params.format = VGSVaultAliasFormat.UUID.rawValue // or other supported alias format
/// let dateCfg = VGSDateTokenizationConfiguration(collector: collector, fieldName: "start_date")
/// dateCfg.tokenizationParameters = params
/// dateField.configuration = dateCfg
/// ```
///
/// Notes:
/// - Changing `format` influences only alias representation, not validation or display.
/// - Keep date parsing/format validation separate via `validationRules` and `formatPattern`.
public struct VGSDateTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public var storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alias format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// `VGSDateTokenizationConfiguration` - configuration object for a date field tokenization.
///
/// Summary:
/// Specialized configuration for `.date` fields enabling Vault tokenization, optional date-picker input, and optional format serialization before submission.
///
/// Behavior:
/// - Forces `type` to `.date`.
/// - Provides `tokenizationParameters` consumed by tokenization/alias APIs.
/// - Supports optional date picker via `inputSource = .datePicker` and year range customization (`datePickerStartDate` / `datePickerEndDate`).
/// - Allows input/output date format conversion & serialization through `serializers` collection.
///
/// Usage:
/// ```swift
/// let dateCfg = VGSDateTokenizationConfiguration(collector: collector, fieldName: "event_date")
/// dateCfg.inputSource = .datePicker
/// dateCfg.inputDateFormat = .mmddyyyy
/// dateCfg.outputDateFormat = .yyyymmdd
/// dateCfg.tokenizationParameters.format = VGSVaultAliasFormat.UUID.rawValue
/// dateField.configuration = dateCfg
/// ```
///
/// Customization Notes:
/// - Set format conversion properties before assigning configuration to the field.
/// - Provide serializers when you need extra structured output (e.g. separate year/month fields) prior to tokenization.
/// - Adjust start/end picker dates via initializer optional parameters.
///
/// Security:
/// - Tokenization replaces raw date with an alias; never log raw date content if considered sensitive (e.g. birth dates).
/// - Do not persist raw input.
@MainActor public final class VGSDateTokenizationConfiguration: VGSConfiguration, VGSDateConfigurationProtocol, @preconcurrency VGSTextFieldTokenizationConfigurationProtocol, VGSFormatSerializableProtocol {
    
    // MARK: - Properties
    /// Start date used to fill out the date picker
    private var datePickerStartDate: VGSDate = VGSDateConfiguration.minValidPickerStartDate
    
    /// End date used to fill out the date picker
    private var datePickerEndDate: VGSDate = VGSDateConfiguration.maxValidPickerEndDate
    
    /// Get the list of years from `datePickerStartDate` to `datePickerEndDate`.
    /// In case any of the dates are not set, it will use the default
    /// values `minValidStartDate` and `maxValidEndDate` respectively
    internal var years: [Int] {
        Array(datePickerStartDate.year...datePickerEndDate.year)
    }
    
    // MARK: - Constructor
    /// Initialization
    /// Date configuration initializer, if no `datePickerStartDate` is provided,
    /// a default date will be used adding 100 years to the current date.
    /// Similar approach will be used if `datePickerEndDate` is not provided,
    /// it will be calculated removing 100 years from current date.
    ///
    /// - Parameters:
    ///   - vgs: `VGSCollect` instance.
    ///   - fieldName: associated `fieldName`.
    ///   - datePickerStartDate: optional `VGSDate` instance.
    ///   - datePickerEndDate: optional `VGSDate` instance.
    public init(collector vgs: VGSCollect,
                fieldName: String,
                datePickerStartDate: VGSDate? = nil,
                datePickerEndDate: VGSDate? = nil) {
        /// Setup custom picker start date
        if let startDate = datePickerStartDate {
            self.datePickerStartDate = startDate
        }
        /// Setup custom picker end date
        if let endDate = datePickerEndDate {
            self.datePickerEndDate = endDate
        }
        /// Super initializer
        super.init(collector: vgs, fieldName: fieldName)
    }
    
    // MARK: - Overridden methods and properties
    public override var type: FieldType {
        get { return .date }
        set {}
    }
    
    // MARK: - VGSDateConfigurationProtocol implementation
    public var inputSource: VGSTextFieldInputSource = .datePicker
    public var inputDateFormat: VGSDateFormat?
    public var outputDateFormat: VGSDateFormat?
    
    // MARK: - VGSFormatSerializableProtocol implementation
    @preconcurrency public var serializers: [VGSFormatSerializerProtocol] = []
    @preconcurrency func serialize(_ content: String) -> [String: Any] {
        return DateFormatConvertor.serialize(content, serializers: serializers, outputFormat: outputDateFormat)
    }
    @preconcurrency internal var shouldSerialize: Bool {
        return !serializers.isEmpty
    }
    
    // MARK: - VGSDateTokenizationParameters implementation
    public var tokenizationParameters = VGSDateTokenizationParameters()
    internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
        return tokenizationParameters
    }
}

// MARK: - `TextFormatConvertable` implementation
extension VGSDateTokenizationConfiguration: @preconcurrency VGSTextFormatConvertable {
    
    /// :nodoc:
    var inputFormat: InputConvertableFormat? {
        return inputDateFormat
    }
    
    /// :nodoc:
    var outputFormat: OutputConvertableFormat? {
        return outputDateFormat
    }
    
    /// :nodoc:
    var convertor: TextFormatConvertor {
        return DateFormatConvertor()
    }
}
