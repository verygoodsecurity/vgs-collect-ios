//
//  ChecksumAlgoritmType.swift
//  VGSPaymentCards
//
//  Created by Dima on 08.06.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Check Sum Algorithm Types
public enum CheckSumAlgorithmType {
  
  /// Luhn Algorithm
  case luhn
}

public extension CheckSumAlgorithmType {
  /// Validate input String with specified algorithm.
  func validate(_ input: String) -> Bool {
    switch self {
    case .luhn:
      return Self.validateWithLuhnAlgorithm(with: input)
    }
  }
}

extension CheckSumAlgorithmType {
  
  /// Validate input number via LuhnAlgorithm algorithm.
  static func validateWithLuhnAlgorithm(with cardNumber: String) -> Bool {
                      
      guard cardNumber.count >= 9 else {
          return false
      }
      
      var sum = 0
      let digitStrings = cardNumber.reversed().map { String($0) }

      for tuple in digitStrings.enumerated() {
          if let digit = Int(tuple.element) {
              let odd = tuple.offset % 2 == 1

              switch (odd, digit) {
              case (true, 9):
                  sum += 9
              case (true, 0...8):
                  sum += (digit * 2) % 9
              default:
                  sum += digit
              }
          } else {
              return false
          }
      }
      let valid = sum % 10 == 0
      return valid
  }
}
