import XCTest
@testable import VGSCollectSDK

private final class CardAttributesLookupURLProtocolStub: URLProtocol {
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override static func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    guard let handler = Self.requestHandler else {
      let error = NSError(domain: "CardAttributesLookupURLProtocolStub", code: 0)
      client?.urlProtocol(self, didFailWithError: error)
      return
    }

    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}

private final class CardAttributesAnalyticsURLProtocolStub: URLProtocol {
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override static func canInit(with request: URLRequest) -> Bool { true }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    guard let handler = Self.requestHandler else {
      client?.urlProtocol(self, didFailWithError: NSError(domain: "CardAttributesAnalyticsURLProtocolStub", code: 0))
      return
    }

    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}

@MainActor
final class CardAttributesLookupTests: XCTestCase {

  override func setUp() {
    super.setUp()
    CardAttributesLookupURLProtocolStub.requestHandler = nil
    CardAttributesAnalyticsURLProtocolStub.requestHandler = nil
    VGSAnalyticsClient.shared.shouldCollectAnalytics = false
  }

  override func tearDown() {
    CardAttributesLookupURLProtocolStub.requestHandler = nil
    CardAttributesAnalyticsURLProtocolStub.requestHandler = nil
    VGSAnalyticsClient.shared.shouldCollectAnalytics = false
    VGSAnalyticsClient.shared.urlSession = URLSession(configuration: .ephemeral)
    super.tearDown()
  }

  func testLookupTriggersAt11DigitsAndDeliversSuccessFromSandboxEndpoint() async {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = ["card_type"]
    collector.cardAttributesLookupURLSession = makeMockedLookupSession()

    let expWillBegin = expectation(description: "willBegin")
    let expDidRetrieve = expectation(description: "didRetrieve")
    let expDidReceiveResponse = expectation(description: "didReceiveResponse")

    collector.willBeginCardAttributesLookup = {
      expWillBegin.fulfill()
    }

    collector.didRetrieveCardAttributes = { attrs in
      guard let payload = attrs["data"] as? [String: Any],
            let data = payload["enriched_attributes"] as? [String: Any],
            let cardProperties = data["card_properties"] as? [String: Any],
            let bank = data["bank"] as? [String: Any] else {
        XCTFail("Expected complete wrapped response payload")
        return
      }
      XCTAssertEqual(payload["card_brand"] as? String, "VISA")
      XCTAssertEqual(payload["card_type"] as? String, "CREDIT")
      XCTAssertEqual(cardProperties["issuer_bin"] as? String, "411111")
      XCTAssertEqual(cardProperties["country_letter_code"] as? String, "US")
      XCTAssertEqual(bank["issuer_name"] as? String, "Sandbox Bank")
      expDidRetrieve.fulfill()
    }

    collector.cardAttributesLookupResponse = { response in
      guard case .success(let code, let data, let urlResponse) = response else {
        XCTFail("Expected success response")
        return
      }
      XCTAssertEqual(code, 200)
      XCTAssertNotNil(data)
      XCTAssertEqual((urlResponse as? HTTPURLResponse)?.statusCode, 200)
      expDidReceiveResponse.fulfill()
    }

    collector.didFailToRetrieveCardAttributes = { code, data, response, error in
      XCTFail("Unexpected error: code=\(code) data=\(String(describing: data)) response=\(String(describing: response)) error=\(String(describing: error))")
    }

    collector.authHandler = { completion in
      completion(.success("jwt"))
    }

    CardAttributesLookupURLProtocolStub.requestHandler = { request in
      XCTAssertEqual(
        request.url?.absoluteString,
        "https://card-enrichment-api.sandbox.verygoodvault.com/cardattributes/enriched"
      )
      XCTAssertEqual(request.httpMethod, "POST")
      XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer jwt")

      if let bodyObject = Self.requestBodyData(from: request),
         let bodyJSON = try JSONSerialization.jsonObject(with: bodyObject, options: []) as? [String: Any] {
        XCTAssertEqual(bodyJSON["number"] as? String, "41111111111")
        XCTAssertEqual(bodyJSON["filter"] as? [String], ["card_type"])
      } else {
        XCTFail("Expected card attributes request body with number/filter payload.")
      }

      let responseJSON: [String: Any] = [
        "data": [
          "card_brand": "VISA",
          "card_type": "CREDIT",
          "enriched_attributes": [
            "card_properties": [
              "issuer_bin": "411111",
              "country_letter_code": "US"
            ],
            "bank": [
              "issuer_name": "Sandbox Bank"
            ]
          ]
        ]
      ]

      let data = try JSONSerialization.data(withJSONObject: responseJSON, options: [])
      let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, data)
    }

