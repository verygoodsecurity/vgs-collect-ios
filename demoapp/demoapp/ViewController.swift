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
    var vgs: VGS? = nil
    
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
        
        vgs = VGS(upstreamHost: "https://tntva5wfdrp.SANDBOX.verygoodproxy.com")
        
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
        sendButton.backgroundColor = .green
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalTo(cvvCardNum.snp.bottom).offset(35)
        }
    }
    
    private func setupElements() {
        cardNumber.model = VGSTextFieldModel(alias: "cardNumber", placeholder: "card number", textField: .cardNumberField)        
        expCardDate.model = VGSTextFieldModel(alias: "expDate", placeholder: "exp date", textField: .dateExpirationField)
        nameHolder.model = VGSTextFieldModel(alias: "nameHolder", placeholder: "Name Holder", textField: .nameHolderField)
        cvvCardNum.model = VGSTextFieldModel(alias: "cvvNum", placeholder: "cvv", textField: .cvvField)
        
        // Register text fields
        let tfs = [cardNumber, expCardDate, nameHolder, cvvCardNum]
        vgs?.registerTextFields(textField: tfs)
        
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
        vgs?.sendData(completion: { [weak self] (json, error) in
            
            if error == nil, let json = json {
                print(json)
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
