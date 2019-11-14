//
//  CardBrand.swift
//  Alamofire
//
//  Created by Vitalii Obertynskyi on 9/15/19.
//

import Foundation

public enum CardBrand: String, CaseIterable {
    case unknown
    case visa
    case mastercard
    case maestro
    case amex
}

extension CardBrand {
    var patter: String {
        switch self {
        case .amex:
            return "^(3[47][0-9]{13})$"
        case .mastercard:
            return "^(5[1-5][0-9]{14}|2(22[1-9][0-9]{12}|2[3-9][0-9]{13}|[3-6][0-9]{14}|7[0-1][0-9]{13}|720[0-9]{12}))$"
        case .maestro:
            return "^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$"
        case .visa:
            return "^4[0-9]{12}(?:[0-9]{3})?$"
        default:
            return ""
        }
    }
}
