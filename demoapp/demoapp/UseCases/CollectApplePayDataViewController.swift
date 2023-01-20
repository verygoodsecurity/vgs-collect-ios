//
//  CollectApplePayData.swift
//  demoapp
//

/**
 Below is code example how to collect and decrypt ApplePay payment requests with VGS.
 This require few steps:
 1. Create  certificate signing request (CSR file) and generate Payment Processing Certificate at Apple Dashboard.
 2. Configure VGS Route with ApplePay Merchant ID, Vault Access Credentials, Payment Processing Certificate.
 3. Get payment data from `PKPayment.token` and send data to your vault with VGSCollect.send() request.
 
 You can find more details how to prepare VGS Route configuration to handle ApplePay here -  https://github.com/vgs-samples/apple-pay-setup .
 
 NOTE: This use case can be tested only on real iOS device!
 **/

import Foundation
import PassKit
import VGSCollectSDK
                                                  
class CollectApplePayData: UIViewController {
  
  @IBOutlet weak var payButtonsStackView: UIStackView!
  @IBOutlet weak var consoleLabel: UILabel!
  @IBOutlet weak var consoleStatusLabel: UILabel!
  
  /// Init VGS Collect
  var collector = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
  /// ApplePay payment controller
  var paymentController: PKPaymentAuthorizationController?
  /// Supported Networks via ApplePay
  static let supportedNetworks: [PKPaymentNetwork] = [
      .amex,
      .discover,
      .masterCard,
      .visa
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// Check if ApplePay option available
    let result = Self.applePayStatus()
    if result.canMakePayments && result.canSetupCards {
      let applePayButton = PKPaymentButton(paymentButtonType: .checkout, paymentButtonStyle: .black)
      applePayButton.addTarget(self, action: #selector(Self.payPressed), for: .touchUpInside)
      payButtonsStackView.addArrangedSubview(applePayButton)
    }
  }

  /// Get ApplePay status
  class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
      return (PKPaymentAuthorizationController.canMakePayments(),
              PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
  }
  
  /// Setup payment request
  private var paymentRequest: PKPaymentRequest = {
    let items = PKPaymentSummaryItem(label: "Shopping Items", amount: NSDecimalNumber(string: "50.97"), type: .final)
    let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "5.00"), type: .final)
    let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "50.97"), type: .final)
    let paymentSummaryItems = [items, tax, total]
    
    let paymentRequest = PKPaymentRequest()
    paymentRequest.paymentSummaryItems = paymentSummaryItems
    /// Merchand id associated with ApplePay Payment Processing Certificate.
    paymentRequest.merchantIdentifier = "<merchant-id>"
    paymentRequest.merchantCapabilities = .capability3DS
    paymentRequest.countryCode = "US"
    paymentRequest.currencyCode = "USD"
    paymentRequest.supportedNetworks = supportedNetworks
    return paymentRequest
  }()
  
  /// Handle ApplePay button pressed
  @objc func payPressed(sender: AnyObject) {
      self.startPayment()
  }
  
  /// Initiate PKPayment Authorization request
  func startPayment() {
    self.consoleStatusLabel.text = "Collecting ApplePay data"
    paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
    paymentController?.delegate = self
    paymentController?.present(completion: { (presented: Bool) in
        if !presented {
          self.consoleLabel.text = "Failed to present payment controller"
        }
    })
  }
}

/// Handle PKPaymentAuthorizationController results
extension CollectApplePayData: PKPaymentAuthorizationControllerDelegate {

  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
      /// Prepapre payment data required to collect for your use-case
    guard let paymentDataDictionary: [String: Any] = try? JSONSerialization.jsonObject(with: payment.token.paymentData, options: .mutableContainers) as? [String: Any] else {
      print("Error: can't parse payment.token.paymentData")
      completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
      return
    }
      let paymentData = ["paymentData": paymentDataDictionary]
      let paymentToken = ["token": paymentData]
    
      /// Send data to your vault
    collector.sendData(path: "/post", extraData: paymentToken) { [weak self] result in
        self?.consoleStatusLabel.text = "RESPONSE"

        switch result {
        case .success(let code, let data, _):
          print("code: \(code)")
          if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // swiftlint:disable force_try
            let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
            self?.consoleLabel.text = "Success: \n\(response)"
            print(response)
            // swiftlint:enable force_try
            }
            return
          
          completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        case .failure(let code, _, _, _):
          self?.consoleLabel.text = "Error: Something went wrong. Code: \(code)"
          completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
        }
      }
    }
  
  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss(completion: nil)
  }
}
