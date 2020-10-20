//
//  TestCustomCardNumbersDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 04.08.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest

class TestCustomCardNumbersDataFlow: XCTestCase {

    let flowType = "Customize Payment Cards"
  
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

  func testValidCustomBrand() {
     let app = XCUIApplication()
     app.navigationBars["Demo"].buttons["VaultID"].tap()
     app.alerts["Set <vault id>"].waitForExistence(timeout: 2)
     app.alerts["Set <vault id>"].scrollViews.otherElements.collectionViews/*@START_MENU_TOKEN@*/.buttons["Clear text"]/*[[".cells",".textFields.buttons[\"Clear text\"]",".buttons[\"Clear text\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
     app.alerts["Set <vault id>"].typeText("tntva5wfdrp")
     app.alerts["Set <vault id>"].scrollViews.otherElements.buttons["Save"].tap()
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
     let app = XCUIApplication()
     app.navigationBars["Demo"].buttons["VaultID"].tap()
     app.alerts["Set <vault id>"].waitForExistence(timeout: 2)
     app.alerts["Set <vault id>"].scrollViews.otherElements.collectionViews/*@START_MENU_TOKEN@*/.buttons["Clear text"]/*[[".cells",".textFields.buttons[\"Clear text\"]",".buttons[\"Clear text\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
     app.alerts["Set <vault id>"].typeText("tntva5wfdrp")
     app.alerts["Set <vault id>"].scrollViews.otherElements.buttons["Save"].tap()
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
      let app = XCUIApplication()
      app.navigationBars["Demo"].buttons["VaultID"].tap()
      app.alerts["Set <vault id>"].waitForExistence(timeout: 2)
      app.alerts["Set <vault id>"].scrollViews.otherElements.collectionViews/*@START_MENU_TOKEN@*/.buttons["Clear text"]/*[[".cells",".textFields.buttons[\"Clear text\"]",".buttons[\"Clear text\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
      app.alerts["Set <vault id>"].typeText("tntva5wfdrp")
      app.alerts["Set <vault id>"].scrollViews.otherElements.buttons["Save"].tap()
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
