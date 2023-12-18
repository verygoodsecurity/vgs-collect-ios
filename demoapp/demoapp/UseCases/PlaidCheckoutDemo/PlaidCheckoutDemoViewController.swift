//
//  PlaidCheckoutDemoViewController.swift
//  demoapp
//
import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS
class PlaidCheckoutDemoViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!

    // Init VGS Collector
    var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
    
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSExpDateTextField()
    var cvcCardNum = VGSTextField()
    var cardHolderName = VGSTextField()
  
    var linkHandler: VGSPlaidLinkHandler?


    override func viewDidLoad() {
      super.viewDidLoad()

      setupUI()
      setupElementsConfiguration()
  }
    
    // MARK: - Init UI
    private func setupUI() {
        cardDataStackView.addArrangedSubview(cardNumber)
        cardDataStackView.addArrangedSubview(cardHolderName)
        let dateStackView = UIStackView()
        dateStackView.axis = .horizontal
        dateStackView.distribution = .fillEqually
        dateStackView.spacing = 8
        dateStackView.addArrangedSubview(expCardDate)
        dateStackView.addArrangedSubview(cvcCardNum)
        cardDataStackView.addArrangedSubview(dateStackView)
            
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }

    @objc
    func hideKeyboard() {
        view.endEditing(true)
    }

    private func setupElementsConfiguration() {
      
        let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card_number")
        cardConfiguration.type = .cardNumber
        cardNumber.configuration = cardConfiguration
        cardNumber.placeholder = "Card number"
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
        expDateConfiguration.inputSource = .keyboard
        
        /// Update validation rules
        expDateConfiguration.validationRules = VGSValidationRuleSet(rules: [
          VGSValidationRuleCardExpirationDate(dateFormat: .shortYear, error: VGSValidationErrorType.expDate.rawValue)
        ])

        expCardDate.configuration = expDateConfiguration
        expCardDate.placeholder = "Expiration date"
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
        cardHolderName.configuration = holderConfiguration
        cardHolderName.placeholder = "Card holder"
        
        vgsCollect.textFields.forEach { textField in
          textField.textColor = UIColor.inputBlackTextColor
          textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
          textField.tintColor = .lightGray
          /// Implement VGSTextFieldDelegate methods
          textField.delegate = self
        }
    }
  @IBAction func nextButtonAction(_ sender: Any) {
      // Insert Link SDK token here
      self.linkHandler = VGSPlaidLinkHandler(collector: vgsCollect, linkToken: "<PLAID_LINK_TOKEN>", delegate: self)
      self.linkHandler?.open(on: self)
    }
    
    // Upload data from TextFields to VGS
    func sendPaymentData(_ plaidAccountsData: [String: Any]?, completion: @escaping() -> Void?) {
      // hide kayboard
      hideKeyboard()

      // check if textfields are valid
      vgsCollect.textFields.forEach { textField in
        textField.borderColor = textField.state.isValid ? .lightGray : .red
      }

      /// New sendRequest func
      vgsCollect.sendData(path: "/post", extraData: plaidAccountsData) {(response) in
        
        switch response {
        case .success(_, let data, _):
          if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // swiftlint:disable force_try
            let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
              print(response)
            // swiftlint:enable force_try
            }
            completion()
            return
        case .failure(let code, _, _, let error):
          switch code {
          case 400..<499:
            // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
            print("Error: Wrong Request, code: \(code)")
          case VGSErrorType.inputDataIsNotValid.rawValue:
            if let error = error as? VGSError {
              print(error)
            }
          default:
            print("Error: Something went wrong. Code: \(code)")
          }
          print("Submit request error: \(code), \(String(describing: error))")
          completion()
          return
        }
      }
    }
  
  private func showPlaceOrderVC() {
      let orderVC =  UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PlaidCheckoutPlaceOrderViewController") as! PlaidCheckoutPlaceOrderViewController
      orderVC.modalPresentationStyle = .overCurrentContext
      self.present(orderVC, animated: false, completion: nil)
  }
}

// MARK: - VGSTextFieldDelegate
extension PlaidCheckoutDemoViewController: VGSTextFieldDelegate {
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

extension PlaidCheckoutDemoViewController: VGSPlaidLinkHandlerDelegate {
  func didFinish(with metadata: [String : Any]) {
    print(metadata)
    sendPaymentData(metadata) { [weak self] in
      self?.showPlaceOrderVC()
    }
  }
}
