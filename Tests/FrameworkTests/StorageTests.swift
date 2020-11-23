//
//  StorageTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/3/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class StorageTests: XCTestCase {
    var storage: Storage!
    var textField: VGSTextField!
    
    override func setUp() {
        storage = Storage()
        textField = VGSTextField()
    }

    override func tearDown() {
        storage = nil
        textField = nil
    }
    
    func testAdd() {
        storage.addTextField(textField)
        XCTAssert(storage.textFields.count == 1)
        
        storage.addTextField(textField)
        XCTAssert(storage.textFields.count == 1)
    }
    
    func testRemove() {
        storage.removeTextField(textField)
        XCTAssert(storage.textFields.count == 0)
    }
}
