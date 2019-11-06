//
//  VGSTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

/// VGSTextFiled - secure text field for getting user data and safety sending to VGS server
public class VGSTextField: UIView {
    private(set) weak var vgsCollector: VGSCollect?
    internal var textField = MaskedTextField(frame: .zero)
    internal var focusStatus: Bool = false
    internal var isRequired: Bool = false
    internal var fieldType: FieldType = .none
    internal var validationModel = VGSValidation()
    internal var fieldName: String!
    internal var token: String?
    
    /// You can set padding for text and placeholder
    public var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            textField.padding = padding
        }
    }
    
    public var configuration: VGSConfiguration? {
        didSet {
            
            guard let configuration = configuration else {
                return
            }
            
            // config text field
            fieldName = configuration.fieldName
            isRequired = configuration.isRequired
            fieldType = configuration.type
            textField.placeholder = configuration.placeholder
            textField.isSecureTextEntry = configuration.type.isSecureDate
            textField.keyboardType = configuration.type.keyboardType
            
            if configuration.formatPattern.count != 0 {
                textField.formatPattern = configuration.formatPattern
            } else {
                textField.formatPattern = configuration.type.formatPattern
            }
            
            // regex
            validationModel.pattern = configuration.type.regex
            
            if let vgs = configuration.vgsCollector {
                vgsCollector = vgs
                vgs.registerTextFields(textField: [self])
            }
        }
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
        vgsCollector?.unregisterTextFields(textField: [self])
    }
    
    // MARK: - private API
    private func mainInitialization() {
        // set main style for view
        mainStyle()
        // text view
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        let views = ["view": self, "textField": textField]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[textField]-0-|",
                                                                  options: .alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: views)
        NSLayoutConstraint.activate(horizontalConstraints)
        
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[textField]-0-|",
                                                                options: .alignAllCenterX,
                                                                metrics: nil,
                                                                views: views)
        NSLayoutConstraint.activate(verticalConstraint)
        
        
        //delegate
        textField.addSomeTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.addSomeTarget(self, action: #selector(textField(_:shouldChangeCharactersIn:replacementString:)), for: .editingChanged)
        
        // tap gesture for update focus state
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusOn))
        textField.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func textFieldDidChange(_ sender: UITextField) {
        // change status
        vgsCollector?.updateStatus(for: self)
    }
}

// MARL: - Text filed delegate
extension VGSTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let tfText = textField.text else {
            return true
        }
        
        let mask = self.textField.formatPattern
        if mask.count < tfText.count + string.count {
            return false
        }
        
        return true
    }
}

// MARK: - change focus here
extension VGSTextField {
    @objc
    private func focusOn() {
        // change status
        textField.becomeFirstResponder()
        vgsCollector?.updateStatus(for: self)
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
