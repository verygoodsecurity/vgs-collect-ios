//
//  VGSCollectSatelliteUtils.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Collect utils for satellite.
internal class VGSCollectSatelliteUtils {

	/// Constants.
	internal enum Constants {

		/// Valid port numbers.
		static let validPortNumbers: ClosedRange<Int> = 1...65535

		/// Valid localhost prefix.
		static let validLocalHostPrefix = "localhost"

		/// Valid localhost IP address prefix.
		static let validLocalIPAddressPrefix = "192.168"
	}

	/// Build URL for satellite.
	/// - Parameters:
	///   - environment: `String` object, only `sandbox` is valid.
	///   - hostname: `String` object, should be valid hostname for satellite.
	///   - satellitePort: `Int` object, should be valid port.
	/// - Returns: `URL?`, satellite `URL` or `nil` for invalid configuration.
	internal static func buildSatelliteURL(with environment: String, hostname: String?, satellitePort: Int) -> URL? {

		// Check satelliteHostname is set.
		guard let satelliteHostname = hostname else {
			let errorText = "SATELLITE CONFIGURATION ERROR! HOSTNAME NOT SET! SHOULD BE *http://localhost* or *http://192.168.*"
			let event = VGSLogEvent(level: .warning, text: errorText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)

			return nil
		}

		// Check environment == .sandbox, validate port.
		guard isEnvironmentValidForSatellite(environment), isSatellitePortValid(satellitePort) else {
			return nil
		}

		// Check hostname is valid for satellite.
		guard isSatelliteHostnameValid(satelliteHostname) else {
			return nil
		}

		// Normalize URL. Set HTTP scheme.
		guard let normalizedHostname = satelliteHostname.normalizedHostname(), let url = URL(string: normalizedHostname), let httpSatelliteURL = URL.urlWithHTTPScheme(from: url) else {

			// Cannot normalize hostname for satellite.
			let errorText = "SATELLITE CONFIGURATION ERROR! HOSTNAME \(satelliteHostname) IS NOT VALID AND CANNOT BE NORMALIZED FOR SATELLITE! SHOULD BE *http://localhost* or *http://192.168.*"
			let event = VGSLogEvent(level: .warning, text: errorText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)

			return nil
		}

		return httpSatelliteURL
	}

	/// Validate satellite hostname. Should be http://localhost or http://192.168 or 192.168.1.3
	/// Any other hostnames will be ignored for satellite.
	/// - Parameter hostname: `String` object, hostname to validate.
	/// - Returns: `true` if hostname is valid for satellite.
	internal static func isSatelliteHostnameValid(_ hostname: String) -> Bool {

		// Normalize hostname.
		guard let normalizedHostName = hostname.normalizedHostname() else {
			return false
		}

		// Create components.
		guard let components = URLComponents(string: normalizedHostName) else {return false}

		var path: String
		if let componentHost = components.host {
			// Use hostname if component is url with scheme.
			path = componentHost
		} else {
			// Use path if component has path only.
			path = components.path
		}

		if path == Constants.validLocalHostPrefix {
			return true
		}

		if path.hasPrefix(Constants.validLocalIPAddressPrefix) {
			return true
		}

		let errorText = "SATELLITE CONFIGURATION ERROR! HOSTNAME \(hostname) IS INVALID FOR SATELLITE! SHOULD BE *http://localhost* or *192.168.*"
		let event = VGSLogEvent(level: .warning, text: errorText, severityLevel: .error)
		VGSCollectLogger.shared.forwardLogEvent(event)

		return false
	}

	/// Return `true` if environment is valid for satellite (`.sandbox`).
	/// - Parameter environment: `String` object, environment to check.
	/// - Returns: `Bool` flag, `true` if `.sandbox`, otherwise `false`.
	internal static func isEnvironmentValidForSatellite(_ environment: String) -> Bool {
		guard environment == Environment.sandbox.rawValue else {
			let errorText = "CONFIGURATION ERROR! ENVIRONMENT *\(environment)* IS NOT *sandbox*! SATELLITE IS AVAILABLE ONLY FOR *sandbox*!"
			let event = VGSLogEvent(level: .warning, text: errorText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)

			return false
		}

		return true
	}

	/// Return `true` if port is valid for satellite.
	/// - Parameter port: `Int` object, should be valid port.
	/// - Returns: `Bool` flag, `true` if port in range *1...65535*, otherwise `false`.
	internal static func isSatellitePortValid(_ port: Int) -> Bool {
		guard Constants.validPortNumbers.contains(port) else {
			let errorText = "SATELLITE CONFIGURATION ERROR! PORT \(port) is invalid! Should be in range *1...65535*."
			let event = VGSLogEvent(level: .warning, text: errorText, severityLevel: .error)
			VGSCollectLogger.shared.forwardLogEvent(event)

			return false
		}

		return true
	}
}
