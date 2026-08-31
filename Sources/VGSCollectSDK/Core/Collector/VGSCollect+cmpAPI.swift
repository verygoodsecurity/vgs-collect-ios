//
//  VGSCollect+CMP.swift
//  VGSCollectSDK
//

import Foundation
import Combine

private extension VGSResponse {
  var statusCode: Int? {
    switch self {
    case .success(let code, _, _): return code
    case .failure(let code, _, _, _): return code
    }
  }
}

private enum VGSCMPAnalyticsOperation: String {
  case createCard = "cardCreate"
  case updateCard = "cardUpdate"
}

private struct VGSCMPRequest {
  let path: String
  let method: VGSCollectHTTPMethod
  let body: BodyData
  let operation: VGSCMPAnalyticsOperation
  let content: [String]
}

// MARK: - CMP request construction
extension VGSCollect {
  internal func buildCreateCardBody(extraData: [String: Any]? = nil) -> BodyData {
    let fieldValues = mapFieldsToBodyJSON(with: .flatJSON, extraData: nil)
    let wrappedAttributes = (extraData?["data"] as? BodyData)?["attributes"] as? BodyData
    var attributes = wrappedAttributes ?? extraData ?? [:]
    if let pan = fieldValues["pan"] {
      attributes["pan"] = pan
    }
    applyCMPExpirationAttributes(from: fieldValues, to: &attributes)
    if let cvc = fieldValues["cvc"] {
      attributes["cvc"] = cvc
    }
    if let cardholderName = fieldValues["cardholder"] {
      var cardholder = attributes["cardholder"] as? BodyData ?? [:]
      cardholder["name"] = cardholderName
      attributes["cardholder"] = cardholder
    }
    normalizeCMPExpirationAttributes(in: &attributes)
    var meta: BodyData = [
      "_source": "vgs-collect",
      "_medium": "iosSDK",
      "_version": Utils.vgsCollectVersion
    ]
    if let sessionFormId {
      meta["_formId"] = sessionFormId
    }

    let body: BodyData = [
      "data": [
        "attributes": attributes,
        "meta": meta
      ]
    ]

    // Avoid nesting a caller-provided JSON:API attributes envelope twice.
    if wrappedAttributes != nil, let extraData {
      return deepMerge(extraData, body)
    }
    return body
  }

  internal func buildUpdateCardBody(extraData: [String: Any]? = nil) -> BodyData {
    let fieldValues = mapFieldsToBodyJSON(with: .flatJSON, extraData: nil)
    var attributes = extraData ?? [:]
    applyCMPExpirationAttributes(from: fieldValues, to: &attributes)
    if let cvc = fieldValues["cvc"] {
      attributes["cvc"] = cvc
    }
    normalizeCMPExpirationAttributes(in: &attributes)
    return [
      "data": [
        "attributes": attributes
      ]
    ]
  }

  private func applyCMPExpirationAttributes(from fieldValues: BodyData,
                                            to attributes: inout BodyData) {
    if let month = fieldValues["exp_month"] {
      attributes["exp_month"] = month
    }
    if let year = fieldValues["exp_year"] {
      attributes["exp_year"] = year
    }
  }

  private func normalizeCMPExpirationAttributes(in attributes: inout BodyData) {
    for key in ["exp_month", "exp_year"] {
      guard let value = attributes[key] else { continue }
      if let integer = value as? Int {
        attributes[key] = integer
      } else if let string = value as? String, let integer = Int(string) {
        attributes[key] = integer
      }
    }
  }

  private func makeCMPRequestValidationError(description: String) -> VGSError {
    VGSError(
      type: .inputDataIsNotValid,
      userInfo: VGSErrorInfo(
        key: VGSSDKErrorInputDataIsNotValid,
        description: description,
        extraInfo: [:]
      )
    )
  }

