//
//  VGSDocumentPicker.swift
//  VGSCollectSDK
//
//  Created by Dima on 13.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
import MobileCoreServices
#endif

/// A class that manage UIDocumentPickerViewController
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
        guard controller.documentPickerMode == .import else {
            return
        }

        if let url = urls.first, let fileData = try? Data(contentsOf: url) {
            vgsCollector?.storage.files = [filename: fileData]
            let fileMetadata = VGSFileInfo(fileExtension: url.pathExtension, size: fileData.count, sizeUnits: "bytes")
            let text = "Did pick a file with size: \(fileData.count)."
            let event = VGSLogEvent(level: .info, text: text, severityLevel: .warning)
            VGSCollectLogger.shared.forwardLogEvent(event)
          
            delegate?.userDidPickFileWithInfo(fileMetadata)
        } else {
            let text = "Document File format is not supported. Cannot convert to Data object!!!."
            let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)
          
            delegate?.filePickingFailedWithError(VGSError(type: .inputFileTypeIsNotSupported, userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported, description: "Document File format is not supported. Can't convert to Data.", extraInfo: [:])))
        }
        return
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.userDidSCancelFilePicking()
    }
}
