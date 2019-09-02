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
    
    private let baseURL: URL!
    
    init(baseURL url: URL) {
        baseURL = url
    }
    
    func sendSaveCardRequest(value: BodyData, completion block: @escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        // Add Headers
        let headers = [
            "Content-Type": "application/json",
        ]
        // JSON Body
        let body: [String : Any] = value
        // Path
        let path = baseURL.appendingPathComponent("post")
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
