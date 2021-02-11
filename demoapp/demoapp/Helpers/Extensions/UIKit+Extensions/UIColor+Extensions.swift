//
//  UIColor+Extensions.swift
//  demoapp
//
//  Created by Eugene on 05.02.2021.
//  Copyright © 2021 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	static var inputBlackTextColor: UIColor {
		if #available(iOS 13.0, *) {
			return UIColor {(traits) -> UIColor in
				return traits.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
			}
		} else {
			return .black
		}
	}
}
