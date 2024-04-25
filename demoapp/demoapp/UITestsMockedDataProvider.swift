//
//  UITestsMockedDataProvider.swift
//  demoapp
//

import Foundation

/// Utility class for UITests only.
final class UITestsMockedDataProvider {

	static func setupMockedDataForTestsIfNeeded() {
		if isRunningUITest {
			guard let path = Bundle.main.path(forResource: "UITestsMockedData", ofType: "plist") else {
					print("Path not found")
					return
			}

			guard let dictionary = NSDictionary(contentsOfFile: path) else {
					print("Unable to get dictionary from path")
					return
			}

      let vaultIdForUITests = dictionary["vaultID"] as? String ?? ""
      AppCollectorConfiguration.shared.vaultId = vaultIdForUITests
      let tokenizationVaultIdForUITests = dictionary["tokenization_vaultId"] as? String ?? ""
      AppCollectorConfiguration.shared.tokenizationVaultId = tokenizationVaultIdForUITests
		}
	}

	/// `true` if demo app in UITests mode.
	static var isRunningUITest: Bool {
			return ProcessInfo().arguments.contains("VGSCollectDemoAppUITests")
	}
}
