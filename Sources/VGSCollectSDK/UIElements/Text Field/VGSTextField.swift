//
//  VGSTextField.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

/// An object that displays an editable text area in user interface.
public class VGSTextField: UIView {
    
    private(set) weak var vgsCollector: VGSCollect?
    internal var textField = MaskedTextField(frame: .zero)
    internal var focusStatus: Bool = false
    internal var isRequired: Bool = false
    internal var isRequiredValidOnly: Bool = false
    internal var isDirty: Bool = false
    internal var fieldType: FieldType = .none
    internal var fieldName: String!
    internal var token: String?
    internal var horizontalConstraints = [NSLayoutConstraint]()
    internal var verticalConstraint = [NSLayoutConstraint]()
    internal var validationRules = VGSValidationRuleSet()

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
        didSet { setMainPaddings() }
    }
    
    /// The technique to use for aligning the text.
    public var textAlignment: NSTextAlignment = .natural {
        didSet { textField.textAlignment = textAlignment }
    }
    
    /// Sets when the clear button shows up. Default is `UITextField.ViewMode.never`
    public var clearButtonMode: UITextField.ViewMode = .never {
      didSet { textField.clearButtonMode = clearButtonMode }
    }
  
    /// Identifies whether the text object should disable text copying and in some cases hide the text being entered. Default is false.
    public var isSecureTextEntry: Bool = false {
        didSet { textField.isSecureTextEntry = isSecureTextEntry }
    }
  
    /// Indicates whether `VGSTextField ` should automatically update its font when the device’s `UIContentSizeCategory` is changed.
    public var adjustsFontForContentSizeCategory: Bool = false {
      didSet { textField.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory }
    }
    
    /// Input Accessory View
    public var keyboardAccessoryView: UIView? {
      didSet { textField.inputAccessoryView = keyboardAccessoryView }
    }
  
    /// Determines whether autocorrection is enabled or disabled during typing.
    public var autocorrectionType: UITextAutocorrectionType = .default {
      didSet {
        textField.autocorrectionType = autocorrectionType
      }
    }
  
    // MARK: - Functional Attributes
    
    /// Specifies `VGSTextField` configuration parameters to work with `VGSCollect`.
    public var configuration: VGSConfiguration? {
        didSet {
            guard let configuration = configuration else {
              let message = "VGSTextField CONFIGURATION ERROR! VGSConfiguration is REQUIRED!!!"
              let event = VGSLogEvent(level: .warning, text: message, severityLevel: .error)
              VGSCollectLogger.shared.forwardLogEvent(event)
              return
            }
            
            // config text field
            fieldName = configuration.fieldName
            isRequired = configuration.isRequired
            isRequiredValidOnly = configuration.isRequiredValidOnly
            fieldType = configuration.type
            textField.keyboardType = configuration.keyboardType ?? configuration.type.keyboardType
            textField.returnKeyType = configuration.returnKeyType ?? .default
            textField.keyboardAppearance = configuration.keyboardAppearance ?? .default
            
            if let pattern = configuration.formatPattern {
                textField.formatPattern = pattern
            } else {
                textField.formatPattern = configuration.type.defaultFormatPattern
            }
            
            if let divider = configuration.divider {
                textField.divider = divider
            } else {
                textField.divider = configuration.type.defaultDivider
            }
          
            /// Validation
            if let rules = configuration.validationRules {
              validationRules = rules
            } else {
              validationRules = fieldType.defaultValidation
            }

            if let collector = configuration.vgsCollector {
              vgsCollector = collector
              collector.registerTextFields(textField: [self])
              VGSAnalyticsClient.shared.trackFormEvent(collector.formAnalyticsDetails, type: .fieldInit, extraData: ["field": fieldType.stringIdentifier])
            }
        }
    }
    
    /// Delegates `VGSTextField` editing events. Default is `nil`.
    public weak var delegate: VGSTextFieldDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainInitialization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    // MARK: - Manage input
    /// Set textfield default text.
    /// - Note: This will not change `State.isDirty` attribute.
    /// - Discussion: probably you should want to set field configuration before setting default value, so the input format will be update as required.
    public func setDefaultText(_ text: String?) {
      updateTextFieldInput(text)
    }
  
    /// :nodoc: Set textfield text.
    public func setText(_ text: String?) {
      isDirty = true
      updateTextFieldInput(text)
    }

      /// Removes input from field.
    public func cleanText() {
      updateTextFieldInput("")
    }
  
  internal func getOutputText() -> String? {
    if let config = configuration as? FormatConvertable, let input = textField.getSecureTextWithDivider, let outputFormat = config.outputFormat, let inputFormat = config.inputFormat {
      return config.convertor.convert(input, inputFormat: inputFormat, outputFormat: outputFormat)
    }
    return textField.getSecureTextWithDivider
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

	 /// :nodoc: Wrap native `UITextField` delegate method for `textFieldDidBeginEditing`.
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldValueChanged()
        delegate?.vgsTextFieldDidBeginEditing?(self)
    }
  
    @objc func textFieldDidChange(_ textField: UITextField) {
        isDirty = true
        textFieldValueChanged()
        delegate?.vgsTextFieldDidChange?(self)
    }

	  /// :nodoc: Wrap native `UITextField` delegate method for `didEndEditing`.
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldValueChanged()
        delegate?.vgsTextFieldDidEndEditing?(self)
    }
    
    @objc func textFieldDidEndEditingOnExit(_ textField: UITextField) {
        textFieldValueChanged()
        delegate?.vgsTextFieldDidEndEditingOnReturn?(self)
    }
}

