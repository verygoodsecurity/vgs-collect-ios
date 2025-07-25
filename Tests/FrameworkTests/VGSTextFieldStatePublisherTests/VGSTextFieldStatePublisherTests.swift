//
//  VGSTextFieldStatePublisherTests.swift
//  FrameworkTests
//

import XCTest
import Combine
@testable import VGSCollectSDK

@available(iOS 13.0, *)
@MainActor
class VGSTextFieldStatePublisherTests: XCTestCase {
    
    var collector: VGSCollect!
    private var cancellableSet: Set<AnyCancellable> = []
  
    override func setUp() {
        collector = VGSCollect(id: "vaultId")
        cancellableSet = []
    }
    
    func testVGSTextFieldStatePublisher() {
        let exp = expectation(description: "VGSTextField State Publisher Test")
        let config = VGSConfiguration(collector: collector, fieldName: "name")
        config.type = .cardHolderName

        let textField = VGSTextField()
        textField.configuration = config
        var states: [VGSTextFieldState] = []
        
        textField.statePublisher
            .prepend(textField.state) // Emit the initial state
            .sink { state in
                states.append(state)
                if states.count == 3 {
                    exp.fulfill()
                }
            }
            .store(in: &cancellableSet)
        
        textField.setText("Test Text")
        textField.cleanText()

        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(states[0].isValid, false)
        XCTAssertEqual(states[0].isDirty, false)
        XCTAssertEqual(states[1].isValid, true)
        XCTAssertEqual(states[1].isDirty, true)
        XCTAssertEqual(states[2].isValid, false)
        XCTAssertEqual(states[2].isDirty, true)
    }
    
    func testVGSCardTextFieldStatePublisher() {
        let exp = expectation(description: "VGSCardTextField State Publisher Test")
        
        let config = VGSConfiguration.init(collector: collector, fieldName: "card_num")
        config.type = .cardNumber
        config.isRequired = true
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = config
      
        var states: [VGSCardState] = []
        cardTextField.statePublisher
            .prepend(cardTextField.state) // Emit the initial state
            .compactMap { $0 as? VGSCardState }
            .sink { cardState in
                states.append(cardState)
                if states.count == 2 {
                    exp.fulfill()
                }
            }
            .store(in: &cancellableSet)
        
        cardTextField.setText("4000 0000 0000 0002") // Invalid Visa card number
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(states[0].isValid, false)
        XCTAssertEqual(states[0].isDirty, false)
        XCTAssertEqual(states[0].cardBrand, VGSPaymentCards.CardBrand.unknown)
        XCTAssertEqual(states[1].isValid, true)
        XCTAssertEqual(states[1].isDirty, true)
        XCTAssertEqual(states[1].cardBrand, VGSPaymentCards.CardBrand.visa)
    }
}
