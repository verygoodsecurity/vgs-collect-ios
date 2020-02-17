//
//  VGSFilePickerController.swift
//  VGSFramework
//
//  Created by Dima on 14.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

@objc
public protocol VGSFilePickerControllerDelegate {
    @objc func userDidPickFileWithInfo(_ info: [String: Any])
    @objc func userDidSCancelFilePicking()
    @objc optional func filePickingFailedWithError(_ error: String)
}

public class VGSFilePickerController {
    
    public weak var delegate: VGSFilePickerControllerDelegate? {
        didSet {
            filePicker.delegate = delegate
        }
    }

    internal let configuration: VGSFilePickerConfiguration
    internal lazy var filePicker: VGSFilePickerProtocol = {
        return getFilePicker(configuration.fileSource)
    }()
    
    public required init(configuration: VGSFilePickerConfiguration) {
        self.configuration = configuration
    }
    
    public func presentFilePicker(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        filePicker.present(on: viewController, animated: animated, completion: completion)
    }
    
    public func dismissFilePicker(animated: Bool, completion: (() -> Void)? = nil) {
        filePicker.dismiss(animated: animated, completion: completion)
    }
}
