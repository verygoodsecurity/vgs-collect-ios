//
//  APIClient+Utils.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal extension ProxyAPIClient {

	// MARK: - Vault Url

	/// Generates API URL with vault id, environment and data region.
  static func buildVaultURL(tenantId: String, regionalEnvironment: String, routeId: String? = nil) -> URL? {

		// Check environment is valid.
		if !VGSCollect.regionalEnironmentStringValid(regionalEnvironment) {
			let eventText = "CONFIGURATION ERROR: ENVIRONMENT STRING IS NOT VALID!!! region \(regionalEnvironment)"
			let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)
			assert(VGSCollect.regionalEnironmentStringValid(regionalEnvironment), "❗VGSCollectSDK CONFIGURATION ERROR: ENVIRONMENT STRING IS NOT VALID!!!")
		}

		// Check tenant is valid.
		if !VGSCollect.tenantIDValid(tenantId) {
			let eventText = "CONFIGURATION ERROR: TENANT ID IS NOT VALID OR NOT SET!!! tenant: \(tenantId)"
			let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)
			assert(VGSCollect.tenantIDValid(tenantId), "❗VGSCollectSDK CONFIGURATION ERROR: : TENANT ID IS NOT VALID!!!")
		}
    
    let strUrl: String
    // Check is routeId is set and valid.
    if let routeId = routeId, !routeId.isEmpty {
      // Validate routeId is valid UUID string.
      guard UUID(uuidString: routeId) != nil else {
        let eventText = "CONFIGURATION ERROR: NOT VALID ROUTE ID PARAMETER!!! routeId: \(routeId), tenantID: \(tenantId), environment: \(regionalEnvironment)"
        let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
        VGSCollectLogger.shared.forwardLogEvent(event)
          assertionFailure("❗VGSCollectSDK CONFIGURATION ERROR: : NOT VALID ROUTE ID PARAMETER!!!")
        return nil
      }
      // Build url with specifi route id.
      strUrl = "https://" + tenantId + "-" + "\(routeId)" + "." + regionalEnvironment + ".verygoodproxy.com"
    } else {
      // Build default url.
      strUrl = "https://" + tenantId + "." + regionalEnvironment + ".verygoodproxy.com"
    }

		// Check vault url is valid.
		guard let url = URL(string: strUrl) else {
			assertionFailure("❗VGSCollectSDK CONFIGURATION ERROR: : NOT VALID ORGANIZATION PARAMETERS!!!")

			let eventText = "CONFIGURATION ERROR: NOT VALID ORGANIZATION PARAMETERS!!! tenantID: \(tenantId), environment: \(regionalEnvironment)"
			let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)

			return nil
		}
		return url
	}
}
