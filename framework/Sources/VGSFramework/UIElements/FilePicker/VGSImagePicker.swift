//
//  VGSImagePicker.swift
//  VGSFramework
//
//  Created by Dima on 13.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal class VGSImagePicker: NSObject, FilePickerProtocol {
    weak var vgsCollector: VGSCollect?
    var filename: String = ""
    let picker = UIImagePickerController()
    
    required init(configuration: VGSFilePickerConfiguration, sourceType: UIImagePickerController.SourceType) {
        super.init()
        vgsCollector = configuration.vgsCollector
        filename = configuration.fieldName
        picker.sourceType = sourceType
        picker.delegate = self
    }
    
    func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        if !isSourceEnabled() {
            //delegate error
            return
        }
        viewController.present(picker, animated: animated, completion: completion)
    }
    
    private func isSourceEnabled() -> Bool {
        switch picker.sourceType {
        case .camera:
            return UIImagePickerController.isSourceTypeAvailable(.camera)
        case .photoLibrary:
            return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        case .savedPhotosAlbum:
            return UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        }
    }
}

extension VGSImagePicker: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            vgsCollector?.storage.files[filename] = image
        } else {
            //delegate error
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
