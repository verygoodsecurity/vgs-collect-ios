//
//  CardBrand+icon.swift
//  VGSCollectSDK
//

import Foundation
#if os(iOS)
import UIKit
#endif

@MainActor extension VGSPaymentCards.CardBrand {
    /// Default icon for unknown brand (used as fallback for unknown or custom brands without provided image).
    static var defaultUnknownBrandIcon = UIImage(named: "unknown", in: AssetsBundle.main.iconBundle, compatibleWith: nil)
  
    /// Default CVC icon for brands with 3-digit CVC.
    static var defaultCVCIcon3Digits = UIImage(named: "cvc3", in: AssetsBundle.main.iconBundle, compatibleWith: nil)
  
    /// Default CVC icon for brands with 4-digit CVC (e.g. Amex).
    static var defaultCVCIcon4Digits = UIImage(named: "cvc4", in: AssetsBundle.main.iconBundle, compatibleWith: nil)

    /// Current brand icon. Returns custom brand icon if supplied via `VGSPaymentCardModel.brandIcon`, otherwise default asset or unknown fallback.
    public var brandIcon: UIImage? {
      return VGSPaymentCards.availableCardBrands.first(where: { $0.brand == self })?.brandIcon ?? VGSPaymentCards.unknown.brandIcon
    }

    /// Current brand CVC helper icon. Returns custom icon if supplied via `VGSPaymentCardModel.cvcIcon`, otherwise default length-specific asset or unknown fallback.
    public var cvcIcon: UIImage? {
      return VGSPaymentCards.availableCardBrands.first(where: { $0.brand == self })?.cvcIcon ?? VGSPaymentCards.unknown.cvcIcon
    }

    /// Default brand icon resolved from bundled images based on brand value.
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
        case .custom:
          resultIcon = Self.defaultUnknownBrandIcon
        }
        return resultIcon
    }

    /// Default CVC icon resolved from bundled images based on brand's expected CVC length.
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

/// Internal helper for resolving image bundle for different integration methods (SPM, CocoaPods, Carthage).
internal class AssetsBundle {
    @MainActor static let main = AssetsBundle()
    var iconBundle: Bundle?

        /// Initializes and resolves the appropriate bundle containing card icons.
    init() {
            #if SWIFT_PACKAGE
                iconBundle = Bundle.module
            #endif

            guard iconBundle == nil else {
                return
            }

            let containingBundle = Bundle(for: AssetsBundle.self)

            if let bundleURL = containingBundle.url(forResource: "CardIcon", withExtension: "bundle") {
                iconBundle = Bundle(url: bundleURL)
            } else {
                iconBundle = containingBundle
            }
    }
}
