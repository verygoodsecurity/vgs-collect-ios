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

    // Create strong referrence of VGSFilePickerController
    @IBOutlet weak var stateLabel: UILabel!
    var pickerController: VGSFilePickerController?
    // Collector vgs
    var vgsForm = VGSCollect(id: "tntdw5wjxet", environment: environment)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateLabel.text = "Select File to Upload!"
    }
    
    @IBAction func selectFileAction(_ sender: UIButton) {
        selectFileFromSource()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        stateLabel.text = "Uploading file..."
        vgsForm.submitFile(path: "/post", method: .post) { [weak self](json, error) in
            if error == nil, let json = json {
                self?.stateLabel.text = "Success!!!\n" + (String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
                self?.stateLabel.text = "Something when wrong!"
            }
        }
    }
    
    private func selectFileFromSource() {
        let alert = UIAlertController(title: "Source Type", message: "Where is file you need to upload?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Photo Library", style: .default , handler:{ [weak self]  (UIAlertAction)in
            self?.showPickerWithSource(.library)
        }))

        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ [weak self](UIAlertAction)in
            self?.showPickerWithSource(.camera)
        }))

        alert.addAction(UIAlertAction(title: "Documents Directory", style: .default , handler:{ [weak self] (UIAlertAction)in
            self?.showPickerWithSource(.documentsDirectory)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func showPickerWithSource(_ source: VGSFileSource) {
        let fieldName = source == .documentsDirectory ? "secred_doc" : "card_image"
        let filePickerConfig = VGSFilePickerConfiguration(collector: vgsForm, fieldName: fieldName, fileSource: source)
        pickerController = VGSFilePickerController(configuration: filePickerConfig)
        pickerController?.delegate = self
        pickerController?.presentFilePicker(on: self, animated: true, completion: nil)
    }
    
}

extension FilePickerViewController: VGSFilePickerControllerDelegate {
    func userDidPickFileWithInfo(_ info: VGSFileInfo) {
        self.stateLabel.text = """
                                File info:
                                - fileExtension: \(info.fileExtension ?? "unknown")
                                - size: \(info.size)
                                - sizeUnit: \(info.sizeUnit ?? "unknown")
                                """
        pickerController?.dismissFilePicker(animated: true)
    }
    
    func userDidSCancelFilePicking() {
        pickerController?.dismissFilePicker(animated: true)
    }
    
    func filePickingFailedWithError(_ error: String) {
        self.stateLabel.text = "Select file error! Try again!"
        pickerController?.dismissFilePicker(animated: true)
    }
}