  private func validateCMPRequestBody(_ request: VGSCMPRequest) -> VGSError? {
    guard let data = request.body["data"] as? BodyData,
          let attributes = data["attributes"] as? BodyData else {
      return makeCMPRequestValidationError(description: "CMP card attributes are required.")
    }

    switch request.operation {
    case .createCard:
      guard let pan = attributes["pan"] as? String, !pan.isEmpty else {
        return makeCMPRequestValidationError(description: "PAN is required for a CMP create card request.")
      }
      guard validateCMPExpirationAttributes(attributes) else {
        return makeCMPRequestValidationError(description: "Valid expiration month and year are required for a CMP create card request.")
      }
    case .updateCard:
      let allowedKeys: Set<String> = ["cvc", "exp_month", "exp_year"]
      guard !attributes.isEmpty else {
        return makeCMPRequestValidationError(description: "At least one mutable card attribute is required for a CMP update request.")
      }
      guard Set(attributes.keys).isSubset(of: allowedKeys) else {
        return makeCMPRequestValidationError(description: "CMP update request contains unsupported card attributes.")
      }
      guard validateOptionalCMPExpirationAttributes(attributes) else {
        return makeCMPRequestValidationError(description: "CMP update request contains an invalid expiration month or year.")
      }
    }

    if let cvc = attributes["cvc"] {
      guard let cvc = cvc as? String, (3...4).contains(cvc.count) else {
        return makeCMPRequestValidationError(description: "CMP card verification code must contain three or four characters.")
      }
    }
    return nil
  }

  private func validateCMPExpirationAttributes(_ attributes: BodyData) -> Bool {
    guard let month = attributes["exp_month"] as? Int,
          let year = attributes["exp_year"] as? Int else {
      return false
    }
    return (1...12).contains(month) && (0...99).contains(year)
  }

  private func validateOptionalCMPExpirationAttributes(_ attributes: BodyData) -> Bool {
    if let month = attributes["exp_month"] {
      guard let month = month as? Int, (1...12).contains(month) else { return false }
    }
    if let year = attributes["exp_year"] {
      guard let year = year as? Int, (0...99).contains(year) else { return false }
    }
    return true
  }

  private func makeInvalidCardIDError() -> VGSError {
    VGSError(
      type: .invalidCardID,
      userInfo: VGSErrorInfo(
        key: VGSSDKErrorInvalidCardID,
        description: "Card ID is required for an update card request.",
        extraInfo: [:]
      )
    )
  }

  private func validatedCardID(_ cardId: String) -> Result<String, Error> {
    let trimmed = cardId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, !trimmed.contains("/"), trimmed != ".", trimmed != ".." else {
      return .failure(makeInvalidCardIDError())
    }
    return .success(trimmed)
  }

  private func cmpContent(extraData: [String: Any]?) -> [String] {
    var content = ["textField"]
    if !(extraData?.isEmpty ?? true) {
      content.append("custom_data")
    }
    return content
  }

  private func trackCMPBeforeSubmit(operation: VGSCMPAnalyticsOperation,
                                    status: VGSAnalyticsClient.AnalyticEventStatus,
                                    statusCode: Int,
                                    content: [String]) {
    VGSAnalyticsClient.shared.trackFormEvent(
      formAnalyticsDetails,
      type: .beforeSubmit,
      status: status,
      extraData: [
        "statusCode": statusCode,
        "upstream": "cmp",
        "operation": operation.rawValue,
        "content": content
      ]
    )
  }

  private func trackCMPSubmit(operation: VGSCMPAnalyticsOperation,
                              response: VGSResponse,
                              content: [String]) {
    switch response {
    case .success(let code, _, _):
      VGSAnalyticsClient.shared.trackFormEvent(
        formAnalyticsDetails,
        type: .submit,
        extraData: [
          "statusCode": code,
          "upstream": "cmp",
          "operation": operation.rawValue,
          "content": content
        ]
      )
    case .failure(let code, _, _, let error):
      VGSAnalyticsClient.shared.trackFormEvent(
        formAnalyticsDetails,
        type: .submit,
        status: .failed,
        extraData: [
          "statusCode": code,
          "error": error == nil ? "request_failed" : "transport_error",
          "upstream": "cmp",
          "operation": operation.rawValue,
          "content": content
        ]
      )
    }
  }

