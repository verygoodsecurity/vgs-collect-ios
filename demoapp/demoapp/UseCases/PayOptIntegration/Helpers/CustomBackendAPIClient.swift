//
//  CustomBackendAPIClient.swift
//  demoapp
//

import Foundation

/// Your Custom API client for payment orchestration.
final class CustomBackendAPIClient {

	/// Defines API client request result.
	private enum APIRequestResult {
		/// Request success.
		case success(_ json: [String: Any]?, _ data: Data?)
		/// Request fail.
		case fail(_ errorText: String)
	}

	/// API request completion.
	private typealias APIRequestCompletion = (_ result: APIRequestResult) -> Void
	/// Succcess completion for token fetch.
	typealias FetchTokenCompletionSuccess = (_ token: String) -> Void
	/// Fail completion for token fetch.
	typealias FetchTokenCompletionFail = (_ errorMessage: String) -> Void
	/// Succcess completion for loading saved cards details
	typealias FetchSavedCardsCompletionSuccess = ( _ savedCards: [SavedCardModel]) -> Void
	/// Fail completion for loading saved cards details
	typealias FetchSavedCardsCompletionFailure = ( _ error: Error?) -> Void

	/// Main url.
	private let baseUrl = URL(string:  AppCollectorConfiguration.shared.customBackendBaseUrl)!


	/// Fetch payment orchestration token from your own backend.
	/// - Parameters:
	///   - success: `FetchTokenCompletionSuccess` object, completion on success request with token.
	///   - failure: `FetchTokenCompletionFail` object, completion on failed request with error message.
	func fetchToken(with success: @escaping FetchTokenCompletionSuccess, failure: @escaping FetchTokenCompletionFail) {

		let tokenUrl = baseUrl.appendingPathComponent("get-auth-token")
		var request = URLRequest(url: tokenUrl)
		request.httpMethod = "POST"
		let task = URLSession.shared.dataTask(
			with: request,
			completionHandler: { (data, response, error) in
				guard let data = data,
							let json = try? JSONSerialization.jsonObject(with: data, options: [])
								as? [String: Any],
							let token = json["access_token"] as? String else {
								// Handle error
								DispatchQueue.main.async {
									failure("Cannot fetch token")
								}
								return
							}

				let multipexingToken = token
				print("access_token: \(token)")
				DispatchQueue.main.async {
					success(multipexingToken)
				}
			})
		task.resume()
	}

	/// Fetch saved card details by finIds
	/// - Parameters:
	///   - savedCardIds: `[String]` financial instruments ids
	///   - accessToken: `String` payopt access token
	///   - success: `FetchSavedCardsCompletionSuccess` object, completion on success request with saved card.
	///   - failure: `FetchSavedCardsCompletionFailure` object, completion on failed request with error message.
	func fetchSavedPaymentMethods(_ savedCardIds: [String], accessToken: String, success: @escaping FetchSavedCardsCompletionSuccess, failure: @escaping FetchSavedCardsCompletionFailure) {

			var fetchedSavedCards = [SavedCardModel]()
			let dispatchGroup = DispatchGroup()
			for finId in savedCardIds {
					dispatchGroup.enter()
					fetchPaymentInstrument(with: finId, accessToken: accessToken) { savedCard in
						fetchedSavedCards.append(savedCard)
						dispatchGroup.leave()
					} failure: { error in
						dispatchGroup.leave()
					}
			}

			dispatchGroup.notify(queue: .main) {
				// Reorder fetched by ids since it can be different depending on API request.
				fetchedSavedCards = fetchedSavedCards.reorderByIds(savedCardIds)
				success(fetchedSavedCards)
			}
	}

	//// Fetch saved card details by finIds
	/// - Parameters:
	///   - id: `String` financial instrument id
	///   - accessToken: `String` payopt access token
	///   - success: `FetchSavedCardsCompletionSuccess` object, completion on success request with saved card.
	///   - failure: `FetchSavedCardsCompletionFailure` object, completion on failed request with error message.
	func fetchPaymentInstrument(with id: String, accessToken: String, success: @escaping ( _ savedCard: SavedCardModel) -> Void, failure: @escaping ( _ error: Error?) -> Void) {

		let path = "financial_instruments/\(id)"
		let customHeader = ["Authorization": "Bearer \(accessToken)"]

		/// Fetch
		let url = URL(string: "https://\(AppCollectorConfiguration.shared.vaultId)-\(AppCollectorConfiguration.shared.paymentOrchestrationDefaultRouteId).\(AppCollectorConfiguration.shared.environment).verygoodproxy.com")!
		print("🔼🔼🔼 fetchPaymentInstrument url: \(url.absoluteString)")

		// Use API client directly since we don't need to send data from VGS Collect (it can contain data from VGSTextFields).
		sendRequest(path, url: url, payload: nil, httpMethod: "GET", headers: customHeader, completion: { response in
			switch response {
			case .success(let json, let data):
				guard let jsonData = data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any], let savedCard = SavedCardModel(json: json) else {
					failure(nil)
					return
				 }
				print("⬇️ fetchPaymentInstrument result:\n\(savedCard.id)")
				success(savedCard)
			case .fail(let error):
				print("⬇️ fetchPaymentInstrument result:\n\(error.description)")
				failure(nil)
			}
		})
	}


	// MARK: - Private

	/// Sends API request.
	/// - Parameters:
	///   - path: `String` object, path to send data.
	///   - payload: `[String: Any]?` object, payload, should be valid JSON.
	///   - httpMethod: `String` object, should be valid HTTP Method.
	///   - headers: `[String : String]?` object, headers, default is `nil`.
	///   - completion: `APIRequestCompletion` object, api request completion.
	private func sendRequest(_ path: String, url: URL, payload: [String: Any]?, httpMethod: String, headers: [String: String]? = nil, completion: @escaping (APIRequestCompletion)) {

		let requestUrl = url.appendingPathComponent(path)
		var request = URLRequest(url: requestUrl)
		request.httpMethod = httpMethod
		var requestHeaders: [String:String] = [:]
		requestHeaders["Content-Type"] = "application/json"

		if let customerHeaders = headers, customerHeaders.count > 0 {
			customerHeaders.keys.forEach({ (key) in
				requestHeaders[key] = customerHeaders[key]
			})
		}

		request.allHTTPHeaderFields = requestHeaders

		if let bodyPayload = payload {
			request.httpBody = try? JSONSerialization.data(withJSONObject: bodyPayload)
		}

		let task = URLSession.shared.dataTask(
				with: request,
				completionHandler: {(data, response, error) in
						guard let data = data,
								let json = try? JSONSerialization.jsonObject(with: data, options: [])
										as? [String: Any] else {
								// Handle error
							DispatchQueue.main.async {
								completion(APIRequestResult
									.fail("❌❌❌ Error ⬇️ Cannot parse response"))
							}
							return
						}
					print("✅ Success ⬇️ response:\n \(json)")

					DispatchQueue.main.async {
						completion(APIRequestResult
							.success(json, data))
					}
				})
		task.resume()
	}
}
