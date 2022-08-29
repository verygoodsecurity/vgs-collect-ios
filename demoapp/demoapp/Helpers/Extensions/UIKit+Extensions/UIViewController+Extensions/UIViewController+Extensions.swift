//
//  UIViewController+Extensions.swift
//  demoapp
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// no:doc
internal extension UIViewController {

	/// Loader overlay container view.
	private var overlayContainerView: UIView {
		if let navigationView: UIView = navigationController?.view {
			return navigationView
		}
		return view
	}

	/// Displays loader in view controller.
	func displayLoader() {
		overlayContainerView.displayAnimatedActivityIndicatorView()
	}

	/// Hides loader in view controller.
	func hideLoader() {
		overlayContainerView.hideAnimatedActivityIndicatorView()
	}
}
