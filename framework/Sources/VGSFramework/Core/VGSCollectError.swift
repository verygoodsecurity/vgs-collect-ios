//
//  VGSCollectError.swift
//  VGSFramework
//
//  Created by Dima on 12.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public typealias VGSErrorInfo = [String: Any]
    
public enum VGSTextFieldInputError: Error {
    case isRequired(_ info: VGSErrorInfo)
    case isRequiredValidOnly(_ info: VGSErrorInfo)
}
