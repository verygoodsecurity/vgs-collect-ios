//
//  TextFieldMaxInputLengthTests.swift
//  FrameworkTests

import Foundation
import XCTest
@testable import VGSCollectSDK

/// Tests for max input length.
@MainActor 
class TextFieldMaxInputLengthTests: VGSCollectBaseTestCase {

	  /// Collect instance.
		var collector: VGSCollect!

	  /// Configuration instance.
		var configuration: VGSConfiguration!

	  /// VGS text field.
		var textfield: VGSTextField!

	  /// Default setup.
		override func setUp() {
				super.setUp()
				collector = VGSCollect(id: "vaultid")
				configuration = VGSConfiguration.init(collector: collector, fieldName: "test1")
				textfield = VGSTextField()
				textfield.configuration = configuration
		}

		/// Default tear down.
		override func tearDown() {
				collector  = nil
				configuration = nil
				textfield = nil
		}

	  /// Test set default text with max input length.
		func testSetDefaultTextWithMaxLength() {
			configuration.type = .none
			configuration.maxInputLength = 3
			textfield.configuration = configuration
			textfield.setDefaultText("Joe Doe")
			XCTAssertTrue(textfield.textField.secureText == "Joe")
			XCTAssertTrue(textfield.state.inputLength == 3)
			XCTAssertTrue(textfield.state.isDirty == false)
			XCTAssertTrue(textfield.state.isEmpty == false)
			XCTAssertTrue(textfield.state.isValid == true)

			// Test set nil.
			textfield.setDefaultText(nil)
			XCTAssertTrue(textfield.textField.secureText == "")

			// Disable max input length.
			configuration.maxInputLength = nil
			textfield.setDefaultText("Joe Doe")
			XCTAssertTrue(textfield.textField.secureText == "Joe Doe")
			XCTAssertTrue(textfield.state.inputLength == 7)
			XCTAssertTrue(textfield.state.isDirty == false)
			XCTAssertTrue(textfield.state.isEmpty == false)
			XCTAssertTrue(textfield.state.isValid == true)
		}

		/// Test set text with max input length.
		func testSetTextWithMaxLength() {
			configuration.type = .none
			configuration.maxInputLength = 3
			textfield.configuration = configuration
			textfield.setText("Joe Doe")
			XCTAssertTrue(textfield.textField.secureText == "Joe")
			XCTAssertTrue(textfield.state.inputLength == 3)
			XCTAssertTrue(textfield.state.isDirty == true)
			XCTAssertTrue(textfield.state.isEmpty == false)
			XCTAssertTrue(textfield.state.isValid == true)

			// Test set nil.
			textfield.setText(nil)
			XCTAssertTrue(textfield.textField.secureText == "")

      // Disable max input length.
			configuration.maxInputLength = nil
			textfield.setText("Joe Doe")
			XCTAssertTrue(textfield.textField.secureText == "Joe Doe")
			XCTAssertTrue(textfield.state.inputLength == 7)
			XCTAssertTrue(textfield.state.isDirty == true)
			XCTAssertTrue(textfield.state.isEmpty == false)
			XCTAssertTrue(textfield.state.isValid == true)
	}

	/// Test clean text with max input length.
	func testCleanTextWithMaxInputLength() {
			configuration.type = .none
			configuration.maxInputLength = 3
			textfield.configuration = configuration
			textfield.setDefaultText("Joe")
			textfield.cleanText()
			XCTAssertTrue(textfield.textField.secureText == "")
			XCTAssertTrue(textfield.state.inputLength == 0)
			XCTAssertTrue(textfield.state.isDirty == false)
			XCTAssertTrue(textfield.state.isEmpty == true)

			configuration.type = .none
			configuration.maxInputLength = 3
			textfield.configuration = configuration
			textfield.setText("Joe")
			textfield.cleanText()
			XCTAssertTrue(textfield.textField.secureText == "")
			XCTAssertTrue(textfield.state.inputLength == 0)
			XCTAssertTrue(textfield.state.isDirty == true)
			XCTAssertTrue(textfield.state.isEmpty == true)
	 }
    func testMaskedPasteRespectsMaxInputLength() throws {
        configuration.formatPattern = "#### ####"
        configuration.maxInputLength = 6
        textfield.configuration = configuration
        let field = textfield.textField
        field.secureText = "1234"
        field.selectedTextRange = field.textRange(from: field.endOfDocument, to: field.endOfDocument)
        let initialRange = try XCTUnwrap(field.selectedTextRange)
        _ = field.textPasteConfigurationSupporting(field, performPasteOf: NSAttributedString(string: "567"), to: initialRange)
        XCTAssertEqual(field.secureText, "1234")
        let rejected = try XCTUnwrap(field.selectedTextRange)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: rejected.start), 4)
        let acceptedRange = try XCTUnwrap(field.selectedTextRange)
        _ = field.textPasteConfigurationSupporting(field, performPasteOf: NSAttributedString(string: "56"), to: acceptedRange)
        XCTAssertEqual(field.secureText, "1234 56")
        let accepted = try XCTUnwrap(field.selectedTextRange)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: accepted.start), 7)
    }

    func testMaskedDeletionAndChangeCallback() throws {
        configuration.formatPattern = "#### ####"
        textfield.configuration = configuration
        let field = textfield.textField
        field.secureText = "123456"
        field.selectedTextRange = field.textRange(from: field.endOfDocument, to: field.endOfDocument)
        let observer = ChangeObserver()
        textfield.delegate = observer
        field.deleteBackward()
        XCTAssertEqual(field.secureText, "1234 5")
        XCTAssertEqual(observer.changeCount, 1)
        let selection = try XCTUnwrap(field.selectedTextRange)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: selection.start), 6)
        field.insertText("67")
        XCTAssertEqual(field.secureText, "1234 567")
        XCTAssertEqual(observer.changeCount, 2)
    }

    private class ChangeObserver: NSObject, VGSTextFieldDelegate {
        var changeCount = 0
        func vgsTextFieldDidChange(_ textField: VGSTextField) {
            changeCount += 1
        }
    }
}
