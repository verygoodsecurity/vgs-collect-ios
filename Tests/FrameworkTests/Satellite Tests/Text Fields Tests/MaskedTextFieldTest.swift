//
//  MaskedTextFieldTest.swift
//  FrameworkTests
//
//  Created by Dima on 27.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class MaskedTextFieldTest: VGSCollectBaseTestCase {
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
    
    func testDigitsMaskingText() {
        configuration.formatPattern = "#### ####-####.####"
        textfield.configuration = configuration
        textfield.textField.secureText = "011122223333444455556"
        XCTAssertTrue(textfield.textField.secureText == "0111 2222-3333.4444")
        XCTAssertTrue(textfield.state.inputLength == 16)
      
        configuration.formatPattern = "#### ####_####?##+##"
        textfield.configuration = configuration
      
        textfield.textField.secureText = ""
        XCTAssertTrue(textfield.textField.secureText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
       
        textfield.textField.secureText! += " adf"
        XCTAssertTrue(textfield.textField.secureText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
      
        textfield.textField.secureText! += " 0 1 "
        XCTAssertTrue(textfield.textField.secureText == "01")
        XCTAssertTrue(textfield.state.inputLength == 2)
      
        textfield.textField.secureText! += "112222 333344445555sd "
        XCTAssertTrue(textfield.textField.secureText == "0111 2222_3333?44+44")
        XCTAssertTrue(textfield.state.inputLength == 16)
    }
    
    func testLettersMaskingText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = "TEST test-tEsT.tEsTu"
        XCTAssertTrue(textfield.textField.secureText == "TEST test-tEsT.tEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.textField.secureText == "TEST test-tEsT.tEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
    }
    
    func testLettersAndDigitMaskingText() {
        let inputText = " Aa11_22:22/33+ 2s"
      
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.secureText = inputText
        XCTAssertTrue(textfield.textField.secureText == inputText)
        XCTAssertTrue(textfield.state.inputLength == inputText.count)
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.secureText = "Aa1122223333444455556"
        XCTAssertTrue(textfield.textField.secureText == "Aa11")
        XCTAssertTrue(textfield.state.inputLength == 4)

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.secureText = " tE2 5test"
        XCTAssertTrue(textfield.textField.secureText == "tE./_:+25")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testGetRawDigitsText() {
        configuration.formatPattern = "#### #### #### ####"
        textfield.configuration = configuration
        textfield.textField.secureText = "4111111111111111"
        XCTAssertTrue(textfield.textField.getSecureRawText == "4111111111111111")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.formatPattern = " ####-####?####_####.#### "
        textfield.configuration = configuration
        textfield.textField.secureText = "411122223333444455556"
        XCTAssertTrue(textfield.textField.getSecureRawText == "41112222333344445555")
        XCTAssertTrue(textfield.state.inputLength == 20)
      
        textfield.textField.secureText = "41112"
        XCTAssertTrue(textfield.textField.getSecureRawText == "41112")
        XCTAssertTrue(textfield.state.inputLength == 5)
      
        textfield.textField.secureText = ""
        XCTAssertTrue(textfield.textField.getSecureRawText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
      
        configuration.formatPattern = " _##/## "
        textfield.configuration = configuration
        textfield.textField.secureText = "012345678"
        XCTAssertTrue(textfield.textField.getSecureRawText == "0123")
        XCTAssertTrue(textfield.state.inputLength == 4)
        
        configuration.formatPattern = "####-"
        textfield.configuration = configuration
        textfield.textField.secureText = "4111"
        XCTAssertTrue(textfield.textField.getSecureRawText == "4111")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testGetRawLettersText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = "TESTtesttEsTtEsTu"
        XCTAssertTrue(textfield.textField.getSecureRawText == "TESTtesttEsTtEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
      
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.textField.getSecureRawText == "TESTtesttEsTtEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
      
        textfield.textField.secureText = "1234"
        XCTAssertTrue(textfield.textField.getSecureRawText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
    }
    
    func testGetRawLettersAndDigitsText() {
        let inputText = " Aa11_22:22/33+ 2s"
      
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.secureText = inputText
        XCTAssertTrue(textfield.textField.getSecureRawText == inputText)
        XCTAssertTrue(textfield.state.inputLength == inputText.count)
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.secureText = "Aa1122223333444455556"
        XCTAssertTrue(textfield.textField.getSecureRawText == "Aa11")
        XCTAssertTrue(textfield.state.inputLength == 4)
      
        textfield.textField.secureText = "a1"
        XCTAssertTrue(textfield.textField.getSecureRawText == "a1")
        XCTAssertTrue(textfield.state.inputLength == 2)

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.secureText = " tE2 5test"
        XCTAssertTrue(textfield.textField.getSecureRawText == "tE25")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testAddDivider() {
        configuration.formatPattern = "#### ####-####.####"
        configuration.divider = "-"
        textfield.configuration = configuration
        textfield.textField.secureText = "5252525252525252"
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "5252-5252-5252-5252")
        XCTAssertTrue(textfield.getOutputText() == "5252-5252-5252-5252")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.formatPattern = "-####-"
        configuration.divider = "+"
        textfield.configuration = configuration
        textfield.textField.secureText = "5252525252525252"
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "+5252+")
        XCTAssertTrue(textfield.getOutputText() == "+5252+")
        XCTAssertTrue(textfield.state.inputLength == 4)
      
        textfield.setText("")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
        
        configuration.formatPattern = " AAA/aaa/####"
        configuration.divider = "__"
        textfield.configuration = configuration
        textfield.setText("XYZxyz123456789wertert")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "__XYZ__xyz__1234")
        XCTAssertTrue(textfield.getOutputText() == "__XYZ__xyz__1234")
        XCTAssertTrue(textfield.state.inputLength == 10)
      
        textfield.setText("XYZxyz")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "__XYZ__xyz")
        XCTAssertTrue(textfield.state.inputLength == 6)
        
        configuration.formatPattern = " #-#--#---#"
        configuration.divider = "-"
        textfield.configuration = configuration
        textfield.setText("12345678")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "-1-2--3---4")
        XCTAssertTrue(textfield.getOutputText() == "-1-2--3---4")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testDefaultDivider() {
        configuration.type = .cardNumber
        configuration.divider = nil
        configuration.formatPattern = "#### ####.####-####"
        textfield.configuration = configuration
        textfield.setText("5252525252525252")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "5252525252525252")
        XCTAssertTrue(textfield.getOutputText() == "5252525252525252")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.type = .expDate
        configuration.divider = nil
        configuration.formatPattern = nil
        textfield.configuration = configuration
        textfield.setText("1234")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "12/34")
        XCTAssertTrue(textfield.getOutputText() == "12/34")
        XCTAssertTrue(textfield.state.inputLength == 4)
        
        let nameInput = "Joe's Business"
        configuration.type = .cardHolderName
        configuration.divider = nil
        configuration.formatPattern = nil
        textfield.configuration = configuration
        textfield.setText(nameInput)
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == nameInput)
        XCTAssertTrue(textfield.getOutputText() == nameInput)
        XCTAssertTrue(textfield.state.inputLength == nameInput.count)
        
        configuration.type = .cvc
        configuration.formatPattern =  nil
        configuration.divider = nil
        textfield.configuration = configuration
        textfield.setText("1234")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "1234")
        XCTAssertTrue(textfield.getOutputText() == "1234")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
}
