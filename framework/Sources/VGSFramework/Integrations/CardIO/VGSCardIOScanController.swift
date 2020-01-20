//
//  VGSCardIOScanController.swift
//  VGSFramework
//
//  Created by Dima on 17.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

internal protocol VGSScanHandlerProtocol {
    var delegate: VGSCardIOScanControllerDelegate? { get set }
    func presentScanVC(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismissScanVC(animated: Bool, completion: (() -> Void)?)
}

public class VGSCardIOScanController {
    
    internal var scanHandler: VGSScanHandlerProtocol?
    
    /// VGSCardIOScanControllerDelegate - handle CardIO states
    public var delegate: VGSCardIOScanControllerDelegate? {
        didSet {
            scanHandler?.delegate = delegate
        }
    }
    
    public required init(_ delegate: VGSCardIOScanControllerDelegate? = nil) {
        #if canImport(CardIO)
            self.scanHandler = VGSCardIOHandler()
            self.delegate = delegate
        #else
            print("Can't import CardIO. Please check that CardIO submodule is installed")
            return
        #endif
    }
    
    /// Present CardIO scan controller
    public func presentCardScanner(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        scanHandler?.presentScanVC(on: viewController, animated: animated, completion: completion)
    }
    
    /// Dismiss CardIO scan controller
    public func dismissCardScanner(animated: Bool, completion: (() -> Void)?) {
        scanHandler?.dismissScanVC(animated: animated, completion: completion)
    }
}
