//
//  ViewController.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSFramework
import SnapKit

class ViewController: UIViewController {
    var consoleLabel: UILabel!
    var consoleMessage: String = "" {
        didSet {
            consoleLabel.text = consoleMessage
        }
    }
    // Collector vgs
    var vgsCollector = VGSCollect(tnt: "tntva5wfdrp", environment: .sandbox)
    
    // VGS UI Elements
    var cardNumber = VGSTextField()
    var expCardDate = VGSTextField()
    var cvvCardNum = VGSTextField()
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
        vgsCollector.customHeaders = [
            "my custome header": "some custom data"
        ]
        
        // Observing text fields
        vgsCollector.observeForm = { [weak self] form in
            
            self?.consoleMessage = ""
            
            form.forEach({ textField in
                                
                self?.consoleMessage.append(textField.state.description)
                self?.consoleMessage.append("\n")
            })
        }
        setupElements()
    }
    
    // MARK: - Init UI
    private func setupUI() {
        // init card holder name
        cardHolderName.layer.borderWidth = 1
        cardHolderName.layer.borderColor = UIColor.lightGray.cgColor
        cardHolderName.layer.cornerRadius = 4
        cardHolderName.placeholder = "card holder name"
        view.addSubview(cardHolderName)
        cardHolderName.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(55)
        }
        
        // setup card number text field
        view.addSubview(cardNumber)
        cardNumber.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardHolderName.snp.bottom).offset(10)
        }
        
        // setup expiration card date
        view.addSubview(expCardDate)
        expCardDate.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardNumber.snp.bottom).offset(10)
        }
        
        // setup CVV card number
        view.addSubview(cvvCardNum)
        cvvCardNum.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(expCardDate.snp.bottom).offset(10)
        }
        
        // init send button
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = UIColor(red: 0.337, green: 0.761, blue: 0.333, alpha: 1.00)
        sendButton.layer.cornerRadius = 6
        sendButton.clipsToBounds = true
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalTo(cvvCardNum.snp.bottom).offset(35)
        }
        
        ///
        consoleLabel = UILabel(frame: .zero)
        consoleLabel.text = ""
        consoleLabel.numberOfLines = 0
        consoleLabel.contentMode = .topLeft
        consoleLabel.backgroundColor = .lightGray
        consoleLabel.textColor = .black
        view.addSubview(consoleLabel)
        consoleLabel.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(35)
            make.left.equalTo(25)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().priority(250)
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
        let cardConfiguration = VGSConfiguration(collector: vgsCollector, fieldName: "cardNumber")
        cardConfiguration.placeholder = "card number"
        cardConfiguration.isRequired = true
        cardConfiguration.type = .cardNumber
        
        cardNumber.configuration = cardConfiguration
        
        let expDateConfiguration = VGSConfiguration(collector: vgsCollector, fieldName: "expDate")
        expDateConfiguration.placeholder = "exp date"
        expDateConfiguration.isRequired = true
        expDateConfiguration.type = .expDate
        
        expCardDate.configuration = expDateConfiguration
        
         let cvvConfiguration = VGSConfiguration(collector: vgsCollector, fieldName: "cvvNum")
        cvvConfiguration.placeholder = "cvv"
        cvvConfiguration.isRequired = true
        cvvConfiguration.type = .cvv
        
        cvvCardNum.configuration = cvvConfiguration
        
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
        var data = [String: Any]()
        data["cardHolderName"] = cardHolderName.text
        
        // send data
        vgsCollector.sendData(path: "post", data: data, completion: { [weak self] (json, error) in
            if error == nil, let json = json {
                var strJson = json.description
                strJson = strJson.replacingOccurrences(of: "[", with: "[\n")
                strJson = strJson.replacingOccurrences(of: "]", with: "\n]")
                strJson = strJson.replacingOccurrences(of: ",", with: ",\n")
                self?.consoleLabel.text = strJson
                
            } else {
                self?.consoleLabel.text = "Something went wrong!"
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
}
