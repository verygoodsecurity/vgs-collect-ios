//
//  VGSFilePickerController+internal.swift
//  VGSCollectSDK
//
//  Created by Dima on 17.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

internal protocol VGSFilePickerProtocol {
    var delegate: VGSFilePickerControllerDelegate? { get set }
    func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

internal extension VGSFilePickerController {
    
    /// Create specific type of picker instance
    func getFilePicker(_ fileSource: VGSFileSource) -> VGSFilePickerProtocol {
        switch fileSource {
        case .camera:
            return VGSImagePicker(configuration: configuration, sourceType: .camera)
        case .photoLibrary:
            return VGSImagePicker(configuration: configuration, sourceType: .photoLibrary)
        case .documentsDirectory:
            return VGSDocumentPicker(configuration: configuration)
        }
    }
}
