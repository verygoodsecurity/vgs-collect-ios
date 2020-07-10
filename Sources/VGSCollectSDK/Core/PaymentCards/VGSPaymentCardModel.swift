//
//  VGSPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// :nodoc:
public protocol VGSPaymentCardModelProtocol {
  var brand: VGSPaymentCards.CardBrand { get }
  var name: String { get set }
  var regex: String { get set }
  var formatPattern: String { get set }
  var cardNumberLengths: [Int] { get set }
  var cvcLengths: [Int] { get set }
  var checkSumAlgorithm: CheckSumAlgorithmType? { get set }
  var brandIcon: UIImage? { get set }
}

public struct VGSPaymentCardModel: VGSPaymentCardModelProtocol {
  
  public let brand: VGSPaymentCards.CardBrand
  public var name: String
  public var regex: String
  public var cardNumberLengths: [Int]
  public var cvcLengths: [Int]
  public var checkSumAlgorithm: CheckSumAlgorithmType?
  public var formatPattern: String
  public var brandIcon: UIImage?
  
  init(brand: VGSPaymentCards.CardBrand) {
    self.brand = brand
    self.name = brand.defaultName
    self.regex = brand.defaultRegex
    self.cardNumberLengths = brand.defaultCardLengths
    self.cvcLengths = brand.defaultCVCLengths
    self.checkSumAlgorithm = brand.defaultCheckSumAlgorithm
    self.brandIcon = brand.defaultBrandIcon
    self.formatPattern = brand.defaultFormatPattern
  }
}
