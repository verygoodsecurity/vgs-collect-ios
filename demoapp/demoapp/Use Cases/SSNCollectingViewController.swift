//
//  SSNCollectingViewController.swift
//  demoapp
//
//  Created by Dima on 29.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS
class SSNCollectingViewController: UIViewController {
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!
    @IBOutlet weak var hiddenNumberLabel: UILabel!
  
  // Init VGS Collector
    var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
    
    // VGS UI Elements
    var ssnField = VGSTextField()
    
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
      
        /// Observe active VGSTextField changes
        vgsCollect.observeFieldState = { [weak self] textField in

            self?.consoleMessage = ""
            self?.consoleStatusLabel.text = "STATE"
            self?.consoleMessage.append(textField.state.description)
            self?.consoleMessage.append("\n")

            if let ssnState = textField.state as? SSNState, ssnState.isValid {
              self?.hiddenNumberLabel.text = "SSN: XXX-XX-\(ssnState.last4)"
            } else {
               self?.hiddenNumberLabel.text = ""
            }
        }
  }
    
    // MARK: - Init UI
    private func setupUI() {
      containerStackView.addArrangedSubview(ssnField)
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
      
        let ssnFieldConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "custom_field")
      
        /// Choose field type "none", that don't have predefined setting like validations or format pattern.
        ssnFieldConfiguration.type = .ssn
        ssnFieldConfiguration.isRequired = true
        ssnFieldConfiguration.isRequiredValidOnly = true
    
        /// Divider string will be added to raw data on sendData(_:) request
        ssnFieldConfiguration.divider = "-"
      
        ssnField.configuration = ssnFieldConfiguration
        ssnField.placeholder = "XXX-XX-XXXX"
        ssnField.textAlignment = .center

        ssnField.textColor = .darkText
        ssnField.font = .systemFont(ofSize: 22)
        ssnField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        ssnField.tintColor = .lightGray
        ssnField.delegate = self
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

extension SSNCollectingViewController: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    textField.borderColor = textField.state.isValid  ? .gray : .red
  }
}
