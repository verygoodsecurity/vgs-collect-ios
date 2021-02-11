//
//  APIClient.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

/// Key-value data type, usually used for response format.
public typealias JsonData = [String: Any]

/// Key-value data type, used in http request headers.
public typealias HTTPHeaders = [String: String]

/// Key-value data type, for internal use.
internal typealias BodyData = [String: Any]

/// HTTP request methods
public enum HTTPMethod: String {
    /// GET method.
    case get     = "GET"
    /// POST method.
    case post    = "POST"
    /// PUT method.
    case put     = "PUT"
    /// PATCH method.
    case patch = "PATCH"
    /// DELETE method.
    case delete = "DELETE"
}

/// Response enum cases for SDK requests
@frozen public enum VGSResponse {
    /**
     Success response case
     
     - Parameters:
        - code: response status code.
        - data: response **data** object.
        - response: URLResponse object represents a URL load response.
    */
    case success(_ code: Int, _ data: Data?, _ response: URLResponse?)
    
    /**
     Failed response case
     
     - Parameters:
        - code: response status code.
        - data: response **Data** object.
        - response: `URLResponse` object represents a URL load response.
        - error: `Error` object.
    */
    case failure(_ code: Int, _ data: Data?, _ response: URLResponse?, _ error: Error?)
}

class APIClient {

    var customHeader: HTTPHeaders?

    private let vaultId: String
    private let vaultUrl: URL
    private static let hostValidatorUrl = "https://js.verygoodvault.com/collect-configs"
    private let formAnalyticDetails: VGSFormAnanlyticsDetails

	  /// Determinates hostname status states.
		enum CustomHostStatus {
			/**
			 Resolving host name is in progress.

			 - Parameters:
					- hostnameToResolve: `String` object, hostname to resolve.
			*/
			case isResolving(_ hostnameToResolve: String)

			/**
			 Hostname is resolved and can be used for requests.

			 - Parameters:
					- resolvedURL: `URL` object, resolved host name URL.
			*/
			case resolved(_ resolvedURL: URL)

			/**
			 Hostname cannot be resolved, default vault URL will be used.

			 - Parameters:
					- vaultURL: `URL` object, should be default vault URL.
			*/
			case useDefaultVault(_ vaultURL: URL)

			var url: URL? {
				switch self {
				case .isResolving:
					return nil
				case .useDefaultVault(let defaultVaultURL):
					return defaultVaultURL
				case .resolved(let resolvedURL):
					return resolvedURL
				}
			}
		}

	  /// Determinates host URL policy for sending Collect requests.
		enum HostURLPolicy {
			/**
			 Use vault url, custom hostname not set.

			 - Parameters:
					- url: `URL` object, default vault URL.
			*/
			case vaultURL(_ vaultURL: URL)

			/**
			 Custom host URL.

			 - Parameters:
					- status: `CustomHostStatus` object, hostname status.
			*/
			case customHostURL(_ status: CustomHostStatus)

			var url: URL? {
				switch self {
				case .vaultURL(let vaultURL):
					return vaultURL
				case .customHostURL(let hostStatus):
					return hostStatus.url
				}
			}
		}

		internal var baseURL: URL? {
			return self.hostURLPolicy.url
		}

	  /// Host URL policy. Determinates final URL to send Collect requests.
		internal var hostURLPolicy: HostURLPolicy

    /// Serial queue for syncing requests on resolving hostname flow.
    private let dataSyncQueue: DispatchQueue = .init(label: "iOS.VGSCollect.ResolveHostNameRequestsQueue")
    private let syncSemaphore: DispatchSemaphore = .init(value: 1)
  
    internal static let defaultHttpHeaders: HTTPHeaders = {
        // Add Headers
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
      
        // Add Headers
        var headers = APIClient.defaultHttpHeaders
        headers["Content-Type"] = "application/json"
        // Add custom headers if need
        if let customerHeaders = customHeader, customerHeaders.count > 0 {
            customerHeaders.keys.forEach({ (key) in
                headers[key] = customerHeaders[key]
            })
        }
        // Setup URLRequest
        let jsonData = try? JSONSerialization.data(withJSONObject: value)
        var request = URLRequest(url: url)
        request.httpBody = jsonData
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        // Send data
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    block?(.failure(error.code, data, response, error))
                    return
                }
              let statusCode = (response as? HTTPURLResponse)?.statusCode ?? VGSErrorType.unexpectedResponseType.rawValue
                
                switch statusCode {
                case 200..<300:
                    block?(.success(statusCode, data, response))
                    return
                default:
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
      assert(VGSCollect.regionalEnironmentStringValid(regionalEnvironment), "ENVIRONMENT STRING IS NOT VALID!!!")
      assert(VGSCollect.tenantIDValid(tenantId), "ERROR: TENANT ID IS NOT VALID!!!")
    
      let strUrl = "https://" + tenantId + "." + regionalEnvironment + ".verygoodproxy.com"
      guard let url = URL(string: strUrl) else {
          fatalError("ERROR: NOT VALID ORGANIZATION PARAMETERS!!!")
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
          VGSAnalyticsClient.shared.trackFormEvent(strongSelf.formAnalyticDetails, type: .hostnameValidation, status: .failed, extraData: ["hostname": hostname])
          return
        }
      }
		}
	}
}
