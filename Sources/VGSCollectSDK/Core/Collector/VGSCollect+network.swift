//
//  VGSCollect+network.swift
//  VGSCollectSDK
//

import Foundation
import Combine
import VGSClientSDKAnalytics

// MARK: - Send data
extension VGSCollect {
    /**
     Send data from VGSTextFields to your organization vault.
     
     - Parameters:
        - path: Inbound rout path for your organization vault.
        - method: VGSCollectHTTPMethod, default is `.post`.
        - routeId: id of VGS Proxy Route, default is `nil`.
        - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
	      - requestOptions: `VGSCollectRequestOptions` object, holds additional request options. Default options are `.nestedJSON`.
        - completion: response completion block, returns `VGSResponse`.
     
     - Note:
        Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
    */
  public func sendData(path: String, method: VGSCollectHTTPMethod = .post, routeId: String? = nil, extraData: [String: Any]? = nil, requestOptions: VGSCollectRequestOptions = VGSCollectRequestOptions(), completion block: @escaping (VGSResponse) -> Void) {
      
        // Content analytics.
        var content: [String] = ["textField"]
        if !(extraData?.isEmpty ?? true) {
          content.append("custom_data")
        }
        if !(customHeaders?.isEmpty ?? true) {
          content.append("custom_header")
        }

				let fieldMappingPolicy = requestOptions.fieldNameMappingPolicy

				content.append(fieldMappingPolicy.analyticsName)
        if let error = validateStoredInputData() {
          
          VGSAnalyticsClient.shared.capture(
            self.formAnalyticsDetails,
            event: VGSAnalyticsEvent.Request(
              status: VGSAnalyticsStatus.failed,
              code: Int32(error.code),
              content: content,
              upstream: VGSAnalyticsUpstream.custom
            )
          )
          
          block(.failure(error.code, nil, nil, error))
            return
        }

        let body = mapFieldsToBodyJSON(with: fieldMappingPolicy, extraData: extraData)

        VGSAnalyticsClient.shared.capture(
          self.formAnalyticsDetails,
          event: VGSAnalyticsEvent.Request(
            status: VGSAnalyticsStatus.ok,
            code: 200,
            content: content,
            upstream: VGSAnalyticsUpstream.custom
          )
        )
    
        // Send request.
        apiClient.sendRequest(path: path, method: method, routeId: routeId, value: body) { [weak self](response ) in
          
          // Analytics
          if let strongSelf = self {
            switch response {
            case .success(let code, _, _):
              VGSAnalyticsClient.shared.capture(
                strongSelf.formAnalyticsDetails,
                event: VGSAnalyticsEvent.Response(
                  status: VGSAnalyticsStatus.ok,
                  code: Int32(code),
                  upstream: VGSAnalyticsUpstream.custom,
                  errorMessage: nil
                )
              )
            case .failure(let code, _, _, let error):
              let errorMessage =  (error as NSError?)?.localizedDescription ?? ""
              VGSAnalyticsClient.shared.capture(
                strongSelf.formAnalyticsDetails,
                event: VGSAnalyticsEvent.Response(
                  status: VGSAnalyticsStatus.failed,
                  code: Int32(code),
                  upstream: VGSAnalyticsUpstream.custom,
                  errorMessage: errorMessage
                )
              )
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
        - routeId: id of VGS Proxy Route, default is `nil`.
        - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
        - completion: response completion block, returns `VGSResponse`.
     
     - Note:
        Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
    */
    public func sendFile(path: String, method: VGSCollectHTTPMethod = .post, routeId: String? = nil, extraData: [String: Any]? = nil, requestOptions: VGSCollectRequestOptions = VGSCollectRequestOptions(), completion block: @escaping (VGSResponse) -> Void) {

        var content: [String] = ["file"]
        if !(extraData?.isEmpty ?? true) {
          content.append("custom_data")
        }
        if !(customHeaders?.isEmpty ?? true) {
          content.append("custom_header")
        }
        // Check if file is exist.
        guard let key = storage.files.keys.first, let value = storage.files.values.first else {
            let text = "No file to send! File not selected or doesn't exist!"
            let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)
          
            let error = VGSError(type: .inputFileNotFound,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileNotFound,
                                                        description: "File not selected or doesn't exist",
                                                        extraInfo: [:]))
            VGSAnalyticsClient.shared.capture(
              self.formAnalyticsDetails,
              event: VGSAnalyticsEvent.Request(
                status: VGSAnalyticsStatus.failed,
                code: Int32(error.code),
                content: content,
                upstream: VGSAnalyticsUpstream.custom
              )
            )
            block(.failure(error.code, nil, nil, error))
            return
        }
        // Check if file is converted to Data.
        guard let result = value as? Data else {
            let text = "File format is not supported!!! Cannot convert file type to Data object."
            let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)
          
            let error = VGSError(type: .inputFileTypeIsNotSupported,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported,
                                                        description: "File format is not supported. Cannot convert to Data.",
                                                        extraInfo: [:]))
            VGSAnalyticsClient.shared.capture(
              self.formAnalyticsDetails,
              event: VGSAnalyticsEvent.Request(
                status: VGSAnalyticsStatus.failed,
                code: Int32(error.code),
                content: content,
                upstream: VGSAnalyticsUpstream.custom
              )
            )
            block(.failure(error.code, nil, nil, error))
            return
        }
        // Check max file size.
        if result.count >= maxFileSizeInternalLimitInBytes {
          
          let text = "File size is too large - \(result.count). File size shouldn't exceed \(maxFileSizeInternalLimitInBytes)"
          let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
          VGSCollectLogger.shared.forwardLogEvent(event)
          
            let error = VGSError(type: .inputFileSizeExceedsTheLimit,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileSizeExceedsTheLimit,
                                                        description: "File size is too large.",
                                                        extraInfo: [
                                                            "expectedSize": maxFileSizeInternalLimitInBytes,
                                                            "fileSize": "\(result.count)", "sizeUnits": "bytes"]))
            VGSAnalyticsClient.shared.capture(
              self.formAnalyticsDetails,
              event: VGSAnalyticsEvent.Request(
                status: VGSAnalyticsStatus.failed,
                code: Int32(error.code),
                content: content,
                upstream: VGSAnalyticsUpstream.custom
              )
            )
            block(.failure(error.code, nil, nil, error))
            return
        }
        // Encode file.
        let encodedData = result.base64EncodedString()
        if encodedData.count == 0 {
          let text = "Encoded file size - \(encodedData.count)!!!"
          let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
          VGSCollectLogger.shared.forwardLogEvent(event)
          
            let error = VGSError(type: .inputFileTypeIsNotSupported,
                                 userInfo: VGSErrorInfo(key: VGSSDKErrorFileTypeNotSupported,
                                                        description: "File format is not supported. File is empty.",
                                                        extraInfo: [:]))
          VGSAnalyticsClient.shared.capture(
            self.formAnalyticsDetails,
            event: VGSAnalyticsEvent.Request(
              status: VGSAnalyticsStatus.failed,
              code: Int32(error.code),
              content: content,
              upstream: VGSAnalyticsUpstream.custom
            )
          )
          block(.failure(error.code, nil, nil, error))
            return
        }
        // Make body.
        let body = mapStringKVOToDictionary(key: key, value: encodedData, separator: ".")
        VGSAnalyticsClient.shared.capture(
          self.formAnalyticsDetails,
          event: VGSAnalyticsEvent.Request(
            status: VGSAnalyticsStatus.ok,
            code: 200,
            content: content,
            upstream: VGSAnalyticsUpstream.custom
          )
        )

