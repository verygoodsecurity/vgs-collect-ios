//
//  TestCollectCardsDataTokenizationFlow.swift
//  demoappUITests
//

/// Payment cards flow.
class TestCollectCardsDataTokenizationFlow: TestCollectBaseTestCase {

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
        static let expirationDate: VGSUITestElement = .init(type: .textField, identifier: "MM/YY")

        /// CVC.
        static let cvc: VGSUITestElement = .init(type: .secureTextField, identifier: "CVC")
      }
    }

    /// Navigation bar elements.
    enum NavigationBar {

      /// Expiration date.
      static let navigationBar: VGSUITestElement = .init(type: .navigationBar, identifier: "Collect Card Tokenization")

      /// Title.
      static let title = "Collect Card Tokenization"
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
      static let upload: VGSUITestElement = .init(type: .button, identifier: "TOKENIZE")
    }
    // swiftlint:enable nesting
  }

  /// Test valid data flow.
  func testPutCorrectData() {

    // Navigate to payment cards.
    app.tables.staticTexts[TestsCollectFlowType.paymentCardsTokenization.name].tap()

    // Tap on nav bar.
    let navigationBar = UIElements.NavigationBar.navigationBar.find(in: app).staticTexts[UIElements.NavigationBar.title]

    // Fill in correct data.
    fillInCorrectCardData()

    // Tap on console.
    app.staticTexts[UIElements.Labels.consoleLabelIdentifier].tap()
    
    /// Verify all fields are valid.
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
  func fillInCorrectCardData() {
    let cardHolderNameField = UIElements.VGSTextField.CardDetails.cardHolderName.find(in: app)
    let cardNumberField = UIElements.VGSTextField.CardDetails.cardNumber.find(in: app)
    let expDateField = UIElements.VGSTextField.CardDetails.expirationDate.find(in: app)
    let cvcField = UIElements.VGSTextField.CardDetails.cvc.find(in: app)

    cardHolderNameField.tap()
    cardHolderNameField.typeText("Joe B")

    cardNumberField.tap()
    cardNumberField.typeText("378282246310005")

    expDateField.tap()

    fillInCorrectDateWithDatePicker()

    cvcField.tap()
    cvcField.typeText("1234")
  }
}
