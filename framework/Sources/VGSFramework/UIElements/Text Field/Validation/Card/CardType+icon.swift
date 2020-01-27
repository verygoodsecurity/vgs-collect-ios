//
//  CardType+icon.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 27.11.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension SwiftLuhn.CardType {
    
    var brandIcon: UIImage? {
        let bundle = AssetsBundle.main.iconBundle
        
        var resultIcon: UIImage?
        switch self {
        case .visa:
            resultIcon = UIImage(named: "visa", in: bundle, compatibleWith: nil)
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
        case .jcb:
            resultIcon = UIImage(named: "jcb", in: bundle, compatibleWith: nil)
        default:
            resultIcon = UIImage(named: "unknown", in: bundle, compatibleWith: nil)
        }
        
        return resultIcon
    }
}

class AssetsBundle {
    static var main = AssetsBundle()
    var iconBundle: Bundle?
    
    init() {
        let containingBundle = Bundle(for: AssetsBundle.self)
        if let bundleURL = containingBundle.url(forResource: "CardIcon", withExtension: "bundle") {
            iconBundle = Bundle(url: bundleURL)
        } else {
            iconBundle = containingBundle
        }
    }
}
