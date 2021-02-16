//
//  APIHostnameValidator.swift
//  VGSCollectSDK
//
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal class APIHostnameValidator {

	/// Constants.
 	internal enum Constants {
		static let validStatuses: Range<Int> = 200..<300
	}

	/// Base validation URL.
	private static let hostValidatorBaseURL = URL(string: "https://js.verygoodvault.com/collect-configs")!

	/// URLSession object.
	static private var session = URLSession(configuration: .ephemeral)

	/// Validate custom hostname.
	/// - Parameters:
	///   - hostname: `String` object, hostname to validate.
	///   - tenantId: `String` object, tenant id.
	///   - completion: `((URL?) -> Void)` completion block.
	internal static func validateCustomHostname(_ hostname: String, tenantId: String, completion: @escaping ((URL?) -> Void)) {

		guard !hostname.isEmpty else {
			completion(nil)
			return
		}

		guard let url = buildHostValidationURL(with: hostname, tenantId: tenantId), let normalizedHostName = hostname.normalizedHostname() else {

			let text = "Cannot build validation URL with tenantId: \"\(tenantId)\", hostname: \"\(hostname)\""
			let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)
			completion(nil)
			return
		}

		performHostnameValidationRequest(with: hostname, normalizedHostName: normalizedHostName, validationURL: url, completion: completion)
	}

	/// Perform hostname validation request.
	/// - Parameters:
	///   - hostname: `String` object, hostname to validate.
	///   - normalizedHostName: `String` object, normalized hostname.
	///   - validationURL: `URL` object, validation URL.
	///   - completion:`((URL?) -> Void)` completion block.
	private static func performHostnameValidationRequest(with hostname: String, normalizedHostName: String, validationURL: URL, completion: @escaping ((URL?) -> Void)) {
		let task = URLRequest(url: validationURL)
		session.dataTask(with: task) { (responseData, response, error) in
			guard let httpResponse = response as? HTTPURLResponse, let data = responseData else {
				let text = "Error! Cannot resolve hostname \"\(hostname)\". Invalid response type!"
				let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
				VGSCollectLogger.shared.forwardLogEvent(event)

				completion(nil)
				return
			}

			if let error = error as NSError? {
				let text = "Error! Cannot resolve hostname \(hostname) Error: \(error)!"
				let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
				VGSCollectLogger.shared.forwardLogEvent(event)

				completion(nil)
				return
			}

			let statusCode = httpResponse.statusCode

			guard Constants.validStatuses.contains(statusCode) else {
				logErrorForStatusCode(statusCode, hostname: hostname)
				completion(nil)
				return
			}

			let responseText = String(decoding: data, as: UTF8.self)

			let eventText = "response text: \"\(responseText)\""
			let event = VGSLogEvent(level: .info, text: eventText)
			VGSCollectLogger.shared.forwardLogEvent(event)

			if responseText.contains(normalizedHostName) {
				completion(URL(string: responseText))
				return
			} else {
				let text = "Error❗Cannot find hostname: \"\(hostname)\" in list: \"\(responseText)\""
				let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
				VGSCollectLogger.shared.forwardLogEvent(event)

				completion(nil)
				return
			}
		}.resume()
	}

	/// Log error for status code.
	/// - Parameters:
	///   - statusCode: `Int` object. Status code error.
	///   - hostname: `String` object, hostname.
	private static func logErrorForStatusCode(_ statusCode: Int, hostname: String) {
		switch statusCode {
		case 403:
			let warningText = "A specified host: \"\(hostname)\" was not correct❗Looks like you don't activate cname for VGSCollect SDK on the Dashboard"
			let event = VGSLogEvent(level: .warning, text: warningText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)
		default:
			let text = "Error❗Cannot resolve hostname \(hostname). Status code \(statusCode)"
			let event = VGSLogEvent(level: .warning, text: text, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)
		}
	}

	/// Build hostname validation URL.
	/// - Parameters:
	///   - hostname: `String` object, custom hostname.
	///   - tenantId: `String` object, tenant id.
	/// - Returns: `URL?` object.
	internal static func buildHostValidationURL(with hostname: String, tenantId: String) -> URL? {

		guard let normalizedHostname = hostname.normalizedHostname() else {return nil}

		let hostPath = "\(normalizedHostname)__\(tenantId).txt"

		let  url = hostValidatorBaseURL.appendingPathComponent(hostPath)

		let eventText = "Final URL to validate custom hostname: \(url.absoluteString)"
		let event = VGSLogEvent(level: .info, text: eventText)
		VGSCollectLogger.shared.forwardLogEvent(event)

		return url
	}
}
