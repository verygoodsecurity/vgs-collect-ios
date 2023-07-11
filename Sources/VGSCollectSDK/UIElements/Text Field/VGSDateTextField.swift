//
//  VGSDateTextField.swift
//  VGSCollectSDK
//

import UIKit

// swiftlint:disable file_length
/// An object that displays an editable text area. Can be use instead of a `VGSTextField` when need to show picker view with a Date. It support to define a range of valid dates to select from.
public final class VGSDateTextField: VGSTextField {
    
    // MARK: - Inner objects
    /// Available month Label formats in `UIPickerView`
    public enum MonthFormat {
        /// Short month name, e.g.: `Jan`
        case shortSymbols
        /// Long month name, e.g.: `January`
        case longSymbols
        /// Month number: e.g.: `01`
        case numbers
    }
    
    // MARK: - Properties
    /// UIPickerView month label format
    public var monthPickerFormat: MonthFormat = .shortSymbols {
        didSet {
            updateMonthsDataSource()
        }
    }
    /// UIPickerView components order, it is based on the input format of the configuration
    internal var pickerDateFormat: VGSDateFormat?
    /// Visual day data source
    internal var daysDataSource = [String]()
    /// Visual month data source
    internal var monthsDataSource = [String]()
    /// Visual year data source
    internal var yearsDataSource = [String]()
    /// Valid days range, it is updated when the Month or Year are selected
    internal lazy var days = [Int]()
    /// Valid months range
    internal lazy var months = Array(1...12)
    /// Valid years range, it is updated when the configuration is set
    internal lazy var years = [Int]()
    /// Store the components index in the picker
    private let pickerComponent = (left: 0, center: 1, right: 2)
    
    // MARK: - Properties
    /// `UIPickerView` reference
    internal lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    // MARK: - Overridden methods and properties
    public override var configuration: VGSConfiguration? {
        didSet {
            fieldType = .date
        }
    }
    
    override func mainInitialization() {
        super.mainInitialization()
        setupDatePicker()
    }
    
    override func setupField(with configuration: VGSConfiguration) {
        super.setupField(with: configuration)
        guard let config = configuration as? VGSDateConfigurationProtocol else {
            return
        }
        
        // setup input source
        switch config.inputSource {
        case .datePicker:
            setupDatePicker()
        case .keyboard:
            setupKeyboard(with: configuration)
        }
    }
}

// MARK: - UIPickerViewDelegate and UIPickerViewDataSource implementation
extension VGSDateTextField: UIPickerViewDelegate, UIPickerViewDataSource {
    
    /// :nodoc: Picker view dataSource implementation.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    /// :nodoc: Picker view dataSource implementation.
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case pickerComponent.left:
            switch pickerDateFormat {
            case .ddmmyyyy:
                return daysDataSource.count
            case .mmddyyyy:
                return monthsDataSource.count
            case .yyyymmdd:
                return yearsDataSource.count
            default:
                // Default format: .mmddyyyy
                return monthsDataSource.count
            }
            
        case pickerComponent.center:
            switch pickerDateFormat {
            case .ddmmyyyy, .yyyymmdd:
                return monthsDataSource.count
            case .mmddyyyy:
                return daysDataSource.count
            default:
                // Default format: .mmddyyyy
                return daysDataSource.count
            }
            
        case pickerComponent.right:
            switch pickerDateFormat {
            case .ddmmyyyy, .mmddyyyy:
                return yearsDataSource.count
            case .yyyymmdd:
                return daysDataSource.count
            default:
                // Default format: .mmddyyyy
                return yearsDataSource.count
            }
            
        default:
            // This should never happend
            assertionFailure("No valid component index for picker")
            return 0
        }
    }
    
    /// :nodoc: Picker view delegate implementation.
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case pickerComponent.left:
            switch pickerDateFormat {
            case .ddmmyyyy:
                return daysDataSource[row]
            case .mmddyyyy:
                return monthsDataSource[row]
            case .yyyymmdd:
                return yearsDataSource[row]
            default:
                // Default format: .mmddyyyy
                return monthsDataSource[row]
            }
            
        case pickerComponent.center:
            switch pickerDateFormat {
            case .ddmmyyyy, .yyyymmdd:
                return monthsDataSource[row]
            case .mmddyyyy:
                return daysDataSource[row]
            default:
                // Default format: .mmddyyyy
                return daysDataSource[row]
            }
            
        case pickerComponent.right:
            switch pickerDateFormat {
            case .ddmmyyyy, .mmddyyyy:
                return yearsDataSource[row]
            case .yyyymmdd:
                return daysDataSource[row]
            default:
                // Default format: .mmddyyyy
                return yearsDataSource[row]
            }
            
        default:
            // This should never happend
            assertionFailure("No valid component index for picker")
            return ""
        }
    }
    
    /// :nodoc: Picker view delegate implementation.
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case pickerComponent.left:
            if pickerDateFormat == .mmddyyyy || pickerDateFormat == .yyyymmdd {
                updateDaysDataSource()
            }
            
        case pickerComponent.center:
            if pickerDateFormat == .ddmmyyyy || pickerDateFormat == .yyyymmdd {
                updateDaysDataSource()
            }
            
        case pickerComponent.right:
            if pickerDateFormat == .ddmmyyyy || pickerDateFormat == .mmddyyyy {
                updateDaysDataSource()
            }
        default:
            // This should never happend
            assertionFailure("No valid component index for picker")
        }
        
        // Update text selection
        updateTextFieldWithDatePickerSelection()
    }
}

