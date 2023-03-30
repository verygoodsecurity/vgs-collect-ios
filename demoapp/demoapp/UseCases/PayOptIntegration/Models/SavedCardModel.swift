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
	/// Card brand.
	internal let cardBrand: VGSPaymentCards.CardBrand

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
					let brand = cardJSON[keys.brand] as? String,
					let last4 = cardJSON[keys.last4] as? String else {
			return nil
		}
		self.id = id
		self.cardHolder = name
		self.last4 = last4
		self.expDate = "\(expMonth)/" + "\(expYear)"
		self.cardBrandName = brand
		self.cardBrand = VGSPaymentCards.CardBrand(brand)
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
		self.cardBrand = VGSPaymentCards.CardBrand(cardBrand)
	}

	/// Payment option cell view model.
	internal var paymentOptionCellViewModel: VGSPaymentOptionCardCellViewModel {
		let image = cardBrand.brandIcon

		let last4Text = "•••• \(last4) | \(expDate)"

		return VGSPaymentOptionCardCellViewModel(cardBrandImage: image, cardHolder: cardHolder, last4AndExpDateText: last4Text, isSelected: isSelected, last4: self.last4)
	}

	/// Masled last 4 digits.
	internal var maskedLast4: String {
		return "•••• \(last4)"
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
			for card in self where card.id == id {
					orderedArray.append(card)
			}
		}

		return orderedArray
	}
}

/// Card payment option cell view model.
internal struct VGSPaymentOptionCardCellViewModel {

	/// Card brand image.
	internal let cardBrandImage: UIImage?

	/// Card holder name text.
	internal let cardHolder: String?

	/// Last 4 and exp date 4 text.
	internal let last4AndExpDateText: String?

	/// Indicates selected state.
	internal var isSelected: Bool

	/// Last 4.
	internal let last4: String?
}

extension VGSPaymentCards.CardBrand {

	/// Normalized brandname.
	internal var normalizedBrandName: String {
		switch self {
		case .elo:
			return "elo"
		case .visaElectron:
			return "visaelectron"
		case .maestro:
			return "maestro"
		case .forbrugsforeningen:
			return "forbrugsforeningen"
		case .dankort:
			return "dankort"
		case .visa:
			return "visa"
		case .mastercard:
			return "mastercard"
		case .amex:
			return "amex"
		case .hipercard:
			return "hipercard"
		case .dinersClub:
			return "dinersclub"
		case .discover:
			return "discover"
		case .unionpay:
			return "unionpay"
		case .jcb:
			return "jcb"
		case .unknown:
			return "uknown"
			//						case .custom(let brandName):
			//							return brandName
		case .custom(brandName: let brandName):
			return brandName
		}
	}

	/// Initializer.
	/// - Parameter jsonCardBrandName: `String` object, card brand name from JSON.
	internal init(_ jsonCardBrandName: String) {
		guard let brand = VGSPaymentCards.CardBrand.allNonCustomBrands.first(where: {return jsonCardBrandName.normalizedCardBrandName == $0.normalizedBrandName}) else {
			self = .unknown
			return
		}
		self = brand
	}

	/// An array of non-custom brands.
	internal static var allNonCustomBrands: [VGSPaymentCards.CardBrand] {
		return [
			.elo,
			.visaElectron,
			.maestro,
			.forbrugsforeningen,
			.dankort,
			.visa,
			.mastercard,
			.amex,
			.hipercard,
			.dinersClub,
			.discover,
			.unionpay,
			.jcb
		]
	}
}

/// no:doc
internal extension String {

	/// Normalized card brand name.
	var normalizedCardBrandName: String {
		return lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
