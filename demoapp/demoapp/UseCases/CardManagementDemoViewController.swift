//
//  CardManagementDemoViewController.swift
//  demoapp
//


import UIKit
import VGSCollectSDK

// swiftlint:disable all
/// A class that demonstrates how to create card  alias from VGSTextFields and upload it to VGS Card Management API https://www.verygoodsecurity.com/docs/card-management.
class CardManagementDemoViewController: UIViewController {
    
    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!

    // Init VGS Collector
    var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
    
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSExpDateTextField()
    var cvcCardNum = VGSCVCTextField()
    
    var consoleMessage: String = "" {
        didSet { consoleLabel.text = consoleMessage }
    }

    // Should be provided by your backend app:
    // https://www.verygoodsecurity.com/docs/card-management/authentication
    private let authToken = "<your_authentication_token>"
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupElementsConfiguration()
        
        // IMPORTANT: set proper content type and auth_token as custom headers.
        vgsCollect.customHeaders = [
          "Content-Type" : "application/vnd.api+json",
          "Authorization": "Bearer \(authToken)"
        ]
    
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
        view?.accessibilityIdentifier = "CreateCardAliasesViewController.Screen.RootView"
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
      
        /// Setup proper field names according to Card Management API
        let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "data.attributes.pan")
        cardConfiguration.type = .cardNumber
        cardNumber.configuration = cardConfiguration
        cardNumber.placeholder = "4111 1111 1111 1111"
        cardNumber.textAlignment = .natural
        cardNumber.cardIconLocation = .right
      
        cardNumber.becomeFirstResponder()
        /// Use `VGSExpDateTokenizationConfiguration`for tokenization
        let expDateConfiguration = VGSExpDateConfiguration(collector: vgsCollect, fieldName: "expDate")
        expDateConfiguration.serializers = [VGSExpDateSeparateSerializer.init(monthFieldName: "data.attributes.exp_month", yearFieldName: "data.attributes.exp_year")]
        /// Set UI configuration
        expDateConfiguration.inputDateFormat = .longYear
        expDateConfiguration.outputDateFormat = .longYear

        /// Default .expDate format is "##/##"
        expDateConfiguration.formatPattern = "##/####"
              
        /// Update validation rules
        expDateConfiguration.validationRules = VGSValidationRuleSet(rules: [
          VGSValidationRuleCardExpirationDate(dateFormat: .longYear, error: VGSValidationErrorType.expDate.rawValue)
        ])

        expCardDate.configuration = expDateConfiguration
        expCardDate.placeholder = "MM/YYYY"
        expCardDate.monthPickerFormat = .longSymbols
      
        let cvcConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "data.attributes.cvc")
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

      // Set path as `cards` to create new card.
      // Requires <auth_token> in headers.
      vgsCollect.sendData(path: "/cards"){[weak self](response) in
        
        self?.consoleStatusLabel.text = "RESPONSE"
        switch response {
        case .success(_, let resultBody, _):
          let response = (String(data: try! JSONSerialization.data(withJSONObject: resultBody!, options: .prettyPrinted), encoding: .utf8)!)
          self?.consoleLabel.text = "Success: \n\(response)"
            print(response)
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
extension CardManagementDemoViewController: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    print(textField.state.description)
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

// swiftlint:enable all
