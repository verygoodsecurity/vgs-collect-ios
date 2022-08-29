//
//  UITableView+Extensions.swift
//  demoapp
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// swiftlint:disable all

internal extension UITableView {
		func dequeue<T: UITableViewCell>(cellForRowAt indexPath: IndexPath) -> T {
			return dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as! T
		}
}

// swiftlint:enable all
