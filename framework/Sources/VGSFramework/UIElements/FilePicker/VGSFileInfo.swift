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

public class VGSFileInfo: NSObject, VGSFileInfoProtocol {
    public let fileExtension: String?
    public let size: Int
    public let sizeUnits: String?
    
    required public init(fileExtension: String, size: Int, sizeUnits: String) {
        self.fileExtension = fileExtension
        self.size = size
        self.sizeUnits = sizeUnits
    }
}