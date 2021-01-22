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
  public var inputDateFormat: CardExpDateFormat?
  
  /// Output date format.
  public var outputDateFormat: CardExpDateFormat?

}

/// Implement `FormatConvertable` protocol.
extension VGSExpDateConfiguration: FormatConvertable {
  internal var outputFormat: CardExpDateFormat? {
    return outputDateFormat
  }

  internal var inputFormat: CardExpDateFormat? {
    return inputDateFormat
  }
  
  internal var convertor: TextFormatConvertor {
    return ExpDateFormatConvertor()
  }
}
