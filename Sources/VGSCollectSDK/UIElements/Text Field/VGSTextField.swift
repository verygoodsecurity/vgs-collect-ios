//
//  VGSTextField.swift
//  VGSCollectSDK
//


#if os(iOS)
import UIKit
#endif

// swiftlint:disable file_length
/// A secure input view that masks, formats, and validates sensitive user data before submission via `VGSCollect`.
///
/// Summary:
/// Acts as the primary UI component for secure data entry (card number, CVC, expiration date, SSN, generic text, etc.).
/// Provides formatting masks, validation rule application, secure raw storage abstraction, and integration hooks for tokenization.
///
/// Responsibilities:
/// - Applies format pattern & divider to user keystrokes (dynamic for certain types like card number).
/// - Exposes state snapshots (`state`) through `VGSCollect` observation closures for validation & UI feedback.
/// - Holds reference to `VGSConfiguration` that defines semantic role, validation rules, input formatting and tokenization parameters.
///
/// Formatting & Masking:
/// - `formatPattern` (from configuration or dynamic adjustment) determines visible grouping (# placeholders).
/// - `divider` inserted between pattern groups (e.g. `/` for dates, `-` for SSN).
/// - Card number and CVC patterns update automatically based on detected brand when using associated field types.
///
/// Validation:
/// - Default validation rules determined by `FieldType`; can be overridden via `configuration.validationRules`.
/// - Validation runs on each editing change and contributes to field & form state.
///
/// Tokenization:
/// - If a tokenization configuration subclass is assigned, internal `tokenizationParameters` are captured for Vault alias creation.
/// - Tokenization does not modify validation or formatting; it only affects how collected data is transformed server-side.
///
/// Usage:
/// ```swift
/// let cardField = VGSCardTextField() // or VGSTextField()
/// let cfg = VGSCardNumberTokenizationConfiguration(collector: collector, fieldName: "card_number")
/// cfg.isRequiredValidOnly = true
/// cardField.configuration = cfg // registers with collector
/// // Observe validity via collector.observeFieldState or cardField.state (if public)
/// ```
///
/// Security:
/// - Never read or log internal `textField` contents directly; rely on state metadata (`last4`, `isValid`).
/// - Do not persist raw user-entered values (store only aliases returned from backend responses).
/// - Avoid copying sensitive field values into analytics, crash logs, or third-party SDKs.
///
/// Performance:
/// - Avoid repeatedly reassigning configuration after user input begins.
///
/// Accessibility:
/// - Customize accessibility label/hint via provided properties; keep hints free of sensitive content.
/// - Ensure sufficient contrast and dynamic type scaling if `adjustsFontForContentSizeCategory` is enabled.
///
/// Invariants / Preconditions:
/// - A non-nil `configuration` is required before using the field for secure submission.
/// - Do not mutate `configuration` while field is first responder to avoid inconsistent formatting.
///
/// See also:
/// - `VGSConfiguration` for defining semantic meaning & validation.
/// - `VGSCollect` for submission & state observation.
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
    internal var tokenizationParameters: VGSTokenizationParametersProtocol?

    // MARK: - UI Attributes
    
    /// Placeholder text displayed when there is no user input.
    /// - Update before field becomes first responder to avoid layout flicker.
    public var placeholder: String? {
        didSet { textField.placeholder = placeholder }
    }

    /// Autocapitalization behavior for textual input.
    /// - Default: `.sentences`.
    /// - Usually left as default for names; set `.none` for numeric / code inputs.
    public var autocapitalizationType: UITextAutocapitalizationType = .sentences {
        didSet { textField.autocapitalizationType = autocapitalizationType }
    }

    /// Spell checking behavior.
    /// - Default: `.default`.
    /// - Set `.no` for numeric or strictly formatted fields (card, CVC, SSN).
    public var spellCheckingType: UITextSpellCheckingType  = .default {
        didSet { textField.spellCheckingType = spellCheckingType }
    }
    
    /// Attributed placeholder allowing styled placeholder text.
    /// - Loses effect if `placeholder` later reassigned; prefer one approach.
    public var attributedPlaceholder: NSAttributedString? {
        didSet { textField.attributedPlaceholder = attributedPlaceholder }
    }
  
    /// Natural intrinsic size including content insets (padding).
    public override var intrinsicContentSize: CGSize { getIntrinsicContentSize() }
    
    /// Content inset for text & placeholder inside the field.
    /// - Adjust to increase touch target or visual spacing.
    public var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { setMainPaddings() }
    }
    
    /// Horizontal text alignment.
    /// - Defaults to `.natural`; adjust for RTL/LTR explicit layout needs.
    public var textAlignment: NSTextAlignment = .natural {
        didSet { textField.textAlignment = textAlignment }
    }
    
    /// Clear button display mode.
    /// - Default: `.never`.
    /// - Avoid enabling for sensitive fields unless UX mandates quick clearing.
    public var clearButtonMode: UITextField.ViewMode = .never {
      didSet { textField.clearButtonMode = clearButtonMode }
    }
  
    /// Secure text entry toggle.
    /// - Masks visible characters when true; use for CVC or other sensitive short values.
    /// - Avoid enabling for card number masking (handled by format pattern & state exposure of last4 instead).
    public var isSecureTextEntry: Bool = false {
        didSet { textField.isSecureTextEntry = isSecureTextEntry }
    }
  
    /// Dynamic Type scaling flag.
    /// - Enable if adopting system-wide accessibility text size adjustments.
    public var adjustsFontForContentSizeCategory: Bool = false {
      didSet { textField.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory }
    }
    
    /// Custom accessory view displayed above the keyboard (e.g. toolbar with Done button).
    public var keyboardAccessoryView: UIView? {
      didSet { textField.inputAccessoryView = keyboardAccessoryView }
    }
  
    /// Autocorrection behavior.
    /// - Default `.default`; disable (`.no`) for formats like card number, CVC, SSN, dates.
    public var autocorrectionType: UITextAutocorrectionType = .default {
      didSet { textField.autocorrectionType = autocorrectionType }
    }

    // MARK: - Accessibility Attributes
    
    /// Accessibility label describing the field's purpose (without sensitive content).
    public var textFieldAccessibilityLabel: String? {
        get { textField.accessibilityLabel }
        set { textField.accessibilityLabel = newValue }
    }
    
    /// Accessibility hint describing the result of interaction (avoid exposing actual values).
    public var textFieldAccessibilityHint: String? {
        get { textField.accessibilityHint }
        set { textField.accessibilityHint = newValue }
    }
    
    /// Determines if the underlying text control is an accessibility element.
    /// - Set false only when grouping with a custom container element.
    public var textFieldIsAccessibilityElement: Bool {
        get { textField.isAccessibilityElement }
        set { textField.isAccessibilityElement = newValue }
    }

    // MARK: - Functional Attributes
    
    /// Configuration establishing semantic type, formatting, validation rules, and collector registration.
    ///
    /// Behavior:
    /// - On assignment: registers with the provided `VGSCollect` instance; applies format & validation defaults.
    /// - Re-assignment replaces previous configuration (not recommended mid-edit).
    /// - Nil assignment logs a warning and leaves field unregistered.
    ///
    /// Usage:
    /// ```swift
    /// let cfg = VGSConfiguration(collector: collector, fieldName: "card_cvc")
    /// cfg.type = .cvc
    /// cvcField.configuration = cfg
    /// ```
    ///
    /// Notes:
    /// - Set before user interaction; avoid mutation while first responder.
    public var configuration: VGSConfiguration? {
        didSet {
            guard let configuration = configuration else {
              let message = "VGSTextField CONFIGURATION ERROR! VGSConfiguration is REQUIRED!!!"
              let event = VGSLogEvent(level: .warning, text: message, severityLevel: .error)
              VGSCollectLogger.shared.forwardLogEvent(event)
              return
            }
          setupField(with: configuration)
        }
    }
    
    /// Delegate receiving editing lifecycle callbacks (`begin`, `change`, `end`, `return`).
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
    
    /// Sets a default (prefilled) value WITHOUT marking field as dirty.
    /// - Use for restoring a non-sensitive placeholder-like value or formatting demonstration.
    /// - Does not trigger `isDirty` so initial unchanged state logic remains intact.
    /// - If `maxInputLength` is specified, value is trimmed accordingly.
    public func setDefaultText(_ text: String?) {
            let trimmedText = trimTextIfNeeded(text)
            updateTextFieldInput(trimmedText)
    }
    /// :nodoc: 
    public func setText(_ text: String?) {
            isDirty = true
            let trimmedText = trimTextIfNeeded(text)
            updateTextFieldInput(trimmedText)
    }

    /// Removes all input content.
    /// - Resets formatting state while retaining configuration.
    public func cleanText() {
      updateTextFieldInput("")
    }
  
    // MARK: - Compare Input

    /// Compares raw (unformatted) content equality with another `VGSTextField`.
    /// - Ignores masking characters and dividers.
    /// - Returns true only if secure raw strings match exactly.
    /// - Useful for confirm-input patterns (e.g. email repeat) when using masking.
    public func isContentEqual(_ textField: VGSTextField) -> Bool {
      return self.textField.getSecureRawText == textField.textField.getSecureRawText
    }
    
    internal func getOutputText() -> String? {
        if let config = configuration as? VGSTextFormatConvertable,
           let input = textField.getSecureTextWithDivider,
           let inputFormat = config.inputFormat,
           let outputFormat = config.outputFormat {
            return config.convertor.convert(input, inputFormat: inputFormat, outputFormat: outputFormat)
        }
        return textField.getSecureTextWithDivider
    }
  
  /// Field Configuration
  internal func setupField(with configuration: VGSConfiguration) {
    // config text field
    fieldName = configuration.fieldName
    isRequired = configuration.isRequired
    isRequiredValidOnly = configuration.isRequiredValidOnly
    fieldType = configuration.type
    textField.textContentType = configuration.isTextContentTypeSet ? configuration.textContentType : configuration.type.textContentType
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
    if  let config = configuration as? VGSTextFieldTokenizationConfigurationProtocol {
      tokenizationParameters = config.tokenizationConfiguration
    }
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
      // delegates
			textField.delegate = textField
			textField.customDelegate = self
			textField.addSomeTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
      // Note: .allEditingEvents doesn't work proparly when set text programatically. Use setText instead!
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
  
    /// Calculate IntrinsicContentSize
    private func getIntrinsicContentSize() -> CGSize {
      /// Add paddings
      let width = textField.intrinsicContentSize.width + padding.left + padding.right
      let height = textField.intrinsicContentSize.height + padding.bottom + padding.top
      return CGSize(width: width, height: height)
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
    if self.fieldType == .cardNumber, let cardState = self.state as? VGSCardState {
        
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

    /// Returns trimmed text if `.maxInputLength` is set.
    /// - Parameter text: `String?` object, new text to set.
    /// - Returns: `String?` object, trimmed text or initial text if `.maxInputLength` not set.
    func trimTextIfNeeded(_ text: String?) -> String? {
        guard let maxInputLength = configuration?.maxInputLength, let newText = text else {
            return text
        }

        let trimmedText = String(newText.prefix(maxInputLength))
        return trimmedText
    }

    /// `true` if has format pattern.
    fileprivate var hasFormatPattern: Bool {
        return !textField.formatPattern.isEmpty
    }
}

// MARK: - MaskedTextFieldDelegate

extension VGSTextField: @preconcurrency MaskedTextFieldDelegate {
	func maskedTextField(_ maskedTextField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard let maxInputLength = configuration?.maxInputLength, let currentString: NSString = textField.secureText as? NSString else {return true}

		let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString

		// Do not filter text when format pattern is not set (empty). Spaces and non alpha-numeric chards will be treated as valid characters and will be used in maxInputLength check.
		// Otherwise when formatPattern is set filter text only for alphanumeric characters.
		let rawText: NSString
		if hasFormatPattern {
			rawText = getFilteredString(newString as String) as NSString
		} else {
			rawText = newString
		}

		return rawText.length <= maxInputLength
	}

	fileprivate func getFilteredString(_ string: String) -> String {
			let charactersArray = string.components(separatedBy: CharacterSet.alphanumerics.inverted)
			return charactersArray.joined(separator: "")
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
// swiftlint:enable file_length
