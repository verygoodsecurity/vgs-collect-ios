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
    
    // VGS Elements
    var cardNumebr = VGSTextField()
    var expCardDate = VGSTextField()
    var cvvCardNum = VGSTextField()
    var nameHolder = VGSTextField()
    var send = VGSButton()
    
    override func loadView() {
        super.loadView()
        initialization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        // uncomment for testing
//        turnOnObservation()
    }
    
    private func initialization() {
        // init card number text field
        view.addSubview(cardNumebr)
        cardNumebr.snp.makeConstraints { make in
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
            make.top.equalTo(cardNumebr.snp.bottom).offset(10)
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
        view.addSubview(send)
        send.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalTo(cvvCardNum.snp.bottom).offset(35)
        }
    }
    
    private func setupElements() {
        cardNumebr.model = VGSModel(alisa: "cardNumber", "card number", type: .cardNumberField)
        expCardDate.model = VGSModel(alisa: "expDate", "exp date", type: .dateExpirationField)
        nameHolder.model = VGSModel(alisa: "nameHolder", "Name Holder", type: .nameHolderField)
        cvvCardNum.model = VGSModel(alisa: "cvvNum", "cvv", type: .cvvField)
        
        // type for button
        send.type = .sendButton
        // callback for see received data
        send.callBack = { [weak self] data, error in
            
            DispatchQueue.main.async {
                
                guard let self = self, error == nil else {
                    return
                }
                
                var txt = ""
                data?.forEach({ (key, value) in
                    txt.append("\(key)= \(value)\n\n")
                })
                
                self.consoleLabel.text = txt
            }
        }
    }
}

// MARK: - Check security
extension ViewController {
    func turnOnObservation() {
        // Important thing
        // using for lessing mistakes #keyPath(cardNumebr.textView)
        addObserver(self,
                    forKeyPath: "cardNumebr.textView",
                    options: [.old, .new],
                    context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "cardNumebr.textView" {
            
            print(" We r hacked")
        }
    }
}
