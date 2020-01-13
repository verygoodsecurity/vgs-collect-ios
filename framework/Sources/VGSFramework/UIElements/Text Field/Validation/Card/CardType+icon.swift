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
            resultIcon = UIImage(named: "1", in: bundle, compatibleWith: nil)
            
        case .mastercard:
            resultIcon = UIImage(named: "2", in: bundle, compatibleWith: nil)
            
        case .amex:
            resultIcon = UIImage(named: "22", in: bundle, compatibleWith: nil)
            
        case .maestro:
            resultIcon = UIImage(named: "3", in: bundle, compatibleWith: nil)
            
        case .discover:
            resultIcon = UIImage(named: "14", in: bundle, compatibleWith: nil)
        default:
            resultIcon = UIImage(named: "0", in: bundle, compatibleWith: nil)
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
