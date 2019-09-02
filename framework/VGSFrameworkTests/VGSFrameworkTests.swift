//
//  VGSFrameworkTests.swift
//  VGSFrameworkTests
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class TestVGS: VGS {
    public var storage: Storage {
        return Storage()
    }
}

class VGSFrameworkTests: XCTestCase {
    var vgs: TestVGS? = nil
    var card: VGSTextField!
    var cvv: VGSTextField!
    var expDate: VGSTextField!
    var nameHolder: VGSTextField!
    
    override func setUp() {
        vgs = TestVGS(upstreamHost: "https://tntva5wfdrp.SANDBOX.verygoodproxy.com")
        
        card = VGSTextField(frame: .zero)
        card.text = "1212121212121212"
        
        cvv = VGSTextField(frame: .zero)
        cvv.text = "123"
        
        expDate = VGSTextField(frame: .zero)
        expDate.text = "12/23"
        
        nameHolder = VGSTextField(frame: .zero)
        nameHolder.text = "John Connor"
    }

    override func tearDown() {
        vgs = nil
        card = nil
        cvv = nil
        expDate = nil
        nameHolder = nil
    }

    func testRegisterElements() {
        let allElements: [VGSTextField] = [card, cvv, expDate, nameHolder]
        vgs?.registerTextFields(textField: allElements)
        
        XCTAssert((allElements.count == vgs?.storage.elements.count))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
