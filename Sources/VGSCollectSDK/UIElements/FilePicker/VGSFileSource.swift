//
//  ButtonType.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 11.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Available file source destinations that `VGSFilePickerController` can work with.
public enum VGSFileSource: Int, CaseIterable {
    
    /// Device photo library.
    case photoLibrary
    
    /// Device camera.
    case camera
    
    /// Device documents directory.
    case documentsDirectory
}
