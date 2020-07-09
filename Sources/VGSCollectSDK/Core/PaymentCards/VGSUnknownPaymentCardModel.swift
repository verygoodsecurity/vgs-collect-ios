//
//  VGSUnknownPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSUnknownPaymentCardModel {
  internal var typePattern: String = "^[0-9]+$"
  public var formatPattern: String = VGSPaymentCards.CardType.unknown.defaultFormatPattern
  public var cardNumberLengths: [Int] = Array(16...19)
  public var cvcLengths: [Int] = [3, 4]
  public var checkSumAlgorithm: CheckSumAlgorithmType? = .luhn
  public var brandIcon: UIImage? = VGSPaymentCards.CardType.unknown.brandIcon
  
  public init() {}
}
