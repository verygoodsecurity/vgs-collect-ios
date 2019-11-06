//
//  VGSForm.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/26/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import Alamofire

/// The VGSForm class needed for collect all text filelds
public class VGSCollect {
    internal let apiClient: APIClient
    internal let storage = Storage()
    
    /// Observing focused text field of state
    public var observeFieldState: ((_ textField: VGSTextField) -> Void)?
    
    /// Observing all text fields states
    public var observeStates: ((_ form:[VGSTextField]) -> Void)?
    
    /// Set your custom HTTP headers
    public var customHeaders: [String: String]? {
        didSet {
            if customHeaders != oldValue {
                apiClient.customHeader = customHeaders
            }
        }
    }
    
    // MARK: - Initialzation
    
    /// Init VGSForm instance
    ///
    /// - Parameters:
    ///   - id: Your tanent id value
    ///   - environment: By default it's `sandbox`, better for testing. And `live` when you ready for prodaction.
    public init(id: String, environment: Environment = .sandbox) {
        let strUrl = "https://" + id + "." + environment.rawValue + ".verygoodproxy.com"
        guard let url = URL(string: strUrl) else {
            fatalError("Upstream Host is broken. Can't to converting to URL!")
        }
        apiClient = APIClient(baseURL: url)
    }
    
    func registerTextFields(textField objects: [VGSTextField]) {
        objects.forEach { [weak self] tf in
            self?.storage.addElement(tf)
        }
    }
    
    func unregisterTextFields(textField objects: [VGSTextField]) {
        objects.forEach { [weak self] tf in
            self?.storage.removeElement(tf)
        }
    }
}

extension VGSCollect {
    func updateStatus(for textField: VGSTextField) {
        // reset all focus status
        storage.elements.forEach { textField in
            textField.focusStatus = false
        }
        // set focus for textField
        textField.focusStatus = true
        // call observers
        observeStates?(storage.elements)
        observeFieldState?(textField)
    }
}

// MARK: - sending data
extension VGSCollect {
    public func submit(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        
        var body = BodyData()
        
        let elements = storage.elements
        
        let allKeys = elements.compactMap( { $0.fieldName } )
        allKeys.forEach { key in
            if let value = elements.filter( { $0.fieldName == key } ).first {
                body[key] = value.textField.text
            } else {
                fatalError("Wrong key: \(key)")
            }
        }
        
        if extraData?.count != 0 {
            body["data"] = extraData?.description
        }
        
        apiClient.sendRequest(path: path, method: method, value: body) { (json, error) in
            
            if let error = error {
                print("Error: \(String(describing: error.localizedDescription))")
                block(json, error)
                
            } else {
                let allKeys = json?.keys
                allKeys?.forEach({ key in
                    
                    if let element = elements.filter( { $0.fieldName == key } ).first {
                        element.token = json?[key] as? String
                    }
                })
            }
            block(json, nil)
        }
    }
    
    public func submitFiles(path: String, method: HTTPMethod = .post, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        
        var valueForSend = BodyData()
        
        guard let key = storage.files.keys.first, let value = storage.files.values.first else {
            return
        }
        
        let result: Data
        if let image = value as? UIImage {
            result = image.jpegData(compressionQuality: 0.5)!
            
        } else if let data = value as? Data {
            result = data
            
        } else {
            return
        }
        
        valueForSend[key] = result.base64EncodedString()
        
        if valueForSend.count == 0 {
            return
        }
        
        apiClient.sendRequest(path: path, method: method, value: valueForSend, completion: block)
    }
}
