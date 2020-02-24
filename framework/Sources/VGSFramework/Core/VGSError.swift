//
//  VGSError.swift
//  VGSFramework
//
//  Created by Dima on 24.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public class VGSError: NSError {
    
    public enum ErrorType: Int {
        // TextField data errors
        case inputDataRequired = 1001
        case inputDataRequiredValidOnly = 1002
        
        // File data errors
        case inputFileSizeExceedsTheLimit = 1101
        case inputFileTypeIsWrong = 1102
        case inputFileTypeIsNotSupported = 1103
        case inputFileNotFound = 1104
    }

    public let type: ErrorType!
    
    override public var code: Int {
        return type.rawValue
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal required init(type: ErrorType, userInfo dict: [String: Any]? = nil) {
        self.type = type
        super.init(domain: "vgscollectsdk", code: type.rawValue, userInfo: dict)
    }
}
