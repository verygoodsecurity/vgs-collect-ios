//
//  VGSDateFormat.swift
//  VGSCollectSDK
//

/// Format used to validate a VGS date text input
public enum VGSDateFormat: InputConvertableFormat, OutputConvertableFormat {
    case mmddyyyy
    case ddmmyyyy
    case yyyymmdd
    
    /// Initializer
    /// - Parameter name: String object, date format name.
    internal init?(name: String) {
        switch name {
        case "mmddyyyy":
            self = .mmddyyyy
            return
        case "ddmmyyyy":
            self = .ddmmyyyy
            return
        case "yyyymmdd":
            self = .yyyymmdd
            return
        default:
            print("WRONG name!: \(name)")
            return nil
        }
    }
    
    /// Amount of expected characters for day date component
    internal var daysCharacters: Int {
        return 2
    }
    
    /// Amount of expected characters for month date component
    internal var monthCharacters: Int {
        return 2
    }
    
    /// Amount of expected characters for year date component
    internal var yearCharacters: Int {
        return 4
    }
    
    /// Amount of expected dividers in the formatted date
    internal var dividerCharacters: Int {
        return 2
    }
    
    /// Get the formatted date to be used as a string representation based
    /// in the selected date format.
    ///
    /// - Returns: `String`, formatted date
    internal func mapDatePickerDataForFieldFormat(_ date: VGSDate) -> String {
        /// Day and month values
        let dayString = String(format: "%02d", date.day)
        let monthString = String(format: "%02d", date.month)
        
        /// Return the string of the date based on the format
        switch self {
        case .mmddyyyy:
            return "\(monthString)\(dayString)\(date.year)"
        case .ddmmyyyy:
            return "\(dayString)\(monthString)\(date.year)"
        case .yyyymmdd:
            return "\(date.year)\(monthString)\(dayString)"
        }
    }
    
    /// Get the formatted date including the divider
    internal func formatDate(_ date: VGSDate, divider: String) -> String {
        /// Day and month values
        let dayString = String(format: "%02d", date.day)
        let monthString = String(format: "%02d", date.month)
        
        /// Return the string of the date based on the format
        switch self {
        case .mmddyyyy:
            return "\(monthString)\(divider)\(dayString)\(divider)\(date.year)"
        case .ddmmyyyy:
            return "\(dayString)\(divider)\(monthString)\(divider)\(date.year)"
        case .yyyymmdd:
            return "\(date.year)\(divider)\(monthString)\(divider)\(dayString)"
        }
    }
    
    /// Format and validate an input string and try to convert it to `VGSDate`
    /// - Parameter input: `String` object, input data.
    /// - Returns: `VGSDate?`, date reference or `nil`.
    internal func dateFromInput(_ input: String?) -> VGSDate? {
        /// Make sure if is a valid input string
        guard let input = input else {
            return nil
        }
        /// Check the amount of chars per date component are correct
        let expectedCount = daysCharacters + monthCharacters + yearCharacters
        guard input.count == expectedCount else {
            return nil
        }
        // Format the date
        switch self {
        case .mmddyyyy:
            /// Get month, day and year
            let month = Int(input.prefix(monthCharacters))
            let day = Int(input.prefix(monthCharacters + daysCharacters).dropFirst(monthCharacters))
            let year = Int(input.suffix(yearCharacters))
            /// Make sure the data is good to create the date
            if let month = month, let day = day, let year = year {
                return VGSDate(day: day, month: month, year: year)
            }
            
        case .ddmmyyyy:
            /// Get day, month and year
            let day = Int(input.prefix(daysCharacters))
            let month = Int(input.prefix(daysCharacters + monthCharacters).dropFirst(daysCharacters))
            let year = Int(input.suffix(yearCharacters))
            /// Make sure the data is good to create the date
            if let day = day, let month = month, let year = year {
                return VGSDate(day: day, month: month, year: year)
            }
            
        case .yyyymmdd:
            /// Get year, month and day
            let year = Int(input.prefix(yearCharacters))
            let month = Int(input.prefix(yearCharacters + monthCharacters).dropFirst(yearCharacters))
            let day = Int(input.suffix(daysCharacters))
            /// Make sure the data is good to create the date
            if let year = year, let month = month, let day = day {
                return VGSDate(day: day, month: month, year: year)
            }
        }
        // By default return nil, no valid date
        return nil
    }
    
    /// Date format used for display in UI
    public var displayFormat: String {
        switch self {
        case .mmddyyyy:
            return "mm-dd-yyyy"
        case .ddmmyyyy:
            return "dd-mm-yyyy"
        case .yyyymmdd:
            return "yyyy-mm-dd"
        }
    }
    
    /// Accessibility date from input
    internal func accessibilityDateFromInput(input: String) -> String? {
        /// Find the divider in the input
        let divider = VGSDateFormat.dividerInInput(input)
        /// There must be only 1 divider
        guard !divider.isEmpty else {
            return input
        }
        
        /// Create input date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = displayFormat.replacingOccurrences(of: "-", with: divider)
        
        /// Parse input to date
        guard let date = dateFormatter.date(from: input) else {
            return input
        }
        
        /// Parse date to accessibility string
        let accessibilityDateFormatter = DateFormatter()
        accessibilityDateFormatter.dateFormat = "MMMM dd yyyy"
        return accessibilityDateFormatter.string(from: date)
    }
    
    /// Date format pattern used to display in the text field
    internal var formatPattern: String {
        switch self {
        case .mmddyyyy, .ddmmyyyy:
            return "##-##-####"
        case .yyyymmdd:
            return "####-##-##"
        }
    }
    
    // MARK: - Static properties and methods
    /// Default format
    static public let `default`: VGSDateFormat = .mmddyyyy
    
    /// Search the separator used in the input
    /// - Parameter input: `String` object, input data.
    /// - Returns: `String`, divider reference or empty string.
    static internal func dividerInInput(_ input: String) -> String {
        /// Remove all digits
        let dividers = input.components(separatedBy: CharacterSet.decimalDigits).split(separator: "")
        /// There must be only 2 dividers
        if dividers.count == 2,
           let first = dividers.first?.first,
           let second = dividers.last?.first {
            /// The dividers must be the same
            if String(first) == String(second) {
                return String(first)
            }
        }
        /// If no divider found, return empty
        return ""
    }
}
