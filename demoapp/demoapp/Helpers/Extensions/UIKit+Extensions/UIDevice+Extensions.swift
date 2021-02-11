//
//  UIDevice+Extensions.swift
//  demoapp
//
//  Copyright © 2021 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {

	/// `true` if current device is sumulator.
	static var isSimulator: Bool {
		#if arch(i386) || arch(x86_64)
		return true
		#else
		return false
		#endif
	}
}
