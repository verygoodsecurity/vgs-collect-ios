//
//  CardsDataCollectingViewController.swift
//  demoapp
//
//  Created by Dima on 29.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS
class CardsDataCollectingViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!

    // Init VGS Collector
    var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
    
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSExpDateTextField()
    var cvcCardNum = VGSCVCTextField()
    var cardHolderName = VGSTextField()
    
    /// BlinkCard Card Scanner
    var scanController: VGSBlinkCardController?
  
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
          
      // Observing text fields. The call back return all textfields with updated states.
      // You also can use VGSTextFieldDelegate instead.
      vgsCollect.observeStates = { [weak self] form in

          self?.consoleMessage = ""
          self?.consoleStatusLabel.text = "STATE"

          form.forEach({ textField in
              self?.consoleMessage.append(textField.state.description)
              self?.consoleMessage.append("\n")
          })
      }
      
      // Init VGSBlinkCardController with BlinkCard license key
      if let licenseKey = AppCollectorConfiguration.shared.blinkCardLicenseKey {
        scanController = VGSBlinkCardController(licenseKey: licenseKey, delegate: self, onError: { errorCode in
          print("BlinkCard license error, code: \(errorCode)")
        })
      } else {
        print("⚠️ VGSBlinkCardController not initialized. Check license key!")
      }
      
  //      // If you need to set your own card brand icons
  //
  //      VGSPaymentCards.visa.brandIcon = UIImage(named: "my visa icon")
  //      VGSPaymentCards.unknown.brandIcon = UIImage(named: "my unknown brand icon")
    }

	override func awakeFromNib() {
		super.awakeFromNib()

		let view = self.view
		if UITestsMockedDataProvider.isRunningUITest {
			view?.accessibilityIdentifier = "CardsDataCollectingViewController.Screen.RootView"
		}
	}
    
    // MARK: - Init UI
    private func setupUI() {
        
        cardDataStackView.addArrangedSubview(cardHolderName)
        cardDataStackView.addArrangedSubview(cardNumber)
        cardDataStackView.addArrangedSubview(expCardDate)
        cardDataStackView.addArrangedSubview(cvcCardNum)
            
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
      
        let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card_number")
        cardConfiguration.type = .cardNumber
        cardNumber.configuration = cardConfiguration
        cardNumber.placeholder = "4111 1111 1111 1111"
        cardNumber.textAlignment = .natural
        cardNumber.cardIconLocation = .right
      
//        cardNumber.becomeFirstResponder()
        /// Use `VGSExpDateConfiguration` if you need to convert output date format
        let expDateConfiguration = VGSExpDateConfiguration(collector: vgsCollect, fieldName: "card_expirationDate")
        expDateConfiguration.type = .expDate
				expDateConfiguration.inputDateFormat = .shortYear
        expDateConfiguration.outputDateFormat = .longYear

        /// Default .expDate format is "##/##"
        expDateConfiguration.formatPattern = "##/##"
        
        /// Update validation rules
        expDateConfiguration.validationRules = VGSValidationRuleSet(rules: [
          VGSValidationRuleCardExpirationDate(dateFormat: .shortYear, error: VGSValidationErrorType.expDate.rawValue)
        ])

        expCardDate.configuration = expDateConfiguration
        expCardDate.placeholder = "MM/YY"
        expCardDate.monthPickerFormat = .longSymbols
      
        let cvcConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card_cvc")
        cvcConfiguration.type = .cvc

        cvcCardNum.configuration = cvcConfiguration
        cvcCardNum.isSecureTextEntry = true
        cvcCardNum.placeholder = "CVC"
        cvcCardNum.tintColor = .lightGray

        let holderConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "cardHolder_name")
        holderConfiguration.type = .cardHolderName
        holderConfiguration.keyboardType = .namePhonePad
        /// Required to be not empty
      
        cardHolderName.textAlignment = .natural
				// Set max input length
				// holderConfiguration.maxInputLength = 32
        cardHolderName.configuration = holderConfiguration
        cardHolderName.placeholder = "Cardholder Name"
        
        vgsCollect.textFields.forEach { textField in
					textField.textColor = UIColor.inputBlackTextColor
          textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
          textField.tintColor = .lightGray
          /// Implement VGSTextFieldDelegate methods
          textField.delegate = self
        }
    }
    
    // Start BlinkCard scanning
    @IBAction func scanAction(_ sender: Any) {
      guard let scanController = scanController else {
        print("⚠️ VGSBlinkCardController not initialized. Check license key!")
        return
      }
      scanController.presentCardScanner(on: self, animated: true, modalPresentationStyle: .fullScreen, completion: nil)
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

// MARK: - VGSTextFieldDelegate
extension CardsDataCollectingViewController: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    textField.borderColor = textField.state.isValid  ? .gray : .red
    
    /// Update CVC field UI in case if valid cvc digits change, e.g.: input card number brand changed form Visa(3 digints CVC) to Amex(4 digits CVC) )
    if textField == cardNumber, cvcCardNum.state.isDirty {
      cvcCardNum.borderColor =  cvcCardNum.state.isValid  ? .gray : .red
    }

    /// Check Card Number Field State with addition attributes
    if let cardState = textField.state as? CardState, cardState.isValid {
        print("THIS IS: \(cardState.cardBrand.stringValue) - \(cardState.bin.prefix(4)) **** **** \(cardState.last4)")
    }
  }
}

extension CardsDataCollectingViewController: VGSBlinkCardControllerDelegate {
  func textFieldForScannedData(type: VGSBlinkCardDataType) -> VGSTextField? {
      // match VGSTextField with scanned data
      switch type {
      case .expirationDateLong:
          return expCardDate
      case .cardNumber:
          return cardNumber
      case .cvc:
        return cvcCardNum
      case .name:
        return cardHolderName
      default:
          return nil
      }
  }
  
  func userDidFinishScan() {
      scanController?.dismissCardScanner(animated: true, completion: {
          // add actions on scan controller dismiss completion
      })
  }
  
  func userDidCancelScan() {
      scanController?.dismissCardScanner(animated: true, completion: {
          // add actions on scan controller dismiss completion
      })
  }
}
