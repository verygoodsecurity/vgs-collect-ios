//
//  APICustomHostStatus.swift
//  VGSCollectSDK
//
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Determinates hostname status states.
internal enum APICustomHostStatus {
	/**
	 Resolving host name is in progress.

	 - Parameters:
			- hostnameToResolve: `String` object, hostname to resolve.
	*/
	case isResolving(_ hostnameToResolve: String)

	/**
	 Hostname is resolved and can be used for requests.

	 - Parameters:
			- resolvedURL: `URL` object, resolved host name URL.
	*/
	case resolved(_ resolvedURL: URL)

	/**
	 Hostname cannot be resolved, default vault URL will be used.

	 - Parameters:
			- vaultURL: `URL` object, should be default vault URL.
	*/
	case useDefaultVault(_ vaultURL: URL)

	var url: URL? {
		switch self {
		case .isResolving:
			return nil
		case .useDefaultVault(let defaultVaultURL):
			return defaultVaultURL
		case .resolved(let resolvedURL):
			return resolvedURL
		}
	}
}
