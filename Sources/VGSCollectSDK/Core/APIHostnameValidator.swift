//
//  APIHostnameValidator.swift
//  VGSCollectSDK
//
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal class APIHostnameValidator {

	private static let hostValidatorBaseURL = URL(string: "https://js.verygoodvault.com/collect-configs")!

	internal static func hasSecureScheme(url: URL) -> Bool {
		return url.scheme == "https"
	}

	internal static func urlWithSecureScheme(from url: URL) -> URL? {
		var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		components?.scheme = "https"

		return components?.url
	}

  internal static func validateCustomHostname(_ hostname: String, tenantId: String, completion: @escaping ((URL?) -> Void)) {

    guard !hostname.isEmpty else {
      completion(nil)
      return
    }

		if let url = buildHostValidationURL(with: hostname, tenantId: tenantId), let normalizedHostName = hostname.normalizedHostname() {
      DispatchQueue.global(qos: .userInitiated).async {
          let contents = try? String(contentsOf: url)
          DispatchQueue.main.async {
            if let contents = contents, contents.contains(normalizedHostName) {
              completion(URL(string: contents))
              return
            } else {
              print("ERROR: NOT VALID HOST NAME!!! WILL USE VAULT URL INSTEAD!!!")
              completion(nil)
              return
            }
          }
       }
    } else {
			print("ERROR: CANNOT BUILD HOSTNAME WITH: \(hostname)")
      completion(nil)
    }
  }

	internal static func buildHostValidationURL(with hostname: String, tenantId: String) -> URL? {

		guard let normalizedHostname = hostname.normalizedHostname() else {return nil}

		let hostPath = "\(normalizedHostname)__\(tenantId).txt"

		let	url = hostValidatorBaseURL.appendingPathComponent(hostPath)
		print("final url: \(url)")
		return url
	}
}
