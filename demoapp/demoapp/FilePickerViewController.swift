//
//  ViewController2.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 12.02.2020.
//  Copyright © 2020 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSCollectSDK

class FilePickerViewController: UIViewController {

    var filePicker: VGSFilePickerController?
    // Collector vgs
    var vgsForm = VGSCollect(id: "tntdw5wjxet", environment: environment)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func selectFileAction(_ sender: UIButton) {
        
        let filePickerConfig = VGSFilePickerConfiguration.init(collector: vgsForm, fieldName: "card_image", fileSource: .library)
        filePicker = VGSFilePickerController.init(configuration: filePickerConfig)
        filePicker?.present(on: self, animated: true, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        vgsForm.submitFile(path: "/post", method: .post) { (json, error) in
            if error == nil, let json = json {

            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
