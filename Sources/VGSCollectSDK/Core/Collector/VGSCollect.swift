//
//  VGSForm.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/26/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// An object you use for observing `VGSTextField` `State` and send data to your organization vault.
public class VGSCollect {
    internal let apiClient: APIClient
    internal let storage = Storage()
    internal let regionalEnvironment: String
    internal let tenantId: String
    internal let formAnalyticsDetails: VGSFormAnanlyticsDetails
  
    /// Max file size limit by proxy. Is static and can't be changed!
    internal let maxFileSizeInternalLimitInBytes = 24_000_000
    /// Unique form identifier.
    internal let formId = UUID().uuidString
      
    // MARK: Custom HTTP Headers
    
    /// Set your custom HTTP headers.
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
      return storage.textFields
    }
  
    // MARK: - Initialzation
    
    /// Initialzation.
    ///
    /// - Parameters:
    ///   - id: your organization vault id.
    ///   - environment: your organization vault environment with data region.(e.g. "live", "live-eu1", "sanbox").
    ///   - hostname:
    public init(id: String, environment: String, hostname: String? = nil) {
      self.tenantId = id
      self.regionalEnvironment = environment
      self.formAnalyticsDetails = VGSFormAnanlyticsDetails.init(formId: formId, tenantId: tenantId, environment: regionalEnvironment)
      self.apiClient = APIClient(tenantId: id, regionalEnvironment: environment, hostname: hostname, formAnalyticsDetails: formAnalyticsDetails)
    }
  
    // MARK: - Initialzation
    
    /// Initialzation.
    ///
    /// - Parameters:
    ///   - id: your organization vault id.
    ///   - environment: your organization vault environment. By default `Environment.sandbox`.
    ///   - dataRegion: id of data storage region (e.g. "eu-123").
    public convenience init(id: String, environment: Environment = .sandbox, dataRegion: String? = nil, hostname: String? = nil) {
      let env = Self.generateRegionalEnvironmentString(environment, region: dataRegion)
      self.init(id: id, environment: env, hostname: hostname)
    }

    // MARK: - Manage VGSTextFields
    
    /// Returns `VGSTextField` with `VGSConfiguration.fieldName` associated with `VGCollect` instance.
    public func getTextField(fieldName: String) -> VGSTextField? {
        return storage.textFields.first(where: { $0.fieldName == fieldName })
    }
  
    /// Unassign `VGSTextField` from `VGSCollect` instance.
    ///
    /// - Parameters:
    ///   - textField: `VGSTextField` that should be unassigned.
    public func unassignTextField(_ textField: VGSTextField) {
      self.unregisterTextFields(textField: [textField])
    }
  
    /// Unassign `VGSTextField`s from `VGSCollect` instance.
    ///
    /// - Parameters:
    ///   - textFields: an array of `VGSTextField`s that should be unassigned.
    public func unassignTextFields(_ textFields: [VGSTextField]) {
      self.unregisterTextFields(textField: textFields)
    }
  
    /// Unassign  all `VGSTextField`s from `VGSCollect` instance.
    public func unassignAllTextFields() {
      self.unregisterAllTextFields()
    }
  
    // MARK: - Manage Files
  
    /// Detach files for associated `VGSCollect` instance.
    public func cleanFiles() {
      self.unregisterAllFiles()
    }
}
