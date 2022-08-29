//
//  VGSSavedCardCellActionView.swift
//  demoapp
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// A set of methods to notify about changes in saved card option action view.
internal protocol VGSSavedCardOptionActionViewDelegate: AnyObject {

	/// Tells the delegate that remove card button was tapped.
	/// - Parameter view: `VGSSavedCardCellActionView` object, action view object.
	func removeCardDidTapInView(in view: VGSSavedCardCellActionView)
}

/// Holds UI for saved card accessory options view.
internal class VGSSavedCardCellActionView: UIView {

	/// Defines state for view.
	enum ActionViewState {

		/// Hidden.
		case hidden

		/// Selection, display checkbox in selected/unselected state.
		/// - Parameters:
		///	 - isSelected: `Bool` object, indicates selection result.
		case selected(_ isSelected: Bool)

		/// Remove card, display remove card icon.
		case remove
	}

	// MARK: - Constants

	/// Remove icon size.
	private let removeCardIconSize: CGSize = CGSize(width: 20, height: 20)

	/// Remove card icon image.
	private let removeCardImage = UIImage(named: "saved_card_remove_card_icon", in: Bundle.main, compatibleWith: nil)

	// MARK: - Vars

	internal weak var delegate: VGSSavedCardOptionActionViewDelegate?

	/// Checkbox.
	private let checkbox: VGSRoundedCheckbox

	/// Remove card button.
	lazy var removeCardButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(removeCardImage, for: .normal)
		button.imageView?.contentMode = .scaleAspectFit

		return button
	}()

	/// View current state. Default is `hidden`.
	internal var actionViewState: ActionViewState = .hidden {
		didSet {
			updateUI()
		}
	}

	// MARK: - Initializer

	/// Initializer.
	/// - Parameter uiTheme: `VGSCheckoutThemeProtocol` object, ui theme.
	init() {
		let checkboxTheme = VGSRoundedCheckbox.generateCheckboxThemeForSavedCard()
		self.checkbox = VGSRoundedCheckbox(theme: checkboxTheme)
		super.init(frame: .zero)
		setupUI()
	}

	/// no:doc
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Interface

	// MARK: - Helpers

	/// Setups UI.
	private func setupUI() {
		setupCheckboxUI()
		setupRemoveButtonUI()
	}

	/// Setups checkbox UI.
	private func setupCheckboxUI() {
		addSubview(checkbox)
		checkbox.translatesAutoresizingMaskIntoConstraints = false
		checkbox.demoapp_constraintViewToSuperviewCenter()
	}

	/// Setups remove button UI.
	private func setupRemoveButtonUI() {
		addSubview(removeCardButton)
		removeCardButton.demoapp_constraintViewToSuperviewEdges()
		removeCardButton.addTarget(self, action: #selector(removeCardButtonDidTap), for: .touchUpInside)
	}

	/// Updates UI with current state.
	private func updateUI() {
		switch actionViewState {
		case .hidden:
			checkbox.isHidden = true
			removeCardButton.isHidden = true
		case .selected(let isSelected):
			checkbox.isHidden = false
			removeCardButton.isHidden = true
			checkbox.isSelected = isSelected
		case .remove:
			checkbox.isHidden = true
			removeCardButton.isHidden = false
		}
	}

	// MARK: - Actions

	/// Handles tap on remove card button.
	@objc private func removeCardButtonDidTap() {
		delegate?.removeCardDidTapInView(in: self)
	}
}
