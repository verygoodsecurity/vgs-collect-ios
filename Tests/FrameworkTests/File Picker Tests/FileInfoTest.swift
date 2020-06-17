//
//  FileInfoTest.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 20.04.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class FileInfoTest: XCTestCase {
    
    var fileInfo: VGSFileInfo!
    var fileExtension: String!
    var fileSize: Int!
    var sizeUnits: String!
    
    override func setUp() {
        fileExtension = "png"
        fileSize = 987654321
        sizeUnits = "mb"
        fileInfo = VGSFileInfo(fileExtension: fileExtension,
                               size: fileSize,
                               sizeUnits: sizeUnits)
    }
    
    override func tearDown() {
        fileInfo = nil
        fileExtension = nil
        fileSize = nil
        sizeUnits = nil
    }
    
    func testInfo() {
        XCTAssertTrue(fileInfo.fileExtension == fileExtension)
        XCTAssertTrue(fileInfo.size == fileSize)
        XCTAssertTrue(fileInfo.sizeUnits == sizeUnits)
    }
}
