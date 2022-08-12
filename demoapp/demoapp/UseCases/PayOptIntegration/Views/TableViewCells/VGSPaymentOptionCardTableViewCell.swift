//
//  VGSPaymentOptionCardTableViewCell.swift
//  demoapp

import Foundation
import UIKit
import VGSCollectSDK

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

	/// The background color of the payment option item.
	internal	var checkoutPaymentOptionBackgroundColor: UIColor = .vgsPaymentOptionBackgroundColor

	/// The text color of the card holder title in saved card item.
	internal var checkoutSavedCardCardholderTitleColor: UIColor = .vgsInputBlackTextColor

	/// The text color of the card holder title in saved card item in selected state.
	internal var checkoutSavedCardCardholderSelectedTitleColor: UIColor = .systemBlue

	/// The text font of the card holder title in saved card item. Default is `.caption1` with `.semibold` weight.
	internal var checkoutSavedCardCardholderTitleFont: UIFont = .vgsPreferredFont(forTextStyle: .caption1, weight: .semibold, maximumPointSize: 18)

	/// The text color of the last 4 and exp date in saved card item.
	internal	var checkoutSavedCardDetailsTitleColor: UIColor = .vgsSystemGrayColor

	/// The text color of the last 4 and exp date in saved card item in selected state.
	internal	var checkoutSavedCardDetailsSelectedTitleColor: UIColor = .vgsSystemGrayColor

	/// The text font of the of the last 4 and exp date in saved card item. Default is `.callout` with `.semibold` weight.
	internal	var checkoutSavedCardDetailsTitleFont: UIFont = .vgsPreferredFont(forTextStyle: .callout, weight: .medium, maximumPointSize: 16)

	/// The border color of the saved card item when selected.
	internal	var checkoutSavedCardSelectedBorderColor: UIColor = .systemBlue

	/// The text color for new card payment option title.
	internal	var checkoutPaymentOptionNewCardTitleColor: UIColor = .systemBlue

	/// The font for new card payment option title. Default is `.callout` with `.semibold` weight.
	internal	var checkoutPaymentOptionNewCardTitleFont: UIFont = .vgsPreferredFont(forTextStyle: .callout, weight: .semibold, maximumPointSize: 18)

	/// The background color of the payment option checkbox for unselected state.
	internal	var checkoutPaymentOptionCheckboxUnselectedColor: UIColor = UIColor.vgsSystemGrayColor

	/// The background color of the payment option checkbox for selected state.
	internal	var checkoutPaymentOptionCheckboxSelectedColor: UIColor = UIColor.systemBlue

	/// The checkmark tint color in the payment option checkbox.
	internal	var checkoutPaymentOptionCheckmarkTintColor: UIColor = .white

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
	internal func configure(with viewModel: VGSPaymentOptionCardCellViewModel, isEditing: Bool) {

		cardBrandImageView.image = viewModel.cardBrandImage
		cardHolderLabel.text = viewModel.cardHolder?.uppercased()
		cardDetailsLabel.text = viewModel.last4AndExpDateText

		cardHolderLabel.font = checkoutSavedCardCardholderTitleFont
		cardDetailsLabel.font = checkoutSavedCardDetailsTitleFont
		itemContainerView.backgroundColor = checkoutPaymentOptionBackgroundColor

		if saveCardActionView == nil {
			let actionView = VGSSavedCardCellActionView()
			actionView.translatesAutoresizingMaskIntoConstraints = false
			actionView.widthAnchor.constraint(equalToConstant: 30).isActive = true
			itemContainerView.stackView.addArrangedSubview(actionView)
			saveCardActionView = actionView
			saveCardActionView?.delegate = self
		}

		if isEditing {
			saveCardActionView?.actionViewState = .remove
		} else {
			saveCardActionView?.actionViewState = .selected(viewModel.isSelected)
		}

		if viewModel.isSelected && !isEditing {
			cardHolderLabel.textColor = checkoutSavedCardCardholderSelectedTitleColor
			cardDetailsLabel.textColor = checkoutSavedCardDetailsSelectedTitleColor
			itemContainerView.layer.borderColor = checkoutSavedCardSelectedBorderColor.cgColor
			itemContainerView.layer.borderWidth = 1
		} else {
			cardHolderLabel.textColor = checkoutSavedCardCardholderTitleColor
			cardDetailsLabel.textColor = checkoutSavedCardDetailsTitleColor
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
