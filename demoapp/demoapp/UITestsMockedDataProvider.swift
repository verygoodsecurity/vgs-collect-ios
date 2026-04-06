//
//  UITestsMockedDataProvider.swift
//  demoapp
//

import Foundation

/// Utility class for UITests only.
final class UITestsMockedDataProvider {

  enum RequestKind {
    case collect
    case tokenize
  }

  private enum Fallback {
    static let vaultId = "demovaultid123"
    static let tokenizationVaultId = "demotokenvault123"
  }

  @MainActor private(set) static var isUsingFallbackVaultId = false
  @MainActor private(set) static var isUsingFallbackTokenizationVaultId = false

  @MainActor static func setupMockedDataForTestsIfNeeded() {
    guard isRunningUITest else { return }

    var dictionary = [String: Any]()
    if let path = Bundle.main.path(forResource: "UITestsMockedData", ofType: "plist"),
       let values = NSDictionary(contentsOfFile: path) as? [String: Any] {
      dictionary = values
    }

    let validVaultId = validatedVaultId(dictionary["vaultID"] as? String)
    let validTokenizationVaultId = validatedVaultId(dictionary["tokenization_vaultId"] as? String)
    isUsingFallbackVaultId = validVaultId == nil
    isUsingFallbackTokenizationVaultId = validTokenizationVaultId == nil

    let vaultIdForUITests = validVaultId ?? Fallback.vaultId
    AppCollectorConfiguration.shared.vaultId = vaultIdForUITests

    let tokenizationVaultIdForUITests = validTokenizationVaultId ?? Fallback.tokenizationVaultId
    AppCollectorConfiguration.shared.tokenizationVaultId = tokenizationVaultIdForUITests
  }

  private static func validatedVaultId(_ value: String?) -> String? {
    guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
      return nil
    }

    guard value.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil else {
      return nil
    }

    return value
  }

	/// `true` if demo app in UITests mode.
  static var isRunningUITest: Bool {
			return ProcessInfo().arguments.contains("VGSCollectDemoAppUITests")
	}

  @MainActor static func mockedSuccessResponse(for requestKind: RequestKind) -> String? {
    guard isRunningUITest else { return nil }

    switch requestKind {
    case .collect where isUsingFallbackVaultId:
      return "Success: \n{ \"mocked\": true }"
    case .tokenize where isUsingFallbackTokenizationVaultId:
      return "Success: \n{ \"mocked\": true }"
    default:
      return nil
    }
  }
}
