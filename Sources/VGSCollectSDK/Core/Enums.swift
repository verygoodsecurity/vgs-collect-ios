//
//  Enums.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

/// Organization vault environment.
public enum Environment: String {
    
    /// Should be used for development and testing purpose.
    case sandbox
    
    /// Should be used for production.
    case live
}

/// Type of `VGSTextField` configuration.
public enum FieldType: Int, CaseIterable {
    
    /// Field type that doesn't require any input formatting and validation.
    case none
    
    /// Field type that requires Credit Card Number input formatting and validation.
    case cardNumber
    
    /// Field type that requires Expiration Date input formatting and validation.
    case expDate
    
    /// Field type that requires Credit Card CVC input formatting and validation.
    case cvc
    
    /// Field type that requires Cardholder Name input formatting and validation.
    case cardHolderName
  
    /// Field type that requires US Social Security Number input formatting and validation.
    case ssn
}

internal extension FieldType {
    
    var defaultFormatPattern: String {
        switch self {
        case .cardNumber:
            return "#### #### #### ####"
        case .cvc:
            return "####"
        case .expDate:
            return DateFormatPattern.shortYear.rawValue
        case .ssn:
            return "###-##-####"
        default:
            return ""
        }
    }
    
    var defaultDivider: String {
      switch self {
      case .expDate:
        return "/"
      case .ssn:
        return "-"
      default:
        return ""
      }
    }
    
   var defaultRegex: String {
        switch self {
        case .cardNumber:
            return "^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\\d{3})\\d{11})$"
        case .expDate:
            return "^(0[1-9]|1[0-2])\\/?([0-9]{4}|[0-9]{2})$"
        case .cardHolderName:
            return "^([a-zA-Z0-9\\ \\,\\.\\-\\']{2,})$"
        case .ssn:
            return
          "^(?!\\b(\\d)\\1+\\b)(?!(123456789|219099999|078051120|457555462))(?!(000|666|9))(\\d{3}-?(?!(00))\\d{2}-?(?!(0000))\\d{4})$"
        case .cvc:
          return "\\d*$"
        case .none:
          return ""
      }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .cardNumber, .cvc, .expDate, .ssn:
            return .asciiCapableNumberPad
        default:
            return .alphabet
        }
    }
  
    var defaultValidation: VGSValidationRuleSet {
      var rules = VGSValidationRuleSet()
      switch self {
      case .cardHolderName, .ssn:
        rules.add(rule: VGSValidationRulePattern(pattern: self.defaultRegex, error: VGSValidationErrorType.pattern.rawValue))
      case .expDate:
        rules.add(rule: VGSValidationRulePattern(pattern: self.defaultRegex, error: VGSValidationErrorType.pattern.rawValue))
        rules.add(rule: VGSValidationRuleCardExpirationDate(error: VGSValidationErrorType.expDate.rawValue))
      case .cardNumber:
        rules.add(rule: VGSValidationRulePaymentCard(error: VGSValidationErrorType.cardNumber.rawValue))
      case .cvc:
        rules.add(rule: VGSValidationRulePattern(pattern: self.defaultRegex, error: VGSValidationErrorType.pattern.rawValue))
        rules.add(rule: VGSValidationRuleLengthMatch(lengths: [3, 4], error: VGSValidationErrorType.lengthMathes.rawValue))
      case .none:
        rules = VGSValidationRuleSet()
      }
      return rules
    }
  
    // String idetifier for each  field type. Can be used for ananlytics, etc.
    var stringIdentifier: String {
      switch self {
      case .cardHolderName:
        return "card-holder-name"
      case .cardNumber:
         return "card-number"
      case .cvc:
         return "card-security-code"
      case .expDate:
         return "card-expiration-date"
      case .ssn:
         return "ssn"
      case .none:
         return "text"
      }
    }
}

internal enum DateFormatPattern: String {
    case shortYear = "##/##"
    case longYear = "##/####"
}
