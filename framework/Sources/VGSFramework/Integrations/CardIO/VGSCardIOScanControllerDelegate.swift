//
//  VGSCardIOScanControllerDelegate.swift
//  VGSFramework
//
//  Created by Dima on 20.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Supported field types by CardIO
@objc
public enum CradIODataType: Int {
    case cardNumber         // 16 digits string
    case expirationDate     // "01/21"
    case expirationMonth    // "01"
    case expirationYear     // "21"
    case cvc                // "123"
}

/// Handle CardIO states, set VGSTextField with Scanned data
@objc
public protocol VGSCardIOScanControllerDelegate {
    
    /// On user confirm scanned data by selecting Done button on CardIO screen
    @objc optional func userDidFinishScan()
    
    /// On user pressing Cancel buttonn on CardIO screen
    @objc optional func userDidCancelScan()
    
    /// Asks VGSTextField where scanned data with type need to be set. Called after user select Done button, just before userDidFinishScan() delegate.
    @objc func textFieldForScannedData(type: CradIODataType) -> VGSTextField?
}
