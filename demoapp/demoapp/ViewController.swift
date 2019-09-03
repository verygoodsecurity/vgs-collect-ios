//
//  ViewController.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSFramework

class ViewController: UIViewController {
    var consoleLabel: UILabel!
    var consoleMessage: String = "" {
        didSet {
            consoleLabel.text = consoleMessage
        }
    }
    // VGS Core
    var vgs = VGS(tnt: "tntva5wfdrp", environment: .sandbox)
    // VGS Elements
    var cardNumber = VGSTextField()
    var expCardDate = VGSTextField()
    var cvvCardNum = VGSTextField()
    var cardHolderName = UITextField(frame: .zero)
    
    // Button
    var sendButton = UIButton()
    
    // MARK: - Life circle methods
    override func loadView() {
        super.loadView()
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // chack jailbroke
        if VGS.isJailbroken() {
            print("Device is Jailbroken")
        }
        // Observe data
        vgs.observeForm = { [weak self] form in
            
            self?.consoleMessage = ""
            
            form.forEach({ textField in
                let name = textField.configuration?.alias ?? "no name"
                
                let isEmpty = textField.isEmpty
                let isFocused = textField.isFocused
                
                self?.consoleMessage.append("\n\(name)\tisEmpty: \(isEmpty), isFocused: \(isFocused)\n")
                
                textField.setGreenBorder(!isEmpty)
            })
        }
        setupElements()
//        uncomment for testing
//        turnOnObservation()
    }
    
    // MARK: - Init UI
    private func setupUI() {
        // init card holder name
        cardHolderName.layer.borderWidth = 1
        cardHolderName.layer.borderColor = UIColor.lightGray.cgColor
        cardHolderName.layer.cornerRadius = 4
        cardHolderName.placeholder = " card holder name"
        view.addSubview(cardHolderName)
        cardHolderName.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(55)
        }
        
        // init card number text field
        view.addSubview(cardNumber)
        cardNumber.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardHolderName.snp.bottom).offset(10)
        }
        
        // init expiration card date
        view.addSubview(expCardDate)
        expCardDate.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardNumber.snp.bottom).offset(10)
        }
        
        // init CVV card number
        view.addSubview(cvvCardNum)
        cvvCardNum.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(expCardDate.snp.bottom).offset(10)
        }
        
        // init send button
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = UIColor.myGreen
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
        cardNumber.configuration = VGSTextFieldConfig(vgs, alias: "cardNumber",
                                                      textField: .cardNumberField,
                                                      placeholder: "card number")
        
        expCardDate.configuration = VGSTextFieldConfig(vgs, alias: "expDate",
                                                       textField: .dateExpirationField,
                                                       placeholder: "exp date")
        
        cvvCardNum.configuration = VGSTextFieldConfig(vgs, alias: "cvvNum",
                                                      textField: .cvvField,
                                                      placeholder: "cvv")
        
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
        view.endEditing(true)
        
        // send data
        vgs.sendData(completion: { [weak self] (json, error) in
            if error == nil, let json = json {
                self?.consoleLabel.text = json.description
            } else {
                self?.consoleLabel.text = "Something went wrong!"
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
}

// MARK: - Check security
extension ViewController {
    func turnOnObservation() {
        // Important thing
        // using for lessing mistakes #keyPath(cardNumber.textView)
        addObserver(self,
                    forKeyPath: "cardNumber.text",
                    options: [.old, .new],
                    context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "cardNumber.text" {
            
            print(" We r hacked")
        }
    }
}
