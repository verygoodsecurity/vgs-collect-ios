//
//  UITextField+Extensions.swift
//  demoapp
//
//  Created by Dmytro on 13.02.2024.
//  Copyright © 2024 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class TextField: UITextField {

    var padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
