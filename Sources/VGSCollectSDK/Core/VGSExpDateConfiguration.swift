//
//  VGSExpDateConfiguration.swift
//  VGSCollectSDK
//
//  Created by Dima on 22.01.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// A class responsible for configuration `VGSTextField` with `fieldType = .expDate`. Extends `VGSConfogiration` class.
public final class VGSExpDateConfiguration: VGSConfiguration {
       
  /// Input date format to convert.
  public var inputDateFormat: String?
  
  /// Output date format.
  public var outputDateFormat: String?

}

/// Implement `FormatConvertable` protocol.
extension VGSExpDateConfiguration: FormatConvertable {
  internal var outputFormat: String? {
    return outputDateFormat
  }

  internal var inputFormat: String? {
    return inputDateFormat
  }
  
  internal var convertor: TextFormatConvertor {
    return ExpDateFormatConvertor()
  }
}
