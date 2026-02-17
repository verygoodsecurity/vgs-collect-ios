//
//  TestCollectCardsDataFlowInSwiftUI.swift
//  demoappUITests
//

import XCTest

/// Payment cards flow.
class TestCollectCardsDataFlowInSwiftUI: TestCollectBaseTestCase {

  /// UI elements.
  enum UIElements {
  // swiftlint:disable nesting

    /// VGSText field.
    enum VGSTextFieldRepresentable {

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
      static let navigationBar: VGSUITestElement = .init(type: .navigationBar, identifier: "Collect Card Data in SwiftUI")

      /// Title.
      static let title = "Collect Card Data in SwiftUI"
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
    }
    // swiftlint:enable nesting
  }

  /// Test valid data flow.
  func testPutCorrectData() {

    // Navigate to payment cards.
    openCollectFlow(.paymentCardsInSwiftUI)
 
    // Fill in correct data.
    fillInCorrectCardData()
    
    UIElements.Buttons.upload.find(in: app).tap()

    // Wait for request.
    wait(forTimeInterval: 30)

    // Verify success response.
    verifySuccessResponse()
  }

  /// Fills in correct card data.
  func fillInCorrectCardData() {
    let cardHolderNameField = UIElements.VGSTextFieldRepresentable.CardDetails.cardHolderName.find(in: app)
    let cardNumberField = UIElements.VGSTextFieldRepresentable.CardDetails.cardNumber.find(in: app)
    let expDateField = UIElements.VGSTextFieldRepresentable.CardDetails.expirationDate.find(in: app)
    let cvcField = UIElements.VGSTextFieldRepresentable.CardDetails.cvc.find(in: app)

    XCTAssertTrue(cardHolderNameField.waitForExistence(timeout: 15), "Card holder field should appear in SwiftUI card form.")
    cardHolderNameField.tap()
    cardHolderNameField.typeText("Joe B")

    XCTAssertTrue(cardNumberField.waitForExistence(timeout: 15), "Card number field should appear in SwiftUI card form.")
    cardNumberField.tap()
    cardNumberField.typeText("378282246310005")

    XCTAssertTrue(expDateField.waitForExistence(timeout: 15), "Expiration date field should appear in SwiftUI card form.")
    expDateField.tap()

    fillInCorrectDateWithDatePicker()

    XCTAssertTrue(cvcField.waitForExistence(timeout: 15), "CVC field should appear in SwiftUI card form.")
    cvcField.tap()
    cvcField.typeText("1234")
  }
}
