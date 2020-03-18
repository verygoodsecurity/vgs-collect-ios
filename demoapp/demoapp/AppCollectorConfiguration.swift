//
//  AppConfiguration.swift
//  demoapp
//
//  Created by Dima on 04.03.2020.
//  Copyright © 2020 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import VGSCollectSDK

/// Setup your Vault configuration details here
class AppCollectorConfiguration {
    
    static let shared = AppCollectorConfiguration()
    
    /// Set your vault id here https://www.verygoodsecurity.com/terminology/nomenclature#vault
    let vaultId = "vaultId"
    
    ///  Set environment - `.sandbox` for testing or `.live` for production
    let environment = Environment.sandbox
}
