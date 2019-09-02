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
    @IBOutlet weak var consoleLabel: UILabel!

    // VGS Core
    var vgs: VGS = VGS(upstreamHost: "https://tntva5wfdrp.SANDBOX.verygoodproxy.com")
    
    // VGS Elements
    var cardNumber = VGSTextField()
    var expCardDate = VGSTextField()
    var cvvCardNum = VGSTextField()
    var nameHolder = VGSTextField()
    
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
            print("Devise is Jailbroken")
        }
        // Observe data
        vgs.observeForm = { form in
            print("--------------------------------------")
            form.forEach({ textField in
                let name = textField.configuration?.alias ?? "no name"
                let isEmpty = textField.isEmpty
                print("TextField: \(name) isEmpty: \(isEmpty)")
                // set gteen border if tf not empty
                textField.setGreenBorder(!isEmpty)
            })
            
            form.forEach({ textField in
                let name = textField.configuration?.alias ?? "no name"
                let isFocused = textField.isFocused
                print("TextField: \(name) isFocused: \(isFocused)")
                
                textField.setBorderBolder(isFocused)
            })
        }
        
        setupElements()
//        uncomment for testing
//        turnOnObservation()
    }
    
    // MARK: - Init UI
    private func setupUI() {
        // init card number text field
        view.addSubview(cardNumber)
        cardNumber.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(155)
        }
        
        // init name holder
        view.addSubview(nameHolder)
        nameHolder.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardNumber.snp.bottom).offset(10)
        }
        
        // init expiration card date
        view.addSubview(expCardDate)
        expCardDate.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(nameHolder.snp.bottom).offset(10)
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
    }
    
    private func setupElements() {
        cardNumber.configuration = VGSTextFieldConfig(vgs, alias: "cardNumber", textField: .cardNumberField, placeholder: "card number")
        expCardDate.configuration = VGSTextFieldConfig(vgs, alias: "expDate", textField: .dateExpirationField, placeholder: "exp date")
        nameHolder.configuration = VGSTextFieldConfig(vgs, alias: "nameHolder", textField: .nameHolderField, placeholder: "Name Holder")
        cvvCardNum.configuration = VGSTextFieldConfig(vgs, alias: "cvvNum", textField: .cvvField, placeholder: "cvv")
        
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
