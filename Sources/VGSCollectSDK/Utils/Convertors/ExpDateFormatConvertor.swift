//
//  ExpDateFormatConvertor.swift
//  VGSCollectSDK
//
//  Created by Dima on 22.01.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal protocol FormatConvertable {
  /// Input text format
  var inputFormat: String? { get }
  /// Output text format
  var outputFormat: String? { get }
  /// Text convertor object
  var convertor: TextFormatConvertor { get }
}

internal protocol TextFormatConvertor {
  func convert(_ input: String, inputFormat: String, outputFormat: String) -> String
}

/// Card Expiration date format convertor
internal class ExpDateFormatConvertor: TextFormatConvertor {
  
  /// Convert Exp Date String with input Format to Output Format
  func convert(_ input: String, inputFormat: String, outputFormat: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    dateFormatter.dateFormat = inputFormat
    if let date = dateFormatter.date(from: input) {
      dateFormatter.dateFormat = outputFormat
      let outputDate = dateFormatter.string(from: date)
      return outputDate
    }
    print("NOT VALID INPUT DATE FORMAT, WILL USE INPUT DATE!!!!")
    return input
  }
}
