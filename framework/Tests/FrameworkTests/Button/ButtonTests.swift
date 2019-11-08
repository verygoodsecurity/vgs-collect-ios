//
//  ButtonTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/6/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class ButtonTests: XCTestCase {

    var button: VGSButton!
    
    override func setUp() {
        button = VGSButton(frame: .zero)
        button.type = .library
        button.presentViewController = UIViewController()
    }

    override func tearDown() {
        button = nil
    }
    
    func testInitialization() {
        button.prepareForInterfaceBuilder()
        XCTAssertNotNil(button.button)
        XCTAssert(button.type != .none)
    }
    
    func testAlert() {
        button.showAlert(message: "test")
    }
    
    func testGetImage() {
        button.getImageFromLibrary()
    }
    
    func testGetCamera() {
        button.getImageFromCamera()
    }
    
    func testTarget() {
        let tmp = button.button.actions(forTarget: button, forControlEvent: .touchUpInside)
        XCTAssertNotNil(tmp)
        XCTAssert(tmp?.first == "buttonAction:")
    }
    
    func testGetFile() {
        button.getFile()
        button.getFileFromPicker(files: [URL(fileURLWithPath: "file://*.*")])
        XCTAssert(button.title == "Selected")
    }
    
    // MARK: - UI path
    func testUIBorder() {
        let color = UIColor.green
        
        button.layer.borderColor = nil
        XCTAssert(button.borderColor != color)
        
        button.borderColor = color
        XCTAssert(button.borderColor == color)
        XCTAssert(button.layer.borderColor == color.cgColor)
    }
    
    func testBorderWidth() {
        let width: CGFloat = 1
        button.borderWidth = width
        XCTAssert(button.borderWidth == width)
        XCTAssert(button.layer.borderWidth == width)
    }
    
    func testRadius() {
        let radius: CGFloat = 4
        button.cornerRadius = radius
        XCTAssert(button.cornerRadius == radius)
        XCTAssert(button.layer.cornerRadius == radius)
        XCTAssert(button.layer.masksToBounds == true)
    }
    
    func testTextColor() {
        let color = UIColor.red
        button.textColor = color
        XCTAssert(button.textColor == color)
        XCTAssert(button.button.titleLabel?.textColor == color)
    }
    
    func testTitle() {
        let title = "adlkjlakjdkajd"
        button.title = title
        XCTAssert(button.title == title)
        XCTAssert(button.button.title(for: .normal) == title)
        XCTAssert(button.button.titleLabel?.text == title)
    }
    
    func testSetFont() {
        let font = UIFont.systemFont(ofSize: 34)
        button.font = font
        XCTAssert(button.font == font)
        XCTAssert(button.button.titleLabel?.font == font)
    }
}
