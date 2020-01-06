//
//  VGSScanProviderFactory.swift
//  VGSFramework
//
//  Created by Dima on 06.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal class VGSScanProviderFactory {
    
    static func getScanProviderInstance(_ provider: ScanProvider) -> VGSScanProviderProtocol? {
        switch  provider {
        case .cardIO:
            return nil
        case .cardScan:
            return getCardScanProxy()
        }
    }
    
    private static func getCardScanProxy() -> VGSScanProviderProtocol? {
        #if canImport(CardScan)
            return VGSCardScanProxy()
        #else
            return nil
        #endif
    }
}
