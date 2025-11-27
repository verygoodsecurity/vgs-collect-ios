//
//  VGSValidationRuleABARoutingNumber.swift
//  VGSCollectSDK
//
//
//  Validation rule for US ABA Routing Number. A valid routing number:
//  - consists of exactly 9 digits
//  - passes checksum: (3*(d0+d3+d6) + 7*(d1+d4+d7) + 1*(d2+d5+d8)) % 10 == 0
//
//

import Foundation

/**
 Validate input against ABA (American Bankers Association) routing number requirements.
 Rules:
  - Must be exactly 9 numeric digits.
  - Checksum must satisfy: (3*(d0+d3+d6) + 7*(d1+d4+d7) + (d2+d5+d8)) mod 10 == 0.
 */
public struct VGSValidationRuleABARoutingNumber: VGSValidationRuleProtocol {
  
  /// Validation Error
  public let error: VGSValidationError
  
  /// Initialization
  /// - Parameters:
  ///   - error: `VGSValidationError` - error on failed validation result.
  public init(error: VGSValidationError) {
    self.error = error
  }
}

extension VGSValidationRuleABARoutingNumber: VGSRuleValidator {
  internal func validate(input: String?) -> Bool {
    guard let value = input, value.count == 9, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: value)) else {
      return false
    }
    // Convert characters to integers safely
    let digits = value.compactMap { Int(String($0)) }
    guard digits.count == 9 else { return false }
    // Compute checksum per ABA formula
    // 3 * (d0 + d3 + d6) + 7 * (d1 + d4 + d7) + 1 * (d2 + d5 + d8)
    let sum = 3 * (digits[0] + digits[3] + digits[6]) + 7 * (digits[1] + digits[4] + digits[7]) + (digits[2] + digits[5] + digits[8])
    return sum % 10 == 0
  }
}
