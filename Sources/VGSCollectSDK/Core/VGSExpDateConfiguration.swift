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

/// Attributes required to configure date format and input source for field with type  `.expDate`.
public protocol VGSExpDateConfigurationProtocol {
  
  /// Input Source type.
  var inputSource: VGSTextFieldInputSource {get set}
  
  /// Input date format to convert.
  var inputDateFormat: VGSCardExpDateFormat? {get set}
  
  /// Output date format.
  var outputDateFormat: VGSCardExpDateFormat? {get set}
}

/// A class responsible for configuration `VGSTextField` with `fieldType = .expDate`. Extends `VGSConfiguration` class.
public final class VGSExpDateConfiguration: VGSConfiguration, VGSExpDateConfigurationProtocol, VGSFormatSerializableProtocol {
   
  // MARK: - Attributes
  /// `FieldType.expDate` type of `VGSTextField` configuration.
  override public var type: FieldType {
    get { return .expDate }
    set {}
  }
  
  // MARK: - VGSExpDateConfigurationProtocol
  /// Input Source type. Default is `VGSTextFieldInputSource.datePicker`.
  public var inputSource: VGSTextFieldInputSource = .datePicker
  
  /// Input date format to convert.
  public var inputDateFormat: VGSCardExpDateFormat?
  
  /// Output date format.
  public var outputDateFormat: VGSCardExpDateFormat?
  
  // MARK: - VGSFormatSerializableProtocol
  /// Output date format.
  public var serializers: [VGSFormatSerializerProtocol] = []
  
  // MARK: - `VGSExpDateConfiguration` implementation
  /// Serialize Expiration Date
  internal func serialize(_ content: String) -> [String: Any] {
    return ExpDateFormatConvertor.serialize(content, serializers: serializers, outputFormat: outputFormat)
  }
  
  /// Returns if Content should be Serialized
  internal var shouldSerialize: Bool {
    return !serializers.isEmpty
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
