//
//  MaskedTextField+security.swift
//
//  Created by Vitalii Obertynskyi on 06.11.2019.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension MaskedTextField {
    override open func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {}
    
    override open var delegate: UITextFieldDelegate? {
        get { return nil }
        set {}
    }
    
    func addSomeTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
    }
}
