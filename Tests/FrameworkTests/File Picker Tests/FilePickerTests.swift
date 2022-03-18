//
//  ButtonTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/6/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class FilePickerTests: VGSCollectBaseTestCase {
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
        let bundle = AssetsBundle.main.iconBundle
        let testImage = UIImage(named: "visa", in: bundle, compatibleWith: nil)?.jpegData(compressionQuality: 1)
        
        XCTAssertNotNil(testImage)
        vgsForm.storage.files["image"] = testImage
        
        let expectation = XCTestExpectation(description: "Upload file...")
      
        vgsForm.sendData(path: "post") { (response) in
          switch response {
          case .success(let code, let data, _):
            XCTAssertTrue(code == 200)
            XCTAssertNotNil(data)
          case .failure(let code, _, _, let error):
              XCTFail("Error: code=\(code):\(String(describing: error?.localizedDescription))")
          }
          expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
}