// MARK: - Private methods
private extension VGSDateTextField {
    
    var pickerDayComponent: Int {
        switch pickerDateFormat {
        case .ddmmyyyy:
            return pickerComponent.left
        case .mmddyyyy:
            return pickerComponent.center
        case .yyyymmdd:
            return pickerComponent.right
        default:
            // Default format: .mmddyyyy
            return pickerComponent.center
        }
    }
    
    var pickerMonthComponent: Int {
        switch pickerDateFormat {
        case .ddmmyyyy, .yyyymmdd:
            return pickerComponent.center
        case .mmddyyyy:
            return pickerComponent.left
        default:
            // Default format: .mmddyyyy
            return pickerComponent.left
        }
    }
    
    var pickerYearComponent: Int {
        switch pickerDateFormat {
        case .ddmmyyyy, .mmddyyyy:
            return pickerComponent.right
        case .yyyymmdd:
            return pickerComponent.left
        default:
            // Default format: .mmddyyyy
            return pickerComponent.right
        }
    }
    
    func updateMonthsDataSource() {
        switch monthPickerFormat {
        case .shortSymbols:
            monthsDataSource = DateFormatter().shortMonthSymbols
        case .longSymbols:
            monthsDataSource = DateFormatter().monthSymbols
        case .numbers:
            monthsDataSource =  months.map { (String(format: "%02d", $0)) }
        }
    }
    
    func updateDaysDataSource() {
        /// Make sure it has valid data for months and years
        guard months.count > 0, years.count > 0 else {
            return
        }
        /// Get month and year
        var day = 0
        if days.count > 0 {
            day = days[picker.selectedRow(inComponent: pickerDayComponent)]
        }
        let month = months[picker.selectedRow(inComponent: pickerMonthComponent)]
        let year = years[picker.selectedRow(inComponent: pickerYearComponent)]
        
        /// Get amount of days in selected month and year
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: dateComponents)!
        
        // Get range of days in month
        if let range = calendar.range(of: .day, in: .month, for: date) {
            days = range.map { $0 }
        }
        daysDataSource = days.map { String($0) }
        
        // Reload days
        picker.reloadComponent(pickerDayComponent)
        
        // If the day is not valid in the month and year, update it to the last one in the days collection
        if day >= days.count {
            picker.selectRow(days.count - 1, inComponent: pickerDayComponent, animated: true)
        }
    }
    
    func updateYearsDataSource() {
        /// Make sure the configuration is valid
        if let config  = configuration as? VGSDateConfiguration {
            years = config.years
        } else if let tokenizationConfig = configuration as? VGSDateTokenizationConfiguration {
            years = tokenizationConfig.years
        } else {
            years = VGSDateConfiguration.defaultYears
        }
        yearsDataSource = years.map { String($0) }
    }
    
    func updateTextFieldWithDatePickerSelection() {
        /// Get date components
        let day = days[picker.selectedRow(inComponent: pickerDayComponent)]
        let month = months[picker.selectedRow(inComponent: pickerMonthComponent)]
        let year = years[picker.selectedRow(inComponent: pickerYearComponent)]
        
        /// Get input date format, if not set, use the default
        var inputDateFormat = VGSDateFormat.default
        if let config = configuration as? VGSDateConfigurationProtocol,
           let fieldDateFormat = config.inputDateFormat {
            inputDateFormat = fieldDateFormat
        }
        
        /// Create the date string and update the display text
        if let date = VGSDate(day: day, month: month, year: year) {
            self.setText(inputDateFormat.mapDatePickerDataForFieldFormat(date))
        }
    }
    
    func scrollToCurrentMonthAndYear(animated: Bool) {
        let currentMonthIndex = Calendar.currentMonth - 1
        let currentYearIndex = Calendar.currentYear - 1
        picker.selectRow(currentMonthIndex, inComponent: pickerMonthComponent, animated: animated)
        picker.selectRow(currentYearIndex, inComponent: pickerYearComponent, animated: animated)
    }
    
    /// Setup date picker configuration
    func setupDatePicker() {
        textField.inputView = picker
        updateMonthsDataSource()
        updateYearsDataSource()
        updateDaysDataSource()
        
        // If the date format change, reload the picker component
        if let config = configuration as? VGSDateConfigurationProtocol,
           let fieldDateFormat = config.inputDateFormat {
            // Update the picker format only if it is different
            if pickerDateFormat != fieldDateFormat {
                pickerDateFormat = fieldDateFormat
                picker.reloadAllComponents()
            }
        }
        scrollToCurrentMonthAndYear(animated: false)
        textField.inputAccessoryView = UIView()
    }
    
    /// Setup keyboard configuration
    func setupKeyboard(with configuration: VGSConfiguration) {
        textField.keyboardType = configuration.keyboardType ?? configuration.type.keyboardType
        textField.returnKeyType = configuration.returnKeyType ?? .default
        textField.keyboardAppearance = configuration.keyboardAppearance ?? .default
        // Remove date picker if any
        textField.inputView = nil
        textField.inputAccessoryView  = nil
    }
}
// swiftlint:enable file_length
