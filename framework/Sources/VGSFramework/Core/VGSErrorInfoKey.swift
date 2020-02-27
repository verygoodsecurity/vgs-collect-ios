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
public let VGSSDKErrorInputDataRequired: VGSErrorInfoKey = "VGSSDKErrorInputDataRequired"
public let VGSSDKErrorInputDataRequiredValid: VGSErrorInfoKey = "VGSSDKErrorInputDataRequiredValid"

// Response errors

public let VGSSDKErrorUnexpectedResponseDataFormat: VGSErrorInfoKey = "VGSSDKErrorUnexpectedResponseDataFormat"
