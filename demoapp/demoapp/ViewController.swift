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

class ViewController: UIViewController {
    var consoleLabel: UILabel!
    var consoleStatusLabel: UILabel!
    
    var consoleMessage: String = "" {
        didSet {
            consoleLabel.text = consoleMessage
        }
    }
    // Collector vgs
    var vgsForm = VGSCollect(id: "<your-vault-id>", environment: .sandbox)
    
    // VGS UI Elements
    // initialase you cardNumber like a VGSCardTextField class
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSTextField()
    var cvcCardNum = VGSTextField()
    var cardHolderName = UITextField(frame: .zero)
    
    // the Send data Button
    var sendButton = UIButton()
    
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
        
        // Observing text fields
        vgsForm.observeStates = { [weak self] form in
            
            self?.consoleMessage = ""
            self?.consoleStatusLabel.text = "STATE"

            form.forEach({ textField in
                self?.consoleMessage.append(textField.state.description)
                self?.consoleMessage.append("\n")
            })
        }
        
        // if you wonna to set your card brand icon then use this closure
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
        sendButton.setTitle("Submit", for: .normal)
        sendButton.backgroundColor = UIColor(red: 0.337, green: 0.761, blue: 0.333, alpha: 1.00)
        sendButton.layer.cornerRadius = 6
        sendButton.clipsToBounds = true
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalTo(cvcCardNum.snp.bottom).offset(35)
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
        consoleLabel.numberOfLines = 0
        consoleLabel.contentMode = .topLeft
        consoleLabel.textColor = .black
        consoleBackgroundView.addSubview(consoleLabel)
        
        consoleLabel.snp.makeConstraints { make in
            make.top.equalTo(consoleStatusLabel.snp.bottom).offset(8)
            make.left.equalTo(30)
            make.right.equalTo(15)
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
        
        let textColor = UIColor.label
        let textFont = UIFont.systemFont(ofSize: 22)
        let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let cardConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_number")
        cardConfiguration.placeholder = "Card number"
        cardConfiguration.isRequired = true
        cardConfiguration.type = .cardNumber
        
        cardNumber.configuration = cardConfiguration
        cardNumber.textColor = textColor
        cardNumber.font = textFont
        cardNumber.padding = padding
        
        let expDateConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_expirationDate")
        expDateConfiguration.placeholder = "MM/YY"
        expDateConfiguration.isRequired = true
        expDateConfiguration.type = .expDate
        
        expCardDate.configuration = expDateConfiguration
        expCardDate.textColor = textColor
        expCardDate.font = textFont
        expCardDate.padding = padding
        
        let cvcConfiguration = VGSConfiguration(collector: vgsForm, fieldName: "card_cvc")
        cvcConfiguration.placeholder = "CVC"
        cvcConfiguration.isRequired = true
        cvcConfiguration.type = .cvc
        
        cvcCardNum.configuration = cvcConfiguration
        cvcCardNum.textColor = textColor
        cvcCardNum.font = textFont
        cvcCardNum.padding = padding
        
        
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
    }
}

// MARK: - send/receive data
extension ViewController {
    @objc
    func sendData(_ sender: UIButton) {
        consoleLabel.text = "Processing..."
        
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
}
