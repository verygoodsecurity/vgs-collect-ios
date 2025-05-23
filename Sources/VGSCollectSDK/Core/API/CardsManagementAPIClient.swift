//
//  CMPAPIClient.swift
//  VGSCollectSDK
//
//  Created by Dmytro on 16.04.2025.
//  Copyright © 2025 VGS. All rights reserved.
//

import Foundation

class CardsManagementAPIClient: VGSAPIClientProtocol {
  
  internal let urlSession = URLSession(configuration: .ephemeral)
  
  var baseURL: URL?
  
  func setCustomHeaders(headers: HTTPHeaders?) {
    self.customHeader = headers
  }
  
//  var analyticsHeaders: HTTPHeaders
  
  var customHeader: HTTPHeaders?
  
  
  private static func getBaseURL(env: String) -> URL {
    let environment = env.lowercased()
    switch environment {
    case "sandbox":
      return URL(string: "https://sandbox.vgsapi.com")!
    default:
      return URL(string: "https://vgsapi.com")!
    }
  }
  
  required init(environment: String, formAnalyticsDetails: VGSFormAnanlyticsDetails) {
    self.baseURL = Self.getBaseURL(env: environment)
  }
  
  func sendRequest(path: String, method: VGSCollectHTTPMethod, routeId: String? = nil, value: BodyData, completion block: ((VGSResponse) -> Void)?) {

    // Add headers.
    var headers = APIClient.defaultHttpHeaders
    headers["Content-Type"] = "application/vnd.api+json"
    if let customerHeaders = customHeader, customerHeaders.count > 0 {
      customerHeaders.keys.forEach({ (key) in
        headers[key] = customerHeaders[key]
      })
    }
    
    // Add custom headers if needed.
    // Setup URLRequest.
    let jsonData = try? JSONSerialization.data(withJSONObject: value)
    let url = baseURL!.appendingPathComponent(path)
    var request = URLRequest(url: url)
    request.httpBody = jsonData
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers

    // Log request.
    VGSCollectRequestLogger.logRequest(request, payload: value)

    // Send data.
    urlSession.dataTask(with: request) { (data, response, error) in
      DispatchQueue.main.async {
        if let error = error as NSError? {
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: error.code)
          block?(.failure(error.code, data, response, error))
          return
        }
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? VGSErrorType.unexpectedResponseType.rawValue

        switch statusCode {
        case 200..<300:
          VGSCollectRequestLogger.logSuccessResponse(response, data: data, code: statusCode)
          block?(.success(statusCode, data, response))
          return
        default:
          VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: statusCode)
          block?(.failure(statusCode, data, response, error))
          return
        }
      }
    }.resume()
  }
}
