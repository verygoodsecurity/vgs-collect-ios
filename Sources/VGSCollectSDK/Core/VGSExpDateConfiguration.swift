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
  public var inputDateFormat: VGSCardExpDateFormat?
  
  /// Output date format.
  public var outputDateFormat: VGSCardExpDateFormat?
  
  /// Output date format.
  public var serializers: [VGSFormatSerializerProtocol] = []
  
  /// `FieldType.expDate` type of `VGSTextField` configuration.
  override public var type: FieldType {
    get { return .expDate }
    set {}
  }
}

/// Implement `FormatConvertable` protocol.
extension VGSExpDateConfiguration: FormatConvertable {
  internal var outputFormat: VGSCardExpDateFormat? {
    return outputDateFormat
  }

  internal var inputFormat: VGSCardExpDateFormat? {
    return inputDateFormat
  }
  
  internal var convertor: TextFormatConvertor {
    return ExpDateFormatConvertor()
  }
}

extension VGSExpDateConfiguration: VGSFormatSerializableProtocol {
  func serialize(_ content: String) -> [String: Any] {
    var result = [String: Any]()
    for serializer in serializers {
      if let serializer = serializer as? VGSExpDateSeparateSerializer {
        let mth = content.prefix(outputFormat?.monthCharacters ?? 2)
        let year = content.suffix(outputFormat?.yearCharacters ?? 2)
        result[serializer.monthFieldName] = mth
        result[serializer.yearFieldName] = year
      }
    }
    return result
  }
  
  /// Returns if Content should be Serialized
  var shouldSerialize: Bool {
    return !serializers.isEmpty
  }
}
