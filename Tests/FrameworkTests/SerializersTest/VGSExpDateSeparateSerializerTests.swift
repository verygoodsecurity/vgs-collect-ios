//
//  VGSExpDateSeparateSerializerTests.swift
//  FrameworkTests
//
//  Created by Dima on 27.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSExpDateSeparateSerializerTests: VGSCollectBaseTestCase {
  var collector: VGSCollect!
  var textField: VGSExpDateTextField!

  struct TestJSONData {
    let fieldValue: String
    let monthFieldName: String
    let yearFieldName: String
    let submitJSON: JsonData
    
    init?(json: JsonData) {
      guard let submitJSON = json["expectedResult"] as? JsonData else {
        XCTFail("Cannot parse test data.")
        return nil
      }
      self.fieldValue = json["fieldValue"] as? String ?? ""
      self.monthFieldName = json["monthFieldName"] as? String ?? ""
      self.yearFieldName = json["yearFieldName"] as? String ?? ""
      self.submitJSON = submitJSON
    }
  }

  override func setUp() {
      super.setUp()
      collector = VGSCollect(id: "any")
      textField = VGSExpDateTextField()
  }

  override func tearDown() {
      collector = nil
      textField = nil
  }

  func testSplitExpDateSerializerWithDefaultConfig() {
    let testData = VGSFieldNameMapperTestDataProvider.provideTestDataForDefaultExpirationDateSplitSerializer()
    
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
    config.formatPattern = "##/##"
    
    for test in testData {
      config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: test.monthFieldName, yearFieldName: test.yearFieldName)]
      textField.configuration = config
      textField.setText(test.fieldValue)
      
      let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSON, extraData: nil)
      XCTAssertTrue(submitJSON == test.submitJSON, "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
      
    }
  }
  
  func testSplitExpDateSerializerWithCustomConfig() {
    let testData = VGSFieldNameMapperTestDataProvider.provideTestDataForCustomExpirationDateSplitSerializer()
    
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "card.expDate")
    config.formatPattern = "##/##"
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYear
    config.divider = "-/-"
    
    for test in testData {
      config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: test.monthFieldName, yearFieldName: test.yearFieldName)]
      textField.configuration = config
      textField.setText(test.fieldValue)
      
      let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSON, extraData: nil)
      XCTAssertTrue(submitJSON == test.submitJSON, "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
      
    }
  }
}
