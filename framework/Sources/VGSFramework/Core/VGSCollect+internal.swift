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
    
    /// Validate textfields input data
    func validate(_ input: [VGSTextField]) -> Error? {
        var isRequiredErrorFields = [String]()
        var isRequiredValidOnlyErrorFields = [String]()
        
        for textField in input {
            if textField.isRequired, textField.text.isNilOrEmpty {
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
    
    func mapFieldsDataToDictionary(_ body: [String: Any]) -> [String: Any] {
        var resultDict = [String: Any]()
        for (key, value) in body {
            let mappedDict = mapStringKVOToDictionary(key: key, value: value, separator: ".")
            let newDict = deepMerge(resultDict, mappedDict)
            resultDict = newDict
        }
        return resultDict
    }
}

