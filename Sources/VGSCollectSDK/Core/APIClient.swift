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
    /// GET method
    case get     = "GET"
    /// POST method
    case post    = "POST"
    /// PUT method
    case put     = "PUT"
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
    case success(_ code:Int, _ data:Data?, _ response: URLResponse?)
    
    /**
     Failed response case
     
     - Parameters:
        - code: response status code.
        - data: response **Data** object.
        - response: `URLResponse` object represents a URL load response.
        - error: `Error` object.
    */
    case failure(_ code:Int, _ data:Data?, _ response: URLResponse?, _ error:Error?)
}

class APIClient {

    var customHeader: HTTPHeaders?

    private let vaultId: String
    private let vaultUrl: URL
    private var hostURL: URL?
    private static let hostValidatorUrl = "https://js.verygoodvault.com/collect-configs"
	  private static let hostValidatorBaseURL = URL(string: "https://js.verygoodvault.com/collect-configs")!

		enum CustomHostStatus {
			case isResolving(_ hostToResolve: String)
			case resolved(_ url: URL)
			case error
		}

		enum HostURLPolicy {
			case vault
			case customHost(_ status: CustomHostStatus)
		}

		internal var hostURLPolicy: HostURLPolicy

//    private var hostName: String? {
//      set {
//        if !newValue.isNilOrEmpty {
//          self.updateHost(with: newValue!)
//        } else {
//          self.hostURL = nil
//        }
//      }
//      get { return  hostURL?.absoluteString }
//    }
    
  
    internal static let defaultHttpHeaders: HTTPHeaders = {
        // Add Headers
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return [
          "vgs-client": "source=iosSDK&medium=vgs-collect&content=\(Utils.vgsCollectVersion)&osVersion=\(versionString)&vgsCollectSessionId=\(VGSAnalyticsClient.shared.vgsCollectSessionId)"
        ]
    }()
  
    required init(tenantId: String, regionalEnvironment: String, hostName: String?) {
      self.vaultUrl = Self.buildVaultURL(tenantId: tenantId, regionalEnvironment: regionalEnvironment)
      self.vaultId = tenantId

			guard let host = hostName else {
				self.hostURLPolicy = .vault
				return
			}

			self.hostURLPolicy = .customHost(.isResolving(host))
			updateHost(with: host)
    }
  
		func getBaseUrl(_ result: ( @escaping (URL) -> Void)) {
			switch hostURLPolicy {
			  // Use vault URL.
				case .vault:
					result(vaultUrl)
					return

				case .customHost(let status):
					switch status {
						// Use resolved custom URL.
						case .resolved(let customHostURL):
							result(customHostURL)
						case .error:
							// Use vault URL.
							result(vaultUrl)
						case .isResolving(let hostName):
							// Try to send request after resolving custom URL.
							updateHost(with: hostName) { [weak self] _ in
								if let strongSelf = self {
									strongSelf.getBaseUrl(result)
								}
							}
					}
			}
		}
  
    // MARK: - Send request

    func sendRequest(path: String, method: HTTPMethod = .post, value: BodyData, completion block: ((_ response: VGSResponse) -> Void)? ) {

			switch hostURLPolicy {
			case .vault:
				let url = vaultUrl.appendingPathComponent(path)
				self.sendRequest(to: url, method: method, value: value, completion: block)
			default:
				getBaseUrl { [weak self](baseURL) in
					let url = baseURL.appendingPathComponent(path)
					self?.sendRequest(to: url, method: method, value: value, completion: block)
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

  private func updateHost(with hostName: String, completion: ((URL?) -> Void)? = nil) {
      Self.buildHostName(hostName, tenantId: vaultId) { [weak self](url) in
        if let validUrl = url {
					self?.hostURLPolicy = .customHost(.resolved(validUrl))
          self?.hostURL = validUrl
          completion?(validUrl)
          return
        } else {
					self?.hostURLPolicy = .customHost(.error)
          completion?(nil)
          return
        }
      }
    }
  
  private static func buildHostName(_ hostName: String, tenantId: String, completion: @escaping ((URL?) -> Void)) {
    
    guard !hostName.isEmpty else {
      completion(nil)
      return
    }

    if let url = buildHostValidationURL(with: hostName, tenantId: tenantId) {
      DispatchQueue.global(qos: .userInitiated).async {
          let contents = try? String(contentsOf: url)
          DispatchQueue.main.async {
            if let contents = contents, contents.contains(hostName) {
              completion(URL(string: hostName))
              return
            } else {
              print("ERROR: NOT VALID HOST NAME!!! WILL USE VAULT URL INSTEAD!!!")
              completion(nil)
              return
            }
          }
       }
    } else {
      completion(nil)
    }
  }

	private static func buildHostValidationURL(with host: String, tenantId: String) -> URL? {

		let hostPath = "\(host)__\(tenantId).txt"
		guard let component = URLComponents(string: hostPath) else {
			// Cannot build component
			return nil
		}

		let url: URL
		if let hostToValid = component.host {
			// Use hostname if component is url with scheme.
			url = hostValidatorBaseURL.appendingPathComponent(hostToValid)
		} else {
			// Use path if component has path only.
			url = hostValidatorBaseURL.appendingPathComponent(component.path)
		}

		print("final url: \(url)")

		return url
	}
}
