//
//  XCUIElement+Extensions.swift
//  VGSCheckoutDemoAppUITests

import Foundation
import XCTest

extension XCUIElement {
	/**
	Types text into the textField. Clear previous content if specified.

	- parameters:
		- text: `String` object. Text to type.
		- shouldClear: `Bool` flag. If `true` clears previous input. Default is `true`.
	*/
	func type(_ text: String, shouldClear: Bool = true) {
		tap()

		// Clear previous input if needed.
		if shouldClear, let currentText = value as? String, !currentText.isEmpty {
			let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count)
			typeText(deleteString)
		}

		typeText(text)
	}

	/// Scrolls to specific element.
	/// - Parameter element: `XCUIElement` object, UI element.
	func scrollToElement(element: XCUIElement) {
			while !element.visible() {
					swipeUp()
			}
	}

	/// Checks if element is visible.
	/// - Returns: `Bool` flag, true if visible.
	func visible() -> Bool {
		guard self.exists && !self.frame.isEmpty else { return false }
		return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
	}
}
