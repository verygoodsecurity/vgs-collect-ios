//
//  VGSCMPBaseConfiguration.swift
//  VGSCollectSDK
//

public enum VGSCardManagementFieldType {
  case cardNumber
  case expDate
  case cvc
}

internal extension VGSCardManagementFieldType {
  
  var collectFieldType: FieldType {
    switch self {
    case .cardNumber:
      return .cardNumber
    case .expDate:
      return .cvc
    case .cvc:
      return .cvc
    }
  }
}

internal extension VGSCardManagementFieldType {
  
  var fieldName: String {
    switch self {
    case .cardNumber:
      return "pan"
    case .expDate:
      return "expiry"
    case .cvc:
      return "cvc"
    }
  }
}

public class VGSCMPBaseConfiguration: VGSTextFieldConfigurationProtocol {
  
  internal var validationRules: VGSValidationRuleSet?
  
  internal var isRequired: Bool = true
  
  internal var isRequiredValidOnly: Bool = true
  
  internal var type: FieldType
  
  internal var formatPattern: String?
  
  public var keyboardType: UIKeyboardType?
  
  public var returnKeyType: UIReturnKeyType?
  
  public var keyboardAppearance: UIKeyboardAppearance?
  
  internal var fieldName: String
  
  public private(set) weak var cardManager: VGSCardManager?
  
  internal weak var vgsCollector: VGSCollect?{
    return cardManager?.collector
  }

  //  internal let configuration: VGSConfiguration
  
  required public init(manager: VGSCardManager, type: VGSCardManagementFieldType) {
    self.type = type.collectFieldType
    self.fieldName = "pan"
    self.cardManager = manager
  }
}


