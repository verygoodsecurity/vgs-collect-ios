//
//  VGSValidation+type.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/12/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

extension VGSValidation {
    func validateType(txt: String, for type: FieldType) -> Bool {        
        switch type {
        case .expDate:
            return validateExpDate(txt: txt)
        case .cvc:
            return validateCVC(txt: txt)
        default:
            return true
        }
    }
    
    // MARK: - Validate Date expiration
    private func validateExpDate(txt: String) -> Bool {
                
        guard txt.count == 4 else { return false }
                
        let mm = txt.prefix(2)
        let yy = txt.suffix(2)
        
        if yy.count < 2 { return false }
        
        let today = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yy"
        let todayYY = Int(formatter.string(from: today)) ?? 0
        
        formatter.dateFormat = "MM"
        let todayMM = Int(formatter.string(from: today)) ?? 0
        
        guard let inputMM = Int(mm), let inputYY = Int(yy) else {
            return false
        }
        
        if todayYY <= inputYY {
            return true
        } else if todayMM <= inputMM && todayYY <= inputYY {
            return true
        } else {
            return false
        }
    }
    
    private func validateCVC(txt: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: txt)
    }
}
