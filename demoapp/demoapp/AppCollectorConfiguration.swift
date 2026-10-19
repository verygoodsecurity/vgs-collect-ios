//
//  AppConfiguration.swift
//  demoapp
//

import Foundation
import VGSCollectSDK

/// Set your tenant configuration here.
@MainActor
class AppCollectorConfiguration {
    
    static let shared = AppCollectorConfiguration()
    
    /// Set your tenant ID here https://www.verygoodsecurity.com/terminology/nomenclature#vault
    var tenantId = "tenantId"
    
    var tokenizationTenantId = "tokenizationTenantId"
    
    ///  Set environment - `.sandbox` for testing or `.live` for production
    var environment = Environment.sandbox
  
    ///  Set BlinkCard license key to test card scanner
    var blinkCardLicenseKey: String?
}
