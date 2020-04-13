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
    var filePicker: VGSFilePickerController!
    let parentVC = UIViewController()
    
    override func setUp() {
        vgsForm = VGSCollect(id: "tntva5wfdrp", environment: .sandbox)
        let filePickerConfiguration = VGSFilePickerConfiguration(collector: vgsForm, fieldName: "image", fileSource: .photoLibrary)
        filePicker = VGSFilePickerController(configuration: filePickerConfiguration)
    }

    override func tearDown() {
        filePicker = nil
        vgsForm = nil
    }
    
    // MARK: - Upload file
    func testUpload() {
        //The Bundle for your current class
        let bundle = Bundle(for: type(of: self))
        let testImage = UIImage(named: "visa", in: bundle, compatibleWith: nil)?.jpegData(compressionQuality: 1)
        
        XCTAssertNotNil(testImage)
        vgsForm.storage.files["image"] = testImage
        
        let expectation = XCTestExpectation(description: "Upload file...")
        vgsForm.submitFile(path: "/post", method: .post) { result, error in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
}
