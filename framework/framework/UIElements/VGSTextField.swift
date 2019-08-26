//
//  VGSTextField.swift
//  framework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import SnapKit

public class VGSTextField: VGSView {
    private var textView = UITextView(frame: .zero)
    private var placeholderLabel = UILabel(frame: .zero)
    
    var type: FieldType = .none {
        didSet {
            if type != oldValue {
                textView.isSecureTextEntry = type.isSecureDate
                textView.keyboardType = type.keyboardType
            }
        }
    }
    
    public var model: VGSTextFieldModel? {
        didSet {
            guard let model = model else {
                return
            }
            placeholderLabel.text = model.placeholder
            type = model.type
        }
    }
    
    var text: String? {
        get {
            return textView.text
        }
        set {
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
    
    // MARK: - private API
    private func mainInitialization() {
        // text view
        textView.delegate = self
        textView.keyboardDismissMode = .onDrag
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // placeholder
        addSubview(placeholderLabel)
        placeholderLabel.font = textView.font
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.textColor = .lightGray
        placeholderLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        }
    }
}

// MARK: - Statuses
extension VGSTextField {
    var isEmpty: Bool {
        return (text?.count == 0)
    }
}

// Text field delegate
extension VGSTextField: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) { }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if let text = textView.text, text.count == 0 {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // for paste string
        // need to check have digits or characters
        
        // format input
//        if let textPattern = formatter?.textPattern, let currentText = textView.text {
//            
//            let formatter0 = TextInputFormatter(textPattern: textPattern)
//            let result = formatter0.formatInput(currentText: currentText,
//                                                range: range,
//                                                replacementString: text)
//            
//            textView.text = result.formattedText
//            textView.setCursorLocation(result.caretBeginOffset)
//            
////            let startPosition: UITextPosition = textView.beginningOfDocument
////            let endPosition: UITextPosition = textView.endOfDocument
////            let selectedRange: UITextRange? = textView.selectedTextRange
////
////            let newPosition = startPosition
////            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//        }
        
        return true
    }
}

// Text Field security path
extension VGSTextField {
    private func checkObservation() {
        if textView.observationInfo != nil {
            // check observers here
        }
    }
}
