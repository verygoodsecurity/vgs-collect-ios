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

class APIClient {
    let baseURL: URL!
    
    var customHeader: [String: String]?
    
    init(baseURL url: URL) {
        baseURL = url
    }
    
    func sendRequest(path: String, method: HTTPMethod = .post, value: BodyData, completion block: @escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        // Add Headers
        var headers = [
            "Content-Type": "application/json",
            "vgs-client": "source=iosSDK&medium=vgs-collect&content=1.0"
        ]
        
        // Add custom headers if need
        if let customerHeaders = customHeader, customerHeaders.count > 0 {
            customerHeaders.keys.forEach({ (key) in
                headers[key] = customerHeaders[key]
            })
        }
        
        // JSON Body
        let body: [String : Any] = value
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
                    
                    guard let d = data as? JsonData, let json = d["json"] as? JsonData else {
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
