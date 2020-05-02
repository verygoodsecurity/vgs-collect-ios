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
        let vgsCollectVersion: String = {
            guard let vgsInfo = Bundle(for: APIClient.self).infoDictionary,
                let build = vgsInfo["CFBundleShortVersionString"]
            else {
                return "Unknown"
            }
            return "\(build)"
        }()
        return [
            "vgs-client": "source=iosSDK&medium=vgs-collect&content=\(vgsCollectVersion)&osVersion=\(versionString)"
        ]
    }()
    
    @available(*, deprecated, message: "use -sendRequest:")
    func sendRequest(path: String, method: HTTPMethod = .post, value: BodyData, completion block: @escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        // JSON Body
        let body: [String: Any] = value
        // Fetch Request
        sendRequest(path: path, method: method, value: body) { VGSResponse in
            switch VGSResponse {
            case .success( _, let data):

                var resultData: JsonData?
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? JsonData {
                    resultData = json
                }
                block(resultData, nil)

            case .failure(let error):
                block(nil, error)
            }
        }
    }
}

// MARK: - URLSession
public enum VGSResponse {
    case success(Bool, Data?)
    case failure(Error?)
}

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

extension APIClient {
    
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
        
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            var isSuccess = false
            if let rr = response as? HTTPURLResponse {
                switch rr.statusCode {
                case 200..<300:
                    isSuccess = true
                    
                default:
                    isSuccess = false
                }
            }
            DispatchQueue.main.async {
                if error != nil {
                    block?(.failure(error))
                    
                } else {
                    block?(.success(isSuccess, data))
                }
            }
        }.resume()
    }
}
