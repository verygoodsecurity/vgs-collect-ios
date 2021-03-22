//
//  ExpDateTextField.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 17.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ExpDateTextField: VGSCollectBaseTestCase {

    var collector: VGSCollect!
    var textField: VGSExpDateTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "any")
        textField = VGSExpDateTextField()
        let config = VGSConfiguration(collector: collector, fieldName: "textField")
        config.formatPattern = "##/####"
        textField.configuration = config
    }

    override func tearDown() {
        collector = nil
        textField = nil
    }
    
    func testMonthFormat() {
        textField.monthPickerFormat = .longSymbols
        XCTAssertTrue(textField.monthsDataSource.first == "January")
        textField.monthPickerFormat = .shortSymbols
        XCTAssertTrue(textField.monthsDataSource.first == "Jan")
        textField.monthPickerFormat = .numbers
        XCTAssertTrue(textField.monthsDataSource.last == "12")
    }

    func testYearFormat() {
        textField.yearPickeFormat = .long
        XCTAssertTrue(textField.yearsDataSource.first == String(Calendar.currentYear))
        textField.yearPickeFormat = .short
        XCTAssertTrue(textField.yearsDataSource.first == String(Calendar.currentYear - 2000))
    }
    
    func testSelectDate() {
        let monthSelected = 10
        let yearSelected = 5
        textField.picker.selectRow(yearSelected, inComponent: 1, animated: false)
        textField.pickerView(textField.picker, didSelectRow: yearSelected, inComponent: 1)
        textField.picker.selectRow(monthSelected, inComponent: 0, animated: false)
        textField.pickerView(textField.picker, didSelectRow: monthSelected, inComponent: 0)

        let currentValue = textField.textField.secureText
        let monthComponent = currentValue?.components(separatedBy: "/").first ?? "0"
        let yearComponent = currentValue?.components(separatedBy: "/").last ?? "0"
        
        XCTAssertTrue(Int(monthComponent) == monthSelected + 1)
        XCTAssertTrue(Int(yearComponent) == Calendar.currentYear + yearSelected)
    }
    
    func testSelectWrongDate() {
        textField.picker.selectRow(0, inComponent: 1, animated: false)
        textField.picker.selectRow(0, inComponent: 0, animated: false)
        textField.pickerView(textField.picker, didSelectRow: 0, inComponent: 0)
        let currentValue = textField.textField.secureText
        
        let currentMonth = Calendar.currentMonth
        let currentYear = Calendar.currentYear
        let monthComponent = currentValue?.components(separatedBy: "/").first ?? "0"
        let yearComponent = currentValue?.components(separatedBy: "/").last ?? "0"
        
        XCTAssertTrue(Int(monthComponent) == currentMonth)
        XCTAssertTrue(Int(yearComponent) == currentYear)
    }
}
