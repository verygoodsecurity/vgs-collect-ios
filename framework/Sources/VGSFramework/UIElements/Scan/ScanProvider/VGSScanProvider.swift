//
//  VGSScanProvider.swift
//  VGSFramework
//
//  Created by Dima on 06.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum ScanProvider {
    case cardIO
}

internal protocol VGSScanProviderProtocol {
    var delegate: VGSScanControllerDelegate? { get set }
    func presentScan(from viewController: UIViewController)
    func dismissScan(animated: Bool, completion: (() -> Void)?)
}
