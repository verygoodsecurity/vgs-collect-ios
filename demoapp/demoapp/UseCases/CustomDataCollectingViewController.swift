//
//  CustomDataCollectingViewController.swift
//  demoapp
//
//  Created by Dima on 29.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS
class CustomDataCollectingViewController: UIViewController {
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!

    // Init VGS Collector
    var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
    
    // VGS UI Elements
    var customDataField = VGSTextField()
    
    var consoleMessage: String = "" {
        didSet { consoleLabel.text = consoleMessage }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupElementsConfiguration()
        
        // set custom headers
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
    
    // MARK: - Init UI
    private func setupUI() {
      containerStackView.addArrangedSubview(customDataField)
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
      consoleLabel.addGestureRecognizer(tapGesture)
      consoleLabel.isUserInteractionEnabled = true
      view.addGestureRecognizer(tapGesture)
    }

    @objc
    func hideKeyboard() {
        view.endEditing(true)
        consoleLabel.endEditing(true)
    }

    private func setupElementsConfiguration() {
      
        let customDataFieldConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "custom_field")
      
        /// Choose field type "none", that don't have predefined setting like validations or format pattern.
        customDataFieldConfiguration.type = .none
        customDataFieldConfiguration.isRequired = true
        customDataFieldConfiguration.isRequiredValidOnly = true
        /// Set Visual Format Pattern
        customDataFieldConfiguration.formatPattern = "###-###-###"
        /// Divider string will be added to raw data on sendData(_:) request
        customDataFieldConfiguration.divider = "_"
        customDataFieldConfiguration.keyboardType = .decimalPad
      
        /// Add custom validation rules to be sure that input data is valid
        /// For this demo, the valid will be any number starting on 555 and 6-9 digits long
        customDataFieldConfiguration.validationRules = VGSValidationRuleSet(rules: [
          VGSValidationRulePattern(pattern: "^555\\d*$", error: "Not Valid! The code should start on 555"),
          VGSValidationRuleLengthMatch(lengths: Array(6...9), error: VGSValidationErrorType.lengthMathes.rawValue)
        ])
      
        customDataField.configuration = customDataFieldConfiguration
        customDataField.placeholder = "XXX XXX XXX"
        customDataField.textAlignment = .center

        customDataField.textColor = UIColor.inputBlackTextColor
        customDataField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        customDataField.tintColor = .lightGray
        customDataField.delegate = self
    }

    // Upload data from TextFields to VGS
    @IBAction func uploadAction(_ sender: Any) {
      // hide kayboard
      hideKeyboard()

      // check if textfields are valid
      vgsCollect.textFields.forEach { textField in
        textField.borderColor = textField.state.isValid ? .lightGray : .red
      }

      // send extra data
      var extraData = [String: Any]()
      extraData["customKey"] = "Custom Value"

      /// New sendRequest func
      vgsCollect.sendData(path: "/post", extraData: extraData) { [weak self](response) in
        
        self?.consoleStatusLabel.text = "RESPONSE"
        switch response {
        case .success(_, let data, _):
          if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // swiftlint:disable force_try
            let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
            self?.consoleLabel.text = "Success: \n\(response)"
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

extension CustomDataCollectingViewController: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    textField.borderColor = textField.state.isValid  ? .gray : .red
  }
}
