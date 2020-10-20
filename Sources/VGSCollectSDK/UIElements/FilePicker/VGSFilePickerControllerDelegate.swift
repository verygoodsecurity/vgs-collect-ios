//
//  VGSFilePickerControllerDelegate.swift
//  VGSCollectSDK
//
//  Created by Dima on 17.03.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Delegates produced by VGSFilePickerController.
@objc
public protocol VGSFilePickerControllerDelegate {
    
    // MARK: - Handle user ineraction.
    
    /// On user select a file
    ///
    /// - Parameters:
    ///  - info: selected file metadata info.
    func userDidPickFileWithInfo(_ info: VGSFileInfo)
    
    /// On user canceling file picking
    func userDidSCancelFilePicking()
    
    /// On error occured when user pick a file.
    ///
    /// - Parameters:
    ///  - error: contains `VGSError` details.
    func filePickingFailedWithError(_ error: VGSError)
}