    let cardField = VGSTextField()
    let cfg = VGSConfiguration(collector: collector, fieldName: "card_number")
    cfg.type = .cardNumber
    cardField.configuration = cfg

    cardField.setText("41111111111")

    await fulfillment(of: [expWillBegin, expDidRetrieve, expDidReceiveResponse], timeout: 2.0)
  }

  func testLookupUsesFirst11DigitsOnlyAndDoesNotRefetchWhenTypingMore() async {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = ["card_type"]
    collector.cardAttributesLookupURLSession = makeMockedLookupSession()

    var willBeginCount = 0
    var requestCount = 0
    let expDidRetrieve = expectation(description: "didRetrieve")

    collector.willBeginCardAttributesLookup = {
      willBeginCount += 1
    }

    collector.didRetrieveCardAttributes = { _ in
      expDidRetrieve.fulfill()
    }

    collector.didFailToRetrieveCardAttributes = { code, data, response, error in
      XCTFail("Unexpected error: code=\(code) data=\(String(describing: data)) response=\(String(describing: response)) error=\(String(describing: error))")
    }

    collector.authHandler = { completion in
      completion(.success("jwt"))
    }

    CardAttributesLookupURLProtocolStub.requestHandler = { request in
      requestCount += 1
      let responseJSON: [String: Any] = [
        "data": [
          "card_brand": "VISA",
          "card_type": "CREDIT",
          "enriched_attributes": [
            "card_properties": [
              "issuer_bin": "411111"
            ]
          ]
        ]
      ]
      let data = try JSONSerialization.data(withJSONObject: responseJSON, options: [])
      let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, data)
    }

    let cardField = VGSTextField()
    let cfg = VGSConfiguration(collector: collector, fieldName: "card_number")
    cfg.type = .cardNumber
    cardField.configuration = cfg

    cardField.setText("41111111111")
    cardField.setText("411111111111234")

    await fulfillment(of: [expDidRetrieve], timeout: 2.0)
    XCTAssertEqual(willBeginCount, 1)
    XCTAssertEqual(requestCount, 1)
  }

  func testLookupMapsFlatResponsePayload() async {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = ["card_type", "brand", "bin"]
    collector.cardAttributesLookupURLSession = makeMockedLookupSession()

    let expDidRetrieve = expectation(description: "didRetrieve")

    collector.didRetrieveCardAttributes = { attrs in
      XCTAssertEqual(attrs["bin"] as? String, "487104")
      XCTAssertEqual(attrs["brand"] as? String, "VISA")
      XCTAssertEqual(attrs["card_type"] as? String, "DEBIT")
      XCTAssertEqual(attrs["issuing_organization"] as? String, "BNP PARIBAS FORTIS NV/SA.")
      XCTAssertEqual(attrs["issuing_country_code"] as? String, "56")
      expDidRetrieve.fulfill()
    }

    collector.didFailToRetrieveCardAttributes = { code, data, response, error in
      XCTFail("Unexpected error: code=\(code) data=\(String(describing: data)) response=\(String(describing: response)) error=\(String(describing: error))")
    }

    collector.authHandler = { completion in
      completion(.success("jwt"))
    }

    CardAttributesLookupURLProtocolStub.requestHandler = { request in
      let responseJSON: [String: Any] = [
        "bin": "487104",
        "brand": "VISA",
        "issuing_organization": "BNP PARIBAS FORTIS NV/SA.",
        "card_type": "DEBIT",
        "issuing_country_code": "56"
      ]

      let data = try JSONSerialization.data(withJSONObject: responseJSON, options: [])
      let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, data)
    }

    let cardField = VGSTextField()
    let cfg = VGSConfiguration(collector: collector, fieldName: "card_number")
    cfg.type = .cardNumber
    cardField.configuration = cfg

    cardField.setText("48710411111")

    await fulfillment(of: [expDidRetrieve], timeout: 2.0)
  }

  func testLookupDoesNotTriggerWhenIncludedAttributesEmpty() async {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = []

    let willBegin = expectation(description: "willBegin")
    willBegin.isInverted = true

    collector.willBeginCardAttributesLookup = {
      willBegin.fulfill()
    }

    collector.didRetrieveCardAttributes = { _ in
      XCTFail("Should not retrieve when feature disabled")
    }

    collector.didFailToRetrieveCardAttributes = { _, _, _, _ in
      XCTFail("Should not fail when feature disabled")
    }

    collector.authHandler = { completion in
      completion(.success("jwt"))
    }

    let cardField = VGSTextField()
    let cfg = VGSConfiguration(collector: collector, fieldName: "card_number")
    cfg.type = .cardNumber
    cardField.configuration = cfg

    cardField.setText("41111111111")

    await fulfillment(of: [willBegin], timeout: 0.5)
  }

  func testLookupEndpointUsesRequestedEnvironment() {
    XCTAssertEqual(
      VGSCollect.cardAttributesLookupURL(environment: "live").absoluteString,
      "https://card-enrichment-api.live.verygoodvault.com/cardattributes/enriched"
    )
    XCTAssertEqual(
      VGSCollect.cardAttributesLookupURL(environment: "sandbox").absoluteString,
      "https://card-enrichment-api.sandbox.verygoodvault.com/cardattributes/enriched"
    )
    XCTAssertEqual(
      VGSCollect.cardAttributesLookupURL(environment: "live-eu1").absoluteString,
      "https://card-enrichment-api.live.verygoodvault.com/cardattributes/enriched"
    )
    XCTAssertEqual(
      VGSCollect.cardAttributesLookupURL(environment: "sandbox-eu1").absoluteString,
      "https://card-enrichment-api.sandbox.verygoodvault.com/cardattributes/enriched"
    )
  }

  func testLookupMapsNon2xxStatusToFailureCallbackWithResponseMetadata() async {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = ["card_type"]
    collector.cardAttributesLookupURLSession = makeMockedLookupSession()

    let expDidFail = expectation(description: "didFail")
    let expDidReceiveResponse = expectation(description: "didReceiveResponse")

    collector.didRetrieveCardAttributes = { _ in
      XCTFail("Unexpected success response")
    }

    collector.cardAttributesLookupResponse = { response in
      guard case .failure(let code, let data, let response, let underlyingError) = response else {
        XCTFail("Expected failure response")
        expDidReceiveResponse.fulfill()
        return
      }

      XCTAssertEqual(code, 500)
      XCTAssertEqual(data, Data("{}".utf8))
      XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 500)
      XCTAssertNil(underlyingError)
      expDidReceiveResponse.fulfill()
    }

    collector.didFailToRetrieveCardAttributes = { code, data, response, error in
      XCTAssertEqual(code, 500)
      XCTAssertEqual(data, Data("{}".utf8))
      XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 500)
      XCTAssertNil(error)
      expDidFail.fulfill()
    }

    collector.authHandler = { completion in
      completion(.success("jwt"))
    }

    CardAttributesLookupURLProtocolStub.requestHandler = { request in
      let data = Data("{}".utf8)
      let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 500, httpVersion: nil, headerFields: nil)!
      return (response, data)
    }

    let cardField = VGSTextField()
    let cfg = VGSConfiguration(collector: collector, fieldName: "card_number")
    cfg.type = .cardNumber
    cardField.configuration = cfg

    cardField.setText("41111111111")

    await fulfillment(of: [expDidFail, expDidReceiveResponse], timeout: 2.0)
  }

  func testLookupMapsInvalidPayloadShapeToLookupFailureError() async {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = ["card_type"]
    collector.cardAttributesLookupURLSession = makeMockedLookupSession()

    let expDidFail = expectation(description: "didFail")
    let expDidReceiveResponse = expectation(description: "didReceiveResponse")

    collector.didRetrieveCardAttributes = { _ in
      XCTFail("Unexpected success response")
    }

    collector.cardAttributesLookupResponse = { response in
      guard case .failure(let code, let data, let urlResponse, let error) = response else {
        XCTFail("Expected failure response")
        expDidReceiveResponse.fulfill()
        return
      }

      XCTAssertEqual(code, VGSErrorType.unexpectedResponseDataFormat.rawValue)
      XCTAssertEqual(data, Data("{}".utf8))
      XCTAssertEqual((urlResponse as? HTTPURLResponse)?.statusCode, 200)
      XCTAssertTrue(error is VGSError)
      expDidReceiveResponse.fulfill()
    }

    collector.didFailToRetrieveCardAttributes = { code, data, response, error in
      XCTAssertEqual(code, VGSErrorType.unexpectedResponseDataFormat.rawValue)
      XCTAssertEqual(data, Data("{}".utf8))
      XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)

      guard let vgsError = error as? VGSError else {
        XCTFail("Expected underlying VGSError, got \(String(describing: error))")
        expDidFail.fulfill()
        return
      }

      XCTAssertEqual(vgsError.type, .unexpectedResponseDataFormat)
      XCTAssertEqual(vgsError.code, VGSErrorType.unexpectedResponseDataFormat.rawValue)
      XCTAssertEqual(vgsError.userInfo["key"] as? String, VGSSDKErrorUnexpectedResponseDataFormat)
      expDidFail.fulfill()
    }

    collector.authHandler = { completion in
      completion(.success("jwt"))
    }

    CardAttributesLookupURLProtocolStub.requestHandler = { request in
      let invalidShapeJSON = [String: Any]()
      let data = try JSONSerialization.data(withJSONObject: invalidShapeJSON, options: [])
      let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, data)
    }

    let cardField = VGSTextField()
    let cfg = VGSConfiguration(collector: collector, fieldName: "card_number")
    cfg.type = .cardNumber
    cardField.configuration = cfg

    cardField.setText("41111111111")

    await fulfillment(of: [expDidFail, expDidReceiveResponse], timeout: 2.0)
  }
}

