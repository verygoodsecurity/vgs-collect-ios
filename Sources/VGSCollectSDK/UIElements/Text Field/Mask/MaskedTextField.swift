//
//  MaskedTextField.swift
//  VGSCollectSDK
//
#if os(iOS)
import UIKit
#endif

/// Defines interface for masked text field delegate.
internal protocol MaskedTextFieldDelegate: AnyObject {
	func maskedTextField(_ maskedTextField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
}

/// :nodoc: Internal wrapper for `UITextField`.
internal class MaskedTextField: UITextField {
    enum MaskedTextReplacementChar: String, CaseIterable {
        case lettersAndDigit = "*"
        case anyLetter = "@"
        case lowerCaseLetter = "a"
        case upperCaseLetter = "A"
        case digits = "#"
    }

	  /// Internal delegate that acts as a proxy of `UITextFieldDelegate`.
		internal weak var customDelegate: MaskedTextFieldDelegate?

    /**
     Var that holds the format pattern that you wish to apply
     to some text
     
     If the pattern is set to "" no mask would be applied and
     the textfield would behave like a normal one
     */
    var formatPattern: String = ""
    
    /**
    Divider string used to replace symbols that not included in *MaskedTextReplacementChar* in masked textField text.
     
    If  divider is set to "" no divider would be applied and
    the textfield would behave like a normal one
    */
    var divider: String = ""

    /**
	  Defines custom output format pattern. User input data will be 	formatted with specified pattern for collect request.
    */
    var outputFormat: String?
    
    /**
     Var that holds the prefix to be added to the textfield
     
     If the prefix is set to "" no string will be added to the beginning
     of the text
     */
    var prefix: String = ""
    
    /**
     Var that have the maximum length, based on the mask set
     */
    var maxLength: Int {
        get {
            return formatPattern.count + prefix.count
        }
        set { }
    }
    
    /**
     Overriding the var text from UITextField so if any text
     is applied programmatically by calling formatText
     */
    @available(*, deprecated, message: "Don't use this method.")
    override var text: String? {
        get { return nil }
        set {
            secureText = newValue
        }
    }
        
    /// set/get text just for internal using
    internal var secureText: String? {
        get {
            return super.text
        }
        set {
            super.text = newValue
            self.updateTextFormat()
        }
    }
    
    /// returns textfield text without mask
    internal var getSecureRawText: String? {
        return getRawText()
    }
    
    /// Check *formatPattern* and replace  symbols that not included in *MaskedTextReplacementChar* with Divider string in a raw text.
    ///  Example:
    ///  formatPattern: "#### #### #### ####"
    ///  input: "4111 1111 1111 1111"
    ///  divider: "-"
    ///  output: "4111-1111-1111-1111"
    internal var getSecureTextWithDivider: String? {
        return getRawTextWithDivider()
    }
  
    /// The natural size for the Textfield, considering only properties of the view itself.
    override var intrinsicContentSize: CGSize {
      return getIntrinsicContentSize()
    }
  
    // MARK: - Text Padding
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    func updateTextFormat() {
        self.undoManager?.removeAllActions()
        self.formatText()
    }
    
    fileprivate func getOnlyDigitsString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.vgsAsciiDecimalDigits.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getOnlyLettersString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.letters.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getUppercaseLettersString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.uppercaseLetters.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getLowercaseLettersString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.lowercaseLetters.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getFilteredString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getRawText() -> String? {
        guard let text = secureText else {
            return nil
        }
        return formatPattern.isEmpty ? secureText : getFilteredString(text)
    }
    
    fileprivate func getRawTextWithDivider() -> String? {
        guard let text = secureText else {
            return nil
        }
        if formatPattern.isEmpty || divider.isEmpty {
            return getRawText()
        }
        
        let inputCharacters = Array(text).map { String($0) }
        let formatPatternCharacters = Array(formatPattern).map { String($0) }
        let availableFormatPatternChars = MaskedTextReplacementChar.allCases.map { $0.rawValue }
        var result = [String]()
        for index in 0..<inputCharacters.count {
            if index == formatPatternCharacters.count {
                return result.joined()
            }
            if !availableFormatPatternChars.contains(formatPatternCharacters[index]) {
                result.append(divider)
            } else {
                result.append(inputCharacters[index])
            }
        }
        return result.joined()
    }
    
    fileprivate func getStringWithoutPrefix(_ string: String) -> String {
        if string.range(of: self.prefix) != nil {
            if string.count > self.prefix.count {
                let prefixIndex = string.index(string.endIndex, offsetBy: (string.count - self.prefix.count) * -1)
                return String(string[prefixIndex...])
            } else if string.count == self.prefix.count {
                return ""
            }
        }
        return string
    }
    
    /**
     Func that formats the text based on formatPattern
     
     Override this function if you want to customize the behaviour of 
     the class
     */
    func formatText() {
        guard let text = super.text, !formatPattern.isEmpty else { return }
        let selection = selectedTextRange.map {
            (offset(from: beginningOfDocument, to: $0.start),
             offset(from: beginningOfDocument, to: $0.end))
        }
        let formatted = formattedText(text)
        guard formatted != text else { return }
        super.text = formatted

        if let selection = selection {
            let source = text as NSString
            let startOffset = formattedText(source.substring(to: min(selection.0, source.length))).utf16.count
            let endOffset = formattedText(source.substring(to: min(selection.1, source.length))).utf16.count
            if let start = position(from: beginningOfDocument, offset: min(startOffset, formatted.utf16.count)),
               let end = position(from: beginningOfDocument, offset: min(endOffset, formatted.utf16.count)) {
                selectedTextRange = textRange(from: start, to: end)
            }
        }
    }

