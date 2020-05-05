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
        storage.addElement(textField)
        XCTAssert(storage.elements.count == 1)
        
        storage.addElement(textField)
        XCTAssert(storage.elements.count == 1)
    }
    
    func testRemove() {
        storage.removeElement(textField)
        XCTAssert(storage.elements.count == 0)
    }
}
