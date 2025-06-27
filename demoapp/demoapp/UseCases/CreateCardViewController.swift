//
//  CreateCardViewController.swift
//  demoapp
//

import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS
class CreateCardViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!

    // Init VGS Collector with **accountId** and **environment**
    var vgsCollect = VGSCollect(accountId: AppCollectorConfiguration.shared.accountId, environment: AppCollectorConfiguration.shared.environment.rawValue)
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSExpDateTextField()
    var cvcCardNum = VGSCVCTextField()
      
    var consoleMessage: String = "" {
        didSet { consoleLabel.text = consoleMessage }
    }
  
  let authToken = "<your_cpm_authToken>"

    override func viewDidLoad() {
      super.viewDidLoad()

      setupUI()
      setupElementsConfiguration()
      
      // Observing text fields. The call back return all textfields with updated states.
      // You also can use VGSTextFieldDelegate instead.
      vgsCollect.observeStates = { [weak self] textFields in
          var invalidTextFieldsCount = 0
          self?.consoleMessage = ""
          textFields.forEach({ textField in
              self?.consoleMessage.append(textField.state.description)
              self?.consoleMessage.append("\n")
              if !textField.state.isValid {invalidTextFieldsCount+=1}
          })
          let formStateMsg = invalidTextFieldsCount > 0 ? "Not valid fields - \(invalidTextFieldsCount)!" : "All Valid!"
          self?.consoleStatusLabel.text = "STATE: \(formStateMsg)"
      }
    }

	override func awakeFromNib() {
		super.awakeFromNib()

		let view = self.view
		if UITestsMockedDataProvider.isRunningUITest {
			view?.accessibilityIdentifier = "CreateCardViewController.Screen.RootView"
		}
	}
    
    // MARK: - Init UI
    private func setupUI() {
        
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
    
      let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "pan")
      cardConfiguration.type = .cardNumber
      cardNumber.configuration = cardConfiguration
      cardNumber.placeholder = "4111 1111 1111 1111"
      cardNumber.textAlignment = .natural
      cardNumber.cardIconLocation = .right
    
      let expDateConfiguration = VGSExpDateConfiguration(collector: vgsCollect, fieldName: "exp_date")
      expDateConfiguration.type = .expDate
      // set serializers that will convert date to format expected by CMP API
      expDateConfiguration.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "exp_month", yearFieldName: "exp_year")]
    
      expCardDate.configuration = expDateConfiguration
      expCardDate.placeholder = "MM/YY"
      expCardDate.monthPickerFormat = .longSymbols
    
      let cvcConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "cvc")
      cvcConfiguration.type = .cvc

      cvcCardNum.configuration = cvcConfiguration
      cvcCardNum.isSecureTextEntry = true
      cvcCardNum.placeholder = "CVC"
      cvcCardNum.tintColor = .lightGray
      
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
      // hide kayboard
      hideKeyboard()
      // check if textfields are valid
      vgsCollect.textFields.forEach { textField in
        textField.borderColor = textField.state.isValid ? .lightGray : .red
      }
      // set CMP API required headers
      vgsCollect.customHeaders = [
        "Content-Type": "application/vnd.api+json",
        "Authorization": "Bearer \(authToken)"
      ]
      /// New sendRequest func
      vgsCollect.createCard(completion: { [weak self] response in
        self?.consoleStatusLabel.text = "RESPONSE"
        switch response {
        case .success(_, let data, _):
          if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // swiftlint:disable force_try
            let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted), encoding: .utf8)!)
            print(response)
            // swiftlint:enable force_try
            self?.consoleLabel.text = "Success: \n\(response)"
            }
            return
        case .failure(let code, _, _, let error):
          self?.consoleLabel.text = "Submit request error: \(code), \(String(describing: error))"
          print("Submit request error: \(code), \(String(describing: error))")
          return
        }
      })
    }
}

// MARK: - VGSTextFieldDelegate
extension CreateCardViewController: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    textField.borderColor = textField.state.isValid  ? .gray : .red
    
    /// Update CVC field UI in case if valid cvc digits change, e.g.: input card number brand changed form Visa(3 digints CVC) to Amex(4 digits CVC) )
    if textField == cardNumber, cvcCardNum.state.isDirty {
      cvcCardNum.borderColor =  cvcCardNum.state.isValid  ? .gray : .red
    }

    /// Check Card Number Field State with addition attributes
    if let cardState = textField.state as? VGSCardState, cardState.isValid {
        print("THIS IS: \(cardState.cardBrand.stringValue) - \(cardState.bin.prefix(4)) **** **** \(cardState.last4)")
    }
  }
}
