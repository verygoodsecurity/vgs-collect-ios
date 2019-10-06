//
//  VGSButton.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 10/6/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

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
    
//    deinit {
//        
//    }
    
    // MARK: - private API
    private func mainInitialization() {
        
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
        
        button.addTarget(self, action: #selector(buttonFunction(_:)), for: .touchUpInside)
    }
    
    @objc
    private func buttonFunction(_ sender: UIButton) {
        switch type {
        case .camera:
            getImageFromCamera()
        case .library:
            getImageFromLibrary()
        case .file:
            #warning("Need to investigate work with icloud file")
            break
        default:
            showAlert(message: "Need to set correct type for VGSButton")
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
            picker.sourceType = .camera
            presenter.present(picker, animated: true, completion: nil)
        }
    }

    // MARK: - UIImage picker delegate
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let originalImage = info[.originalImage] as! UIImage
        image = originalImage
        
        picker.dismiss(animated: true, completion: nil)
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
