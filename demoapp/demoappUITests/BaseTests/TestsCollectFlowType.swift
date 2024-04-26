//
//  TestsCollectFlowType.swift
//  demoappUITests
//

import Foundation

/// Defines collect tests flow type.
enum TestsCollectFlowType {
  /// Payment cards.
  case paymentCards
  /// Payment cards with SwiftUI
  case paymentCardsInSwiftUI
  /// Payment cards with Combine
  case paymentCardsWithCombine
  /// Payment cards Tokenization
  case paymentCardsTokenization
  /// SSN.
  case ssn
  /// Custom payment cards.
  case customPaymentCards
  /// Date
  case date

  /// Flow name.
  var name: String {
    switch self {
    case .paymentCards:
      return "Collect Payment Cards Data"
    case .ssn:
      return "Collect Social Security Number"
    case .date:
      return "Collect Date Data"
    case .paymentCardsInSwiftUI:
      return "Collect Card Data in SwiftUI"
    case .paymentCardsWithCombine:
      return "Collect+Combine"
    case .paymentCardsTokenization:
      return "Tokenize Card Data"
    case .customPaymentCards:
      return "Customize Payment Cards"
    }
  }
}