extension CardAttributesLookupTests {
  func testLookupSuccessAnalyticsIncludesReferenceFieldsWithoutSensitiveData() async throws {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = ["card_type"]
    collector.cardAttributesLookupURLSession = makeMockedLookupSession()
    configureAnalyticsCapture()

    let analyticsExpectation = expectation(description: "analytics")
    let lookupExpectation = expectation(description: "lookup")

    CardAttributesAnalyticsURLProtocolStub.requestHandler = { request in
      let payload = try Self.analyticsPayload(from: request)
      guard payload["type"] as? String == "CardLookup" else {
        return try Self.emptyHTTPResponse(for: request)
      }
      XCTAssertEqual(payload["type"] as? String, "CardLookup")
      XCTAssertEqual(payload["status"] as? String, "Ok")
      XCTAssertEqual(payload["error"] as? String, "")
      XCTAssertEqual(payload["statusCode"] as? Int, 200)
      XCTAssertNotNil(payload["latency"] as? Int)

      let serialized = String(data: try JSONSerialization.data(withJSONObject: payload), encoding: .utf8) ?? ""
      XCTAssertFalse(serialized.contains("41111111111"))
      XCTAssertFalse(serialized.contains("lookup-jwt"))
      analyticsExpectation.fulfill()
      return try Self.emptyHTTPResponse(for: request)
    }

    CardAttributesLookupURLProtocolStub.requestHandler = { request in
      let data = Data(#"{"data":{"card_type":"CREDIT"}}"#.utf8)
      let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, data)
    }

    collector.authHandler = { $0(.success("lookup-jwt")) }
    collector.didRetrieveCardAttributes = { _ in lookupExpectation.fulfill() }
    triggerLookup(on: collector, cardNumber: "41111111111")

    await fulfillment(of: [analyticsExpectation, lookupExpectation], timeout: 2.0)
  }

