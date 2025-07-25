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
@MainActor 
class VGSExpDateSeparateSerializerTests: VGSCollectBaseTestCase {
    
    // MARK: - Properties
    private var collector: VGSCollect!
    private var textField: VGSExpDateTextField!
    
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
            return "VGSExpDateSerialization_" + jsonFileNameSuffix
        }
        
        /// JSON file name
        var jsonFileNameSuffix: String {
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
            self.yearFieldName = json["yearFieldName"] as? String ?? ""
            self.submitJSON = submitJSON
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
        /// Get JSON test data
        let fileName = TestFlow.defaultConfig.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
        config.formatPattern = "##/##"
        
        /// Run test for each case from JSON
        for test in testData {
            /// Prepare serializer
            config.serializers = [
                VGSExpDateSeparateSerializer(
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
            XCTAssertTrue(submitJSON == test.submitJSON,
                          "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
        }
    }
    
    /// Test custom exp date configuration.
    func testSplitExpDateSerializerWithCustomConfig() {
        /// Get JSON test data
        let fileName = TestFlow.customConfig.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSExpDateConfiguration(collector: collector, fieldName: "card.expDate")
        config.formatPattern = "##/##"
        config.inputDateFormat = .shortYear
        config.outputDateFormat = .longYear
        config.divider = "-/-"
        
        /// Run test for each case from JSON
        for test in testData {
            /// Prepare serializer
            config.serializers = [
                VGSExpDateSeparateSerializer(
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
            XCTAssertTrue(submitJSON == test.submitJSON,
                          "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
        }
    }
    
    /// Test custom exp date output format.
    func testSplitCustomExpDateOutputSerializerWithCustomConfig() {
        /// Get JSON test data
        let fileName = TestFlow.customExpDateOutputConfig.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSExpDateConfiguration(collector: collector, fieldName: "card.expDate")
        config.formatPattern = "####/##"
        config.inputDateFormat = .longYearThenMonth
        config.outputDateFormat = .shortYearThenMonth
        config.divider = "-/-"
        
        /// Run test for each case from JSON
        for test in testData {
            /// Prepare serializer
            config.serializers = [
                VGSExpDateSeparateSerializer(
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
            XCTAssertTrue(submitJSON == test.submitJSON,
                          "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
        }
    }
    
    /// Test map with array merge.
    func testSplitExpDateSerializersMapWithArray() {
        /// Get JSON test data
        let fileName = TestFlow.mapWithArrayMerge.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
        config.formatPattern = "##/##"
        
        /// Setup extra data
        let extraData = ["card_data": [["user_id": "123"]]]
        
        /// Run test for each case from JSON
        for test in testData {
            /// Prepare serializer
            config.serializers = [
                VGSExpDateSeparateSerializer(
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
            XCTAssertTrue(submitJSON == test.submitJSON,
                          "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
        }
    }
    
    /// Test map with array overwrite.
    func testSplitExpDateSerializersMapWithArrayOverwrite() {
        /// Get JSON test data
        let fileName = TestFlow.mapWithArrayOverwrite.jsonFileName
        let testData: [TestJSONData] = SerializersDataProvider.provideTestData(for: fileName)
        
        /// Prepare configuration
        let config = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
        config.formatPattern = "##/##"
        
        /// Setup extra data
        let extraData = ["card_data": [["month": "3", "year": "2033"]]]
        
        /// Run test for each case from JSON
        for test in testData {
            /// Prepare serializer
            config.serializers = [
                VGSExpDateSeparateSerializer(
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
            XCTAssertTrue(submitJSON == test.submitJSON,
                          "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
        }
    }
}
