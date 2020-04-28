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

/// An object that displays an editable text area in user interface.
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
    
    // MARK: - UI Attributes
    
    /// Textfield placeholder string.
    public var placeholder: String? {
        didSet { textField.placeholder = placeholder }
    }
    
    /// Textfield attributedPlaceholder string.
    public var attributedPlaceholder: NSAttributedString? {
        didSet {
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }
    
    /// `UIEdgeInsets` for text and placeholder inside `VGSTextField`.
    public var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { textField.padding = padding }
    }
    
    /// The technique to use for aligning the text.
    public var textAlignment: NSTextAlignment = .natural {
        didSet { textField.textAlignment = textAlignment }
    }
    
    // MARK: - Functional Attributes
    
    /// Specifies `VGSTextField` configuration parameters to work with `VGSCollect`.
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
            
            if let pattern = configuration.formatPattern {
                textField.formatPattern = pattern
            } else {
                textField.formatPattern = configuration.type.defaultFormatPattern
            }
            
            if let devider = configuration.devider {
                textField.devider = devider
            } else {
                textField.devider = configuration.type.defaultDevider
            }
            
            // regex
            validationModel.regex = configuration.type.regex
            if fieldType == .expDate {
                validationModel.isLongDateFormat = textField.formatPattern == DateFormatPattern.longYear.rawValue
            }

            if let vgs = configuration.vgsCollector {
                vgsCollector = vgs
                vgs.registerTextFields(textField: [self])
            }
        }
    }
    
    /// Delegates `VGSTextField` editing events. Default is `nil`.
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
}

// MARK: - UIResponder methods
extension VGSTextField {
    
    /// Make `VGSTextField` focused.
    @discardableResult override public func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    /// Remove  focus from `VGSTextField`.
    @discardableResult override public func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    /// Check if `VGSTextField` is focused.
    override public var isFirstResponder: Bool {
        return textField.isFirstResponder
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

// MARK: - private API
internal extension VGSTextField {
    
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
    
    /// :nodoc: Set textfield text. For internal use only! Not allowed to be public for PCI scope!
    func setText(_ text: String?) {
        textField.secureText = text
        // this will update card textfield icons
        textFieldValueChanged()
    }
    
    // change focus here
    @objc
    func focusOn() {
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
