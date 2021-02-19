//
//  ExpDateTextFieldTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ExpDateTextFieldTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var expDateTextField: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "tntva5wfdrp")
        expDateTextField = VGSTextField()
        expDateTextField.textField.secureText = "1223"
    }
    
    override func tearDown() {
        expDateTextField.configuration = nil
        collector  = nil
        expDateTextField = nil
    }
    
    func testAlias() {
        let config = VGSConfiguration(collector: collector, fieldName: "expDate")
        config.type = .expDate
        expDateTextField.configuration = config
        XCTAssertTrue(expDateTextField.state.fieldName == "expDate")
    }
    
    func testNotValidDateReturnsFalse() {
        
        let notValidShortDates = [
            "21/23", "01/20", "01/01", "00/00",
            "20/12", "01/50", "1/25", "12/3"
        ]

        /// default configuration
        let config = VGSConfiguration(collector: collector, fieldName: "expDate")
        config.type = .expDate
        expDateTextField.configuration = config

        for date in notValidShortDates {
            expDateTextField.textField.secureText = date
            expDateTextField.focusOn()
            XCTAssertFalse(expDateTextField.state.isValid)
            XCTAssertFalse(expDateTextField.state.isEmpty)
        }

        /// short date format configuration
        config.formatPattern = DateFormatPattern.shortYear.rawValue
        expDateTextField.configuration = config

        for date in notValidShortDates {
            expDateTextField.textField.secureText = date
            expDateTextField.focusOn()
            XCTAssertFalse(expDateTextField.state.isValid)
            XCTAssertFalse(expDateTextField.state.isEmpty)
        }

        let notValidLongDates = [
            "21/2023", "01/2020", "01/2001", "00/0000",
            "20/1212", "01/2050", "1/2025", "12/203"
        ]

        /// long date format configuration
        config.formatPattern = DateFormatPattern.longYear.rawValue
        expDateTextField.configuration = config

        for date in notValidLongDates {
          expDateTextField.textField.secureText = date
          expDateTextField.focusOn()
          XCTAssertFalse(expDateTextField.state.isValid)
          XCTAssertFalse(expDateTextField.state.isEmpty)
        }
        
    }
    
    func testValidDateReturnsTrue() {
        
        /// Test today
        let today = Date()
        let formatter = DateFormatter()

        formatter.dateFormat = "yy"
        let todayYY = formatter.string(from: today)
        
        formatter.dateFormat = "yyyy"
        let todayYYYY = formatter.string(from: today)

        formatter.dateFormat = "MM"
        let todayMM = formatter.string(from: today)
        let todayShort = "\(todayMM)/\(todayYY)"
        let todayLong = "\(todayMM)/\(todayYYYY)"
        
        let validShortDates = [
            "01/23", "10/25", "12/40", "01/30", todayShort
        ]
        
        /// default configuration
        let config = VGSConfiguration(collector: collector, fieldName: "expDate")
        expDateTextField.configuration = config
        
        for date in validShortDates {
            expDateTextField.textField.secureText = date
            expDateTextField.focusOn()
            XCTAssertTrue(expDateTextField.state.isValid)
            XCTAssertFalse(expDateTextField.state.isEmpty)
        }
        
        /// short date format configuration
        config.formatPattern = DateFormatPattern.shortYear.rawValue
        expDateTextField.configuration = config
        
        for date in validShortDates {
            expDateTextField.textField.secureText = date
            expDateTextField.focusOn()
            XCTAssertTrue(expDateTextField.state.isValid)
            XCTAssertFalse(expDateTextField.state.isEmpty)
        }
        
        let validLongDates = [
            "01/2023", "10/2025", "12/2040", "01/2030", todayLong
        ]
        
        /// long date format configuration
        config.formatPattern = DateFormatPattern.longYear.rawValue
        expDateTextField.configuration = config
        
        for date in validLongDates {
            expDateTextField.textField.secureText = date
            expDateTextField.focusOn()
            XCTAssertTrue(expDateTextField.state.isValid)
            XCTAssertFalse(expDateTextField.state.isEmpty)
        }
    }
}
