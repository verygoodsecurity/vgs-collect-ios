//
//  ButtonType.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 11.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// VGS file source type
public enum VGSFileSource: Int, CaseIterable {
    
    /// Device photo library
    case photoLibrary
    
    /// Device camera
    case camera
    
    /// Device documents directory
    case documentsDirectory
}
