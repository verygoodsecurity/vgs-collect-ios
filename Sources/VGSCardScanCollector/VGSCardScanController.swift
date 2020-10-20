//
//  VGSCardScanController.swift
//  VGSCardScanCollector
//
//  Created by Dima on 18.08.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif

/// Controller responsible for managing CardScan scanner
public class VGSCardScanController {
    
    // MARK: - Attributes
    
    internal var scanHandler: VGSCardScanHandler?
    
    /// `VGSCardScanControllerDelegate` - handle user interaction with `CardScan` scanner
    public var delegate: VGSCardScanControllerDelegate? {
      set {
        scanHandler?.delegate = newValue
      }
      get {
        return scanHandler?.delegate
      }
    }
    
    // MARK: - Initialization
    /// Initialization
    ///
    /// - Parameters:
    ///   - delegate: `VGSCardScanControllerDelegate`. Default is `nil`.
    public required init(apiKey: String, delegate: VGSCardScanControllerDelegate? = nil) {
          
      self.scanHandler = VGSCardScanHandler(apiKey: apiKey)
      self.delegate = delegate
    }
    
    // MARK: - Methods
    
    /// Present `CardScan` scanner.
    /// - Parameters:
    ///   - viewController: `UIViewController` that will present card scanner.
    ///   - animated: pass `true` to animate the presentation; otherwise, pass `false`.
    ///   - completion: the block to execute after the presentation finishes.
    public func presentCardScanner(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        scanHandler?.presentScanVC(on: viewController, animated: animated, completion: completion)
    }
    
    /// Dismiss `CardScan` scanner.
    ///
    /// - Parameters:
    ///   - animated: pass `true` to animate the dismiss of presented viewcontroller; otherwise, pass `false`.
    ///   - completion: the block to execute after the dismiss finishes.
    public func dismissCardScanner(animated: Bool, completion: (() -> Void)?) {
        scanHandler?.dismissScanVC(animated: animated, completion: completion)
    }
  
    /// Check if CardScan can run on current device.
    static public func isCompatible() -> Bool {
      return VGSCardScanHandler.isCompatible()
    }
}
