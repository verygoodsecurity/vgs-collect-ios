//
//  MaskedTextField+security.swift
//
//  Created by Vitalii Obertynskyi on 06.11.2019.
//

import Foundation
#if os(iOS)
import UIKit
#endif

extension MaskedTextField {

	  /// :nodoc: Disable custom target-action outside `VGSCollectSDK`.
    override public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {}

	  /// :nodoc: Replace native textfield delgate with custom.
    override public var delegate: UITextFieldDelegate? {
        get { return nil }
        set {}
    }
    
    func addSomeTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
    }
}
