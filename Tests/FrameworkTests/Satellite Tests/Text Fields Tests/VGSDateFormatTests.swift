//
//  VGSDateFormatTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK

class VGSDateFormatTests: VGSCollectBaseTestCase {
    
    // MARK: - Tests
    /// Test date format initialization
    func testDateFormatInitialization() {
        /// Date format mmddyyyy
        let mmddyyyyFormat = VGSDateFormat(name: "mmddyyyy")
        XCTAssertEqual(mmddyyyyFormat, .mmddyyyy)
        
        /// Date format ddmmyyyy
        let ddmmyyyyFormat = VGSDateFormat(name: "ddmmyyyy")
        XCTAssertEqual(ddmmyyyyFormat, .ddmmyyyy)
        
        /// Date format yyyymmdd
        let yyyymmddFormat = VGSDateFormat(name: "yyyymmdd")
        XCTAssertEqual(yyyymmddFormat, .yyyymmdd)
        
        /// Invalid format
        let invalidFormat = VGSDateFormat(name: "any")
        XCTAssertNil(invalidFormat)
    }
    
    /// Test the amount of expected characters for each part of the date
    func testAmountOfCharacters() {
        /// Expected values
        let expectedDays = 2
        let expectedMonths = 2
        let expectedYears = 4
        let expectedDivider = 2
        
        /// Days
        XCTAssertEqual(VGSDateFormat.mmddyyyy.daysCharacters, expectedDays)
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.daysCharacters, expectedDays)
        XCTAssertEqual(VGSDateFormat.yyyymmdd.daysCharacters, expectedDays)
        
