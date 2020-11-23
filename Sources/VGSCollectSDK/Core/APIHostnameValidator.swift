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

		var nornalizedHostname = hostname
		// Drop last "/" for valid file path.
		if hostname.hasSuffix("/") {
			nornalizedHostname = String(nornalizedHostname.dropLast())
		}

		let hostPath = "\(nornalizedHostname)__\(tenantId).txt"
		guard let component = URLComponents(string: hostPath) else {
			// Cannot build component
			return nil
		}

		var path: String
		if let componentHost = component.host {
			// Use hostname if component is url with scheme.
			path = componentHost
		} else {
			// Use path if component has path only.
			path = component.path
		}

		let wwwPrefix = "www."
		// Remove www. if neeeded.
		if path.hasPrefix(wwwPrefix) {
			path = String(path.dropFirst(wwwPrefix.count))
		}

		let	url = hostValidatorBaseURL.appendingPathComponent(path)
		return url
	}
}
