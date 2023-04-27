//
//  VGSDateSeparateSerializer.swift
//  VGSCollectSDK
//

import Foundation

public struct VGSDateSeparateSerializer: VGSFormatSerializerProtocol {
    
    // MARK: - Properties
    /// Field Name that will be used as a JSON key with day value from date string on send request.
    public let dayFieldName: String
    
    /// Field Name that will be used as a JSON key with month value from date string on send request.
    public let monthFieldName: String
    
    /// Field Name that will be used as a JSON key with year value from date string on send request.
    public let yearFieldName: String
    
    // MARK: - Initialization
    /// Initialization
    ///
    /// - Parameters:
    ///   - dayFielddName: key, that should be associated with day value in request JSON.
    ///   - monthFieldName: key, that should be associated with month value in request JSON.
    ///   - yearFieldName: key, that should be associated with year value in request JSON.
    public init(dayFieldName: String, monthFieldName: String, yearFieldName: String) {
        self.dayFieldName = dayFieldName
        self.monthFieldName = monthFieldName
        self.yearFieldName = yearFieldName
    }
}
