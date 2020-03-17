//
//  VGSFileMetaData.swift
//  VGSFramework
//
//  Created by Dima on 17.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

@objc
public protocol VGSFileInfoProtocol {
    var fileExtension: String? { get }
    var size: Int { get }
    var sizeUnits: String? { get }
}

/// An object that can contain files' metadata
public class VGSFileInfo: NSObject, VGSFileInfoProtocol {
    
    /// File extension, like "jpeg", "png", etc.
    public let fileExtension: String?
    
    /// File size
    public let size: Int
    
    /// File size units
    public let sizeUnits: String?
    
    required internal init(fileExtension: String, size: Int, sizeUnits: String) {
        self.fileExtension = fileExtension
        self.size = size
        self.sizeUnits = sizeUnits
    }
}
