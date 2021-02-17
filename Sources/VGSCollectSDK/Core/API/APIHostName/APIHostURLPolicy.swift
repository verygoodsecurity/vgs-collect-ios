//
//  APIHostURLPolicy.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Defines API flows.
internal enum APIHostURLPolicy {

	/**
	 Use vault url, custom hostname not set.

	 - Parameters:
			- url: `URL` object, default vault URL.
	*/
	case vaultURL(_ vaultURL: URL)

	/**
	 Custom host URL.

	 - Parameters:
			- status: `CustomHostStatus` object, hostname status.
	*/
	case customHostURL(_ status: APICustomHostStatus)

	/**
	 Invalid vault URL, API client has incorrect configuration and cannot send request.
	*/
	case invalidVaultURL

	/**
	 Use satellite url for local testing.

	 - Parameters:
			- url: `URL` object, should be valid satellite URL for local testing.
	*/
	case satelliteURL(_ satelliteURL: URL)

	var url: URL? {
		switch self {
		case .invalidVaultURL:
			return nil
		case .vaultURL(let vaultURL):
			return vaultURL
		case .customHostURL(let hostStatus):
			return hostStatus.url
		case .satelliteURL(let satelliteURL):
			return satelliteURL
		}
	}
}
