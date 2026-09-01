import XCTest
@testable import VGSCollectSDK

private final class SessionFormConfigurationURLProtocolStub: URLProtocol {
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    guard let handler = Self.requestHandler else {
      let error = NSError(domain: "SessionFormConfigurationURLProtocolStub", code: 0)
      client?.urlProtocol(self, didFailWithError: error)
      return
    }

    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      if let data {
        client?.urlProtocol(self, didLoad: data)
      }
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}

@MainActor
final class SessionFormConfigurationTests: XCTestCase {

  override func setUp() {
    super.setUp()
    SessionFormConfigurationURLProtocolStub.requestHandler = nil
    VGSCollect.sessionConfigurationURLSessionFactory = {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [SessionFormConfigurationURLProtocolStub.self]
      return URLSession(configuration: configuration)
    }
  }

  override func tearDown() {
    SessionFormConfigurationURLProtocolStub.requestHandler = nil
    VGSCollect.sessionConfigurationURLSessionFactory = {
      URLSession(configuration: .ephemeral)
    }
    super.tearDown()
  }

  func testCollectConfigFilenameHexUsesLowercaseUTF8() {
    XCTAssertEqual(VGSCollect.collectConfigFilenameHex(form: "my-form"), "6d792d666f726d")
    XCTAssertEqual(VGSCollect.collectConfigFilenameHex(form: "Aß"), "41c39f")
  }

  func testBuildSessionConfigURLUsesCanonicalTemplate() {
    let url = VGSCollect.buildSessionConfigURL(form: "my-form", vaultId: "vault123")
    XCTAssertEqual(url?.absoluteString, "https://js.verygoodvault.com/session-configuration/vault123/6d792d666f726d.json")
  }

  func testValidateFormIdEnforcesMaxLength50() {
    let valid50 = String(repeating: "a", count: 50)
    let invalid51 = String(repeating: "a", count: 51)

    XCTAssertTrue(VGSCollect.validateFormId(valid50))
    XCTAssertFalse(VGSCollect.validateFormId(invalid51))
  }

  func testResolveIncludedCardAttributesUsesCanonicalConfigOnlyWhenEnabled() {
    let enabledConfig = VGSCollect.VGSFormConfigurationData.Config(
      cardAttributes: .init(enable: true, parameters: [" bin ", "", "cardBrand", "bin"])
    )

    XCTAssertEqual(
      VGSCollect.resolveIncludedCardAttributes(from: enabledConfig),
      ["bin", "cardBrand"]
    )
  }

  func testResolveIncludedCardAttributesReturnsEmptyForDisabledOrMissingParameters() {
    let disabledConfig = VGSCollect.VGSFormConfigurationData.Config(
      cardAttributes: .init(enable: false, parameters: ["bin"])
    )
    let noParametersConfig = VGSCollect.VGSFormConfigurationData.Config(
      cardAttributes: .init(enable: true, parameters: [])
    )
    let missingParametersConfig = VGSCollect.VGSFormConfigurationData.Config(
      cardAttributes: .init(enable: true, parameters: nil)
    )
    let nilConfig: VGSCollect.VGSFormConfigurationData.Config? = nil

    XCTAssertEqual(VGSCollect.resolveIncludedCardAttributes(from: disabledConfig), [])
    XCTAssertEqual(VGSCollect.resolveIncludedCardAttributes(from: noParametersConfig), [])
    XCTAssertEqual(VGSCollect.resolveIncludedCardAttributes(from: missingParametersConfig), [])
    XCTAssertEqual(VGSCollect.resolveIncludedCardAttributes(from: nilConfig), [])
  }

  func testSessionCollectInitExtraDataUsesSessionFormTypeAndConfigLoadMetrics() {
    let metrics = VGSCollect.VGSFormConfigurationLoadMetrics(
      filename: "6d792d666f726d.json",
      statusCode: 200,
      latency: 123
    )

    let extraData = VGSCollect.sessionCollectInitExtraData(metrics: metrics)

    XCTAssertEqual(extraData["formType"] as? String, "session")
    XCTAssertEqual(extraData["configFile"] as? String, "6d792d666f726d.json")
    XCTAssertEqual(extraData["configFileStatusCode"] as? Int, 200)
    XCTAssertEqual(extraData["configFileLatency"] as? Int, 123)
  }

