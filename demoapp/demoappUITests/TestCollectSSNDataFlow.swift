//
//  TestCollectSSNDataFlow.swift
//  demoappUITests
//
//  Created by Dima on 31.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest

/// Tests for SSN data flow.
class TestCollectSSNDataFlow: TestCollectBaseTestCase {

  /// UI elements.
  enum UIElements {
  // swiftlint:disable nesting
    
    /// VGSText field.
    enum VGSTextField {

      /// SSN fields.
      enum SSN {
        /// Card holder name.
        static let ssn: VGSUITestElement = .init(type: .textField, identifier: "XXX-XX-XXXX")
      }
    }

    /// Labels.
    enum Labels {

      /// Console label identifier.
      static let consoleLabelIdentifier = "ConsoleLabelIdentifire"

      /// State label.
      static let state = "STATE"

      /// Response label.
      static let response = "RESPONSE"
    }

    /// Buttons.
    enum Buttons {

      /// Upload.
      static let upload: VGSUITestElement = .init(type: .button, identifier: "UPLOAD")
    }

    /// Texts.
    enum Texts {

      /// Raw ssn.
      static let rawSSN = "111558899"

      /// Masked ssn.
      static let maskedSSN = "SSN: XXX-XX-8899"
    }
    // swiftlint:enable nesting
  }

  /// Verifies correct data flow works for ssn.
  func testPutCorrectData() {
    // Navigate to SSN.
    app.tables.staticTexts[TestsCollectFlowType.ssn.name].tap()

    let ssnField = UIElements.VGSTextField.SSN.ssn.find(in: app)
    ssnField.tap()
    ssnField.typeText(UIElements.Texts.rawSSN)
    
    app.staticTexts[UIElements.Texts.maskedSSN].tap()
    UIElements.Buttons.upload.find(in: app).tap()

    // Wait for request.
    wait(forTimeInterval: 30)

    // Find response label.
    let responseLabel = app.staticTexts[UIElements.Labels.response]

    // Verify success response.
    verifySuccessResponse()
  }
}
