//
//  APIClient.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import Alamofire

public typealias JsonData = [String: Any]
public typealias BodyData = [String: Any]
public typealias HTTPHeaders = [String: String]

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
            guard
                let vgsInfo = Bundle(for: APIClient.self).infoDictionary,
                let build = vgsInfo["CFBundleShortVersionString"]
            else { return "Unknown" }

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
                          method: .post,
                          parameters: body,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success(let data):
                    
                    guard let dict = data as? JsonData, let json = dict["json"] as? JsonData else {
                        block(nil, nil)
                        return
                    }
                    block(json, nil)
                    
                case .failure(let error):
                    block(nil, error)
                }
        }
    }
}
