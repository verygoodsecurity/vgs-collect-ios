//
//  VGSFilePickerController.swift
//  VGSCollectSDK
//
//  Created by Dima on 14.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Controller responsible for importing files from device sources.
public class VGSFilePickerController {
    
    // MARK: - Attributes

    internal let configuration: VGSFilePickerConfiguration

    internal lazy var filePicker: VGSFilePickerProtocol = {
        return getFilePicker(configuration.fileSource)
    }()
    
    /// `VGSFilePickerControllerDelegate` - handle user interaction on file picking.
    public weak var delegate: VGSFilePickerControllerDelegate? {
        didSet {
            filePicker.delegate = delegate
        }
    }
    
    // MARK: - Initialization
    /// Initialization
    ///
    /// - Parameters:
    ///   - configuration: `VGSFilePickerConfiguration`
    public required init(configuration: VGSFilePickerConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Methods
    
    /// Present file picker view
    ///
    /// - Parameters:
    ///   - viewController: `UIViewController` that will present card scanner
    ///   - animated: pass `true` to animate the presentation; otherwise, pass `false`
    ///   - completion: the block to execute after the presentation finishes
    public func presentFilePicker(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        filePicker.present(on: viewController, animated: animated, completion: completion)
    }
    
    /// Dismiss file picker view
    ///
    /// - Parameters:
    ///   - animated: pass `true` to animate the dismiss of presented viewcontroller; otherwise, pass `false`
    ///   - completion: the block to execute after the dismiss finishes
    public func dismissFilePicker(animated: Bool, completion: (() -> Void)? = nil) {
        filePicker.dismiss(animated: animated, completion: completion)
    }
}
