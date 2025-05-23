//
//  VGSCardmanager.swift
//  VGSCollectSDK
//


public class VGSCardManager {
  
  internal let collector: VGSCollect
  private let accountId: String
  internal var authToken: String?
  
  public var textFields: [VGSTextField] {
    return collector.textFields
  }
    
  public required init(accountId: String, environment: String) {
    // TODO: validate attributes
    self.accountId = accountId
    collector = VGSCollect(accountId: accountId, environment: environment)
  }
  
  public func createCard(authToken: String, completion block: @escaping (VGSResponse) -> Void) {
    return collector.createCard(authToken: authToken, completion: block)
  }
  
  public func setAuthToken(_ authToken: String) {
    self.authToken = authToken
  }
}
