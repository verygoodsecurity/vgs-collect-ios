//
//  CardBrand+default.swift
//  VGSCollectSDK
//
//  Created by Dima on 10.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Default CardBrand settings
internal extension VGSPaymentCards.CardBrand {
  
  /// Returns regex for specific card brand detection
  var defaultRegex: String {
      switch self {
      case .amex:
          return "^3[47]\\d*$"
      case .dinersClub:
          return "^3(?:[689]|(?:0[059]+))\\d*$"
      case .discover:
          return "^(6011|65|64[4-9]|622)\\d*$"
      case .unionpay:
          return "^62\\d*$"
      case .jcb:
          return "^35\\d*$"
      case .mastercard:
          return  "^(5[1-5]|677189)\\d*$|^(222[1-9]|2[3-6]\\d{2,}|27[0-1]\\d|2720)([0-9]{2,})\\d*$"
      case .visaElectron:
          return "^4(026|17500|405|508|844|91[37])\\d*$"
      case .visa:
          return "^4\\d*$"
      case .maestro:
          return "^(5018|5020|5038|56|57|58|6304|6390[0-9]{2,}|67[0-9]{4,})\\d*$"
      case .forbrugsforeningen:
        return "^600\\d*$"
      case .dankort:
        return "^5019\\d*$"
      case .elo:
        return "^(4011(78|79)|43(1274|8935)|45(1416|7393|763(1|2))|50(4175|6699|67[0-7][0-9]|9000)|627780|63(6297|6368)|650(03([^4])|04([0-9])|05(0|1)|4(0[5-9]|3[0-9]|8[5-9]|9[0-9])|5([0-2][0-9]|3[0-8])|9([2-6][0-9]|7[0-8])|541|700|720|901)|651652|655000|655021)\\d*$"
      case .hipercard:
        return "^(384100|384140|384160|606282|637095|637568|60(?!11))\\d*$"
      case .unknown:
         return "^\\d*$"
      case .custom(brandName: _):
          return ""
      }
  }
  
  var defaultCardLengths: [Int] {
        switch self {
        case .amex:
            return [15]
        case .dinersClub:
            return [14, 16]
        case .discover:
            return [16]
        case .unionpay:
            return [16, 17, 18, 19]
        case .jcb:
            return [16, 17, 18, 19]
        case .mastercard:
            return [16]
        case .visaElectron:
            return [16]
        case .visa:
            return [13, 16, 19]
        case .maestro:
            return [12, 13, 14, 15, 16, 17, 18, 19]
        case .elo:
          return [16]
        case .forbrugsforeningen:
          return [16]
        case .dankort:
          return [16]
        case .hipercard:
          return [14, 15, 16, 17, 18, 19]
        case .unknown:
            return [16, 17, 18, 19]
        case .custom(brandName: _):
          return []
        }
    }
  
    var defaultCVCLengths: [Int] {
        switch self {
        case .amex:
            return [4]
        case .unknown:
            return [3, 4]
        default:
          return [3]
        }
    }
  
    var cvcFormatPattern: String {
      var maxLength = 0
      if let cardBrand = VGSPaymentCards.availableCardBrands.first(where: { $0.brand == self }) {
        maxLength = cardBrand.cvcLengths.max() ?? 0
      } else {
        maxLength = VGSPaymentCards.unknown.cvcLengths.max() ?? 0
      }
      return String(repeating: "#", count: maxLength)
    }
  
    var defaultFormatPattern: String {
      switch self {
      case .amex:
        return "#### ###### #####"
      case .dinersClub:
        return "#### ###### ######"
      default:
        return "#### #### #### #### ###"
      }
    }
  
    var defaultName: String {
        switch self {
        case .amex:
            return "American Express"
        case .visa:
            return "Visa"
        case .visaElectron:
            return "Visa Electron"
        case .mastercard:
            return "Mastercard"
        case .discover:
            return "Discover"
        case .dinersClub:
            return "Diners Club"
        case .unionpay:
            return "UnionPay"
        case .jcb:
            return "JCB"
        case .maestro:
            return "Maestro"
        case .elo:
          return "ELO"
        case .forbrugsforeningen:
          return "Forbrugsforeningen"
        case .dankort:
          return "Dankort"
        case .hipercard:
          return "HiperCard"
        case .unknown:
          return "Unknown"
        case .custom(brandName: _):
          return ""
        }
    }
  
    var defaultCheckSumAlgorithm: CheckSumAlgorithmType? {
      switch self {
      case .unionpay:
        return nil
      default:
        return .luhn
      }
    }
}
