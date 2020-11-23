//
//  APIHostnameValidator.swift
//  VGSCollectSDK
//
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal class APIHostnameValidator {

	private static let hostValidatorBaseURL = URL(string: "https://js.verygoodvault.com/collect-configs")!

  internal static func validateCustomHostname(_ hostname: String, tenantId: String, completion: @escaping ((URL?) -> Void)) {

    guard !hostname.isEmpty else {
      completion(nil)
      return
    }

    if let url = buildHostValidationURL(with: hostname, tenantId: tenantId) {
      DispatchQueue.global(qos: .userInitiated).async {
          let contents = try? String(contentsOf: url)
          DispatchQueue.main.async {
            if let contents = contents, contents.contains(hostname) {
              completion(URL(string: hostname))
              return
            } else {
              print("ERROR: NOT VALID HOST NAME!!! WILL USE VAULT URL INSTEAD!!!")
              completion(nil)
              return
            }
          }
       }
    } else {
      completion(nil)
    }
  }

	internal static func buildHostValidationURL(with hostname: String, tenantId: String) -> URL? {

		let hostPath = "\(hostname)__\(tenantId).txt"
		guard let component = URLComponents(string: hostPath) else {
			// Cannot build component
			return nil
		}

		let url: URL
		if let hostToValid = component.host {
			// Use hostname if component is url with scheme.
			url = hostValidatorBaseURL.appendingPathComponent(hostToValid)
		} else {
			// Use path if component has path only.
			url = hostValidatorBaseURL.appendingPathComponent(component.path)
		}

		print("final url: \(url)")

		return url
	}
}

