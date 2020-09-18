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

/// An object you use for observing `VGSTextField` `State` and send data to your organization vault.
public class VGSCollect {
    internal let apiClient: APIClient
    internal let storage = Storage()
    internal let environment: Environment
    internal let dataRegion: String?
    internal let tenantId: String
  
    /// Max file size limit by proxy. Is static and can't be changed!
    internal let maxFileSizeInternalLimitInBytes = 24_000_000
    /// Unique form identifier
    internal let formId = UUID().uuidString
    
    /// Identifire that can be used for cross-debugging
    public var vgsCollectSessionId = UUID().uuidString
  
    // MARK: Custom HTTP Headers
    
    /// Set your custom HTTP headers
    public var customHeaders: [String: String]? {
        didSet {
            if customHeaders != oldValue {
                apiClient.customHeader = customHeaders
            }
        }
    }
    
    // MARK: Observe VGSTextField states
    
    /// Observe only focused `VGSTextField` on editing events.
    public var observeFieldState: ((_ textField: VGSTextField) -> Void)?
    
    /// Observe  all `VGSTextField` on editing events.
    public var observeStates: ((_ form: [VGSTextField]) -> Void)?
    
  
    // MARK: Get Registered VGSTextFields
    
    /// Returns array of `VGSTextField`s associated with `VGSCollect` instance.
    public var textFields: [VGSTextField] {
      return storage.elements
    }
  
    // MARK: - Initialzation
    
    /// Initialzation
    ///
    /// - Parameters:
    ///   - id: your organization vault id.
    ///   - environment: your organization vault environment. By default `Environment.sandbox`.
    ///   - dataRegion: id of data storage region (e.g. "eu-123"). Effects ONLY `Environment.live` vaults.
    public init(id: String, environment: Environment = .sandbox, dataRegion: String? = nil) {
      let url = Self.generateVaultURL(tenantId: id, environment: environment, region: dataRegion)
      apiClient = APIClient(baseURL: url)
      self.tenantId = id
      self.environment = environment
      self.dataRegion = dataRegion
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