        // Send request.
        apiClient.sendRequest(path: path, method: method, routeId: routeId, value: body) { [weak self](response ) in
            
            // Analytics.
            if let strongSelf = self {
              switch response {
              case .success(let code, _, _):
                VGSAnalyticsClient.shared.capture(
                  strongSelf.formAnalyticsDetails,
                  event: VGSAnalyticsEvent.Response(
                    status: VGSAnalyticsStatus.ok,
                    code: Int32(code),
                    upstream: VGSAnalyticsUpstream.custom,
                    errorMessage: nil
                  )
                )
              case .failure(let code, _, _, let error):
                let errorMessage =  (error as NSError?)?.localizedDescription ?? ""
                VGSAnalyticsClient.shared.capture(
                  strongSelf.formAnalyticsDetails,
                  event: VGSAnalyticsEvent.Response(
                    status: VGSAnalyticsStatus.failed,
                    code: Int32(code),
                    upstream: VGSAnalyticsUpstream.custom,
                    errorMessage: errorMessage
                  )
                )
              }
          }
          block(response)
        }
    }
  
  /**
   Send tokenization request with data from VGSTextFields.
   - Parameters:
      - routeId: id of VGS Proxy Route, default is `nil`.
      - completion: response completion block, returns `VGSTokenizationResponse`.
   - Note:
      Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
  */
  public func tokenizeData(routeId: String? = nil, completion block: @escaping (VGSTokenizationResponse) -> Void) {
    // Default request params
    let path = "tokens"
    let method = VGSCollectHTTPMethod.post
    
    // Check fields validation status
    if let error = validateStoredInputData() {
      VGSAnalyticsClient.shared.capture(
        self.formAnalyticsDetails,
        event: VGSAnalyticsEvent.Request(
          status: VGSAnalyticsStatus.failed,
          code: Int32(error.code),
          content: [],
          upstream: VGSAnalyticsUpstream.tokenization
        )
      )
      block(.failure(error.code, nil, nil, error))
      return
    }

    // TextField attached to collect by tokenization protocol implementation
    let tokenizableFields = storage.tokenizableTextFields
    let notTokenizableFields = storage.notTokenizibleTextFields
    
    // Check if there are fields for tokenization. Return data from not tokenizable fields.
    if tokenizableFields.count == 0 {
      let code = 200
      let responseBody = mapNotTokenizableFieldsToResponseBody(notTokenizableFields)
      VGSAnalyticsClient.shared.capture(
        self.formAnalyticsDetails,
        event: VGSAnalyticsEvent.Response(
          status: VGSAnalyticsStatus.ok,
          code: Int32(code),
          upstream: VGSAnalyticsUpstream.tokenization,
          errorMessage: nil
        )
      )
      block(.success(code, responseBody, nil))
      return
    }
      
    // Get tokenized textfields params as JSON body
    let tokenizationJSON = mapFieldsToTokenizationRequestBodyJSON(tokenizableFields)
    // Send request.
    apiClient.sendRequest(path: path, method: method, routeId: routeId, value: tokenizationJSON) { [weak self](response ) in
      if let strongSelf = self {
        switch response {
        case .success(let code, let data, let response):
          // Analytics
          VGSAnalyticsClient.shared.capture(
            strongSelf.formAnalyticsDetails,
            event: VGSAnalyticsEvent.Response(
              status: VGSAnalyticsStatus.ok,
              code: Int32(code),
              upstream: VGSAnalyticsUpstream.tokenization,
              errorMessage: nil
            )
          )
          // Build response - combine tokenized data with not tokenized
          let responseBody = strongSelf.buildTokenizationResponseBody(data, tokenizedFields: tokenizableFields, notTokenizedFields: notTokenizableFields)
          block(.success(code, responseBody, response))
          return
        case .failure(let code, let data, let response, let error):
          let errorMessage =  (error as NSError?)?.localizedDescription ?? ""
          VGSAnalyticsClient.shared.capture(
            strongSelf.formAnalyticsDetails,
            event: VGSAnalyticsEvent.Response(
              status: VGSAnalyticsStatus.failed,
              code: Int32(code),
              upstream: VGSAnalyticsUpstream.tokenization,
              errorMessage: errorMessage
            )
          )
          block(.failure(code, data, response, error))
          return
        }
      }
    }
  }
}

