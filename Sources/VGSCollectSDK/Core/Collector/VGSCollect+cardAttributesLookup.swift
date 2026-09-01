//
//  VGSCollect+cardAttributesLookup.swift
//  VGSCollectSDK
//

import Foundation

// Defines the contract for an entity capable of looking up card attributes.
/// Useful for dependency injection and mocking in Unit Tests.
public protocol VGSCardAttributesLookupService: AnyObject {
    
    // MARK: - Configuration
//    /// Indicates if the lookup feature is enabled by the form configuration.
//    var isCardAttributesLookupEnabled: Bool { get }
    
    // MARK: - Data Provider Callbacks
    /// Closure to provide the JWT token needed for the request.
    var authHandler: ((_ completion: @escaping (Result<String, Error>) -> Void) -> Void)? { get set }
    
    // MARK: - Lifecycle Callbacks
    /// Called when the 11-digit trigger occurs, before the request starts.
    var willBeginCardAttributesLookup: (() -> Void)? { get set }
    
    /// Called with the complete parsed backend object from a successful lookup response.
    /// Use `cardAttributesLookupResponse` when raw response bytes are needed.
    var didRetrieveCardAttributes: (([String: Any]) -> Void)? { get set }

    /// Called when card attributes lookup request completes.
    /// Success and failure cases expose the raw response details from the lookup request.
    var cardAttributesLookupResponse: ((VGSCardAttributesLookupResponse) -> Void)? { get set }

    /// Called when the lookup fails.
    /// Follows the same payload shape as `VGSResponse.failure(code, data, response, error)`.
    var didFailToRetrieveCardAttributes: ((Int, Data?, URLResponse?, Error?) -> Void)? { get set }
}

@MainActor
internal extension VGSCollect {
  private static let cardAttributesLookupSandboxURLString = "https://card-enrichment-api.sandbox.verygoodvault.com/cardattributes/enriched"
  private static let cardAttributesLookupProductionURLString = "https://card-enrichment-api.live.verygoodvault.com/cardattributes/enriched"

  static func cardAttributesLookupURL(environment: String) -> URL {
    let endpoint = environment.lowercased().starts(with: "live")
      ? cardAttributesLookupProductionURLString
      : cardAttributesLookupSandboxURLString
    return URL(string: endpoint)!
  }

  // MARK: - Card Attributes Lookup

  /// Entry point invoked on each card number edit.
  func handlePotentialCardAttributesLookup(for textField: VGSTextField) {
    guard textField.fieldType == .cardNumber else { return }

    // Feature flag from form config: do not trigger lookup if no attributes requested.
    guard !includedCardAttributes.isEmpty else { return }

    // Use secure raw text (unformatted), then keep digits only.
    let raw = textField.textField.getSecureRawText ?? ""
    let digitsOnly = raw.filter({ $0.isNumber })

    // If user deleted below threshold, reset state so future edits can trigger again.
    guard digitsOnly.count >= 11 else {
      cardAttributesLookupContext = CardAttributesLookupContext(requestedDigits11: nil, inFlightDigits11: nil, startedAt: nil)
      return
    }

    let first11 = String(digitsOnly.prefix(11))

    // Don't re-request for the same first 11 digits.
    let ctx = cardAttributesLookupContext
    if ctx.requestedDigits11 == first11 || ctx.inFlightDigits11 == first11 {
      return
    }

    cardAttributesLookupContext = CardAttributesLookupContext(requestedDigits11: first11, inFlightDigits11: first11, startedAt: Date())

    willBeginCardAttributesLookup?()

    // Reuse shared JWT fetch/caching logic.
    getOrFetchJWT { [weak self] tokenResult in
      guard let self else { return }

      switch tokenResult {
      case .success(let token):
        self.performCardAttributesRequest(for: first11, token: token)
      case .failure(let error):
        let response: VGSCardAttributesLookupResponse = .failure((error as NSError).code, nil, nil, error)
        self.finishLookupIfCurrent(digits11: first11, result: .failure(response: response))
      }
    }
  }

  // MARK: - Backend Request

