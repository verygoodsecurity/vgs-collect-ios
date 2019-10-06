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
}
