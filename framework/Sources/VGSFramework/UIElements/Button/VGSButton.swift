//
//  VGSButton.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 10/6/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import MobileCoreServices

public class VGSButton: UIView {
    private(set) weak var vgsCollector: VGSCollect?
    internal var button = UIButton(type: .custom)
    internal var fieldName: String!
    internal var file: Data?
    internal var image: UIImage?
    internal var token: String?
    
    public var type: ButtonType = .none
    public var presentViewController: UIViewController?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        mainInitialization()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mainInitialization()
    }
    
    // MARK: - private API
    private func mainInitialization() {
        
        mainStyle()
        
        button.setTitle("Upload", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        let views = ["view": self, "button": button]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[button]-0-|",
                                                                   options: .alignAllCenterY,
                                                                   metrics: nil,
                                                                   views: views)
        NSLayoutConstraint.activate(horizontalConstraints)
        
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[button]-0-|",
                                                                options: .alignAllCenterX,
                                                                metrics: nil,
                                                                views: views)
        NSLayoutConstraint.activate(verticalConstraint)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc
    internal func buttonAction(_ sender: UIButton) {
        switch type {
        case .camera:
            getImageFromCamera()
            
        case .library:
            getImageFromLibrary()
            
        case .file:
            getFile()
            
        default:
            guard let presenter = presentViewController else {
                fatalError("Need to set presentViewController for VGSButton")
            }
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] (action) in
                self?.getImageFromLibrary()
            }))
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (action) in
                self?.getImageFromCamera()
            }))
            actionSheet.addAction(UIAlertAction(title: "iCloud storage", style: .default, handler: { [weak self] (action) in
                self?.getFile()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
         
            presenter.present(actionSheet, animated: true, completion: nil)
        }
    }
}

extension VGSButton: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let originalImage = info[.originalImage] as? UIImage else {
            return
        }
        
        image = originalImage
        picker.dismiss(animated: true, completion: nil)
    }
}

extension VGSButton: UIDocumentPickerDelegate {
    internal func getFile() {
        guard let presenter = presentViewController else {
            fatalError("Need to set presentViewController for VGSButton")
        }
        
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
        picker.delegate = self
        presenter.present(picker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if controller.documentPickerMode == .import {
            // This is what it should be
//            let t = String(contentsOfFile: urls.first?.path)
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension VGSButton {
    internal func showAlert(message string: String) {
        guard let presenter = presentViewController else {
            fatalError("Need to set presentViewController for VGSButton")
        }
        
        let alert = UIAlertController(title: nil,
                                      message: string,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        presenter.present(alert, animated: true, completion: nil)
    }
}
