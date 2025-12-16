//
//  MockedDataProvider.swift
//  FrameworkTests
//
//  Created by Eugene on 04.07.2022.
//  Copyright © 2022 VGS. All rights reserved.
//

import Foundation

/// Mocked data provider.
final class MockedDataProvider {

  /// Mocked tokenization vault id.
  var vaultId: String = ""
	/// Mocked tokenization vault id.
	var tokenizationVaultId: String = ""
	/// Shared instance.
	static let shared = MockedDataProvider()

	/// no:doc
	private init() {
		provideMockedData()
	}

	/// Provided mocked data.
	private func provideMockedData() {
		#if SWIFT_PACKAGE
			let bundle = Bundle.module
		#else
			let bundle = Bundle(for: type(of: VGSCollectTestBundleHelper()))
		#endif

		if let path = bundle.path(forResource: "MockedData", ofType: "plist") {
			guard let dictionary = NSDictionary(contentsOfFile: path) else {
					assertionFailure("Mocked data not found!")
					return
			}
      vaultId = dictionary["VAULT_ID"] as? String ?? ""
			tokenizationVaultId = dictionary["TOKENIZATION_VAULT_ID"] as? String ?? ""
		} else {
			assertionFailure("Mocked data not found!")
		}
	}
}
