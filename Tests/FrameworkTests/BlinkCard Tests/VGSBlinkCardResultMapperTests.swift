import XCTest
@testable import VGSBlinkCardCollector

final class VGSBlinkCardResultMapperTests: XCTestCase {
  func testMapsCompleteScanResult() {
    let result = VGSBlinkCardScanResult(
      cardNumber: " 4111111111111111 ",
      cardholderName: " Jane Doe ",
      cvc: " 123 ",
      iban: " HR1210010051863000160 ",
      expirationMonth: 1,
      expirationYear: 2031
    )

    let data = VGSBlinkCardResultMapper.mapScanResult(result)

    XCTAssertEqual(data[.cardNumber], "4111111111111111")
    XCTAssertEqual(data[.name], "Jane Doe")
    XCTAssertEqual(data[.cvc], "123")
    XCTAssertEqual(data[.iban], "HR1210010051863000160")
    XCTAssertEqual(data[.expirationDate], "0131")
    XCTAssertEqual(data[.expirationDateLong], "012031")
    XCTAssertEqual(data[.expirationDateShortYearThenMonth], "3101")
    XCTAssertEqual(data[.expirationDateLongYearThenMonth], "203101")
    XCTAssertEqual(data[.expirationYear], "31")
    XCTAssertEqual(data[.expirationYearLong], "2031")
    XCTAssertEqual(data[.expirationMonth], "01")
  }

  func testMissingValuesAreNotMapped() {
    let result = VGSBlinkCardScanResult(expirationMonth: 12, expirationYear: nil)

    let data = VGSBlinkCardResultMapper.mapScanResult(result)

    XCTAssertTrue(data.isEmpty)
  }

  func testTwoDigitExpirationYearIsNormalized() {
    let result = VGSBlinkCardScanResult(expirationMonth: 9, expirationYear: 32)

    let data = VGSBlinkCardResultMapper.mapScanResult(result)

    XCTAssertEqual(data[.expirationDate], "0932")
    XCTAssertEqual(data[.expirationYearLong], "2032")
  }

  @available(iOS 16.0, *)
  func testConfigurationMapsLegacySettingsToBlinkCardV3000Settings() {
    let configuration = VGSBlinkCardConfiguration(
      extractOwner: false,
      extractExpiryDate: false,
      extractCvv: false,
      extractIban: false,
      allowInvalidCardNumber: true,
      showOnboardingInfo: false,
      showIntroductionDialog: false
    )

    XCTAssertFalse(configuration.extractionSettings.extractCardholderName)
    XCTAssertFalse(configuration.extractionSettings.extractExpiryDate)
    XCTAssertFalse(configuration.extractionSettings.extractCvv)
    XCTAssertFalse(configuration.extractionSettings.extractIban)
    XCTAssertTrue(configuration.extractionSettings.extractInvalidCardNumber)
  }
}
