//
//  Localization.swift
//  VGSCollectSDK
//

import Foundation

/// Encapsulate all the localized values of the project
internal struct Localization {
    
    // MARK: - Localization structs
    /// Labels shown for each field type in voice over
    struct FieldTypeAccessibility {
        static let none = localizedString(key: "vgs_text_input",
                                          comment: "Field `none` accessibility label")
        static let cardNumber = localizedString(key: "vgs_card_number_input",
                                                comment: "Field `cardNumber` accessibility label")
        static let expDate = localizedString(key: "vgs_expiration_date_input",
                                             comment: "Field `expDate` with picker accessibility label")
        static let expDatePicker = localizedString(key: "vgs_expiration_date_picker_input",
                                                   comment: "Field `expDate` with picker accessibility label")
        static let date = localizedString(key: "vgs_date_input",
                                          comment: "Field `date` accessibility label")
        static let datePicker = localizedString(key: "vgs_date_picker_input",
                                                comment: "Field `date` with picker accessibility label")
        static let cvc = localizedString(key: "vgs_card_security_code",
                                         comment: "Field `cvc` accessibility label")
        static let cardHolderName = localizedString(key: "vgs_card_holder_name_input",
                                                    comment: "Field `cardHolderName` accessibility label")
        static let ssn = localizedString(key: "vgs_social_security_number",
                                         comment: "Field `ssn` accessibility label")
    }
    
    /// Values shown for each date format in voice over
    struct DateFormatAccessibility {
        static let mmddyyyy = localizedString(key: "vgs_month_day_year",
                                              comment: "Date format `mmddyyyy` accessibility value")
        static let ddmmyyyy = localizedString(key: "vgs_day_month_year",
                                              comment: "Date format `ddmmyyyy` accessibility value")
        static let yyyymmdd = localizedString(key: "vgs_year_month_day",
                                              comment: "Date format `yyyymmdd` accessibility value")
    }
    
    /// Values shown for each expiration date format in voice over
    struct ExpirationDateFormatAccessibility {
        static let shortYear = localizedString(key: "vgs_month_and_short_year",
                                               comment: "Expiration date format `shortYear` accessibility value")
        static let longYear = localizedString(key: "vgs_month_and_long_year",
                                              comment: "Expiration date format `longYear` accessibility value")
        static let shortYearThenMonth = localizedString(key: "vgs_short_year_and_month",
                                                        comment: "Expiration date format `shortYearThenMonth` accessibility value")
        static let longYearThenMonth = localizedString(key: "vgs_long_year_and_month",
                                                       comment: "Expiration date format `longYearThenMonth` accessibility value")
    }
    
    /// Values shown for status valid or invalid in voice over
    struct FieldStatus {
        static let valid = localizedString(key: "vgs_valid",
                                           comment: "Valid status")
        static let invalid = localizedString(key: "vgs_invalid",
                                             comment: "Invalid status")
    }
    
    // MARK: - Utilities
    /// Search the localizable key in the bundle of the application, if it
    /// is not overriden by the user, then get it from the library bundle `VGSLocalizable`.
    private static func localizedString(key: String, comment: String) -> String {
        /// Try to get the string from the localized strings
        var string = NSLocalizedString(key, comment: comment)
        
        /// If the string is not found, try to find it in the bundle strings `VGSLocalizable`
        if string == key, let bundle = AssetsBundle.main.iconBundle {
            string = NSLocalizedString(key,
                                       tableName: "VGSLocalizable",
                                       bundle: bundle,
                                       comment: comment)
        }
        return string
    }
}
