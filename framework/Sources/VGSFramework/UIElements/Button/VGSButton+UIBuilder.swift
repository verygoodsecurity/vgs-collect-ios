//
//  VGSButton+UIBuilder.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 27.10.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public extension VGSButton {
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
            return button.titleLabel?.font
        }
        set {
            button.titleLabel?.font = newValue
        }
    }
    @IBInspectable var textColor: UIColor? {
        get {
            return button.titleLabel?.textColor
        }
        set {
            button.titleLabel?.textColor = newValue
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.cornerRadius = cornerRadius
    }
}
