//
//  StorageTests.swift
//  FrameworkTests
//


import XCTest
@testable import VGSCollectSDK
@MainActor
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
