//
//  VGSTokenizationResponseMappingTests.swift
//  FrameworkTests

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSTokenizationResponseMappingTests: VGSCollectBaseTestCase {
  var collector: VGSCollect!
  var cardNumberTextField: VGSCardTextField! = VGSCardTextField(frame: .zero)
  var expDateTextField: VGSExpDateTextField! = VGSExpDateTextField(frame: .zero)
  var cvcTextField: VGSCVCTextField! = VGSCVCTextField(frame: .zero)

  enum TestFlow {
    case defaultConfiguration

    var jsonFileName: String {
      return "VGSTokenizationTestJSON_" + jsonFileNameSuffix
    }

    var jsonFileNameSuffix: String {
      switch self {
      case .defaultConfiguration:
        return "DefaultConfig"
      }
    }
  }

  struct TextFieldTestData {
    let fieldName: String
    let inputValue: String
    let storage: String
    let format: String
    let isSerializationEnabled: Bool
    var outputFormat: VGSCardExpDateFormat?

    init?(json: JsonData) {
      guard let fieldName = json["field_name"] as? String,
            let inputValue = json["value"] as? String,
            let storage = json["storage"] as? String,
            let format = json["format"] as? String else  {
              return nil
            }

      self.fieldName = fieldName
      self.inputValue = inputValue
      self.storage = storage
      self.format = format
      self.isSerializationEnabled = json["is_serialization_enabled"] as? Bool ?? false
      if let outputFormatName = json["outputFormat"] as? String {
        self.outputFormat = VGSCardExpDateFormat(name: outputFormatName)
      }
    }
  }

  struct TestJSONData {
    let textFieldTestData: [TextFieldTestData]
    let tokenizedResponseBody: JsonData
    let expectedMappedResponse: JsonData

    init?(json: JsonData) {
      guard let inputData = json["input_data"] as? [JsonData],
            let tokenizedResponse = json["tokenized_response"] as? JsonData,
            let expectedMappedResponse = json["expected_mapped_response"] as? JsonData else {
        return nil
      }

      self.textFieldTestData = inputData.compactMap({return TextFieldTestData(json: $0)})
      self.tokenizedResponseBody = tokenizedResponse
      self.expectedMappedResponse = expectedMappedResponse
    }
  }

  static func provideTokenizationTestData(for fileName: String) -> [VGSTokenizationResponseMappingTests.TestJSONData] {
    guard let rootTestJSON = JsonData(jsonFileName: fileName) else {
      XCTFail("cannot build data for file \(fileName)")
      return []
    }

    guard let testDataJSONArray = rootTestJSON["test_data"] as? [JsonData] else {
      XCTFail("test_data JSON array not found in \(fileName)")
      return []
    }

    var testData = [VGSTokenizationResponseMappingTests.TestJSONData]()

    for json in testDataJSONArray {
      if let testItem = VGSTokenizationResponseMappingTests.TestJSONData(json: json) {
        testData.append(testItem)
      } else {
        XCTFail("Cannot build test data for json: \(json)")
      }
    }
    return testData
  }

  // MARK: - Override

  override func setUp() {
      super.setUp()
      collector = VGSCollect(id: "any")
  }

  override func tearDown() {
      collector = nil
      cardNumberTextField = nil
      expDateTextField = nil
      cvcTextField = nil
  }

  // MARK: - Tests

  /// Tests tokenization response mapping.
  func testTokenizationResponseMapping() {
    let fileName = TestFlow.defaultConfiguration.jsonFileName
    let testData = VGSTokenizationResponseMappingTests.provideTokenizationTestData(for: fileName)

    print(testData)

    for index in 0...1 {
      let test = testData[index]
      let tokenizedResponse = test.tokenizedResponseBody
      let expectedJSON = test.expectedMappedResponse

      for textFieldData in test.textFieldTestData {
        let fieldName = textFieldData.fieldName
        switch fieldName {
        case "card_number":
          var config = VGSCardNumberTokenizationConfiguration(collector: collector, fieldName: fieldName)
          config.tokenizationParameters.format = textFieldData.storage
          config.tokenizationParameters.format = textFieldData.format
          cardNumberTextField.configuration = config
          cardNumberTextField.setText(textFieldData.inputValue)
        case "exp_date":
          var config = VGSExpDateTokenizationConfiguration(collector: collector, fieldName: fieldName)

          if textFieldData.isSerializationEnabled {
            config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "month", yearFieldName: "year")]
          } else {
            config.serializers = []
          }
          config.outputDateFormat = textFieldData.outputFormat
          config.tokenizationParameters.format = textFieldData.storage
          config.tokenizationParameters.format = textFieldData.format
          config.formatPattern = "##/##"
          expDateTextField.configuration = config
          expDateTextField.setText(textFieldData.inputValue)
        case "cvc":
          var config = VGSCVCTokenizationConfiguration(collector: collector, fieldName: fieldName)
          config.tokenizationParameters.format = textFieldData.storage
          config.tokenizationParameters.format = textFieldData.format
          cvcTextField.configuration = config
          cvcTextField.setText(textFieldData.inputValue)
        default:
          break
        }
      }

      collector.registerTextFields(textField: [
        cardNumberTextField,
        expDateTextField,
        cvcTextField
      ])

      let data = jsonToData(json: tokenizedResponse)
      let actualJSON = collector.buildTokenizationResponseBody(data, tokenizedFields: collector.storage.tokenizableTextFields, notTokenizedFields: [])

      guard let json = actualJSON else {
        XCTFail("No json!")
        return
      }

      XCTAssertTrue(json == expectedJSON, "Tokenization data mapping error:\n - Index: \(index)\n - Actual JSON: \(actualJSON)\n - Expected: \(expectedJSON)")
    }
  }

  func jsonToData(json: Any) -> Data? {
      do {
          return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
      } catch let myJSONError {
          print(myJSONError)
      }
      return nil
  }
}
