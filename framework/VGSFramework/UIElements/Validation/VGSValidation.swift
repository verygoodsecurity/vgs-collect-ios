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
        let resultRegEx = woSpace.matches(for: regex).count > 0
        let resultType = validateType(txt: txt, for: type)
        
        return resultRegEx && resultType
    }
}

extension String {
    func matches(for regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