// MARK: VGSCollect + async
@available(iOS 13, *)
extension VGSCollect {
  /**
   Asynchronously send data from VGSTextFields to your organization vault.
   
   - Parameters:
      - path: Inbound rout path for your organization vault.
      - method: VGSCollectHTTPMethod, default is `.post`.
      - routeId: id of VGS Proxy Route, default is `nil`.
      - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
      - requestOptions: `VGSCollectRequestOptions` object, holds additional request options. Default options are `.nestedJSON`.
    - Returns:
      -   VGSResponse: response completion block, returns `VGSResponse`.
   
   - Note:
      Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
  */
  public func sendData(path: String, method: VGSCollectHTTPMethod = .post, routeId: String? = nil, extraData: [String: Any]? = nil, requestOptions: VGSCollectRequestOptions = VGSCollectRequestOptions()) async -> VGSResponse {
    return await withCheckedContinuation { continuation in
      // NOTE:  We need to use main thread since data will be collected  from UI elements
      DispatchQueue.main.async {
        self.sendData(path: path, method: method, routeId: routeId, extraData: extraData, requestOptions: requestOptions) { response in
          continuation.resume(returning: response)
          
        }
      }
    }
  }
  
  /**
   Asynchronously send file to your organization vault. Only send one file at a time.
   
   - Parameters:
      - path: Inbound rout path for your organization vault.
      - method: HTTPMethod, default is `.post`.
      - routeId: id of VGS Proxy Route, default is `nil`.
      - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
      - completion: response completion block, returns `VGSResponse`.

   - Note:
      Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
  */
  public func sendFile(path: String, method: VGSCollectHTTPMethod = .post, routeId: String? = nil, extraData: [String: Any]? = nil) async -> VGSResponse {
    return await withCheckedContinuation { continuation in
      self.sendFile(path: path, method: method, routeId: routeId, extraData: extraData) { response in
        continuation.resume(returning: response)
      }
    }
  }
  
