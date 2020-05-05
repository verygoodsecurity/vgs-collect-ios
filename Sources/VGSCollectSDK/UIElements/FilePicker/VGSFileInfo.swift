//
//  VGSFileMetaData.swift
//  VGSCollectSDK
//
//  Created by Dima on 17.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

@objc
internal protocol VGSFileInfoProtocol {
    var fileExtension: String? { get }
    var size: Int { get }
    var sizeUnits: String? { get }
}

/// An object that holds optional files' metadata on selecting file through `VGSFilePickerController`.
public class VGSFileInfo: NSObject, VGSFileInfoProtocol {
    
    /// File extension, like "jpeg", "png", etc.
    ///
    /// - Note:
    ///     Returns the path extension of the file URL, or an empty string if the path is an empty string.
    public let fileExtension: String?
    
    /// File size.
    public let size: Int
    
    /// File size units.
    public let sizeUnits: String?
    
    required internal init(fileExtension: String, size: Int, sizeUnits: String) {
        self.fileExtension = fileExtension
        self.size = size
        self.sizeUnits = sizeUnits
    }
}
