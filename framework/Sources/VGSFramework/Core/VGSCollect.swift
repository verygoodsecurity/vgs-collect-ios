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
        
        if textField.fieldType == .cardNumber {
            // cange card format
            textField.textField.formatPattern = textField.formatPatternForCard
            // change cvc format
            if let cvcField = storage.elements.filter({ $0.fieldType == .cvc }).first {
                cvcField.textField.formatPattern = textField.formatPatternForCvc
            }
            // change date format here (if needs)
        }
    }
}

// MARK: - sending data
extension VGSCollect {
    public func submit(path: String, method: HTTPMethod = .post, extraData: [String: Any]? = nil, completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        
        if let error = validateStoredInputData() {
            block(nil, error)
            return
        }

        let body = mapStoredInputDataForSubmit(with: extraData)
                
        apiClient.sendRequest(path: path, method: method, value: body) { (json, error) in
            if let error = error {
                block(json, error)
                return
            } else {
                block(json, nil)
                return
            }
        }
    }
}