  private func performCMPRequest(_ request: VGSCMPRequest,
                                 token: String,
                                 completion block: @escaping (VGSResponse) -> Void) {
    let normalizedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedToken.isEmpty else {
      let error = VGSError(
        type: .invalidAccessToken,
        userInfo: VGSErrorInfo(
          key: VGSSDKErrorInvalidAccessToken,
          description: "Access token is required for a CMP card request.",
          extraInfo: [:]
        )
      )
      trackCMPBeforeSubmit(
        operation: request.operation,
        status: .failed,
        statusCode: error.code,
        content: request.content
      )
      block(.failure(error.code, nil, nil, error))
      return
    }

    if let error = validateStoredInputData() {
      trackCMPBeforeSubmit(
        operation: request.operation,
        status: .failed,
        statusCode: error.code,
        content: request.content
      )
      block(.failure(error.code, nil, nil, error))
      return
    }

    if let error = validateCMPRequestBody(request) {
      trackCMPBeforeSubmit(
        operation: request.operation,
        status: .failed,
        statusCode: error.code,
        content: request.content
      )
      block(.failure(error.code, nil, nil, error))
      return
    }

    let authorization = normalizedToken.hasPrefix("Bearer ")
      ? normalizedToken
      : "Bearer \(normalizedToken)"
    cmpAPIClient.customHeader = [
      "Content-Type": "application/vnd.api+json",
      "Authorization": authorization
    ]
    trackCMPBeforeSubmit(operation: request.operation, status: .success, statusCode: 200, content: request.content)
    cmpAPIClient.sendRequest(
      path: request.path,
      method: request.method,
      routeId: nil,
      value: request.body
    ) { [weak self] response in
      self?.trackCMPSubmit(operation: request.operation, response: response, content: request.content)
      block(response)
    }
  }

  private func performCMPRequestUsingCachedJWT(_ request: VGSCMPRequest,
                                               didRetryAfterAuthFailure: Bool = false,
                                               completion block: @escaping (VGSResponse) -> Void) {
    getOrFetchJWT { [weak self] tokenResult in
      guard let self else { return }
      switch tokenResult {
      case .success(let token):
        self.performCMPRequest(request, token: token) { [weak self] response in
          guard let self else { return }
          if let code = response.statusCode, code == 401 || code == 403 {
            self.jwtTokenCache.invalidate()
            guard !didRetryAfterAuthFailure else {
              block(response)
              return
            }
            self.performCMPRequestUsingCachedJWT(
              request,
              didRetryAfterAuthFailure: true,
              completion: block
            )
            return
          }
          block(response)
        }
      case .failure(let error):
        self.trackCMPBeforeSubmit(
          operation: request.operation,
          status: .failed,
          statusCode: (error as NSError).code,
          content: request.content
        )
        block(.failure((error as NSError).code, nil, nil, error))
      }
    }
  }
}

// MARK: - CMP create card
extension VGSCollect {
  /// Creates a card through CMP using `authHandler` and the in-memory JWT cache.
  ///
  /// - Parameter extraData: Additional CMP card attributes. Supply the contents
  ///   of `data.attributes`; the SDK adds the JSON:API envelope. Attribute names
  ///   and value types must match the Card Management API schema or CMP can
  ///   return a `4xx` response.
  public func createCard(extraData: [String: Any]? = nil,
                         completion block: @escaping (VGSResponse) -> Void) {
    let request = VGSCMPRequest(
      path: "cards",
      method: .post,
      body: buildCreateCardBody(extraData: extraData),
      operation: .createCard,
      content: cmpContent(extraData: extraData)
    )
    performCMPRequestUsingCachedJWT(request, completion: block)
  }

  /// Creates a card through CMP using an explicit access token.
  ///
  /// - Parameters:
  ///   - token: Card Management API access token.
  ///   - extraData: Additional CMP card attributes. Supply the contents of
  ///     `data.attributes`; the SDK adds the JSON:API envelope. Attribute names
  ///     and value types must match the Card Management API schema or CMP can
  ///     return a `4xx` response.
  public func createCard(token: String,
                         extraData: [String: Any]? = nil,
                         completion block: @escaping (VGSResponse) -> Void) {
    let request = VGSCMPRequest(
      path: "cards",
      method: .post,
      body: buildCreateCardBody(extraData: extraData),
      operation: .createCard,
      content: cmpContent(extraData: extraData)
    )
    performCMPRequest(request, token: token, completion: block)
  }
}

