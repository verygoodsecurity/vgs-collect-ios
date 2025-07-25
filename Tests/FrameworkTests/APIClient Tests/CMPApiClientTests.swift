import XCTest
@testable import VGSCollectSDK
@MainActor
class CMPAPIClientTests: VGSCollectBaseTestCase {
    
    var formAnalyticsDetails: VGSFormAnanlyticsDetails!
    
    override func setUp() {
        super.setUp()
        // Globally register the mock protocol before each test.
        formAnalyticsDetails = VGSFormAnanlyticsDetails(formId: "testForm", tenantId: "testTenant", environment: "sandbox")
    }
    
    override func tearDown() {
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
    
    /// This test also does not make a network call and is unaffected.
    func test_init_withLiveEnvironment_shouldSetLiveBaseURL() {
        // Given
        let environment = "live"
        
        // When
        let client = CMPAPIClient(environment: environment, formAnalyticsDetails: formAnalyticsDetails)
        
        // Then
        XCTAssertEqual(client.baseURL?.absoluteString, "https://vgsapi.com", "Base URL should be the live URL.")
    }
}
@MainActor
class VGSCollectCreateCardTests: VGSCollectBaseTestCase {
    
    var vgsCollect: VGSCollect!
  
    override func tearDown() {
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
}
