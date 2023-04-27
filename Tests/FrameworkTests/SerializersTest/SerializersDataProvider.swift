//
//  SerializersDataProvider.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK

/// Define the methods required to parse test JSON data
protocol TestJSONDataProtocol {
    init?(json: JsonData)
}

/// Class with the methods required to read and parse JSON files for testing
final class SerializersDataProvider {
    
    /// Method that reads and parse `JSON` file with data for testing. It define an abstract
    /// parameter that must implement the `TestJSONDataProtocol`
    ///
    /// - Parameters:
    ///   - fileName: `String` with the name of the `JSON` file to read the data from.
    ///   - rootName: `String` with the name of the root node of the `JSON` file, by defaul it is defined as `test_data`
    static func provideTestData<T: TestJSONDataProtocol>(for fileName: String, rootNodeName: String = "test_data") -> [T] {
        /// Read json data from file
        guard let rootTestJSON = JsonData(jsonFileName: fileName) else {
            XCTFail("Cannot build data for file \(fileName)")
            return []
        }
        
        /// Get root node
        guard let testDataJSONArray = rootTestJSON[rootNodeName] as? [JsonData] else {
            XCTFail("\(rootNodeName) JSON array not found in \(fileName)")
            return []
        }
        
        /// Parse test data
        var testData = [T]()
        for json in testDataJSONArray {
            if let testItem = T(json: json) {
                testData.append(testItem)
            } else {
                XCTFail("Cannot build test data for JSON: \(json)")
            }
        }
        return testData
    }
}
