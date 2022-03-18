//
//  TestCollectCardsDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 29.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest
@testable import demoapp

class TestCollectCardsDataFlow: TestCollectBaseTestCase {

			let flowType = "Collect Payment Cards"

      func testPutCorrectData() {
      app.tables.staticTexts["Collect Payment Cards Data"].tap()

      let cardHolderNameField = app.textFields["Cardholder Name"]
      let cardNumberField = app.textFields["4111 1111 1111 1111"]
      let expDateField = app.textFields["MM/YY"]
      let cvcField = app.secureTextFields["CVC"]
      let consoleLabel = app.staticTexts.matching(identifier: "ConsoleLabelIdentifire")
      let navigationBar = app.navigationBars["Collect Payment Cards"].staticTexts["Collect Payment Cards"]

      cardHolderNameField.tap()
      cardHolderNameField.typeText("Joe B")

      cardNumberField.tap()
      cardNumberField.typeText("378282246310005")

      expDateField.tap()

      app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "March")
      app.pickerWheels.element(boundBy: 0).tap()

      app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2027")
      app.pickerWheels.element(boundBy: 1).tap()

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
}
