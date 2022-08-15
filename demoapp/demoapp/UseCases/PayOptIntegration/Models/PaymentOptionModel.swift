//
//  PaymentOptionModel.swift
//  demoapp
//

import Foundation

/// Payment options.
internal enum PaymentOption {

	/// Saved card.
	/// - Parameter card: `SavedCardModel` object, saved card object.
	case savedCard(_ card: SavedCardModel)

	/// New card.
	case newCard

	/// Saved card associated value of type `SavedCardModel` if .case matches .savedCard.
	internal var savedCardModel: SavedCardModel? {
		switch self {
		case .savedCard(let cardModel):
			return cardModel
		default:
			return nil
		}
	}
}
