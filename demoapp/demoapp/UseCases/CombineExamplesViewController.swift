//
//  CombineExamplesViewController.swift
//  demoapp
//

import UIKit
import VGSCollectSDK
import Combine

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS
class CombineExamplesViewController: UIViewController {
  
  @IBOutlet weak var cardDataStackView: UIStackView!
  @IBOutlet weak var consoleStatusLabel: UILabel!
  @IBOutlet weak var consoleLabel: UILabel!
  
  @IBOutlet weak var uploadButton: UIButton!
  
  var cancellables = Set<AnyCancellable>()
  
  // Init VGS Collector
  var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
  
  // VGS UI Elements
  var cardNumber = VGSCardTextField()
  var expCardDate = VGSExpDateTextField()
  var cvcCardNum = VGSCVCTextField()
  var cardHolderName = VGSTextField()
  
  /// BlinkCard Card Scanner
  var scanController: VGSBlinkCardController?

  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupElementsConfiguration()
    
    /// Track textfield state changes
    cardHolderName.statePublisher.sink { [weak self] state in
      self?.cardHolderName.borderColor = state.isValid ? .lightGray : .red
    }.store(in: &cancellables)
    
    /// Map State to CardState to get access for card attributes
    cardNumber.statePublisher.compactMap { state -> VGSCardState? in
      return state as? VGSCardState
    }.sink { [weak self] cardState in
      self?.cardNumber.borderColor = cardState.isValid ? .lightGray : .red
    }.store(in: &cancellables)
    
    expCardDate.statePublisher.sink { [weak self] state in
      self?.expCardDate.borderColor = state.isValid ? .lightGray : .red
    }.store(in: &cancellables)
    
    cvcCardNum.statePublisher.sink { [weak self] state in
      self?.cvcCardNum.borderColor = state.isValid ? .lightGray : .red
    }.store(in: &cancellables)
    
    /// Update state label msg
    Publishers.CombineLatest4(cardHolderName.statePublisher,
                              cardNumber.statePublisher,
                              expCardDate.statePublisher,
                              cvcCardNum.statePublisher)
    .map { state1, state2, state3, state4 in
      return state1.isValid && state2.isValid && state3.isValid && state4.isValid
    }
    .sink { [weak self] allValid in
      let formStateMsg = allValid ? "All Valid!" : "Form not Valid!"
      self?.consoleStatusLabel.text = "STATE: \(formStateMsg)"
    }.store(in: &cancellables)
    
    // set custom headers
    vgsCollect.customHeaders = [
      "custom_header": "some custom data"
    ]
    
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
      Task { @MainActor in
          let view = self.view
          if UITestsMockedDataProvider.isRunningUITest {
              view?.accessibilityIdentifier = "CombineExamplesViewController.Screen.RootView"
          }
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
    
    // send extra data
    var extraData = [String: Any]()
    extraData["customKey"] = "Custom Value"
    
    vgsCollect.sendDataPublisher(path: "/post", extraData: extraData).sink(
      receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case .failure(let error):
          print("Error: \(error.localizedDescription)")
        }
      },
      receiveValue: { [weak self]response in
        self?.consoleStatusLabel.text = "RESPONSE"
        switch response {
        case .success(_, let data, _):
          self?.handleSuccessResponse(data)
        case .failure(let code, _, _, let error):
          self?.handleFailedRespose(code, error: error )
        }
      }
    ).store(in: &cancellables)
  }
  
  private func handleSuccessResponse(_ data: Data?) {
    if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
      // swiftlint:disable force_try
      let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
      self.consoleLabel.text = "Success: \n\(response)"
      print(response)
      // swiftlint:enable force_try
    } else {
      self.consoleLabel.text = "Response Parsing ERROR!"
    }
  }
  
  private func handleFailedRespose(_ errorCode: Int, error: Error?) {
    switch errorCode {
    case 400..<499:
      // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
      self.consoleLabel.text = "Error: Wrong Request, code: \(errorCode)"
    case VGSErrorType.inputDataIsNotValid.rawValue:
      if let error = error as? VGSError {
        self.consoleLabel.text = "Error: Input data is not valid. Details:\n \(error)"
      }
    default:
      self.consoleLabel.text = "Error: Something went wrong. Code: \(errorCode)"
    }
    print("Submit request error: \(errorCode), \(String(describing: error))")
  }
  
  // Start BlinkCard scanning
  @IBAction func scanAction(_ sender: Any) {
    guard let scanController = scanController else {
      print("⚠️ VGSBlinkCardController not initialized. Check license key!")
      return
    }
    scanController.presentCardScanner(on: self, animated: true, modalPresentationStyle: .fullScreen, completion: nil)
  }
}

extension CombineExamplesViewController: VGSBlinkCardControllerDelegate {
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
