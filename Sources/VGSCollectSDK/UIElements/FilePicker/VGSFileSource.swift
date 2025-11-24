//
//  ButtonType.swift
//  VGSCollectSDK
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
