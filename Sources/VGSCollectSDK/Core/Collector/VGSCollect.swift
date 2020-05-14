//
//  VGSForm.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/26/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
//import Alamofire

/// An object you use for observing `VGSTextField` `State` and send data to your organization vault.
public class VGSCollect {
    internal let apiClient: APIClient
    internal let storage = Storage()
    /// Max file size limit by proxy. Is static and can't be changed!
    internal let maxFileSizeInternalLimitInBytes = 24_000_000
    
    // MARK: Custom HTTP Headers
    
    /// Set your custom HTTP headers
    public var customHeaders: [String: String]? {
        didSet {
            if customHeaders != oldValue {
                apiClient.customHeader = customHeaders
            }
        }
    }
    
    // MARK: - Observe VGSTextField states
    
    /// Observe only focused `VGSTextField` on editing events.
    public var observeFieldState: ((_ textField: VGSTextField) -> Void)?
    
    /// Observe  all `VGSTextField` on editing events.
    public var observeStates: ((_ form: [VGSTextField]) -> Void)?
    
    // MARK: - Initialzation
    
    /// Initialzation
    ///
    /// - Parameters:
    ///   - id: your organization vault id.
    ///   - environment: your organization vault environment. By default `Environment.sandbox`.
    public init(id: String, environment: Environment = .sandbox) {
        assert(Self.tenantIDValid(id), "Error: vault id is not valid!")
        let strUrl = "https://" + id + "." + environment.rawValue + ".verygoodproxy.com"
        guard let url = URL(string: strUrl) else {
            fatalError("Upstream Host is broken. Can't to converting to URL!")
        }
        apiClient = APIClient(baseURL: url)
    }
    
    // MARK: - Helper functions
    
    /// Detach files for associated `VGSCollect` instance.
    public func cleanFiles() {
        storage.removeFiles()
    }
    
    /// Returns `VGSTextField` with `VGSConfiguration.fieldName` associated with `VGCollect` instance.
    public func getTextField(fieldName: String) -> VGSTextField? {
        return storage.elements.first(where: { $0.fieldName == fieldName })
    }
}
