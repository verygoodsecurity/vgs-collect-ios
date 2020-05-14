//
//  VGSCollect+network.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 09.05.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Send data
extension VGSCollect {
    /**
     Send data from VGSTextFields to your organization vault.
     
     - Parameters:
        - path: Inbound rout path for your organization vault.
        - method: HTTPMethod, default is `.post`.
        - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
        - completion: response completion block, returns `VGSResponse`.
     
     - Note:
        If there are validation errors, SDK will return `Error` in **error** case block.
    */
    public func sendRequest(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block: @escaping (VGSResponse) -> Void) {
        if let error = validateStoredInputData() {
          block(.failure(error.code, nil, nil, error))
            return
        }
        let body = mapStoredInputDataForSubmit(with: extraData)
        apiClient.sendRequest(path: path, method: method, value: body, completion: block)
    }
    
    /**
     Send data from VGSTextFields to your organization vault.
     
     - Parameters:
        - path: Inbound rout path for your organization vault.
        - method: HTTPMethod, default is `.post`.
        - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
        - completion: response completion block, returns `VGSResponse`.
     
     - Note:
        If there are validation errors, SDK will return `Error` in **error** case block.
    */
    public func sendFileRequest(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block: @escaping (VGSResponse) -> Void) {
        // check if file is exist
        guard let key = storage.files.keys.first, let value = storage.files.values.first else {
            let error = VGSError(type: .inputFileNotFound,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileNotFound,
                                                        description: "File not selected or doesn't exists",
                                                        extraInfo: [:]))
            block(.failure(error.code, nil, nil, error))
            return
        }
        // check if file converted to Data
        guard let result = value as? Data else {
            let error = VGSError(type: .inputFileTypeIsNotSupported,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported,
                                                        description: "File format is not supported. Can't convert to Data.",
                                                        extraInfo: [:]))
            
            block(.failure(error.code, nil, nil, error))
            return
        }
        // check mac file size
        if result.count >= maxFileSizeInternalLimitInBytes {
            let error = VGSError(type: .inputFileSizeExceedsTheLimit,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileSizeExceedsTheLimit,
                                                        description: "File size is too large.",
                                                        extraInfo: [
                                                            "expectedSize": maxFileSizeInternalLimitInBytes,
                                                            "fileSize": "\(result.count)", "sizeUnits": "bytes"]))
            block(.failure(error.code, nil, nil, error))
            return
        }
        // encode file
        let encodedData = result.base64EncodedString()
        if encodedData.count == 0 {
            let error = VGSError(type: .inputFileTypeIsNotSupported,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported,
                                                        description: "File format is not supported. File is empty.",
                                                        extraInfo: [:]))
          block(.failure(error.code, nil, nil, error))
            return
        }
        // make body
        let body = mapStringKVOToDictionary(key: key, value: encodedData, separator: ".")
        // senf request
        apiClient.sendRequest(path: path, method: method, value: body, completion: block)
    }
}

// MARK: - Deprecated version of submit requests
// - Send data to organization vault
extension VGSCollect {
    /**
     Send data from VGSTextFields to your organization vault.
     
     - Parameters:
        - path: Inbound rout path for your organization vault.
        - method: HTTPMethod, default is `.post`.
        - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
        - completion: response completion block, returns `JsonData` or an `Error`.
     
     - Note:
        If there are validation errors, SDK will return `VGSError` in **error** field.
    */
    @available(*, deprecated, message:"Will be removed in v1.5.0, use sendRequest(path: method: extraData: completion block:(VGSResponse))")
    public func submit(path: String, method: Alamofire.HTTPMethod = .post, extraData: [String: Any]? = nil, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        
        if let error = validateStoredInputData() {
            block(nil, error)
            return
        }

        let body = mapStoredInputDataForSubmit(with: extraData)
        apiClient.sendRequest(path: path, method: method, value: body, completion: block)
    }
    
    /**
        Send file to your organization vault. Only send one file at a time.
     
        - Parameters:
            - path: Inbound rout path for your organization vault.
            - method: HTTPMethod, default is   `.post`.
            - extraData: Any data you want to send together file , default is `nil`.
            - completion: response completion block, returns `JsonData` or an `Error`.
     
        - Note:
           If there are validation errors, SDK will return `VGSError` in **error** field.
    */
    @available(*, deprecated, message:"This will be removed in v1.5.0, use to a sendFileRequest(path: method: extraData: completion block:(VGSResponse))")
    public func submitFile(path: String, method: Alamofire.HTTPMethod = .post, extraData: [String: Any]? = nil, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {

         guard let key = storage.files.keys.first, let value = storage.files.values.first else {
            block(nil, VGSError(type: .inputFileNotFound, userInfo: VGSErrorInfo(key: VGSSDKErrorFileNotFound, description: "File not selected or doesn't exists", extraInfo: [:])))
            
            return
        }

        let result: Data
 
        if let data = value as? Data {
            result = data
        } else {
            // swiftlint:disable:next line_length
            block(nil, VGSError(type: .inputFileTypeIsNotSupported, userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported, description: "File format is not supported. Can't convert to Data.", extraInfo: [:])))
            return
        }
        
        if result.count >= maxFileSizeInternalLimitInBytes {
            // swiftlint:disable:next line_length
            block(nil, VGSError(type: .inputFileSizeExceedsTheLimit, userInfo: VGSErrorInfo(key: VGSSDKErrorFileSizeExceedsTheLimit, description: "File size is too large.", extraInfo: ["expectedSize": maxFileSizeInternalLimitInBytes, "fileSize": "\(result.count)", "sizeUnits": "bytes"])))
            return
        }
        
        let encodedData = result.base64EncodedString()

        if encodedData.count == 0 {
            // swiftlint:disable:next line_length
            block(nil, VGSError(type: .inputFileTypeIsNotSupported, userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported, description: "File format is not supported. File is empty.", extraInfo: [:])))
            return
        }
        
        var body = mapStringKVOToDictionary(key: key, value: encodedData, separator: ".")

        if let customData = extraData, customData.count != 0 {
          // NOTE: If there are similar keys on same level, body values will override custom values values for that keys
          body = deepMerge(customData, body)
        }
        
         apiClient.sendRequest(path: path, method: method, value: body, completion: block)
    }
}
