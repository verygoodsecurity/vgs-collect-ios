//
//  VGSForm.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/26/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import Alamofire

/// The VGSForm class needed for collect all text filelds
public class VGSCollect {
    internal let apiClient: APIClient
    internal let storage = Storage()
    /// Max file size limit by proxy. Is static and can't be changed!
    internal let maxFileSizeInternalLimitInBytes = 24_000_000
    
    /// Observing focused text field of state
    public var observeFieldState: ((_ textField: VGSTextField) -> Void)?
    
    /// Observing all text fields states
    public var observeStates: ((_ form: [VGSTextField]) -> Void)?
    
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
        assert(Self.tenantIDValid(id), "Error: vault id is not valid!")
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
    
    public func getTextField(fieldName: String) -> VGSTextField? {
        return storage.elements.first(where: { $0.fieldName == fieldName })
    }
    
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
        
        var body = FileData()
        
        let elements = storage.elements
        
        let allKeys = elements.compactMap({ $0.fieldName })
        allKeys.forEach { key in
            if let value = elements.filter({ $0.fieldName == key }).first {
                body[key] = value.rawText
            } else {
                fatalError("Wrong key: \(key)")
            }
        }
        
        if extraData?.count != 0 {
            extraData?.forEach { (key, value) in body[key] = value }
        }
        
        apiClient.sendRequest(path: path, method: method, value: body) { (json, error) in
            
            if let error = error {
                print("Error: \(String(describing: error.localizedDescription))")
                block(json, error)
                return
            } else {
                let allKeys = json?.keys
                allKeys?.forEach({ key in
                    
                    if let element = elements.filter({ $0.fieldName == key }).first {
                        element.token = json?[key] as? String
                    }
                })
                block(json, nil)
                return
            }
        }
    }
    
    public func submitFile(path: String, method: HTTPMethod = .post, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {

         var valueForSend = FileData()

         guard let key = storage.files.keys.first, let value = storage.files.values.first else {
            block(nil, VGSError(type: .inputFileNotFound, userInfo: ["key": "file_not_found_error",
                                                                     "description": "File not selected or doesn't exists"]))
            return
        }

        let result: Data
 
        if let data = value as? Data {
            result = data
        } else {
            block(nil, VGSError(type: .inputFileTypeIsNotSupported, userInfo: ["key": "not_supported_file_format",
                                                                               "description": "File format is not supported"]))
            return
        }

        if result.count >= maxFileSizeInternalLimitInBytes {
            block(nil, VGSError(type: .inputFileSizeExceedsTheLimit, userInfo: ["key": "file_size_too_large",
                                                                                "description": "File size is too large: (\(result.count)) bytes. Max file size should be \(maxFileSizeInternalLimitInBytes) bytes"]))
            return
        }
        valueForSend[key] = result.base64EncodedString()

        if valueForSend.count == 0 {
            block(nil,  VGSError(type: .inputFileTypeIsNotSupported, userInfo: ["key": "not_supported_file_format",
                                                                                "description": "File format is not supported"]))
            return
        }
         apiClient.sendRequest(path: path, method: method, value: valueForSend, completion: block)
    }
}

// MARK: - Validation
internal extension VGSCollect {

    class func tenantIDValid(_ tenantId: String) -> Bool {
        return tenantId.isAlphaNumeric
    }
}
