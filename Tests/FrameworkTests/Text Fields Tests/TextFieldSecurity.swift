//
//  TextFieldSecurity.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 06.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class TextFieldSecurity: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var textField: VGSTextField!
    var cardNum = "4111 1111 1111 1111"
    
    override func setUp() {
				super.setUp()
        collector = VGSCollect(id: "id")
        textField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "testField")
        config.type = .cardNumber
        config.isRequired = true
        textField.configuration = config
        
        textField.textField.secureText = cardNum
    }

    override func tearDown() {
        collector  = nil
        textField = nil
    }

    // MARK: - Tests
    func testDescription() {
        let cleanCardNum = cardNum.replacingOccurrences(of: " ", with: "")
        
        textField.frame = CGRect(x: 0, y: 0, width: 300, height: 45)
        textField.textField.secureText = cardNum
        
        let txt1 = textField.description
        let txt2 = textField.debugDescription
        let txt3 = textField.textField.description
        let txt4 = textField.textField.debugDescription
        
        XCTAssertFalse(txt1.contains(cardNum))
        XCTAssertFalse(txt2.contains(cardNum))
        XCTAssertFalse(txt3.contains(cardNum))
        XCTAssertFalse(txt4.contains(cardNum))
        
        XCTAssertFalse(txt1.contains(cleanCardNum))
        XCTAssertFalse(txt2.contains(cleanCardNum))
        XCTAssertFalse(txt3.contains(cleanCardNum))
        XCTAssertFalse(txt4.contains(cleanCardNum))
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
        
        textField.textField.secureText = cardNum
        
        textField.subviews.forEach { (view) in
            if let tf = view as? UITextField {
                tf.allTargets.forEach { (target) in
                    if target is TextFieldSecurity {
                        XCTFail("Text Field has target")
                    }
                    
                    if let txt = tf.text, txt.count > 0 {
                        XCTFail("Not secure. Text was gotted")
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
