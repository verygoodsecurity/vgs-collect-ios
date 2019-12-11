//
//  VGSTextField+UIBuilder.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/28/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import UIKit

public extension VGSTextField {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgcolor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgcolor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    var font: UIFont? {
        get {
            return textField.font
        }
        set {
            textField.font = newValue
        }
    }
    @IBInspectable var textColor: UIColor? {
        get {
            return textField.textColor
        }
        set {
            textField.textColor = newValue
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.cornerRadius = cornerRadius
    }
}
