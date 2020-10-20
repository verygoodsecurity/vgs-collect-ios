//
//  MaskedTextField.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 9/28/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

internal class MaskedTextField: UITextField {
    enum MaskedTextReplacementChar: String, CaseIterable {
        case lettersAndDigit = "*"
        case anyLetter = "@"
        case lowerCaseLetter = "a"
        case upperCaseLetter = "A"
        case digits = "#"
    }

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
     Var that holds the prefix to be added to the textfield
     
     If the prefix is set to "" no string will be added to the beggining
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
        set {
            secureText = newValue
        }
        get { return nil }
    }
        
    /// set/get text just for internal using
    internal var secureText: String? {
        set {
            super.text = newValue
            self.updateTextFormat()
        }
        get {
            return super.text
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
        var currentTextForFormatting = ""
        
        if let text = super.text {
            if text.count > 0 {
                currentTextForFormatting = self.getStringWithoutPrefix(text)
            }
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
            
            if finalText.count > 0 {
                super.text = "\(self.prefix)\(finalText)"
            } else {
                super.text = finalText
            }
            
            if let text = self.secureText {
                if text.count > self.maxLength {
                    super.text = String(text[text.index(text.startIndex, offsetBy: self.maxLength)])
                }
            }
        }
    }
}

extension MaskedTextField {
    override var description: String {
        return NSStringFromClass(self.classForCoder)
    }
}
