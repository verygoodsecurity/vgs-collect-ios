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
    
    
    let inputYear = inputFormat.isYearFirst ? String(input.prefix(inputFormat.yearCharacters)) : String(input.suffix(inputFormat.yearCharacters))
    let inputMonth = inputFormat.isYearFirst ? input.suffix(inputFormat.monthCharacters) : input.prefix(inputFormat.monthCharacters)
    let divider = inputFormat.isYearFirst ? String(input.dropLast(inputFormat.monthCharacters)).dropFirst(inputFormat.yearCharacters) : String(input.dropLast(inputFormat.yearCharacters)).dropFirst(inputFormat.monthCharacters)
    
		let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    dateFormatter.dateFormat = inputFormat.dateYearFormat
		dateFormatter.locale = Locale(identifier: "en_US")
    
    if let date = dateFormatter.date(from: inputYear) {
      dateFormatter.dateFormat = outputFormat.dateYearFormat
      let outputYear = dateFormatter.string(from: date)
      let output = outputFormat.isYearFirst ? String(outputYear + divider + inputMonth) :
      String(inputMonth + divider + outputYear)
      return output
    }
    let text = "CANNOT CONVERT DATE FORMAT! NOT VALID INPUT YEAR - \(inputYear). WILL USE ORIGINAL(INPUT) DATE FORMAT!"
    let event = VGSLogEvent(level: .warning, text: text, severityLevel: .warning)
    VGSCollectLogger.shared.forwardLogEvent(event)
    
    return input
  }

  /// Serializes expiration date.
  /// - Parameters:
  ///   - content: `String` object, content to serialize
  ///   - serializers: `[VGSFormatSerializerProtocol]` object, an array of serializers.
  ///   - outputFormat: `VGSCardExpDateFormat` object, output date format,
  /// - Returns: `[String: Any]` object, json with serialized data.
  static internal func serialize(_ content: String, serializers: [VGSFormatSerializerProtocol], outputFormat: VGSCardExpDateFormat?) -> [String: Any] {
    var result = [String: Any]()
    for serializer in serializers {
      if let serializer = serializer as? VGSExpDateSeparateSerializer {
        /// remove dividers
        var dateDigitsString = content.digits

        /// get output date format, if not set - use default
        let outputDateFormat = outputFormat ?? .shortYear
        /// check output date components length
        let outputMonthDigits = outputDateFormat.monthCharacters
        let outputYearDigits = outputDateFormat.yearCharacters

        let mth: String
        let year: String
        if outputDateFormat.isYearFirst {
          /// take month digitis
          year = String(dateDigitsString.prefix(outputYearDigits))
          /// remove month digits
          dateDigitsString = String(dateDigitsString.dropFirst(outputYearDigits))
          /// take year digitis
          mth = String(dateDigitsString.prefix(outputMonthDigits))
        } else {
          /// take month digitis
          mth = String(dateDigitsString.prefix(outputMonthDigits))
          /// remove month digits
          dateDigitsString = String(dateDigitsString.dropFirst(outputMonthDigits))
          /// take year digitis
          year = String(dateDigitsString.prefix(outputYearDigits))
        }

        /// set result for specific fieldnames
        result[serializer.monthFieldName] = mth
        result[serializer.yearFieldName] = year
      }
    }
    return result
  }
}
