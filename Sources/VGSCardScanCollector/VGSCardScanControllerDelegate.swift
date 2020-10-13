//
//  VGSCardScanControllerDelegate.swift
//  VGSCardScanCollector
//
//  Created by Dima on 31.08.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif

/// Supported scan data fields by CardScan
@objc
public enum CradScanDataType: Int {
    
    /// Credit Card Number. Digits string.
    case cardNumber
    
    /// Credit Card Expiration Date. String in format "01/21".
    case expirationDate
    
    /// Credit Card Expiration Month. String in format "01".
    case expirationMonth
    
    /// Credit Card Expiration Year. String in format "21".
    case expirationYear
  
    /// Credit Card Expiration Date. String in format "01/2021".
    case expirationDateLong
  
    /// Credit Card Expiration Year. String in format "2021".
    case expirationYearLong
  
    /// Card holder name displayed on card.
    case name
}

/// Delegates produced by `VGSCardScanController` instance.
@objc
public protocol VGSCardScanControllerDelegate {
    
    // MARK: - Handle user ineraction with `CardScan`
    
    /// On user confirm scanned data by selecting Done button on `CardScan` screen.
    @objc func userDidFinishScan()
    
    /// On user press Cancel buttonn on `CardScan` screen.
    @objc func userDidCancelScan()
    
    // MARK: - Manage scanned data
    
    /// Asks `VGSTextField` where scanned data with `VGSConfiguration.FieldType` need to be set. Called after user select Done button, just before userDidFinishScan() delegate.
    @objc func textFieldForScannedData(type: CradScanDataType) -> VGSTextField?
}

