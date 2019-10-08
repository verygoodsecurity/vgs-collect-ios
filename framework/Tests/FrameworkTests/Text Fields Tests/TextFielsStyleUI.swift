//
//  TextFielsStyleUI.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/3/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class TextFielsStyleUI: XCTestCase {

    var textField: VGSTextField!
    
    override func setUp() {
        textField = VGSTextField()
    }

    override func tearDown() {
        textField = nil
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
    
    func testPadding() {
        var newRect: CGRect = .zero
        let value: CGFloat = 15
        let padding = UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
        textField.padding = padding
        
        newRect = textField.textField.textRect(forBounds: .zero)
        XCTAssert(newRect.origin.x == value)
        XCTAssert(newRect.size.width == value*(-2))
        
        newRect = textField.textField.placeholderRect(forBounds: .zero)
        XCTAssert(newRect.origin.x == value)
        XCTAssert(newRect.size.width == value*(-2))
        
        newRect = textField.textField.editingRect(forBounds: .zero)
        XCTAssert(newRect.origin.x == value)
        XCTAssert(newRect.size.width == value*(-2))
    }
}
