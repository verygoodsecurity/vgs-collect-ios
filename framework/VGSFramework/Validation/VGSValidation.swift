//
//  VGSValidation.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public class VGSValidation {
    var pattern: String?
    
    func isValid(_ txt: String, type: FieldType?) -> Bool {
        guard txt.count != 0, let regex = pattern else {
            return false
        }
        let woSpace = txt.replacingOccurrences(of: " ", with: "")
        let resultRegEx = matches(for: regex, in: woSpace).count > 0
        let resultType = validateType(txt: txt, for: type)
        
        return resultRegEx && resultType
    }
}

extension VGSValidation {
    static func defaultValidationModel() -> VGSValidation {
        return VGSValidation()
    }
}

extension VGSValidation {
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