// MARK: - private API
internal extension VGSTextField {
    
    @objc
    func mainInitialization() {
        // set main style for view
        mainStyle()
        // add UI elements
        buildTextFieldUI()
        // add otextfield observers and delegates
        addTextFieldObservers()
    }
  
    @objc
    func buildTextFieldUI() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        setMainPaddings()
    }
  
    @objc
    func addTextFieldObservers() {
      //delegates
      textField.addSomeTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
      //Note: .allEditingEvents doesn't work proparly when set text programatically. Use setText instead!
      textField.addSomeTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
      textField.addSomeTarget(self, action: #selector(textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
      NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: UITextField.textDidChangeNotification, object: textField)
      // tap gesture for update focus state
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusOn))
      textField.addGestureRecognizer(tapGesture)
    }
  
    @objc
    func setMainPaddings() {
      NSLayoutConstraint.deactivate(verticalConstraint)
      NSLayoutConstraint.deactivate(horizontalConstraints)
      
      let views = ["view": self, "textField": textField]
        
      horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(padding.left)-[textField]-\(padding.right)-|",
                                                                   options: .alignAllCenterY,
                                                                   metrics: nil,
                                                                   views: views)
      NSLayoutConstraint.activate(horizontalConstraints)
        
      verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(padding.top)-[textField]-\(padding.bottom)-|",
                                                                options: .alignAllCenterX,
                                                                metrics: nil,
                                                                views: views)
      NSLayoutConstraint.activate(verticalConstraint)
      self.layoutIfNeeded()
    }

    @objc
    func textFieldValueChanged() {
        // update format pattern after field input changed
        updateFormatPattern()
        // update status
        vgsCollector?.updateStatus(for: self)
    }
  
  func updateFormatPattern() {
    // update card number and cvc format dynamically based on card brand
    if self.fieldType == .cardNumber, let cardState = self.state as? CardState {
        
      if let cardModel = VGSPaymentCards.getCardModelFromAvailableModels(brand: cardState.cardBrand) {
        self.textField.formatPattern = cardModel.formatPattern
      } else {
        self.textField.formatPattern = VGSPaymentCards.unknown.formatPattern
      }
      // change cvc format pattern and validation rules based on card brand
      if let cvcField = self.vgsCollector?.storage.textFields.filter({ $0.fieldType == .cvc }).first {
        cvcField.textField.formatPattern = cardState.cardBrand.cvcFormatPattern
        cvcField.validationRules = self.getCVCValidationRules(cardBrand: cardState.cardBrand)
        if let field = cvcField as? VGSCVCTextField {
          field.updateCVCImage(for: cardState.cardBrand)
        }
      }
    }
    textField.updateTextFormat()
  }
    
    // change focus here
    @objc
    func focusOn() {
        // change status
        textField.becomeFirstResponder()
        textFieldValueChanged()
    }
  
  /// This will update format pattern and notify about the change
  func updateTextFieldInput(_ text: String?) {
    /// clean previous format pattern and add new  based on content after text is set
    if self.fieldType == .cardNumber {
      textField.formatPattern = ""
    }
    textField.secureText = text

    // this will update card textfield icons and dynamic format pattern
    textFieldValueChanged()
    delegate?.vgsTextFieldDidChange?(self)
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
