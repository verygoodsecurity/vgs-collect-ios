//
//  Validation.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/28/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public extension VGSTextField {
    var isEmpty: Bool {
        return (text?.count == 0)
    }
    
    override var isFocused: Bool {
        return textView.isFirstResponder
    }
}
