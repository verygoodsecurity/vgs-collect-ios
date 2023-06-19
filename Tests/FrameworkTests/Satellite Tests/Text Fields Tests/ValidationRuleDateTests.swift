//
//  ValidationRuleDateTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK

class ValidationRuleDateTests: VGSCollectBaseTestCase {
    
    // MARK: - Constants
    /// Default error
    private let error = "date_error"
    
    // MARK: - Properties
    private var collector: VGSCollect!
    private var textField: VGSTextField!
    private var config: VGSConfiguration!
    
    // MARK: - Overrides
    override func setUp() {
        super.setUp()
        
        collector = VGSCollect(id: "any")
        textField = VGSTextField()
        config = VGSConfiguration(collector: collector, fieldName: "test_field")
        config.type = .date
    }
    
    override func tearDown() {
        collector = nil
        textField = nil
        config = nil
    }
    
    // MARK: - Tests
    /// Test date validation rule with default configuration
    func testDateRule() {
        /// Test validation success
        textField.configuration = config
        textField.textField.secureText = "10102004"
        XCTAssertTrue(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 0)
        
        /// Test invalid format
        textField.textField.secureText = "102024"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
        
        /// Test invalid date, in this case month is `50`
        textField.textField.secureText = "50012024"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
    }
    
    /// Test each of the date formats
    func testRuleDateFormats() {
        /// Use `ddmmyyy` format
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRuleDateRange(
                dateFormat: .ddmmyyyy,
                error: error
            )
        ])
        
        /// Test validation success
        textField.configuration = config
        textField.textField.secureText = "20111984"
        XCTAssertTrue(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 0)
        
        /// Test validation fails
        textField.configuration = config
        textField.textField.secureText = "19841120"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
        
        /// Use `mmddyyyy` format
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRuleDateRange(
                dateFormat: .mmddyyyy,
                error: error
            )
        ])
        
        // Test validation success
        textField.configuration = config
        textField.textField.secureText = "11201984"
        XCTAssertTrue(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 0)
        
        /// Test validation fails
        textField.configuration = config
        textField.textField.secureText = "19842011"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
        
        /// Use `yyyymmdd` format
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRuleDateRange(
                dateFormat: .yyyymmdd,
                error: error
            )
        ])
        
        // Test validation success
        textField.configuration = config
        textField.textField.secureText = "19841120"
        XCTAssertTrue(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 0)
        
        /// Test validation fails
        textField.configuration = config
        textField.textField.secureText = "20111984"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
    }
    
    /// Test when start date and end date are set
    func testRuleWithStartAndEndDate() {
        /// Setup start and end dates
        let startDate = VGSDate(day: 10, month: 11, year: 2015)
        let endDate = VGSDate(day: 08, month: 12, year: 2030)
        
        /// Use default format
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRuleDateRange(
                error: error,
                start: startDate,
                end: endDate
            )
        ])
        
        /// Test validation success
        textField.configuration = config
        textField.textField.secureText = "10122020"
        XCTAssertTrue(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 0)
        
        /// Test validation fails, date before start date
        textField.configuration = config
        textField.textField.secureText = "1012215"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
        
        /// Test validation fails, date after end date
        textField.configuration = config
        textField.textField.secureText = "12102030"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
    }
    
    /// Test when only start date is set
    func testRuleWithStartDate() {
        /// Setup start date
        let startDate = VGSDate(day: 10, month: 11, year: 2015)
        
        /// Use default format
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRuleDateRange(
                error: error,
                start: startDate
            )
        ])
        
        /// Test validation success
        textField.configuration = config
        textField.textField.secureText = "10122020"
        XCTAssertTrue(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 0)
        
        /// Test validation fails, date before start date
        textField.configuration = config
        textField.textField.secureText = "1012215"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
    }
    
    /// Test when only end date is set
    func testRuleWithEndDate() {
        /// Setup end date
        let endDate = VGSDate(day: 08, month: 12, year: 2030)
        
        /// Use default format
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRuleDateRange(
                error: error,
                end: endDate
            )
        ])
        
        /// Test validation success
        textField.configuration = config
        textField.textField.secureText = "10122020"
        XCTAssertTrue(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 0)
        
        /// Test validation fails, date after end date
        textField.configuration = config
        textField.textField.secureText = "12102030"
        XCTAssertFalse(textField.state.isValid)
        XCTAssertEqual(textField.state.validationErrors.count, 1)
    }
}
