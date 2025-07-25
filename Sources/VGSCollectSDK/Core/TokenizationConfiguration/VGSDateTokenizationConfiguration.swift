//
//  VGSDateTokenizationConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSDateTokenizationParameters` - parameters required for tokenization API
public struct VGSDateTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public var storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// Class responsible for configuration `VGSDateTextField` or `VGSTextField` with `fieldType = .date`.
/// Extends `VGSConfiguration`. Required to work with tokenization API.
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
