//
//  VGSAnalyticsClient.swift
//  VGSCollectSDK
//
//  Created by Dima on 03.09.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// :nodoc: Client responsably for managing and sending analytics events.
public class VGSAnalyticsClient {
  
  public enum AnalyticEventStatus: String {
    case success = "Ok"
    case failed = "Failed"
  }
  
  public static let shared = VGSAnalyticsClient()
  public var shouldCollectAnalytics = true
  
  private init() {}
  
  internal let baseURL = "https://5072a069c86f.ngrok.io"
  
  internal let defaultHttpHeaders: HTTPHeaders = {
    return [ "Origin": "https://js.verygoodvault.io",
             "Content-Type": "application/x-www-form-urlencoded" ]
  }()
  
  internal static let userAgentData: [String: Any] = {
      let version = ProcessInfo.processInfo.operatingSystemVersion
      let osVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
      return [
              "platform": UIDevice.current.systemName,
              "device" : UIDevice.current.model,
              "osVersion": osVersion ]
      }()
  
  internal let vgsCollectVersion: String = {
      guard let vgsInfo = Bundle(for: APIClient.self).infoDictionary,
          let build = vgsInfo["CFBundleShortVersionString"]
          else {
              return "Unknown"
      }
      return "\(build)"
  }()

  /// :nodoc: Track events related to specific VGSCollect instance
  public func trackFormEvent(_ form: VGSCollect, type: String, status: AnalyticEventStatus = .success, extraData: [String: Any]? = nil) {
    let env = (form.dataRegion != nil) ? "\(form.environment.rawValue)-\(form.dataRegion ?? "")" : form.environment.rawValue
    let formDetails = ["formId": form.formId,
                       "tnt": form.tenantId,
                       "env": env
                      ]
    let data: [String: Any]
    if let extraData = extraData {
      data = deepMerge(formDetails, extraData)
    } else {
      data = formDetails
    }
    trackEvent(type, status: status, extraData: data)
  }
  
  /// :nodoc: Base function to Track analytics event
  public func trackEvent(_ type: String, status: AnalyticEventStatus = .success, extraData: [String: Any]? = nil) {
      var data = [String: Any]()
      if let extraData = extraData {
        data = extraData
      }
      data["type"] = type
      data["status"] = status.rawValue
      data["ua"] = VGSAnalyticsClient.userAgentData
      data["version"] = VGSAnalyticsClient.shared.vgsCollectVersion
      data["source"] = "iosSDK"
      sendAnalyticsRequest(data: data)
  }

  internal func sendAnalyticsRequest(method: HTTPMethod = .post, path: String = "vgs", data: [String: Any] ) {
    
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
      request.allHTTPHeaderFields = VGSAnalyticsClient.shared.defaultHttpHeaders

      let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
      let encodedJSON = jsonData?.base64EncodedData()
      request.httpBody = encodedJSON
    
      // Send data
      URLSession.shared.dataTask(with: request) { (data, response, error) in

          let statusCode = (response as? HTTPURLResponse)?.statusCode ?? VGSErrorType.unexpectedResponseType.rawValue

          switch statusCode {
          case 200..<300:
              return
          default:
              return
          }
      }.resume()
  }
}
