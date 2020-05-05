//
//  VGSValidation.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

internal class VGSValidation {
    var regex: String = ""
    var isLongDateFormat = false
    
    func isValid(_ txt: String, type: FieldType) -> Bool {
        if type == .none { return true }
        
        guard txt.count != 0, regex.count != 0 else {
            return false
        }
        let resultRegEx = txt.matches(for: regex).count > 0
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
