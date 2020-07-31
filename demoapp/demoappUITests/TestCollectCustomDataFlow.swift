//
//  TestCollectCustomDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 31.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest

class TestCollectCustomDataFlow: XCTestCase {

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

     func testPutCorrectData() {
          
        let app = XCUIApplication()
        app.navigationBars["Choose a Demo"].buttons["VaultID"].tap()
        app.alerts["Set <vault id>"].waitForExistence(timeout: 2)
        app.alerts["Set <vault id>"].scrollViews.otherElements.collectionViews/*@START_MENU_TOKEN@*/.buttons["Clear text"]/*[[".cells",".textFields.buttons[\"Clear text\"]",".buttons[\"Clear text\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.alerts["Set <vault id>"].typeText("tntva5wfdrp")
        app.alerts["Set <vault id>"].scrollViews.otherElements.buttons["Save"].tap()
        app.tables.staticTexts["Collect Social Security Number"].tap()

        let ssnField = app.textFields["XXX-XX-XXXX"]
        ssnField.tap()
        ssnField.typeText("111558899")
    
        app.staticTexts["SSN: XXX-XX-8899"].tap()
//        app.buttons["UPLOAD"].tap()
      
      
      let app = app2
      let tablesQuery = app.tables
      tablesQuery.staticTexts["Collect Social Security Number"].tap()
      app.navigationBars["Collect Custom Data"].buttons["Choose a Demo"].tap()
      tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Collect Custom Data"]/*[[".cells.staticTexts[\"Collect Custom Data\"]",".staticTexts[\"Collect Custom Data\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      app.textFields["XXX XXX XXX"].tap()
      
      app.staticTexts["Very Secret Code"].tap()
      app.buttons["UPLOAD"].tap()
      
  }
}
