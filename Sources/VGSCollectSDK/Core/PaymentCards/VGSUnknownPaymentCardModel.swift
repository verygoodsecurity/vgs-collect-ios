//
//  VGSUnknownPaymentCardModel.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An object representing Unknown Payment Cards - cards not defined in the SDK. Object is used when validation for`CardBrand.unknown` is set as `true`. Check `VGSValidationRulePaymentCard` for more details. Validation attributes can be edited through ``VGSPaymentCards.unknown` model.
public struct VGSUnknownPaymentCardModel {
  
  internal let name = VGSPaymentCards.CardBrand.unknown.defaultName
  
  internal var regex: String = VGSPaymentCards.CardBrand.unknown.defaultRegex

  /// Valid Unknown Card Numbers Lengths
  public var cardNumberLengths: [Int] = VGSPaymentCards.CardBrand.unknown.defaultCardLengths
  
   /// Valid Unknown Card CVC/CVV Lengths. For most brands valid cvc lengths is [3], while for Amex is [4].  For unknown brands can be set as [3, 4]
  public var cvcLengths: [Int] = VGSPaymentCards.CardBrand.unknown.defaultCVCLengths
  
  /// Check sum validation algorithm. For most brands  card number can be validated by `CheckSumAlgorithmType.luhn` algorithm. If `none` - result of Checksum Algorithm validation will be `true`.
  public var checkSumAlgorithm: CheckSumAlgorithmType? = VGSPaymentCards.CardBrand.unknown.defaultCheckSumAlgorithm
  
  /// Unknown Payment Card Numbers visual format pattern. NOTE: format pattern length limits input length.
  public var formatPattern: String = VGSPaymentCards.CardBrand.unknown.defaultFormatPattern

   /// Image, associated with Unknown Payment Card Brands.
  public var brandIcon: UIImage? = VGSPaymentCards.CardBrand.unknown.defaultBrandIcon
  
  /// Image, associated with CVC for Unknown Payment Card Brands.
  public var cvcIcon: UIImage? = VGSPaymentCards.CardBrand.unknown.defaultCVCIcon
}
