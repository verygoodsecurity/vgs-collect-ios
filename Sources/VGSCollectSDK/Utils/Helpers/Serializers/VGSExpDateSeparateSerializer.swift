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
  public let monthFieldName: String
  public let yearFieldName: String
  
  public init(monthFieldName: String, yearFieldName: String) {
    self.monthFieldName = monthFieldName
    self.yearFieldName = yearFieldName
  }
}
