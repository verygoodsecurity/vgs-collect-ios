//
//  VGSBlinkCardControllerDelegate.swift
//  VGSBlinkCardCollector
//

import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif
#if os(iOS)
import UIKit
#endif

/// Supported scan data fields by BlinkCard.
@objc
public enum VGSBlinkCardDataType: Int, CaseIterable {
    
    /// Credit Card Number. Digits string.
    case cardNumber
  
    /// Card holder name displayed on card.
    case name
  
    /// Card cvc.
    case cvc
    
    /// Credit Card Expiration Date. String in format "mm/yy", e.g: "01/21".
    case expirationDate
    
    /// Credit Card Expiration Month. String in format "mm", e.g:"01".
    case expirationMonth
    
    /// Credit Card Expiration Year. String in format "yy", e.g: "21".
    case expirationYear
  
    /// Credit Card Expiration Year. String in format "yyyy", e.g:"2021".
    case expirationYearLong
  
    /// Credit Card Expiration Date. String in format "mm/yyyy", e.g:"01/2021".
    case expirationDateLong
    
    /// Credit Card Expiration Date. String in format "yy/mm", e.g:"21/01".
    case expirationDateShortYearThenMonth

    /// Credit Card Expiration Date. String in format "yyyy/mm", e.g:"2021/01".
    case expirationDateLongYearThenMonth
}

/// Delegates produced by `VGSBlinkCardController` instance.
@objc
public protocol VGSBlinkCardControllerDelegate {
    
    // MARK: - Handle user ineraction with `BlinkCard`
    
    /// On user confirm scanned data by selecting Done button on `BlinkCard` screen.
    @objc func userDidFinishScan()
    
    /// On user press Cancel buttonn on `BlinkCard` screen.
    @objc func userDidCancelScan()
    
    // MARK: - Manage scanned data
    
    /// Asks `VGSTextField` where scanned data with `VGSConfiguration.FieldType` need to be set. Called after user select Done button, just before userDidFinishScan() delegate.
    @objc func textFieldForScannedData(type: VGSBlinkCardDataType) -> VGSTextField?
}
