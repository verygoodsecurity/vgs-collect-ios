//
//  AppConfiguration.swift
//  demoapp
//
//  Created by Dima on 04.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import VGSCollectSDK

/// Setup your Vault configuration details here
class AppCollectorConfiguration {
    
    static let shared = AppCollectorConfiguration()
    
    /// Set your vault id here https://www.verygoodsecurity.com/terminology/nomenclature#vault
    var vaultId = "vaultId"
  
    var tokenizationVaultId = "tokenization_vaultId"
    
    ///  Set environment - `.sandbox` for testing or `.live` for production
    var environment = Environment.sandbox
  
  ///  Set BlinkCard license key to test card scanner
  var blinkCardLicenseKey: String?

	var paymentOrchestrationDefaultRouteId = "4880868f-d88b-4333-ab70-d9deecdbffc4"
	
	/// Path to custom backend URL to fetch token for payment orchestration demo.
	var customBackendBaseUrl = "https://custom-backend.com"

	/// Saved fin ids.
	var savedFinancialInstruments: [String] = []
}