        /// Months
        XCTAssertEqual(VGSDateFormat.mmddyyyy.monthCharacters, expectedMonths)
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.monthCharacters, expectedMonths)
        XCTAssertEqual(VGSDateFormat.yyyymmdd.monthCharacters, expectedMonths)
        
        /// Years
        XCTAssertEqual(VGSDateFormat.mmddyyyy.yearCharacters, expectedYears)
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.yearCharacters, expectedYears)
        XCTAssertEqual(VGSDateFormat.yyyymmdd.yearCharacters, expectedYears)
        
        /// Divider
        XCTAssertEqual(VGSDateFormat.mmddyyyy.dividerCharacters, expectedDivider)
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.dividerCharacters, expectedDivider)
        XCTAssertEqual(VGSDateFormat.yyyymmdd.dividerCharacters, expectedDivider)
    }
    
    /// Test when the map picker data is formatted
    func testMapDatePickerDataForFieldFormat() {
        /// Expected date
        let date = VGSDate(day: 2, month: 5, year: 2016)!
        
        /// mmddyyyy
        XCTAssertEqual(VGSDateFormat.mmddyyyy.mapDatePickerDataForFieldFormat(date), "05022016")
        
        /// ddmmyyyy
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.mapDatePickerDataForFieldFormat(date), "02052016")
        
        /// yyyymmdd
        XCTAssertEqual(VGSDateFormat.yyyymmdd.mapDatePickerDataForFieldFormat(date), "20160502")
    }
    
    /// Test when the format date is called
    func testFormatDate() {
        /// Expected date
        let date = VGSDate(day: 2, month: 5, year: 2016)!
        
        /// Divider A
        var divider = "_"
        XCTAssertEqual(VGSDateFormat.mmddyyyy.formatDate(date, divider: divider), "05\(divider)02\(divider)2016")
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.formatDate(date, divider: divider), "02\(divider)05\(divider)2016")
        XCTAssertEqual(VGSDateFormat.yyyymmdd.formatDate(date, divider: divider), "2016\(divider)05\(divider)02")
        
        /// Divider B
        divider = "+_+"
        XCTAssertEqual(VGSDateFormat.mmddyyyy.formatDate(date, divider: divider), "05\(divider)02\(divider)2016")
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.formatDate(date, divider: divider), "02\(divider)05\(divider)2016")
        XCTAssertEqual(VGSDateFormat.yyyymmdd.formatDate(date, divider: divider), "2016\(divider)05\(divider)02")
        
        /// Divider C
        divider = "/"
        XCTAssertEqual(VGSDateFormat.mmddyyyy.formatDate(date, divider: divider), "05\(divider)02\(divider)2016")
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.formatDate(date, divider: divider), "02\(divider)05\(divider)2016")
        XCTAssertEqual(VGSDateFormat.yyyymmdd.formatDate(date, divider: divider), "2016\(divider)05\(divider)02")
        
        /// Divider C
        divider = "..."
        XCTAssertEqual(VGSDateFormat.mmddyyyy.formatDate(date, divider: divider), "05\(divider)02\(divider)2016")
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.formatDate(date, divider: divider), "02\(divider)05\(divider)2016")
        XCTAssertEqual(VGSDateFormat.yyyymmdd.formatDate(date, divider: divider), "2016\(divider)05\(divider)02")
    }
    
    /// Test when a date is created from an input string
    func testDateFromInput() {
        /// Expected date
        let date = VGSDate(day: 2, month: 5, year: 2016)!
        
        /// mmddyyyy
        XCTAssertEqual(VGSDateFormat.mmddyyyy.dateFromInput("05022016"), date)
        
        /// ddmmyyyy
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.dateFromInput("02052016"), date)
        
        /// yyyymmdd
        XCTAssertEqual(VGSDateFormat.yyyymmdd.dateFromInput("20160502"), date)
        
        /// Invalid input
        XCTAssertNil(VGSDateFormat.mmddyyyy.dateFromInput("any"))
    }
    
    /// Test the display format
    func testDisplayFormat() {
        /// mmddyyyy
        XCTAssertEqual(VGSDateFormat.mmddyyyy.displayFormat, "mm-dd-yyyy")
        
        /// ddmmyyyy
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.displayFormat, "dd-mm-yyyy")
        
        /// yyyymmdd
        XCTAssertEqual(VGSDateFormat.yyyymmdd.displayFormat, "yyyy-mm-dd")
    }
    
    /// Test format pattern
    func testFormatPattern() {
        /// mmddyyyy
        XCTAssertEqual(VGSDateFormat.mmddyyyy.formatPattern, "##-##-####")
        
        /// ddmmyyyy
        XCTAssertEqual(VGSDateFormat.ddmmyyyy.formatPattern, "##-##-####")
        
        /// yyyymmdd
        XCTAssertEqual(VGSDateFormat.yyyymmdd.formatPattern, "####-##-##")
    }
    
    /// Test to get the divider in an input date string
    func testDividerInInput() {
        /// Divider A
        var divider = "_"
        XCTAssertEqual(VGSDateFormat.dividerInInput("05\(divider)02\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("02\(divider)05\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("2016\(divider)05\(divider)02"), divider)
        
        /// Divider B
        divider = "+_+"
        XCTAssertEqual(VGSDateFormat.dividerInInput("05\(divider)02\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("02\(divider)05\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("2016\(divider)05\(divider)02"), divider)
        
        /// Divider C
        divider = "/"
        XCTAssertEqual(VGSDateFormat.dividerInInput("05\(divider)02\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("02\(divider)05\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("2016\(divider)05\(divider)02"), divider)
        
        /// Divider C
        divider = "..."
        XCTAssertEqual(VGSDateFormat.dividerInInput("05\(divider)02\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("02\(divider)05\(divider)2016"), divider)
        XCTAssertEqual(VGSDateFormat.dividerInInput("2016\(divider)05\(divider)02"), divider)
        
        /// Invalid input
        XCTAssertEqual(VGSDateFormat.dividerInInput("05|02-2016"), "")
        XCTAssertEqual(VGSDateFormat.dividerInInput("05-02*2016"), "")
        XCTAssertEqual(VGSDateFormat.dividerInInput("05-..-022016"), "")
    }
}
