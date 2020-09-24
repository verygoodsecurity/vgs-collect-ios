//
//  APIClient.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

/// Key-value data type, usually used for response format.
public typealias JsonData = [String: Any]

/// Key-value data type, used in http request headers.
public typealias HTTPHeaders = [String: String]

/// Key-value data type, for internal use.
internal typealias BodyData = [String: Any]

/// HTTP request methods
public enum HTTPMethod: String {
    /// GET method
    case get     = "GET"
    /// POST method
    case post    = "POST"
    /// PUT method
    case put     = "PUT"
}

/// Response enum cases for SDK requests
@frozen public enum VGSResponse {
    /**
     Success response case
     
     - Parameters:
        - code: response status code.
        - data: response **data** object.
        - response: URLResponse object represents a URL load response.
    */
    case success(_ code:Int, _ data:Data?, _ response: URLResponse?)
    
    /**
     Failed response case
     
     - Parameters:
        - code: response status code.
        - data: response **Data** object.
        - response: `URLResponse` object represents a URL load response.
        - error: `Error` object.
    */
    case failure(_ code:Int, _ data:Data?, _ response: URLResponse?, _ error:Error?)
}

class APIClient {
    let baseURL: URL!
    
    var customHeader: HTTPHeaders?
    
    init(baseURL url: URL) {
        baseURL = url
    }
    
    internal static let defaultHttpHeaders: HTTPHeaders = {
        // Add Headers
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return [
            "vgs-client": "source=iosSDK&medium=vgs-collect&content=\(vgsCollectVersion)&osVersion=\(versionString)"
        ]
    }()

    func sendRequest(path: String, method: HTTPMethod = .post, value: BodyData, completion block: ((_ response: VGSResponse) -> Void)? ) {
        // Add Headers
        var headers = APIClient.defaultHttpHeaders
        headers["Content-Type"] = "application/json"
        // Add custom headers if need
        if let customerHeaders = customHeader, customerHeaders.count > 0 {
            customerHeaders.keys.forEach({ (key) in
                headers[key] = customerHeaders[key]
            })
        }
        // Setup URLRequest
        let jsonData = try? JSONSerialization.data(withJSONObject: value)
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpBody = jsonData
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        // Send data
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    block?(.failure(error.code, data, response, error))
                    return
                }
              let statusCode = (response as? HTTPURLResponse)?.statusCode ?? VGSErrorType.unexpectedResponseType.rawValue
                
                switch statusCode {
                case 200..<300:
                    block?(.success(statusCode, data, response))
                    return
                default:
                    block?(.failure(statusCode, data, response, error))
                    return
                }
            }
        }.resume()
    }
}
