//
//  VGSError.swift
//  VGSCollectSDK
//
//  Created by Dima on 24.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Type of `VGSError`  and it status code.
public enum VGSErrorType: Int {
    
    // MARK: - Text input data errors
    
    /// When input data is not valid, but required to be valid
    case inputDataIsNotValid = 1001
    
    // MARK: - Files data errors
    
    /// When can't find file on device
    case inputFileNotFound = 1101
    
    /// When can't find file on device
    case inputFileTypeIsNotSupported = 1102
    
    /// When file size is larger then allowed limit
    case inputFileSizeExceedsTheLimit = 1103
    
    /// When can't get access to file source
    case sourceNotAvailable = 1150
    
    // MARK: - Other errors
    /// Response data errors
    case unexpectedResponseDataFormat = 1401
}

/// An error produced by `VGSCollectSDK`. Works similar to default `NSError` in iOS.
public class VGSError: NSError {
    
    /// `VGSErrorType `-  required for each `VGSError` instance
    public let type: VGSErrorType!
    
    /// Code assiciated with `VGSErrorType`
    override public var code: Int {
        return type.rawValue
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal required init(type: VGSErrorType, userInfo info: VGSErrorInfo? = nil) {
        self.type = type
        super.init(domain: VGSCollectSDKErrorDomain, code: type.rawValue, userInfo: info?.asDictionary)
    }
}
