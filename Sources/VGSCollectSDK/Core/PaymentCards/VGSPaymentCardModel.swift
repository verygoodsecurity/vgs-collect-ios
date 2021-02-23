//
//  VGSPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// :nodoc: Payment Card Model Protocol
public protocol VGSPaymentCardModelProtocol {
  var brand: VGSPaymentCards.CardBrand { get }
  var name: String { get set }
  var regex: String { get set }
  var formatPattern: String { get set }
  var cardNumberLengths: [Int] { get set }
  var cvcLengths: [Int] { get set }
  var checkSumAlgorithm: CheckSumAlgorithmType? { get set }
  var brandIcon: UIImage? { get set }
  var cvcIcon: UIImage? { get set }
}

/// An object representing Payment Card
public struct VGSPaymentCardModel: VGSPaymentCardModelProtocol {
  
  /// Payment Card Brand
  public let brand: VGSPaymentCards.CardBrand
  
  /// Payment Card Name
  public var name: String
  
  /// Regex Pattern required to detect Payment Card Brand
  public var regex: String
  
  /// Valid Card Number Lengths
  public var cardNumberLengths: [Int]
  
  /// Valid Card CVC/CVV Lengths. For most brands valid cvc lengths is [3], while for Amex is [4].  For unknown brands can be set as [3, 4]
  public var cvcLengths: [Int]
  
  /// Check sum validation algorithm. For most brands  card number can be validated by `CheckSumAlgorithmType.luhn` algorithm. If `none` - result of Checksum Algorithm validation will be `true`.
  public var checkSumAlgorithm: CheckSumAlgorithmType?
  
  /// Payment Card Number visual format pattern.
  /// - Note: format pattern length limits input length.
  public var formatPattern: String
  
  /// Image, associated with Payment Card Brand.
  public var brandIcon: UIImage?
  
  /// Image, associated with CVC for Payment Card Brand.
  public var cvcIcon: UIImage?
  
  init(brand: VGSPaymentCards.CardBrand) {
    self.brand = brand
    self.name = brand.defaultName
    self.regex = brand.defaultRegex
    self.cardNumberLengths = brand.defaultCardLengths
    self.cvcLengths = brand.defaultCVCLengths
    self.checkSumAlgorithm = brand.defaultCheckSumAlgorithm
    self.brandIcon = brand.defaultBrandIcon
    self.formatPattern = brand.defaultFormatPattern
    self.cvcIcon = brand.defaultCVCIcon
  }
}
