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
        setupTextFields()
        
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
    
    private func setupTextFields() {
        // type for text fields
        cardNumebr.type = .cardNumberField
        nameHolder.type = .nameHolderField
        expCardDate.type = .dateExpirationField
        cvvCardNum.type = .cvvField
        
        // type for button
        send.type = .sendButton
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
