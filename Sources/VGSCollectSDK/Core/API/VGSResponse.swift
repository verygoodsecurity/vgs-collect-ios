//
//  VGSResponse.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Response enum cases for SDK requests.
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

/// Session initialization response enum cases.
@frozen public enum VGSCollectSessionResponse {
    /**
     Success response case.

     - Parameter collector: fully initialized `VGSCollect` instance.
    */
    case success(_ collector: VGSCollect)

    /**
     Terminal session validation failure.

     - Parameters:
        - code: SDK error code.
        - data: optional response data when available.
        - response: optional URL response when available.
        - error: underlying validation error.
    */
    case failure(_ code: Int, _ data: Data?, _ response: URLResponse?, _ error: Error?)
}

/// Card attributes lookup response enum cases.
@frozen public enum VGSCardAttributesLookupResponse {
    /**
     Success response case.

     - Parameters:
        - code: response status code.
        - data: response data object.
        - response: URL response object.
    */
    case success(_ code: Int, _ data: Data?, _ response: URLResponse?)

    /**
     Failed response case.

     - Parameters:
        - code: response or SDK error code.
        - data: backend response body for non-2xx HTTP failures.
        - response: backend URL response for non-2xx HTTP failures.
        - error: underlying error for SDK-side or transport failures, otherwise `nil` for backend HTTP failures.
    */
    case failure(_ code: Int, _ data: Data?, _ response: URLResponse?, _ error: Error?)
}

/// Tokenization response enum cases for SDK requests.
@frozen public enum VGSTokenizationResponse: @unchecked Sendable {
    /**
     Success response case

     - Parameters:
        - code: response status code.
        - body: response **JsonData** object.
        - response: URLResponse object represents a URL load response.
    */
  case success(_ code: Int, _ body: JsonData?, _ response: URLResponse?)

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
