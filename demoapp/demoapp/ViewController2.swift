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

    let vgsForm = VGSCollect(id: "tnts8xrfjrt")
     
    @IBOutlet weak var activity: UIActivityIndicatorView! {
        didSet {
            activity.stopAnimating()
        }
    }
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = ""
        }
    }
    @IBOutlet weak var button: VGSButton! {
        didSet {
            button.presentViewController = self
        }
    }
        
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        button.configuration = VGSConfiguration(collector: vgsForm, fieldName: "data")
        
        let configuration = VGSConfiguration(collector: vgsForm, fieldName: "image")
        configuration.type = .cardHolderName
    }
    
    // MARK: - Action
    @IBAction private func submit(_ sender: UIButton) {
        sender.isEnabled = false
        activity.startAnimating()
        label.text = "Uploading..."
        vgsForm.submitFiles(path: "/post", method: .post) { [weak self] (json, error) in
        
            self?.activity.stopAnimating()
            sender.isEnabled = true
            
            if (error != nil) {
                self?.label.text = error?.localizedDescription
            } else {
                self?.label.text = json?["data"] as? String
            }
        }
    }
}
