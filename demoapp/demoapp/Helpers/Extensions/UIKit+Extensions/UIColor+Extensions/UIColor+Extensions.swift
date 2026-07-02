//
//  UIColor+Extensions.swift
//  demoapp

import Foundation
import UIKit

internal extension UIColor {
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt64()
		Scanner(string: hex).scanHexInt64(&int)
		let alha, red, green, blue: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(alha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(alha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(alha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(alha, red, green, blue) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alha) / 255)
	}
}

// This code is taken from https://github.com/noahsark769/ColorCompatibility
// Thanks to Noah Gilmore.
// Copyright (c) 2019 Noah Gilmore <noah.w.gilmore@gmail.com>
internal extension UIColor {

	/// :nodoc: System background color (white).
	static var vgsSystemBackground: UIColor {
		return .systemGroupedBackground
	}

	/// :nodoc: Input text color (black).
	static var vgsInputBlackTextColor: UIColor {
		return UIColor { traits -> UIColor in
			return traits.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
		}
	}

	/// :nodoc: Input text color (black).
	static var vgsBorderColor: UIColor {
		return UIColor { traits -> UIColor in
			return traits.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
		}
	}

	/// :nodoc: VGS section title color.
	static var vgsSectionTitleColor: UIColor {
		return label
	}

	/// :nodoc: VGS section background color.
	static var vgsSectionBackgroundColor: UIColor {
		return UIColor.secondarySystemGroupedBackground
	}

	/// :nodoc:
	static var vgsPaymentOptionBackgroundColor: UIColor {
		return UIColor.secondarySystemGroupedBackground
	}

	/// :nodoc: VGS systemGray2 color.
	static var vgsSystemGray2Color: UIColor {
		return UIColor.systemGray2
	}

	/// :nodoc: VGS systemGray color.
	static var vgsSystemGrayColor: UIColor {
		return UIColor.systemGray
	}
}

extension UIColor {
	static var inputBlackTextColor: UIColor {
		return UIColor { traits -> UIColor in
			return traits.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
		}
	}
}
