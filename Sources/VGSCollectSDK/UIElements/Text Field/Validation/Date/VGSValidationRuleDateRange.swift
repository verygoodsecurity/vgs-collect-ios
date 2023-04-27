//
//  VGSDateRangeValidationRule.swift
//  VGSCollectSDK
//

import Foundation

/// Validation rule used to validate the date input in objects
/// like `VGSDateTextField`, `VGSTextField` and `VGSExpDateTextField`
public struct VGSValidationRuleDateRange: VGSValidationRuleProtocol {
    
    // MARK: - Properties
    /// Store the start date, it can be null
    internal let startDate: VGSDate?
    
    /// Store the end date, it can be null
    internal let endDate: VGSDate?
    
    /// Date format used to validate the rule
    public let dateFormat: VGSDateFormat
    
    /// Error used in case the validation is invalid
    public let error: VGSValidationError
    
    // MARK: - Constructor
    /// Initialization
    ///
    /// - Parameters:
    ///   - dateFormat: Format used to validate the rule, defaults to `VGSDateFormat.default`.
    ///   - error: Error used in case there is an error with the validation rule.
    ///   - startDate: optional `VGSDate` instance.
    ///   - endDate: optional `VGSDate` instance.
    public init(dateFormat: VGSDateFormat = VGSDateFormat.default,
                error: VGSValidationError,
                start: VGSDate? = nil,
                end: VGSDate? = nil) {
        self.dateFormat = dateFormat
        self.error = error
        self.startDate = start
        self.endDate = end
    }
}

// MARK: - VGSRuleValidator implementation
extension VGSValidationRuleDateRange: VGSRuleValidator {
    
    /// :nodoc:
    internal func validate(input: String?) -> Bool {
        /// Must have valid input
        guard let input = input else {
            return false
        }
        
        /// Format input date match selected format
        guard let inputDate = dateFormat.dateFromInput(input) else {
            return false
        }
        
        /// When startDate and endDate are set, validate that startDate `<=` inputDate `<=` endDate
        if let startDate = startDate, let endDate = endDate {
            return startDate <= inputDate && inputDate <= endDate
        }
        
        /// When startDate is set, validate that startDate `<=` inputDate
        if let startDate = startDate {
            return startDate <= inputDate
        }
        
        /// When endDate is set, validate that inputDate `<=` endDate
        if let endDate = endDate {
            return inputDate <= endDate
        }
        
        return true
    }
}
