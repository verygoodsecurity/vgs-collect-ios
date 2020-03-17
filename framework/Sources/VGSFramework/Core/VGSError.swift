//
//  VGSError.swift
//  VGSFramework
//
//  Created by Dima on 24.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public enum VGSErrorType: Int {
    // TextField data errors
    case inputDataRequired = 1001
    case inputDataRequiredValidOnly = 1002
    
    // Files data errors
    case inputFileNotFound = 1101
    case inputFileTypeIsNotSupported = 1102
    case inputFileSizeExceedsTheLimit = 1103
    case sourceNotAvailable = 1150
    
    // Response data errors
    case unexpectedResponseDataFormat = 1401
}

public class VGSError: NSError {
    
    public let type: VGSErrorType!
    
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
