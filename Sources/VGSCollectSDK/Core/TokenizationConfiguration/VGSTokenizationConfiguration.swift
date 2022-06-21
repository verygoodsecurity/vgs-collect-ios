//
//  VGSTokenizationConfiguration.swift
//  VGSCollectSDK
//
//  Created by Dmytro on 15.06.2022.
//  Copyright © 2022 VGS. All rights reserved.
//

import Foundation

/// `VGSTokenizationParameters` - parameters required for tokenization api.
public struct VGSTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public var storage: String = VGSVaultStorageType.PERSISTANT.rawValue
    
    /// Data alies format.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// `VGSTokenizationConfiguration` - textfield configuration for textfield with any type of data, required for work with tokenization api.
public class VGSTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationPatameters = VGSTokenizationParameters()

  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationPatameters
  }
}
