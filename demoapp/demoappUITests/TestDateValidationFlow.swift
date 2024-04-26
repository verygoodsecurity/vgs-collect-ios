//
//  TestDateValidationFlow.swift
//  demoappUITests
//


import XCTest

/// Test SSN flow.
class TestDateValidationFlow: TestCollectBaseTestCase {

  /// UI elements.
  enum UIElements {
  // swiftlint:disable nesting
    
    /// VGSText field.
    enum VGSTextField {

      /// SSN fields.
      enum Date {
        /// Card holder name.
        static let date: VGSUITestElement = .init(type: .textField, identifier: "MM-DD-YYYY")
      }
    }
    
    enum NavigationBar {

      /// Expiration date.
      static let navigationBar: VGSUITestElement = .init(type: .navigationBar, identifier: "Date Validation")

      /// Title.
      static let title = "Date Validation"
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

    /// Texts.
    enum Texts {

      /// Raw ssn.
      static let rawDate = "12212033"

      /// Masked ssn.
      static let maskedDate = "12/21/2033"
    }
    // swiftlint:enable nesting
  }

  /// Verifies ssn flow work for valid ssn.
  func testPutCorrectData() {

    // Navigate to payment cards.
    app.tables.staticTexts[TestsCollectFlowType.date.name].tap()

    // Tap on nav bar.
    let navigationBar = UIElements.NavigationBar.navigationBar.find(in: app).staticTexts[UIElements.NavigationBar.title]

    // Fill in correct data.
    fillInCorrectCardData()

    // Tap on console.
    app.staticTexts[UIElements.Labels.consoleLabelIdentifier].tap()
    
    /// Verify all fields are valid.
    verifyFormIsValid()
  }

  /// Fills in correct card data.
  func fillInCorrectCardData() {
    let dateField = UIElements.VGSTextField.Date.date.find(in: app)
   
    dateField.tap()
    fillInCorrectFullDateWithDatePicker()
  }
}