  func testLookupFailureAnalyticsIncludesStatusCodeAndCategoricalError() async throws {
    let collector = VGSCollect(id: "tnt123", environment: "sandbox")
    collector.includedCardAttributes = ["card_type"]
    collector.cardAttributesLookupURLSession = makeMockedLookupSession()
    configureAnalyticsCapture()

    let analyticsExpectation = expectation(description: "analytics")
    let lookupExpectation = expectation(description: "lookup")

    CardAttributesAnalyticsURLProtocolStub.requestHandler = { request in
      let payload = try Self.analyticsPayload(from: request)
      guard payload["type"] as? String == "CardLookup" else {
        return try Self.emptyHTTPResponse(for: request)
      }
      XCTAssertEqual(payload["type"] as? String, "CardLookup")
      XCTAssertEqual(payload["status"] as? String, "Failed")
      XCTAssertEqual(payload["error"] as? String, "http_error")
      XCTAssertEqual(payload["statusCode"] as? Int, 500)
      XCTAssertNotNil(payload["latency"] as? Int)
      analyticsExpectation.fulfill()
      return try Self.emptyHTTPResponse(for: request)
    }

    CardAttributesLookupURLProtocolStub.requestHandler = { request in
      let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 500, httpVersion: nil, headerFields: nil)!
      return (response, Data("{}".utf8))
    }

