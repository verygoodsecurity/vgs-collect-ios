//
//  ViewController2.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 12.02.2020.
//  Copyright © 2020 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSCollectSDK

class ViewController2: UIViewController {

    @IBOutlet weak var button: VGSFilePicker!
    // Collector vgs
    var vgsForm = VGSCollect(id: "id", environment: environment)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button.configuration = VGSConfiguration(collector: vgsForm, fieldName: "image")
        button.presentViewController = self
//        button.type = .library
    }
    
    @IBAction func uploadTap(_ sender: UIButton) {
        vgsForm.submitFiles(path: "/post", method: .post) { (result, error) in
            
            
        }
    }
}
