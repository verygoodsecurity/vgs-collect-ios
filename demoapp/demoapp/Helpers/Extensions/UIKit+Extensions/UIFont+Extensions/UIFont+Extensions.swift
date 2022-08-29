//
//  UIFont+Extensions.swift
//  demoapp
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// no:doc
public extension UIFont {

	/// Returns font with textStyle and weight.
	/// - Parameters:
	///   - style: `TextStyle` object, font text style.
	///   - weight: `Weight` object, font weight.
	///   - maximumPointSize: `CGFloat?` object, max font size in points, default is `nil`.
	/// - Returns: `UIFont` object.
		static func vgsPreferredFont(forTextStyle style: TextStyle, weight: Weight? = nil, maximumPointSize: CGFloat? = nil) -> UIFont {
				let metrics = UIFontMetrics(forTextStyle: style)
				let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
				let font: UIFont
				if let fontWeight = weight {
					font = UIFont.systemFont(ofSize: desc.pointSize, weight: fontWeight)
				} else {
					font = UIFont.systemFont(ofSize: desc.pointSize)
				}

				if let maximumPointSize = maximumPointSize {
					return metrics.scaledFont(for: font, maximumPointSize: maximumPointSize)
				}

				return metrics.scaledFont(for: font)
		}
}
