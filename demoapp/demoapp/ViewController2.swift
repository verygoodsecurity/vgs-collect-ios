//
//  ViewController2.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 9/28/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSFramework

class ViewController2: UIViewController {

    @IBOutlet weak var textField: VGSTextField!
    
    var vgsCollector = VGSCollect(tnt: "ytyty")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let config = VGSConfiguration(collector: vgsCollector, fieldName: "test")
        config.isRequired = false
        config.placeholder = "name pppp"
        config.type = .cardNumber
        
        textField.configuration = config
        
        textField.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
