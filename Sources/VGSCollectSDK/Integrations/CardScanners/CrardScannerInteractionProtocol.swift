//
//  CrardScannerInteractionProtocol.swift
//  VGSCollectSDK
//
//  Created by Dima on 28.08.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
public protocol VGSScanHandlerProtocol {
//    var delegate: VGSCardScanControllerDelegate? { get set }
//    var cameraPosition: AVCaptureDevice.Position? { get set }
    
    func presentScanVC(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismissScanVC(animated: Bool, completion: (() -> Void)?)
}
