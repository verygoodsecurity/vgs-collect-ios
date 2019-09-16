//
//  VGSFrameworkTests.swift
//  VGSFrameworkTests
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework


class VGSFrameworkTests: XCTestCase {
    var vgs: VGSForm!
    var card: VGSTextField!
    var cvv: VGSTextField!
    var expDate: VGSTextField!
    
    override func setUp() {
        
        vgs = VGSForm(tnt: "tntva5wfdrp", environment: .sandbox)
        
        card = VGSTextField()
        card.configuration = VGSConfiguration(form: vgs, alias: "cardNum")
        card.configuration?.type = .cardNumber
        card.text = "1212121212121212"
        
        cvv = VGSTextField()
        cvv.configuration = VGSConfiguration(form: vgs, alias: "cvv")
        cvv.configuration?.type = .cvv
        cvv.text = "123"
        
        expDate = VGSTextField()
        expDate.configuration = VGSConfiguration(form: vgs, alias: "expDate")
        expDate.configuration?.type = .dateExpiration
        expDate.text = "12/23"
    }

    override func tearDown() {
        vgs = nil
        card = nil
        cvv = nil
        expDate = nil
    }

    func testExpDateValid() {
        
        let flag = expDate.isValid
        XCTAssertTrue(flag)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
