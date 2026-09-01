//
//  VGSCollect+jwt.swift
//  VGSCollectSDK
//

import Foundation

@MainActor
internal extension VGSCollect {

  /// Returns cached JWT if available, otherwise calls `authHandler` to fetch it.
  ///
  /// - Important: This does not validate JWT expiration locally. Token is expected to be invalidated
  ///   by callers on upstream 401/403 responses.
  ///
  /// - Parameter completion: Called with a non-empty token or an error.
  func getOrFetchJWT(completion: @escaping (Result<String, Error>) -> Void) {
    if let cached = jwtTokenCache.token {
      completion(.success(cached))
      return
    }

    guard let authHandler else {
      let message = "authHandler is required."
      let error = VGSError(type: .authHandlerNotSet,
                           userInfo: VGSErrorInfo(key: VGSSDKErrorAuthHandlerNotSet,
                                                  description: message,
                                                  extraInfo: [:]))
      completion(.failure(error))
      return
    }

    authHandler { [weak self] tokenResult in
      guard let self else { return }
      switch tokenResult {
      case .success(let token):
        self.jwtTokenCache.store(token)
        if let cached = self.jwtTokenCache.token {
          completion(.success(cached))
        } else {
          let error = VGSError(type: .invalidAccessToken,
                               userInfo: VGSErrorInfo(key: VGSSDKErrorInvalidAccessToken,
                                                      description: "JWT token is empty.",
                                                      extraInfo: [:]))
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
