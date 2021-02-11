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
    public var yearPickeFormat: YearFormat = .long {
        didSet {
          updateYearsDataSource()
        }
    }
    
    ///:nodoc:
    public override var configuration: VGSConfiguration? {
        didSet {
            fieldType = .expDate
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
        
    // MARK: - Initialization
  
    override func mainInitialization() {
      super.mainInitialization()
      textField.inputView = picker
      updateYearsDataSource()
      updateMonthsDataSource()
      scrollToCurrentMonth(animated: false)
      textField.inputAccessoryView = UIView()
    }
        
    private func updateTextField() {
      let month = months[picker.selectedRow(inComponent: monthPickerComponent)]
      let year = years[picker.selectedRow(inComponent: yearPickerComponent)]
      let format = textField.formatPattern.components(separatedBy: "/").last ?? FieldType.expDate.defaultFormatPattern
      let yearString = (format.count == 4) ? String(year) : String(year - 2000)
      let monthString = String(format: "%02d", month)
      self.setText("\(monthString)\(yearString)")
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
      updateTextField()
    }
}

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
      let suffixLength = yearPickeFormat == .short ? 2 : 4
      yearsDataSource = years.map { String(String($0).suffix(suffixLength))}
    }
  
    func scrollToCurrentMonth(animated: Bool) {
      let currentMonthIndex = Calendar.currentMonth - 1
      picker.selectRow(currentMonthIndex, inComponent: monthPickerComponent, animated: animated)
      picker.selectRow(0, inComponent: yearPickerComponent, animated: animated)
    }
}
