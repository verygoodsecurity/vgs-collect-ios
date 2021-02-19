//
//  VGSAnalyticsClient.swift
//  VGSCollectSDK
//
//  Created by Dima on 03.09.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// :nodoc: VGS Analytics event type
public enum VGSAnalyticsEventType: String {
  case fieldInit = "Init"
  case hostnameValidation = "HostNameValidation"
  case beforeSubmit = "BeforeSubmit"
  case submit = "Submit"
  case scan = "Scan"
}

/// Client responsably for managing and sending VGS Collect SDK analytics events.
/// Note: we track only VGSCollectSDK usage and features statistics.
/// :nodoc:
public class VGSAnalyticsClient {
  
  public enum AnalyticEventStatus: String {
    case success = "Ok"
    case failed = "Failed"
    case cancel = "Cancel"
  }
  
  /// Shared `VGSAnalyticsClient` instance
  public static let shared = VGSAnalyticsClient()
  
  /// Enable or disable VGS analytics tracking
  public var shouldCollectAnalytics = true
  
  /// Uniq id that should stay the same during application rintime
  public let vgsCollectSessionId = UUID().uuidString
  
  private init() {}
  
  internal let baseURL = "https://vgs-collect-keeper.apps.verygood.systems/"
  
  internal let defaultHttpHeaders: HTTPHeaders = {
    return ["Content-Type": "application/x-www-form-urlencoded" ]
  }()
  
  internal static let userAgentData: [String: Any] = {
      let version = ProcessInfo.processInfo.operatingSystemVersion
      let osVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

			var defaultUserAgentData = [
				"platform": UIDevice.current.systemName,
				"device": UIDevice.current.model,
				"deviceModel": UIDevice.current.modelIdentifier,
				"osVersion": osVersion,
				"dependencyManager": sdkIntegration]

				if let locale = Locale.preferredLanguages.first {
					defaultUserAgentData["deviceLocale"] = locale
				}

      return defaultUserAgentData
      }()

  /// :nodoc: Track events related to specific VGSCollect instance
  public func trackFormEvent(_ form: VGSFormAnanlyticsDetails, type: VGSAnalyticsEventType, status: AnalyticEventStatus = .success, extraData: [String: Any]? = nil) {
      let formDetails = ["formId": form.formId,
                         "tnt": form.tenantId,
                         "env": form.environment
                      ]
    var data: [String: Any]
    if let extraData = extraData {
      data = deepMerge(formDetails, extraData)
    } else {
      data = formDetails
    }

		// track only true or both?
		if form.isSatelliteMode == true {
			data["vgsSatellite"] = true
		}
    trackEvent(type, status: status, extraData: data)
  }

  /// :nodoc: Base function to Track analytics event
  public func trackEvent(_ type: VGSAnalyticsEventType, status: AnalyticEventStatus = .success, extraData: [String: Any]? = nil) {
      var data = [String: Any]()
      if let extraData = extraData {
        data = extraData
      }
      data["type"] = type.rawValue
      data["status"] = status.rawValue
      data["ua"] = VGSAnalyticsClient.userAgentData
      data["version"] = Utils.vgsCollectVersion
      data["source"] = "iosSDK"
      data["localTimestamp"] = Int(Date().timeIntervalSince1970 * 1000)
      data["vgsCollectSessionId"] = vgsCollectSessionId
      sendAnalyticsRequest(data: data)
  }

	/// SDK integration tool.
	private static var sdkIntegration: String {
		#if COCOAPODS
			return "COCOAPODS"
		#endif

		#if SWIFT_PACKAGE
			return "SPM"
		#endif

		return "OTHER"
	}
}

internal extension VGSAnalyticsClient {
  
  // send events
  func sendAnalyticsRequest(method: HTTPMethod = .post, path: String = "vgs", data: [String: Any] ) {
    
      // Check if tracking events enabled
      guard shouldCollectAnalytics else {
        return
      }
    
      // Setup URLRequest
      guard let url = URL(string: baseURL)?.appendingPathComponent(path) else {
        return
      }
      var request = URLRequest(url: url)
      request.httpMethod = method.rawValue
      request.allHTTPHeaderFields = defaultHttpHeaders

      let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
      let encodedJSON = jsonData?.base64EncodedData()
      request.httpBody = encodedJSON
      // Send data
      URLSession.shared.dataTask(with: request).resume()
  }
}
