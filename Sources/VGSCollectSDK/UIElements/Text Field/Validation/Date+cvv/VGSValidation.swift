//
//  VGSValidation.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public protocol VGSValidationModelProtocol {
  
  var regex: String{ get set }
  func validate(_ text: String) -> [VGSError]
  
}

public protocol VGSValidationProtocol {
  
}

public class VGSBaseValidation: VGSValidationModelProtocol {
  
  public var regex: String = ""
  
  public init() {}
  
  public func validate(_ text: String) -> [VGSError] {
    var errors = [VGSError]()
    if text.matches(for: regex).count == 0 {
      errors.append(VGSError(type: .inputDataIsNotValid, userInfo: nil))
    }
    return errors
  }
}



public class VGSDateValidation: VGSValidationModelProtocol {

  public var regex: String = FieldType.expDate.regex
  var minDate = ""
  var maxDate = ""
  
  ///TODO: Change to enum
  var isLongDateFormat = false

  public init() {}
  
  public func validate(_ txt: String) -> [VGSError] {
    
    let mmChars = 2
    let yyChars = self.isLongDateFormat ? 4 : 2
    if txt.count != mmChars + yyChars  {
      return [VGSError(type: .inputDataIsNotValid)]
    }
            
    let mm = txt.prefix(mmChars)
    let yy = txt.suffix(yyChars)
            
    let today = Date()
    let formatter = DateFormatter()
    
    formatter.dateFormat = self.isLongDateFormat ? "yyyy" : "yy"
    let todayYY = Int(formatter.string(from: today)) ?? 0
    
    formatter.dateFormat = "MM"
    let todayMM = Int(formatter.string(from: today)) ?? 0
    
    guard let inputMM = Int(mm), let inputYY = Int(yy) else {
      return [VGSError(type: .inputDataIsNotValid)]
    }
    
    if inputYY < todayYY || inputYY > (todayYY + 20) {
        return [VGSError(type: .inputDataIsNotValid)]
    }
    
    if inputYY == todayYY && inputMM < todayMM {
      return [VGSError(type: .inputDataIsNotValid)]
    }
    return [VGSError]()
  }
}

public class VGSCardNumberValidation: VGSValidationProtocol  {
  public var regex: String = ""

  public var isLengthValidationOn: Bool = true
  public var isBrandValidationOn: Bool = true
  public var isAlgorithmValidationOn: Bool = true
  
  public init() {}
  
}
 
extension VGSCardNumberValidation: VGSValidationModelProtocol {
  
  
  public func validate(_ cardNumber: String) -> [VGSError] {
    
    var errors = [VGSError]()
    let cardType =  SwiftLuhn.getCardType(from: cardNumber)
    
    /// check supported card brand
    if isBrandValidationOn {
      if cardType == .unknown {
        errors.append(VGSError.init(type: .inputDataIsNotValid))
      }
    }
    
    /// check if card number length is valid for specific brand
    if isLengthValidationOn {
      if !cardType.cardLengths.contains(cardNumber.count) {
          errors.append(VGSError.init(type: .inputDataIsNotValid))
      }
    }
    
    /// perform Luhn Algorithm check
    if isAlgorithmValidationOn {
      if !SwiftLuhn.performLuhnAlgorithm(with: cardNumber) {
        errors.append(VGSError.init(type: .inputDataIsNotValid))
      }
    }
    return errors
  }
}

internal class VGSValidation {
    var regex: String = ""
    var isLongDateFormat = false
    
    func isValid(_ txt: String, type: FieldType) -> Bool {
        if type == .none { return true }

        guard txt.count != 0, regex.count != 0 else {
            return false
        }
        let resultRegEx = txt.matches(for: regex).count > 0
        let resultType = validateType(txt: txt, for: type)

        return resultRegEx && resultType
    }
}

extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
