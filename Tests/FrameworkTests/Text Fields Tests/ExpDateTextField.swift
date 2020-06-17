//
//  ExpDateTextField.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 17.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ExpDateTextField: XCTestCase {

    var collector: VGSCollect!
    var textField: VGSExpDateTextField!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
        
        textField = VGSExpDateTextField()
        let config = VGSConfiguration(collector: collector, fieldName: "textField")
        config.formatPattern = "##/####"
        textField.configuration = config
    }

    override func tearDown() {
        collector = nil
        textField = nil
    }

    func testType() {
        XCTAssertTrue(textField.fieldType == .expDate)
        
        let newConfig = VGSConfiguration(collector: collector, fieldName: "some_name")
        newConfig.type = .cvc
        
        
        XCTAssertTrue(textField.fieldType == .expDate)
    }
    
    func testMonthFormat() {
        let firstSymbol = textField.monthsSymbol.first
        let lastSymbol = textField.monthsSymbol.last
        
        XCTAssertTrue(firstSymbol == "01")
        XCTAssertTrue(lastSymbol == "12")
    }

    func testYearFormat() {
        // TBD: Needs improve this test with dynamic year
        
        var firstSymbol: String?
        var lastSymbol: String?
        
        var newConfig = VGSConfiguration(collector: collector, fieldName: "test_field1")
        newConfig.formatPattern = "##/####"
        
        textField.configuration = newConfig
        
        firstSymbol = textField.yearsSymbol.first
        lastSymbol = textField.yearsSymbol.last
        
        XCTAssertTrue(firstSymbol == "2020")
        XCTAssertTrue(lastSymbol == "2070")
        
        // Test default format "##/##"
        newConfig = VGSConfiguration(collector: collector, fieldName: "test_field2")
        
        textField.configuration = newConfig
        
        firstSymbol = textField.yearsSymbol.first
        lastSymbol = textField.yearsSymbol.last
        
        XCTAssertTrue(firstSymbol == "20")
        XCTAssertTrue(lastSymbol == "70")
    }
    
    func testMinimumSelectedDate() {
        let currentValue = textField.textField.secureText
        
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        let monthComponent = currentValue?.components(separatedBy: "/").first ?? "0"
        let yearComponent = currentValue?.components(separatedBy: "/").last ?? "0"
        
        let selectedMonth = Int(monthComponent)
        let selectedYear = Int(yearComponent)
        
        XCTAssertTrue(selectedMonth == currentMonth)
        XCTAssertTrue(selectedYear == currentYear)
    }
    
    func testSelectWrongDate() {
        // not shure if it's working correctlly
        textField.picker.selectRow(0, inComponent: 0, animated: false)
        
        let currentValue = textField.textField.secureText
        
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let monthComponent = currentValue?.components(separatedBy: "/").first ?? "0"
        let selectedMonth = Int(monthComponent)
        
        XCTAssertTrue(selectedMonth == currentMonth)
    }
}
