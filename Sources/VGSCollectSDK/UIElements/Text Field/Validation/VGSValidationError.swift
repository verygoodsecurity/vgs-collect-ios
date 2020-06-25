//
//  VGSValidationError.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public typealias VGSValidationError = String

public enum VGSValidationErrorType: String {
  case pattern = "PATTERN_VALIDATION_ERROR"
  case length = "LENGTH_VALIDATION_ERROR"
  case expDate = "EXPIRATION_DATE_VALIDATION_ERROR"
  case cardNumber = "CARD_NUMBER_VALIDATION_ERROR"
}
