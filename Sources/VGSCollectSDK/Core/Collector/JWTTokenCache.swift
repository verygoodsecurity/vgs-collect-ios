//
//  JWTTokenCache.swift
//  VGSCollectSDK
//

import Foundation

/// Simple in-memory cache for a bearer JWT token.
///
/// We don't attempt to parse JWT `exp` claim. Instead we optimistically reuse the token
/// until the server reports it as invalid/expired (401/403), at which point we invalidate.
@MainActor
internal final class JWTTokenCache {

  private var cachedToken: String?

  var token: String? {
    cachedToken
  }

  func store(_ token: String) {
    let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
    cachedToken = trimmed.isEmpty ? nil : trimmed
  }

  func invalidate() {
    cachedToken = nil
  }
}
