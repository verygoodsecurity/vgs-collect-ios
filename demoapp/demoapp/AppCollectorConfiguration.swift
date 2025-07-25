//
//  AppConfiguration.swift
//  demoapp
//

import Foundation
import VGSCollectSDK

/// Setup your Vault configuration details here
@MainActor
class AppCollectorConfiguration {
    
    static let shared = AppCollectorConfiguration()
    
    /// Set your vault id here https://www.verygoodsecurity.com/terminology/nomenclature#vault
    var vaultId = "vaultId"
    
    var tokenizationVaultId = "tokenization_vaultId"
    
    ///  Set environment - `.sandbox` for testing or `.live` for production
    var environment = Environment.sandbox
  
    ///  Set BlinkCard license key to test card scanner
    var blinkCardLicenseKey: String?
}
