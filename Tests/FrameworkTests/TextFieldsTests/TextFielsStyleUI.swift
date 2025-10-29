//
//  TextFielsStyleUI.swift
//  FrameworkTests
//


import XCTest
@testable import VGSCollectSDK

class TextFielsStyleUI: XCTestCase {

    var textField: VGSTextField!
    
    override func setUp() {
        textField = VGSTextField()
    }

    override func tearDown() {
        textField = nil
    }
    
    func testFocusOn() {
        textField.focusOn()
        XCTAssertFalse(textField.isFocused)
    }
    
    func testBorderColor() {
        let color = UIColor.green
        textField.borderColor = color
        XCTAssert(textField.borderColor == color)
        XCTAssert(textField.layer.borderColor == color.cgColor)
    }
    
    func testBorderWidth() {
        let width: CGFloat = 1
        textField.borderWidth = width
        XCTAssert(textField.borderWidth == width)
        XCTAssert(textField.layer.borderWidth == width)
    }
    
    func testRadius() {
        let radius: CGFloat = 4
        textField.cornerRadius = radius
        XCTAssert(textField.cornerRadius == radius)
        XCTAssert(textField.layer.cornerRadius == radius)
        XCTAssert(textField.layer.masksToBounds == true)
    }
    
    func testFont() {
        let font = UIFont(name: "Arial", size: 22)
        textField.font = font
        XCTAssert(textField.font?.pointSize == font?.pointSize)
        XCTAssert(textField.font?.familyName == "Arial")
    }
    
    func testTextColor() {
        let color = UIColor.green
        textField.textColor = color
        XCTAssert(textField.textField.textColor == color)
    }
}
