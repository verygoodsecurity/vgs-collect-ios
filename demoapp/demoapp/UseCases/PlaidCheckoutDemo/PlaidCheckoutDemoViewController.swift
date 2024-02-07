//
//  PlaidCheckoutDemoViewController.swift
//  demoapp
//
import UIKit
import VGSCollectSDK


/// Prerequisites
///
/// Create Link account
/// Setup and run demo backend - https://github.com/vgs-samples/collect-plaid-integration
/// Setup VGS routes https://dashboard.verygoodsecurity.com/ . You can find test routes in .yaml files inside our backend demo app.
/// Set your 'vaultId' in AppCollectorConfiguration.swift file
/// Run the demo

/* Steps:
- Submit button action
- Collect send fields data/tokenize(Collect API)
- Get bin from card textfield(optional)(Collect API)
- Create link token with bin(BE API)
- Init plaid flow with link token(Collect API)
- Complete Plaid flow with public token(Collect API)
- Exchange public token to access token(BE API)
- Get tokenized DDA with access token(BE API)
*/

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
    
    /// VGS-Plaid Link
    var linkHandler: VGSPlaidLinkHandler?
    var linkToken: String?
    
    /// Demo App backend url(https://github.com/vgs-samples/collect-plaid-integration)
    private let baseUrl = URL(string: "http://localhost:8081/api/")!

  
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
      
        let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "pan")
        cardConfiguration.type = .cardNumber
        cardNumber.configuration = cardConfiguration
        cardNumber.placeholder = "Card number"
        cardNumber.textAlignment = .natural
        cardNumber.cardIconLocation = .right
      
//        cardNumber.becomeFirstResponder()
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
  @IBAction func nextButtonAction(_ sender: Any) {
      hideKeyboard()
      collectCardData()
      initiatePlaidFlow()
    }
  func collectCardData() {
    /// New sendRequest func. NOTE:  you can check routeId on Dashboard->Route settings
    vgsCollect.sendData(path: "/post", routeId: nil) {(response) in
      
      switch response {
      case .success(_, let data, _):
        if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          // swiftlint:disable force_try
          let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
          print(response)
          // swiftlint:enable force_try
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
  
  private func showPlaceOrderVC() {
      let orderVC =  UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PlaidCheckoutPlaceOrderViewController") as! PlaidCheckoutPlaceOrderViewController
      orderVC.modalPresentationStyle = .overCurrentContext
      self.present(orderVC, animated: false, completion: nil)
  }

  func initiatePlaidFlow() {
    // take card bin from card textfield
    var bin = ""
    if let cardState = cardNumber.state as? CardState {
      bin = cardState.bin
    }
    // create plaid link token
    createLinkToken(with: bin) { [weak self] in
      // open plaid link flow
      self?.openPlaid()
    }
  }
  
  func createLinkToken(with bin: String, completion: @escaping() -> Void?) {
    let url = baseUrl.appendingPathComponent("create_link_token")
    var request = URLRequest(url: url)
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["bin": bin])
    request.httpMethod = "POST"
    let task = URLSession.shared.dataTask(
      with: request,
      completionHandler: { (data, _, _) in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any],
                let linkToken = json["link_token"] as? String else {
              
                  // Handle error
                  print("- Cannot fetch link_token")
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
  
  func openPlaid() {
    guard let token = linkToken else {return}
    // Insert Link SDK token here
    self.linkHandler = VGSPlaidLinkHandler(collector: vgsCollect, linkToken: token, delegate: self)
    self.linkHandler?.open(on: self)
  }

  func exangePlaidPublicTokenToAccessToken(_ token: String, completion: @escaping(String) -> Void?) {
    let url = baseUrl.appendingPathComponent("exchange_public_token")
    var request = URLRequest(url: url)
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["public_token": token])
    request.httpMethod = "POST"
    print(request)
    let task = URLSession.shared.dataTask(
      with: request,
      completionHandler: { (data, _, _) in
//        guard let data = data,
//              let json = try? JSONSerialization.jsonObject(with: data, options: [])
//                as? [String: Any],
//              let publicToken = json["access_token"] as? String else {
//                // Handle error
////                DispatchQueue.main.async {
////                  failure("Cannot fetch token")
////                }
//                return
//              }
        completion("")
      })
    task.resume()
  }
    
  func getTokenizedDDA(_ accessToken: String) {
    let url = baseUrl.appendingPathComponent("data")
    var request = URLRequest(url: url)
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    request.httpMethod = "POST"
    print(request)
    let task = URLSession.shared.dataTask(
      with: request,
      completionHandler: { (data, _, _) in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any] else {
          // Handle error
          print("- Cannot fetch tokenized DDA")
          return
        }
        print(json)
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
        print("THIS IS: \(cardState.cardBrand.stringValue) - \(cardState.bin.prefix(4)) **** **** \(cardState.last4)")
    }
  }
}

extension PlaidCheckoutDemoViewController: VGSPlaidLinkHandlerDelegate {
  func didFinish(with metadata: [String : Any]) {
    guard let publicToken = metadata["public_token"] as? String else {
      print("PLAID PUBLIC TOKEN NOT FOUND!!!\n\(metadata)")
      return
    }
    self.exangePlaidPublicTokenToAccessToken(publicToken) { accessToken in
      self.getTokenizedDDA(accessToken)
    }
  }
}
