//
//  PlaidCheckoutDemoViewController.swift
//  demoapp
//
import UIKit
import VGSCollectSDK


/*  Prerequisites
- Create Link account - https://plaid.com/
- Setup and run demo backend - https://github.com/vgs-samples/collect-plaid-integration
- Setup VGS routes https://dashboard.verygoodsecurity.com/ . You can find test routes in `.yaml` files inside our backend demo. app.
- Set your organization details in `PlaidDemoConfiguration` class
- Run Pod install in Terminal
- Run the demo
*/

/* Steps:
- Submit button action
- Collect send fields data/tokenize(Collect API)
- Get BIN from card textfield(optional)(Collect API)
- Create link token with BIN(BE API)
- Init plaid flow with link token(Collect API)
- Complete Plaid flow and get public token(Collect API)
- Exchange public token to access token(BE API)
- Get tokenized DDA with access token(BE API)
*/

/* Test Card Details:
Swith Account Flow: 4003 9000 0000 0000
RememberMe Flow: 1113 3333 4567 8913
Full Flow: 4111 1111 1111 1111
 
Test phone number: 4155550011
*/

/// Demo app config.
class PlaidDemoConfiguration {
  static let vaultId = "<vault-id>"
  static let environment = "sandbox"
  static let tokenizationRouteId = "<route-id>"
  /// Demo App backend url(https://github.com/vgs-samples/collect-plaid-integration)
  static let backendBaseURL = URL(string: "http://localhost:8081/api/")!
}
/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS and handle Plaid Auth flow
class PlaidCheckoutDemoViewController: UIViewController {

    @IBOutlet weak var contactStackView: UIStackView!
    @IBOutlet weak var cardDataStackView: UIStackView!

    // Init VGS Collector
    var vgsCollect = VGSCollect(id: PlaidDemoConfiguration.vaultId, environment: PlaidDemoConfiguration.environment)
    // Demo App backend url
    private let baseUrl = PlaidDemoConfiguration.backendBaseURL
    
    // VGS Contact UI Elements
    var nameField = TextField()
    var emailField = TextField()
    var phoneField = TextField()
  
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSExpDateTextField()
    var cvcCardNum = VGSTextField()
    var cardHolderName = VGSTextField()
    
    // Confirmation block
    @IBOutlet weak var agreementCheckmark: UIImageView!
    @IBOutlet weak var hasPlaidAccountCheckmark: UIImageView!
    var confirmUserAgreement = false
    var havePlaidAccount = false
  
    // VGS-Plaid Link handler
    var linkHandler: VGSPlaidLinkHandler?
    // Token to start Plaid Auth Flow
    var linkToken: String?
    
  
    override func viewDidLoad() {
      super.viewDidLoad()
      setupUI()
      setupContactFields()
      setupCardDataFields()

      /// Add support custom card brand starting on *11* for remember me flow(1113 3333 4567 8913)
      let customBrand = VGSCustomPaymentCardModel(name: "VGS Plaid Platinum",
                                                  regex: "^11\\d*$",
                                                  formatPattern: "#### #### #### ####",
                                                  cardNumberLengths: [16],
                                                  cvcLengths: [3],
                                                  checkSumAlgorithm: .luhn,
                                                  brandIcon: UIImage(named: "vgs platinum"))
      
      VGSPaymentCards.cutomPaymentCardModels = [ customBrand ]
  }
    
