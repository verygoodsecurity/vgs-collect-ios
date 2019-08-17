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
    
    override func loadView() {
        super.loadView()
        initialization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        
        cardNumebr.text = "3456789867656545"
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
        
        // init expiration card date
        view.addSubview(expCardDate)
        expCardDate.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardNumebr.snp.bottom).offset(10)
        }
        
        // init CVV card number
        view.addSubview(cvvCardNum)
        cvvCardNum.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(expCardDate.snp.bottom).offset(10)
        }
    }
    
    private func setupTextFields() {
        // type
//        cardNumebr.type = .creditCardField
//        expCardDate.type = .dateExpirationField
//        cvvCardNum.type = .cvvField
        
        // placeholder
        cardNumebr.placeholder = "card number"
        expCardDate.placeholder = "expiration date"
        cvvCardNum.placeholder = "cvv"
    }
}

