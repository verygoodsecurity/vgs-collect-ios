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
        textfield.textField.text = "011122223333444455556"
        XCTAssertTrue(textfield.text == "0111 2222-3333.4444")
        
        configuration.formatPattern = "#### ####_####?##+##"
        textfield.configuration = configuration
        textfield.textField.text = " adf 01112222 333344445555sd"
        XCTAssertTrue(textfield.text == "0111 2222_3333?44+44")
    }
    
    func testLettersMaskingText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.text = "TEST test-tEsT.tEsTu"
        XCTAssertTrue(textfield.text == "TEST test-tEsT.tEsT")
        
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.text = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.text == "TEST test-tEsT.tEsT")
    }
    
    func testLettersAndDigitMaskingText() {
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.text = " Aa11_22:22/33+ 2s"
        XCTAssertTrue(textfield.text == " Aa11_22:22/33+ 2s")
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.text = "Aa1122223333444455556"
        XCTAssertTrue(textfield.text == "Aa11")

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.text = " tE2 5test"
        XCTAssertTrue(textfield.text == "tE./_:+25")
    }
    
    func testGetRawDigitsText() {
        configuration.formatPattern = "#### #### #### ####"
        textfield.configuration = configuration
        textfield.textField.text = "4111111111111111"
        XCTAssertTrue(textfield.rawText == "4111111111111111")
        
        configuration.formatPattern = " ####-####?####_####.#### "
        textfield.configuration = configuration
        textfield.textField.text = "411122223333444455556"
        XCTAssertTrue(textfield.rawText == "41112222333344445555")
        
        configuration.formatPattern = " _##/## "
        textfield.configuration = configuration
        textfield.textField.text = "012345678"
        XCTAssertTrue(textfield.rawText == "0123")
        
        configuration.formatPattern = "####-"
        textfield.configuration = configuration
        textfield.textField.text = "4111"
        XCTAssertTrue(textfield.rawText == "4111")
    }
    
    func testGetRawLettersText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.text = "TESTtesttEsTtEsTu"
        XCTAssertTrue(textfield.rawText == "TESTtesttEsTtEsT")
        
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.text = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.rawText == "TESTtesttEsTtEsT")
    }
    
    func testGetRawLettersAndDigitsText() {
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.text = " Aa11_22:22/33+ 2s"
        XCTAssertTrue(textfield.rawText == " Aa11_22:22/33+ 2s")
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.text = "Aa1122223333444455556"
        XCTAssertTrue(textfield.rawText == "Aa11")

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.text = " tE2 5test"
        XCTAssertTrue(textfield.rawText == "tE25")
    }
}
