//
//  TestCustomCardNumbersDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 04.08.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest

/// Tests for custom card brands flow.
class TestCustomCardNumbersDataFlow: TestCollectBaseTestCase {

  /// UI elements.
  enum UIElements {

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
    }
  }

	let flowType = "Customize Payment Cards"

  /// Tests valid custom brand.
  func testValidCustomBrand() {

    // Navigate to payment cards.
    app.tables.staticTexts[TestsCollectFlowType.customPaymentCards.name].tap()

    // Fill in correct data.
    fillInCorrectCardData()

    // Tap on state.
    app.staticTexts[UIElements.Labels.state].tap()

    /// Tap on upload button.
    UIElements.Buttons.upload.find(in: app).tap()

    // Wait for request.
    wait(forTimeInterval: 30)

    // Find response label.
    let responseLabel = app.staticTexts[UIElements.Labels.response]

    // Verify success response.
    let successResponsePredicate = NSPredicate(format: "label BEGINSWITH 'Success: '")
    let successResponseLabel = app.staticTexts.element(matching: successResponsePredicate)
    XCTAssert(successResponseLabel.exists)
  }

  func testValidUnknownBrand() {
     app.tables.staticTexts[flowType].tap()
     
     let cardHolderNameField = app.textFields["Cardholder Name"]
     let cardNumberField = app.textFields["4111 1111 1111 1111"]
     let expDateField = app.textFields["MM/YYYY"]
     let cvcField = app.secureTextFields["CVC"]
     
     cardHolderNameField.tap()
     cardHolderNameField.typeText("Joe B")

     cardNumberField.tap()
     cardNumberField.typeText("9111 1111 1111 111")

     expDateField.tap()
     
     app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2030")
     app.pickerWheels.element(boundBy: 1).tap()
    
     app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "May")
     app.pickerWheels.element(boundBy: 0).tap()

     cvcField.tap()
     cvcField.typeText("1234")
     
     app.staticTexts["STATE"].tap()
     
     app.buttons["UPLOAD"].tap()
     let responseLabel = app.staticTexts["RESPONSE"]
     responseLabel.waitForExistence(timeout: 30)
     
     let successResponsePredicate = NSPredicate(format: "label BEGINSWITH 'Success: '")
     let successResponseLabel = app.staticTexts.element(matching: successResponsePredicate)
     XCTAssert(successResponseLabel.exists)
    
  }
  
  func testValidInputThroughCardIO() {
      app.tables.staticTexts[flowType].tap()
    
      let cardHolderNameField = app.textFields["Cardholder Name"]
      
      cardHolderNameField.tap()
      cardHolderNameField.typeText("Joe B")

      app.staticTexts["STATE"].tap()
    
      app.buttons["SCAN"].tap()
      let cardIOCardNumField =  app.tables.textFields["Card Number"]
      let cardIOExpDateField =  app.tables.textFields["MM / YY"]
      let cardIOCVVField =  app.tables.textFields["CVV"]

      cardIOCardNumField.tap()
      cardIOCardNumField.typeText("4111111111111111")
    
      cardIOExpDateField.tap()
      cardIOExpDateField.typeText("0130")

      cardIOCVVField.tap()
      cardIOCVVField.typeText("123")
    
      app.navigationBars["Card"].buttons["Done"].tap()
            
      app.buttons["UPLOAD"].tap()
      let responseLabel = app.staticTexts["RESPONSE"]
      responseLabel.waitForExistence(timeout: 30)
      
      let successResponsePredicate = NSPredicate(format: "label BEGINSWITH 'Success: '")
      let successResponseLabel = app.staticTexts.element(matching: successResponsePredicate)
      XCTAssert(successResponseLabel.exists)
  }


  /// Fills in correct card data.
  func fillInCorrectCardData() {
    let cardHolderNameField = UIElements.VGSTextField.CardDetails.cardHolderName.find(in: app)
    let cardNumberField = UIElements.VGSTextField.CardDetails.cardNumber.find(in: app)
    let expDateField = UIElements.VGSTextField.CardDetails.expirationDate.find(in: app)
    let cvcField = UIElements.VGSTextField.CardDetails.cvc.find(in: app)


    cardHolderNameField.tap()
    cardHolderNameField.typeText("Joe B")

    typeInVisa()

    expDateField.tap()

    fillInCorrectDateWithDatePicker()

    cvcField.tap()
    cvcField.typeText("1234")
  }

  /// Types in visa.
  func typeInVisa() {
    let cardNumberField = UIElements.VGSTextField.CardDetails.cardNumber.find(in: app)

    cardNumberField.tap()
    cardNumberField.typeText("4111 1111 1111 1111")
  }
}
