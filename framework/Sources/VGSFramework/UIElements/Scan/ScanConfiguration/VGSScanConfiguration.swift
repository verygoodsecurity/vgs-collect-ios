//
//  VGSScanConfiguration.swift
//  VGSFramework
//
//  Created by Dima on 06.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public protocol VGSScanConfigurationProtocol {
    var scanProvider: ScanProvider { get }
}

public struct VGSScanConfiguration: VGSScanConfigurationProtocol {
    
    public let scanProvider: ScanProvider
    
    public init(scanProvider: ScanProvider) {
        self.scanProvider = scanProvider
    }
}
