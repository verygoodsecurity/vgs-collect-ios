//
//  APIClient.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

class APIClient {

    var customHeader: HTTPHeaders?

    private let vaultId: String
    private let vaultUrl: URL?

    private static let hostValidatorUrl = "https://js.verygoodvault.com/collect-configs"

    private let formAnalyticDetails: VGSFormAnanlyticsDetails

	  /// Base URL.
		internal var baseURL: URL? {
			return self.hostURLPolicy.url
		}

	  /// Host URL policy. Determinates final URL to send Collect requests.
		internal var hostURLPolicy: APIHostURLPolicy

    /// Serial queue for syncing requests on resolving hostname flow.
    private let dataSyncQueue: DispatchQueue = .init(label: "iOS.VGSCollect.ResolveHostNameRequestsQueue")

	  /// Semaphore for sync logic.
    private let syncSemaphore: DispatchSemaphore = .init(value: 1)
  
    internal static let defaultHttpHeaders: HTTPHeaders = {
        // Add Headers.
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

				let trStatus = VGSAnalyticsClient.shared.shouldCollectAnalytics ? "default" : "none"

        return [
          "vgs-client": "source=iosSDK&medium=vgs-collect&content=\(Utils.vgsCollectVersion)&osVersion=\(versionString)&vgsCollectSessionId=\(VGSAnalyticsClient.shared.vgsCollectSessionId)&tr=\(trStatus)"
        ]
    }()

  required init(tenantId: String, regionalEnvironment: String, hostname: String?, formAnalyticsDetails: VGSFormAnanlyticsDetails) {
      self.vaultUrl = Self.buildVaultURL(tenantId: tenantId, regionalEnvironment: regionalEnvironment)
      self.vaultId = tenantId
      self.formAnalyticDetails = formAnalyticsDetails
    
			guard let hostnameToResolve = hostname, !hostnameToResolve.isEmpty else {
				self.hostURLPolicy = .vaultURL(vaultUrl)
				return
			}

			self.hostURLPolicy = .customHostURL(.isResolving(hostnameToResolve))
			updateHost(with: hostnameToResolve)
    }

    // MARK: - Send request

	func sendRequest(path: String, method: HTTPMethod = .post, value: BodyData, completion block: ((_ response: VGSResponse) -> Void)? ) {

		let sendRequestBlock: (URL) -> Void = {requestURL in
			let url = requestURL.appendingPathComponent(path)
			self.sendRequest(to: url, method: method, value: value, completion: block)
		}

		switch hostURLPolicy {
		case .vaultURL(let url):
			sendRequestBlock(url)
		case .customHostURL(let status):
			switch status {
			case .resolved(let resolvedURL):
				sendRequestBlock(resolvedURL)
			case .useDefaultVault(let defaultVaultURL):
				sendRequestBlock(defaultVaultURL)
			case .isResolving(let hostnameToResolve):
				updateHost(with: hostnameToResolve) { (url) in
					sendRequestBlock(url)
				}
			}
		}
	}

   private  func sendRequest(to url: URL, method: HTTPMethod = .post, value: BodyData, completion block: ((_ response: VGSResponse) -> Void)? ) {
      
        // Add headers.
        var headers = APIClient.defaultHttpHeaders
        headers["Content-Type"] = "application/json"
        // Add custom headers if needed.
        if let customerHeaders = customHeader, customerHeaders.count > 0 {
            customerHeaders.keys.forEach({ (key) in
                headers[key] = customerHeaders[key]
            })
        }
        // Setup URLRequest.
        let jsonData = try? JSONSerialization.data(withJSONObject: value)
        var request = URLRequest(url: url)
        request.httpBody = jsonData
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
    
        // Log request.
        VGSCollectRequestLogger.logRequest(request, payload: value)
    
        // Send data.
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: error.code)
                    block?(.failure(error.code, data, response, error))
                    return
                }
              let statusCode = (response as? HTTPURLResponse)?.statusCode ?? VGSErrorType.unexpectedResponseType.rawValue
                
                switch statusCode {
                case 200..<300:
                    VGSCollectRequestLogger.logSuccessResponse(response, data: data, code: statusCode)
                    block?(.success(statusCode, data, response))
                    return
                default:
                    VGSCollectRequestLogger.logErrorResponse(response, data: data, error: error, code: statusCode)
                    block?(.failure(statusCode, data, response, error))
                    return
                }
            }
        }.resume()
    }
}

extension APIClient {
  
  // MARK: - Vault Url
  
  /// Generates API URL with vault id, environment and data region.
  private static func buildVaultURL(tenantId: String, regionalEnvironment: String) -> URL {
    
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
    
      let strUrl = "https://" + tenantId + "." + regionalEnvironment + ".verygoodproxy.com"
    
      // Check vault url is valid.
      guard let url = URL(string: strUrl) else {
        let eventText = "CONFIGURATION ERROR: NOT VALID ORGANIZATION PARAMETERS!!! tenantID: \(tenantId), environment: \(regionalEnvironment)"
        let event = VGSLogEvent(level: .warning, text: eventText, severityLevel: .error)
        VGSCollectLogger.shared.forwardLogEvent(event)
        
        fatalError("❗VGSCollectSDK CONFIGURATION ERROR: : NOT VALID ORGANIZATION PARAMETERS!!!")

      }
      return url
  }
  
  // MARK: - Custom Host Name

  private func updateHost(with hostname: String, completion: ((URL) -> Void)? = nil) {

		dataSyncQueue.async {

			// Enter sync zone.
			self.syncSemaphore.wait()

			// Check if we already have URL. If yes, don't fetch it the same time.
			if let url = self.hostURLPolicy.url {
				completion?(url)
				// Quite sync zone.
				self.syncSemaphore.signal()
				return
			}

			// Resolve hostname.
			APIHostnameValidator.validateCustomHostname(hostname, tenantId: self.vaultId) {[weak self](url) in
				if var validUrl = url {

					// Update url scheme if needed.
					if !APIHostnameValidator.hasSecureScheme(url: validUrl), let secureURL = APIHostnameValidator.urlWithSecureScheme(from: validUrl) {
						validUrl = secureURL
					}

					self?.hostURLPolicy = .customHostURL(.resolved(validUrl))
          completion?(validUrl)

					// Exit sync zone.
					self?.syncSemaphore.signal()
          if let strongSelf = self {
            
            let text = "✅ Success! VGSSCollectSDK hostname \(hostname) has been successfully resolved and will be used for requests!"
            let event = VGSLogEvent(level: .info, text: text)
            VGSCollectLogger.shared.forwardLogEvent(event)
            
            VGSAnalyticsClient.shared.trackFormEvent(strongSelf.formAnalyticDetails, type: .hostnameValidation, status: .success, extraData: ["hostname": hostname])
          }
          return
        } else {
					guard let strongSelf = self else {
						return
					}
					strongSelf.hostURLPolicy = .customHostURL(.useDefaultVault(strongSelf.vaultUrl))
          completion?(strongSelf.vaultUrl)

					// Exit sync zone.
					strongSelf.syncSemaphore.signal()
          
          let text = "VAULT URL WILL BE USED!"
          let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
          VGSCollectLogger.shared.forwardLogEvent(event)
          
          VGSAnalyticsClient.shared.trackFormEvent(strongSelf.formAnalyticDetails, type: .hostnameValidation, status: .failed, extraData: ["hostname": hostname])
          return
        }
      }
		}
	}
}
