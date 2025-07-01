//
//  VaultAPI.swift
//  VGSCollectSDK
//

/// Vault API Version Enum
enum VaultAPIVersion {
  case v1
  case v2
  
func getTokenizationPath() -> String {
    switch self {
    case .v1:
      return "tokens"
    case .v2:
      return "aliases"
    }
  }
}
