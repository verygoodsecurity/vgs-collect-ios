//
//  ViewController.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSCollectSDK
import SnapKit

let vaultId = "vaultId"// Set your vault id here https://www.verygoodsecurity.com/terminology/nomenclature#vault
let environment = Environment.sandbox // Set enviremont

class ViewController: UIViewController {
    
    var scanController = VGSCardIOScanController()
    var consoleLabel: UILabel!
    var consoleStatusLabel: UILabel!
    var consoleMessage: String = "" {
        didSet {
            consoleLabel.text = consoleMessage
        }
    }
    // Collector vgs
    var vgsForm = VGSCollect(id: vaultId, environment: environment)
    
    // VGS UI Elements
    // initialase you cardNumber like a VGSCardTextField class
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSTextField()
    var cvcCardNum = VGSTextField()
    var cardHolderName = UITextField(frame: .zero)
    
    // Send data Button
    var sendButton = UIButton()
    // Scan card action button
    var scanButton = UIButton()

    // MARK: - Life cycle methods
    override func loadView() {
        super.loadView()
        setupUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        setupElements()
    }

    // MARK: - Init UI
    private func setupUI() {
        // title
        let titleLabel = UILabel()
        titleLabel.text = "Collecting credit card data"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 22)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(55)
        }

        view.addSubview(cardHolderName)
        cardHolderName.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
            make.top.equalTo(120)
        }

        // setup card number text field
        view.addSubview(cardNumber)
        cardNumber.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardHolderName.snp.bottom).offset(10)
        }
        // setup expiration card date
        view.addSubview(expCardDate)
        expCardDate.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardNumber.snp.bottom).offset(10)
        }

        // setup CVC card number
        view.addSubview(cvcCardNum)
        cvcCardNum.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
            make.top.equalTo(expCardDate.snp.bottom).offset(10)
        }

        // init send button
        sendButton.setTitle("SEND", for: .normal)
        sendButton.backgroundColor = UIColor(red: 0.337, green: 0.761, blue: 0.333, alpha: 1.00)
        sendButton.layer.cornerRadius = 6
        sendButton.clipsToBounds = true
        view.addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(55)
            make.width.equalTo(150)
            make.top.equalTo(cvcCardNum.snp.bottom).offset(35)
        }
        
        scanButton.setTitle("SCAN", for: .normal)
        scanButton.backgroundColor = UIColor(red: 0.337, green: 0.761, blue: 0.333, alpha: 1.00)
        scanButton.layer.cornerRadius = 6
        scanButton.clipsToBounds = true
        scanButton.backgroundColor = .blue
        view.addSubview(scanButton)
        scanButton.snp.makeConstraints { make in
            make.right.equalTo(-25)
            make.top.equalTo(sendButton.snp.top)
            make.height.equalTo(sendButton.snp.height)
            make.width.equalTo(150)
        }

        // setup console views
        let separastor = UIView()
        separastor.backgroundColor = .lightGray
        view.addSubview(separastor)
        separastor.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(35)
            make.left.right.equalTo(0)
            make.height.equalTo(1)
        }

        let consoleBackgroundView = UIView()
        consoleBackgroundView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        view.addSubview(consoleBackgroundView)
        consoleBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(separastor.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalToSuperview().priority(250)
        }

        consoleStatusLabel = UILabel(frame: .zero)
        consoleStatusLabel.text = "Waiting for data..."
        consoleStatusLabel.numberOfLines = 0
        consoleStatusLabel.textAlignment = .center
        consoleStatusLabel.textColor = .darkGray
        consoleStatusLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        consoleStatusLabel.backgroundColor = .white
        consoleBackgroundView.addSubview(consoleStatusLabel)
        consoleStatusLabel.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(40)
        }

        consoleLabel = UILabel(frame: .zero)
        consoleLabel.text = ""
        consoleLabel.textAlignment = .left
        consoleLabel.numberOfLines = 0
        consoleLabel.contentMode = .topLeft
        consoleLabel.textColor = .black
        consoleBackgroundView.addSubview(consoleLabel)

        consoleLabel.snp.makeConstraints { make in
            make.top.equalTo(consoleStatusLabel.snp.bottom).offset(8)
            make.left.right.equalTo(15)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        consoleLabel.addGestureRecognizer(tapGesture)
        consoleLabel.isUserInteractionEnabled = true
    }

    @objc
    func hideKeyboard() {
        view.endEditing(true)
    }

    private func setupElements() {
        
        let textColor = UIColor.darkText
        let textFont = UIFont.systemFont(ofSize: 22)
        let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let cardConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_number")
        cardConfiguration.isRequired = true
        cardConfiguration.type = .cardNumber

        cardNumber.configuration = cardConfiguration
        cardNumber.textColor = textColor
        cardNumber.font = textFont
        cardNumber.padding = padding
        cardNumber.placeholder = "Card Number"
        cardNumber.textAlignment = .natural
        // To handle VGSTextFieldDelegate methods
        // cardNumber.delegate = self
        cardNumber.becomeFirstResponder()

        let expDateConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_expirationDate")
        expDateConfiguration.isRequired = true
        expDateConfiguration.type = .expDate

        expCardDate.configuration = expDateConfiguration
        expCardDate.textColor = textColor
        expCardDate.font = textFont
        expCardDate.padding = padding
        expCardDate.placeholder = "MM/YY"

        let cvcConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_cvc")
        cvcConfiguration.isRequired = true
        cvcConfiguration.type = .cvc

        cvcCardNum.configuration = cvcConfiguration
        cvcCardNum.textColor = textColor
        cvcCardNum.font = textFont
        cvcCardNum.padding = padding
        cvcCardNum.placeholder = "CVC"

        cardHolderName.layer.borderWidth = 1
        cardHolderName.layer.borderColor = UIColor.lightGray.cgColor
        cardHolderName.layer.cornerRadius = 4
        cardHolderName.placeholder = "Name"
        cardHolderName.font = textFont
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: cardHolderName.frame.height))
        cardHolderName.leftView = paddingView
        cardHolderName.leftViewMode = .always

        // Add target for send button
        sendButton.addTarget(self, action: #selector(sendData(_:)), for: .touchUpInside)
        scanButton.addTarget(self, action: #selector(scanData(_:)), for: .touchUpInside)
        
    }
}

// MARK: - send/receive data
extension ViewController {
    @objc
    func sendData(_ sender: UIButton) {
 
        // hide kayboard
        hideKeyboard()

        // send extra data
        var extraData = [String: Any]()
        extraData["cardHolderName"] = cardHolderName.text

        // send data
        vgsForm.submit(path: "post", extraData: extraData, completion: { [weak self] (json, error) in
            self?.consoleStatusLabel.text = "RESPONSE"
            if error == nil, let json = json {
                self?.consoleLabel.text = (String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
            } else {
                self?.consoleLabel.text = "Something went wrong!"
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
    
    @objc
    func scanData(_ sender: UIButton) {
        scanController.presentCardScanner(on: self, animated: true, completion: nil)
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