    fileprivate func replaceFormattedText(in range: NSRange, with string: String) -> Bool {
        let currentText = (super.text ?? "") as NSString
        guard range.location >= 0, range.length >= 0,
              range.location <= currentText.length,
              range.length <= currentText.length - range.location else { return false }
        super.text = currentText.replacingCharacters(in: range, with: string)
        if let cursor = position(from: beginningOfDocument, offset: range.location + string.utf16.count) {
            selectedTextRange = textRange(from: cursor, to: cursor)
        }
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
        sendActions(for: .editingChanged)
        return true
    }

    private func formattedText(_ text: String) -> String {
        guard !formatPattern.isEmpty else { return text }
        var currentTextForFormatting = ""
        
        if !text.isEmpty {
            currentTextForFormatting = self.getStringWithoutPrefix(text)
        }
        
        if self.maxLength > 0 {
            var formatterIndex = self.formatPattern.startIndex, currentTextForFormattingIndex = currentTextForFormatting.startIndex
            var finalText = ""
            
            currentTextForFormatting = self.getFilteredString(currentTextForFormatting)
            
            if currentTextForFormatting.count > 0 {
                while true {
                    let formatPatternRange = formatterIndex ..< formatPattern.index(after: formatterIndex)
                    let currentFormatCharacter = String(self.formatPattern[formatPatternRange])
                    if let currentFormatCharacterType = MaskedTextReplacementChar(rawValue: currentFormatCharacter) {
                        
                        let currentTextForFormattingPatterRange = currentTextForFormattingIndex ..< currentTextForFormatting.index(after: currentTextForFormattingIndex)
                        let currentTextForFormattingCharacter = String(currentTextForFormatting[currentTextForFormattingPatterRange])

                        switch currentFormatCharacterType {
                        case .lettersAndDigit:
                            finalText += currentTextForFormattingCharacter
                            currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                            formatterIndex = formatPattern.index(after: formatterIndex)
                        case .anyLetter:
                            let filteredChar = self.getOnlyLettersString(currentTextForFormattingCharacter)
                            if !filteredChar.isEmpty {
                                finalText += filteredChar
                                formatterIndex = formatPattern.index(after: formatterIndex)
                            }
                            currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                        case .lowerCaseLetter:
                            let filteredChar = self.getLowercaseLettersString(currentTextForFormattingCharacter)
                            if !filteredChar.isEmpty {
                                finalText += filteredChar
                                formatterIndex = formatPattern.index(after: formatterIndex)
                            }
                            currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                        case .upperCaseLetter:
                            let filteredChar = self.getUppercaseLettersString(currentTextForFormattingCharacter)
                            if !filteredChar.isEmpty {
                                finalText += filteredChar
                                formatterIndex = formatPattern.index(after: formatterIndex)
                            }
                            currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                        case .digits:
                            let filteredChar = self.getOnlyDigitsString(currentTextForFormattingCharacter)
                            if !filteredChar.isEmpty {
                                finalText += filteredChar
                                formatterIndex = formatPattern.index(after: formatterIndex)
                            }
                            currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                        }
                    } else {
                        finalText += currentFormatCharacter
                        formatterIndex = formatPattern.index(after: formatterIndex)
                    }
                    
                    if formatterIndex >= self.formatPattern.endIndex ||
                        currentTextForFormattingIndex >= currentTextForFormatting.endIndex {
                        break
                    }
                }
            }
            
            return finalText.isEmpty ? finalText : "\(self.prefix)\(finalText)"
        }
        return text
    }

  // Calculate IntrinsicContentSize
  fileprivate func getIntrinsicContentSize() -> CGSize {
    if secureText.isNilOrEmpty && placeholder.isNilOrEmpty {
      return super.intrinsicContentSize
    }
    /// If there is placeholder in field, intrinsicContentSize  should return max width between placeholder and input text
    let placeholderSize = placeholder?.size() ?? .zero
    let secureTextSize = secureText?.size() ?? .zero
    return secureTextSize.width >= placeholderSize.width ? secureTextSize : placeholderSize
  }
}

// MARK: - UITextFieldDelegate

extension MaskedTextField: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let customTextFieldDelegate = customDelegate else {
			return true
		}

		return customTextFieldDelegate.maskedTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
	}
}

extension MaskedTextField: UITextPasteDelegate {
    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
                                          performPasteOf attributedString: NSAttributedString,
                                          to textRange: UITextRange) -> UITextRange {
        let location = offset(from: beginningOfDocument, to: textRange.start)
        let length = offset(from: textRange.start, to: textRange.end)
        let source = (secureText ?? "") as NSString
        guard location >= 0, length >= 0,
              location <= source.length, length <= source.length - location else { return textRange }
        let range = NSRange(location: location, length: length)
        guard self.textField(self, shouldChangeCharactersIn: range, replacementString: attributedString.string) else {
            return textRange
        }
        let startOffset = formattedText(source.substring(to: location)).utf16.count
        guard replaceFormattedText(in: range, with: attributedString.string) else { return textRange }
        guard let start = position(from: beginningOfDocument, offset: startOffset),
              let end = selectedTextRange?.end else { return textRange }
        return self.textRange(from: start, to: end) ?? textRange
    }
}

extension MaskedTextField {
    override var description: String {
        return NSStringFromClass(self.classForCoder)
    }
}
