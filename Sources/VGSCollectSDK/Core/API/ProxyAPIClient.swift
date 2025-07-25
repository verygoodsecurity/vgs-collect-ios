//
//  APIClient.swift
//  VGSCollectSDK
//

import Foundation

class ProxyAPIClient: VGSAPIClientProtocol {
  func setCustomHeaders(headers: HTTPHeaders?) {
    self.customHeader = headers
  }
  

	/// Additional custom headers.
	var customHeader: HTTPHeaders?

  /// Vault Id.
	private let vaultId: String
  
  /// Environment.
  private let environment: String

	/// Vault URL.
	private let vaultUrl: URL?

	/// Form analytics details.
	private(set) internal var formAnalyticDetails: VGSFormAnanlyticsDetails

	/// Base URL.
	internal var baseURL: URL? {
		return self.hostURLPolicy.url
	}

	/// URL session object with `.ephemeral` configuration.
	internal let urlSession = URLSession(configuration: .ephemeral)

	/// Host URL policy. Determinates final URL to send Collect requests.
	internal var hostURLPolicy: APIHostURLPolicy

	/// Serial queue for syncing requests on resolving hostname flow.
	private let dataSyncQueue: DispatchQueue = .init(label: "iOS.VGSCollect.ResolveHostNameRequestsQueue")

	/// Semaphore for sync logic.
	private let syncSemaphore: DispatchSemaphore = {
		// DispatchSemaphore checks to see whether the semaphore’s associated value is less at deinit than at init, and if so, it fails. In short, if the value is less, libDispatch concludes that the semaphore is still being used.
		// https://stackoverflow.com/a/70458886

		// Semantically the same as DispatchSemaphore(value: 1) but does not crash on deinit/dealloc if its current value != 1.
		// See https://lists.apple.com/archives/cocoa-dev/2014/Apr/msg00484.html.
		let semaphore = DispatchSemaphore(value: 0)
		semaphore.signal()
		return semaphore
	}()

	/// Default headers.
    @MainActor
    internal static let defaultHttpHeaders: HTTPHeaders = {
		// Add Headers.
		let version = ProcessInfo.processInfo.operatingSystemVersion
		let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

		let trStatus = VGSAnalyticsClient.shared.shouldCollectAnalytics ? "default" : "none"

		return [
			"vgs-client": "source=iosSDK&medium=vgs-collect&content=\(Utils.vgsCollectVersion)&osVersion=\(versionString)&vgsCollectSessionId=\(VGSAnalyticsClient.shared.vgsCollectSessionId)&tr=\(trStatus)"
		]
	}()

	/// Initialization.
	/// - Parameters:
	///   - tenantId: `String` object, should be valid tenant id.
	///   - regionalEnvironment: `String` object, should be valid environment.
	///   - hostname: `String?` object, should be valid hostname or `nil`.
	///   - formAnalyticsDetails: `VGSFormAnanlyticsDetails` object, analytics data.
	required init(tenantId: String, regionalEnvironment: String, hostname: String?, formAnalyticsDetails: VGSFormAnanlyticsDetails) {
		self.vaultUrl = Self.buildVaultURL(tenantId: tenantId, regionalEnvironment: regionalEnvironment)
		self.vaultId = tenantId
    self.environment = regionalEnvironment
		self.formAnalyticDetails = formAnalyticsDetails

		guard let validVaultURL = vaultUrl else {
			// Cannot resolve hostname with invalid Vault URL.
			self.hostURLPolicy = .invalidVaultURL
			return
		}

		guard let hostnameToResolve = hostname, !hostnameToResolve.isEmpty else {

			if let name = hostname, name.isEmpty {
				let message = "Hostname is invalid (empty) and will be ignored. Default Vault URL will be used."
				let event = VGSLogEvent(level: .warning, text: message, severityLevel: .error)
				VGSCollectLogger.shared.forwardLogEvent(event)
			}

			// Use vault URL.
			self.hostURLPolicy = .vaultURL(validVaultURL)
			return
		}

		self.hostURLPolicy = .customHostURL(.isResolving(hostnameToResolve))
		updateHost(with: hostnameToResolve)
	}

	// MARK: - Send request

