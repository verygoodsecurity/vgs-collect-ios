//
//  MaskedTextField+security.swift
//  Alamofire
//
//  Created by Vitalii Obertynskyi on 06.11.2019.
//

import Foundation
import UIKit

extension MaskedTextField {
    override open func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {}
    
    override open var delegate: UITextFieldDelegate? {
        get {
            return nil
        }
        set {}
    }
    
    func addSomeTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
    }
}
