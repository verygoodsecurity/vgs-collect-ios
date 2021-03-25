//
//  VGSValidationRuleExpirationDate.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Payment Card Expiration Date Format
public enum VGSCardExpDateFormat {
  
  /// Exp.Date in format mm/yy: 01/22
  case shortYear
  
  /// Exp.Date in format mm/yyyy: 01/2022
  case longYear
  
  var yearCharacters: Int {
    switch self {
    case .shortYear:
      return 2
    case .longYear:
      return 4
    }
  }
  
  var monthCharacters: Int {
    return 2
  }
  
  internal var dateYearFormat: String {
    switch self {
    case .shortYear:
      return "yy"
    case .longYear:
      return "yyyy"
    }
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

  /// Initialzation
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
    
        let mmChars = 2
        let yyChars = self.dateFormat.yearCharacters
        guard input.count == mmChars + yyChars else { return false }
                
        let mm = input.prefix(mmChars)
        let yy = input.suffix(yyChars)
                        
        let todayYY = Calendar(identifier: .gregorian).component(.year, from: Date())
        let todayMM = Calendar(identifier: .gregorian).component(.month, from: Date())
        
        guard let inputMM = Int(mm), (1...12).contains(inputMM), var inputYY = Int(yy) else {
            return false
        }
        ///convert input year to long format if needed
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
