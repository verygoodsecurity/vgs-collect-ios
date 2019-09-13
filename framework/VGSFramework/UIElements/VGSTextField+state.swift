//
//  VGSTextField+state.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation


public extension VGSTextField {
    var isEmpty: Bool {
        return (text?.count == 0)
    }
    
    var isValid: Bool {
        let str = textField.text ?? ""
        return validationModel.isValid(str, type: configuration?.type)
    }
    
    var isRequared: Bool {
        return configuration?.isRequired ?? false
    }
    
    override var isFocused: Bool {
        return focusStatus
    }
}
