//
//  VGSExpDateTokenizationSerializerTests.swift
//  FrameworkTests

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSExpDateTokenizationSerializerTests: VGSCollectBaseTestCase {
  var collector: VGSCollect!
  var textField: VGSExpDateTextField!

  enum TestFlow {
    case defaultConfiguration

    var jsonFileName: String {
      return "VGSExpDateTokenizationSerialization_" + jsonFileNameSuffix
    }

    var jsonFileNameSuffix: String {
      switch self {
      case .defaultConfiguration:
        return "DefaultConfig"
      }
    }
  }

  struct TestJSONData {
    let fieldValue: String
    let monthFieldName: String
    let yearFieldName: String
    let submitJSON: JsonData
    let outputFormat: VGSCardExpDateFormat
    let comment: String

    init?(json: JsonData) {
      guard let submitJSON = json["expectedResult"] as? JsonData else {
        XCTFail("Cannot parse test data.")
        return nil
      }
      guard let formatName = json["outputFormat"] as? String,
      let format = VGSCardExpDateFormat(name: formatName) else {
        XCTFail("Cannot parse output format from test json")
        return nil
      }
      self.fieldValue = json["fieldValue"] as? String ?? ""
      self.monthFieldName = json["monthFieldName"] as? String ?? ""
      self.yearFieldName = json["yearFieldName"] as? String ?? ""
      self.submitJSON = submitJSON
      self.outputFormat = format
      self.comment = json["comment"] as? String ?? ""
    }
  }

  // MARK: - Override

  override func setUp() {
      super.setUp()
      collector = VGSCollect(id: "any")
      textField = VGSExpDateTextField()
  }

  override func tearDown() {
      collector = nil
      textField = nil
  }

  // MARK: - Tests

  /// Test default configuration.
  func testSplitExpDateSerializerWithDefaultConfig() {
    let fileName = TestFlow.defaultConfiguration.jsonFileName
    let testData = VGSExpDateSerializersDataProvider.provideTokenizationTestData(for: fileName)

    let config = VGSExpDateTokenizationConfiguration(collector: collector, fieldName: "expDate")
    config.formatPattern = "##/##"
    config.inputDateFormat = .shortYear

    for test in testData {
      config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: test.monthFieldName, yearFieldName: test.yearFieldName)]
      config.outputDateFormat = test.outputFormat
      textField.configuration = config

      textField.setText(test.fieldValue)

      let submitJSON = collector.mapFieldsToTokenizationRequestBodyJSON(collector.textFields)
//      print("submitJSON: \(submitJSON)")
//      print("test.submitJSON: \(test.submitJSON)")
      XCTAssertTrue(submitJSON == test.submitJSON, "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON) \nComment: \(test.comment)")
    }
  }
}
