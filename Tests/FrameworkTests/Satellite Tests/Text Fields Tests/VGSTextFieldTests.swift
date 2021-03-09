//
//  VGSTextFieldTests.swift
//  FrameworkTests
//
//  Created by Dima on 02.09.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class VGSTextFieldTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var configuration: VGSConfiguration!
    var textfield: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "vaultid")
        configuration = VGSConfiguration.init(collector: collector, fieldName: "test1")
        textfield = VGSTextField()
        textfield.configuration = configuration
    }
    
    override func tearDown() {
        collector  = nil
        configuration = nil
        textfield = nil
    }
  
    func testSetDefaultText() {
      configuration.type = .cardNumber
      textfield.configuration = configuration
      textfield.setDefaultText("4111111111111111")
      XCTAssertTrue(textfield.textField.secureText == "4111 1111 1111 1111")
      XCTAssertTrue(textfield.state.inputLength == 16)
      XCTAssertTrue(textfield.state.isDirty == false)
      XCTAssertTrue(textfield.state.isEmpty == false)
      XCTAssertTrue(textfield.state.isValid == true)
    }
    
    func testSetText() {
      configuration.type = .cardNumber
      textfield.configuration = configuration
      textfield.setText("4111111111111111")
      XCTAssertTrue(textfield.textField.secureText == "4111 1111 1111 1111")
      XCTAssertTrue(textfield.state.inputLength == 16)
      XCTAssertTrue(textfield.state.isDirty == true)
      XCTAssertTrue(textfield.state.isEmpty == false)
      XCTAssertTrue(textfield.state.isValid == true)
  }
  
  func testCleanText() {
      configuration.type = .cardNumber
      textfield.configuration = configuration
      textfield.setDefaultText("4111111111111111")
      textfield.cleanText()
      XCTAssertTrue(textfield.textField.secureText == "")
      XCTAssertTrue(textfield.state.inputLength == 0)
      XCTAssertTrue(textfield.state.isDirty == false)
      XCTAssertTrue(textfield.state.isEmpty == true)
      XCTAssertTrue(textfield.state.isValid == false)
    
      textfield.setText("4111111111111111")
      textfield.cleanText()
      XCTAssertTrue(textfield.textField.secureText == "")
      XCTAssertTrue(textfield.state.inputLength == 0)
      XCTAssertTrue(textfield.state.isDirty == true)
      XCTAssertTrue(textfield.state.isEmpty == true)
      XCTAssertTrue(textfield.state.isValid == false)
   }
}
       
