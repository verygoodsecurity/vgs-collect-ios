//
//  VGS.swift
//  framework
//
//  Created by Vitalii Obertynskyi on 8/26/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public class VGS {
    private let apiClient: APIClient
    private let storage: Storage
    
    public init(upstreamHost url: String) {
        guard let url = URL(string: url) else {
            fatalError("Upstream Host is broken. Can't to converting to URL!")
        }
        apiClient = APIClient(baseURL: url)
        storage = Storage()
    }
    
    public func registerTextFields(textField objects: [VGSTextField]) {
        objects.forEach { [weak self] tf in
            self?.storage.addElement(tf)
        }
    }
    
    public func unregisterTextFields(textField objects: [VGSTextField]) {
        objects.forEach { [weak self] tf in
            self?.storage.removeElement(tf)
        }
    }
}

// MARK: - sending data
extension VGS {
    public func sendData(completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        
        var body = BodyData()
        
        let elements = storage.elements
        
        let allKeys = elements.compactMap( { $0.model?.alias } )
        allKeys.forEach { key in
            if let value = elements.filter( { $0.model?.alias == key } ).first {
                body[key] = value.text
            } else {
                fatalError("Wrong key: \(key)")
            }
        }
        
        apiClient.sendSaveCardRequest(value: body) { [weak self] (json, error) in
            
            if let error = error {
                print("Error: \(String(describing: error.localizedDescription))")
                block(json, error)
                
            } else {
                let allKeys = json?.keys
                allKeys?.forEach({ key in
                    
                    if let element = elements.filter( { $0.model?.alias == key } ).first {
                        element.model?.token = json?[key] as? String
                    }
                })
            }
            
            print(">>> \(String(describing: elements.compactMap( { $0.model?.token } )))")
            block(json, nil)
        }
    }
}
