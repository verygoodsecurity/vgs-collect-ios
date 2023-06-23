//
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An object that displays an editable text area. Can be use instead of a `VGSTextField` when need to show picker view with Card Number Expiration Month and Year.
public final class VGSExpDateTextField: VGSTextField {
    
    // MARK: - Enums
    /// Available Month Label formats in `UIPickerView`
    public enum MonthFormat {
      /// Short month name, e.g.: `Jan`
      case shortSymbols
      /// Long month name, e.g.: `January`
      case longSymbols
      /// Month number: e.g.: `01`
      case numbers
    }
  
    /// Available Year Label formats in `UIPickerView`
    public enum YearFormat {
      /// Two digits year format, e.g.: `21`
      case short
      /// Four digits year format:, e.g.:`2021`
      case long
    }
    
    // MARK: - Attributes
    /// UIPickerView Month Label format
    public var monthPickerFormat: MonthFormat = .longSymbols {
      didSet {
        updateMonthsDataSource()
      }
    }
  
    /// UIPickerView Year Label format
    public var yearPickerFormat: YearFormat = .long {
        didSet {
          updateYearsDataSource()
        }
    }
    
    /// :nodoc:
    public override var configuration: VGSConfiguration? {
        didSet {
            fieldType = .expDate
            setupAccessibilityLabel()
        }
    }
  
    /// Visual month data source
    internal var monthsDataSource = [String]()
    /// Visual year data source
    internal var yearsDataSource = [String]()
    /// Valid months range
    internal lazy var months = Array(1...12)
    /// Valid years range
    internal lazy var years: [Int] = {
      let current = Calendar.currentYear
      return Array(current...(current + validYearsCount))
    }()
    internal let monthPickerComponent = 0
    internal let yearPickerComponent = 1
    internal let validYearsCount = 20
    internal lazy var picker = self.makePicker()
          
    override func mainInitialization() {
      super.mainInitialization()
      // default behaviour in case field setup with VGSConfiguration
      setupDatePicker()
    }
    
    override func updateAccessibilityValues() {
        super.updateAccessibilityValues()
        
        /// If the text is secure, avoid talk over the value
        if textField.isSecureTextEntry {
            textFieldAccessibilityValue = ""
            return
        }
        
        /// Get input format
        var inputFormat = VGSCardExpDateFormat.longYear
        
        /// Check if specific `.inputFormat` is set in field configuration
        if let config = configuration as? VGSExpDateConfiguration,
           let fieldDateFormat = config.inputFormat as? VGSCardExpDateFormat {
            inputFormat = fieldDateFormat
        } else {
            /// Default format could be mm/yy or mm/yyyy. In other case `.inputDateFormat` should be specified
            let format = textField.formatPattern.components(separatedBy: "/").last ?? FieldType.expDate.defaultFormatPattern
            let defaultDateFormat: VGSCardExpDateFormat = (format.count == 4) ? .longYear : .shortYear
            inputFormat = defaultDateFormat
        }
        
        /// Get current text
        let secureText = textField.secureText ?? ""
        let expectedCount = inputFormat.yearCharacters + inputFormat.monthCharacters + 1
        if secureText.isEmpty {
            textFieldAccessibilityValue = inputFormat.accessibilityValue
        } else if secureText.count == expectedCount {
            textFieldAccessibilityValue = inputFormat.accessibilityDateFromInput(input: secureText)
        } else {
            textFieldAccessibilityValue = secureText
        }
    }
  
    override func setupField(with configuration: VGSConfiguration) {
      super.setupField(with: configuration)
      guard let config  = configuration as? VGSExpDateConfiguration else {
        return
      }
      // setup input source
      switch config.inputSource {
      case .datePicker:
        setupDatePicker()
      case .keyboard:
        setupKeyboard(with: config)
      }
    }
}

extension VGSExpDateTextField: UIPickerViewDelegate, UIPickerViewDataSource {

	  /// :nodoc: Picker view dataSource implementation.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

