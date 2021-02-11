//
//  VGSCollectRequestLogger.swift
//  VGSCollectSDK
//

import Foundation

/// Utilities to log network requests.
internal class VGSCollectRequestLogger {

	/// Log sending request.
	/// - Parameters:
	///   - request: `URLRequest` object, request to send.
	///   - payload: `VGSRequestPayloadBody` object, request payload.
	internal static func logRequest(_ request: URLRequest, payload: JsonData?) {

		if !VGSCollectLogger.shared.configuration.isNetworkDebugEnabled {return}

		print("⬆️ Send VGSCollectSDK request url: \(stringFromURL(request.url))")
		if let headers = request.allHTTPHeaderFields {
			print("⬆️ Send VGSCollectSDK request headers:")
			print(normalizeRequestHeadersForLogs(headers))
		}
		if let payloadValue = payload {
			print("⬆️ Send VGSCollectSDK request payload:")
			print(stringifyRawRequestPayloadForLogs(payloadValue))
		}
		print("------------------------------------")
	}

	/// Log failed request.
	/// - Parameters:
	///   - response: `URLResponse?` object.
	///   - data: `Data?` object of failed request.
	///   - error: `Error?` object, request error.
	///   - code: `Int` object, status code.
	internal static func logErrorResponse(_ response: URLResponse?, data: Data?, error: Error?, code: Int) {

		if !VGSCollectLogger.shared.configuration.isNetworkDebugEnabled {return}

		if let url = response?.url {
			print("❗Failed ⬇️ VGSCollectSDK request url: \(stringFromURL(url))")
		}
		print("❗Failed ⬇️ VGSCollectSDK response status code: \(code)")
		if let httpResponse = response as? HTTPURLResponse {
			print("❗Failed ⬇️ VGSCollectSDK response headers:")
			print(normalizeHeadersForLogs(httpResponse.allHeaderFields))
		}
		if let errorData = data {
			if let bodyErrorText = String(data: errorData, encoding: String.Encoding.utf8) {
				print("❗Failed ⬇️ VGSCollectSDK response extra info:")
				print("\(bodyErrorText)")
			}
		}

		// Track error.
		let errorMessage = (error as NSError?)?.localizedDescription ?? ""

		print("❗Failed ⬇️ VGSCollectSDK response error message: \(errorMessage)")
		print("------------------------------------")
	}

	/// Log success request.
	/// - Parameters:
	///   - response: `URLResponse?` object.
	///   - data: `Data?` object of success request.
	///   - code: `Int` object, status code.
	internal static func logSuccessResponse(_ response: URLResponse?, data: Data?, code: Int) {

		if !VGSCollectLogger.shared.configuration.isNetworkDebugEnabled {return}

		print("✅ Success ⬇️ VGSCollectSDK request url: \(stringFromURL(response?.url))")
		print("✅ Success ⬇️ VGSCollectSDK response code: \(code)")

		if let httpResponse = response as? HTTPURLResponse {
			print("✅ Success ⬇️ VGSCollectSDK response headers:")
			print(normalizeHeadersForLogs(httpResponse.allHeaderFields))
		}

    if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        print("✅ Success ⬇️ VGSCollectSDK response JSON:")
        print(stringifyJSONForLogs(jsonData))
      }
		print("------------------------------------")
	}

	/// Stringify URL.
	/// - Parameter url: `URL?` to stringify.
	/// - Returns: String representation of `URL` string or "".
	private static func stringFromURL(_ url: URL?) -> String {
		guard let requestURL = url else {return ""}
		return requestURL.absoluteString
	}

	/// Utility function to normalize request headers for logging.
	/// - Parameter headers: `[String : String]`, request headers.
	/// - Returns: `String` object, normalized headers string.
	private static func normalizeRequestHeadersForLogs(_ headers: [String: String]) -> String {
		let stringifiedHeaders = headers.map({return "  \($0.key) : \($0.value)"}).joined(separator: "\n  ")

		return "[\n  \(stringifiedHeaders) \n]"
	}

	/// Utility function to normalize response headers for logging.
	/// - Parameter headers: `[AnyHashable : Any]`, response headers.
	/// - Returns: `String` object, normalized headers string.
	private static func normalizeHeadersForLogs(_ headers: [AnyHashable: Any]) -> String {
		let stringifiedHeaders = headers.map({return "  \($0.key) : \($0.value)"}).joined(separator: "\n  ")

		return "[\n  \(stringifiedHeaders) \n]"
	}

	/// Stringify `JSON` for logging.
	/// - Parameter vgsJSON: `VGSJSONData` object.
	/// - Returns: `String` object, pretty printed `JSON`.
	private static func stringifyJSONForLogs(_ vgsJSON: JsonData) -> String {
		if let json = try? JSONSerialization.data(withJSONObject: vgsJSON, options: .prettyPrinted) {
			return String(decoding: json, as: UTF8.self)
		} else {
				return ""
		}
	}

	/// Stringify payload of `Any` type for logging.
	/// - Parameter payload: `Any` paylod.
	/// - Returns: `String` object, formatted stringified payload.
	private static func stringifyRawRequestPayloadForLogs(_ payload: Any) -> String {
		if let json = payload as? JsonData {
			return stringifyJSONForLogs(json)
		}

		return ""
	}
}
