//
//  VGSValidation.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public protocol VGSValidationModelProtocol {
  
  
}

public class VGSBaseValidation: VGSValidationModelProtocol {
  
  public var regex: String = ""
  
  public init() {}
}

public class VGSDateValidation: VGSValidationModelProtocol {
  
  public var regex: String = FieldType.expDate.regex
  var minDate = ""
  var maxDate = ""
  
  ///TODO: Change to enum
  var isLongDateFormat = false

  public init() {}
}

public class VGSCardNumberValidation: VGSValidationModelProtocol  {
  public var isLengthValidationOn: Bool = true
  public var isBrandValidationOn: Bool = true
  public var isAlgorithmValidationOn: Bool = true
}

internal class VGSValidation {
  
  class func validate(value: String, validationModel: VGSValidationModelProtocol) -> [VGSError] {
    if let validationModel = validationModel as? VGSBaseValidation {
      return Self.validate(value: value, validationModel: validationModel)
    }
    else if let validationModel = validationModel as? VGSCardNumberValidation {
      return Self.validate(value: value, validationModel: validationModel)
    }
    else if let validationModel = validationModel as? VGSDateValidation {
      return Self.validate(value: value, validationModel: validationModel)
    }
    print("ERROR: VGSValidation.validate function doesn't support \(validationModel)")
    return [VGSError]()
  }
  
  class func validate(value: String, validationModel: VGSCardNumberValidation) -> [VGSError] {
      
      var errors = [VGSError]()
      let cardType =  SwiftLuhn.getCardType(from: value)
      
      /// check supported card brand
    if validationModel.isBrandValidationOn {
        if cardType == .unknown {
          errors.append(VGSError.init(type: .inputDataIsNotValid))
        }
      }
      
      /// check if card number length is valid for specific brand
    if validationModel.isLengthValidationOn {
        if !cardType.cardLengths.contains(value.count) {
            errors.append(VGSError.init(type: .inputDataIsNotValid))
        }
      }
      
      /// perform Luhn Algorithm check
    if validationModel.isAlgorithmValidationOn {
        if !SwiftLuhn.performLuhnAlgorithm(with: value) {
          errors.append(VGSError.init(type: .inputDataIsNotValid))
        }
      }
      return errors
    }
  
    class func validate(value: String, validationModel: VGSBaseValidation) -> [VGSError] {
      if value.matches(for: validationModel.regex).count > 0 {
        return [VGSError]()
      }
      return [VGSError.init(type: .inputDataIsNotValid)]
    }
  
    class func validate(value: String, validationModel: VGSDateValidation) -> [VGSError] {

      guard value.matches(for: validationModel.regex).count > 0 else {
        return [VGSError.init(type: .inputDataIsNotValid)]
      }
      let mmChars = 2
      let yyChars = validationModel.isLongDateFormat ? 4 : 2
      guard value.count == mmChars + yyChars else {
        return [VGSError.init(type: .inputDataIsNotValid)]
      }

      let mm = value.prefix(mmChars)
      let yy = value.suffix(yyChars)

      let today = Date()
      let formatter = DateFormatter()

      formatter.dateFormat = validationModel.isLongDateFormat ? "yyyy" : "yy"
      let todayYY = Int(formatter.string(from: today)) ?? 0

      formatter.dateFormat = "MM"
      let todayMM = Int(formatter.string(from: today)) ?? 0

      guard let inputMM = Int(mm), let inputYY = Int(yy) else {
          return [VGSError.init(type: .inputDataIsNotValid)]
      }

      if inputYY < todayYY || inputYY > (todayYY + 20) {
          return [VGSError.init(type: .inputDataIsNotValid)]
      }

      if inputYY == todayYY && inputMM < todayMM {
          return [VGSError.init(type: .inputDataIsNotValid)]
      }
      return [VGSError]()
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
