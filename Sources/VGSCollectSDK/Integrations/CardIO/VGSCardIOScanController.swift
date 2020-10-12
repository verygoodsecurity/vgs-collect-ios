//
//  VGSCardIOScanController.swift
//  VGSCollectSDK
//
//  Created by Dima on 17.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import AVFoundation.AVCaptureDevice

#if canImport(UIKit)
import UIKit
#endif

internal protocol VGSScanHandlerProtocol {
    var delegate: VGSCardIOScanControllerDelegate? { get set }
    var cameraPosition: AVCaptureDevice.Position? { get set }
    var languageOrLocale: String? { get set }
    var disableManualEntryButtons: Bool { get set }
    var suppressScanConfirmation: Bool { get set }
    
    func presentScanVC(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismissScanVC(animated: Bool, completion: (() -> Void)?)
}

/// Controller responsible for managing Card.io scanner
public class VGSCardIOScanController {
    
    // MARK: - Attributes
    
    internal var scanHandler: VGSScanHandlerProtocol?
    
    /// `VGSCardIOScanControllerDelegate` - handle user interaction with `Card.io` scanner
    public var delegate: VGSCardIOScanControllerDelegate? {
        set {
          scanHandler?.delegate = newValue
        }
        get {
          return scanHandler?.delegate
        }
    }
    
    /// Defines preferred `AVCaptureDevice.Position`. Deault is `AVCaptureDevice.Position.unspecified`
    public var preferredCameraPosition: AVCaptureDevice.Position? {
        didSet {
            scanHandler?.cameraPosition = preferredCameraPosition
        }
    }

    /// If `true`, user don't have to confirm the scanned card, just return the results immediately.
    /// Defaults is `false`.
    public var suppressScanConfirmation: Bool = false {
      didSet {
          scanHandler?.suppressScanConfirmation = suppressScanConfirmation
      }
    }
  
    /// Defines preferred language for all strings appearing in the CardIO user interface.
    /// If not set, or if set to nil, defaults to the device's current language setting.
    public var languageOrLocale: String? = nil {
        didSet {
            scanHandler?.languageOrLocale = languageOrLocale
        }
    }
  
    /// Set to `true` to prevent CardIO from showing its "Enter Manually" button. Defaults to `false`.
    public var disableManualEntryButtons: Bool = false {
        didSet {
            scanHandler?.disableManualEntryButtons = disableManualEntryButtons
        }
    }
    
    // MARK: - Initialization
    /// Initialization
    ///
    /// - Parameters:
    ///   - delegate: `VGSCardIOScanControllerDelegate`. Default is `nil`.
    public required init(_ delegate: VGSCardIOScanControllerDelegate? = nil) {
        #if canImport(CardIO)
            self.scanHandler = VGSCardIOHandler()
            self.delegate = delegate
        #else
            print("Can't import CardIO. Please check that CardIO submodule is installed")
            return
        #endif
    }
    
    // MARK: - Methods
    
    /// Present `Card.io` scanner.
    /// - Parameters:
    ///   - viewController: `UIViewController` that will present card scanner.
    ///   - animated: pass `true` to animate the presentation; otherwise, pass `false`.
    ///   - completion: the block to execute after the presentation finishes.
    public func presentCardScanner(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        scanHandler?.presentScanVC(on: viewController, animated: animated, completion: completion)
    }
    
    /// Dismiss `Card.io` scanner.
    /// 
    /// - Parameters:
    ///   - animated: pass `true` to animate the dismiss of presented viewcontroller; otherwise, pass `false`.
    ///   - completion: the block to execute after the dismiss finishes.
    public func dismissCardScanner(animated: Bool, completion: (() -> Void)?) {
        scanHandler?.dismissScanVC(animated: animated, completion: completion)
    }
}
