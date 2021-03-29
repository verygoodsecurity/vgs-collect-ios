//
//  VGSExpDateSeparateSerializer.swift
//  VGSCollectSDK
//
//  Created by Dima on 25.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Expiration Date Separate serializer, split date string to components with separate fieldNames
public struct VGSExpDateSeparateSerializer: VGSFormatSerializerProtocol {
  
  /// Field Name that will be used as a JSON key with month value from expDate string on send request.
  public let monthFieldName: String
  
  /// Field Name that will be used as a JSON key with year value from expDate string on send request.
  public let yearFieldName: String
  
  // MARK: - Initialization
  
  /// Initialization
  ///
  /// - Parameters:
  ///   - monthFieldName: key, that should be associated with month value in request JSON.
  ///   - yearFieldName: key, that should be associated with year value in request JSON.
  public init(monthFieldName: String, yearFieldName: String) {
    self.monthFieldName = monthFieldName
    self.yearFieldName = yearFieldName
  }
}
