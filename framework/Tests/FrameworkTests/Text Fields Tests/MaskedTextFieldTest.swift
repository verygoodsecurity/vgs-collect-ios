//
//  MaskedTextFieldTest.swift
//  FrameworkTests
//
//  Created by Dima on 27.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSFramework

class MaskedTextFieldTest: XCTestCase {
    var collector: VGSCollect!
    var configuration: VGSConfiguration!
    var textfield: VGSTextField!
    
    override func setUp() {
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
        
        configuration.formatPattern = "#### ####_####?##+##"
        textfield.configuration = configuration
        textfield.textField.secureText = " adf 01112222 333344445555sd"
        XCTAssertTrue(textfield.textField.secureText == "0111 2222_3333?44+44")
    }
    
    func testLettersMaskingText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = "TEST test-tEsT.tEsTu"
        XCTAssertTrue(textfield.textField.secureText == "TEST test-tEsT.tEsT")
        
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.textField.secureText == "TEST test-tEsT.tEsT")
    }
    
    func testLettersAndDigitMaskingText() {
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.secureText = " Aa11_22:22/33+ 2s"
        XCTAssertTrue(textfield.textField.secureText == " Aa11_22:22/33+ 2s")
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.secureText = "Aa1122223333444455556"
        XCTAssertTrue(textfield.textField.secureText == "Aa11")

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.secureText = " tE2 5test"
        XCTAssertTrue(textfield.textField.secureText == "tE./_:+25")
    }
    
    func testGetRawDigitsText() {
        configuration.formatPattern = "#### #### #### ####"
        textfield.configuration = configuration
        textfield.textField.secureText = "4111111111111111"
        XCTAssertTrue(textfield.textField.getSecureRawText == "4111111111111111")
        
        configuration.formatPattern = " ####-####?####_####.#### "
        textfield.configuration = configuration
        textfield.textField.secureText = "411122223333444455556"
        XCTAssertTrue(textfield.textField.getSecureRawText == "41112222333344445555")
        
        configuration.formatPattern = " _##/## "
        textfield.configuration = configuration
        textfield.textField.secureText = "012345678"
        XCTAssertTrue(textfield.textField.getSecureRawText == "0123")
        
        configuration.formatPattern = "####-"
        textfield.configuration = configuration
        textfield.textField.secureText = "4111"
        XCTAssertTrue(textfield.textField.getSecureRawText == "4111")
    }
    
    func testGetRawLettersText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = "TESTtesttEsTtEsTu"
        XCTAssertTrue(textfield.textField.getSecureRawText == "TESTtesttEsTtEsT")
        
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.textField.getSecureRawText == "TESTtesttEsTtEsT")
    }
    
    func testGetRawLettersAndDigitsText() {
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.secureText = " Aa11_22:22/33+ 2s"
        XCTAssertTrue(textfield.textField.getSecureRawText == " Aa11_22:22/33+ 2s")
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.secureText = "Aa1122223333444455556"
        XCTAssertTrue(textfield.textField.getSecureRawText == "Aa11")

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.secureText = " tE2 5test"
        XCTAssertTrue(textfield.textField.getSecureRawText == "tE25")
    }
    
    func testAddDevider() {
        configuration.formatPattern = "#### ####-####.####"
        configuration.devider = "-"
        textfield.configuration = configuration
        textfield.textField.secureText = "5252525252525252"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "5252-5252-5252-5252")
        
        configuration.formatPattern = "-####-"
        configuration.devider = "+"
        textfield.configuration = configuration
        textfield.textField.secureText = "5252525252525252"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "+5252+")
        
        configuration.formatPattern = " AAA/aaa/####"
        configuration.devider = "__"
        textfield.configuration = configuration
        textfield.textField.secureText = "XYZxyz123456789wertert"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "__XYZ__xyz__1234")
        
        configuration.formatPattern = " #-#--#---#"
        configuration.devider = "-"
        textfield.configuration = configuration
        textfield.textField.secureText = "12345678"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "-1-2--3---4")
    }
    
    func testDefaultDevider() {
        configuration.type = .cardNumber
        configuration.devider = nil
        configuration.formatPattern = "#### ####.####-####"
        textfield.configuration = configuration
        textfield.textField.secureText = "5252525252525252"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "5252525252525252")
        
        configuration.type = .expDate
        configuration.devider = nil
        configuration.formatPattern = nil
        textfield.configuration = configuration
        textfield.textField.secureText = "1234"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "12/34")
        
        configuration.type = .cardHolderName
        configuration.devider = nil
        configuration.formatPattern = nil
        textfield.configuration = configuration
        textfield.textField.secureText = "Joe's Business"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "Joe's Business")
        
        configuration.type = .cvc
        configuration.formatPattern =  nil
        configuration.devider = nil
        textfield.configuration = configuration
        textfield.textField.secureText = "1234"
        XCTAssertTrue(textfield.textField.getSecureTextWithDevider == "1234")
    }
}