  private func performCardAttributesRequest(for digits11: String,
                                            token: String,
                                            didRetryAfterAuthFailure: Bool = false) {
    let normalizedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedToken.isEmpty else {
      let error = VGSError(type: .invalidAccessToken,
                           userInfo: VGSErrorInfo(key: VGSSDKErrorInvalidAccessToken,
                                                  description: "JWT token is empty.",
                                                  extraInfo: [:]))
      let response: VGSCardAttributesLookupResponse = .failure(error.code, nil, nil, error)
      finishLookupIfCurrent(digits11: digits11, result: .failure(response: response))
      return
    }

    guard let request = buildCardAttributesLookupRequest(digits11: digits11, token: normalizedToken) else {
      let error = makeLookupSDKError(type: .unexpectedResponseDataFormat,
                                     description: "Failed to build card attributes lookup request.")
      let response: VGSCardAttributesLookupResponse = .failure(error.code, nil, nil, error)
      finishLookupIfCurrent(digits11: digits11, result: .failure(response: response))
      return
    }
    VGSCollectRequestLogger.logRequest(request, payload: nil)

    cardAttributesLookupURLSession.dataTask(with: request) { [weak self] data, response, error in
      DispatchQueue.main.async {
        guard let self else { return }

        if let error {
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: (error as NSError).code)
          let responseResult: VGSCardAttributesLookupResponse = .failure((error as NSError).code, data, response, error)
          self.finishLookupIfCurrent(digits11: digits11, result: .failure(response: responseResult))
          return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
          let error = self.makeLookupSDKError(type: .unexpectedResponseType,
                                              description: "Card attributes lookup response is invalid.")
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: error.code)
          let responseResult: VGSCardAttributesLookupResponse = .failure(error.code, data, response, error)
          self.finishLookupIfCurrent(digits11: digits11, result: .failure(response: responseResult))
          return
        }

        let statusCode = httpResponse.statusCode
        if statusCode == 401 || statusCode == 403, !didRetryAfterAuthFailure {
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: nil, code: statusCode)
          self.jwtTokenCache.invalidate()
          self.getOrFetchJWT { [weak self] tokenResult in
            guard let self else { return }
            switch tokenResult {
            case .success(let refreshedToken):
              self.performCardAttributesRequest(for: digits11, token: refreshedToken, didRetryAfterAuthFailure: true)
            case .failure(let error):
              let responseResult: VGSCardAttributesLookupResponse = .failure((error as NSError).code, data, response, error)
              self.finishLookupIfCurrent(digits11: digits11, result: .failure(response: responseResult))
            }
          }
          return
        }

