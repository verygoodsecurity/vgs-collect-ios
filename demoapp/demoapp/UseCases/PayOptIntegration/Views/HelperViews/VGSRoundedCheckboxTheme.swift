//
//  VGSRoundedCheckboxTheme.swift
//  demoapp
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// Rounded checkbox theme.
internal protocol VGSRoundedCheckboxTheme {
	/// The background color of the checkbox for unselected state.
	var unselectedColor: UIColor { get set }

	/// The background color of the checkbox for selected state.
	var selectedColor: UIColor { get set }

	/// The checkmark tint color in checkbox.
	var checkmarkTintColor: UIColor { get set }
}

/// Custom rounded checkbox control.
internal class VGSRoundedCheckbox: UIView {

	/// Unselected state image.
	private let unselectedStateImage = UIImage(named: "radio_button_unselected", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

	/// Checkmark image.
	private let checkmarkImage = UIImage(named: "checkmark", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

	// MARK: - Vars

	/// Image view.
	internal lazy var imageView: UIImageView = {
		let imageView = UIImageView(frame: .zero)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	/// Image view with checkmark.
	internal lazy var checkmarkImageView: UIImageView = {
		let imageView = UIImageView(frame: .zero)
		imageView.image = checkmarkImage
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	/// Indicates selection state.
	internal var isSelected: Bool = false {
		didSet {
			updateUI()
		}
	}

	/// Theme object.
	fileprivate let theme: VGSRoundedCheckboxTheme

	// MARK: - Override

	init(theme: VGSRoundedCheckboxTheme) {
		self.theme = theme
		super.init(frame: .zero)

		addSubview(imageView)
		imageView.demoapp_constraintViewToSuperviewEdges()
		addSubview(checkmarkImageView)
		checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		checkmarkImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		checkmarkImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
		checkmarkImageView.heightAnchor.constraint(equalToConstant: 8).isActive = true
	}

	/// no:doc
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}

	/// Updates UI.
	internal func updateUI() {
		if isSelected {
			imageView.image = nil
			imageView.backgroundColor = theme.selectedColor
			checkmarkImageView.tintColor = theme.checkmarkTintColor
			imageView.layer.cornerRadius = 11
			imageView.layer.masksToBounds = true
			checkmarkImageView.isHidden = false
		} else {
			checkmarkImageView.isHidden = true
			imageView.tintColor = theme.unselectedColor
			imageView.image = unselectedStateImage
			imageView.backgroundColor = .clear
			imageView.layer.masksToBounds = false
		}
	}

	/// no:doc
	internal override var intrinsicContentSize: CGSize {
		return CGSize(width: 22, height: 22)
	}

	/// The background color of the payment option checkbox for unselected state.
	internal static	var checkoutPaymentOptionCheckboxUnselectedColor: UIColor = UIColor.vgsSystemGrayColor

	/// The background color of the payment option checkbox for selected state.
	internal static 	var checkoutPaymentOptionCheckboxSelectedColor: UIColor = UIColor.systemBlue

	/// The checkmark tint color in the payment option checkbox.
	internal static	var checkoutPaymentOptionCheckmarkTintColor: UIColor = .white

	/// Generates ui theme for saved card rounded checkbox.
	/// - Returns: `CardCellCheckboxTheme` object, CardCellCheckboxTheme
	static func generateCheckboxThemeForSavedCard() -> VGSRoundedCheckboxTheme {
		let cellCheckboxTheme = VGSPaymentOptionCardTableViewCell.CardCellCheckboxTheme(unselectedColor: checkoutPaymentOptionCheckboxUnselectedColor, selectedColor: checkoutPaymentOptionCheckboxSelectedColor, checkmarkTintColor: checkoutPaymentOptionCheckmarkTintColor)

		return cellCheckboxTheme
	}
}
