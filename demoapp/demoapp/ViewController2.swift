//
//  ViewController2.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 9/28/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSCollectSDK

class ViewController2: UIViewController {

    let vgsForm = VGSCollect(id: "tntva5wfdrp")
    
    @IBOutlet weak var button: VGSButton! {
        didSet {
            button.presentViewController = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = VGSConfiguration(collector: vgsForm, fieldName: "image")
        configuration.type = .cardHolderName
    }
}
