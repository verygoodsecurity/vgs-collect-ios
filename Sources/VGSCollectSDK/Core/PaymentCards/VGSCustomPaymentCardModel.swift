//
//  VGSCustomPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import UIKit

public struct VGSCustomPaymentCardModel: VGSPaymentCardModelProtocol {
  
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
  
   /// Image, associated with  Payment Card Brand.
  public var brandIcon: UIImage?
  
  // MARK: - Initialzation
  
  public init(name: String, regex: String, formatPattern: String, cardNumberLengths: [Int], cvcLengths: [Int] = [3], checkSumAlgorithm: CheckSumAlgorithmType? = .luhn, brandIcon: UIImage?) {
    self.brand = .custom(brandName: name)
    self.name = name
    self.regex = regex
    self.formatPattern = formatPattern
    self.cardNumberLengths = cardNumberLengths
    self.cvcLengths = cvcLengths
    self.checkSumAlgorithm = checkSumAlgorithm
    self.brandIcon = brandIcon
  }
}
