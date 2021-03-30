//
//  VGSCollect+internal.swift
//  VGSCollectSDK
//
//  Created by Dima on 10.03.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal extension VGSCollect {
  
    /// Validate tenant id
    class func tenantIDValid(_ tenantId: String) -> Bool {
        return tenantId.isAlphaNumeric
    }
    
    /// Validate data region id
    class func regionValid(_ region: String) -> Bool {
      return !region.isEmpty && region.range(of: ".*[^a-zA-Z0-9-].*", options: .regularExpression) == nil
    }
  
    /// Validate string representing environment and data region
    class func regionalEnironmentStringValid(_ enironment: String) -> Bool {
      return !enironment.isEmpty && NSPredicate(format: "SELF MATCHES %@", "^(live|sandbox|LIVE|SANDBOX)+((-)+([a-zA-Z0-9]+)|)+\\d*$").evaluate(with: enironment)
    }
  
    /// Validate stored textfields input data
    func validateStoredInputData() -> VGSError? {
        return validate(storage.textFields)
    }
    
    /// Validate specific textfields input data
    func validate(_ input: [VGSTextField]) -> VGSError? {
        var isRequiredErrorFields = [String]()
        var isRequiredValidOnlyErrorFields = [String]()
        
        for textField in input {
            if textField.isRequired, textField.textField.getSecureRawText.isNilOrEmpty {
                isRequiredErrorFields.append(textField.fieldName)
            }
            if textField.isRequiredValidOnly && !textField.state.isValid {
                isRequiredValidOnlyErrorFields.append(textField.fieldName)
            }
        }
        
        var errorFields = [String: [String]]()
        if isRequiredErrorFields.count > 0 {
          
            let eventText = "NOT VALID FIELDS CONTENT!!!. Next fields configuration set as **isRequired** but fields' content is **nil** or **empty**: \(isRequiredErrorFields)"
            let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)
          
            errorFields[VGSSDKErrorInputDataRequired] = isRequiredErrorFields
        }
        if isRequiredValidOnlyErrorFields.count > 0 {
            let eventText = "NOT VALID FIELDS CONTENT!!!. Next fields configuration set as **sRequiredValidOnly** but fields' content didn't pass validation: \(isRequiredValidOnlyErrorFields)"
            let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)
            errorFields[VGSSDKErrorInputDataRequiredValid] = isRequiredValidOnlyErrorFields
        }
        
        if errorFields.count > 0 {
            // swiftlint: disable superfluous_disable_command
            return VGSError(type: .inputDataIsNotValid, userInfo: VGSErrorInfo(key: VGSSDKErrorInputDataIsNotValid, description: "Input data is not valid", extraInfo: errorFields))
            // swiftlint: enable superfluous_disable_command
        }
        return nil
    }
    
    /// Turns textfields data saved in Storage and extra data in format ready to send
    func mapStoredInputDataForSubmit(with extraData: [String: Any]? = nil) -> [String: Any] {

        let textFieldsData: BodyData = storage.textFields.reduce(into: BodyData()) { (dict, element) in
          let output = element.getOutputText()
          
          /// Check if any serialization should be done before data will be send
          if let serialazable = element.configuration as? VGSFormatSerializableProtocol, serialazable.shouldSerialize {
            let result = serialazable.serialize(output ?? "")
            dict = deepMerge(dict, result)
          } else {
            dict[element.fieldName] = output
          }
        }

        var body = mapInputFieldsDataToDictionary(textFieldsData)

        if let customData = extraData, customData.count != 0 {
           // NOTE: If there are similar keys on same level, body values will override customvalues values for that keys
           body = deepMerge(customData, body)
        }

        return body
    }
    
    /// Maps textfield string key with separator  into nesting Dictionary
    func mapInputFieldsDataToDictionary(_ body: [String: Any]) -> [String: Any] {
        var resultDict = [String: Any]()
        for (key, value) in body {
            let mappedDict = mapStringKVOToDictionary(key: key, value: value, separator: ".")
            let newDict = deepMerge(resultDict, mappedDict)
            resultDict = newDict
        }
        return resultDict
    }
    
    /// Update fields state
    func updateStatus(for textField: VGSTextField) {
        // reset all focus status
        storage.textFields.forEach { textField in
            textField.focusStatus = false
        }
        // set focus for textField
        textField.focusStatus = true
        
        // call observers ONLY after all internal updates done
        observeStates?(storage.textFields)
        observeFieldState?(textField)
    }
  
    /// Generates API String with environment and data region.
    class func generateRegionalEnvironmentString(_ environment: Environment, region: String?) -> String {
      var environmentString = environment.rawValue
      if let region = region, !region.isEmpty {
          if !Self.regionValid(region) {
            let eventText = "VGSCollectSDK CONFIGURATION ERROR: REGION STRING IS NOT VALID!!! region: \(region)"
            let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)
            
            assert(Self.regionValid(region), "❗VGSCollectSDK CONFIGURATION ERROR:: REGION IS NOT VALID!!!")
          }
          environmentString += "-" + region
      }
      return environmentString
    }
}

// MARK: - Fields registration
internal extension VGSCollect {
  func registerTextFields(textField objects: [VGSTextField]) {
      objects.forEach { [weak self] tf in
          self?.storage.addTextField(tf)
      }
  }
  
  func unregisterTextFields(textField objects: [VGSTextField]) {
      objects.forEach { [weak self] tf in
          self?.storage.removeTextField(tf)
      }
  }

  func unregisterAllTextFields() {
      self.storage.removeAllTextFields()
  }
  
  func unregisterAllFiles() {
      self.storage.removeFiles()
  }
}
