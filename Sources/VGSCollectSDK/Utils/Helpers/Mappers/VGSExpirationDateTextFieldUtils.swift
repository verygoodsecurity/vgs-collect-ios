//
//  VGSExpirationDateTextFieldUtils.swift
//  VGSCollectSDK
//
//  Created by Dima on 21.04.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal final class VGSExpirationDateTextFieldUtils {
  
  /// Map the date components to expected VGSCardExpDateFormat
  internal static func mapDatePickerExpirationDataForFieldFormat(_ format: VGSCardExpDateFormat, month: Int, year: Int) -> String {
    
    let monthString = String(format: "%02d", month)

    switch format {
    case .shortYear:
      let yearString = String(year - 2000)
      return "\(monthString)\(yearString)"
    case .longYear:
      let yearString = String(year)
      return "\(monthString)\(yearString)"
    case .shortYearThenMonth:
      let yearString = String(year - 2000)
      return "\(yearString)\(monthString)"
    case .longYearThenMonth:
      let yearString = String(year)
      return "\(yearString)\(monthString)"
    }
  }
}
