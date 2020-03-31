//
//  VGSCollect+internal.swift
//  VGSFramework
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
    
    /// Validate stored textfields input data
    func validateStoredInputData() -> Error? {
        return validate(storage.elements)
    }
    
    /// Validate specific textfields input data
    func validate(_ input: [VGSTextField]) -> Error? {
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
        
        if isRequiredErrorFields.count > 0 {
            return VGSError(type: .inputDataRequired, userInfo: VGSErrorInfo(key: VGSSDKErrorInputDataRequired, description: "Input data can't be nil or empty", extraInfo: ["fields": isRequiredErrorFields]))
        } else if isRequiredValidOnlyErrorFields.count > 0 {
            return VGSError(type: .inputDataRequiredValidOnly, userInfo: VGSErrorInfo(key: VGSSDKErrorInputDataRequiredValid, description: "Input data should be valid only", extraInfo: ["fields": isRequiredValidOnlyErrorFields]))
        }
        return nil
    }
    
    /// Turns textfields data saved in Storage and extra data in format ready to submit
    func mapStoredInputDataForSubmit(with extraData: [String: Any]? = nil) -> [String: Any] {

        let textFieldsData: BodyData = storage.elements.reduce(into: BodyData()) { (dict, element) in
            dict[element.fieldName] = element.textField.getSecureRawText
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
        storage.elements.forEach { textField in
            textField.focusStatus = false
        }
        // set focus for textField
        textField.focusStatus = true

        if textField.fieldType == .cardNumber {
            // change cvc format pattern based on card brand
            if let cvcField = storage.elements.filter({ $0.fieldType == .cvc }).first {
                cvcField.textField.formatPattern = textField.cvcFormatPatternForCardType
                cvcField.validationModel.pattern = textField.cvcRegexForCardType
            }
        }
        
        // call observers ONLY after all internal updates done
        observeStates?(storage.elements)
        observeFieldState?(textField)
    }
}
