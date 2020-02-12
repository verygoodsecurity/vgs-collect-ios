//
//  VGSButton+file.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 27.10.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import MobileCoreServices

extension VGSFilePicker: UIDocumentPickerDelegate {
    internal func getFile() {
        guard let presenter = presentViewController else {
            fatalError("Need to set presentViewController for VGSButton")
        }
        
        let docType = [String(kUTTypeText),
                       String(kUTTypeContent),
                       String(kUTTypeItem),
                       String(kUTTypeData)]
        let picker = UIDocumentPickerViewController(documentTypes: docType, in: .import)
        picker.delegate = self
        presenter.present(picker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if controller.documentPickerMode == .import {
            if let url = urls.first {
                title = "Selected"
                vgsCollector?.storage.files[fieldName] = try? Data(contentsOf: url)
                
            } else {
                print("⚠️ Error: file not found...")
            }
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
