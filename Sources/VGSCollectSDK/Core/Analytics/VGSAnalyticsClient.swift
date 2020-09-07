//
//  VGSAnalyticsClient.swift
//  VGSCollectSDK
//
//  Created by Dima on 03.09.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

protocol BaseAnalyticsEventProtocol {
  var formID: String { get }
  var tnt: String { get }
  var env: String { get }
  var type: String { get }
}

struct AnyTrackingEvent: BaseAnalyticsEventProtocol {
  
  let formID: String
  let tnt: String
  let env: String
  let type: String
  
  var optionalInfo: [String: Any]?
  
  func map() {}
  
}

public class VGSAnalyticsClient {
  public static let shared = VGSAnalyticsClient()
  public var shouldCollectAnalytics = true
  
  public func trackFormEvent(_ form: VGSCollect, details: [String: Any]) {
    let env = (form.dataRegion != nil) ? "\(form.environment.rawValue)-\(form.dataRegion ?? "")" : form.environment.rawValue
    let formDetails = ["formId": form.formId,
                       "tnt": form.tenantId,
                       "env": env
                      ]
    let data = deepMerge(formDetails, details)
    sendAnalyticsRequest(data: data)
  }
  
  public func trackEvent(_ details: [String: Any]) {
      sendAnalyticsRequest(data: details)
  }
  
  
  internal let baseURL = "https://vgs-collect-keeper.verygoodsecurity.io"
  
  internal let defaultHttpHeaders: HTTPHeaders = {
    return [ "Origin": "https://js.verygoodvault.io",
             "Content-Type": "application/x-www-form-urlencoded" ]
  }()
  
  internal static let userAgentData: [String: Any] = {
      // Add Headers
      let version = ProcessInfo.processInfo.operatingSystemVersion
      let osVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
      return [ "ua" : [
                  "platform": UIDevice.current.systemName,
                  "device" : UIDevice.current.model,
                  "versionOS": osVersion ]
              ]
  }()
  
  internal let vgsCollectVersion: String = {
      guard let vgsInfo = Bundle(for: APIClient.self).infoDictionary,
          let build = vgsInfo["CFBundleShortVersionString"]
          else {
              return "Unknown"
      }
      return "\(build)"
  }()


  public func  sendAnalyticsRequest(method: HTTPMethod = .post, path: String = "vgs", data: [String: Any] ) {
      
      // Setup URLRequest
      guard let url = URL(string: baseURL)?.appendingPathComponent(path) else {
        return
      }
      var request = URLRequest(url: url)
      request.httpMethod = method.rawValue
      request.allHTTPHeaderFields = VGSAnalyticsClient.shared.defaultHttpHeaders

      // Add User Agent data
      var resultDict = deepMerge(data, VGSAnalyticsClient.userAgentData)
      resultDict["version"] = VGSAnalyticsClient.shared.vgsCollectVersion
      let jsonData = try? JSONSerialization.data(withJSONObject: resultDict, options: .prettyPrinted)
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
