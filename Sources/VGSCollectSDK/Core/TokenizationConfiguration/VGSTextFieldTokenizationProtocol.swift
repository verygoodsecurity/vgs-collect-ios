//
//  VGSTextFieldTokenizationProtocol.swift
//  VGSCollectSDK
//
//  Created by Dmytro on 14.06.2022.
//  Copyright © 2022 VGS. All rights reserved.
//

import Foundation

/// Type of VGS Valut storage.
public enum VGSVaultStorageType: String {
  /// PERSISTANT data storage.
  case PERSISTANT = "PERSISTANT"
  
  /// VOLATILE data storage.
  case VOLATILE = "VOLATILE"
}

/// Type of Alias format. Read more about avaliable formats: https://www.verygoodsecurity.com/docs/terminology/nomenclature#alias-formats .
public enum VGSVaultAliasFormat: String {
  case FPE_ACC_NUM_T_FOUR = "FPE_ACC_NUM_T_FOUR"
  case FPE_ALPHANUMERIC_ACC_NUM_T_FOUR = "FPE_ALPHANUMERIC_ACC_NUM_T_FOUR"
  case FPE_SIX_T_FOUR = "FPE_SIX_T_FOUR"
  case FPE_SSN_T_FOUR = "FPE_SSN_T_FOUR"
  case FPE_T_FOUR = "FPE_T_FOUR"
  case NUM_LENGTH_PRESERVING = "NUM_LENGTH_PRESERVING"
  case PFPT = "PFPT"
  case RAW_UUID = "RAW_UUID"
  case UUID = "UUID"
}

internal protocol VGSTextFieldTokenizationConfigurationProtocol {
  
  var tokenizationConfiguration: VGSTokenizationParametersProtocol { get }
}

/// Parameters describing textfield input tokenization.
public protocol VGSTokenizationParametersProtocol {
  /// Tokenization format
  var format: String { get }
  /// Storage type
  var storage: String  { get }
}

internal extension VGSTokenizationParametersProtocol {
  func mapToJSON() -> [String: Any] {
    return [
      "storage": storage,
      "format": format
    ]
  }
}
