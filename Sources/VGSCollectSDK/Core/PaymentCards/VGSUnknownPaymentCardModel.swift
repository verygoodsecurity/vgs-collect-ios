//
//  VGSUnknownPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSUnknownPaymentCardModel {
  internal let name = VGSPaymentCards.CardBrand.unknown.defaultName
  internal var regex: String = VGSPaymentCards.CardBrand.unknown.defaultRegex
  public var formatPattern: String = VGSPaymentCards.CardBrand.unknown.defaultFormatPattern
  public var cardNumberLengths: [Int] = VGSPaymentCards.CardBrand.unknown.defaultCardLengths
  public var cvcLengths: [Int] = VGSPaymentCards.CardBrand.unknown.defaultCVCLengths
  public var checkSumAlgorithm: CheckSumAlgorithmType? = VGSPaymentCards.CardBrand.unknown.defaultCheckSumAlgorithm
  public var brandIcon: UIImage? = VGSPaymentCards.CardBrand.unknown.defaultBrandIcon
}
