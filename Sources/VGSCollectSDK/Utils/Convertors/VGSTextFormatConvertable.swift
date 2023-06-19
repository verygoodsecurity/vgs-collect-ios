//
//  VGSTextFormatConvertable.swift
//  VGSCollectSDK
//

import Foundation

/// Base protocol describing the input format to conver a string value
protocol InputConvertableFormat { }

/// Base protocol describing the output format to conver a string value
protocol OutputConvertableFormat { }
 
/// Base protocol to implements the method to convert an `input` string
/// with input `InputConvertableFormat` to output `OutputConvertableFormat`
protocol TextFormatConvertor {
    func convert(_ input: String,
                 inputFormat: InputConvertableFormat,
                 outputFormat: OutputConvertableFormat) -> String
}

/// Base protocol to implement the input and output formats and
/// the convertor for input strings
protocol VGSTextFormatConvertable {
    /// Input text format
    var inputFormat: InputConvertableFormat? { get }
    /// Output text format
    var outputFormat: OutputConvertableFormat? { get }
    /// Text convertor object
    var convertor: TextFormatConvertor { get }
}
