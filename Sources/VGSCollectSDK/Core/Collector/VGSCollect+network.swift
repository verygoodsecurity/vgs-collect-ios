//
//  VGSCollect+network.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 09.05.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

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
        Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
    */
    public func sendData(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block: @escaping (VGSResponse) -> Void) {
        if let error = validateStoredInputData() {
          block(.failure(error.code, nil, nil, error))
            return
        }
        let body = mapStoredInputDataForSubmit(with: extraData)
        apiClient.sendRequest(path: path, method: method, value: body, completion: block)
    }
    
    /**
     Send file to your organization vault. Only send one file at a time.
     
     - Parameters:
        - path: Inbound rout path for your organization vault.
        - method: HTTPMethod, default is `.post`.
        - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
        - completion: response completion block, returns `VGSResponse`.
     
     - Note:
        Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
    */
    public func sendFile(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block: @escaping (VGSResponse) -> Void) {
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
