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

    // Init VGS Collector
    var vgsCardManager = VGSCardManager(accountId: "asdfasdf", environment: "sandbox")
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSExpDateTextField()
    var cvcCardNum = VGSCVCTextField()
      
    var consoleMessage: String = "" {
        didSet { consoleLabel.text = consoleMessage }
    }

    override func viewDidLoad() {
      super.viewDidLoad()

      setupUI()
      setupElementsConfiguration()
      // set custom headers
  //      // If you need to set your own card brand icons
  //
  //      VGSPaymentCards.visa.brandIcon = UIImage(named: "my visa icon")
  //      VGSPaymentCards.unknown.brandIcon = UIImage(named: "my unknown brand icon")
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
      
      let cardConfiguration = VGSCardManagementConfiguration(manager: vgsCardManager, fieldType: .cardNumber)
        cardNumber.configuration = cardConfiguration
        cardNumber.placeholder = "4111 1111 1111 1111"
        cardNumber.textAlignment = .natural
        cardNumber.cardIconLocation = .right
        
        let expDateConfiguration = VGSCardManagementConfiguration(manager: vgsCardManager, fieldType: .expDate)
        expDateConfiguration.formatPattern = "##/##"
    
        expCardDate.configuration = expDateConfiguration
        expCardDate.placeholder = "MM/YY"
        expCardDate.monthPickerFormat = .longSymbols
        
        let cvcConfiguration = VGSCardManagementConfiguration(manager: vgsCardManager, fieldType: .cvc)
        cvcCardNum.configuration = cvcConfiguration
        cvcCardNum.isSecureTextEntry = true
        cvcCardNum.placeholder = "CVC"
        cvcCardNum.tintColor = .lightGray

      vgsCardManager.textFields.forEach { textField in
					textField.textColor = UIColor.inputBlackTextColor
          textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
          textField.tintColor = .lightGray
          /// Implement VGSTextFieldDelegate methods
          textField.delegate = self
        }
    }
  
    let authToken = "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI1RVhBTnFldTBIbUNGVHZDUGs1c21iQjNjcVo1c0FLUzNKWFRjeHdTWjY4In0.eyJleHAiOjE3NDc3NTU2NTgsImlhdCI6MTc0Nzc1NDQ1OCwianRpIjoiYzkwZDcwYTAtYmI1Yi00YTRhLWJhYjgtMThkNjBmZWNiODkzIiwiaXNzIjoiaHR0cHM6Ly9hdXRoLnZlcnlnb29kc2VjdXJpdHkuY29tL2F1dGgvcmVhbG1zL3ZncyIsImF1ZCI6WyJjYWxtLXNhbmRib3giLCJjYWxtLWxpdmUiXSwic3ViIjoiNDljYTNjMjUtODI0OC00ZWNiLWI5NzUtZDI0MmViYmE2ZGQ0IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiQUNoR3VDZFhvLUNQTV9URVNULXFPb09OIiwicmVzb3VyY2VfYWNjZXNzIjp7ImNhbG0tc2FuZGJveCI6eyJyb2xlcyI6WyJjYXJkczpyZWFkIiwiYWNjb3VudHM6d3JpdGUiLCJjYXJkczp3cml0ZSIsIm5ldHdvcmstdG9rZW5zOndyaXRlIiwiYWNjb3VudHM6cmVhZCIsIm5ldHdvcmstdG9rZW5zOnJlYWQiLCJtZXJjaGFudHM6d3JpdGUiXX0sImNhbG0tbGl2ZSI6eyJyb2xlcyI6WyJjYXJkczpyZWFkIiwiYWNjb3VudHM6d3JpdGUiLCJjYXJkczp3cml0ZSIsIm5ldHdvcmstdG9rZW5zOndyaXRlIiwiYWNjb3VudHM6cmVhZCIsIm5ldHdvcmstdG9rZW5zOnJlYWQiLCJtZXJjaGFudHM6d3JpdGUiXX19LCJzY29wZSI6ImFjY291bnRzOndyaXRlIGNhcmRzOnJlYWQgYWNjb3VudHM6cmVhZCBtZXJjaGFudHM6d3JpdGUgc2VydmljZS1hY2NvdW50IGNhcmRzOndyaXRlIHVzZXJfaWQiLCJzZXJ2aWNlX2FjY291bnQiOnRydWUsImNsaWVudEhvc3QiOiIxODUuNS4yNTMuMTg5IiwiY2xpZW50QW5ub3RhdGlvbnMiOnsidmdzLmlvL3ZhdWx0LWlkIjoidG50eHZ0ZzB6Y2UifSwiY2xpZW50QWRkcmVzcyI6IjE4NS41LjI1My4xODkiLCJjbGllbnRfaWQiOiJBQ2hHdUNkWG8tQ1BNX1RFU1QtcU9vT04ifQ.I5wfJK4h7SPhD7h3lZJ5_4TsV93Nw7A2O8gb0t72wpvkacKNuK5jc4LxzbQRIF7pXEdmdeR0xsgX9vymWdlNAziQUzZJVw6wKBRiSZMNeW7VPSQrxBdfQ8VsTDJbqckNKTZCYXWwvRYUvfaHoLNddTEHPwsbMfs3-F4A5yylc3DAYUtjPtd43K1uxWeWr649jlEowcZjl_CKz75VotMD_6i6jmp50bksrHeRo-Iot5Hz3X-Otft9rm8jKdGpCeIQ1NKXbmGd_vg_KV-eF4vP1S1MUOHfpjnQgjE2B0KRWIp5c_Mxl-z5iqAIAYvr4aa8FEOor3zMQIxaddsHthTPXQ"
    
    // Upload data from TextFields to VGS
    @IBAction func uploadAction(_ sender: Any) {
      // hide kayboard
      hideKeyboard()

      // check if textfields are valid
//      vgsCollect.textFields.forEach { textField in
//        textField.borderColor = textField.state.isValid ? .lightGray : .red
//      }

      /// New sendRequest func
      vgsCardManager.createCard(authToken: authToken, completion: { [weak self] response in
        switch response {
        case .success(_, let data, _):
          if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // swiftlint:disable force_try
            let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
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
