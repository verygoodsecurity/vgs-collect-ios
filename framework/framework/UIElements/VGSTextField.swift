//
//  VGSTextField.swift
//  framework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import SnapKit

class VGSTextField: VGSView {
    private var _textField: UITextField!
    
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
        _textField = UITextField(frame: bounds)
        _textField.borderStyle = .roundedRect
        
        addSubview(_textField)
        _textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func checkObservation() {
        if _textField.observationInfo != nil {
            // check observers here
        }
    }
}
