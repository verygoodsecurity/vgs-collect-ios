//
//  VGSTextFieldDelegate.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 22.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

/// Delegates produced by `VGSTextField` instance.
@objc
public protocol VGSTextFieldDelegate {
    
    // MARK: - Handle user ineraction with VGSTextField
    
    /// `VGSTextField` did become first responder.
    @objc optional func vgsTextFieldDidBeginEditing(_ textField: VGSTextField)
    
    /// `VGSTextField` did resign first responder.
    @objc optional func vgsTextFieldDidEndEditing(_ textField: VGSTextField)
    
    /// `VGSTextField` did resign first responder on Return button pressed.
    @objc optional func vgsTextFieldDidEndEditingOnReturn(_ textField: VGSTextField)
    
    /// `VGSTextField` input changed.
    @objc optional func vgsTextFieldDidChange(_ textField: VGSTextField)
}
