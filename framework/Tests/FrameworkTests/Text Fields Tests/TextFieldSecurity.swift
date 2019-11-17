//
//  TextFieldSecurity.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 06.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class TextFieldSecurity: XCTestCase {
    var collector: VGSCollect!
    var textField: VGSTextField!
    var cardNum = "4111 1111 1111 1111"
    
    override func setUp() {
        collector = VGSCollect(id: "id")
        textField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        config.type = .cardNumber
        config.isRequired = true
        textField.configuration = config
        
        textField.textField.text = cardNum
    }

    override func tearDown() {
        collector  = nil
        textField = nil
    }

    func testSetDelegate() {
        textField.subviews.forEach { (view) in
            if let tf = view as? UITextField {
                tf.delegate = self
            }
        }

        XCTAssertNil(textField.textField.delegate)
    }
    
    func testAddTarget() {
        textField.subviews.forEach { (view) in
            if let tf = view as? UITextField {
                tf.delegate = self
                tf.addTarget(self, action: #selector(textField(_:shouldChangeCharactersIn:replacementString:)), for: .allEvents)
            }
        }
        
        textField.textField.text = cardNum
        
        textField.subviews.forEach { (view) in
            if let tf = view as? UITextField {
                tf.allTargets.forEach { (target) in
                    if let _ = target as? TextFieldSecurity {
                        XCTFail()
                    }
                    
                    if let txt = tf.text as? String, txt.count > 0 {
                        XCTFail()
                    }
                }
            }
        }
    }
}

extension TextFieldSecurity: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
