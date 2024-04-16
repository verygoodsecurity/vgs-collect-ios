//
//  VGSUITestElement.swift
//  VGSCheckoutDemoAppUITests

import Foundation
import XCTest

/// Holds XCUIElement identifiers and types.
struct VGSUITestElement {

	/// For simple element lookup. Check `UITestElement.find()`.
	let type: VGSUITestElementType

	/// Accessibility identifier of the UI element.
	let identifier: String

	/// Find element in app.
	/// - Parameter app: `XCUIApplication` object.
	/// - Returns: `XCUIElement` object.
	func find(in app: XCUIApplication) -> XCUIElement {
      switch type {
      case .label:
        return app.staticTexts[identifier]
      case .button:
        return app.buttons[identifier]
      case .table:
        return app.tables[identifier]
      case .slider:
        return app.sliders[identifier]
      case .other:
        return app.otherElements[identifier]
      case .collection:
        return app.collectionViews[identifier]
      case .image:
        return app.images[identifier]
      case .textField:
        return app.textFields[identifier]
      case .secureTextField:
        return app.secureTextFields[identifier]
      case .tabBar:
        return app.tabBars[identifier]
      case .navigationBar:
        return app.navigationBars[identifier]
      }
	}

	/// Check if element exists in app.
	/// - Parameters:
	///   - app: `XCUIApplication` object.
	///   - timeout: `TimeInterval` to wait, default is `3`.
	/// - Returns: `Bool` flag, `true` if exists.
	func exists(in app: XCUIApplication, timeout: TimeInterval = 3) -> Bool {
		return find(in: app).waitForExistence(timeout: timeout)
	}
}
