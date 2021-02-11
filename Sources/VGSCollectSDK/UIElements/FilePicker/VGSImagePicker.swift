//
//  VGSImagePicker.swift
//  VGSCollectSDK
//
//  Created by Dima on 13.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// A class that manage UIImagePickerController
internal class VGSImagePicker: NSObject, VGSFilePickerProtocol {
    
    weak var delegate: VGSFilePickerControllerDelegate?
    
    private weak var vgsCollector: VGSCollect?
    private var filename: String = ""
    private var picker = UIImagePickerController()
    
    required init(configuration: VGSFilePickerConfiguration, sourceType: UIImagePickerController.SourceType) {
        super.init()
        vgsCollector = configuration.vgsCollector
        filename = configuration.fieldName
        picker.sourceType = sourceType
        picker.allowsEditing = false
        picker.delegate = self
    }
    
    func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        if !isSourceEnabled() {
          let text = "Image source not available. Source: \(picker.sourceType)"
          let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
          VGSCollectLogger.shared.forwardLogEvent(event)
          
            delegate?.filePickingFailedWithError(VGSError(type: .sourceNotAvailable, userInfo: VGSErrorInfo(key: VGSSDKErrorSourceNotAvailable, description: "Image source not available.", extraInfo: ["source": "\(picker.sourceType)"])))
            return
        }
        viewController.present(picker, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        picker.dismiss(animated: animated, completion: completion)
    }
    
    private func isSourceEnabled() -> Bool {
        switch picker.sourceType {
        case .camera:
            return UIImagePickerController.isSourceTypeAvailable(.camera)
        case .photoLibrary:
            return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        case .savedPhotosAlbum:
            return UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        @unknown default:
            return false
        }
    }
}

extension VGSImagePicker: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.userDidSCancelFilePicking()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            var data: Data?
            var fileExtension = ""
            if let jpegData = image.jpegData(compressionQuality: 1) {
                data = jpegData
                fileExtension = "jpeg"
            } else if let pngData = image.pngData() {
                data = pngData
                fileExtension = "png"
            }
            
            guard let imageData = data else {
              let text = "Image File format is not supported!!! Can't convert to Data."
              let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
              VGSCollectLogger.shared.forwardLogEvent(event)
              
                delegate?.filePickingFailedWithError(VGSError(type: .inputFileTypeIsNotSupported, userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported, description: "Image File format is not supported. Can't convert to Data.", extraInfo: [:])))
                return
            }
            
            vgsCollector?.storage.files = [filename: imageData]
            let imgMetadata = VGSFileInfo(fileExtension: fileExtension, size: imageData.count, sizeUnits: "bytes")
            delegate?.userDidPickFileWithInfo(imgMetadata)
            return
        } else {
          let text = "Image File format is not supported. Cannot convert to Data object!!!."
          let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
          VGSCollectLogger.shared.forwardLogEvent(event)
          
            delegate?.filePickingFailedWithError(VGSError(type: .inputFileTypeIsNotSupported, userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported, description: "Image File format is not supported.", extraInfo: [:])))
            return
        }
    }
}