// MARK: - CMP update card
extension VGSCollect {
  /// Updates a card through CMP using `authHandler` and the in-memory JWT cache.
  public func updateCard(cardId: String,
                         extraData: [String: Any]? = nil,
                         completion block: @escaping (VGSResponse) -> Void) {
    switch validatedCardID(cardId) {
    case .success(let cardId):
      let request = VGSCMPRequest(
        path: "cards/\(cardId)",
        method: .patch,
        body: buildUpdateCardBody(extraData: extraData),
        operation: .updateCard,
        content: cmpContent(extraData: extraData)
      )
      performCMPRequestUsingCachedJWT(request, completion: block)
    case .failure(let error):
      block(.failure((error as NSError).code, nil, nil, error))
    }
  }

  /// Updates a card through CMP using an explicit access token.
  public func updateCard(cardId: String,
                         token: String,
                         extraData: [String: Any]? = nil,
                         completion block: @escaping (VGSResponse) -> Void) {
    switch validatedCardID(cardId) {
    case .success(let cardId):
      let request = VGSCMPRequest(
        path: "cards/\(cardId)",
        method: .patch,
        body: buildUpdateCardBody(extraData: extraData),
        operation: .updateCard,
        content: cmpContent(extraData: extraData)
      )
      performCMPRequest(request, token: token, completion: block)
    case .failure(let error):
      block(.failure((error as NSError).code, nil, nil, error))
    }
  }
}

// MARK: - CMP async APIs
@available(iOS 13, *)
extension VGSCollect {
  public func createCard(extraData: [String: Any]? = nil) async -> VGSResponse {
    await withCheckedContinuation { continuation in
      createCard(extraData: extraData) { continuation.resume(returning: $0) }
    }
  }

  public func createCard(token: String, extraData: [String: Any]? = nil) async -> VGSResponse {
    await withCheckedContinuation { continuation in
      createCard(token: token, extraData: extraData) { continuation.resume(returning: $0) }
    }
  }

  public func updateCard(cardId: String, extraData: [String: Any]? = nil) async -> VGSResponse {
    await withCheckedContinuation { continuation in
      updateCard(cardId: cardId, extraData: extraData) { continuation.resume(returning: $0) }
    }
  }

  public func updateCard(cardId: String,
                         token: String,
                         extraData: [String: Any]? = nil) async -> VGSResponse {
    await withCheckedContinuation { continuation in
      updateCard(cardId: cardId, token: token, extraData: extraData) { continuation.resume(returning: $0) }
    }
  }
}

// MARK: - CMP Combine APIs
@available(iOS 13, *)
extension VGSCollect {
  public func createCardPublisher(extraData: [String: Any]? = nil) -> Future<VGSResponse, Never> {
    Future { [weak self] completion in
      self?.createCard(extraData: extraData) { completion(.success($0)) }
    }
  }

  public func createCardPublisher(token: String,
                                  extraData: [String: Any]? = nil) -> Future<VGSResponse, Never> {
    Future { [weak self] completion in
      self?.createCard(token: token, extraData: extraData) { completion(.success($0)) }
    }
  }

  public func updateCardPublisher(cardId: String,
                                  extraData: [String: Any]? = nil) -> Future<VGSResponse, Never> {
    Future { [weak self] completion in
      self?.updateCard(cardId: cardId, extraData: extraData) { completion(.success($0)) }
    }
  }

  public func updateCardPublisher(cardId: String,
                                  token: String,
                                  extraData: [String: Any]? = nil) -> Future<VGSResponse, Never> {
    Future { [weak self] completion in
      self?.updateCard(cardId: cardId, token: token, extraData: extraData) { completion(.success($0)) }
    }
  }
}
