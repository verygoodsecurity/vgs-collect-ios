//
//  CollectApplePayData.swift
//  demoapp
//

import Foundation
import PassKit
import VGSCollectSDK

class CollectApplePayData: UIViewController {
  @IBOutlet weak var buttonsStackView: UIStackView!
  
  var collector = VGSCollect(id: "tnt", environment: "sandbox")
  
  var paymentController: PKPaymentAuthorizationController?
  
  static let supportedNetworks: [PKPaymentNetwork] = [
      .amex,
      .discover,
      .masterCard,
      .visa
  ]

  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    VGSCollectLogger.shared.configuration.isNetworkDebugEnabled = true
    VGSCollectLogger.shared.configuration.level = .info
    
    /// Check if Apple Pay available
    let result = Self.applePayStatus()
    if result.canMakePayments {
        let applePayButton = PKPaymentButton(paymentButtonType: .checkout, paymentButtonStyle: .black)
        applePayButton.addTarget(self, action: #selector(Self.payPressed), for: .touchUpInside)
          let constraints = [
              applePayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              applePayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
          ]
          applePayButton.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(applePayButton)
          NSLayoutConstraint.activate(constraints)
      }
    }

  class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
      return (PKPaymentAuthorizationController.canMakePayments(),
              PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
  }
  
  var controller: PKPaymentAuthorizationViewController?

  private var paymentRequest: PKPaymentRequest = {
    let ticket = PKPaymentSummaryItem(label: "Shopping Items", amount: NSDecimalNumber(string: "50.97"), type: .final)
    let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "5.00"), type: .final)
    let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "50.97"), type: .final)
    let paymentSummaryItems = [ticket, tax, total]
    
    let paymentRequest = PKPaymentRequest()
    paymentRequest.paymentSummaryItems = paymentSummaryItems
    paymentRequest.merchantIdentifier = "<merchantid>"
    paymentRequest.merchantCapabilities = .capability3DS
    paymentRequest.countryCode = "US"
    paymentRequest.currencyCode = "USD"
    paymentRequest.supportedNetworks = supportedNetworks
    paymentRequest.shippingType = .delivery
    paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
    return paymentRequest
  }()
  
  
  func startPayment() {
    paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
    paymentController?.delegate = self
    paymentController?.present(completion: { (presented: Bool) in
        if presented {
            debugPrint("Presented payment controller")
        } else {
            debugPrint("Failed to present payment controller")
//            self.completionHandler(false)
        }
    })
  }

    @objc func payPressed(sender: AnyObject) {
        self.startPayment()
    }
}

extension CollectApplePayData: PKPaymentAuthorizationControllerDelegate {
  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss(completion: nil)
  }
  
 
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    
      let paymentDataDictionary: [String: Any] = try! JSONSerialization.jsonObject(with: payment.token.paymentData, options: .mutableContainers) as! [String : Any]
      let paymentData = ["paymentData": paymentDataDictionary]
      let paymentToken = ["token": paymentData]
    
      /// Send data to your vault
      collector.sendData(path: "/post", extraData: paymentToken) { response in
        switch response {
        case .success(let _, let _, let response):
          print(response)
          completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        case .failure(let _, let _, let _, let _):
          completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
        }
      }
    }
}

