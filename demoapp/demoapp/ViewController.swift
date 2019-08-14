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

    @IBOutlet weak var testView: VGSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testView.elementType = .cvvField
        
        testView.borderColor = .red
        testView.borderWidth = 1
    }
}

