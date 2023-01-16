//
//  VGSTokenizationConfigurationsTest.swift
//  FrameworkTests
//

import Foundation

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSTokenizationConfigurationsTest: VGSCollectBaseTestCase {
  
  var textField: VGSTextField!
  var collector = VGSCollect(id: "testVaultId")

  
  override func tearDown() {
      super.tearDown()
      textField = nil
      collector.unregisterAllFiles()
  }
  
  func testTokenizationConfiguration() {
    // set configuration
    let configuration = VGSTokenizationConfiguration(collector: collector, fieldName: "fieldName")
    textField = VGSTextField()
    textField.configuration = configuration

    // Test field type is correct
    XCTAssertTrue(textField.fieldType == configuration.type, "Error: wrong field type: \(textField.fieldType). Should be: \(configuration.type)")
    
    // Test tokenization parameters
    guard let tokenizationConfiguration = textField.configuration as? VGSTokenizationConfiguration else {
      XCTFail("Wrong configuration type, should be `VGSTokenizationConfiguration`")
      return
    }
    let defaultTokenizationParams = VGSTokenizationParameters()
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.format == defaultTokenizationParams.format, "Error: wrong tokenization format!")
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.storage == defaultTokenizationParams.storage, "Error: wrong tokenization storage!")
    
    // Test custom tokenization parameters
    var customTokenizationParams = VGSTokenizationParameters()
    customTokenizationParams.storage = VGSVaultStorageType.VOLATILE.rawValue
    customTokenizationParams.format = VGSVaultAliasFormat.FPE_T_FOUR.rawValue
    configuration.tokenizationParameters = customTokenizationParams
    textField.configuration = configuration
    
    guard let customTokenizationConfiguration = textField.configuration as? VGSTokenizationConfiguration else {
      XCTFail("Wrong configuration type, should be `VGSTokenizationConfiguration`")
      return
    }
    XCTAssertTrue(customTokenizationConfiguration.tokenizationParameters.format == customTokenizationParams.format, "Error: wrong custom tokenization format!")
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.storage == customTokenizationParams.storage, "Error: wrong custom tokenization storage!")
  }
  
  func testCVCTokenizationConfiguration() {
    // set configuration
    let configuration = VGSCVCTokenizationConfiguration(collector: collector, fieldName: "fieldName")
    textField = VGSCVCTextField()
    textField.configuration = configuration
    
    // Test field type is correct
    XCTAssertTrue(textField.fieldType == configuration.type, "Error: wrong field type: \(textField.fieldType). Should be: \(configuration.type)")
    
    // Test tokenization parameters
    guard let tokenizationConfiguration = textField.configuration as? VGSCVCTokenizationConfiguration else {
      XCTFail("Wrong configuration type, should be `VGSCVCTokenizationConfiguration`")
      return
    }
    let defaultTokenizationParams = VGSCVCTokenizationParameters()
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.format == defaultTokenizationParams.format, "Error: wrong tokenization format!")
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.storage == defaultTokenizationParams.storage, "Error: wrong tokenization storage!")
  }
  
  func testExpDateTokenizationConfiguration() {
    // set configuration
    let configuration = VGSExpDateTokenizationConfiguration(collector: collector, fieldName: "fieldName")
    textField = VGSExpDateTextField()
    textField.configuration = configuration
    
    // Test field type is correct
    XCTAssertTrue(textField.fieldType == configuration.type, "Error: wrong field type: \(textField.fieldType). Should be: \(configuration.type)")
    
    // Test tokenization parameters
    guard let tokenizationConfiguration = textField.configuration as? VGSExpDateTokenizationConfiguration else {
      XCTFail("Wrong configuration type, should be `VGSExpDateTokenizationConfiguration`")
      return
    }
    let defaultTokenizationParams = VGSExpDateTokenizationParameters()
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.format == defaultTokenizationParams.format, "Error: wrong tokenization format!")
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.storage == defaultTokenizationParams.storage, "Error: wrong tokenization storage!")
  }
  
  func testCardNumberTokenizationConfiguration() {
    // set configuration
    let configuration = VGSCardNumberTokenizationConfiguration(collector: collector, fieldName: "fieldName")
    textField = VGSCardTextField()
    textField.configuration = configuration
    
    // Test field type is correct
    XCTAssertTrue(textField.fieldType == configuration.type, "Error: wrong field type: \(textField.fieldType). Should be: \(configuration.type)")
    
    // Test tokenization parameters
    guard let tokenizationConfiguration = textField.configuration as? VGSCardNumberTokenizationConfiguration else {
      XCTFail("Wrong configuration type, should be `VGSCardNumberTokenizationConfiguration`")
      return
    }
    let defaultTokenizationParams = VGSCardNumberTokenizationParameters()
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.format == defaultTokenizationParams.format, "Error: wrong tokenization format!")
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.storage == defaultTokenizationParams.storage, "Error: wrong tokenization storage!")
  }
  
  func testCardHolderNameTokenizationConfiguration() {
    // set configuration
    let configuration = VGSCardHolderNameTokenizationConfiguration(collector: collector, fieldName: "fieldName")
    textField = VGSTextField()
    textField.configuration = configuration
    
    // Test field type is correct
    XCTAssertTrue(textField.fieldType == configuration.type, "Error: wrong field type: \(textField.fieldType). Should be: \(configuration.type)")
    
    // Test tokenization parameters
    guard let tokenizationConfiguration = textField.configuration as? VGSCardHolderNameTokenizationConfiguration else {
      XCTFail("Wrong configuration type, should be `VGSCardHolderNameTokenizationConfiguration`")
      return
    }
    let defaultTokenizationParams = VGSCardHolderNameTokenizationParameters()
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.format == defaultTokenizationParams.format, "Error: wrong tokenization format!")
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.storage == defaultTokenizationParams.storage, "Error: wrong tokenization storage!")
  }
  
  func testSSNTokenizationConfiguration() {
    // set configuration
    let configuration = VGSSSNTokenizationConfiguration(collector: collector, fieldName: "fieldName")
    textField = VGSTextField()
    textField.configuration = configuration
    
    // Test field type is correct
    XCTAssertTrue(textField.fieldType == configuration.type, "Error: wrong field type: \(textField.fieldType). Should be: \(configuration.type)")
    
    // Test tokenization parameters
    guard let tokenizationConfiguration = textField.configuration as? VGSSSNTokenizationConfiguration else {
      XCTFail("Wrong configuration type, should be `VGSSSNTokenizationConfiguration`")
      return
    }
    let defaultTokenizationParams = VGSSSNTokenizationParameters()
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.format == defaultTokenizationParams.format, "Error: wrong tokenization format!")
    XCTAssertTrue(tokenizationConfiguration.tokenizationParameters.storage == defaultTokenizationParams.storage, "Error: wrong tokenization storage!")
  }
}
