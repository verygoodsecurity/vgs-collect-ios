//
//  DateFormatConvertor.swift
//  VGSCollectSDK
//

import Foundation

/// Date format convertor
internal class DateFormatConvertor: TextFormatConvertor {
    
    /// Convert date string with input `VGSDateFormat` to output `VGSDateFormat`
    func convert(_ input: String,
                 inputFormat: InputConvertableFormat,
                 outputFormat: OutputConvertableFormat) -> String {
        /// Make sure the input and output formats are references to `VGSCardExpDateFormat`
        guard let inputFormat = inputFormat as? VGSDateFormat,
              let outputFormat = outputFormat as? VGSDateFormat else {
            let text = "CANNOT CONVERT DATE FORMAT! NOT VALID INPUT OR OUTPUT FORMATS. WILL USE ORIGINAL(INPUT) DATE FORMAT!"
            let event = VGSLogEvent(level: .warning, text: text, severityLevel: .warning)
            VGSCollectLogger.shared.forwardLogEvent(event)
            return input
        }
        
        // Get digits
        let result = input.digits
        // Get output
        if let inputDate = inputFormat.dateFromInput(result) {
            /// Store the dividers
            let divider = VGSDateFormat.dividerInInput(input)
            // Return output date including the divider
            return outputFormat.formatDate(inputDate, divider: divider)
        }
        
        // Error, no valid input
        let text = "CANNOT CONVERT DATE FORMAT! NOT VALID INPUT OR OUTPUT FORMATS. WILL USE ORIGINAL(INPUT) DATE FORMAT!"
        let event = VGSLogEvent(level: .warning, text: text, severityLevel: .warning)
        VGSCollectLogger.shared.forwardLogEvent(event)
        return input
    }
    
    /// Serializes date
    /// - Parameters:
    ///   - content: `String` object, content to serialize
    ///   - serializers: `[VGSFormatSerializerProtocol]` object, an array of serializers.
    ///   - outputFormat: `VGSDateFormat` object, output date format,
    /// - Returns: `[String: Any]` object, json with serialized data.
    static internal func serialize(_ content: String,
                                   serializers: [VGSFormatSerializerProtocol],
                                   outputFormat: VGSDateFormat?) -> [String: Any] {
        var result = [String: Any]()
        for serializer in serializers {
            if let serializer = serializer as? VGSDateSeparateSerializer {
                /// Remove dividers
                let dateDigitsString = content.digits
                
                /// Get output date format, or default if not set
                let outputDateFormat = outputFormat ?? .default
                
                /// Check output date components length
                if let outputDate = outputDateFormat.dateFromInput(dateDigitsString) {
                    /// Set result for specific field names
                    result[serializer.dayFieldName] = outputDate.dayFormatted
                    result[serializer.monthFieldName] = outputDate.monthFormatted
                    result[serializer.yearFieldName] = String(outputDate.year)
                } else {
                    // Error, no valid output
                    let text = "CANNOT SERIALIZE DATE! NOT VALID OUTPUT FORMATS OR INPUT. WILL USE ORIGINAL(INPUT) DATE FORMAT!"
                    let event = VGSLogEvent(level: .warning, text: text, severityLevel: .warning)
                    VGSCollectLogger.shared.forwardLogEvent(event)
                }
            }
        }
        return result
    }
}