    collector.authHandler = { $0(.success("lookup-jwt")) }
    collector.didFailToRetrieveCardAttributes = { _, _, _, _ in lookupExpectation.fulfill() }
    triggerLookup(on: collector, cardNumber: "41111111111")

    await fulfillment(of: [analyticsExpectation, lookupExpectation], timeout: 2.0)
  }

  private func makeMockedLookupSession() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [CardAttributesLookupURLProtocolStub.self]
    return URLSession(configuration: configuration)
  }

  private func configureAnalyticsCapture() {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [CardAttributesAnalyticsURLProtocolStub.self]
    VGSAnalyticsClient.shared.urlSession = URLSession(configuration: configuration)
    VGSAnalyticsClient.shared.shouldCollectAnalytics = true
  }

  private func triggerLookup(on collector: VGSCollect, cardNumber: String) {
    let cardField = VGSTextField()
    let configuration = VGSConfiguration(collector: collector, fieldName: "card_number")
    configuration.type = .cardNumber
    cardField.configuration = configuration
    cardField.setText(cardNumber)
  }

  private static func analyticsPayload(from request: URLRequest) throws -> [String: Any] {
    let encodedData = try XCTUnwrap(requestBodyData(from: request))
    let decodedData = try XCTUnwrap(Data(base64Encoded: encodedData))
    return try XCTUnwrap(JSONSerialization.jsonObject(with: decodedData) as? [String: Any])
  }

  private static func emptyHTTPResponse(for request: URLRequest) throws -> (HTTPURLResponse, Data) {
    let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (response, Data("{}".utf8))
  }

  private static func requestBodyData(from request: URLRequest) -> Data? {
    if let body = request.httpBody {
      return body
    }

    guard let stream = request.httpBodyStream else {
      return nil
    }

    stream.open()
    defer { stream.close() }

    var data = Data()
    let bufferSize = 1024
    var buffer = [UInt8](repeating: 0, count: bufferSize)

    while stream.hasBytesAvailable {
      let readCount = stream.read(&buffer, maxLength: bufferSize)
      if readCount <= 0 { break }
      data.append(buffer, count: readCount)
    }

    return data.isEmpty ? nil : data
  }
}
