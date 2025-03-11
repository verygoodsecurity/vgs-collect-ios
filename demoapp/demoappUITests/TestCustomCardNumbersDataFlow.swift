//
//  TestCustomCardNumbersDataFlow.swift
//  demoappUITests
//

import XCTest

/// Tests for custom card brands flow.
class TestCustomCardNumbersDataFlow: TestCollectBaseTestCase {

  /// UI elements.
  enum UIElements {
    // swiftlint:disable nesting
    
    /// VGSText field.
    enum VGSTextField {

      /// Card Details fields.
      enum CardDetails {
        /// Card holder name.
        static let cardHolderName: VGSUITestElement = .init(type: .textField, identifier: "Cardholder Name")

        /// Card number.
        static let cardNumber: VGSUITestElement = .init(type: .textField, identifier: "4111 1111 1111 1111")

        /// Expiration date.
        static let expirationDate: VGSUITestElement = .init(type: .textField, identifier: "MM/YYYY")

        /// CVC.
        static let cvc: VGSUITestElement = .init(type: .secureTextField, identifier: "CVC")
      }
    }

    /// Navigation bar elements.
    enum NavigationBar {

      /// Expiration date.
      static let navigationBar: VGSUITestElement = .init(type: .navigationBar, identifier: "Collect Payment Cards")

      /// Title.
      static let title = "Collect Payment Cards"
    }

    /// Labels.
    enum Labels {

      /// Console label identifier.
      static let consoleLabelIdentifier = "ConsoleLabelIdentifire"

      /// State label.
      static let state = "STATE"

      /// Response label.
      static let response = "RESPONSE"
    }

    /// Buttons.
    enum Buttons {

      /// Upload.
      static let upload: VGSUITestElement = .init(type: .button, identifier: "UPLOAD")

      /// Done.
      static let done: VGSUITestElement = .init(type: .button, identifier: "Done")
    }

    /// Card numbers.
    enum CardNumbers {

      /// Visa.
      static let visa = "4111 1111 1111 1111"

      /// Custom brand.
      static let uknownBrand = "9111 1111 1111 111"
    }
    // swiftlint:enable nesting
  }

  /// Tests valid custom brand.
  func testValidCustomBrand() {

    // Navigate to payment cards.
    app.tables.staticTexts[TestsCollectFlowType.customPaymentCards.name].tap()

    // Fill in correct data.
    fillInCorrectCardData(with: UIElements.CardNumbers.visa)

    // Tap on console.
    app.staticTexts[UIElements.Labels.consoleLabelIdentifier].tap()
    
    //  Verify form is valid
    verifyFormIsValid()

    /// Tap on upload button.
    UIElements.Buttons.upload.find(in: app).tap()

    // Wait for request.
    wait(forTimeInterval: 30)

    // Find response label.
    let responseLabel = app.staticTexts[UIElements.Labels.response]

    // Verify success response.
    verifySuccessResponse()
  }

  // Verify uknown brand can be used for card data.
  func testValidUnknownBrand() {
    // Navigate to payment cards.
    app.tables.staticTexts[TestsCollectFlowType.customPaymentCards.name].tap()

    // Fill in correct data.
    fillInCorrectCardData(with: UIElements.CardNumbers.uknownBrand)

    // Tap on console.
    app.staticTexts[UIElements.Labels.consoleLabelIdentifier].tap()
    
    //  Verify form is valid
    verifyFormIsValid()

    /// Tap on upload button.
    UIElements.Buttons.upload.find(in: app).tap()

    // Wait for request.
    wait(forTimeInterval: 30)

    // Find response label.
    let responseLabel = app.staticTexts[UIElements.Labels.response]

    // Verify success response.
    verifySuccessResponse()
  }

  /// Fills in correct card data.
  func fillInCorrectCardData(with cardNumber: String) {
    let cardHolderNameField = UIElements.VGSTextField.CardDetails.cardHolderName.find(in: app)
    let cardNumberField = UIElements.VGSTextField.CardDetails.cardNumber.find(in: app)
    let expDateField = UIElements.VGSTextField.CardDetails.expirationDate.find(in: app)
    let cvcField = UIElements.VGSTextField.CardDetails.cvc.find(in: app)

    cardHolderNameField.tap()
    cardHolderNameField.typeText("Joe B")

    cardNumberField.tap()
    cardNumberField.typeText(cardNumber)

    expDateField.tap()

    fillInCorrectDateWithDatePicker()

    cvcField.tap()
    cvcField.typeText("1234")
  }
}
