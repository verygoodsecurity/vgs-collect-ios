//
//  DateTextField.swift
//  VGSCollectSDK
//

import XCTest
@testable import VGSCollectSDK

class DateTextFieldTest: VGSCollectBaseTestCase {
    
    // MARK: - Properties
    private var collector: VGSCollect!
    private var textField: VGSDateTextField!
    
    // MARK: - Overrides
    override func setUp() {
        super.setUp()
        
        collector = VGSCollect(id: "any")
        textField = VGSDateTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "textField")
        config.formatPattern = VGSDateFormat.default.formatPattern
        textField.configuration = config
    }
    
    override func tearDown() {
        collector = nil
        textField = nil
    }
    
    // MARK: - Tests
    /// Test when different month formats are selected
    func testMonthFormat() {
        /// Define the first month `January` for each month format
        let firstLongAr = "يناير"
        var validLongMonth = "January"
        var validShortMonth = "Jan"
        
        /// For Arabic long and short month is the same.
        if Locale.current.languageCode == "ar" {
            validLongMonth = firstLongAr
            validShortMonth = firstLongAr
        }
        
        /// Asserts
        textField.monthPickerFormat = .longSymbols
        XCTAssertEqual(textField.monthsDataSource.first, validLongMonth)
        textField.monthPickerFormat = .shortSymbols
        XCTAssertEqual(textField.monthsDataSource.first, validShortMonth)
        textField.monthPickerFormat = .numbers
        XCTAssertEqual(textField.monthsDataSource.last, "12")
    }
    
    /// Test when a valid date is selected using the default start and end date range
    func testSelectDateWithDefaultDateRange() {
        /// Select month
        let monthSelected = 0
        textField.picker.selectRow(monthSelected, inComponent: 0, animated: false)
        textField.pickerView(textField.picker, didSelectRow: monthSelected, inComponent: 0)
        
        /// Select day
        let daySelected = 8
        textField.picker.selectRow(daySelected, inComponent: 1, animated: false)
        textField.pickerView(textField.picker, didSelectRow: daySelected, inComponent: 1)
        
        /// Select year
        let yearSelected = 61
        textField.picker.selectRow(yearSelected, inComponent: 2, animated: false)
        textField.pickerView(textField.picker, didSelectRow: yearSelected, inComponent: 2)
        
        /// Get selected date
        let currentValue = textField.textField.secureText
        let monthComponent = currentValue?.components(separatedBy: "-").first ?? "0"
        let dayComponent = currentValue?.components(separatedBy: "-")[1] ?? "0"
        let yearComponent = currentValue?.components(separatedBy: "-").last ?? "0"
        
        /// Asserts: Validate the selected date is correct
        XCTAssertEqual(Int(monthComponent), monthSelected + 1)
        XCTAssertEqual(Int(dayComponent), daySelected + 1)
        XCTAssertEqual(Int(yearComponent), (Calendar.currentYear - VGSDateConfiguration.validYearsCount) + yearSelected)
    }
    
    /// Test when an invalid date is selected using the default start and end date range
    func testSelectWrongDateWithDefaultDateRange() {
        /// Select month
        let monthSelected = 0
        textField.picker.selectRow(monthSelected, inComponent: 0, animated: false)
        textField.pickerView(textField.picker, didSelectRow: monthSelected, inComponent: 0)
        
        /// Select day
        let daySelected = 8
        textField.picker.selectRow(daySelected, inComponent: 1, animated: false)
        textField.pickerView(textField.picker, didSelectRow: daySelected, inComponent: 1)
        
        /// Select invalid year, outside valid default range
        let yearSelected = VGSDateConfiguration.validYearsCount * 3
        textField.picker.selectRow(yearSelected, inComponent: 2, animated: false)
        textField.pickerView(textField.picker, didSelectRow: yearSelected, inComponent: 2)
        
        /// Get selected date
        let currentValue = textField.textField.secureText
        let monthComponent = currentValue?.components(separatedBy: "-").first ?? "0"
        let dayComponent = currentValue?.components(separatedBy: "-")[1] ?? "0"
        let yearComponent = currentValue?.components(separatedBy: "-").last ?? "0"
        
        /// Asserts: Selecting invalid day, month or year should be ignored
        XCTAssertEqual(Int(monthComponent), monthSelected + 1)
        XCTAssertEqual(Int(dayComponent), daySelected + 1)
        XCTAssertEqual(Int(yearComponent), Calendar.currentYear - VGSDateConfiguration.validYearsCount)
    }
    
    /// Test when a valid date is selected with a configuration that has custom start and end dates
    func testSelectDateWithCustomDateRange() {
        /// Define custom dates
        let startDate = VGSDate(day: 1, month: 1, year: 2000)!
        let endDate = VGSDate(day: 1, month: 1, year: 2030)!
        
        /// Setup custom configuration
        let customConfig = VGSDateConfiguration(
            collector: collector,
            fieldName: "textField",
            datePickerStartDate: startDate,
            datePickerEndDate: endDate
        )
        textField.configuration = customConfig
        
        /// Select month
        let monthSelected = 6
        textField.picker.selectRow(monthSelected, inComponent: 0, animated: false)
        textField.pickerView(textField.picker, didSelectRow: monthSelected, inComponent: 0)
        
        /// Select day
        let daySelected = 15
        textField.picker.selectRow(daySelected, inComponent: 1, animated: false)
        textField.pickerView(textField.picker, didSelectRow: daySelected, inComponent: 1)
        
        /// Select year, exactly the middle between start and end dates
        let yearSelected = (endDate.year - startDate.year) / 2
        textField.picker.selectRow(yearSelected, inComponent: 2, animated: false)
        textField.pickerView(textField.picker, didSelectRow: yearSelected, inComponent: 2)
        
        /// Get current date
        let currentValue = textField.textField.secureText
        let monthComponent = currentValue?.components(separatedBy: "-").first ?? "0"
        let dayComponent = currentValue?.components(separatedBy: "-")[1] ?? "0"
        let yearComponent = currentValue?.components(separatedBy: "-").last ?? "0"
        
        /// Asserts: The selected year should be the same selected in the textField
        XCTAssertEqual(Int(monthComponent), monthSelected + 1)
        XCTAssertEqual(Int(dayComponent), daySelected + 1)
        XCTAssertEqual(Int(yearComponent), startDate.year + yearSelected)
        XCTAssertEqual(Int(yearComponent), endDate.year - yearSelected)
    }
    
    /// Test when an invalid date is selected with a configuration that has custom start and end dates
    func testSelectWrongDateWithCustomDateRange() {
        /// Define custom dates
        let startDate = VGSDate(day: 1, month: 1, year: 2000)!
        let endDate = VGSDate(day: 1, month: 1, year: 2030)!
        
        /// Setup custom configuration
        let customConfig = VGSDateConfiguration(
            collector: collector,
            fieldName: "textField",
            datePickerStartDate: startDate,
            datePickerEndDate: endDate
        )
        textField.configuration = customConfig
        
        /// Select month
        let monthSelected = 6
        textField.picker.selectRow(monthSelected, inComponent: 0, animated: false)
        textField.pickerView(textField.picker, didSelectRow: monthSelected, inComponent: 0)
        
        /// Select invalid day, outside the custom range
        let daySelected = 50
        textField.picker.selectRow(daySelected, inComponent: 1, animated: false)
        textField.pickerView(textField.picker, didSelectRow: daySelected, inComponent: 1)
        
        /// Select year
        let yearSelected = 5
        textField.picker.selectRow(yearSelected, inComponent: 2, animated: false)
        textField.pickerView(textField.picker, didSelectRow: yearSelected, inComponent: 2)
        
        /// Get current date
        let currentValue = textField.textField.secureText
        let monthComponent = currentValue?.components(separatedBy: "-").first ?? "0"
        let dayComponent = currentValue?.components(separatedBy: "-")[1] ?? "0"
        let yearComponent = currentValue?.components(separatedBy: "-").last ?? "0"
        
        /// Asserts: Selecting invalid day, month or year should be ignored
        XCTAssertEqual(Int(monthComponent), monthSelected + 1)
        XCTAssertEqual(Int(dayComponent), 1)
        XCTAssertEqual(Int(yearComponent), startDate.year + yearSelected)
    }
    
    /// Test when the keyboard configuration is selected in the configuration
    func testDateKeyboardConfiguration() {
        /// Setup custom configuration with keyboard
        let customConfig = VGSDateConfiguration(collector: collector, fieldName: "textField")
        customConfig.inputSource = .keyboard
        customConfig.keyboardType = .namePhonePad
        customConfig.returnKeyType = .go
        customConfig.keyboardAppearance = .dark
        textField.configuration = customConfig
        
        /// Asserts
        XCTAssertTrue(textField.textField.keyboardType == customConfig.keyboardType, "Wrong keyboardType!")
        XCTAssertTrue(textField.textField.returnKeyType == customConfig.returnKeyType, "Wrong returnKeyType!")
        XCTAssertTrue(textField.textField.keyboardAppearance == customConfig.keyboardAppearance, "Wrong keyboardAppearance!")
    }
    
    /// Test when the picker configuration is selected in the configuration
    func testDateDatePickerConfiguration() {
        /// Setup custom configuration with date picker
        let customConfig = VGSDateConfiguration(collector: collector, fieldName: "textField")
        customConfig.inputSource = .datePicker
        textField.configuration = customConfig
        
        /// Asserts
        XCTAssertTrue(textField.textField.inputView != nil, "Date picker not set!")
        XCTAssertTrue(textField.textField.inputView is UIPickerView, "Wrong date picker view!")
    }
  
    /// Test accessibility properties
    func testAccessibilityAttributes() {
        // Hint
        let accHint = "accessibility hint"
        textField.textFieldAccessibilityHint = accHint
        XCTAssertNotNil(textField.textFieldAccessibilityHint)
        XCTAssertEqual(textField.textFieldAccessibilityHint, accHint)
        
        // Label
        let accLabel = "accessibility label"
        textField.textFieldAccessibilityLabel = accLabel
        XCTAssertNotNil(textField.textFieldAccessibilityLabel)
        XCTAssertEqual(textField.textFieldAccessibilityLabel, accLabel)
        
        // Element
        textField.textFieldIsAccessibilityElement = true
        XCTAssertTrue(textField.textFieldIsAccessibilityElement)
        
        // Value
        let accValue = "accessibility value"
        textField.textField.secureText = accValue
        XCTAssertTrue(textField.textField.secureText!.isEmpty)
        XCTAssertNil(textField.textField.accessibilityValue)
    }
}
