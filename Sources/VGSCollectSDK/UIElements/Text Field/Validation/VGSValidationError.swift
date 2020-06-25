//
//  VGSValidationError.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSValidationError {
  let errorMessage: String
  
  public init(errorMessage: String) {
    self.errorMessage = errorMessage
  }
}
