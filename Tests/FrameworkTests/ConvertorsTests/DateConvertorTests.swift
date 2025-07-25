//
//  DateConvertorTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK
@MainActor
class DateConvertorTests: VGSCollectBaseTestCase {
    
    // MARK: - Properties
    private var collector: VGSCollect!
    private var textField: VGSDateTextField!
    
    // MARK: - Inner objects
    struct TestDataType {
        let input: String
        let output: String
    }
    
    // MARK: - Overrides
    override func setUp() {
        super.setUp()
        
        collector = VGSCollect(id: "any")
        textField = VGSDateTextField()
    }
    
    override func tearDown() {
        collector = nil
        textField = nil
    }
    
    // MARK: - Tests
    /// Test to convert a date from default format
    func testConvertDate() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "12/10/2021", output: "12/10/2021"),
            TestDataType(input: "01/04/2050", output: "01/04/2050"),
            TestDataType(input: "05/07/2100", output: "05/07/2100")
        ]
        
        /// Assert: Test dates output
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from ddmmyyy to ddmmyyy
    func testConvertDate_ddmmyyyy_to_ddmmyyyy() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.ddmmyyyy.formatPattern
        config.inputDateFormat = .ddmmyyyy
        config.outputDateFormat = .ddmmyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "12/10/2021", output: "12/10/2021"),
            TestDataType(input: "01/04/2050", output: "01/04/2050"),
            TestDataType(input: "05/07/2100", output: "05/07/2100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from ddmmyyy to mmddyyyy
    func testConvertDate_ddmmyyyy_to_mmddyyyy() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.ddmmyyyy.formatPattern
        config.inputDateFormat = .ddmmyyyy
        config.outputDateFormat = .mmddyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "12/10/2021", output: "10/12/2021"),
            TestDataType(input: "01/04/2050", output: "04/01/2050"),
            TestDataType(input: "05/07/2100", output: "07/05/2100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from ddmmyyy to yyyymmdd
    func testConvertDate_ddmmyyyy_to_yyyymmdd() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.ddmmyyyy.formatPattern
        config.inputDateFormat = .ddmmyyyy
        config.outputDateFormat = .yyyymmdd
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "12/10/2021", output: "2021/10/12"),
            TestDataType(input: "01/04/2050", output: "2050/04/01"),
            TestDataType(input: "05/07/2100", output: "2100/07/05")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from mmddyyyy to mmddyyyy
    func testConvertDate_mmddyyyy_to_mmddyyyy() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.mmddyyyy.formatPattern
        config.inputDateFormat = .mmddyyyy
        config.outputDateFormat = .mmddyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "10/12/2021", output: "10/12/2021"),
            TestDataType(input: "04/01/2050", output: "04/01/2050"),
            TestDataType(input: "07/05/2100", output: "07/05/2100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from mmddyyyy to ddmmyyy
    func testConvertDate_mmddyyyy_to_ddmmyyy() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.mmddyyyy.formatPattern
        config.inputDateFormat = .mmddyyyy
        config.outputDateFormat = .ddmmyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "10/12/2021", output: "12/10/2021"),
            TestDataType(input: "04/01/2050", output: "01/04/2050"),
            TestDataType(input: "07/05/2100", output: "05/07/2100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from mmddyyyy to yyyymmdd
    func testConvertDate_mmddyyyy_to_yyyymmdd() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.mmddyyyy.formatPattern
        config.inputDateFormat = .mmddyyyy
        config.outputDateFormat = .yyyymmdd
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "10/12/2021", output: "2021/10/12"),
            TestDataType(input: "04/01/2050", output: "2050/04/01"),
            TestDataType(input: "07/05/2100", output: "2100/07/05")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from yyyymmdd to yyyymmdd
    func testConvertDate_yyyymmdd_to_yyyymmdd() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.yyyymmdd.formatPattern
        config.inputDateFormat = .yyyymmdd
        config.outputDateFormat = .yyyymmdd
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "2021/10/12", output: "2021/10/12"),
            TestDataType(input: "2050/04/01", output: "2050/04/01"),
            TestDataType(input: "2100/07/05", output: "2100/07/05")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }

    /// Test to convert a date from yyyymmdd to mmddyyyy
    func testConvertDate_yyyymmdd_to_mmddyyyy() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.yyyymmdd.formatPattern
        config.inputDateFormat = .yyyymmdd
        config.outputDateFormat = .mmddyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "2021/10/12", output: "10/12/2021"),
            TestDataType(input: "2050/04/01", output: "04/01/2050"),
            TestDataType(input: "2100/07/05", output: "07/05/2100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date from yyyymmdd to ddmmyyy
    func testConvertDate_yyyymmdd_to_ddmmyyy() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.yyyymmdd.formatPattern
        config.inputDateFormat = .yyyymmdd
        config.outputDateFormat = .ddmmyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "2021/10/12", output: "12/10/2021"),
            TestDataType(input: "2050/04/01", output: "01/04/2050"),
            TestDataType(input: "2100/07/05", output: "05/07/2100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date with an empty divider
    func testConvertDateEmptyDivider() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.ddmmyyyy.formatPattern
        config.divider = ""
        config.inputDateFormat = .ddmmyyyy
        config.outputDateFormat = .ddmmyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "12/10/2021", output: "12102021"),
            TestDataType(input: "01/04/2050", output: "01042050"),
            TestDataType(input: "05/07/2100", output: "05072100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
    
    /// Test to convert a date with a custom divider
    func testConvertDateCustomDivider() {
        /// Setup configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "test_field")
        config.formatPattern = VGSDateFormat.ddmmyyyy.formatPattern
        config.divider = "-/-"
        config.inputDateFormat = .ddmmyyyy
        config.outputDateFormat = .ddmmyyyy
        textField.configuration = config
        
        /// Test dates
        let testDates: [TestDataType] = [
            TestDataType(input: "12/10/2021", output: "12-/-10-/-2021"),
            TestDataType(input: "01/04/2050", output: "01-/-04-/-2050"),
            TestDataType(input: "05/07/2100", output: "05-/-07-/-2100")
        ]
        
        /// Assert: Test dates
        for date in testDates {
            textField.setText(date.input)
            XCTAssertEqual(textField.getOutputText(), date.output)
        }
    }
}
