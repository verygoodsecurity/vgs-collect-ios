//
//  CardBrand+icon.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 27.11.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

extension VGSPaymentCards.CardBrand {
    static var defaultUnknownBrandIcon = UIImage(named: "unknown", in: AssetsBundle.main.iconBundle, compatibleWith: nil)
  
    static var defaultCVCIcon3Digits = UIImage(named: "cvc3", in: AssetsBundle.main.iconBundle, compatibleWith: nil)
  
    static var defaultCVCIcon4Digits = UIImage(named: "cvc4", in: AssetsBundle.main.iconBundle, compatibleWith: nil)
  
    var brandIcon: UIImage? {
      return VGSPaymentCards.availableCardBrands.first(where: { $0.brand == self })?.brandIcon ?? VGSPaymentCards.unknown.brandIcon
    }
  
    var cvcIcon: UIImage? {
      return VGSPaymentCards.availableCardBrands.first(where: { $0.brand == self })?.cvcIcon ?? VGSPaymentCards.unknown.cvcIcon
    }

    var defaultBrandIcon: UIImage? {
        let bundle = AssetsBundle.main.iconBundle
        
        var resultIcon: UIImage?
        switch self {
        case .visa:
            resultIcon = UIImage(named: "visa", in: bundle, compatibleWith: nil)
        case .visaElectron:
            resultIcon = UIImage(named: "visaElectron", in: bundle, compatibleWith: nil)
        case .mastercard:
            resultIcon = UIImage(named: "mastercard", in: bundle, compatibleWith: nil)
        case .amex:
            resultIcon = UIImage(named: "amex", in: bundle, compatibleWith: nil)
        case .maestro:
            resultIcon = UIImage(named: "maestro", in: bundle, compatibleWith: nil)
        case .discover:
            resultIcon = UIImage(named: "discover", in: bundle, compatibleWith: nil)
        case .dinersClub:
            resultIcon = UIImage(named: "dinersClub", in: bundle, compatibleWith: nil)
        case .unionpay:
            resultIcon = UIImage(named: "unionPay", in: bundle, compatibleWith: nil)
        case .jcb:
            resultIcon = UIImage(named: "jcb", in: bundle, compatibleWith: nil)
        case .elo:
            resultIcon = UIImage(named: "elo", in: bundle, compatibleWith: nil)
        case .forbrugsforeningen:
          resultIcon = UIImage(named: "forbrugsforeningen", in: bundle, compatibleWith: nil)
        case .dankort:
          resultIcon = UIImage(named: "dankort", in: bundle, compatibleWith: nil)
        case .hipercard:
          resultIcon = UIImage(named: "hipercard", in: bundle, compatibleWith: nil)
        case .unknown:
          resultIcon = Self.defaultUnknownBrandIcon
        case .custom(brandName: _):
          resultIcon = Self.defaultUnknownBrandIcon
        }
        return resultIcon
    }
  
    var defaultCVCIcon: UIImage? {
        var resultIcon: UIImage?
        switch self {
        case .amex:
          resultIcon = Self.defaultCVCIcon4Digits
        default:
          resultIcon = Self.defaultCVCIcon3Digits
        }
        return resultIcon
    }
}

internal class AssetsBundle {
    static var main = AssetsBundle()
    var iconBundle: Bundle?
    
    init() {
			// Identify bundle for SPM.
			#if SWIFT_PACKAGE
				iconBundle = Bundle.module
			#endif

			// Return if bundle is found.
			guard iconBundle == nil else {
				return
			}

			let containingBundle = Bundle(for: AssetsBundle.self)

			// Look for CardIcon bundle (handle CocoaPods integration).
			if let bundleURL = containingBundle.url(forResource: "CardIcon", withExtension: "bundle") {
				iconBundle = Bundle(url: bundleURL)
			} else {
				// Icon bundle matches containing bundle (Carthage integration).
				iconBundle = containingBundle
			}
    }
}
