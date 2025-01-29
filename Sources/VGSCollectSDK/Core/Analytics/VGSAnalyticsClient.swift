//
//  VGSAnalyticsClient.swift
//  VGSCollectSDK
//
//  Created by Dima on 03.09.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import VGSClientSDKAnalytics
#if canImport(UIKit)
import UIKit
#endif

/// Client responsably for managing and sending VGS Collect SDK analytics events.
/// Note: we track only VGSCollectSDK usage and features statistics.
/// :nodoc:
public class VGSAnalyticsClient {
  
  internal enum Constants {
    enum Metadata {
      static let source = "iosSDK"
      static let medium = "vgs-collect"
    }
  }
  
  /// Shared `VGSAnalyticsClient` instance
  public static let shared = VGSAnalyticsClient()
  
  private let sharedAnalyticsManager = VGSSharedAnalyticsManager(
    source: Constants.Metadata.source,
    sourceVersion: osVersion,
    dependencyManager: sdkIntegration)
  
  private var _shouldCollectAnalytics: Bool = true
  
  /// Enable or disable VGS analytics tracking
  public var shouldCollectAnalytics: Bool {
    get {
      return _shouldCollectAnalytics
    }
    set {
      _shouldCollectAnalytics = newValue
      sharedAnalyticsManager.setIsEnabled(isEnabled: newValue)
    }
  }
  
  private init() {}

  /// :nodoc: Track events related to specific VGSCollect instance
  public func capture(_ form: VGSFormAnanlyticsDetails = VGSFormAnanlyticsDetails(formId: "", tenantId: "", environment: ""), event: VGSAnalyticsEvent) {
    sharedAnalyticsManager.capture(vault: form.tenantId, environment: form.environment, formId: form.formId, event: event)
  }

  private static var osVersion: String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }
  
	/// SDK integration tool.
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
