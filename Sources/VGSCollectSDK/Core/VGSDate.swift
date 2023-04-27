//
//  VGSDate.swift
//  VGSCollectSDK
//

import Foundation

/// `Struct` that represents a date including `year`, `month` and `day`. It doesn't include `hours`, `minutes` or `seconds`.
public struct VGSDate {
    
    // MARK: - Properties
    public var day: Int
    public var month: Int
    public var year: Int
    
    /// Get the day formatted value, for example if the day is `1` it is returned as `01`
    public var dayFormatted: String {
        return String(format: "%02d", day)
    }
    
    /// Get the month formatted value, for example if the month is `3` it is returned as `03`
    public var monthFormatted: String {
        return String(format: "%02d", month)
    }
   
    // MARK: - Initialization
    /// Create a new instance of a `VGSDate` object, if the date is not valid, it returns `nil`
    /// - Parameters:
    ///     - day: `Int`. Represents the day in the date.
    ///     - month: `Int`. Represents the month in the date.
    ///     - year: `Int`. Represents the year in the date.
    /// - Returns: `VGSDate`, date reference or nil if the date is invalid.
    public init?(day: Int, month: Int, year: Int) {
        // Make sure it is a valid date
        guard DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: year,
            month: month,
            day: day
        ).isValidDate else {
            let message = "Invalid day, month or year to create date at VGSDate initializer"
            let event = VGSLogEvent(level: .warning, text: message, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)
            return nil
        }
        // Save date data
        self.day = day
        self.month = month
        self.year = year
    }
}

// MARK: - Equatable and Comparable implementation
extension VGSDate: Comparable {
    
    /// :nodoc:
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.year == rhs.year &&
        lhs.month == rhs.month &&
        lhs.day == rhs.day
    }
    
    /// :nodoc:
    public static func < (lhs: VGSDate, rhs: VGSDate) -> Bool {
        // Check year
        if lhs.year < rhs.year {
            return true
        }
        // If the year is equal, check month
        else if lhs.year == rhs.year {
            // Check month
            if lhs.month < rhs.month {
                return true
            }
            // If the month is equal, check day
            else if lhs.month == rhs.month {
                // Check day
                return lhs.day < rhs.day
            }
        }
        // The date at left is not less than date at right
        return false
    }
}
