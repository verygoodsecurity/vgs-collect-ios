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

internal protocol VGSScanProxyProtocol {
    var delegate: VGSScanControllerDelegate? { get set }
    func presentScanVC(from viewController: UIViewController, animated: Bool, completion: (() -> Void?))
    func pushScanVC(from viewController: UIViewController, animated: Bool)
    func dismissScanVC(animated: Bool, completion: (() -> Void)?)
}

public class VGSCardIOScanController {
    
    internal var scanHandler: VGSScanProxyProtocol?
    
    required init(delegate: VGSScanControllerDelegate) {
        #if canImport(CardIO)
        self.scanHandler = VGSCardIOHandler()
        #else
        print("Can't import CardIO. Please check that CardIO submodule is installed")
        return
        #endif
        scanHandler?.delegate = delegate
    }
    
    func presentScan(from viewController: UIViewController, animated: Bool, completion: (() -> Void?)) {
        scanHandler?.presentScanVC(from: viewController, animated: animated, completion: completion)
    }
    
    func pushScanVC(from viewController: UIViewController, animated: Bool) {
        scanHandler?.pushScanVC(from: viewController, animated: animated)
    }
    
    func dismissScanVC(animated: Bool, completion: (() -> Void)?) {
        scanHandler?.dismissScanVC(animated: animated, completion: completion)
    }
}
