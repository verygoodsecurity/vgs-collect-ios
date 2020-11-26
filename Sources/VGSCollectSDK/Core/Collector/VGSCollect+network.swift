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
      
        /// content analytics
        var content: [String] = ["textField"]
        if !(extraData?.isEmpty ?? true) {
          content.append("custom_data")
        }
        if !(customHeaders?.isEmpty ?? true) {
          content.append("custom_header")
        }
        if let error = validateStoredInputData() {
          VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails, type: .beforeSubmit, status: .failed, extraData: [ "statusCode": error.code, "content": content])
          block(.failure(error.code, nil, nil, error))
            return
        }
        let body = mapStoredInputDataForSubmit(with: extraData)
        VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails, type: .beforeSubmit, status: .success, extraData: [ "statusCode": 200, "content": content])
      
        // send request
        apiClient.sendRequest(path: path, method: method, value: body) { [weak self](response ) in
          
          // Analytics
          if let strongSelf = self {
            switch response {
            case .success(let code, _, _):
              VGSAnalyticsClient.shared.trackFormEvent(strongSelf.formAnalyticsDetails, type: .submit, extraData: ["statusCode": code, "content": content])
            case .failure(let code, _, _, let error):
              let errorMessage =  (error as NSError?)?.localizedDescription ?? ""
              VGSAnalyticsClient.shared.trackFormEvent(strongSelf.formAnalyticsDetails, type: .submit, status: .failed, extraData: ["statusCode": code, "error": errorMessage])
            }
        }
        block(response)
      }
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

        var content: [String] = ["file"]
        if !(extraData?.isEmpty ?? true) {
          content.append("custom_data")
        }
        if !(customHeaders?.isEmpty ?? true) {
          content.append("custom_header")
        }
        // check if file is exist
        guard let key = storage.files.keys.first, let value = storage.files.values.first else {
            let error = VGSError(type: .inputFileNotFound,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileNotFound,
                                                        description: "File not selected or doesn't exists",
                                                        extraInfo: [:]))
            VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails, type: .beforeSubmit, status: .failed, extraData: [ "statusCode": error.code, "content": content])
            block(.failure(error.code, nil, nil, error))
            return
        }
        // check if file converted to Data
        guard let result = value as? Data else {
            let error = VGSError(type: .inputFileTypeIsNotSupported,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported,
                                                        description: "File format is not supported. Can't convert to Data.",
                                                        extraInfo: [:]))
            VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails, type: .beforeSubmit, status: .failed, extraData: [ "statusCode": error.code, "content": content])
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
          VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails, type: .beforeSubmit, status: .failed, extraData: [ "statusCode": error.code, "content": content])
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
          VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails, type: .beforeSubmit, status: .failed, extraData: [ "statusCode": error.code, "content": content])
          block(.failure(error.code, nil, nil, error))
            return
        }
        // make body
        let body = mapStringKVOToDictionary(key: key, value: encodedData, separator: ".")
        VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails, type: .beforeSubmit, status: .success, extraData: [ "statusCode": 200, "content": content])
      
        // send request
        apiClient.sendRequest(path: path, method: method, value: body) { [weak self](response ) in
            
            // Analytics
            if let strongSelf = self {
              switch response {
              case .success(let code, _, _):
                VGSAnalyticsClient.shared.trackFormEvent(strongSelf.formAnalyticsDetails, type: .submit, extraData: ["statusCode": code, "content": content])
              case .failure(let code, _, _, let error):
                let errorMessage =  (error as NSError?)?.localizedDescription ?? ""
                VGSAnalyticsClient.shared.trackFormEvent(strongSelf.formAnalyticsDetails, type: .submit, status: .failed, extraData: ["statusCode": code, "error": errorMessage, "content": content])
              }
          }
          block(response)
        }
    }
}
