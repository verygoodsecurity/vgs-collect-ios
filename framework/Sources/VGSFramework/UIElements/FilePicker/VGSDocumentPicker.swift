//
//  VGSDocumentPicker.swift
//  VGSFramework
//
//  Created by Dima on 13.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import MobileCoreServices

internal class VGSDocumentPicker: NSObject, VGSFilePickerProtocol {
    
    weak var delegate: VGSFilePickerControllerDelegate?
    private weak var vgsCollector: VGSCollect?
    private var filename: String = ""
    private var picker: UIDocumentPickerViewController!
    
    required init(configuration: VGSFilePickerConfiguration) {
        super.init()
        vgsCollector = configuration.vgsCollector
        filename = configuration.fieldName
        
        let docType = [String(kUTTypeText),
                       String(kUTTypeContent),
                       String(kUTTypeItem),
                       String(kUTTypeData)]
        picker = UIDocumentPickerViewController(documentTypes: docType, in: .import)
        picker.delegate = self
        if #available(iOS 11.0, *) {
            picker.allowsMultipleSelection = false
        }
    }
    
    func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        viewController.present(picker, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        picker.dismiss(animated: animated, completion: completion)
    }
}

extension VGSDocumentPicker: UIDocumentPickerDelegate {
     func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        if controller.documentPickerMode == .import {
            if let url = urls.first {
                vgsCollector?.storage.files[filename] = try? Data(contentsOf: url)
            } else {
                delegate?.filePickingFailedWithError?("file_not_found_error")
            }
            return
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.userDidSCancelFilePicking()
    }
}