  /**
   Asynchronously send tokenization request with data from VGSTextFields.
   - Parameters:
      - routeId: id of VGS Proxy Route, default is `nil`.
      - completion: response completion block, returns `VGSTokenizationResponse`.
   - Note:
      Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
  */
  public func tokenizeData(routeId: String? = nil) async -> VGSTokenizationResponse {
    return await withCheckedContinuation { continuation in
      // NOTE:  We need to use main thread since data will be collected  from UI elements
      DispatchQueue.main.async {
        self.tokenizeData(routeId: routeId) {response in
          continuation.resume(returning: response)
        }
      }
    }
  }
}
  
// MARK: VGSCollect + Combine
@available(iOS 13, *)
extension VGSCollect {
  /**
   Send data from VGSTextFields to your organization vault using the Combine framework.
   
   - Parameters:
      - path: Inbound rout path for your organization vault.
      - method: VGSCollectHTTPMethod, default is `.post`.
      - routeId: id of VGS Proxy Route, default is `nil`.
      - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
      - requestOptions: `VGSCollectRequestOptions` object, holds additional request options. Default options are `.nestedJSON`.
   - Returns: A `Future` publisher that emits a single `VGSResponse`.

   - Note:
      Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
  */
  public func sendDataPublisher(path: String, method: VGSCollectHTTPMethod = .post, routeId: String? = nil, extraData: [String: Any]? = nil, requestOptions: VGSCollectRequestOptions = VGSCollectRequestOptions()) -> Future<VGSResponse, Never> {
    return Future { [weak self] completion in
      self?.sendData(path: path, method: method, routeId: routeId, extraData: extraData, requestOptions: requestOptions) { response in
        completion(.success(response))
      }
    }
  }
  
  /**
   Send file to your organization vault using the Combine framework.
   
   - Parameters:
      - path: Inbound rout path for your organization vault.
      - method: VGSCollectHTTPMethod, default is `.post`.
      - routeId: id of VGS Proxy Route, default is `nil`.
      - extraData: Any data you want to send together with data from VGSTextFields , default is `nil`.
      - requestOptions: `VGSCollectRequestOptions` object, holds additional request options. Default options are `.nestedJSON`.
   - Returns: A `Future` publisher that emits a single `VGSResponse`.

   - Note:
      Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
  */
  public func sendFilePublisher(path: String, method: VGSCollectHTTPMethod = .post, routeId: String? = nil, extraData: [String: Any]? = nil, requestOptions: VGSCollectRequestOptions = VGSCollectRequestOptions()) -> Future<VGSResponse, Never> {
    return Future { [weak self] completion in
      self?.sendFile(path: path, method: method, routeId: routeId, extraData: extraData, requestOptions: requestOptions) { response in
        completion(.success(response))
      }
    }
  }
  
  /**
   Send tokenization request with data from VGSTextFields to your organization vault using the Combine framework.
   
   - Parameters:
      - routeId: id of VGS Proxy Route, default is `nil`.
   - Returns: A `Future` publisher that emits a single `VGSTokenizationResponse`.

   - Note:
      Errors can be returned in the `NSURLErrorDomain` and `VGSCollectSDKErrorDomain`.
  */
  public func tokenizeDataPublisher(routeId: String? = nil) -> Future<VGSTokenizationResponse, Never> {
    return Future { [weak self] completion in
      self?.tokenizeData(routeId: routeId) { response in
        completion(.success(response))
      }
    }
  }
}