	  /// :nodoc: Picker view dataSource implementation.
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case monthPickerComponent:
            return monthsDataSource.count
        default:
            return yearsDataSource.count
        }
    }

	  /// :nodoc: Picker view delegate implementation.
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case monthPickerComponent:
            return monthsDataSource[row]
        default:
            return yearsDataSource[row]
        }
    }

	  /// :nodoc: Picker view delegate implementation.
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      /// check that date is not before current month
      let currentMonthIndex = Calendar(identifier: .gregorian).component(.month, from: Date()) - 1
      if pickerView.selectedRow(inComponent: yearPickerComponent) == 0 && pickerView.selectedRow(inComponent: monthPickerComponent) < currentMonthIndex {
        pickerView.selectRow(currentMonthIndex, inComponent: monthPickerComponent, animated: true)
      }
      updateTextFieldWithDatePickerSelection()
    }
}

// MARK: - Configuration
private extension VGSExpDateTextField {
  
  /// setup date picker configuration
  private func setupDatePicker() {
    textField.inputView = picker
    updateYearsDataSource()
    updateMonthsDataSource()
    scrollToCurrentMonth(animated: false)
    textField.inputAccessoryView = UIView()
  }

  /// setup keyboard configuration
  private func setupKeyboard(with configuration: VGSExpDateConfiguration) {
    textField.keyboardType = configuration.keyboardType ?? configuration.type.keyboardType
    textField.returnKeyType = configuration.returnKeyType ?? .default
    textField.keyboardAppearance = configuration.keyboardAppearance ?? .default
    // remove date picker if any
    textField.inputView = nil
    textField.inputAccessoryView  = nil
  }
    
    /// Setup accessibility label
    func setupAccessibilityLabel() {
        guard let config  = configuration as? VGSExpDateConfiguration, textField.isAccessibilityElement else {
            return
        }
        // setup input source
        switch config.inputSource {
        case .datePicker:
            textFieldAccessibilityLabel = Localization.FieldTypeAccessibility.expDatePicker
        case .keyboard:
            textFieldAccessibilityLabel = Localization.FieldTypeAccessibility.expDate
        }
    }
}

// MARK: - Date Picker
private extension VGSExpDateTextField {
    func makePicker() -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }
  
    func updateMonthsDataSource() {
      switch monthPickerFormat {
      case .shortSymbols:
        monthsDataSource = DateFormatter().shortMonthSymbols
      case .longSymbols:
        monthsDataSource = DateFormatter().monthSymbols
      case .numbers:
        monthsDataSource =  months.map { (String(format: "%02d", $0))}
      }
    }
    
    func updateYearsDataSource() {
      let suffixLength = yearPickerFormat == .short ? 2 : 4
      yearsDataSource = years.map { String(String($0).suffix(suffixLength))}
    }
  
    func updateTextFieldWithDatePickerSelection() {
      let month = months[picker.selectedRow(inComponent: monthPickerComponent)]
      let year = years[picker.selectedRow(inComponent: yearPickerComponent)]
      let inputDateFormat: VGSCardExpDateFormat
      
      /// Check if specific `.inputFormat` is set in field configuration
      if let config = configuration as? VGSExpDateConfiguration,
            let fieldDateFormat = config.inputFormat as? VGSCardExpDateFormat {
          inputDateFormat = fieldDateFormat
      } else {
        /// Default format could be mm/yy or mm/yyyy. In other case `.inputDateFormat` should be specified
        let format = textField.formatPattern.components(separatedBy: "/").last ?? FieldType.expDate.defaultFormatPattern
        inputDateFormat = (format.count == 4) ? .longYear : .shortYear
      }
      
      /// Create the date string
      let dateString = VGSExpirationDateTextFieldUtils.mapDatePickerExpirationDataForFieldFormat(inputDateFormat, month: month, year: year)
      self.setText(dateString)
    }
  
    func scrollToCurrentMonth(animated: Bool) {
      let currentMonthIndex = Calendar.currentMonth - 1
      picker.selectRow(currentMonthIndex, inComponent: monthPickerComponent, animated: animated)
      picker.selectRow(0, inComponent: yearPickerComponent, animated: animated)
    }
}
