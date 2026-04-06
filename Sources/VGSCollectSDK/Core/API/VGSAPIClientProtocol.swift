//
//  BaseAPIClient.swift
//  VGSCollectSDK
//

import Foundation

typealias VGSResponseCompletion = @MainActor (VGSResponse) -> Void
typealias VGSResolvedURLCompletion = @MainActor (URL) -> Void
typealias VGSOptionalURLCompletion = @MainActor (URL?) -> Void

@MainActor protocol VGSAPIClientProtocol {
  var baseURL: URL? { get }
//  var analyticsHeaders: HTTPHeaders { get }
  /// Custom headers from VGSCollect.customHeaders
  var customHeader: HTTPHeaders? { get set }
  
  var urlSession: URLSession { get }

  func sendRequest(path: String, method: VGSCollectHTTPMethod, routeId: String?, value: BodyData, completion block: VGSResponseCompletion? )
  
  func setCustomHeaders(headers: HTTPHeaders?)
}

extension VGSAPIClientProtocol {
  mutating func setCustomHeaders(headers: HTTPHeaders?) {
    customHeader = headers
  }
}
