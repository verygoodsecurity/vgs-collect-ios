//
//  VGSValidationError.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// VGS Validation Error object type
public typealias VGSValidationError = String

/// Default validation error types
public enum VGSValidationErrorType: String {
  /// Default Validation error for `VGSValidationRulePattern`
  case pattern = "PATTERN_VALIDATION_ERROR"
  
  /// Default Validation error for `VGSValidationRuleLength`
  case length = "LENGTH_VALIDATION_ERROR"
  
  /// Default Validation error for `VGSValidationRuleLength`
  case lengthMathes = "LENGTH_RANGE_MATCH_VALIDATION_ERROR"
  
  /// Default Validation error for `VGSValidationRuleCardExpirationDate`
  case expDate = "EXPIRATION_DATE_VALIDATION_ERROR"
  
  /// Default Validation error for `VGSValidationRulePaymentCard`
  case cardNumber = "CARD_NUMBER_VALIDATION_ERROR"
  
  /// Default Validation error for `VGSValidationRuleLuhnCheck`
  case luhnCheck = "LUHN_ALGORITHM_CHECK_VALIDATION_ERROR"
}
