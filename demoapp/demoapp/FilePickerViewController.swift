//
//  ViewController2.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 12.02.2020.
//  Copyright © 2020 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSCollectSDK

/// A class that demonstrates how to use VGSFilePicker for uploading files to VGS
class FilePickerViewController: UIViewController {

    // Create strong referrence of VGSFilePickerController
    @IBOutlet weak var stateLabel: UILabel!
    
    // Create strong reference of VGSFilePickerController instance
    var pickerController: VGSFilePickerController?
    
    // Init VGS Collector
    var vgsForm = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)


    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateLabel.text = "Pick a file that you want to Upload!"
    }
    
    @IBAction func selectFileAction(_ sender: UIButton) {
        selectFileFromSource()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        stateLabel.text = "Uploading file..."
        let extraData = ["document_holder": "Joe Business"]
        
        vgsForm.submitFile(path: "/post", method: .post, extraData: extraData) { [weak self](json, error) in
            if error == nil, let json = json?["json"] {
                self?.stateLabel.text = "Success!!!\n" + (String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
                self?.vgsForm.cleanFiles()
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
                self?.stateLabel.text = "Something went wrong!"
            }
        }
    }
    
    // Show file picker for specific source type
    func showPickerWithSource(_ source: VGSFileSource) {
        let fieldName = source == .documentsDirectory ? "secret_doc" : "card_image"
        let filePickerConfig = VGSFilePickerConfiguration(collector: vgsForm, fieldName: fieldName, fileSource: source)
        pickerController = VGSFilePickerController(configuration: filePickerConfig)
        pickerController?.delegate = self
        pickerController?.presentFilePicker(on: self, animated: true, completion: nil)
    }
    
    // Add UI to select source type
    private func selectFileFromSource() {
        let alert = UIAlertController(title: "Source Type", message: "Where is file you need to upload?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Photo Library", style: .default , handler:{ [weak self]  (UIAlertAction)in
            self?.showPickerWithSource(.photoLibrary)
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
}

extension FilePickerViewController: VGSFilePickerControllerDelegate {
    // Check file info, selected by user
    func userDidPickFileWithInfo(_ info: VGSFileInfo) {
        self.stateLabel.text = """
                                File info:
                                - fileExtension: \(info.fileExtension ?? "unknown")
                                - size: \(info.size)
                                - sizeUnits: \(info.sizeUnits ?? "unknown")
                                """
        pickerController?.dismissFilePicker(animated: true)
    }
    
    // Handle cancel file selection
    func userDidSCancelFilePicking() {
        pickerController?.dismissFilePicker(animated: true)
    }
    
    // Handle errors on picking the file
    func filePickingFailedWithError(_ error: VGSError) {
        self.stateLabel.text = error.localizedDescription
        pickerController?.dismissFilePicker(animated: true)
    }
}
