//
//  Extension.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 9/2/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import VGSFramework

extension VGSTextField {
    func setGreenBorder(_ flag: Bool) {
        layer.borderColor = flag ? UIColor.myGreen.cgColor : UIColor.lightGray.cgColor
    }
    
    func setBorderBolder(_ flag: Bool) {
        layer.borderWidth = flag ? 2 : 1
    }
}

extension UIColor {
    @nonobjc class var myGreen: UIColor {
        return UIColor(red: 0.235, green: 0.698, blue: 0.498, alpha: 1.00)
    }
}
