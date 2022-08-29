//
//  UITableViewCell+Extensions.swift
//  demoapp
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// swiftlint:disable all

internal extension UITableViewCell {
	static var cellIdentifier: String {
		return "\(self)"
	}
}

// swiftlint:enable all
