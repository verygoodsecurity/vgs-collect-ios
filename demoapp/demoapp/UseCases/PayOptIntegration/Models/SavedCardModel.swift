//
//  SavedCardModel.swift
//  demoapp

import Foundation
import VGSCollectSDK

/// Holds saved card data.
internal class SavedCardModel {

	// MARK: - Vars

	/// Fin instrument id.
	internal let id: String
	/// Card brand name.
	internal let cardBrandName: String
	/// Last 4 digits.
	internal let last4: String
	/// Exp date.
	internal let expDate: String
	/// Card holder name.
	internal let cardHolder: String
	/// A Boolean flag, indicates selection state, default is `false`.
	internal var isSelected = false

	/// no:doc
	struct JSONKeys {
		static let data = "data"
		static let id = "id"
		static let card = "card"
		static let number = "number"
		static let name = "name"
		static let expYear = "exp_year"
		static let expMonth = "exp_month"
		static let brand = "brand"
		static let last4 = "last4"
	}

	// MARK: - Initializer

	/// Initializer.
	internal init?(json: JsonData) {
		let keys = JSONKeys.self
		guard let dataJSON = json[keys.data] as? JsonData,
					let id = dataJSON[keys.id] as? String,
				let cardJSON = dataJSON[keys.card] as? JsonData,
		let cardNumber = cardJSON[keys.number] as? String,
		let name = cardJSON[keys.name] as? String,
		let expYear = cardJSON[keys.expYear] as? Int,
		let expMonth = cardJSON[keys.expMonth] as? Int,
		let brand = cardJSON[keys.brand] as? String ,
		let last4 = cardJSON[keys.last4] as? String else {
			return nil
		}
		self.id = id
		self.cardHolder = name
		self.last4 = last4
		self.expDate = "\(expMonth)/" + "\(expYear)"
		self.cardBrandName = brand
	}

	/// Initializer
	/// - Parameters:
	///   - id: `String` object, card fin id.
	///   - cardBrand: `String` object, card brand name.
	///   - last4: `String` object, last 4 digits.
	///   - expDate: `String` object, exp date.
	///   - cardHolder: `String` object, card holder name.
	internal init(id: String, cardBrand: String, last4: String, expDate: String, cardHolder: String) {
		self.id = id
		self.cardBrandName = cardBrand
		self.last4 = last4
		self.expDate = expDate
		self.cardHolder = cardHolder
	}
}

// no:doc
internal extension Array where Element == SavedCardModel {
	/// Reorders array of saved cards by fin instrument ids.
	/// - Parameter cardIds: `[String]` object, an array of fin instrument ids.
	/// - Returns: `[VGSSavedCardModel]` object, an array of reordered saved cards.
	func reorderByIds(_ cardIds: [String]) -> [SavedCardModel] {
		var orderedArray: [SavedCardModel] = []
		cardIds.forEach { id in
			for card in self {
				if card.id == id {
					orderedArray.append(card)
				}
			}
		}

		return orderedArray
	}
}

/// Card payment option cell view model.
internal struct VGSPaymentOptionCardCellViewModel {

	/// Card holder name text.
	internal let cardHolder: String?

	/// Last 4 and exp date 4 text.
	internal let last4AndExpDateText: String?

	/// Indicates selected state.
	internal var isSelected: Bool

	/// Last 4.
	internal let last4: String?
}
