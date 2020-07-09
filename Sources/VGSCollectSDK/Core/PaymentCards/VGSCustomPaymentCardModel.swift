//
//  VGSCustomPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSCustomPaymentCardModel: VGSPaymentCardModelProtocol {
  
  public let type: VGSPaymentCards.CardType
  public var name: String
  public var typePattern: String
  public var formatPattern: String
  public var cardNumberLengths: [Int]
  public var cvcLengths: [Int]
  public var checkSumAlgorithm: CheckSumAlgorithmType?
  public var brandIcon: UIImage?
  
  public init(name: String, typePattern: String, formatPattern: String, cardNumberLengths: [Int], cvcLengths: [Int], checkSumAlgorithm: CheckSumAlgorithmType? = .luhn, brandIcon: UIImage?) {
    self.type = .custom(type: name)
    self.name = name
    self.typePattern = typePattern
    self.formatPattern = formatPattern
    self.cardNumberLengths = cardNumberLengths
    self.cvcLengths = cvcLengths
    self.checkSumAlgorithm = checkSumAlgorithm
    self.brandIcon = brandIcon
  }
}
