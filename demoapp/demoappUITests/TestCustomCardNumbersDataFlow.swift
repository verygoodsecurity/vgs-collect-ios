//
//  TestCustomCardNumbersDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 04.08.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest

class TestCustomCardNumbersDataFlow: TestCollectBaseTestCase {

	let flowType = "Customize Payment Cards"

  func testValidCustomBrand() {
     app.tables.staticTexts[flowType].tap()
     
     let cardHolderNameField = app.textFields["Cardholder Name"]
     let cardNumberField = app.textFields["4111 1111 1111 1111"]
     let expDateField = app.textFields["MM/YYYY"]
     let cvcField = app.secureTextFields["CVC"]
     
     cardHolderNameField.tap()
     cardHolderNameField.typeText("Joe B")

     cardNumberField.tap()
     cardNumberField.typeText("4111 1111 1111 1111")

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
}
