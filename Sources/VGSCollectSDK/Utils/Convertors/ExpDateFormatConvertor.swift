//
//  ExpDateFormatConvertor.swift
//  VGSCollectSDK
//
//  Created by Dima on 22.01.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

internal protocol FormatConvertable {
  /// Input text format
  var inputFormat: VGSCardExpDateFormat? { get }
  /// Output text format
  var outputFormat: VGSCardExpDateFormat? { get }
  /// Text convertor object
  var convertor: TextFormatConvertor { get }
}

internal protocol TextFormatConvertor {
  func convert(_ input: String, inputFormat: VGSCardExpDateFormat, outputFormat: VGSCardExpDateFormat) -> String
}

/// Card Expiration date format convertor
internal class ExpDateFormatConvertor: TextFormatConvertor {
  
  /// Convert Exp Date String with input `CardExpDateFormat` to Output `CardExpDateFormat`
  func convert(_ input: String, inputFormat: VGSCardExpDateFormat, outputFormat: VGSCardExpDateFormat) -> String {
    
    let inputYear = String(input.suffix(inputFormat.yearCharacters))
    let inputStart = input.dropLast(inputFormat.yearCharacters)
    
		let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    dateFormatter.dateFormat = inputFormat.dateYearFormat
		dateFormatter.locale = Locale(identifier: "en_US")
    
    if let date = dateFormatter.date(from: inputYear) {
      dateFormatter.dateFormat = outputFormat.dateYearFormat
      let outputYear = dateFormatter.string(from: date)
      let output = String(inputStart + outputYear)
      return output
    }
    let text = "CANNOT CONVERT DATE FORMAT! NOT VALID INPUT YEAR - \(inputYear). WILL USE ORIGINAL(INPUT) DATE FORMAT!"
    let event = VGSLogEvent(level: .warning, text: text, severityLevel: .warning)
    VGSCollectLogger.shared.forwardLogEvent(event)
    
    return input
  }
}
