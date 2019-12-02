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
            resultIcon = nil
        }
        
        return resultIcon
    }
}
