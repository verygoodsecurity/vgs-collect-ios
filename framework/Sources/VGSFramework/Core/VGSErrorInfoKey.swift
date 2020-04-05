//
//  VGSErrorInfoKey.swift
//  VGSFramework
//
//  Created by Dima on 27.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public typealias VGSErrorInfoKey = String

/// An error domain used to produce `VGSError` from `VGSCollectSDK`.
public let VGSCollectSDKErrorDomain = "vgscollect.sdk"

// MARK: - VGSErrorInfoKeys

// MARK: - Input data errors
public let VGSSDKErrorInputDataIsNotValid: VGSErrorInfoKey = "VGSSDKErrorInputDataIsNotValid"
public let VGSSDKErrorInputDataRequired: VGSErrorInfoKey = "VGSSDKErrorInputDataRequired"
public let VGSSDKErrorInputDataRequiredValid: VGSErrorInfoKey = "VGSSDKErrorInputDataRequiredValid"

// MARK: - File data errors
public let VGSSDKErrorFileNotFound: VGSErrorInfoKey = "VGSSDKErrorFileNotFound"
public let VGSSDKErrorFileTypeNotSupported: VGSErrorInfoKey = "VGSSDKErrorFileTypeNotSupported"
public let VGSSDKErrorFileSizeExceedsTheLimit: VGSErrorInfoKey = "VGSSDKErrorFileSizeExceedsTheLimit"

// MARK: - Source errors
public let VGSSDKErrorSourceNotAvailable: VGSErrorInfoKey = "VGSSDKErrorSourceNotAvailable"

// MARK: - Response errors
public let VGSSDKErrorUnexpectedResponseDataFormat: VGSErrorInfoKey = "VGSSDKErrorUnexpectedResponseDataFormat"
