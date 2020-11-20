//
//  APIHostNameBuilder.swift
//  VGSCollectSDK
//
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal class APIHostNameBuilder {

	private static let hostValidatorBaseURL = URL(string: "https://js.verygoodvault.com/collect-configs")!

  internal static func buildHostName(_ hostName: String, tenantId: String, completion: @escaping ((URL?) -> Void)) {

    guard !hostName.isEmpty else {
      completion(nil)
      return
    }

    if let url = buildHostValidationURL(with: hostName, tenantId: tenantId) {
      DispatchQueue.global(qos: .userInitiated).async {
          let contents = try? String(contentsOf: url)
          DispatchQueue.main.async {
            if let contents = contents, contents.contains(hostName) {
              completion(URL(string: hostName))
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

	internal static func buildHostValidationURL(with host: String, tenantId: String) -> URL? {

		let hostPath = "\(host)__\(tenantId).txt"
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

