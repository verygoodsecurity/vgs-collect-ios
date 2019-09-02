//
//  VGSTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import SnapKit

public class VGSTextField: VGSView {
    private var textView = UITextView(frame: .zero)
    private var placeholderLabel = UILabel(frame: .zero)
    
    public var configuration: VGSTextFieldConfig? {
        didSet {
            guard let config = configuration else {
                return
            }
            
            placeholderLabel.text = config.placeholder
            textView.isSecureTextEntry = config.type.isSecureDate
            textView.keyboardType = config.type.keyboardType
            
            if let vgs = config.vgs {
                vgs.registerTextFields(textField: [self])
            }
        }
    }
    
    var text: String? {
        get {
            return textView.text
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
        configuration?.vgs?.unregisterTextFields(textField: [self])
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

// MARK: - Text field delegate
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
        
        return true
    }
}

// MARK: - Text Field security path
extension VGSTextField {
    private func checkObservation() {
        if textView.observationInfo != nil {
            // check observers here
        }
    }
}
