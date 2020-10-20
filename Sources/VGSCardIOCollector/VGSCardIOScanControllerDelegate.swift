//
//  VGSCardIOScanControllerDelegate.swift
//  VGSCollectSDK
//
//  Created by Dima on 20.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif

/// Supported scan data fields by Card.io
@objc
public enum CradIODataType: Int {
    
    /// Credit Card Number. 16 digits string.
    case cardNumber
    
    /// Credit Card Expiration Date. String in format "01/21".
    case expirationDate
    
    /// Credit Card Expiration Month. String in format "01".
    case expirationMonth
    
    /// Credit Card Expiration Year. String in format "21".
    case expirationYear
    
    /// Credit Card CVC code. 3-4 digits string in format "123".
    case cvc
  
    /// Credit Card Expiration Date. String in format "01/2021".
    case expirationDateLong
  
    /// Credit Card Expiration Year. String in format "2021".
    case expirationYearLong
}

/// Delegates produced by `VGSCardIOScanController` instance.
@objc
public protocol VGSCardIOScanControllerDelegate {
    
    // MARK: - Handle user ineraction with `Card.io`
    
    /// On user confirm scanned data by selecting Done button on `Card.io` screen.
    @objc func userDidFinishScan()
    
    /// On user press Cancel buttonn on `Card.io` screen.
    @objc func userDidCancelScan()
    
    // MARK: - Manage scanned data
    
    /// Asks `VGSTextField` where scanned data with `VGSConfiguration.FieldType` need to be set. Called after user select Done button, just before userDidFinishScan() delegate.
    @objc func textFieldForScannedData(type: CradIODataType) -> VGSTextField?
}
