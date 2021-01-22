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
  var inputFormat: CardExpDateFormat? { get }
  /// Output text format
  var outputFormat: CardExpDateFormat? { get }
  /// Text convertor object
  var convertor: TextFormatConvertor { get }
}

internal protocol TextFormatConvertor {
  func convert(_ input: String, inputFormat: CardExpDateFormat, outputFormat: CardExpDateFormat) -> String
}

/// Card Expiration date format convertor
internal class ExpDateFormatConvertor: TextFormatConvertor {
  
  /// Convert Exp Date String with input `CardExpDateFormat` to Output `CardExpDateFormat`
  func convert(_ input: String, inputFormat: CardExpDateFormat, outputFormat: CardExpDateFormat) -> String {
    
    let inputYear = String(input.suffix(inputFormat.yearCharacters))
    let inputStart = input.dropLast(inputFormat.yearCharacters)
    
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    dateFormatter.dateFormat = inputFormat.dateYearFormat
    
    if let date = dateFormatter.date(from: inputYear) {
      dateFormatter.dateFormat = outputFormat.dateYearFormat
      let outputYear = dateFormatter.string(from: date)
      let output = String(inputStart + outputYear)
      return output
    }
    print("NOT VALID INPUT YEAR, WILL USE INPUT DATE!!!!")
    return input
  }
}
