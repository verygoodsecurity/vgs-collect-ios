//
//  MasterCardBrandTest.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 06.04.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSFramework

class MasterCardBrandTest: XCTestCase {
    var storage: VGSCollect!
    var cardTextField: VGSTextField!
    
    override func setUp() {
        storage = VGSCollect(id: "123")
        cardTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: storage, fieldName: "cardNum")
        config.type = .cardNumber
        
        cardTextField.configuration = config
    }

    override func tearDown() {
        storage = nil
        cardTextField = nil
    }
    
    func testAllBrand() {
        let allBrands = SwiftLuhn.CardType.allCases
        allBrands.forEach { brand in
            let numbers = brand.cardNumbers
            numbers.forEach { number in
                cardTextField.textField.secureText = number
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
                XCTAssert(state.cardBrand == brand, "Card number \(number) for brand \(brand) fail")
            }
            
        }
    }
}
