//
//  VGSButton+imagePicker.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 27.10.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

extension VGSFilePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func getImageFromLibrary() {
        guard let presenter = presentViewController else {
            fatalError("Need to set presentViewController for VGSButton")
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .savedPhotosAlbum
        picker.delegate = self
        presenter.present(picker, animated: true, completion: nil)
    }
    
    internal func getImageFromCamera() {
        guard let presenter = presentViewController else {
            fatalError("Need to set presentViewController for VGSButton")
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            showAlert(message: "No camera - no photo")
            
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .camera
            presenter.present(picker, animated: true, completion: nil)
        }
    }

    // MARK: - UIImage picker delegate
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let originalImage = info[.originalImage] as? UIImage else {
            return
        }
        
        title = "Selected"
        
        vgsCollector?.storage.files[fieldName] = originalImage
        picker.dismiss(animated: true, completion: nil)
    }
}
