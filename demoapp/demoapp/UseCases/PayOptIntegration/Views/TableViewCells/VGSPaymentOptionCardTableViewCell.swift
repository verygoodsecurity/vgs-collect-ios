//
//  VGSPaymentOptionCardTableViewCell.swift
//  demoapp

import Foundation
import UIKit

/// A set of methods to notify about changes in `VGSPaymentOptionCardTableViewCell` cell.
internal protocol VGSPaymentOptionCardTableViewCellDelegate: AnyObject {

	/// Tells the delegate that user tappped removed card.
	/// - Parameter savedCardCell: `VGSPaymentOptionCardTableViewCell` object, saved card cell.
	func removeCardDidTap(in savedCardCell: VGSPaymentOptionCardTableViewCell)
}

/// Holds UI for saved card payment option cell.
internal class VGSPaymentOptionCardTableViewCell: UITableViewCell {

	/// Card cell checkbox theme.
	struct CardCellCheckboxTheme: VGSRoundedCheckboxTheme {
		/// The background color of the checkbox for unselected state.
		var unselectedColor: UIColor

		/// The background color of the checkbox for selected state.
		var selectedColor: UIColor

		/// The checkmark tint color in checkbox.
		var checkmarkTintColor: UIColor
	}

	// MARK: - Initialization

	// no:doc
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	/// no:doc
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Vars

	/// Celld delegate.
	internal weak var delegate: VGSPaymentOptionCardTableViewCellDelegate?

	/// Container view.
	internal lazy var itemContainerView: VGSPaymentOptionItemContainerView = {
		let view = VGSPaymentOptionItemContainerView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.stackView.setContentCompressionResistancePriority(.required, for: .vertical)
		view.layer.cornerRadius = 8
		view.layer.masksToBounds = true
		// Decrease right inset so remove card button can have bigger tap zone.
		view.stackView.layoutMargins.right = view.stackView.layoutMargins.right - 4

		return view
	}()

	/// Vertical stack view.
	internal lazy var cardDetailsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 8, right: 0)
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.distribution = .fill
		stackView.spacing = 4

		return stackView
	}()

	/// Card brand image image view.
	fileprivate lazy var cardBrandImageView: UIImageView = {
		let imageView = UIImageView(frame: .zero)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
		imageView.contentMode = .scaleAspectFit

		return imageView
	}()

	/// Card holder label.
	fileprivate lazy var cardHolderLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.adjustsFontSizeToFitWidth = true

		return label
	}()

	/// Card details label.
	fileprivate lazy var cardDetailsLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1

		return label
	}()

	/// Action view.
	fileprivate var saveCardActionView: VGSSavedCardCellActionView?

	// MARK: - Interface

	/// Configures cell with view model and theme.
	/// - Parameters:
	///   - viewModel: `VGSPaymentOptionCardCellViewModel` object, cell view model.
	///   - uiTheme: `VGSCheckoutThemeProtocol` object, ui theme.
	internal func configure(with viewModel: VGSPaymentOptionCardCellViewModel, uiTheme: VGSCheckoutThemeProtocol, isEditing: Bool) {

		cardBrandImageView.image = viewModel.cardBrandImage
		cardHolderLabel.text = viewModel.cardHolder?.uppercased()
		cardDetailsLabel.text = viewModel.last4AndExpDateText

		cardHolderLabel.font = uiTheme.checkoutSavedCardCardholderTitleFont
		cardDetailsLabel.font = uiTheme.checkoutSavedCardDetailsTitleFont
		itemContainerView.backgroundColor = uiTheme.checkoutPaymentOptionBackgroundColor

		if saveCardActionView == nil {
			let actionView = VGSSavedCardCellActionView(uiTheme: uiTheme)
			actionView.translatesAutoresizingMaskIntoConstraints = false
			actionView.widthAnchor.constraint(equalToConstant: 30).isActive = true
			itemContainerView.stackView.addArrangedSubview(actionView)
			saveCardActionView = actionView
			saveCardActionView?.delegate = self
		}

//		if UIApplication.isRunningUITest {
//			let last4 = viewModel.last4 ?? ""
//			saveCardActionView?.removeCardButton.accessibilityIdentifier = "VGSCheckout.Screens.PaymentOptions.Buttons.RemoveSavedCard" + last4
//		}

		if isEditing {
			saveCardActionView?.actionViewState = .remove
		} else {
			saveCardActionView?.actionViewState = .selected(viewModel.isSelected)
		}

		if viewModel.isSelected && !isEditing {
			cardHolderLabel.textColor = uiTheme.checkoutSavedCardCardholderSelectedTitleColor
			cardDetailsLabel.textColor = uiTheme.checkoutSavedCardDetailsSelectedTitleColor
			itemContainerView.layer.borderColor = uiTheme.checkoutSavedCardSelectedBorderColor.cgColor
			itemContainerView.layer.borderWidth = 1
		} else {
			cardHolderLabel.textColor = uiTheme.checkoutSavedCardCardholderTitleColor
			cardDetailsLabel.textColor = uiTheme.checkoutSavedCardDetailsTitleColor
			itemContainerView.layer.borderWidth = 1
			itemContainerView.layer.borderColor = UIColor.clear.cgColor
		}
	}

	// MARK: - Helpers

	/// Setups UI.
	private func setupUI() {
		selectionStyle = .none
		contentView.backgroundColor = .clear
		backgroundColor = .clear
		contentView.addSubview(itemContainerView)

		itemContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
		itemContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		itemContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		itemContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

		itemContainerView.stackView.addArrangedSubview(cardBrandImageView)
		itemContainerView.stackView.addArrangedSubview(cardDetailsStackView)

		cardDetailsStackView.addArrangedSubview(cardHolderLabel)
		cardDetailsStackView.addArrangedSubview(cardDetailsLabel)
	}
}

// MARK: - VGSSavedCardOptionActionViewDelegate

/// no:doc
extension VGSPaymentOptionCardTableViewCell: VGSSavedCardOptionActionViewDelegate {

	/// no:doc
	func removeCardDidTapInView(in view: VGSSavedCardCellActionView) {
		delegate?.removeCardDidTap(in: self)
	}
}
