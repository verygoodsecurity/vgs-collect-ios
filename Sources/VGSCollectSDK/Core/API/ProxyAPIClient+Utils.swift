//
//  APIClient+Utils.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal extension ProxyAPIClient {

	// MARK: - Vault Url

	/// Generates API URL with vault id, environment and data region.
  static func buildVaultURL(tenantId: String, regionalEnvironment: String, routeId: String? = nil) -> URL? {

		// Check environment is valid.
		if !VGSCollect.regionalEnironmentStringValid(regionalEnvironment) {
			let eventText = "CONFIGURATION ERROR: ENVIRONMENT STRING IS NOT VALID!!! region \(regionalEnvironment)"
			let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)
			assert(VGSCollect.regionalEnironmentStringValid(regionalEnvironment), "❗VGSCollectSDK CONFIGURATION ERROR: ENVIRONMENT STRING IS NOT VALID!!!")
		}

		// Check tenant is valid.
		if !VGSCollect.tenantIDValid(tenantId) {
			let eventText = "CONFIGURATION ERROR: TENANT ID IS NOT VALID OR NOT SET!!! tenant: \(tenantId)"
			let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)
			assert(VGSCollect.tenantIDValid(tenantId), "❗VGSCollectSDK CONFIGURATION ERROR: : TENANT ID IS NOT VALID!!!")
		}
    
    let strUrl: String
    // Check is routeId is set and valid.
    if let routeId = routeId, !routeId.isEmpty {
      // Validate routeId is valid UUID string.
      guard UUID(uuidString: routeId) != nil else {
        let eventText = "CONFIGURATION ERROR: NOT VALID ROUTE ID PARAMETER!!! routeId: \(routeId), tenantID: \(tenantId), environment: \(regionalEnvironment)"
        let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
        VGSCollectLogger.shared.forwardLogEvent(event)
          assertionFailure("❗VGSCollectSDK CONFIGURATION ERROR: : NOT VALID ROUTE ID PARAMETER!!!")
        return nil
      }
      // Build url with specifi route id.
      strUrl = "https://" + tenantId + "-" + "\(routeId)" + "." + regionalEnvironment + ".verygoodproxy.com"
    } else {
      // Build default url.
      strUrl = "https://" + tenantId + "." + regionalEnvironment + ".verygoodproxy.com"
    }

		// Check vault url is valid.
		guard let url = URL(string: strUrl) else {
			assertionFailure("❗VGSCollectSDK CONFIGURATION ERROR: : NOT VALID ORGANIZATION PARAMETERS!!!")

			let eventText = "CONFIGURATION ERROR: NOT VALID ORGANIZATION PARAMETERS!!! tenantID: \(tenantId), environment: \(regionalEnvironment)"
			let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)

			return nil
		}
		return url
	}
  
  // MARK: - Card Attributes
  
  /// Fetches card attributes from the card attributes server using first 11 digits of card number.
  /// - Parameters:
  ///   - cardNumberBin: First 11 digits of the card number
  ///   - completion: Completion block with VGSResponse
  func fetchCardAttributes(cardNumberBin: String, completion: @escaping (VGSResponse) -> Void) {
    // Card attributes API endpoint
      // TODO: Update endpoint when moved to production
    let urlString = "https://js.verygoodvault.com/card-attributes/v1/\(cardNumberBin)"
    
    guard let url = URL(string: urlString) else {
      let invalidURLError = VGSError(type: .invalidConfigurationURL)
      completion(.failure(invalidURLError.code, nil, nil, invalidURLError))
      return
    }
    
    sendCardAttributesRequest(to: url, completion: completion)
  }
  
  /// Sends request to card attributes endpoint
  @MainActor private func sendCardAttributesRequest(to url: URL, completion: @escaping (VGSResponse) -> Void) {
    var headers = ProxyAPIClient.defaultHttpHeaders
    headers["Content-Type"] = "application/json"
    
    // Add custom headers if needed
    if let customHeaders = customHeader, !customHeaders.isEmpty {
      customHeaders.forEach { key, value in
        headers[key] = value
      }
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = headers
    
    // Log request
    VGSCollectRequestLogger.logRequest(request, payload: [:])
    
    // Send request
    urlSession.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if let error = error as NSError? {
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: error.code)
          completion(.failure(error.code, data, response, error))
          return
        }
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? VGSErrorType.unexpectedResponseType.rawValue
        
        switch statusCode {
        case 200..<300:
          VGSCollectRequestLogger.logSuccessResponse(response, data: data, code: statusCode)
          completion(.success(statusCode, data, response))
        default:
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: statusCode)
          completion(.failure(statusCode, data, response, error))
        }
      }
    }.resume()
  }
}
