//
//  VGSDateSeparateSerializerTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK

class VGSDateSeparateSerializerTests: VGSCollectBaseTestCase {
    
    // MARK: - Properties
    private var collector: VGSCollect!
    private var textField: VGSDateTextField!
    
    // MARK: - Inner objects
    /// Define the file names with JSON data for testing
    private enum TestFlow {
        case defaultConfig
        case customConfig
        case customExpDateOutputConfig
        case mapWithArrayOverwrite
        case mapWithArrayMerge
        
        /// Name of the JSON file
        var jsonFileName: String {
            return "VGSDateSerialization_" + jsonFileNameSuffix
        }
        
        /// JSON file name
        private var jsonFileNameSuffix: String {
            switch self {
            case .defaultConfig:
                return "DefaultConfig"
            case .customConfig:
                return "CustomConfig"
            case .customExpDateOutputConfig:
                return "CustomExpDateOutputConfig"
            case .mapWithArrayOverwrite:
                return "MapWithArrayOverwrite"
            case .mapWithArrayMerge:
                return "MapWithArrayMerge"
            }
        }
    }
    
    /// Store the JSON data for testing
    private struct TestJSONData: TestJSONDataProtocol {
        
        // MARK: - Properties
        let fieldValue: String
        let monthFieldName: String
        let dayFieldName: String
        let yearFieldName: String
        let submitJSON: JsonData
        
        /// Initializer
        init?(json: JsonData) {
            guard let submitJSON = json["expectedResult"] as? JsonData else {
                XCTFail("Cannot parse test data.")
                return nil
            }
            self.fieldValue = json["fieldValue"] as? String ?? ""
            self.monthFieldName = json["monthFieldName"] as? String ?? ""
            self.dayFieldName = json["dayFieldName"] as? String ?? ""
            self.yearFieldName = json["yearFieldName"] as? String ?? ""
            self.submitJSON = submitJSON
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
        let config = VGSDateConfiguration(collector: collector, fieldName: "date")
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
            /// Update configuration
            textField.configuration = config
            /// Setup test value
            textField.setText(test.fieldValue)
            /// Get JSON from collector using serializer
            let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSON, extraData: nil)
            /// Assert: Test JSON content should be equals to the JSON from the collector
            XCTAssertTrue(NSDictionary(dictionary: submitJSON).isEqual(to: test.submitJSON))
        }
    }
    
    /// Test custom configuration
    func testSplitDateSerializerWithCustomConfig() {
        /// Get JSON test data
        let fileName = TestFlow.customConfig.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "card.date")
        config.formatPattern = VGSDateFormat.default.formatPattern
        config.inputDateFormat = .yyyymmdd
        config.outputDateFormat = .ddmmyyyy
        config.divider = "-/-"
        
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
            /// Update configuration
            textField.configuration = config
            /// Setup test value
            textField.setText(test.fieldValue)
            /// Get JSON from collector using serializer
            let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSON, extraData: nil)
            /// Assert: Test JSON content should be equals to the JSON from the collector
            XCTAssertTrue(NSDictionary(dictionary: submitJSON).isEqual(to: test.submitJSON))
        }
    }
    
    /// Test custom output format.
    func testSplitCustomDateOutputSerializerWithCustomConfig() {
        /// Get JSON test data
        let fileName = TestFlow.customExpDateOutputConfig.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "card.date")
        config.formatPattern = VGSDateFormat.default.formatPattern
        config.inputDateFormat = .yyyymmdd
        config.outputDateFormat = .ddmmyyyy
        config.divider = "-/-"
        
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
            /// Update configuration
            textField.configuration = config
            /// Setup test value
            textField.setText(test.fieldValue)
            /// Get JSON from collector using serializer
            let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSON, extraData: nil)
            /// Assert: Test JSON content should be equals to the JSON from the collector
            XCTAssertTrue(NSDictionary(dictionary: submitJSON).isEqual(to: test.submitJSON))
        }
    }
    
    /// Test map with array merge.
    func testSplitExpDateSerializersMapWithArray() {
        /// Get JSON test data
        let fileName = TestFlow.mapWithArrayMerge.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "date")
        config.formatPattern = VGSDateFormat.default.formatPattern
        config.inputDateFormat = .mmddyyyy
        config.outputDateFormat = .mmddyyyy
        config.divider = "/"
        
        /// Setup extra data
        let extraData = ["card_data": [["user_id": "123"]]]
        
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
            /// Update configuration
            textField.configuration = config
            /// Setup test value
            textField.setText(test.fieldValue)
            /// Get JSON from collector using serializer
            let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSONWithArrayMerge, extraData: extraData)
            /// Assert: Test JSON content should be equals to the JSON from the collector
            XCTAssertTrue(NSDictionary(dictionary: submitJSON).isEqual(to: test.submitJSON))
        }
    }
    
    /// Test map with array overwrite.
    func testSplitExpDateSerializersMapWithArrayOverwrite() {
        /// Get JSON test data
        let fileName = TestFlow.mapWithArrayOverwrite.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSDateConfiguration(collector: collector, fieldName: "date")
        config.formatPattern = VGSDateFormat.default.formatPattern
        config.inputDateFormat = .mmddyyyy
        config.outputDateFormat = .mmddyyyy
        config.divider = "/"
        
        /// Setup extra data
        let extraData = ["card_data": [["month": "3", "year": "2033"]]]
        
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
            /// Update configuration
            textField.configuration = config
            /// Setup test value
            textField.setText(test.fieldValue)
            /// Get JSON from collector using serializer
            let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSONWithArrayOverwrite, extraData: extraData)
            /// Assert: Test JSON content should be equals to the JSON from the collector
            XCTAssertTrue(NSDictionary(dictionary: submitJSON).isEqual(to: test.submitJSON))
        }
    }
}
