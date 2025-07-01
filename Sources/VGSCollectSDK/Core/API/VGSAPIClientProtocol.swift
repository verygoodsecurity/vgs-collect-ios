//
//  BaseAPIClient.swift
//  VGSCollectSDK
//


import Foundation

protocol VGSAPIClientProtocol {
  var baseURL: URL? { get }
  /// Analytics & SDK header only.  Content-Type lives in subclasses.
//  var analyticsHeaders: HTTPHeaders { get }
  /// Custom headers from VGSCollect.customHeaders
  var customHeader: HTTPHeaders? { get set }
  
  var urlSession: URLSession { get }

  func sendRequest(path: String, method: VGSCollectHTTPMethod, routeId: String?, value: BodyData, completion block: ((_ response: VGSResponse) -> Void)? )
  
  func setCustomHeaders(headers: HTTPHeaders?)
}

extension VGSAPIClientProtocol {
  mutating func setCustomHeaders(headers: HTTPHeaders?) {
    customHeader = headers
  }
}
