import XCTest
import Combine
@testable import VGSCollectSDK

private final class CMPURLProtocolStub: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "CMPURLProtocolStub", code: 0))
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
class CMPAPIClientTests: VGSCollectBaseTestCase {
    
    var formAnalyticsDetails: VGSFormAnanlyticsDetails!
    
    override func setUp() {
        super.setUp()
        // Globally register the mock protocol before each test.
        formAnalyticsDetails = VGSFormAnanlyticsDetails(formId: "testForm", tenantId: "testTenant", environment: "sandbox")
    }
    
    override func tearDown() {
        CMPURLProtocolStub.requestHandler = nil
        formAnalyticsDetails = nil
        super.tearDown()
    }
    
    /// This test does not make a network call and is unaffected.
    func test_init_withSandboxEnvironment_shouldSetSandboxBaseURL() {
        // Given
        let environment = "sandbox"
        
        // When
        let client = CMPAPIClient(environment: environment, formAnalyticsDetails: formAnalyticsDetails)
        
        // Then
        XCTAssertEqual(client.baseURL?.absoluteString, "https://sandbox.vgsapi.com", "Base URL should be the sandbox URL.")
    }

    func test_init_withRegionalSandboxEnvironment_shouldSetSandboxBaseURL() {
        let client = CMPAPIClient(environment: "sandbox-eu1", formAnalyticsDetails: formAnalyticsDetails)

        XCTAssertEqual(client.baseURL?.absoluteString, "https://sandbox.vgsapi.com")
    }
    
    /// This test also does not make a network call and is unaffected.
    func test_init_withLiveEnvironment_shouldSetLiveBaseURL() {
        // Given
        let environment = "live"
        
        // When
        let client = CMPAPIClient(environment: environment, formAnalyticsDetails: formAnalyticsDetails)
        
        // Then
        XCTAssertEqual(client.baseURL?.absoluteString, "https://vgsapi.com", "Base URL should be the live URL.")
    }

    func test_networkDebugFormattingIncludesExactAuthorizationAndBody() throws {
        var request = URLRequest(url: try XCTUnwrap(URL(string: "https://sandbox.vgsapi.com/cards")))
        request.setValue("Bearer secret-token", forHTTPHeaderField: "Authorization")
        request.httpBody = Data("sensitive-card-data".utf8)

        let headers = try XCTUnwrap(request.allHTTPHeaderFields)
        let body = try XCTUnwrap(request.httpBody)
        let loggedHeaders = VGSCollectRequestLogger.normalizeRequestHeadersForLogs(headers)
        let loggedBody = VGSCollectRequestLogger.stringifyDataForLogs(body)

        XCTAssertTrue(loggedHeaders.contains("Authorization : Bearer secret-token"))
        XCTAssertEqual(loggedBody, "sensitive-card-data")
    }
}
@MainActor
class VGSCollectCreateCardTests: VGSCollectBaseTestCase {
    
    var vgsCollect: VGSCollect!
  
    override func tearDown() {
        CMPURLProtocolStub.requestHandler = nil
        VGSAnalyticsClient.shared.shouldCollectAnalytics = false
        VGSAnalyticsClient.shared.urlSession = URLSession(configuration: .ephemeral)
        vgsCollect = nil
        super.tearDown()
    }
    
