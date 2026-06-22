//
//  VGSBlinkCardResultMapper.swift
//  VGSBlinkCardCollector
//

import Foundation

#if canImport(BlinkCard)
import BlinkCard
#endif

internal struct VGSBlinkCardScanResult {
  let cardNumber: String?
  let cardholderName: String?
  let cvc: String?
  let iban: String?
  let expirationMonth: Int?
  let expirationYear: Int?

  init(cardNumber: String? = nil, cardholderName: String? = nil, cvc: String? = nil, iban: String? = nil, expirationMonth: Int? = nil, expirationYear: Int? = nil) {
    self.cardNumber = cardNumber
    self.cardholderName = cardholderName
    self.cvc = cvc
    self.iban = iban
    self.expirationMonth = expirationMonth
    self.expirationYear = expirationYear
  }
}

internal enum VGSBlinkCardResultMapper {
  static func mapScanResult(_ result: VGSBlinkCardScanResult) -> [VGSBlinkCardDataType: String] {
    var data = [VGSBlinkCardDataType: String]()

    if let number = trimmed(result.cardNumber) {
      data[.cardNumber] = number
    }

    if let name = trimmed(result.cardholderName) {
      data[.name] = name
    }

    if let cvc = trimmed(result.cvc) {
      data[.cvc] = cvc
    }

    if let iban = trimmed(result.iban) {
      data[.iban] = iban
    }

    if let date = VGSBlinkCardExpirationDate(result.expirationMonth, year: result.expirationYear) {
      data[.expirationDate] = date.mapDefaultExpirationDate()
      data[.expirationDateLong] = date.mapLongExpirationDate()
      data[.expirationDateShortYearThenMonth] = date.mapExpirationDateWithShortYearFirst()
      data[.expirationDateLongYearThenMonth] = date.mapLongExpirationDateWithLongYearFirst()
      data[.expirationYear] = String(format: "%02d", date.shortYear)
      data[.expirationYearLong] = String(date.year)
      data[.expirationMonth] = date.monthString
    }

    return data
  }

  private static func trimmed(_ value: String?) -> String? {
    let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return trimmedValue.isEmpty ? nil : trimmedValue
  }
}

#if canImport(BlinkCard)
internal extension VGSBlinkCardScanResult {
  init(_ result: BlinkCardScanningResult) {
    let account = result.cardAccounts.first { account in
      !account.cardNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
      !(account.cvv?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) ||
      account.expiryDate != nil
    }

    self.init(
      cardNumber: account?.cardNumber,
      cardholderName: result.cardholderName,
      cvc: account?.cvv,
      iban: result.iban,
      expirationMonth: account?.expiryDate?.month,
      expirationYear: account?.expiryDate?.year
    )
  }
}
#endif
