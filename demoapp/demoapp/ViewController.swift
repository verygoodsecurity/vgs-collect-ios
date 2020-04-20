//
//  ViewController.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS
class ViewController: UIViewController {
    
    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!

    // Init VGS Collector
    var vgsForm = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
    
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSTextField()
    var cvcCardNum = VGSTextField()
    var cardHolderName = VGSTextField()
    
    var consoleMessage: String = "" {
        didSet { consoleLabel.text = consoleMessage }
    }
    
    // Init CardIO Scan controller
    var scanController = VGSCardIOScanController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupElementsConfiguration()
        
        // check if device is jailbroken
        if VGSCollect.isJailbroken() {
            print("Device is Jailbroken")
        }

        // set custom headers
        vgsForm.customHeaders = [
            "my custome header": "some custom data"
        ]

        
        // set preferred device camera
//        scanController.preferredCameraPosition = .front
        // set VGSCardIOScanDelegate
        scanController.delegate = self

        // Observing text fields
        vgsForm.observeStates = { [weak self] form in

            self?.consoleMessage = ""
            self?.consoleStatusLabel.text = "STATE"

            form.forEach({ textField in
                self?.consoleMessage.append(textField.state.description)
                self?.consoleMessage.append("\n")
            })
        }
        
        // use the closure below if you need to set your own card brand icons
//        cardNumber.cardsIconSource = { cardType in
//            switch cardType {
//            case .mastercard:
//                return UIImage(named: "your mastercard icon")
//            case .visa:
//                return UIImage(named: "your visa icon")
//
//            default:
//                return nil
//            }
//        }
        setupElementsConfiguration()
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
        
        let textColor = UIColor.darkText
        let textFont = UIFont.systemFont(ofSize: 22)
        let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let cardConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_number")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequiredValidOnly = true
        
        cardNumber.configuration = cardConfiguration
        cardNumber.textColor = textColor
        cardNumber.font = textFont
        cardNumber.padding = padding
        cardNumber.placeholder = "4111 1111 1111 1111"
        cardNumber.textAlignment = .natural
        cardNumber.tintColor = .lightGray
        
        cardNumber.sideCardIcon = .right
        cardNumber.iconWidth = 45

        // To handle fields editing events implement `VGSTextFieldDelegate` methods
        // cardNumber.delegate = self
        cardNumber.becomeFirstResponder()

        let expDateConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_expirationDate")
        expDateConfiguration.isRequiredValidOnly = true
        expDateConfiguration.type = .expDate
        /// Default .expDate format is "##/##"
        expDateConfiguration.formatPattern = "##/####"
        
        expCardDate.configuration = expDateConfiguration
        expCardDate.textColor = textColor
        expCardDate.font = textFont
        expCardDate.padding = padding
        expCardDate.placeholder = "MM/YYYY"
        expCardDate.tintColor = .lightGray

        let cvcConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_cvc")
        cvcConfiguration.isRequired = true
        cvcConfiguration.type = .cvc

        cvcCardNum.configuration = cvcConfiguration
        cvcCardNum.textColor = textColor
        cvcCardNum.font = textFont
        cvcCardNum.padding = padding
        cvcCardNum.placeholder = "CVC"
        cvcCardNum.tintColor = .lightGray

        let holderConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "cardHolder_name")
        holderConfiguration.type = .cardHolderName
        cardHolderName.configuration = holderConfiguration
        cardHolderName.textColor = textColor
        cardHolderName.font = textFont
        cardHolderName.padding = padding
        cardHolderName.placeholder = "Cardholder Name"
        cardHolderName.tintColor = .lightGray
    }
    
    // Start CardIO scanning
    @IBAction func scanAction(_ sender: Any) {
        scanController.presentCardScanner(on: self, animated: true, completion: nil)
    }
    
    // Upload data from TextFields to VGS
    @IBAction func uploadAction(_ sender: Any) {
      // hide kayboard
      hideKeyboard()

      // send extra data
      var extraData = [String: Any]()
      extraData["customKey"] = "Custom Value"

      /// New sendRequest func
      vgsForm.sendData(path: "/post", extraData: extraData) { [weak self](response) in
        
        self?.consoleStatusLabel.text = "RESPONSE"
        switch response {
          case .success(_, let data, _):
            if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
              self?.consoleLabel.text = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
              }
              return
          case .failure(let code, _, _, let error):
            switch code {
            case 400..<499:
              // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
              self?.consoleLabel.text = "Wrong Request Error: \(code)"
            case VGSErrorType.inputDataIsNotValid.rawValue:
              if let error = error as? VGSError {
                self?.consoleLabel.text = "Input data is not valid. Details:\n \(error)"
              }
            default:
              self?.consoleLabel.text = "Something went wrong. Code: \(code)"
            }
            print("Submit request error: \(code), \(String(describing: error))")
            return
        }
      }
      
      /// Deprecated
//        vgsForm.submit(path: "/post", extraData: extraData, completion: { [weak self] (json, error) in
//           self?.consoleStatusLabel.text = "RESPONSE"
//            if error == nil, let data = json?["json"] as? [String: Any] {
//                self?.consoleLabel.text = (String(data: try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted), encoding: .utf8)!)
//           } else {
//               if let error = error as NSError?, let errorKey = error.userInfo["key"] as? String {
//                   if errorKey == VGSSDKErrorInputDataIsNotValid {
//                       // Handle VGSError error
//                   }
//               }
//               self?.consoleLabel.text = "Something went wrong!"
//               print("Error: \(String(describing: error))")
//           }
//        })
    }
}

extension ViewController: VGSCardIOScanControllerDelegate {
    
    //When user press Done button on CardIO screen
    func userDidFinishScan() {
        scanController.dismissCardScanner(animated: true, completion: {
            // add actions on scan controller dismiss completion
        })
    }
    
    //When user press Cancel button on CardIO screen
    func userDidCancelScan() {
        scanController.dismissCardScanner(animated: true, completion: nil)
    }
    
    //Asks VGSTextField where scanned data with type need to be set.
    func textFieldForScannedData(type: CradIODataType) -> VGSTextField? {
        switch type {
        case .expirationDate:
            return expCardDate
        case .cvc:
            return cvcCardNum
        case .cardNumber:
            return cardNumber
        default:
            return nil
        }
    }
}
