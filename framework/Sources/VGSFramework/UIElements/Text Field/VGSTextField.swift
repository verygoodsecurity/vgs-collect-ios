//
//  VGSTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

/// VGSTextFiled - secure text field for getting user data and safety sending to VGS server
public class VGSTextField: UIView {
    
    private(set) weak var vgsCollector: VGSCollect?
    internal var textField = MaskedTextField(frame: .zero)
    internal var focusStatus: Bool = false
    internal var isRequired: Bool = false
    internal var isRequiredValidOnly: Bool = false
    internal var fieldType: FieldType = .none
    internal var validationModel = VGSValidation()
    internal var fieldName: String!
    internal var token: String?
    
    /// Textfield placeholder string
    public var placeholder: String? {
        didSet { textField.placeholder = placeholder }
    }
    
    /// Textfield attributedPlaceholder string
    public var attributedPlaceholder: NSAttributedString? {
        didSet {
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }
    
    /// You can set padding for text and placeholder
    public var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { textField.padding = padding }
    }
    
    /// The technique to use for aligning the text
    public var textAlignment: NSTextAlignment = .natural {
        didSet { textField.textAlignment = textAlignment }
    }
    
    /// Setup VGSTextField additional params. Default is nil
    public var configuration: VGSConfiguration? {
        didSet {
            guard let configuration = configuration else { return }
            
            // config text field
            fieldName = configuration.fieldName
            isRequired = configuration.isRequired
            isRequiredValidOnly = configuration.isRequiredValidOnly
            fieldType = configuration.type
            textField.isSecureTextEntry = configuration.type.isSecureDate
            textField.keyboardType = configuration.keyboardType ?? configuration.type.keyboardType
            textField.returnKeyType = configuration.returnKeyType ?? .default
            textField.keyboardAppearance = configuration.keyboardAppearance ?? .default
            
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
    
    /// Delegates VGSTextField update events. Default is nil
    public weak var delegate: VGSTextFieldDelegate?
    
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
    func mainInitialization() {
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
        
        //delegates
        //Note: .allEditingEvents doesn't work proparly when set text programatically. Use setText instead!
        textField.addSomeTarget(self, action: #selector(textFieldValueChanged), for: .allEditingEvents)        
        textField.addSomeTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addSomeTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        textField.addSomeTarget(self, action: #selector(textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
        // tap gesture for update focus state
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusOn))
        textField.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func textFieldValueChanged() {
        // update status
        textField.updateTextFormat()
        vgsCollector?.updateStatus(for: self)
    }
    
    /// Set textfield text. For internal use only! Not allowed to be public for PCI scope!
    internal func setText(_ text: String?) {
        textField.secureText = text
        // this will update card textfield icons
        textFieldValueChanged()
    }
}

// MARK: - Textfiled delegate
extension VGSTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.vgsTextFieldDidBeginEditing?(self)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.vgsTextFieldDidEndEditing?(self)
    }
    
    @objc public func textFieldDidEndEditingOnExit(_ textField: UITextField) {
        delegate?.vgsTextFieldDidEndEditingOnReturn?(self)
    }
}

// MARK: - UIResponder methods
extension VGSTextField {
    @discardableResult override public func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult override public func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    override public var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
}

// MARK: - change focus here
extension VGSTextField {
    @objc
    internal func focusOn() {
        // change status
        textField.becomeFirstResponder()
        textFieldValueChanged()
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
