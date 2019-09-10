//
//  VGSTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import SnapKit

public class VGSTextField: UIView {
    var textField = MaskedTextField(frame: .zero)
    var focusStatus: Bool = false
    
    public var configuration: VGSTextFieldConfig? {
        didSet {
            guard let config = configuration else {
                return
            }
            
            textField.placeholder = config.placeholder
            textField.isSecureTextEntry = config.type.isSecureDate
            textField.keyboardType = config.type.keyboardType
            
            if config.formatPattern.count != 0 {
                textField.formatPattern = config.formatPattern
            } else {
                textField.formatPattern = config.type.formatPattern
            }
            
            if let vgs = config.vgsForm {
                vgs.registerTextFields(textField: [self])
            }
        }
    }
    
    var text: String? {
        get {
            return textField.text
        }
        set { }
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainInitialization()
    }
    
    deinit {
        configuration?.vgsForm?.unregisterTextFields(textField: [self])
    }
    
    // MARK: - private API
    private func mainInitialization() {
        // set main style for view
        mainStyle()
        // text view
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // tap gesture for update focus state
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(focusOn))
        textField.addGestureRecognizer(tapGesture)
    }
}

// MARK: - change focus here
extension VGSTextField {
    @objc
    private func focusOn() {
        // change status
        textField.becomeFirstResponder()
        configuration?.vgsForm?.updateStatus(for: self)
    }
}

// MARK: - Text Field security path
extension VGSTextField {
    private func checkObservation() {
        if textField.observationInfo != nil {
            // check observers here
        }
    }
}

// MARK: - Main style for text field
extension UIView {
    func mainStyle() {
        clipsToBounds = true
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
    }
}
