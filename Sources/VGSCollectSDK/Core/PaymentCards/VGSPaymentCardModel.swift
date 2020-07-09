//
//  VGSPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public protocol VGSPaymentCardModelProtocol {
  var type: VGSPaymentCards.CardType { get }
  var name: String { get set }
  var typePattern: String { get set }
  var formatPattern: String { get set }
  var cardNumberLengths: [Int] { get set }
  var cvcLengths: [Int] { get set }
  var checkSumAlgorithm: CheckSumAlgorithmType? { get set }
  var brandIcon: UIImage? { get set }
}

public struct VGSPaymentCardModel: VGSPaymentCardModelProtocol {
  
  public let type: VGSPaymentCards.CardType
  public var name: String
  public var typePattern: String
  public var cardNumberLengths: [Int]
  public var cvcLengths: [Int]
  public var checkSumAlgorithm: CheckSumAlgorithmType?
  public var formatPattern: String
  public var brandIcon: UIImage?
  
  init(type: VGSPaymentCards.CardType) {
    self.type = type
    self.name = type.defaultName
    self.typePattern = type.defaultTypeDetectRegex
    self.cardNumberLengths = type.defaultCardLengths
    self.cvcLengths = type == .amex ? [4] : [3]
    self.checkSumAlgorithm = .luhn
    self.brandIcon = type.defaultBrandIcon
    self.formatPattern = type.defaultFormatPattern
  }
}
