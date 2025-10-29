//
//  VGSPaymentCards.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Class responsible for storing and managing Payment Card definitions used by the SDK.
/// - Provides predefined payment card models (Visa, Mastercard, Amex, etc.).
/// - Supports adding custom payment card models (regex & format pattern based).
/// - Allows configuring behaviour and validation for unknown brands through `VGSPaymentCards.unknown`.
@MainActor final public class VGSPaymentCards {

    /// Private initialization to restrict instantiation. Use static members instead.
  private init() {}
    
  // MARK: - CardBrand Enum Cases

  /// Supported card brands handled by the SDK.
  /// - NOTE: `.custom(brandName:)` can be used to add developer-defined brands; ensure `brandName` uniqueness.
  public enum CardBrand: Equatable, Sendable {
      /// ELO brand.
      case elo
      /// Visa Electron brand.
      case visaElectron
      /// Maestro brand.
      case maestro
      /// Forbrugsforeningen brand.
      case forbrugsforeningen
      /// Dankort brand.
      case dankort
      /// Visa brand.
      case visa
      /// Mastercard brand.
      case mastercard
      /// American Express brand.
      case amex
      /// Hipercard brand.
      case hipercard
      /// Diners Club brand.
      case dinersClub
      /// Discover brand.
      case discover
      /// UnionPay brand.
      case unionpay
      /// JCB brand.
      case jcb
      /// Not supported / undetected brand.
      case unknown
      /// Custom Payment Card Brand. Should have unique `brandName`.
      case custom(brandName: String)
  }
  
    // MARK: - Payment Card Models
  
    /// Elo payment card model.
    @MainActor public static var elo = VGSPaymentCardModel(brand: .elo)
    /// Visa Electron payment card model.
    @MainActor public static var visaElectron = VGSPaymentCardModel(brand: .visaElectron)
    /// Maestro payment card model.
    @MainActor public static var maestro = VGSPaymentCardModel(brand: .maestro)
    /// Forbrugsforeningen payment card model.
    @MainActor public static var forbrugsforeningen = VGSPaymentCardModel(brand: .forbrugsforeningen)
    /// Dankort payment card model.
    @MainActor public static var dankort = VGSPaymentCardModel(brand: .dankort)
    /// Visa payment card model.
    @MainActor public static var visa = VGSPaymentCardModel(brand: .visa)
    /// Mastercard payment card model.
    @MainActor public static var masterCard = VGSPaymentCardModel(brand: .mastercard)
    /// American Express payment card model.
    @MainActor public static var amex = VGSPaymentCardModel(brand: .amex)
    /// Hipercard payment card model.
    @MainActor public static var hipercard = VGSPaymentCardModel(brand: .hipercard)
    /// Diners Club payment card model.
    @MainActor public static var dinersClub = VGSPaymentCardModel(brand: .dinersClub)
    /// Discover payment card model.
    @MainActor public static var discover = VGSPaymentCardModel(brand: .discover)
    /// UnionPay payment card model.
    @MainActor public static var unionpay = VGSPaymentCardModel(brand: .unionpay)
    /// JCB payment card model.
    @MainActor public static var jcb = VGSPaymentCardModel(brand: .jcb)
  
    // MARK: - Unknown Payment Card Model
  
    /// Unknown brand payment card model. Customize to influence validation for brands not detected by predefined or custom models.
    @MainActor public static var unknown = VGSUnknownPaymentCardModel()
  
    // MARK: - Custom Payment Card Models
  
    /// Array of custom payment card models.
    /// - Important: Order impacts brand detection priority. Earlier entries are matched first.
    @MainActor public static var cutomPaymentCardModels = [VGSCustomPaymentCardModel]()

    /// Explicit list of valid brands (predefined + custom) to be used for detection. If `nil`, `availableCardBrands` is used.
    /// - Important: Order impacts brand detection priority.
    @MainActor public static var validCardBrands: [VGSPaymentCardModelProtocol]?

    /// Internal array of default predefined card models in priority order.
    @MainActor internal static var defaultCardModels: [VGSPaymentCardModelProtocol] {
                                            return  [ elo,
                                                      visaElectron,
                                                      maestro,
                                                      forbrugsforeningen,
                                                      dankort,
                                                      visa,
                                                      masterCard,
                                                      amex,
                                                      hipercard,
                                                      dinersClub,
                                                      discover,
                                                      unionpay,
                                                      jcb ] }
      
    /// Array of card brands currently considered for detection and validation.
    /// - Returns: `validCardBrands` if set, otherwise concatenation of `cutomPaymentCardModels` and `defaultCardModels`.
    /// - Important: Order impacts heuristic detection by regex.
    @MainActor internal static var availableCardBrands: [VGSPaymentCardModelProtocol] {
      if let userValidBrands = validCardBrands {
        return userValidBrands
      }
      return Self.cutomPaymentCardModels + Self.defaultCardModels
    }
}

// MARK: - Attributes
public extension VGSPaymentCards.CardBrand {
  
    /// Human-readable name for the card brand (falls back to unknown brand name if not resolved).
    @MainActor var stringValue: String {
      return VGSPaymentCards.getCardModelFromAvailableModels(brand: self)?.name ?? VGSPaymentCards.unknown.name
    }

    /// Valid card number lengths for this brand (falls back to unknown model lengths if not resolved).
    @MainActor var cardLengths: [Int] {
      return VGSPaymentCards.getCardModelFromAvailableModels(brand: self)?.cardNumberLengths ?? VGSPaymentCards.unknown.cardNumberLengths
    }
  
    /// Equatable implementation comparing brand identity or custom brand names.
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.visa, .visa),
           (.elo, .elo),
           (.visaElectron, .visaElectron),
           (.maestro, .maestro),
           (.forbrugsforeningen, .forbrugsforeningen),
           (.dankort, .dankort),
           (.mastercard, .mastercard),
           (.amex, .amex),
           (.hipercard, .hipercard),
           (.dinersClub, .dinersClub),
           (.discover, .discover),
           (.unionpay, .unionpay),
           (.jcb, .jcb),
           (.unknown, .unknown): return true
      case (.custom(let lhsString), .custom(let rhsString)):
        return lhsString == rhsString
      default:
        return false
      }
    }
}

public extension VGSPaymentCards {

        /// Returns the payment card model for a specific brand from currently available models.
    /// - Parameter brand: Brand to look up.
    /// - Returns: `VGSPaymentCardModelProtocol?` matching model or `nil` if not available.
    @MainActor static func getCardModelFromAvailableModels(brand: VGSPaymentCards.CardBrand) -> VGSPaymentCardModelProtocol? {
      return Self.availableCardBrands.first(where: { $0.brand == brand})
    }

        /// Detects card brand from raw PAN input by evaluating regex of available models in priority order.
    /// - Parameter input: Raw card number string (digits only or may include spacing which should be sanitized before detection).
    /// - Returns: Resolved `CardBrand` or `.unknown` if no regex matches.
    @MainActor static func detectCardBrandFromAvailableCards(input: String) -> VGSPaymentCards.CardBrand {
      for cardModel in Self.availableCardBrands {
          let predicate = NSPredicate(format: "SELF MATCHES %@", cardModel.regex)
          if predicate.evaluate(with: input) == true {
            return cardModel.brand
          }
        }
        return .unknown
    }
}
