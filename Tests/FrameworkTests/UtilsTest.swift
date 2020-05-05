//
//  UtilsTest.swift
//  VGSCollectSDK
//
//  Created by Dima on 10.03.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class UtilsTest: XCTestCase {
    
    func testMapStringKVOToDictionary() {
        let stringToMap = "user.data.card_number"
        let val = "any"
        let separator: String.Element = "."
        let expectedResult = [
            "user": [
                "data": [
                    "card_number": val
                ]
            ]
        ]

        let result = mapStringKVOToDictionary(key: stringToMap, value: val, separator: separator)
        XCTAssertTrue(result.jsonStringRepresentation == expectedResult.jsonStringRepresentation)
    }
    
    func testMapStringKVOToDictionaryWithExtraSeparators() {
        let stringToMap = ".user.data...card_number."
        let val = "any"
        let separator: String.Element = "."
        let expectedResult = [
           "user": [
               "data": [
                   "card_number": val
               ]
           ]
        ]
               
        let result = mapStringKVOToDictionary(key: stringToMap, value: val, separator: separator)
        XCTAssertTrue(result.jsonStringRepresentation == expectedResult.jsonStringRepresentation)
    }
    
    func testMapStringKVOToDictionaryWithNoSeparators() {
        let stringToMap = "card_number"
        let val = ["anyValue": "anyKey"]
        let separator: String.Element = "."
        let expectedResult = [
                   "card_number": val
        ]
               
        let result = mapStringKVOToDictionary(key: stringToMap, value: val, separator: separator)
        XCTAssertTrue(result.jsonStringRepresentation == expectedResult.jsonStringRepresentation)
    }
    
    func testDeepMergeWithoutSimilarKeys() {
        let d1 = [
           "user": [
               "data": [
                   "card_number": "any"
               ]
           ]
        ]
        
        let d2 = [
           "data": [
               "user": [
                   "id": "any"
               ]
           ]
        ]
        
        let expectedResult = [
           "user": [
               "data": [
                   "card_number": "any"
               ]
           ],
           "data": [
               "user": [
                   "id": "any"
               ]
           ]
        ]
        let result = deepMerge(d1, d2)
        XCTAssertTrue(expectedResult.jsonStringRepresentation == result.jsonStringRepresentation)
    }
    
    func testDeepMergeWithSimilarKeys() {
        let d1 = [
           "user": [
               "data": [
                "card_number": "any",
                "Id": "CapitalId"
               ],
               "accountNumber": 1111
           ]
        ]
        
        let d2 = [
           "user": [
               "data": [
                   "id": "anyId"
               ],
               "accountNumber": 2222
           ]
        ]
        
        let expectedResult = [
           "user": [
                "data": [
                    "card_number": "any",
                    "id": "anyId",
                    "Id": "CapitalId"
                ],
                "accountNumber": 2222
           ]
        ]
        let result = deepMerge(d1, d2)
        XCTAssertTrue(expectedResult.jsonStringRepresentation == result.jsonStringRepresentation)
    }
}
