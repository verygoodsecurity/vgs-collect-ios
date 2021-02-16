//
//  VGSResponse.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Response enum cases for SDK requests
@frozen public enum VGSResponse {
		/**
		 Success response case

		 - Parameters:
				- code: response status code.
				- data: response **data** object.
				- response: URLResponse object represents a URL load response.
		*/
		case success(_ code: Int, _ data: Data?, _ response: URLResponse?)

		/**
		 Failed response case

		 - Parameters:
				- code: response status code.
				- data: response **Data** object.
				- response: `URLResponse` object represents a URL load response.
				- error: `Error` object.
		*/
		case failure(_ code: Int, _ data: Data?, _ response: URLResponse?, _ error: Error?)
}
