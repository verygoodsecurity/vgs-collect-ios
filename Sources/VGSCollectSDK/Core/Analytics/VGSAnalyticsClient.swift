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

/// VGS Analytics event types produced by the SDK.
public enum VGSAnalyticsEventType: String {
  /// Event type for form initialization.
  case fieldInit = "Init"
  /// Event type for hostname validation.
  case hostnameValidation = "HostNameValidation"
  /// Event type for actions before form submission.
  case beforeSubmit = "BeforeSubmit"
  /// Event type for form submission.
  case submit = "Submit"
  /// Event type for scanning actions.
  case scan = "Scan"
}

/// Client responsible for managing and sending VGS Collect SDK analytics events.
/// Note: Only anonymized usage and feature statistics are tracked. No sensitive user data is collected.
/// :nodoc:
public class VGSAnalyticsClient {
  
  /// Status for an analytics event.
  public enum AnalyticEventStatus: String {
    /// Operation finished successfully.
    case success = "Ok"
    /// Operation failed.
    case failed = "Failed"
    /// Operation was canceled by user or programmatically.
    case cancel = "Cancel"
  }
  
  /// Shared singleton `VGSAnalyticsClient` instance.
  @MainActor
  public static let shared = VGSAnalyticsClient()
  
  /// Flag controlling whether analytics events should be collected and sent. Defaults to `true`.
  /// Set to `false` to completely disable analytics tracking.
  public var shouldCollectAnalytics = true

    /// URL session object with ephemeral configuration used for sending analytics requests.
    internal let urlSession = URLSession(configuration: .ephemeral)

  /// Unique identifier generated once per application runtime session. Included with every analytics event.
  public let vgsCollectSessionId = UUID().uuidString
  
  private init() {}
  
  internal let baseURL = "https://vgs-collect-keeper.apps.verygood.systems/"
  
  internal let defaultHttpHeaders: HTTPHeaders = {
    return ["Content-Type": "application/x-www-form-urlencoded" ]
  }()
  
    @MainActor
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

  /// Tracks an analytics event bound to a specific VGS form instance.
  /// - Parameters:
  ///   - form: Form analytics details container.
  ///   - type: Event type to track.
  ///   - status: Operation status. Defaults to `.success`.
  ///   - extraData: Optional additional key-value data to merge into the event payload.
    @MainActor
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
    trackEvent(type, status: status, extraData: data)
  }

  /// Base function to track an analytics event not tied to a specific form.
  /// - Parameters:
  ///   - type: Event type to track.
  ///   - status: Operation status. Defaults to `.success`.
  ///   - extraData: Optional additional key-value data.
    @MainActor
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

    /// SDK integration tool value resolved at compile time.
    private static var sdkIntegration: String {
        #if COCOAPODS
            return "COCOAPODS"
        #elseif SWIFT_PACKAGE
      return "SPM"
        #else
      return "OTHER"
        #endif
    }
}

internal extension VGSAnalyticsClient {
  
  // send events
  func sendAnalyticsRequest(method: VGSCollectHTTPMethod = .post, path: String = "vgs", data: [String: Any] ) {
    
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
            urlSession.dataTask(with: request).resume()
  }
}
