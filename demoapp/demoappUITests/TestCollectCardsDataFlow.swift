//
//  TestCollectCardsDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 29.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest
@testable import demoapp

class TestCollectCardsDataFlow: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

  
    
    func testPutCorrectData() {
      
      let app = XCUIApplication()
      app.launch()
      
      app.navigationBars["Select a Demo"].buttons["VaultID"].tap()
      app.alerts["Set <vault id>"].typeText("tntva5wfdrp")
      app.alerts["Set <vault id>"].scrollViews.otherElements.buttons["Save"].tap()
      app.tables.staticTexts["Collect Payment Cards Data"].tap()
      
      let cardHolderNameField = app.textFields["Cardholder Name"]
      let cardNumberField = app.textFields["4111 1111 1111 1111"]
      let expDateField = app.textFields["MM/YYYY"]
      let cvcField = app.textFields["CVC"]
      let consoleLabel = app.staticTexts.matching(identifier: "ConsoleLabelIdentifire")
      let navigationBar = app.tables.staticTexts["Collect Payment Cards Data"]
      
      cardHolderNameField.tap()
      cardHolderNameField.typeText("Joe B")

      cardNumberField.tap()
      cardNumberField.typeText("378282246310005")

      expDateField.tap()
      app.pickerWheels["December"].tap()
      app.pickerWheels["2027"].tap()

      cvcField.tap()
      cvcField.typeText("1234")
      
      navigationBar.tap()

      app.buttons["UPLOAD"].tap()
      
     
    }

}

