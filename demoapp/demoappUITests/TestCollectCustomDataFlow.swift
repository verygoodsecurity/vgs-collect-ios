//
//  TestCollectCustomDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 31.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest

class TestCollectCustomDataFlow: TestCollectBaseTestCase {

     func testPutCorrectData() {
        app.tables.staticTexts["Collect Social Security Number"].tap()

        let ssnField = app.textFields["XXX-XX-XXXX"]
        ssnField.tap()
        ssnField.typeText("123448899")
    
        app.staticTexts["SSN: XXX-XX-8899"].tap()
        app.buttons["UPLOAD"].tap()
        let responseLabel = app.staticTexts["RESPONSE"]
        responseLabel.waitForExistence(timeout: 30)
        
        let successResponsePredicate = NSPredicate(format: "label BEGINSWITH 'Success: '")
        let successResponseLabel = app.staticTexts.element(matching: successResponsePredicate)
        XCTAssert(successResponseLabel.exists)
  }
}
