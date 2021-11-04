//
//  TextFieldMaxInputLengthTests.swift
//  FrameworkTests

import Foundation
import XCTest
@testable import VGSCollectSDK

/// Tests for max input length.
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
}