    /// Tests  request URL and path in sandbox.
    func test_createCard_shouldConstructCorrectSandboxURL() {
        // Given
        vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      
        let expectation = self.expectation(description: "Request received")
        let authToken = "valid-auth-token"
        
        let textField = VGSTextField()
        let config = VGSConfiguration.makeCardNumberConfiguration(collector: vgsCollect)
        textField.configuration = config
        textField.setText("4111111111111111")

        let expField = VGSTextField()
        expField.configuration = .makeExpDateConfiguration(collector: vgsCollect)
        expField.setText("12/30")
        
        // When: We trigger the call.
        vgsCollect.createCard(token: authToken) { result in
          switch result {
          case .failure(_, _, let response, _):
            let requestURL = response?.url?.absoluteString ?? ""
            XCTAssertEqual(requestURL, "https://sandbox.vgsapi.com/cards", "Wrong request url!")
           
          case .success:
            XCTFail("-wrong response!")
          }
          expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    /// Tests  request URL and path in live.
    func test_createCard_shouldConstructCorrectLiveURL() {
      // Given
      vgsCollect = VGSCollect(id: "tntid", environment: "live")
    
      let expectation = self.expectation(description: "Request received")
      let authToken = "valid-auth-token"
      
      let textField = VGSTextField()
      let config = VGSConfiguration.makeCardNumberConfiguration(collector: vgsCollect)
      textField.configuration = config
      textField.setText("4111111111111111")

      let expField = VGSTextField()
      expField.configuration = .makeExpDateConfiguration(collector: vgsCollect)
      expField.setText("12/30")
      
      // When: We trigger the call.
      vgsCollect.createCard(token: authToken) { result in
        switch result {
        case .failure(_, _, let response, _):
          let requestURL = response?.url?.absoluteString ?? ""
          XCTAssertEqual(requestURL, "https://vgsapi.com/cards", "Wrong request url!")
         
        case .success:
          XCTFail("-wrong response!")
        }
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 2.0)
    }
  
    /// Tests  request URL and path in live.
    func test_createCard_emptyTokenReturnsError() {
      // Given
      vgsCollect = VGSCollect(id: "tntid", environment: "live")
    
      let expectation = self.expectation(description: "Request received")
      let authToken = ""
      
      let textField = VGSTextField()
      let config = VGSConfiguration.makeCardNumberConfiguration(collector: vgsCollect)
      textField.configuration = config
      textField.setText("4111111111111111")
      
      // When: We trigger the call.
      vgsCollect.createCard(token: authToken) { result in
        switch result {
        case .failure(let code, _, _, _):
          XCTAssertEqual(VGSErrorType.invalidAccessToken.rawValue, code, "-Wrong error code when auth token is empty")
        case .success:
          XCTFail("-wrong response when auth token is empty!")
        }
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 2.0)
    }

    func test_createCard_rejectsMissingExpirationBeforeRequest() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [CMPURLProtocolStub.self]
      vgsCollect.cmpAPIClient.urlSession = URLSession(configuration: configuration)
      let requestExpectation = expectation(description: "request not sent")
      requestExpectation.isInverted = true
      let completionExpectation = expectation(description: "completion")

      let panField = VGSTextField()
      panField.configuration = .makeCardNumberConfiguration(collector: vgsCollect)
      panField.setText("4111111111111111")

      CMPURLProtocolStub.requestHandler = { request in
        requestExpectation.fulfill()
        let response = HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        return (response, Data("{}".utf8))
      }

      vgsCollect.createCard(token: "token-123") { response in
        guard case .failure(let code, _, _, let error) = response else {
          XCTFail("Expected missing expiration failure")
          completionExpectation.fulfill()
          return
        }
        XCTAssertEqual(code, VGSErrorType.inputDataIsNotValid.rawValue)
        XCTAssertEqual((error as? VGSError)?.type, .inputDataIsNotValid)
        completionExpectation.fulfill()
      }

      wait(for: [completionExpectation, requestExpectation], timeout: 1.0)
    }

    func test_createCard_extraDataIsMappedUnderAttributes() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")

      let textField = VGSTextField()
      let config = VGSConfiguration.makeCardNumberConfiguration(collector: vgsCollect)
      textField.configuration = config
      textField.setText("4111111111111111")

      let extraData: [String: Any] = [
        "nickname": "Primary",
        "cardholder": [
          "address": [
            "city": "San Francisco"
          ]
        ],
        "_source": "custom-source",
        "_version": "custom-version"
      ]

      let body = vgsCollect.buildCreateCardBody(extraData: extraData)

      guard let data = body["data"] as? [String: Any],
            let attributes = data["attributes"] as? [String: Any],
            let meta = data["meta"] as? [String: Any] else {
        XCTFail("Expected CMP body to contain data.attributes and data.meta")
        return
      }

      XCTAssertEqual(attributes["pan"] as? String, "4111111111111111")
      XCTAssertEqual(attributes["nickname"] as? String, "Primary")
      XCTAssertEqual(attributes["_source"] as? String, "custom-source")
      XCTAssertEqual(attributes["_version"] as? String, "custom-version")
      XCTAssertEqual(meta["_source"] as? String, "vgs-collect")
      XCTAssertEqual(meta["_medium"] as? String, "iosSDK")
      XCTAssertNil(meta["_formId"])
      XCTAssertEqual(meta["_version"] as? String, Utils.vgsCollectVersion)

      guard let cardholder = attributes["cardholder"] as? [String: Any],
            let address = cardholder["address"] as? [String: Any] else {
        XCTFail("Expected nested cardholder attributes")
        return
      }

      XCTAssertEqual(address["city"] as? String, "San Francisco")
      XCTAssertNil(body["meta"])
    }

