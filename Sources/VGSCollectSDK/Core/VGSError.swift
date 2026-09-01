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
  
    /// When access token is nil or empty.
    case invalidAccessToken = 1300

    /// When authHandler is not set but required.
    case authHandlerNotSet = 1301

    /// When a CMP update request has an empty or unsafe card ID.
    case invalidCardID = 1302
  
    /// When response type is not supported
    case unexpectedResponseType = 1400
    
    /// When response data format is not supported
    case unexpectedResponseDataFormat = 1401

    /// When form parameter is invalid.
    case invalidFormConfiguration = 1460

    /// When the session configuration URL cannot be built for `VGSCollect.session(with:vaultId:environment:dataRegion:completion:)`.
    case invalidConfigurationURL = 1480

    /// When `VGSCollect.session(with:vaultId:environment:dataRegion:completion:)` fails while loading or decoding the remote session configuration.
    case sessionInitializationFailed = 1490
}

public extension VGSErrorType {
    // Deprecated compatibility aliases for names published before Swift 6 lint cleanup.
    @available(*, deprecated, renamed: "authHandlerNotSet")
    static var AuthHandlerNotSet: VGSErrorType { .authHandlerNotSet }

    @available(*, deprecated, renamed: "invalidFormConfiguration")
    static var InvalidFormConfiguration: VGSErrorType { .invalidFormConfiguration }

    @available(*, deprecated, renamed: "sessionInitializationFailed")
    static var SessionInitializationFailed: VGSErrorType { .sessionInitializationFailed }
}

/// An error produced by `VGSCollectSDK`. Works similar to default `NSError` in iOS.
public class VGSError: NSError, @unchecked Sendable {
    
    /// `VGSErrorType `-  required for each `VGSError` instance
    public let type: VGSErrorType!
    
    /// Code assiciated with `VGSErrorType`
    override public var code: Int {
        return type.rawValue
    }

      ///: nodoc. Public required init.
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Initializer.
    /// - Parameters:
    ///   - type: `VGSErrorType` object, error type.
    ///   - info: `VGSErrorInfo?` object, error info, default is `nil`.
    internal required init(type: VGSErrorType, userInfo info: VGSErrorInfo? = nil) {
        self.type = type
        super.init(domain: VGSCollectSDKErrorDomain, code: type.rawValue, userInfo: info?.asDictionary)
    }
}
