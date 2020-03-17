//
//  VGSFilePickerControllerDelegate.swift
//  VGSFramework
//
//  Created by Dima on 17.03.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Handle VGSFilePickerController states, get picked file info
@objc
public protocol VGSFilePickerControllerDelegate {
    
    /// On user select a file. `info` - an object that contains selected file metadata
    func userDidPickFileWithInfo(_ info: VGSFileInfo)
    
    /// On user canceling file picking
    func userDidSCancelFilePicking()
    
    /// On error occured when user pick a file. `error` - contains error details
    func filePickingFailedWithError(_ error: VGSError)
}