    // MARK: - Init UI
    private func setupUI() {
        contactStackView.addArrangedSubview(nameField)
        contactStackView.addArrangedSubview(emailField)
        contactStackView.addArrangedSubview(phoneField)
            
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
  
    private func setupContactFields() {
      nameField.textAlignment = .natural
      nameField.keyboardType = .asciiCapable
      nameField.placeholder = "Full name"
      
      emailField.textAlignment = .natural
      emailField.keyboardType = .emailAddress
      emailField.placeholder = "Email"
      
      phoneField.textAlignment = .natural
      phoneField.keyboardType = .numberPad
      phoneField.placeholder = "415-555-0011"
      
      var contactFields = [nameField, emailField, phoneField]
      contactFields.forEach { textField in
        textField.textColor = UIColor.inputBlackTextColor
        textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textField.tintColor = .lightGray
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 4
      }
    }
  
    private func setupCardDataFields() {
      // Card info
      let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "pan")
      cardConfiguration.isRequiredValidOnly = false
      cardConfiguration.type = .cardNumber
      cardNumber.configuration = cardConfiguration
      cardNumber.placeholder = "Card number"
      cardNumber.textAlignment = .natural
      cardNumber.cardIconLocation = .right
    
      /// Use `VGSExpDateConfiguration` if you need to convert output date format
      let expDateConfiguration = VGSExpDateConfiguration(collector: vgsCollect, fieldName: "expirationDate")
      expDateConfiguration.type = .expDate
      expDateConfiguration.inputDateFormat = .longYear
      expDateConfiguration.outputDateFormat = .longYear

      /// Default .expDate format is "##/##"
      expDateConfiguration.formatPattern = "##/####"
      expDateConfiguration.inputSource = .keyboard
      
      /// Update validation rules
      expDateConfiguration.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRuleCardExpirationDate(dateFormat: .longYear, error: VGSValidationErrorType.expDate.rawValue)
      ])

      expCardDate.configuration = expDateConfiguration
      expCardDate.placeholder = "MM/YYYY"
      expCardDate.monthPickerFormat = .longSymbols
    
      let cvcConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "cvc")
      cvcConfiguration.type = .cvc

      cvcCardNum.configuration = cvcConfiguration
      cvcCardNum.isSecureTextEntry = true
      cvcCardNum.placeholder = "CVC"
      cvcCardNum.tintColor = .lightGray

      let holderConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "cardholder")
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
  
  // MARK: - Actions
  @IBAction func userAgreementOptionAction(_ sender: Any) {
    confirmUserAgreement = !confirmUserAgreement
    let imageName = confirmUserAgreement ? "circle-checkbox-full" : "circle-checkbox"
    agreementCheckmark.image = (UIImage(named: imageName))
  }
  
  @IBAction func havePlaidAccountOptionAction(_ sender: Any) {
    havePlaidAccount = !havePlaidAccount
    let imageName = havePlaidAccount ? "circle-checkbox-full" : "circle-checkbox"
    hasPlaidAccountCheckmark.image = (UIImage(named: imageName))
  }
  
  @IBAction func submitButtonAction(_ sender: Any) {
      hideKeyboard()
    
      guard confirmUserAgreement else {return}
      collectCardData()
      initiatePlaidAuthFlow()
    }
  
  private func showPlaceOrderVC() {
    let orderVC =  UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PlaidCheckoutPlaceOrderViewController") as! PlaidCheckoutPlaceOrderViewController
    orderVC.modalPresentationStyle = .overCurrentContext
    self.present(orderVC, animated: false, completion: nil)
  }
  
  // MARK: - API calls
  // Tokenize card data
  func collectCardData() {
    /// New sendRequest func. NOTE:  you can check routeId on Dashboard->Route settings
    vgsCollect.sendData(path: "/post", routeId: PlaidDemoConfiguration.tokenizationRouteId) {(response) in
      
      switch response {
      case .success(_, let data, _):
        if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          print(jsonData)
        }
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
        return
      }
    }
  }

  // Start Plaid auth flow
  func initiatePlaidAuthFlow() {
    // take card bin from card textfield
    var bin = ""
    if let cardState = cardNumber.state as? CardState {
      bin = cardState.bin
    }
    var phoneNumber = ""
    if let number = phoneField.text, number.count == 10 {
      phoneNumber = number
    }
    // create plaid link token
    createLinkToken(with: bin, phoneNumber: phoneNumber, havePlaidAccount: havePlaidAccount) { [weak self] in
      // open plaid link flow
      self?.openPlaid()
    }
  }
  
  // Create Link token with Bin
  func createLinkToken(with bin: String, phoneNumber: String, havePlaidAccount: Bool, completion: @escaping() -> Void?) {
    let url = baseUrl.appendingPathComponent("create_link_token")
    var request = URLRequest(url: url)
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["bin": bin,
                                                                    "phone" : phoneNumber,
                                                                    "havePlaidAcc" : havePlaidAccount] as [String : Any])
    request.httpMethod = "POST"
    let task = URLSession.shared.dataTask(
      with: request,
      completionHandler: { (data, _, _) in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any],
                let linkToken = json["link_token"] as? String else {
                  // Handle error
                  print("❗Cannot fetch link_token")
                  completion()
                  return
        }
        
        DispatchQueue.main.async { [weak self] in
          self?.linkToken = linkToken
          completion()
          return
        }
      })
    task.resume()
    return
  }
  
  // Open Plaid Auth Screen
  func openPlaid() {
    guard let token = linkToken else {return}
    // Insert Link SDK token here
    self.linkHandler = VGSPlaidLinkHandler(collector: vgsCollect, linkToken: token, delegate: self)
    self.linkHandler?.open(on: self)
  }

  // Exchange public_token to auth_token API call
  func exchangePlaidPublicTokenToAccessToken(_ token: String, completion: @escaping(String) -> Void?) {
    let url = baseUrl.appendingPathComponent("exchange_public_token")
    var request = URLRequest(url: url)
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["public_token": token])
    request.httpMethod = "POST"
    print(request)
    let task = URLSession.shared.dataTask(
      with: request,
      completionHandler: { (data, response, _) in
        guard let httpResponse = response as? HTTPURLResponse else {
          return
        }
        guard let access_token = httpResponse.value(forHTTPHeaderField: "access_token") else {
          print("❗access_token not found")
          return
        }
        completion(access_token)
      })
    task.resume()
  }
      
  // Get tokenized DDA data API call
  func getTokenizedDDA(_ accessToken: String, completion: @escaping (Bool) -> Void?) {
    let url = baseUrl.appendingPathComponent("data")
    var request = URLRequest(url: url)
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    request.setValue(accessToken, forHTTPHeaderField: "access_token")
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(
      with: request,
      completionHandler: { (data, _, _) in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any] else {
          // Handle error
          print("❗Can not fetch tokenized DDA")
          completion(false)
          return
        }
        /// Take DDA to proceed with payment later
        print(json)
        completion(true)
      })
    task.resume()
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
        print("BIN: \(cardState.bin)")
    }
  }
}

// MARK: - VGSPlaidLinkHandlerDelegate
extension PlaidCheckoutDemoViewController: VGSPlaidLinkHandlerDelegate {
  func didFinish(with metadata: [String : Any]) {
    /// Get public token on success Plaid Auth  flow completion
    guard let publicToken = metadata["public_token"] as? String else {
      print("❗PLAID PUBLIC TOKEN NOT FOUND!!!\n\(metadata)")
      return
    }
    /// Exchange public token to access token
    self.exchangePlaidPublicTokenToAccessToken(publicToken) { accessToken in
      /// Get tokenized DDA account
      self.getTokenizedDDA(accessToken) { success in
        guard success else {
          print("❗Get Tokenized DDA ERROR")
          return
        }
        /// Navigate to payment
        DispatchQueue.main.async { [weak self] in
          self?.showPlaceOrderVC()
        }
      }
    }
  }
}
