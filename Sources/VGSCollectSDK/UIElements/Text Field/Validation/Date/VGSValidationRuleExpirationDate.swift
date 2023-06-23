//
//  VGSValidationRuleExpirationDate.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Payment Card Expiration Date Format
public enum VGSCardExpDateFormat: InputConvertableFormat, OutputConvertableFormat {
  
  /// Exp.Date in format mm/yy: 01/22
  case shortYear
  
  /// Exp.Date in format mm/yyyy: 01/2022
  case longYear
  
  /// Exp.Date in format yy/mm: 22/01
  case shortYearThenMonth
  
  /// Exp.Date in format yy/mm: 2022/01
  case longYearThenMonth

  /// Initializer
  /// - Parameter name: String object, exp date format name.
  internal init?(name: String) {
    switch name {
    case "shortYear":
      self = .shortYear
      return
    case "longYear":
      self = .longYear
      return
    case "shortYearThenMonth":
      self = .shortYearThenMonth
      return
    case "longYearThenMonth":
      self = .longYearThenMonth
      return
    default:
      print("WRONG name!: \(name)")
      return nil
    }
  }
  
  var yearCharacters: Int {
    switch self {
    case .shortYear, .shortYearThenMonth:
      return 2
    case .longYear, .longYearThenMonth:
      return 4
    }
  }
  
  var monthCharacters: Int {
    return 2
  }
  
  internal var dateYearFormat: String {
    switch self {
    case .shortYear, .shortYearThenMonth:
      return "yy"
    case .longYear, .longYearThenMonth:
      return "yyyy"
    }
  }
  
  internal var isYearFirst: Bool {
    switch self {
    case .shortYear, .longYear:
      return false
    case .shortYearThenMonth, .longYearThenMonth:
      return true
    }
  }
    
    /// Accessibility value
    internal var accessibilityValue: String {
        switch self {
        case .shortYear:
            // MM/YY
            return Localization.ExpirationDateFormatAccessibility.shortYear
        case .longYear:
            // MM/YYYY
            return Localization.ExpirationDateFormatAccessibility.longYear
        case .shortYearThenMonth:
            // YY/MM
            return Localization.ExpirationDateFormatAccessibility.shortYearThenMonth
        case .longYearThenMonth:
            // YYYY/MM
            return Localization.ExpirationDateFormatAccessibility.longYearThenMonth
        }
    }
    
    /// Date format
    internal var dateFormat: String {
        switch self {
        case .shortYear:
            return "MM/yy"
        case .longYear:
            return "MM/yyyy"
        case .shortYearThenMonth:
            return "yy/MM"
        case .longYearThenMonth:
            return "yyyy/MM"
        }
    }
    
    /// Accessibility date from input
    internal func accessibilityDateFromInput(input: String) -> String? {
        /// Find the divider in the input
        let dividers = input.components(separatedBy: CharacterSet.decimalDigits).split(separator: "")
        /// There must be only 1 divider
        guard dividers.count == 1, let divider = dividers.first?.first else {
            return input
        }
        
        /// Create input date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = dateFormat.replacingOccurrences(of: "/", with: divider)
        
        /// Parse input to date
        guard let date = dateFormatter.date(from: input) else {
            return input
        }
        
        /// Parse date to accessibility string
        let accessibilityDateFormatter = DateFormatter()
        accessibilityDateFormatter.dateFormat = "MMMM yyyy"
        return accessibilityDateFormatter.string(from: date)
    }
}

/**
Validate input in scope of matching card expiration date format and time range.
*/
public struct VGSValidationRuleCardExpirationDate: VGSValidationRuleProtocol {

  /// Payment Card Expiration Date Format
  public let dateFormat: VGSCardExpDateFormat
  
  /// Validation Error
  public let error: VGSValidationError

  /// Initialization
  ///
  /// - Parameters:
  ///   - error:`VGSValidationError` - error on failed validation relust.
  ///   - dateFormat: `CardExpDateFormat` date format
  public init(dateFormat: VGSCardExpDateFormat = .shortYear, error: VGSValidationError) {
        self.dateFormat = dateFormat
        self.error = error
    }
}

extension VGSValidationRuleCardExpirationDate: VGSRuleValidator {
  internal func validate(input: String?) -> Bool {
        guard let input = input else {
            return false
        }
    
        let mmChars = self.dateFormat.monthCharacters
        let yyChars = self.dateFormat.yearCharacters
        guard input.count == mmChars + yyChars else { return false }
                
        let mm = self.dateFormat.isYearFirst ? input.suffix(mmChars) : input.prefix(mmChars)
        let yy = self.dateFormat.isYearFirst ? input.prefix(yyChars) : input.suffix(yyChars)
                        
        let todayYY = Calendar(identifier: .gregorian).component(.year, from: Date())
        let todayMM = Calendar(identifier: .gregorian).component(.month, from: Date())
        
        guard let inputMM = Int(mm), (1...12).contains(inputMM), var inputYY = Int(yy) else {
            return false
        }
        /// convert input year to long format if needed
        inputYY = self.dateFormat.yearCharacters == 2 ? (inputYY + 2000) : inputYY
        if inputYY < todayYY || inputYY > (todayYY + 20) {
            return false
        }
        
        if inputYY == todayYY && inputMM < todayMM {
            return false
        }
        return true
    }
}
