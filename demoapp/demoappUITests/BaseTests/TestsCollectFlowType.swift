//
//  TestsCollectFlowType.swift
//  demoappUITests
//

import Foundation

/// Defines collect tests flow type.
enum TestsCollectFlowType {

  /// Payment cards.
  case paymentCards

  /// SSN.
  case ssn

  /// Custom payment cards.
  case customPaymentCards

  /// Flow name.
  var name: String {
    switch self {
    case .paymentCards:
      return "Collect Payment Cards Data"
    case .ssn:
      return "Collect Social Security Number"
    case .customPaymentCards:
      return "Customize Payment Cards"
    }
  }
}
