//
//  DateTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK

class DateTests: VGSCollectBaseTestCase {
    
    // MARK: - Tests
    /// Test date initialization
    func testDateInitialization() {
        /// Valid date
        let validDate = VGSDate(day: 1, month: 1, year: 2010)
        XCTAssertNotNil(validDate)
        
        /// Invalid date
        let invalidDate = VGSDate(day: 50, month: 50, year: 2)
        XCTAssertNil(invalidDate)
    }
    
    /// Test date formatted
    func testFormatters() {
        /// Date
        let date = VGSDate(day: 2, month: 6, year: 2010)
        XCTAssertNotNil(date)
        
        /// Validate formatted month and day
        XCTAssertEqual(date?.dayFormatted, "02")
        XCTAssertEqual(date?.monthFormatted, "06")
    }
    
    /// Test date comparable
    func testDateComparable() {
        /// Dates
        let dateA = VGSDate(day: 12, month: 5, year: 2010)!
        var dateB = VGSDate(day: 12, month: 5, year: 2010)!
        
        /// Validate equals
        XCTAssertEqual(dateA, dateB)
        
        /// Validate not equals
        dateB.year = 2011
        XCTAssertNotEqual(dateA, dateB)
        
        /// Validate less than
        XCTAssertLessThan(dateA, dateB)
        
        /// Validate greater than
        XCTAssertGreaterThan(dateB, dateA)
    }
}
