//
//  VGSConfiguration+extension.swift
//  VGSCollectSDK
//

public extension VGSConfiguration {
  
  static func makeCardNumberConfiguration(collector: VGSCollect) -> VGSConfiguration {
    let configuration = VGSConfiguration(collector: collector, fieldName: "pan")
    configuration.type = .cardNumber
    configuration.isRequired = true
    configuration.isRequiredValidOnly = true
    return configuration
  }
  
  static func makeCardholderConfiguration(collector: VGSCollect) -> VGSConfiguration {
    let configuration = VGSConfiguration(collector: collector, fieldName: "cardholder")
    configuration.type = .cardHolderName
    return configuration
  }
  
  static func makeExpDateConfiguration(collector: VGSCollect) -> VGSExpDateConfiguration {
    let configuration = VGSExpDateConfiguration(collector: collector, fieldName: "exp_date")
    configuration.type = .expDate
    configuration.isRequired = true
    configuration.isRequiredValidOnly = true
    configuration.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "exp_month", yearFieldName: "exp_year")]
    return configuration
  }
  
  static func makeCVCConfiguration(collector: VGSCollect) -> VGSConfiguration {
    let configuration = VGSConfiguration(collector: collector, fieldName: "cvc")
    configuration.type = .cvc
    configuration.isRequired = true
    configuration.isRequiredValidOnly = true
    return configuration
  }
}
