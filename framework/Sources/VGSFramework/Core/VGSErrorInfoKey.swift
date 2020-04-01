//
//  VGSErrorInfoKey.swift
//  VGSFramework
//
//  Created by Dima on 27.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public typealias VGSErrorInfoKey = String

public let VGSCollectSDKErrorDomain = "vgscollect.sdk"

// MARK: - VGSErrorInfoKeys

// Input data errors
public let VGSSDKErrorInputDataIsNotValid: VGSErrorInfoKey = "VGSSDKErrorInputDataIsNotValid"
public let VGSSDKErrorInputDataRequired: VGSErrorInfoKey = "VGSSDKErrorInputDataRequired"
public let VGSSDKErrorInputDataRequiredValid: VGSErrorInfoKey = "VGSSDKErrorInputDataRequiredValid"

// File data errors
public let VGSSDKErrorFileNotFound: VGSErrorInfoKey = "VGSSDKErrorFileNotFound"
public let VGSSDKErrorFileTypeNotSupported: VGSErrorInfoKey = "VGSSDKErrorFileTypeNotSupported"
public let VGSSDKErrorFileSizeExceedsTheLimit: VGSErrorInfoKey = "VGSSDKErrorFileSizeExceedsTheLimit"

// Source errors(camera, photolibrary, etc.)
public let VGSSDKErrorSourceNotAvailable: VGSErrorInfoKey = "VGSSDKErrorSourceNotAvailable"

// Response errors
public let VGSSDKErrorUnexpectedResponseDataFormat: VGSErrorInfoKey = "VGSSDKErrorUnexpectedResponseDataFormat"
