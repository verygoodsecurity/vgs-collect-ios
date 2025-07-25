//
//  VGSDateTokenizationSerializerTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK
@MainActor
class VGSDateTokenizationSerializerTests: VGSCollectBaseTestCase {
    
    // MARK: - Properties
    private var collector: VGSCollect!
    private var textField: VGSDateTextField!
    
    // MARK: - Inner objects
    /// Define the file names with JSON data for testing
    private enum TestFlow {
        case defaultConfig
        
        /// Name of the JSON file
        var jsonFileName: String {
            return "VGSDateTokenizationSerialization_" + jsonFileNameSuffix
        }
        
        /// JSON file name
        private var jsonFileNameSuffix: String {
            switch self {
            case .defaultConfig:
                return "DefaultConfig"
            }
        }
    }
    
    /// Store the JSON data for testing
    @MainActor
    private struct TestJSONData: TestJSONDataProtocol {
        
        // MARK: - Properties
        let fieldValue: String
        let monthFieldName: String
        let dayFieldName: String
        let yearFieldName: String
        let submitJSON: JsonData
        let outputFormat: VGSDateFormat
        let comment: String
        let tokenizedPayloads: [JsonData]
        
        /// Initializer
        init?(json: JsonData) {
            guard let submitJSON = json["expectedResult"] as? JsonData else {
                XCTFail("Cannot parse test data.")
                return nil
            }
            guard let formatName = json["outputFormat"] as? String,
                  let format = VGSDateFormat(name: formatName) else {
                XCTFail("Cannot parse output format from test json")
                return nil
            }
            self.fieldValue = json["fieldValue"] as? String ?? ""
            self.monthFieldName = json["monthFieldName"] as? String ?? ""
            self.dayFieldName = json["dayFieldName"] as? String ?? ""
            self.yearFieldName = json["yearFieldName"] as? String ?? ""
            self.submitJSON = submitJSON
            self.outputFormat = format
            self.comment = json["comment"] as? String ?? ""
            guard let tokenizedPayloads  = submitJSON["data"] as? [JsonData] else {
                XCTFail("Invalid payload")
                return nil
            }
            self.tokenizedPayloads = tokenizedPayloads
        }
    }
    
    // MARK: - Overrides
    override func setUp() {
        super.setUp()
        
        collector = VGSCollect(id: "any")
        textField = VGSDateTextField()
    }
    
    override func tearDown() {
        collector = nil
        textField = nil
    }
    
    // MARK: - Tests
    /// Test default configuration
    func testSplitDateSerializerWithDefaultConfig() {
        /// Get JSON test data
        let fileName = TestFlow.defaultConfig.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSDateTokenizationConfiguration(collector: collector, fieldName: "date")
        config.inputDateFormat = VGSDateFormat.default
        config.formatPattern = VGSDateFormat.default.formatPattern
        
        /// Run test for each case from JSON
        for test in testData {
            /// Prepare serializer
            config.serializers = [
                VGSDateSeparateSerializer(
                    dayFieldName: test.dayFieldName,
                    monthFieldName: test.monthFieldName,
                    yearFieldName: test.yearFieldName
                )
            ]
            config.outputDateFormat = test.outputFormat
            /// Update configuration
            textField.configuration = config
            /// Setup test value
            textField.setText(test.fieldValue)
            /// Get JSON from collector using serializer
            let submitJSON = collector.mapFieldsToTokenizationRequestBodyJSON(collector.textFields)
            
            /// Get payloads
            guard let tokenizedPayloads = submitJSON["data"] as? [JsonData] else {
                XCTFail("Cannot find tokenized data array.")
                return
            }
            var matchedPayloads = 0
            /// mapFieldsToTokenizationRequestBodyJSON can produce array of tokenized data in different
            /// order. So we need to iterate through payloads and check them one by one to get 3 matches
            /// (one is for month, one for day and another one for year).
            for payload in tokenizedPayloads {
                for expectedPayload in test.tokenizedPayloads where payload == expectedPayload {
                    matchedPayloads += 1
                }
            }
            
            /// Assert: Should be at least 3 matches of payloads
            XCTAssertEqual(matchedPayloads, 3)
        }
    }
}