  func sendRequest(path: String, method: VGSCollectHTTPMethod = .post, routeId: String? = nil, value: BodyData, completion block: ((_ response: VGSResponse) -> Void)? ) {

    let sendRequestBlock: (URL?) -> Void = {url in
			guard var requestURL = url else {
				let message = "CONFIGURATION ERROR: NOT VALID ORGANIZATION PARAMETERS!!! CANNOT BUILD URL!!!"
				let event = VGSLogEvent(level: .warning, text: message, severityLevel: .error)
				VGSCollectLogger.shared.forwardLogEvent(event)
				let invalidURLError = VGSError(type: .invalidConfigurationURL)
				block?(.failure(invalidURLError.code, nil, nil, invalidURLError))
				return
			}

      // Check if routeId is set and should be attached to request url
      if case .vaultURL = self.hostURLPolicy,
         let routeId = routeId {
        
        guard let newUrl = ProxyAPIClient.buildVaultURL(tenantId: self.vaultId, regionalEnvironment: self.environment, routeId: routeId) else {
          let invalidURLError = VGSError(type: .invalidConfigurationURL)
          block?(.failure(invalidURLError.code, nil, nil, invalidURLError))
          return
        }
        requestURL = newUrl
      }
    
			let url = requestURL.appendingPathComponent(path)
        self.sendRequest(to: url, method: method, value: value, block: block)
		}

		switch hostURLPolicy {
		case .invalidVaultURL:
			sendRequestBlock(nil)
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

    @MainActor private  func sendRequest(to url: URL, method: VGSCollectHTTPMethod = .post, value: BodyData, block: ((_ response: VGSResponse) -> Void)? ) {

		// Add headers.
        var headers = ProxyAPIClient.defaultHttpHeaders
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
        urlSession.dataTask(with: request) { (data, response, error) in
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

extension ProxyAPIClient {

  private func updateHost(with hostname: String, completion: ((URL) -> Void)? = nil) {
    dataSyncQueue.async { [weak self] in
      guard let self = self else { return }

      // Copy Sendable values outside the async closure
      let tenantId = self.vaultId
      let fallbackURL = self.vaultUrl

      // Enter sync zone
      self.syncSemaphore.wait()

      // Check cache on MainActor
      Task { @MainActor in
        if let cachedURL = self.hostURLPolicy.url {
          completion?(cachedURL)
          self.syncSemaphore.signal()
          return
        }

      APIHostnameValidator.validateCustomHostname(hostname, tenantId: tenantId) { resolvedURL in
          // Determine final URL
          let finalURL: URL
          if var url = resolvedURL {
            if !url.hasSecureScheme(), let secure = URL.urlWithSecureScheme(from: url) {
              url = secure
            }
            self.hostURLPolicy = .customHostURL(.resolved(url))
            finalURL = url

            let logMsg = "✅ Success! VGSSCollectSDK hostname \(hostname) has been successfully resolved and will be used for requests!"
            let event = VGSLogEvent(level: .info, text: logMsg)
            VGSCollectLogger.shared.forwardLogEvent(event)

            VGSAnalyticsClient.shared.trackFormEvent(
              self.formAnalyticDetails,
              type: .hostnameValidation,
              status: .success,
              extraData: ["hostname": hostname]
            )

          } else {
            guard let fallback = fallbackURL else {
              let errMsg = "No VGSCollect instance and no valid URL"
              let event = VGSLogEvent(level: .warning, text: errMsg, severityLevel: .error)
              VGSCollectLogger.shared.forwardLogEvent(event)
              self.syncSemaphore.signal()
              return
            }

            self.hostURLPolicy = .customHostURL(.useDefaultVault(fallback))
            finalURL = fallback

            let warnMsg = "VAULT URL WILL BE USED!"
            let event = VGSLogEvent(level: .warning, text: warnMsg, severityLevel: .error)
            VGSCollectLogger.shared.forwardLogEvent(event)

            VGSAnalyticsClient.shared.trackFormEvent(
              self.formAnalyticDetails,
              type: .hostnameValidation,
              status: .failed,
              extraData: ["hostname": hostname]
            )
          }
          self.syncSemaphore.signal()
          completion?(finalURL)
        }
      }
    }
  }
}