    func test_createCard_withoutExtraDataStillIncludesAnalyticsMeta() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")

      let body = vgsCollect.buildCreateCardBody(extraData: nil)

      guard let data = body["data"] as? [String: Any],
            let meta = data["meta"] as? [String: Any] else {
        XCTFail("Expected analytics meta payload")
        return
      }

      XCTAssertEqual(meta["_source"] as? String, "vgs-collect")
      XCTAssertEqual(meta["_medium"] as? String, "iosSDK")
      XCTAssertNil(meta["_formId"])
      XCTAssertEqual(meta["_version"] as? String, Utils.vgsCollectVersion)
    }

    func test_createCard_wrappedExtraDataEnvelopeDoesNotDoubleNest() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")

      let textField = VGSTextField()
      let config = VGSConfiguration.makeCardNumberConfiguration(collector: vgsCollect)
      textField.configuration = config
      textField.setText("4111111111111111")

      let body = vgsCollect.buildCreateCardBody(extraData: [
        "data": [
          "attributes": [
            "pan": "customer-supplied-value",
            "nickname": "Primary",
            "cardholder": ["address": ["city": "Kyiv"]]
          ]
        ]
      ])

      guard let data = body["data"] as? [String: Any],
            let attributes = data["attributes"] as? [String: Any],
            let cardholder = attributes["cardholder"] as? [String: Any],
            let address = cardholder["address"] as? [String: Any] else {
        XCTFail("Expected wrapped extraData to merge into CMP attributes")
        return
      }

      XCTAssertEqual(attributes["pan"] as? String, "4111111111111111")
      XCTAssertEqual(attributes["nickname"] as? String, "Primary")
      XCTAssertEqual(address["city"] as? String, "Kyiv")
      XCTAssertNil(attributes["data"])
    }

    func test_createCard_sessionBodyUsesSessionFormName() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      vgsCollect.sessionFormId = "checkout-form"

      let body = vgsCollect.buildCreateCardBody()

      guard let data = body["data"] as? [String: Any],
            let meta = data["meta"] as? [String: Any] else {
        XCTFail("Expected analytics meta payload")
        return
      }

      XCTAssertEqual(meta["_formId"] as? String, "checkout-form")
    }

    func test_createCard_customMetadataPreservesAttributesAndStringValues() throws {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let extraData: [String: Any] = ["nickname": "Primary", "meta": "attribute-value"]
      let original = vgsCollect.buildCreateCardBody(extraData: extraData)
      let custom = vgsCollect.buildCreateCardBody(extraData: extraData, meta: [
        "session_id": "sample-session-123", "empty": "", "spacing": "  value  ",
        "__type": "custom-type", "__proto__": "custom-proto"
      ])
      let originalData = try XCTUnwrap(original["data"] as? [String: Any])
      let customData = try XCTUnwrap(custom["data"] as? [String: Any])
      XCTAssertEqual(
        NSDictionary(dictionary: try XCTUnwrap(originalData["attributes"] as? [String: Any])),
        NSDictionary(dictionary: try XCTUnwrap(customData["attributes"] as? [String: Any]))
      )
      let meta = try XCTUnwrap(customData["meta"] as? [String: String])
      XCTAssertEqual(meta["session_id"], "sample-session-123")
      XCTAssertEqual(meta["empty"], "")
      XCTAssertEqual(meta["spacing"], "  value  ")
      XCTAssertEqual(meta["__type"], "custom-type")
      XCTAssertEqual(meta["__proto__"], "custom-proto")
      XCTAssertNoThrow(try JSONSerialization.data(withJSONObject: custom))
      XCTAssertEqual(extraData["meta"] as? String, "attribute-value")
    }

    func test_createCard_nilAndEmptyMetadataPreserveAllExistingEnvelopeShapes() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let fixtures: [[String: Any]?] = [
        nil,
        ["meta": "attribute-value"],
        ["data": ["attributes": ["nickname": "Primary"], "meta": [
          "legacyNumber": 7, "legacyObject": ["flag": true], "_formId": "legacy-form"
        ]]],
        ["data": ["meta": ["legacyNumber": 7]]]
      ]
      for fixture in fixtures {
        let original = NSDictionary(dictionary: vgsCollect.buildCreateCardBody(extraData: fixture))
        XCTAssertEqual(original, NSDictionary(dictionary: vgsCollect.buildCreateCardBody(extraData: fixture, meta: nil)))
        XCTAssertEqual(original, NSDictionary(dictionary: vgsCollect.buildCreateCardBody(extraData: fixture, meta: [:])))
      }
    }

    func test_createCard_customMetadataOverlaysLegacyWithoutRevalidatingIt() throws {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let legacy: [String: Any] = ["data": [
        "attributes": ["nickname": "Primary"],
        "meta": ["orderId": "old-order", "legacyNumber": 7,
                 "legacyObject": ["flag": true], "_formId": "legacy-form"]
      ]]
      let body = vgsCollect.buildCreateCardBody(extraData: legacy, meta: [
        "orderId": "new-order", "integration": "checkout", "_formId": "spoofed-form"
      ])
      let data = try XCTUnwrap(body["data"] as? [String: Any])
      let meta = try XCTUnwrap(data["meta"] as? [String: Any])
      XCTAssertEqual(meta["orderId"] as? String, "new-order")
      XCTAssertEqual(meta["integration"] as? String, "checkout")
      XCTAssertEqual(meta["legacyNumber"] as? Int, 7)
      XCTAssertEqual(meta["legacyObject"] as? [String: Bool], ["flag": true])
      XCTAssertEqual(meta["_formId"] as? String, "legacy-form")
      let legacyData = try XCTUnwrap(legacy["data"] as? [String: Any])
      XCTAssertEqual((legacyData["meta"] as? [String: Any])?["orderId"] as? String, "old-order")
    }

    func test_createCard_customMetadataCannotReplaceSDKMetadataInDirectOrSessionMode() throws {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      for formId in [nil, "checkout-form"] as [String?] {
        vgsCollect.sessionFormId = formId
        let body = vgsCollect.buildCreateCardBody(meta: [
          "_source": "spoofed", "_medium": "spoofed", "_version": "spoofed",
          "_formId": "spoofed", "orderId": "order-123"
        ])
        let data = try XCTUnwrap(body["data"] as? [String: Any])
        let meta = try XCTUnwrap(data["meta"] as? [String: String])
        XCTAssertEqual(meta["_source"], "vgs-collect")
        XCTAssertEqual(meta["_medium"], "iosSDK")
        XCTAssertEqual(meta["_version"], Utils.vgsCollectVersion)
        XCTAssertEqual(meta["_formId"], formId)
        XCTAssertEqual(meta["orderId"], "order-123")
      }
    }

    func test_createCard_existingFunctionReferencesRemainAvailable() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      _ = vgsCollect.createCard(extraData:completion:)
      _ = vgsCollect.createCard(token:extraData:completion:)
      _ = vgsCollect.createCard(extraData:)
      _ = vgsCollect.createCard(token:extraData:)
      _ = vgsCollect.createCardPublisher(extraData:)
      _ = vgsCollect.createCardPublisher(token:extraData:)
    }

    func test_createCard_allMetadataAPIFamiliesSendMetadataToSandbox() async {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let fields = configureMetadataTestFields()
      defer { withExtendedLifetime(fields) {} }
      configureMetadataTestSession()
      vgsCollect.authHandler = { $0(.success("test-jwt")) }
      let metadata = ["session_id": "sample-session-123"]
      var subscriptions = Set<AnyCancellable>()
      var requestCount = 0
      CMPURLProtocolStub.requestHandler = { request in
        requestCount += 1
        let url = try XCTUnwrap(request.url)
        XCTAssertEqual(url.absoluteString, "https://sandbox.vgsapi.com/cards")
        XCTAssertEqual(request.httpMethod, "POST")
        let body = try XCTUnwrap(Self.requestBodyData(from: request))
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        let data = try XCTUnwrap(payload["data"] as? [String: Any])
        let meta = try XCTUnwrap(data["meta"] as? [String: String])
        XCTAssertEqual(meta["session_id"], "sample-session-123")
        let attributes = try XCTUnwrap(data["attributes"] as? [String: Any])
        XCTAssertNil(attributes["session_id"])
        XCTAssertEqual(attributes["exp_month"] as? Int, 12)
        XCTAssertEqual(attributes["exp_year"] as? Int, 30)
        return (try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)), Data("{}".utf8))
      }
      let callbackResult = await withCheckedContinuation { continuation in
        vgsCollect.createCard(meta: metadata) { continuation.resume(returning: $0) }
      }
      let tokenCallbackResult = await withCheckedContinuation { continuation in
        vgsCollect.createCard(token: "test-jwt", meta: metadata) { continuation.resume(returning: $0) }
      }
      let asyncResult = await vgsCollect.createCard(meta: metadata)
      let tokenAsyncResult = await vgsCollect.createCard(token: "test-jwt", meta: metadata)
      let publisherResult = await withCheckedContinuation { continuation in
        vgsCollect.createCardPublisher(meta: metadata)
          .sink { continuation.resume(returning: $0) }.store(in: &subscriptions)
      }
      let tokenPublisherResult = await withCheckedContinuation { continuation in
        vgsCollect.createCardPublisher(token: "test-jwt", meta: metadata)
          .sink { continuation.resume(returning: $0) }.store(in: &subscriptions)
      }
      for response in [callbackResult, tokenCallbackResult, asyncResult, tokenAsyncResult, publisherResult, tokenPublisherResult] {
        guard case .success(let code, _, _) = response else { XCTFail("Expected creation success"); continue }
        XCTAssertEqual(code, 200)
      }
      XCTAssertEqual(requestCount, 6)
    }

    func test_createCard_metadataDoesNotBypassRequiredFieldValidation() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      configureMetadataTestSession()
      CMPURLProtocolStub.requestHandler = { _ in
        XCTFail("Invalid collected fields must not send a card request")
        throw NSError(domain: "UnexpectedRequest", code: 0)
      }
      let completion = expectation(description: "validation response")
      vgsCollect.createCard(token: "test-jwt", meta: ["orderId": "order-123"]) { response in
        guard case .failure(let code, _, _, _) = response else {
          XCTFail("Expected input validation failure")
          completion.fulfill()
          return
        }
        XCTAssertEqual(code, VGSErrorType.inputDataIsNotValid.rawValue)
        completion.fulfill()
      }
      wait(for: [completion], timeout: 1)
    }

    func test_createCard_metadataRetryReusesOriginalBody() async {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let fields = configureMetadataTestFields()
      defer { withExtendedLifetime(fields) {} }
      configureMetadataTestSession()
      var metadata = ["orderId": "original-order"]
      var authCount = 0
      var bodies = [Data]()
      vgsCollect.authHandler = { completion in
        authCount += 1
        if authCount == 2 {
          metadata["orderId"] = "changed-order"
          fields[1].setText("12/31")
        }
        completion(.success("test-jwt-\(authCount)"))
      }
      CMPURLProtocolStub.requestHandler = { request in
        bodies.append(try XCTUnwrap(Self.requestBodyData(from: request)))
        let status = bodies.count == 1 ? 401 : 200
        let response = try XCTUnwrap(HTTPURLResponse(
          url: try XCTUnwrap(request.url), statusCode: status, httpVersion: nil, headerFields: nil
        ))
        return (response, Data("{}".utf8))
      }
      let result = await vgsCollect.createCard(meta: metadata)
      guard case .success(let code, _, _) = result else { XCTFail("Expected refreshed creation success"); return }
      XCTAssertEqual(code, 200)
      XCTAssertEqual(authCount, 2)
      XCTAssertEqual(bodies.count, 2)
      guard bodies.count == 2 else { return }
      // JSON object key ordering is not a wire contract.
      let first = try? JSONSerialization.jsonObject(with: bodies[0]) as? NSDictionary
      let retry = try? JSONSerialization.jsonObject(with: bodies[1]) as? NSDictionary
      XCTAssertNotNil(first)
      XCTAssertEqual(first, retry)
      XCTAssertTrue(String(data: bodies[1], encoding: .utf8)?.contains("original-order") == true)
      XCTAssertFalse(String(data: bodies[1], encoding: .utf8)?.contains("changed-order") == true)
    }

    func test_createCard_customMetadataValuesNeverEnterAnalytics() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let fields = configureMetadataTestFields()
      defer { withExtendedLifetime(fields) {} }
      configureMetadataTestSession()
      VGSAnalyticsClient.shared.urlSession = vgsCollect.cmpAPIClient.urlSession
      VGSAnalyticsClient.shared.shouldCollectAnalytics = true
      let analyticsExpectation = expectation(description: "existing analytics events")
      analyticsExpectation.expectedFulfillmentCount = 2
      let completionExpectation = expectation(description: "card response")
      var payloads = [[String: Any]]()
      CMPURLProtocolStub.requestHandler = { request in
        let url = try XCTUnwrap(request.url)
        if url.host == "vgs-collect-keeper.apps.verygood.systems" {
          let encoded = try XCTUnwrap(Self.requestBodyData(from: request))
          let decoded = try XCTUnwrap(Data(base64Encoded: encoded))
          payloads.append(try XCTUnwrap(JSONSerialization.jsonObject(with: decoded) as? [String: Any]))
          let text = String(data: decoded, encoding: .utf8) ?? ""
          XCTAssertFalse(text.contains("synthetic-private-order"))
          XCTAssertFalse(text.contains("orderId"))
          analyticsExpectation.fulfill()
        } else {
          let body = try XCTUnwrap(Self.requestBodyData(from: request))
          let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
          let data = try XCTUnwrap(payload["data"] as? [String: Any])
          XCTAssertEqual((data["meta"] as? [String: String])?["orderId"], "synthetic-private-order")
        }
        return (try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)), Data("{}".utf8))
      }
      vgsCollect.createCard(token: "test-jwt", meta: ["orderId": "synthetic-private-order"]) { response in
        guard case .success = response else { XCTFail("Expected creation success"); completionExpectation.fulfill(); return }
        completionExpectation.fulfill()
      }
      wait(for: [analyticsExpectation, completionExpectation], timeout: 2)
      XCTAssertEqual(Set(payloads.compactMap { $0["type"] as? String }), ["BeforeSubmit", "Submit"])
      XCTAssertEqual(Set(payloads.compactMap { $0["operation"] as? String }), ["cardCreate"])
      for payload in payloads { XCTAssertEqual(payload["content"] as? [String], ["textField"]) }
    }

    private func configureMetadataTestFields() -> [VGSTextField] {
      let card = VGSTextField()
      card.configuration = .makeCardNumberConfiguration(collector: vgsCollect)
      card.setText("4111111111111111")
      let expiration = VGSTextField()
      expiration.configuration = .makeExpDateConfiguration(collector: vgsCollect)
      expiration.setText("12/30")
      return [card, expiration]
    }

    private func configureMetadataTestSession() {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [CMPURLProtocolStub.self]
      vgsCollect.cmpAPIClient.urlSession = URLSession(configuration: configuration)
    }

    func test_createCard_mapsFieldsToCMPAttributes() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")

      let panField = VGSTextField()
      panField.configuration = .makeCardNumberConfiguration(collector: vgsCollect)
      panField.setText("4111111111111111")

      let nameField = VGSTextField()
      nameField.configuration = .makeCardholderConfiguration(collector: vgsCollect)
      nameField.setText("Taylor Doe")

      let expField = VGSTextField()
      expField.configuration = .makeExpDateConfiguration(collector: vgsCollect)
      expField.setText("12/30")

      let cvcField = VGSTextField()
      cvcField.configuration = .makeCVCConfiguration(collector: vgsCollect)
      cvcField.setText("123")

      let body = vgsCollect.buildCreateCardBody(extraData: [
        "cardholder": [
          "address": ["city": "Kyiv"]
        ]
      ])

      guard let data = body["data"] as? [String: Any],
            let attributes = data["attributes"] as? [String: Any],
            let cardholder = attributes["cardholder"] as? [String: Any],
            let address = cardholder["address"] as? [String: Any] else {
        XCTFail("Expected CMP create attributes")
        return
      }

      XCTAssertEqual(attributes["pan"] as? String, "4111111111111111")
      XCTAssertEqual(attributes["cvc"] as? String, "123")
      XCTAssertEqual(attributes["exp_month"] as? Int, 12)
      XCTAssertEqual(attributes["exp_year"] as? Int, 30)
      XCTAssertEqual(cardholder["name"] as? String, "Taylor Doe")
      XCTAssertEqual(address["city"] as? String, "Kyiv")
    }

    func test_updateCard_mapsOnlyMutableSecureFields() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")

      let panField = VGSTextField()
      panField.configuration = .makeCardNumberConfiguration(collector: vgsCollect)
      panField.setText("4111111111111111")

      let expField = VGSTextField()
      expField.configuration = .makeExpDateConfiguration(collector: vgsCollect)
      expField.setText("12/30")

      let cvcField = VGSTextField()
      cvcField.configuration = .makeCVCConfiguration(collector: vgsCollect)
      cvcField.setText("123")

      let body = vgsCollect.buildUpdateCardBody()

      guard let data = body["data"] as? [String: Any],
            let attributes = data["attributes"] as? [String: Any] else {
        XCTFail("Expected CMP update attributes")
        return
      }

      XCTAssertEqual(attributes["cvc"] as? String, "123")
      XCTAssertEqual(attributes["exp_month"] as? Int, 12)
      XCTAssertEqual(attributes["exp_year"] as? Int, 30)
      XCTAssertNil(attributes["pan"])
      XCTAssertNil(data["meta"])
    }

    func test_updateCard_rejectsEmptyCardID() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let expectation = expectation(description: "update completion")

      vgsCollect.updateCard(cardId: "  ", token: "token") { response in
        guard case .failure(let code, _, _, let error) = response else {
          XCTFail("Expected invalid card ID failure")
          expectation.fulfill()
          return
        }
        XCTAssertEqual(code, VGSErrorType.invalidCardID.rawValue)
        XCTAssertEqual((error as? VGSError)?.type, .invalidCardID)
        expectation.fulfill()
      }

      wait(for: [expectation], timeout: 1.0)
    }

    func test_updateCard_rejectsUnsupportedAttributesBeforeRequest() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [CMPURLProtocolStub.self]
      vgsCollect.cmpAPIClient.urlSession = URLSession(configuration: configuration)
      let requestExpectation = expectation(description: "request not sent")
      requestExpectation.isInverted = true
      let completionExpectation = expectation(description: "completion")

      CMPURLProtocolStub.requestHandler = { request in
        requestExpectation.fulfill()
        let response = HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        return (response, Data("{}".utf8))
      }

      vgsCollect.updateCard(
        cardId: "card_123",
        token: "token-123",
        extraData: ["nickname": "Primary"]
      ) { response in
        guard case .failure(let code, _, _, let error) = response else {
          XCTFail("Expected unsupported attributes failure")
          completionExpectation.fulfill()
          return
        }
        XCTAssertEqual(code, VGSErrorType.inputDataIsNotValid.rawValue)
        XCTAssertEqual((error as? VGSError)?.type, .inputDataIsNotValid)
        completionExpectation.fulfill()
      }

      wait(for: [completionExpectation, requestExpectation], timeout: 1.0)
    }

    func test_updateCard_rejectsEmptyAttributesBeforeRequest() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [CMPURLProtocolStub.self]
      vgsCollect.cmpAPIClient.urlSession = URLSession(configuration: configuration)
      let requestExpectation = expectation(description: "request not sent")
      requestExpectation.isInverted = true
      let completionExpectation = expectation(description: "completion")

      CMPURLProtocolStub.requestHandler = { request in
        requestExpectation.fulfill()
        let response = HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        return (response, Data("{}".utf8))
      }

      vgsCollect.updateCard(cardId: "card_123", token: "token-123") { response in
        guard case .failure(let code, _, _, let error) = response else {
          XCTFail("Expected empty attributes failure")
          completionExpectation.fulfill()
          return
        }
        XCTAssertEqual(code, VGSErrorType.inputDataIsNotValid.rawValue)
        XCTAssertEqual((error as? VGSError)?.type, .inputDataIsNotValid)
        completionExpectation.fulfill()
      }

      wait(for: [completionExpectation, requestExpectation], timeout: 1.0)
    }

    func test_updateCard_sendsPatchToCardPathWithExpectedBody() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [CMPURLProtocolStub.self]
      vgsCollect.cmpAPIClient.urlSession = URLSession(configuration: configuration)

      let requestExpectation = expectation(description: "request")
      let completionExpectation = expectation(description: "completion")

      CMPURLProtocolStub.requestHandler = { request in
        XCTAssertEqual(request.url?.absoluteString, "https://sandbox.vgsapi.com/cards/card_123")
        XCTAssertEqual(request.httpMethod, "PATCH")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-123")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/vnd.api+json")

        let bodyData = try XCTUnwrap(Self.requestBodyData(from: request))
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
        let data = try XCTUnwrap(body["data"] as? [String: Any])
        let attributes = try XCTUnwrap(data["attributes"] as? [String: Any])
        XCTAssertEqual(attributes["exp_month"] as? Int, 4)
        XCTAssertNil(data["meta"])

        requestExpectation.fulfill()
        let response = HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        return (response, Data("{}".utf8))
      }

      vgsCollect.updateCard(
        cardId: "card_123",
        token: "token-123",
        extraData: ["exp_month": 4]
      ) { response in
        guard case .success(let code, _, _) = response else {
          XCTFail("Expected update success")
          completionExpectation.fulfill()
          return
        }
        XCTAssertEqual(code, 200)
        completionExpectation.fulfill()
      }

      wait(for: [requestExpectation, completionExpectation], timeout: 2.0)
    }

    func test_updateCard_acceptsPrefixedBearerToken() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [CMPURLProtocolStub.self]
      vgsCollect.cmpAPIClient.urlSession = URLSession(configuration: configuration)
      let expectation = expectation(description: "completion")

      CMPURLProtocolStub.requestHandler = { request in
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-123")
        let response = HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        return (response, Data("{}".utf8))
      }

      vgsCollect.updateCard(
        cardId: "card_123",
        token: "Bearer token-123",
        extraData: ["exp_year": 30]
      ) { response in
        guard case .success = response else {
          XCTFail("Expected update success")
          expectation.fulfill()
          return
        }
        expectation.fulfill()
      }

      wait(for: [expectation], timeout: 2.0)
    }

    func test_updateCard_tracksPrivacySafeOperationAnalytics() {
      vgsCollect = VGSCollect(id: "tntid", environment: "sandbox")
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [CMPURLProtocolStub.self]
      vgsCollect.cmpAPIClient.urlSession = URLSession(configuration: configuration)
      VGSAnalyticsClient.shared.urlSession = URLSession(configuration: configuration)
      VGSAnalyticsClient.shared.shouldCollectAnalytics = true

      let analyticsExpectation = expectation(description: "analytics")
      analyticsExpectation.expectedFulfillmentCount = 2
      let completionExpectation = expectation(description: "completion")
      var analyticsPayloads = [[String: Any]]()

      CMPURLProtocolStub.requestHandler = { request in
        let url = try XCTUnwrap(request.url)
        if url.host == "vgs-collect-keeper.apps.verygood.systems" {
          let encodedData = try XCTUnwrap(Self.requestBodyData(from: request))
          let decodedData = try XCTUnwrap(Data(base64Encoded: encodedData))
          let payload = try XCTUnwrap(
            JSONSerialization.jsonObject(with: decodedData) as? [String: Any]
          )
          analyticsPayloads.append(payload)
          let payloadDescription = String(data: decodedData, encoding: .utf8) ?? ""
          XCTAssertFalse(payloadDescription.contains("token-123"))
          analyticsExpectation.fulfill()
        }

        let response = HTTPURLResponse(
          url: url,
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        return (response, Data("{}".utf8))
      }

      vgsCollect.updateCard(
        cardId: "card_123",
        token: "token-123",
        extraData: ["exp_month": 4]
      ) { response in
        guard case .success = response else {
          XCTFail("Expected update success")
          completionExpectation.fulfill()
          return
        }
        completionExpectation.fulfill()
      }

      wait(for: [analyticsExpectation, completionExpectation], timeout: 2.0)
      XCTAssertEqual(Set(analyticsPayloads.compactMap { $0["type"] as? String }), ["BeforeSubmit", "Submit"])
      XCTAssertEqual(Set(analyticsPayloads.compactMap { $0["operation"] as? String }), ["cardUpdate"])
      XCTAssertEqual(Set(analyticsPayloads.compactMap { $0["upstream"] as? String }), ["cmp"])
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
      var buffer = [UInt8](repeating: 0, count: 1_024)
      while stream.hasBytesAvailable {
        let readCount = stream.read(&buffer, maxLength: buffer.count)
        if readCount <= 0 { break }
        data.append(buffer, count: readCount)
      }
      return data.isEmpty ? nil : data
    }
}