        guard (200..<300).contains(statusCode) else {
          let responseResult: VGSCardAttributesLookupResponse = .failure(statusCode, data, response, nil)
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: nil, code: statusCode)
          self.finishLookupIfCurrent(digits11: digits11, result: .failure(response: responseResult))
          return
        }

        guard let data else {
          let error = self.makeLookupSDKError(type: .unexpectedResponseDataFormat,
                                              description: "Card attributes lookup response body is empty.")
          VGSCollectRequestLogger.logErrorResponse(response, data: nil, error: error, code: error.code)
          let responseResult: VGSCardAttributesLookupResponse = .failure(error.code, nil, response, error)
          self.finishLookupIfCurrent(digits11: digits11, result: .failure(response: responseResult))
          return
        }

        guard let attributes = self.parseCardAttributesResponse(data, fallbackBIN: String(digits11.prefix(6))) else {
          let error = self.makeLookupSDKError(type: .unexpectedResponseDataFormat,
                                              description: "Card attributes lookup response has invalid data shape.")
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: error.code)
          let responseResult: VGSCardAttributesLookupResponse = .failure(error.code, data, response, error)
          self.finishLookupIfCurrent(digits11: digits11, result: .failure(response: responseResult))
          return
        }

        VGSCollectRequestLogger.logSuccessResponse(response, data: data, code: statusCode)
        self.finishLookupIfCurrent(
          digits11: digits11,
          result: .success(
            response: .success(statusCode, data, response),
            attributes: attributes
          )
        )
      }
    }.resume()
  }

  private func buildCardAttributesLookupRequest(digits11: String, token: String) -> URLRequest? {
    let url = Self.cardAttributesLookupURL(environment: regionalEnvironment)

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let payload: [String: Any] = [
      "number": digits11,
      "filter": includedCardAttributes
    ]

    guard let body = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
      return nil
    }
    request.httpBody = body
    return request
  }

  private func parseCardAttributesResponse(_ data: Data, fallbackBIN _: String) -> [String: Any]? {
    guard
      let object = try? JSONSerialization.jsonObject(with: data, options: []),
      let response = object as? [String: Any]
    else {
      return nil
    }

    guard !response.isEmpty else {
      return nil
    }

    return response
  }

  // MARK: - Result Delivery

  private enum CardAttributesLookupCompletionResult {
    case success(response: VGSCardAttributesLookupResponse, attributes: [String: Any])
    case failure(response: VGSCardAttributesLookupResponse)
  }

  private func finishLookupIfCurrent(digits11: String, result: CardAttributesLookupCompletionResult) {
    // Only accept result for current in-flight request.
    guard cardAttributesLookupContext.inFlightDigits11 == digits11 else {
      return
    }

    // Ensure user still has the same first 11 digits in the card field.
    let cardField = storage.textFields.first(where: { $0.fieldType == .cardNumber })
    let raw = cardField?.textField.getSecureRawText ?? ""
    let digitsOnly = raw.filter({ $0.isNumber })

    guard digitsOnly.count >= 11, String(digitsOnly.prefix(11)) == digits11 else {
      // Input changed. Drop in-flight marker, ignore result.
      cardAttributesLookupContext.inFlightDigits11 = nil
      cardAttributesLookupContext.startedAt = nil
      return
    }

    let startedAt = cardAttributesLookupContext.startedAt
    cardAttributesLookupContext.inFlightDigits11 = nil
    cardAttributesLookupContext.startedAt = nil

    if let startedAt {
      trackCardLookupAnalytics(result: result, startedAt: startedAt)
    }

    switch result {
    case .success(let response, let attributes):
      cardAttributesLookupResponse?(response)
      didRetrieveCardAttributes?(attributes)
    case .failure(let response):
      cardAttributesLookupResponse?(response)
      if case .failure(let code, let data, let urlResponse, let error) = response {
        didFailToRetrieveCardAttributes?(code, data, urlResponse, error)
      }
    }
  }

  private func trackCardLookupAnalytics(result: CardAttributesLookupCompletionResult, startedAt: Date) {
    let latency = max(Int(Date().timeIntervalSince(startedAt) * 1000), 0)
    let status: VGSAnalyticsClient.AnalyticEventStatus
    let error: String
    let statusCode: Any

    switch result {
    case .success(let response, _):
      status = .success
      error = ""
      if case .success(let code, _, _) = response {
        statusCode = code
      } else {
        statusCode = NSNull()
      }
    case .failure(let response):
      status = .failed
      if case .failure(_, _, let urlResponse, let underlyingError) = response {
        if let responseStatusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
          statusCode = responseStatusCode
        } else {
          statusCode = NSNull()
        }
        error = cardLookupAnalyticsErrorCategory(
          response: urlResponse,
          underlyingError: underlyingError
        )
      } else {
        statusCode = NSNull()
        error = "unknown_error"
      }
    }

    VGSAnalyticsClient.shared.trackFormEvent(
      formAnalyticsDetails,
      type: .cardLookup,
      status: status,
      extraData: [
        "error": error,
        "statusCode": statusCode,
        "latency": latency
      ]
    )
  }

  private func cardLookupAnalyticsErrorCategory(response: URLResponse?, underlyingError: Error?) -> String {
    if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
      return "http_error"
    }
    if underlyingError is VGSError {
      return "invalid_response"
    }
    if underlyingError != nil {
      return "network_error"
    }
    return "unknown_error"
  }

  private func makeLookupSDKError(type: VGSErrorType,
                                  description: String,
                                  extraInfo: [String: Any] = [:]) -> VGSError {
    let key: VGSErrorInfoKey
    switch type {
    case .unexpectedResponseType:
      key = VGSSDKErrorUnexpectedResponseType
    case .unexpectedResponseDataFormat:
      key = VGSSDKErrorUnexpectedResponseDataFormat
    default:
      key = VGSSDKErrorUnexpectedResponseDataFormat
    }

    return VGSError(type: type,
                    userInfo: VGSErrorInfo(key: key,
                                           description: description,
                                           extraInfo: extraInfo))
  }

}
