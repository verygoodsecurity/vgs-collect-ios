//
//  APIClient.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import Alamofire

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
    
    func sendRequest(path: String, method: HTTPMethod = .post, value: BodyData, completion block: @escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        // Add Headers
        var headers = APIClient.defaultHttpHeaders
        headers["Content-Type"] = "application/json"
        // Add custom headers if need
        if let customerHeaders = customHeader, customerHeaders.count > 0 {
            customerHeaders.keys.forEach({ (key) in
                headers[key] = customerHeaders[key]
            })
        }
        
        // JSON Body
        let body: [String: Any] = value
        // Path
        let path = baseURL.appendingPathComponent(path)
        // Fetch Request
        Alamofire.request(path,
                          method: method,
                          parameters: body,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in

                switch response.result {
                case .success(let data):
                    guard let dict = data as? JsonData else {
                        // swiftlint:disable:next line_length
                        block(nil, VGSError(type: .unexpectedResponseDataFormat, userInfo: VGSErrorInfo(key: VGSSDKErrorUnexpectedResponseDataFormat, description: "Unexpected response format")))
                        return
                    }
                    block(dict, nil)
                    return
                case .failure(let error):
                    block(nil, error)
                    return
                }
        }
        block(nil, nil)
    }
}
