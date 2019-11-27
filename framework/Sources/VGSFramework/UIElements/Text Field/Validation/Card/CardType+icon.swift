//
//  CardType+icon.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 27.11.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import Foundation

extension SwiftLuhn.CardType {
    
    internal var bundle: Bundle? {
        guard let bundleURL = Bundle(for: SwiftLuhn.self).url(forResource: "CardIcon", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
            return nil
        }
        return bundle
    }
    
    var brandIcon: UIImage? {
        if bundle == nil {
            print("\n\n! Bundle with card icons is absent\n\n")
            return nil
        }
        
        switch self {
        case .visa:
            return UIImage(named: "1", in: bundle, compatibleWith: nil)
            
        case .mastercard:
            return UIImage(named: "2", in: bundle, compatibleWith: nil)
            
        case .amex:
            return UIImage(named: "22", in: bundle, compatibleWith: nil)
            
        case .maestro:
            return UIImage(named: "3", in: bundle, compatibleWith: nil)
            
        case .discover:
            return UIImage(named: "14", in: bundle, compatibleWith: nil)
        default:
            return nil
        }
    }
}