  func testCollectInitExtraDataDistinguishesCreateFromSession() {
    let metrics = VGSCollect.VGSFormConfigurationLoadMetrics(
      filename: "6d792d666f726d.json",
      statusCode: 200,
      latency: 123
    )

    let createExtraData = VGSCollect.createCollectInitExtraData()
    let sessionExtraData = VGSCollect.sessionCollectInitExtraData(metrics: metrics)

    XCTAssertEqual(createExtraData["formType"] as? String, "create")
    XCTAssertEqual(sessionExtraData["formType"] as? String, "session")
  }

  func testLegacyCreateAnalyticsEventTypeRemainsAvailable() {
    XCTAssertEqual(VGSAnalyticsEventType.create.rawValue, "Create")
    XCTAssertEqual(VGSAnalyticsEventType.collectInit.rawValue, "CollectInit")
  }

  func testSessionReturnsCollectorWithInlineFallbackForNon2xxFormLoad() async {
    let responseBody = Data(#"{"errors":[{"code":"invalid_form"}]}"#.utf8)
    let errorExpectation = expectation(description: "configuration error")

    SessionFormConfigurationURLProtocolStub.requestHandler = { request in
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 422,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
      )!
      return (response, responseBody)
    }

    let response = await sessionInitializationResponse(
      form: "my_form",
      vaultId: "vault123",
      configuration: [
        "cardAttributes": [
          "enable": true,
          "parameters": [" card_type ", "brand"]
        ]
      ],
      onError: { error in
        XCTAssertTrue(error is VGSCollect.VGSFormConfigurationLoadError)
        XCTAssertEqual(error.localizedDescription, "Failed to load form configuration: 422.")
        errorExpectation.fulfill()
      }
    )

    guard case .success(let collector) = response else {
      XCTFail("Expected session collector")
      return
    }

    XCTAssertEqual(collector.sessionFormId, "my_form")
    XCTAssertEqual(collector.includedCardAttributes, ["card_type", "brand"])
    await fulfillment(of: [errorExpectation], timeout: 1.0)
  }

  func testSessionReturnsCollectorWithoutLookupForInvalidRemotePayloadAndNoFallback() async {
    let errorExpectation = expectation(description: "configuration error")
    SessionFormConfigurationURLProtocolStub.requestHandler = { request in
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
      )!
      return (response, Data("[]".utf8))
    }

    let response = await sessionInitializationResponse(
      form: "my_form",
      vaultId: "vault123",
      onError: { error in
        guard let loadError = error as? VGSCollect.VGSFormConfigurationLoadError,
              case .failure(let code, _, _, let underlyingError) = loadError.underlyingResponse else {
          XCTFail("Expected session configuration load error")
          errorExpectation.fulfill()
          return
        }
        XCTAssertEqual(code, VGSErrorType.sessionInitializationFailed.rawValue)
        XCTAssertEqual((underlyingError as? VGSError)?.type, .sessionInitializationFailed)
        errorExpectation.fulfill()
      }
    )

    guard case .success(let collector) = response else {
      XCTFail("Expected session collector")
      return
    }

    XCTAssertEqual(collector.sessionFormId, "my_form")
    XCTAssertTrue(collector.includedCardAttributes.isEmpty)
    await fulfillment(of: [errorExpectation], timeout: 1.0)
  }

  func testSessionPrefersRemoteConfigurationOverInlineFallback() async {
    SessionFormConfigurationURLProtocolStub.requestHandler = { request in
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
      )!
      let body = Data(#"{"config":{"cardAttributes":{"enable":true,"parameters":["remote_attribute"]}}}"#.utf8)
      return (response, body)
    }

    let response = await sessionInitializationResponse(
      form: "my_form",
      vaultId: "vault123",
      configuration: [
        "cardAttributes": [
          "enable": true,
          "parameters": ["fallback_attribute"]
        ]
      ],
      onError: { _ in XCTFail("Unexpected configuration error") }
    )

    guard case .success(let collector) = response else {
      XCTFail("Expected session collector")
      return
    }

    XCTAssertEqual(collector.includedCardAttributes, ["remote_attribute"])
  }

  private func sessionInitializationResponse(
    form: String,
    vaultId: String,
    configuration: [String: Any]? = nil,
    onError: ((Error) -> Void)? = nil
  ) async -> VGSCollectSessionResponse {
    return await withCheckedContinuation { continuation in
      VGSCollect.session(
        with: form,
        vaultId: vaultId,
        environment: .sandbox,
        dataRegion: nil,
        configuration: configuration,
        onError: onError,
        completion: { continuation.resume(returning: $0) }
      )
    }
  }
}
