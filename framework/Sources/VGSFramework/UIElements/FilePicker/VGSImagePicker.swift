//
//  VGSImagePicker.swift
//  VGSFramework
//
//  Created by Dima on 13.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal class VGSImagePicker: NSObject, VGSFilePickerProtocol {
    
    weak var delegate: VGSFilePickerControllerDelegate?
    
    private weak var vgsCollector: VGSCollect?
    private var filename: String = ""
    private let picker = UIImagePickerController()
    
    required init(configuration: VGSFilePickerConfiguration, sourceType: UIImagePickerController.SourceType) {
        super.init()
        vgsCollector = configuration.vgsCollector
        filename = configuration.fieldName
        picker.sourceType = sourceType
        picker.delegate = self
    }
    
    func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        if !isSourceEnabled() {
            delegate?.filePickingFailedWithError?("image_source_not_available_error")
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
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 1) {
            vgsCollector?.storage.files[filename] = imageData
            let imgMetadata = VGSFileInfo(fileExtension: "jpeg", size: imageData.count, sizeUnit: "byte")
            delegate?.userDidPickFileWithInfo(imgMetadata)
        } else {
            delegate?.filePickingFailedWithError?("image_not_found_error")
        }
    }
}
