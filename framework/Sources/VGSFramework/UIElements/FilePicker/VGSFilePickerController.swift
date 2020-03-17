//
//  VGSFilePickerController.swift
//  VGSFramework
//
//  Created by Dima on 14.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Controller responsible for managing files import
public class VGSFilePickerController {
    
    internal let configuration: VGSFilePickerConfiguration

    internal lazy var filePicker: VGSFilePickerProtocol = {
        return getFilePicker(configuration.fileSource)
    }()
    
    /// VGSFilePickerControllerDelegate - handle states on file picking
    public weak var delegate: VGSFilePickerControllerDelegate? {
        didSet {
            filePicker.delegate = delegate
        }
    }
    
    /// Initialization
    ///
    /// - Parameters:
    ///   - configuration: VGSFilePickerConfiguration
    public required init(configuration: VGSFilePickerConfiguration) {
        self.configuration = configuration
    }
    
    /// Present file picker view
    public func presentFilePicker(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        filePicker.present(on: viewController, animated: animated, completion: completion)
    }
    
    /// Dismiss file picker view
    public func dismissFilePicker(animated: Bool, completion: (() -> Void)? = nil) {
        filePicker.dismiss(animated: animated, completion: completion)
    }
}
