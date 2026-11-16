//
//  VGSTextFieldTests.swift
//  FrameworkTests
//
//  Created by Dima on 02.09.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK
@MainActor
class VGSTextFieldTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var configuration: VGSConfiguration!
    var textfield: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "vaultid")
        configuration = VGSConfiguration.init(collector: collector, fieldName: "test1")
        textfield = VGSTextField()
        textfield.configuration = configuration
    }
    
    override func tearDown() {
        collector  = nil
        configuration = nil
        textfield = nil
    }
  
    func testAutoFillContentTypes() {
        let types: [FieldType] = [.cardNumber, .cardHolderName, .expDate, .cvc, .ssn, .date, .none]
        for type in types {
            configuration.type = type
            textfield.configuration = configuration
            let expected: UITextContentType?
            switch type {
            case .cardNumber: expected = .creditCardNumber
            case .cardHolderName:
                if #available(iOS 17, *) { expected = .creditCardName } else { expected = .name }
            case .expDate:
                if #available(iOS 17, *) { expected = .creditCardExpiration } else { expected = nil }
            case .cvc:
                if #available(iOS 17, *) { expected = .creditCardSecurityCode } else { expected = nil }
            default: expected = nil
            }
            XCTAssertEqual(textfield.textField.textContentType, expected)
        }
    }

    func testAutoFillContentTypeOverrides() {
        configuration.type = .none
        for hint: UITextContentType in [.username, .password, .oneTimeCode, .emailAddress, .telephoneNumber] {
            configuration.textContentType = hint
            textfield.configuration = configuration
            XCTAssertEqual(textfield.textField.textContentType, hint)
        }
        configuration.type = .cardNumber
        configuration.textContentType = nil
        textfield.configuration = configuration
        XCTAssertNil(textfield.textField.textContentType)
    }

    func testAutoFillStyleBulkInsertion() throws {
        configuration.type = .cardNumber
        textfield.configuration = configuration
        let observer = AutoFillChangeObserver()
        textfield.delegate = observer
        let field = textfield.textField
        field.insertText("4111111111111111")
        XCTAssertEqual(field.secureText, "4111 1111 1111 1111")
        XCTAssertTrue(textfield.state.isValid)
        XCTAssertTrue(textfield.state.isDirty)
        XCTAssertEqual(observer.count, 1)
        field.selectedTextRange = field.textRange(from: field.beginningOfDocument, to: field.endOfDocument)
        field.insertText("378282246310005")
        XCTAssertEqual(field.secureText, "3782 822463 10005")
        XCTAssertTrue(textfield.state.isValid)
        XCTAssertEqual(observer.count, 2)
        let selection = try XCTUnwrap(field.selectedTextRange)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: selection.start), 17)
    }

    func testBulkInsertionAcrossAutoFillFieldTypes() throws {
        let cases: [BulkInputCase] = [
            .init(type: .cardHolderName, input: "Jane Doe", output: "Jane Doe", secure: false),
            .init(type: .expDate, input: "1235", output: "12/35", secure: false),
            .init(type: .cvc, input: "123", output: "123", secure: true),
            .init(type: .none, input: "user@example.com", output: "user@example.com", secure: false)
        ]
        for testCase in cases {
            let config = VGSConfiguration(collector: collector, fieldName: "bulkInput")
            config.type = testCase.type
            let control = VGSTextField()
            control.configuration = config
            control.isSecureTextEntry = testCase.secure
            let observer = AutoFillChangeObserver()
            control.delegate = observer

            control.textField.insertText(testCase.input)

            XCTAssertEqual(control.textField.secureText, testCase.output)
            XCTAssertTrue(control.state.isValid)
            XCTAssertTrue(control.state.isDirty)
            XCTAssertEqual(observer.count, 1)
            XCTAssertEqual(control.textField.isSecureTextEntry, testCase.secure)
            let selection = try XCTUnwrap(control.textField.selectedTextRange)
            XCTAssertEqual(control.textField.offset(from: control.textField.beginningOfDocument,
                                                   to: selection.start), testCase.output.utf16.count)
        }
    }

    func testInvalidBulkCardInputRemainsInvalid() {
        configuration.type = .cardNumber
        textfield.configuration = configuration
        textfield.textField.insertText("4111111111111112")
        XCTAssertFalse(textfield.state.isValid)
        XCTAssertTrue(textfield.state.isDirty)
        XCTAssertEqual(textfield.state.inputLength, 16)
    }

    private struct BulkInputCase {
        let type: FieldType
        let input: String
        let output: String
        let secure: Bool
    }

    private class AutoFillChangeObserver: NSObject, VGSTextFieldDelegate {
        var count = 0
        func vgsTextFieldDidChange(_ textField: VGSTextField) { count += 1 }
    }

    func testSetDefaultText() {
      configuration.type = .cardNumber
      textfield.configuration = configuration
      textfield.setDefaultText("4111111111111111")
      XCTAssertTrue(textfield.textField.secureText == "4111 1111 1111 1111")
      XCTAssertTrue(textfield.state.inputLength == 16)
      XCTAssertTrue(textfield.state.isDirty == false)
      XCTAssertTrue(textfield.state.isEmpty == false)
      XCTAssertTrue(textfield.state.isValid == true)
      XCTAssertTrue(textfield.textField.textContentType == .creditCardNumber)
    }
    
    func testSetText() {
      let placeholder = "card numner"
      configuration.type = .cardNumber
      configuration.textContentType = nil
      textfield.configuration = configuration
      textfield.placeholder = placeholder
      textfield.setText("4111111111111111")
      XCTAssertTrue(textfield.textField.placeholder == placeholder)
      XCTAssertTrue(textfield.textField.secureText == "4111 1111 1111 1111")
      XCTAssertTrue(textfield.state.inputLength == 16)
      XCTAssertTrue(textfield.state.isDirty == true)
      XCTAssertTrue(textfield.state.isEmpty == false)
      XCTAssertTrue(textfield.state.isValid == true)
      XCTAssertNil(textfield.textField.textContentType)
  }
  
  func testCleanText() {
      configuration.type = .cardNumber
      textfield.configuration = configuration
      textfield.setDefaultText("4111111111111111")
      textfield.cleanText()
      XCTAssertTrue(textfield.textField.secureText == "")
      XCTAssertTrue(textfield.state.inputLength == 0)
      XCTAssertTrue(textfield.state.isDirty == false)
      XCTAssertTrue(textfield.state.isEmpty == true)
      XCTAssertTrue(textfield.state.isValid == false)
    
      textfield.setText("4111111111111111")
      textfield.cleanText()
      XCTAssertTrue(textfield.textField.secureText == "")
      XCTAssertTrue(textfield.state.inputLength == 0)
      XCTAssertTrue(textfield.state.isDirty == true)
      XCTAssertTrue(textfield.state.isEmpty == true)
      XCTAssertTrue(textfield.state.isValid == false)
   }
  
  func testFieldsContentEqual() {
    let input1 = "4111111111111111"
    let input2 = "41111111111111111"
    
    /// Field with default `.cardNumber` configuration
    let testField1 = VGSTextField()
    let config = VGSConfiguration(collector: collector, fieldName: "field1")
    config.type = .cardNumber
    testField1.configuration = config
    
    /// Field with default `.none` configuration
    let testField2 = VGSTextField()
    let config2 = VGSConfiguration(collector: collector, fieldName: "field2")
    config2.type = .none
    testField2.configuration = config2
    
    /// Field with custom dividers and formatPattern
    let testField3 = VGSCardTextField()
    let config3 = VGSConfiguration(collector: collector, fieldName: "field3")
    config3.type = .cardNumber
    config3.divider = "---"
    config3.formatPattern = "## ## ## ## ## ## ## ## ##"
    testField3.configuration = config3
    
    /// Field not attached to VGSCollect instance
    let testField4 = VGSTextField()
    
    let testFields = [testField1, testField2, testField3, testField4]
    // swiftlint:disable identifier_name
    for i in 0 ..< testFields.count - 1 {
      let field1 = testFields[i]
      
      for j in (i+1) ..< testFields.count {
        let field2 = testFields[j]
        // swiftlint:enable identifier_name
        
        /// Test positive case with equal input
        field1.textField.secureText = input1
        field2.textField.secureText = input1
        XCTAssertTrue(field1.isContentEqual(field2), "Fields not equal error: \(String(describing: field1.textField.secureText)) != \(String(describing: field2.textField.secureText)))")
        XCTAssertTrue(field2.isContentEqual(field1), "Fields not equal error: \(String(describing: field2.textField.secureText)) != \(String(describing: field1.textField.secureText)))")
        
        /// Test negative case with different input
        field2.textField.secureText = input2
        XCTAssertFalse(field1.isContentEqual(field2), "Fields equal error: \(String(describing: field1.textField.secureText)) == \(String(describing: field2.textField.secureText)))")
        XCTAssertFalse(field2.isContentEqual(field1), "Fields equal error: \(String(describing: field2.textField.secureText)) == \(String(describing: field1.textField.secureText)))")
      }
    }
  }
  
  func testExpDateFieldsContentEqual() {
    let expDate1 = VGSTextField()
    let config1 = VGSExpDateConfiguration.init(collector: collector, fieldName: "expDate1")
    config1.formatPattern = "##---##"
    config1.divider = "."
    expDate1.configuration = config1
  
    let expDate2 = VGSExpDateTextField()
    let config2 = VGSExpDateConfiguration(collector: collector, fieldName: "expDate2")
    config2.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "month2", yearFieldName: "year2")]
    expDate2.configuration = config2
  
    let input1 = "0225"
    let input2 = "0325"
    
    /// Test positive case with equal input
    expDate1.textField.secureText = input1
    expDate2.textField.secureText = input1
    XCTAssertTrue(expDate1.isContentEqual(expDate2), "Fields not equal error: \(String(describing: expDate1.textField.secureText)) != \(String(describing: expDate1.textField.secureText)))")
    XCTAssertTrue(expDate2.isContentEqual(expDate1), "Fields not equal error: \(String(describing: expDate2.textField.secureText)) != \(String(describing: expDate1.textField.secureText)))")
    
    /// Test negative case with different input
    expDate1.textField.secureText = input1
    expDate2.textField.secureText = input2
    XCTAssertFalse(expDate1.isContentEqual(expDate2), "Fields equal error: \(String(describing: expDate1.textField.secureText)) == \(String(describing: expDate1.textField.secureText)))")
    XCTAssertFalse(expDate2.isContentEqual(expDate1), "Fields equal error: \(String(describing: expDate2.textField.secureText)) == \(String(describing: expDate1.textField.secureText)))")
  }
}
       
