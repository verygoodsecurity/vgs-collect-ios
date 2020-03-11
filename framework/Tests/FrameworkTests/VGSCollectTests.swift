//
//  FormTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class VGSCollectTests: XCTestCase {
    var collector: VGSCollect!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
    }

    override func tearDown() {
        collector = nil
    }

    func testEnvByDefault() {
        let host = collector.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("sandbox"))
    }
    
    func testLiveEnvirinment() {
        let liveForm = VGSCollect(id: "testID", environment: .live)
        let host = liveForm.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("live"))
    }
    
    func testCustomHeader() {
        let headerKey = "costom-header"
        let headerValue = "custom header value"
        
        collector.customHeaders = [
            headerKey: headerValue
        ]
        
        XCTAssertNotNil(collector.customHeaders)
        XCTAssert(collector.customHeaders![headerKey] == headerValue)
    }
    
    func testJail() {
        XCTAssertFalse(VGSCollect.isJailbroken())
    }
    
    func testCanOpen() {
        let path = "."
        XCTAssertTrue(VGSCollect.canOpen(path: path))
    }
    
    func testRegistrationTextField() {
        let config = VGSConfiguration(collector: collector, fieldName: "test")
        let tf = VGSTextField()
        tf.configuration = config
        
        XCTAssertTrue(collector.storage.elements.count == 1)
        
        collector.unregisterTextFields(textField: [tf])
        
        XCTAssertTrue(collector.storage.elements.count == 0)
    }
    
    func testCustomJsonMapping() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.card_number")
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.text = "4111 1111 1111 1112"
        
        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.cvc")
        let cvcTextField = VGSTextField()
        cvcTextField.configuration = cvcConfiguration
        cvcTextField.textField.text = "123"
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "user.name")
        let nameTextField = VGSTextField()
        nameTextField.configuration = nameConfiguration
        nameTextField.textField.text = "Joe Business"
        
        let ssnConfiguration = VGSConfiguration(collector: collector, fieldName: "ssn")
        let ssnTextField = VGSTextField()
        ssnTextField.configuration = ssnConfiguration
        ssnTextField.textField.text = "UA411111111111XZ"
        
        let result = collector.mapStoredInputDataForSubmit(with: nil)
        let expectedResult: [String: Any] = [
            "user": [
                "card_data": [
                    "card_number": "4111 1111 1111 1112",
                    "cvc": "123"
                ],
                "name": "Joe Business"
            ],
            "ssn": "UA411111111111XZ"
        ]
        XCTAssertTrue(expectedResult.jsonStringRepresentation == result.jsonStringRepresentation)
    }
    
    func testCustomJsonMappingWithExtraData() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.card_number")
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.text = "4111 1111 1111 1112"
        
        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.cvc")
        let cvcTextField = VGSTextField()
        cvcTextField.configuration = cvcConfiguration
        cvcTextField.textField.text = "123"
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "user.name")
        let nameTextField = VGSTextField()
        nameTextField.configuration = nameConfiguration
        nameTextField.textField.text = "Joe Business"
        
        let ssnConfiguration = VGSConfiguration(collector: collector, fieldName: "ssn")
        let ssnTextField = VGSTextField()
        ssnTextField.configuration = ssnConfiguration
        ssnTextField.textField.text = "UA411111111111XZ"
        
        let extraData: [String: Any] = [
            "user": [
                "id": 1234567890,
                "name": "unknown"
            ],
            "ssn": "not valid",
            "date": "05-05-1990"
        ]

        let result = collector.mapStoredInputDataForSubmit(with: extraData)
        
        let expectedResult: [String: Any] = [
            "user": [
                "card_data": [
                    "card_number": "4111 1111 1111 1112",
                    "cvc": "123"
                ],
                "name": "Joe Business",
                "id": 1234567890
            ],
            "ssn": "UA411111111111XZ",
            "date": "05-05-1990"
        ]
        XCTAssertTrue(expectedResult.jsonStringRepresentation == result.jsonStringRepresentation)
    }
}
