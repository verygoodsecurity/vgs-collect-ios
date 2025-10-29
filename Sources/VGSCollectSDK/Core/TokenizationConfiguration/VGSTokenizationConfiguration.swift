//
//  VGSTokenizationConfiguration.swift
//  VGSCollectSDK
//
//  Created by Dmytro on 15.06.2022.
//  Copyright © 2022 VGS. All rights reserved.
//

import Foundation

/// `VGSTokenizationParameters` - parameters required for tokenization API.
///
/// Summary:
/// Defines generic tokenization settings for fields that do not have a specialized tokenization configuration (e.g. custom text, card holder name, miscellaneous identifiers).
///
/// Properties:
/// - `storage`: Vault storage type. Defaults to `.PERSISTENT` enabling server-side reuse. Switch to `.VOLATILE` only if value must not persist (e.g. ephemeral session identifiers).
/// - `format`: Alias format. Default `.UUID` produces an opaque, non-reversible alias appropriate for most free-form text values.
///
/// Usage:
/// ```swift
/// var genericParams = VGSTokenizationParameters()
/// genericParams.format = VGSVaultAliasFormat.UUID.rawValue // or another supported format
/// let holderCfg = VGSTokenizationConfiguration(collector: collector, fieldName: "card_holder")
/// holderCfg.tokenizationParameters = genericParams
/// nameField.configuration = holderCfg
/// ```
///
/// Notes:
/// - Changing `format` affects alias representation only, not validation or field UI formatting.
/// - Prefer specialized configurations (e.g. `VGSCardNumberTokenizationConfiguration`) for field types with domain-specific alias requirements.
public struct VGSTokenizationParameters: VGSTokenizationParametersProtocol {

    /// Vault storage type.
    public var storage: String = VGSVaultStorageType.PERSISTENT.rawValue
    
    /// Data alias format.
    /// Default `.UUID` produces opaque, non-reversible alias suitable for most generic text values.
    public var format: String = VGSVaultAliasFormat.UUID.rawValue
}

/// `VGSTokenizationConfiguration` - textfield configuration for a text field with any supported `FieldType`, enabling tokenization when no specialized configuration exists.
///
/// Summary:
/// Generic catch-all tokenization configuration. Use for field types like `.cardHolderName`, `.none`, or custom data keys where dedicated tokenization subclasses are not provided.
///
/// Behavior:
/// - Inherits all formatting, validation, and requirement handling from `VGSConfiguration`.
/// - Adds `tokenizationParameters` consumed by Vault tokenization / alias creation APIs (`tokenizeData`, `createAliases`).
///
/// Usage:
/// ```swift
/// let nameCfg = VGSTokenizationConfiguration(collector: collector, fieldName: "card_holder")
/// nameCfg.type = .cardHolderName
/// nameCfg.tokenizationParameters.format = VGSVaultAliasFormat.UUID.rawValue
/// nameField.configuration = nameCfg
/// // Later:
/// collector.createAliases { response in /* handle alias mapping */ }
/// ```
///
/// Customization Notes:
/// - Set `type` and any `validationRules` before tokenization to ensure correct evaluation.
/// - For highly sensitive transient values consider switching `storage` to `.VOLATILE` (alias may not be reusable long-term).
/// - Use a deterministic alias format only if your backend requires stable pattern characteristics.
///
/// Security:
/// - Never log raw input pre-tokenization.
public class VGSTokenizationConfiguration: VGSConfiguration, VGSTextFieldTokenizationConfigurationProtocol {
  
  /// `VGSTokenizationParameters` - tokenization configuration parameters.
  public var tokenizationParameters = VGSTokenizationParameters()

  internal var tokenizationConfiguration: VGSTokenizationParametersProtocol {
    return tokenizationParameters
  }
}
