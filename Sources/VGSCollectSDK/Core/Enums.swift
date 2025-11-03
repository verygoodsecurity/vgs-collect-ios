//
//  Enums.swift
//  VGSCollectSDK
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
    
    /// Field type that requires Date input formatting and validation.
    case date
    
    /// Field type that requires Credit Card CVC input formatting and validation.
    case cvc
    
    /// Field type that requires Cardholder Name input formatting and validation.
    case cardHolderName
  
    /// Field type that requires US Social Security Number input formatting and validation.
    case ssn
}

/// Type of `VGSTextField` input source.
public enum VGSTextFieldInputSource {
  
  /// UIKeyboard input type.
  case keyboard
  
  /// UIDatePicker input type.
  case datePicker
}

@MainActor
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
        case .date:
            return VGSDateFormat.default.formatPattern
        default:
            return ""
        }
    }
    
    var defaultDivider: String {
      switch self {
      case .expDate, .date:
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
        case .date:
            return "^([0-9]{4}|[0-9]{2})\\/?([0-9]{2})\\/?([0-9]{4}|[0-9]{2})$"
        case .cardHolderName:
            return "^([a-zA-Z0-9\\ \\,\\.\\-\\']{2,})$"
        case .ssn:
            return "^(?!(000|666|9))(\\d{3}(-|\\s)?(?!(00))\\d{2}(-|\\s)?(?!(0000))\\d{4})$"
        case .cvc:
          return "\\d*$"
        case .none:
          return ""
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .cardNumber, .cvc, .expDate, .date, .ssn:
            return .asciiCapableNumberPad
        default:
            return .alphabet
        }
    }
    
    /// Default field text content type for `FieldType`
    var textContentType: UITextContentType? {
        switch self {
        case .cardNumber:
            return .creditCardNumber
        case .cardHolderName:
            if #available(iOS 17, *) {
                return .creditCardName
            }
            return .name
        case .cvc:
            if #available(iOS 17, *) {
                return .creditCardSecurityCode
            }
        case .expDate:
            if #available(iOS 17.0, *) {
                return .creditCardExpiration
            }
        default:
            return nil
        }
        return nil
    }
  
    var defaultValidation: VGSValidationRuleSet {
      var rules = VGSValidationRuleSet()
      switch self {
      case .cardHolderName, .ssn:
        rules.add(rule: VGSValidationRulePattern(pattern: self.defaultRegex, error: VGSValidationErrorType.pattern.rawValue))
      case .expDate:
        rules.add(rule: VGSValidationRulePattern(pattern: self.defaultRegex, error: VGSValidationErrorType.pattern.rawValue))
        rules.add(rule: VGSValidationRuleCardExpirationDate(error: VGSValidationErrorType.expDate.rawValue))
      case .date:
        rules.add(rule: VGSValidationRulePattern(pattern: self.defaultRegex, error: VGSValidationErrorType.pattern.rawValue))
        rules.add(rule: VGSValidationRuleDateRange(error: VGSValidationErrorType.date.rawValue))
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
  
    // String identifier for each field type. Can be used for analytics, etc.
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
      case .date:
         return "date"
      case .ssn:
         return "ssn"
      case .none:
         return "text"
      }
    }
  
  // field types with sensitive data that should not ignore tokenization.
  var sensitive: Bool {
    switch self {
    case .cardNumber, .cvc:
      return true
    default:
      return false
    }
  }
}

internal enum DateFormatPattern: String {
    case shortYear = "##/##"
    case longYear = "##/####"
}
