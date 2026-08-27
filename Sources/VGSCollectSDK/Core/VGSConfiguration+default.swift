//
//  VGSConfiguration+extension.swift
//  VGSCollectSDK
//

@MainActor
public extension VGSConfiguration {
  
  /// Creates a prebuilt configuration for a **card number** field used in CMP create card requests.
  ///
  /// The configuration:
  /// - Uses field name `"pan"`.
  /// - Sets `type = .cardNumber`.
  /// - Marks the field as required and required-valid-only.
  ///
  /// - Parameter collector: The `VGSCollect` instance that will register the field.
  /// - Returns: A fully configured `VGSConfiguration` ready to assign to `VGSCardTextField`/`VGSTextField`.
  static func makeCardNumberConfiguration(collector: VGSCollect) -> VGSConfiguration {
    let configuration = VGSConfiguration(collector: collector, fieldName: "pan")
    configuration.type = .cardNumber
    configuration.isRequired = true
    configuration.isRequiredValidOnly = true
    return configuration
  }
  
  /// Creates a prebuilt configuration for a **cardholder name** field used in CMP create card requests.
  ///
  /// The configuration:
  /// - Uses field name `"cardholder"`.
  /// - Sets `type = .cardHolderName`.
  ///
  /// - Parameter collector: The `VGSCollect` instance that will register the field.
  /// - Returns: A fully configured `VGSConfiguration` ready to assign to a `VGSTextField`.
  static func makeCardholderConfiguration(collector: VGSCollect) -> VGSConfiguration {
    let configuration = VGSConfiguration(collector: collector, fieldName: "cardholder")
    configuration.type = .cardHolderName
    return configuration
  }
  
  /// Creates a prebuilt configuration for an **expiration date** field used in CMP create card requests.
  ///
  /// The configuration:
  /// - Uses field name `"exp_date"`.
  /// - Sets `type = .expDate`.
  /// - Marks the field as required and required-valid-only.
  /// - Adds a serializer that outputs **separate** month/year fields:
  ///   - `exp_month`
  ///   - `exp_year`
  ///
  /// - Parameter collector: The `VGSCollect` instance that will register the field.
  /// - Returns: A fully configured `VGSExpDateConfiguration` ready to assign to a `VGSTextField`.
  static func makeExpDateConfiguration(collector: VGSCollect) -> VGSExpDateConfiguration {
    let configuration = VGSExpDateConfiguration(collector: collector, fieldName: "exp_date")
    configuration.type = .expDate
    configuration.isRequired = true
    configuration.isRequiredValidOnly = true
    configuration.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "exp_month", yearFieldName: "exp_year")]
    return configuration
  }
  
  /// Creates a prebuilt configuration for a **CVC** field used in CMP create card requests.
  ///
  /// The configuration:
  /// - Uses field name `"cvc"`.
  /// - Sets `type = .cvc`.
  /// - Marks the field as required and required-valid-only.
  ///
  /// - Parameter collector: The `VGSCollect` instance that will register the field.
  /// - Returns: A fully configured `VGSConfiguration` ready to assign to a `VGSTextField`.
  static func makeCVCConfiguration(collector: VGSCollect) -> VGSConfiguration {
    let configuration = VGSConfiguration(collector: collector, fieldName: "cvc")
    configuration.type = .cvc
    configuration.isRequired = true
    configuration.isRequiredValidOnly = true
    return configuration
  }
}
