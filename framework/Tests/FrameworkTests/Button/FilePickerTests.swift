//
//  ButtonTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/6/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class FilePickerTests: XCTestCase {
    var vgsForm: VGSCollect!
    var filePicker: VGSFilePicker!
    
    override func setUp() {
        vgsForm = VGSCollect(id: "tntva5wfdrp", environment: .sandbox)
        filePicker = VGSFilePicker(frame: .zero)
        filePicker.configuration = VGSConfiguration(collector: vgsForm, fieldName: "image")
        filePicker.type = .library
        filePicker.presentViewController = UIViewController()
    }

    override func tearDown() {
        filePicker = nil
        vgsForm = nil
    }
    
    func testInitialization() {
        XCTAssertNotNil(filePicker.button)
        XCTAssert(filePicker.type != .none)
    }
    
    func testAlert() {
        filePicker.showAlert(message: "test")
    }
    
    func testGetImage() {
        filePicker.getImageFromLibrary()
    }
    
    func testGetCamera() {
        filePicker.getImageFromCamera()
    }
    
    func testTarget() {
        let tmp = filePicker.button.actions(forTarget: filePicker, forControlEvent: .touchUpInside)
        XCTAssertNotNil(tmp)
        XCTAssert(tmp?.first == "buttonAction:")
    }
    
    func testGetFile() {
        filePicker.getFile()
    }
    
    // MARK: - UI path
    func testUIBorder() {
        let color = UIColor.green
        filePicker.borderColor = color
        XCTAssert(filePicker.borderColor == color)
        XCTAssert(filePicker.layer.borderColor == color.cgColor)
    }
    
    func testBorderWidth() {
        let width: CGFloat = 1
        filePicker.borderWidth = width
        XCTAssert(filePicker.borderWidth == width)
        XCTAssert(filePicker.layer.borderWidth == width)
    }
    
    func testRadius() {
        let radius: CGFloat = 4
        filePicker.cornerRadius = radius
        XCTAssert(filePicker.cornerRadius == radius)
        XCTAssert(filePicker.layer.cornerRadius == radius)
        XCTAssert(filePicker.layer.masksToBounds == true)
    }
    
    func testTextColor() {
        let color = UIColor.red
        filePicker.textColor = color
        XCTAssert(filePicker.button.titleLabel?.textColor == color)
    }
    
    func testTitle() {
        let title = "adlkjlakjdkajd"
        filePicker.title = title
        XCTAssert(filePicker.title == title)
        XCTAssert(filePicker.button.title(for: .normal) == title)
        XCTAssert(filePicker.button.titleLabel?.text == title)
    }
    
    // MARK: - Upload file
    func testUpload() {
        //The Bundle for your current class
        let bundle = Bundle(for: type(of: self))
        let testImage = UIImage(named: "visa", in: bundle, compatibleWith: nil)
        
        XCTAssertNotNil(testImage)
        vgsForm.storage.files["image"] = testImage
        
        let expectation = XCTestExpectation(description: "Upload file...")
        vgsForm.submitFiles(path: "/post", method: .post) { result, error in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30.0)
    }
}
