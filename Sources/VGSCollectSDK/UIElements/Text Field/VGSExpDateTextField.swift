//
//  VGSExpDateTextField.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 15.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public final class VGSExpDateTextField: VGSTextField {
    
    internal lazy var picker = self.makePicker()
    internal lazy var topView = self.makeTopView()
    
    internal lazy var monthsSymbol: [String] = {
        var result = [String]()
        (1...12).forEach { num in
            result.append(String(format: "%02d", num))
        }
        return result
    }()
    
    internal var cashedYearsSymbols: [String]?
    internal var yearsSymbol: [String] {
        if cashedYearsSymbols == nil {
            var result = [String]()
            let format = textField.formatPattern.components(separatedBy: "/").last ?? "##"
            let isLongFormat = format.count == 4
            let minYear = minimumYearForPicker
            let maxYear = minYear + 50
            (minYear...maxYear).forEach { year in
                result.append(String(format: "%d", year - (isLongFormat ? 0 : 2000)))
            }
            cashedYearsSymbols = result
        }
        return cashedYearsSymbols!
    }
    
    public var minimumYearForPicker: Int = 2020
    
    // MARK: -
    override func mainInitialization() {
        super.mainInitialization()
        textField.inputView = picker
        textField.inputAccessoryView = topView
        textField.tintColor = .clear
    }
    
    public override var configuration: VGSConfiguration? {
        didSet {
            cashedYearsSymbols = nil
            updateTextField()
        }
    }
    
    @objc
    internal func doneTap(_ sender: UIButton) {
        textField.resignFirstResponder()
    }
    
    private func resetTextFieldIfNeeded() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(Calendar.Component.month, from: Date())
        let currentYear = calendar.component(Calendar.Component.year, from: Date())
        let selectedMonth = picker.selectedRow(inComponent: 0) + 1
        let selectedYear = picker.selectedRow(inComponent: 1) + 2020
        
        if selectedMonth < currentMonth && selectedYear == currentYear {
            picker.selectRow(currentMonth - 1, inComponent: 0, animated: true)
        }
    }
    
    private func updateTextField() {
        resetTextFieldIfNeeded()
        let month = picker.selectedRow(inComponent: 0)
        let year = picker.selectedRow(inComponent: 1)
        textField.secureText = String(format: "%@/%@",
                                      monthsSymbol[month],
                                      yearsSymbol[year])
    }
}

extension VGSExpDateTextField: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return monthsSymbol.count
            
        default:
            return yearsSymbol.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return monthsSymbol[row]
        default:
            return yearsSymbol[row]
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 75
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
    
    func makeTopView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        view.backgroundColor = .lightGray
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneTap(_:)), for: .touchUpInside)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        let views = ["button": doneButton]
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=15)-[button]-(15)-|",
                                               options: .alignAllCenterY,
                                               metrics: nil,
                                               views: views)
        NSLayoutConstraint.activate(h)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|",
                                               options: .alignAllCenterX,
                                               metrics: nil,
                                               views: views)
        NSLayoutConstraint.activate(v)
        return view
    }
}
