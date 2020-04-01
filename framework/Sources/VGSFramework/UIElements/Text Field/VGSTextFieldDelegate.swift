//
//  VGSTextFieldDelegate.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 22.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

@objc
public protocol VGSTextFieldDelegate {
    /// VGSTextField did become first responder
    @objc optional func vgsTextFieldDidBeginEditing(_ textfield: VGSTextField)
    /// VGSTextField did resign first responder
    @objc optional func vgsTextFieldDidEndEditing(_ textfield: VGSTextField)
    /// VGSTextField did resign first responder on Return button pressed
    @objc optional func vgsTextFieldDidEndEditingOnReturn(_ textfield: VGSTextField)
}
