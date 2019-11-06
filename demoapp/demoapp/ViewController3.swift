//
//  ViewController3.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 27.10.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSCollectSDK

class ViewController3: UIViewController {

    @IBOutlet weak var cardNumber: VGSTextField!
    @IBOutlet weak var expDate: VGSTextField!
    @IBOutlet weak var cvv: VGSTextField!
    
    let vgsForm = VGSCollect(id: "tntva5wfdrp")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cardConfig = VGSConfiguration(collector: vgsForm, fieldName: "cardNumber")
        cardConfig.type = .cardNumber
        cardConfig.placeholder = "card numer"
        
        cardNumber.configuration = cardConfig
        cardNumber.font = UIFont.systemFont(ofSize: 24)
        cardNumber.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        let expDateConfig = VGSConfiguration(collector: vgsForm, fieldName: "expDate")
        expDateConfig.type = .expDate
        expDateConfig.placeholder = "exp date"
        
        expDate.configuration = expDateConfig
        expDate.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        let cvvConfig = VGSConfiguration(collector: vgsForm, fieldName: "cvv")
        cvvConfig.type = .cvv
        cvvConfig.placeholder = "cvv"
        
        cvv.configuration = cvvConfig
        cvv.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    @IBAction func sendData(_ sender: UIButton) {
        // hide kayboard
        view.endEditing(true)
        
        // send data
        vgsForm.submit(path: "post", extraData: nil, completion: { [weak self] (json, error) in
            
            let message = error == nil ? "All data is sent successfully." : "Something went wrong!"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .destructive, handler: nil))
            self?.present(alert, animated: true, completion: nil)
            
        })
    }
}
