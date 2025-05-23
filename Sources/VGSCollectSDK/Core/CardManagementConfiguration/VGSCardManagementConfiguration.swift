//
//  VGSCardManagementConfiguration.swift
//  VGSCollectSDK
//

import Foundation

public class VGSCardManagementConfiguration: VGSConfiguration, VGSFormatSerializableProtocol {
  
  public let manager: VGSCardManager

  public let fieldType: VGSCardManagementFieldType

  internal var serializers = [VGSFormatSerializerProtocol]()
  /// Serialize Expiration Date
  internal func serialize(_ content: String) -> [String: Any] {
    return ExpDateFormatConvertor.serialize(content, serializers: serializers, outputFormat: .shortYear)
  }

  /// Returns if Content should be Serialized
  internal var shouldSerialize: Bool {
    return !serializers.isEmpty
  }
  
  required public init(manager: VGSCardManager, fieldType: VGSCardManagementFieldType) {
    self.manager = manager
    self.fieldType = fieldType
    super.init(collector: manager.collector, fieldName: fieldType.fieldName)
    self.isRequired = true
    self.isRequiredValidOnly = true
    self.type = fieldType.collectFieldType
    if fieldType == .expDate {
      self.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "exp_month", yearFieldName: "exp_year")]
    }
  }
}
