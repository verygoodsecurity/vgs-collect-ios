//
//  VGSForm.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/26/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
//import Alamofire

/// An object you use for observing `VGSTextField` `State` and submit data to your organization vault.
public class VGSCollect {
    internal let apiClient: APIClient
    internal let storage = Storage()
    /// Max file size limit by proxy. Is static and can't be changed!
    internal let maxFileSizeInternalLimitInBytes = 24_000_000
    
    // MARK: Custom HTTP Headers
    
    /// Set your custom HTTP headers
    public var customHeaders: [String: String]? {
        didSet {
            if customHeaders != oldValue {
                apiClient.customHeader = customHeaders
            }
        }
    }
    
    // MARK: - Observe VGSTextField states
    
    /// Observe only focused `VGSTextField` on editing events.
    public var observeFieldState: ((_ textField: VGSTextField) -> Void)?
    
    /// Observe  all `VGSTextField` on editing events.
    public var observeStates: ((_ form: [VGSTextField]) -> Void)?
    
    // MARK: - Initialzation
    
    /// Initialzation
    ///
    /// - Parameters:
    ///   - id: your organization vault id.
    ///   - environment: your organization vault environment. By default `Environment.sandbox`.
    public init(id: String, environment: Environment = .sandbox) {
        assert(Self.tenantIDValid(id), "Error: vault id is not valid!")
        let strUrl = "https://" + id + "." + environment.rawValue + ".verygoodproxy.com"
        guard let url = URL(string: strUrl) else {
            fatalError("Upstream Host is broken. Can't to converting to URL!")
        }
        apiClient = APIClient(baseURL: url)
    }
    
    // MARK: - Helper functions
    
    /// Detach files for associated `VGSCollect` instance.
    public func cleanFiles() {
        storage.removeFiles()
    }
    
    /// Returns `VGSTextField` with `VGSConfiguration.fieldName` associated with `VGCollect` instance.
    public func getTextField(fieldName: String) -> VGSTextField? {
        return storage.elements.first(where: { $0.fieldName == fieldName })
    }
}

// MARK: - Send data to organization vault
extension VGSCollect {
    /**
     Send data from VGSTextFields to your organization vault.
     
     - Parameters:
        - path: Inbound rout path for your organization vault.
        - method: HTTPMethod, default is   `.post`.
        - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
        - completion: response completion block, returns `JsonData` or an `Error`.
     
     - Note:
        If there are validation errors, SDK will return `VGSError` in **error** field.
    */
    @available(swift, deprecated: 1.4.0, obsoleted: 1.5.0, message: "This will be removed in v 1.5.0, migrate to a submit(path: method: extraData: completion block:(VGSresponse))")
    public func submit(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        
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
    public func submitFile(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {

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

// MARK: - Simple request w/out Alamofire
extension VGSCollect {
    public func submit(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block: @escaping (VGSResponse) -> Void) {
        if let error = validateStoredInputData() {
            block(.failure(-1, error))
            return
        }

        let body = mapStoredInputDataForSubmit(with: extraData)
        apiClient.sendRequest(path: path, method: method, value: body, completion: block)
    }
}
