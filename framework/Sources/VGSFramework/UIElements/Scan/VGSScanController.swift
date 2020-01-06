//
//  VGSScanController.swift
//  VGSFramework
//
//  Created by Dima on 06.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

@objc public protocol VGSScanControllerDelegate {
    @objc optional func userDidFinishScan()
    @objc optional func userDidCancelScan()
    @objc optional func userDidSkipScan()
    @objc optional func getFormForScanedField(name: String) -> VGSTextField?
}
  
public class VGSScanController {
    internal var scanProvider: VGSScanProviderProtocol?
        
    public init(with configuration: VGSScanConfigurationProtocol, delegate: VGSScanControllerDelegate) {
        guard let provider = VGSScanProviderFactory.getScanProviderInstance(configuration.scanProvider) else {
            assertionFailure("Failed to import \(configuration.scanProvider). Check that module is installed")
            return
        }
        self.scanProvider = provider
        self.scanProvider?.delegate = delegate
    }

    public func presentScan(from viewController: UIViewController) {
        scanProvider?.presentScan(from: viewController)
    }

    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        scanProvider?.dismissScan(animated: animated, completion: completion)
    }
}
