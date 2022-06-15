//
//  VGSTextFieldTokenizationProtocol.swift
//  VGSCollectSDK
//
//  Created by Dmytro on 14.06.2022.
//  Copyright © 2022 VGS. All rights reserved.
//

import Foundation


public enum VGSVaultStorageType: String {
  case PERSISTANT = "PERSISTANT"
  case VALOTILE = "VALOTILE"
}

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

public protocol VGSTokenizationParametersProtocol {
  /// Tokenization format
  var format: String { get }
  /// Storage type
  var storage: String  { get }
  /// Data classifiers
  var classifiers: [String] { get }
  /// Set if data should be tokenized. If `false` raw value will be stored in Vault
  var shouldTokenize: Bool { get }
}

internal extension VGSTokenizationParametersProtocol {
  func mapToJSON() -> [String: Any] {
    return [
      "storage": storage,
      "format": format,
      "classifiers": classifiers,
      "tokenization": shouldTokenize
    ]
  }
}
