//
//  VGSPaymentOptionItemContainerView.swift
//  demoapp
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// Payment option item view.
internal class VGSPaymentOptionItemContainerView: UIView {

	/// Stack view.
	internal lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.spacing = 16
		stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true

		return stackView
	}()

	init() {
		super.init(frame: .zero)
		setupUI()
	}

	/// no:doc
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}

	/// Setup UI.
	private func setupUI() {
		addSubview(stackView)
		stackView.checkout_constraintViewToSuperviewEdges()
	}
}
