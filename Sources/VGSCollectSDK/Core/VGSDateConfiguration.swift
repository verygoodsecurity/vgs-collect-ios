//
//  VGSDateConfiguration.swift
//  VGSCollectSDK
//

import Foundation

/// Define the methods and properties the date configuration must have
@MainActor public protocol VGSDateConfigurationProtocol {
    
    /// Input source type.
    var inputSource: VGSTextFieldInputSource {get set}
    
    /// Input date format to convert.
    var inputDateFormat: VGSDateFormat? {get set}
    
    /// Output date format to convert.
    var outputDateFormat: VGSDateFormat? {get set}
}

/// Class responsible for configuration `VGSDateTextField` or `VGSTextField` with `fieldType = .date`. Extends `VGSConfiguration`
@MainActor public final class VGSDateConfiguration: VGSConfiguration, VGSDateConfigurationProtocol, VGSFormatSerializableProtocol {
    
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
    nonisolated public var inputDateFormat: VGSDateFormat?
    nonisolated public var outputDateFormat: VGSDateFormat?
    
    // MARK: - VGSFormatSerializableProtocol implementation
    public var serializers: [VGSFormatSerializerProtocol] = []
    func serialize(_ content: String) -> [String: Any] {
        return DateFormatConvertor.serialize(content, serializers: serializers, outputFormat: outputDateFormat)
    }
    internal var shouldSerialize: Bool {
        return !serializers.isEmpty
    }
}

// MARK: - Static properties and methods
@MainActor extension VGSDateConfiguration {
    
    /// Amount of years used to calculate the minimun and maximun date picker default dates
    public static var validYearsCount = 100
    
    /// Minimun date picker start date, current year minus `validYearsCount`
    public static let minValidPickerStartDate = VGSDate(
        day: 1,
        month: 1,
        year: Calendar.currentYear - validYearsCount
    )!
    
    /// Maximun date picker valid end date, current year plus `validYearsCount`
    public static var maxValidPickerEndDate = VGSDate(
        day: 1,
        month: 1,
        year: Calendar.currentYear + validYearsCount
    )!
    
    /// Get the array of years used as default when no start date or end date are defined
    internal static var defaultYears: [Int] = {
        let startYear = VGSDateConfiguration.minValidPickerStartDate.year
        let endYear = VGSDateConfiguration.maxValidPickerEndDate.year
        return Array(startYear...endYear)
    }()
}

// MARK: - `TextFormatConvertable` implementation
@MainActor extension VGSDateConfiguration: VGSTextFormatConvertable {
    
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
