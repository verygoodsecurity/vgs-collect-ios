//
//  VGSValidationRuleExpirationDate.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSValidationRuleCardExpirationDate: VGSValidationRule {
    
  public enum ExpDateFormat {
    case shortYear
    case longYear
    
    var yearCharacters: Int {
      switch self {
      case .shortYear:
        return 2
      case .longYear:
        return 4
      }
    }
  }

  public let dateFormat: ExpDateFormat
  public let error: VGSValidationError

  public init(dateFormat: ExpDateFormat = .shortYear, error: VGSValidationError) {
        self.dateFormat = dateFormat
        self.error = error
    }
    
  public func validate(input: String?) -> Bool {

        guard let input = input else {
            return false
        }
    
        let mmChars = 2
        let yyChars = self.dateFormat.yearCharacters
        guard input.count == mmChars + yyChars else { return false }
                
        let mm = input.prefix(mmChars)
        let yy = input.suffix(yyChars)
                
        let today = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = self.dateFormat == .longYear ? "yyyy" : "yy"
        let todayYY = Int(formatter.string(from: today)) ?? 0
        
        formatter.dateFormat = "MM"
        let todayMM = Int(formatter.string(from: today)) ?? 0
        
        guard let inputMM = Int(mm), let inputYY = Int(yy) else {
            return false
        }
        
        if inputYY < todayYY || inputYY > (todayYY + 20) {
            return false
        }
        
        if inputYY == todayYY && inputMM < todayMM {
            return false
        }
        return true
    }
}
