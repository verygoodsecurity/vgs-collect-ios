//
//  VGSCollect+internal.swift
//  VGSCollectSDK
//
//  Created by Dima on 10.03.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

@MainActor
internal extension VGSCollect {
    private static let sessionConfigurationBaseURLString = "https://js.verygoodvault.com/session-configuration"
    static var sessionConfigurationURLSessionFactory: () -> URLSession = {
      URLSession(configuration: .ephemeral)
    }
  
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

           let textFieldsData: BodyData = VGSCollect.mapFieldsDataToBody(from: storage.textFields)

            var body = mapInputFieldsDataToDictionary(textFieldsData)

        if let customData = extraData, customData.count != 0 {
           // NOTE: If there are similar keys on same level, body values will override customvalues values for that keys
           body = deepMerge(customData, body)
        }

        return body
    }

    static func mapStoredInpuToFlatJSON(with extraData: [String: Any]? = nil, from textFields: [VGSTextField]) -> [String: Any] {
        var body: BodyData = mapFieldsDataToBody(from: textFields)

         if let customData = extraData, customData.count != 0 {
                // NOTE: If there are similar keys on same level, body values will override customvalues values for that keys
                body = deepMerge(customData, body)
         }

         return body
    }

      /// Map fields data to body.
      /// - Returns: `BodyData` from collect fields.
    static func mapFieldsDataToBody(from textFields: [VGSTextField]) -> BodyData {
            let textFieldsData: BodyData = textFields.reduce(into: BodyData()) { (dict, element) in
                let output = element.getOutputText()

                /// Check if any serialization should be done before data will be send
                if let serializable = element.configuration as? VGSFormatSerializableProtocol, serializable.shouldSerialize {
                    let result = serializable.serialize(output ?? "")
                    dict = deepMerge(dict, result)
                } else {
                    dict[element.fieldName] = output
                }
            }

            return textFieldsData
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

        // Card attributes lookup trigger (first 11 digits of card number).
        handlePotentialCardAttributesLookup(for: textField)

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
    
    // MARK: - Form configuration
    
    /// Form ID validation regex used by `session(with:)`.
    /// Validates `formId` format for async factory.
    class func validateFormId(_ formId: String) -> Bool {
      let formIdValidationRegex = "^[A-Za-z0-9_-]+$"
      let hasValidFormat = formId.range(of: formIdValidationRegex, options: .regularExpression) != nil
      return hasValidFormat && (1...50).contains(formId.count)
    }

    struct VGSFormConfigurationData: Decodable {
      struct Config: Decodable {
        struct CardAttributes: Decodable {
          let enable: Bool?
          let parameters: [String]?
        }

        let cardAttributes: CardAttributes?
      }

      let formName: String?
      let version: String?
      let config: Config?

      enum CodingKeys: String, CodingKey {
        case formName = "form_name"
        case version
        case config
      }
    }

    struct VGSFormConfigurationLoadMetrics {
      let filename: String
      let statusCode: Int
      let latency: Int
    }

    struct VGSFormConfigurationLoadResult {
      let config: VGSFormConfigurationData
      let metrics: VGSFormConfigurationLoadMetrics
    }

    struct VGSFormConfigurationLoadError: LocalizedError {
      let underlyingResponse: VGSCollectSessionResponse
      let metrics: VGSFormConfigurationLoadMetrics

      var errorDescription: String? {
        switch underlyingResponse {
        case .success:
          return nil
        case .failure(let code, _, _, let error):
          return error?.localizedDescription ?? "Failed to load form configuration: \(code)."
        }
      }
    }

    typealias VGSFormConfigurationLoadCompletion = @MainActor (Result<VGSFormConfigurationLoadResult, Error>) -> Void

    static func createCollectInitExtraData() -> [String: Any] {
      return ["formType": VGSAnalyticsFormType.create.rawValue]
    }

    static func sessionCollectInitExtraData(metrics: VGSFormConfigurationLoadMetrics) -> [String: Any] {
      return [
        "formType": VGSAnalyticsFormType.session.rawValue,
        "configFile": metrics.filename,
        "configFileStatusCode": metrics.statusCode,
        "configFileLatency": metrics.latency
      ]
    }

    private static func makeSessionConfigurationSDKError(type: VGSErrorType,
                                                         description: String,
                                                         extraInfo: [String: Any] = [:]) -> VGSError {
      let key: VGSErrorInfoKey
      switch type {
      case .invalidConfigurationURL:
        key = VGSSDKErrorInvalidConfigurationURL
      case .sessionInitializationFailed:
        key = VGSSDKErrorSessionInitializationFailed
      default:
        key = VGSSDKErrorSessionInitializationFailed
      }

      return VGSError(type: type,
                      userInfo: VGSErrorInfo(key: key,
                                             description: description,
                                             extraInfo: extraInfo))
    }

    private static func formConfigurationLoadMetrics(filename: String,
                                                     startedAt: Date,
                                                     statusCode: Int) -> VGSFormConfigurationLoadMetrics {
      let latency = Int(Date().timeIntervalSince(startedAt) * 1000)
      return VGSFormConfigurationLoadMetrics(
        filename: filename,
        statusCode: statusCode,
        latency: latency
      )
    }

    /// Generates lowercase UTF-8 hex filename for the provided form name.
    static func collectConfigFilenameHex(form: String) -> String {
      return form.utf8.map { String(format: "%02x", $0) }.joined()
    }

    /// Builds canonical session configuration URL for form-driven session initialization.
    static func buildSessionConfigURL(form: String, vaultId: String) -> URL? {
      guard let baseURL = URL(string: sessionConfigurationBaseURLString) else { return nil }
      let filename = collectConfigFilenameHex(form: form)
      return baseURL
        .appendingPathComponent(vaultId)
        .appendingPathComponent("\(filename).json")
    }

    static func decodeFormConfiguration(from data: Data) throws -> VGSFormConfigurationData {
      return try JSONDecoder().decode(VGSFormConfigurationData.self, from: data)
    }

    static func decodeInlineFormConfiguration(_ configuration: [String: Any]?) -> VGSFormConfigurationData? {
      guard
        let configuration,
        JSONSerialization.isValidJSONObject(configuration),
        let data = try? JSONSerialization.data(withJSONObject: ["config": configuration], options: [])
      else {
        return nil
      }

      return try? decodeFormConfiguration(from: data)
    }

    static func resolveIncludedCardAttributes(from config: VGSFormConfigurationData.Config?) -> [String] {
      guard config?.cardAttributes?.enable == true else { return [] }
      let raw = config?.cardAttributes?.parameters ?? []
      let sanitized = raw
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
      guard !sanitized.isEmpty else { return [] }

      var seen = Set<String>()
      var unique = [String]()
      for item in sanitized where !seen.contains(item) {
        seen.insert(item)
        unique.append(item)
      }
      return unique
    }

    static func loadConfiguration(for formId: String,
                                  vaultId: String,
                                  completion: @escaping VGSFormConfigurationLoadCompletion) {
      let filename = "\(collectConfigFilenameHex(form: formId)).json"
      let startedAt = Date()

      guard let url = buildSessionConfigURL(form: formId, vaultId: vaultId) else {
        let error = makeSessionConfigurationSDKError(type: .invalidConfigurationURL,
                                                     description: "Failed to build session configuration URL.")
        let metrics = formConfigurationLoadMetrics(
          filename: filename,
          startedAt: startedAt,
          statusCode: error.code
        )
        completion(.failure(VGSFormConfigurationLoadError(
          underlyingResponse: .failure(error.code, nil, nil, error),
          metrics: metrics
        )))
        return
      }

      let request = URLRequest(url: url)
      VGSCollectRequestLogger.logRequest(request, payload: nil)
      let session = sessionConfigurationURLSessionFactory()
      session.dataTask(with: request) { data, response, error in
        Task { @MainActor in
          if let error = error {
            let sdkError = makeSessionConfigurationSDKError(type: .sessionInitializationFailed,
                                                            description: error.localizedDescription)
            VGSCollectRequestLogger.logErrorResponse(response, data: data, error: sdkError, code: sdkError.code)
            let metrics = formConfigurationLoadMetrics(
              filename: filename,
              startedAt: startedAt,
              statusCode: sdkError.code
            )
            completion(.failure(VGSFormConfigurationLoadError(
              underlyingResponse: .failure(sdkError.code, nil, nil, sdkError),
              metrics: metrics
            )))
            return
          }

          guard let httpResponse = response as? HTTPURLResponse else {
            let sdkError = makeSessionConfigurationSDKError(type: .sessionInitializationFailed,
                                                            description: "Session configuration response is invalid.")
            VGSCollectRequestLogger.logErrorResponse(response, data: data, error: sdkError, code: sdkError.code)
            let metrics = formConfigurationLoadMetrics(
              filename: filename,
              startedAt: startedAt,
              statusCode: sdkError.code
            )
            completion(.failure(VGSFormConfigurationLoadError(
              underlyingResponse: .failure(sdkError.code, data, response, sdkError),
              metrics: metrics
            )))
            return
          }

          guard (200..<300).contains(httpResponse.statusCode) else {
            let statusCode = httpResponse.statusCode
            let responseError: VGSCollectSessionResponse = .failure(statusCode, data, response, nil)
            VGSCollectRequestLogger.logErrorResponse(response, data: data, error: nil, code: statusCode)
            let metrics = formConfigurationLoadMetrics(
              filename: filename,
              startedAt: startedAt,
              statusCode: statusCode
            )
            completion(.failure(VGSFormConfigurationLoadError(
              underlyingResponse: responseError,
              metrics: metrics
            )))
            return
          }

          guard let data else {
            let error = makeSessionConfigurationSDKError(type: .sessionInitializationFailed,
                                                         description: "Session configuration response body is empty.",
                                                         extraInfo: ["statusCode": httpResponse.statusCode])
            VGSCollectRequestLogger.logErrorResponse(response, data: nil, error: error, code: error.code)
            let metrics = formConfigurationLoadMetrics(
              filename: filename,
              startedAt: startedAt,
              statusCode: httpResponse.statusCode
            )
            completion(.failure(VGSFormConfigurationLoadError(
              underlyingResponse: .failure(error.code, nil, nil, error),
              metrics: metrics
            )))
            return
          }

          do {
            let decoded = try decodeFormConfiguration(from: data)
            VGSCollectRequestLogger.logSuccessResponse(response, data: data, code: httpResponse.statusCode)
            let metrics = formConfigurationLoadMetrics(
              filename: filename,
              startedAt: startedAt,
              statusCode: httpResponse.statusCode
            )
            completion(.success(VGSFormConfigurationLoadResult(config: decoded, metrics: metrics)))
          } catch {
            let sdkError = makeSessionConfigurationSDKError(type: .sessionInitializationFailed,
                                                            description: "Session configuration response has invalid data shape.",
                                                            extraInfo: ["statusCode": httpResponse.statusCode])
            VGSCollectRequestLogger.logErrorResponse(response, data: data, error: sdkError, code: sdkError.code)
            let metrics = formConfigurationLoadMetrics(
              filename: filename,
              startedAt: startedAt,
              statusCode: httpResponse.statusCode
            )
            completion(.failure(VGSFormConfigurationLoadError(
              underlyingResponse: .failure(sdkError.code, nil, nil, sdkError),
              metrics: metrics
            )))
          }
        }
      }.resume()
    }
}
