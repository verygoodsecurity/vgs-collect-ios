//
//  DateValidationViewController.swift
//  demoapp
//

import UIKit
import VGSCollectSDK

class DateValidationViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!
    
    // MARK: - Properties
    /// Init VGS Collector
    var vgsCollect = VGSCollect(
        id: AppCollectorConfiguration.shared.vaultId,
        environment: AppCollectorConfiguration.shared.environment
    )
    /// VGS UI Elements
    var dateField = VGSDateTextField()
    var consoleMessage: String = "" {
        didSet {
            consoleLabel.text = consoleMessage
        }
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Configuration
        setupUI()
        setupElementsConfiguration()
        
        /// Set custom headers
        vgsCollect.customHeaders = [
            "my custome header": "some custom data"
        ]
        
        /// Observe VGSTextFields changes
        vgsCollect.observeStates = { [weak self] form in
            
            self?.consoleMessage = ""
            self?.consoleStatusLabel.text = "STATE"
            
            form.forEach({ textField in
                self?.consoleMessage.append(textField.state.description)
                self?.consoleMessage.append("\n")
            })
        }
    }
}

// MARK: - Private methods
private extension DateValidationViewController {
    
    func setupUI() {
        containerStackView.addArrangedSubview(dateField)
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        consoleLabel.addGestureRecognizer(tapGesture)
        consoleLabel.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func hideKeyboard() {
        view.endEditing(true)
        consoleLabel.endEditing(true)
    }
    
    func setupElementsConfiguration() {
        
        /// Start and end dates
        let startDate = VGSDate(day: 1, month: 1, year: 2010)
        let endDate = VGSDate(day: 20, month: 12, year: 2025)
        
        // Date format
        let inputDateFormat = VGSDateFormat.mmddyyyy
        
        /// Create configuration
        let dateFieldConfiguration = VGSDateConfiguration(
            collector: vgsCollect,
            fieldName: "date_field",
            datePickerStartDate: startDate,
            datePickerEndDate: endDate
        )
        dateFieldConfiguration.inputDateFormat = inputDateFormat
        dateFieldConfiguration.outputDateFormat = .yyyymmdd
        dateFieldConfiguration.inputSource = .datePicker
        dateFieldConfiguration.divider = "-"
        dateFieldConfiguration.formatPattern = "##/##/####"
        
        /// Setup validation rules, it is important to set the same start and
        /// end date used in the configuration
        dateFieldConfiguration.validationRules = VGSValidationRuleSet(
            rules: [
                VGSValidationRuleDateRange(
                    dateFormat: inputDateFormat,
                    error: VGSValidationErrorType.date.rawValue,
                    start: startDate,
                    end: endDate
                )
            ]
        )
        
        /// Update configuration in the text field
        dateField.configuration = dateFieldConfiguration
        dateField.placeholder = "MM-DD-YYYY"
        dateField.monthPickerFormat = .longSymbols
        
        /// Add logging
        vgsCollect.textFields.forEach { textField in
            textField.textColor = UIColor.inputBlackTextColor
            textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            textField.tintColor = .lightGray
            /// Implement VGSTextFieldDelegate methods
            textField.delegate = self
        }
    }
    
    // Upload data from TextFields to VGS
    @IBAction func uploadAction(_ sender: Any) {
        // Hide kayboard
        hideKeyboard()
        
        // Check if textfields are valid
        vgsCollect.textFields.forEach { textField in
            textField.borderColor = textField.state.isValid ? .lightGray : .red
        }
        
        // Send extra data
        var extraData = [String: Any]()
        extraData["customKey"] = "Custom Value"
        
        /// New sendRequest func
        vgsCollect.sendData(path: "/post", extraData: extraData) { [weak self] (response) in
            self?.consoleStatusLabel.text = "RESPONSE"
            switch response {
            case .success(_, let data, _):
                if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // swiftlint:disable force_try
                    let response = (
                        String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!,
                                                                 options: .prettyPrinted), encoding: .utf8)!
                    )
                    self?.consoleLabel.text = "Success: \n\(response)"
                    print(response)
                    // swiftlint:enable force_try
                }
                return
                
            case .failure(let code, _, _, let error):
                switch code {
                case 400..<499:
                    // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
                    self?.consoleLabel.text = "Error: Wrong Request, code: \(code)"
                
                case VGSErrorType.inputDataIsNotValid.rawValue:
                    if let error = error as? VGSError {
                        self?.consoleLabel.text = "Error: Input data is not valid. Details:\n \(error)"
                    }
                
                default:
                    self?.consoleLabel.text = "Error: Something went wrong. Code: \(code)"
                }
                print("Submit request error: \(code), \(String(describing: error))")
                return
            }
        }
    }
}

// MARK: - VGSTextFieldDelegate implementation
extension DateValidationViewController: VGSTextFieldDelegate {
    
    func vgsTextFieldDidChange(_ textField: VGSTextField) {
        textField.borderColor = textField.state.isValid  ? .gray : .red
    }
}
