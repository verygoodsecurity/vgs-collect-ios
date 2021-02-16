//
//  APIClient.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

class APIClient {

	/// Additional custom headers.
	var customHeader: HTTPHeaders?

  /// Vault Id.
	private let vaultId: String

	/// Vault URL.
	private let vaultUrl: URL?

	/// Form analytics details.
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

	/// Default headers.
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

	func sendRequest(path: String, method: HTTPMethod = .post, value: BodyData, completion block: ((_ response: VGSResponse) -> Void)? ) {

		let sendRequestBlock: (URL?) -> Void = {url in
			guard let requestURL = url else {
				let message = "CONFIGURATION ERROR: NOT VALID ORGANIZATION PARAMETERS!!! CANNOT BUILD URL!!!"
				let event = VGSLogEvent(level: .warning, text: message, severityLevel: .error)
				VGSCollectLogger.shared.forwardLogEvent(event)

				let invalidURLError = VGSError(type: .invalidConfigurationURL)
				block?(.failure(invalidURLError.code, nil, nil, invalidURLError))
				return
			}

			let url = requestURL.appendingPathComponent(path)
			self.sendRequest(to: url, method: method, value: value, completion: block)
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
					if !validUrl.hasSecureScheme(), let secureURL = URL.urlWithSecureScheme(from: validUrl) {
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
					guard let strongSelf = self, let validVaultURL = self?.vaultUrl else {
						let text = "No VGSCollect instance and any valid url"
						let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
						VGSCollectLogger.shared.forwardLogEvent(event)
						return
					}

					strongSelf.hostURLPolicy = .customHostURL(.useDefaultVault(validVaultURL))
					completion?(validVaultURL)

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
