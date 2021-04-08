//
//  CollectMultiplexingViewController.swift
//  demoapp
//

import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to VGS for Multiplexing setup.
class CollectMultiplexingViewController: UIViewController {

	@IBOutlet weak var cardDataStackView: UIStackView!
	@IBOutlet weak var consoleStatusLabel: UILabel!
	@IBOutlet weak var consoleLabel: UILabel!

	// Init VGS Collector
	var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)

	// VGS UI Elements
	var cardNumber = VGSCardTextField()
	var expCardDate = VGSExpDateTextField()
	var cvcCardNum = VGSCVCTextField()
	var cardHolderFirstName = VGSTextField()
	var cardHolderLastName = VGSTextField()

	var consoleMessage: String = "" {
		didSet { consoleLabel.text = consoleMessage }
	}

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		setupUI()
		setupElementsConfiguration()

		// check if device is jailbroken
		if VGSCollect.isJailbroken() {
			print("Device is Jailbroken")
		}

		// set custom headers
		vgsCollect.customHeaders = [
			"my custome header": "some custom data"
		]

		// Observing text fields. The call back return all textfields with updated states. You also can use VGSTextFieldDelegate
		vgsCollect.observeStates = { [weak self] form in

			self?.consoleMessage = ""
			self?.consoleStatusLabel.text = "STATE"

			form.forEach({ textField in
				self?.consoleMessage.append(textField.state.description)
				self?.consoleMessage.append("\n")
			})
		}
	}

	// MARK: - Init UI
	private func setupUI() {

		cardDataStackView.addArrangedSubview(cardHolderFirstName)
		cardDataStackView.addArrangedSubview(cardHolderLastName)
		cardDataStackView.addArrangedSubview(cardNumber)
		cardDataStackView.addArrangedSubview(expCardDate)
		cardDataStackView.addArrangedSubview(cvcCardNum)

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		consoleLabel.addGestureRecognizer(tapGesture)
		consoleLabel.isUserInteractionEnabled = true
		view.addGestureRecognizer(tapGesture)
	}

	@objc
	func hideKeyboard() {
		view.endEditing(true)
		consoleLabel.endEditing(true)
	}

	private func setupElementsConfiguration() {

		let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "data.attributes.details.number")
		cardConfiguration.type = .cardNumber
		cardNumber.configuration = cardConfiguration
		cardNumber.placeholder = "4111 1111 1111 1111"
		cardNumber.textAlignment = .natural
		cardNumber.cardIconLocation = .right

		cardNumber.becomeFirstResponder()

		/// Use `VGSExpDateConfiguration` if you need to convert output date format
		let expDateConfiguration = VGSExpDateConfiguration(collector: vgsCollect, fieldName: "data.attributes.details")
		expDateConfiguration.type = .expDate
		expDateConfiguration.inputDateFormat = .shortYear
		expDateConfiguration.outputDateFormat = .longYear
		expDateConfiguration.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "data.attributes.details.month", yearFieldName: "data.attributes.details.year")]

		/// Default .expDate format is "##/##"
		expDateConfiguration.formatPattern = "##/##"

		/// Update validation rules
		expDateConfiguration.validationRules = VGSValidationRuleSet(rules: [
			VGSValidationRuleCardExpirationDate(dateFormat: .shortYear, error: VGSValidationErrorType.expDate.rawValue)
		])

		expCardDate.configuration = expDateConfiguration
		expCardDate.placeholder = "MM/YY"
		expCardDate.monthPickerFormat = .longSymbols

		let cvcConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "data.attributes.details.verification_value")
		cvcConfiguration.type = .cvc

		cvcCardNum.configuration = cvcConfiguration
		cvcCardNum.isSecureTextEntry = true
		cvcCardNum.placeholder = "CVC"
		cvcCardNum.tintColor = .lightGray

		let firstNameConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "data.attributes.details.first_name")
		firstNameConfiguration.type = .cardHolderName
		firstNameConfiguration.keyboardType = .namePhonePad
		/// Required to be not empty

		cardHolderFirstName.textAlignment = .natural
		cardHolderFirstName.configuration = firstNameConfiguration
		cardHolderFirstName.placeholder = "First Name"

		let lastNameConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "data.attributes.details.last_name")
		lastNameConfiguration.type = .cardHolderName
		lastNameConfiguration.keyboardType = .namePhonePad
		/// Required to be not empty

		cardHolderLastName.textAlignment = .natural
		cardHolderLastName.configuration = lastNameConfiguration
		cardHolderLastName.placeholder = "Last Name"

		vgsCollect.textFields.forEach { textField in
			textField.textColor = UIColor.inputBlackTextColor
			textField.font = .systemFont(ofSize: 22)
			textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
			textField.tintColor = .lightGray
			/// Implement VGSTextFieldDelegate methods
			textField.delegate = self
		}
	}

	// Upload data from TextFields to VGS
	@IBAction func collectForMultiplexing(_ sender: Any) {
		// hide kayboard
		hideKeyboard()

		// check if textfields are valid
		vgsCollect.textFields.forEach { textField in
			textField.borderColor = textField.state.isValid ? .lightGray : .red
		}

		// Multiplexing extra data
		var extraMultiplexingData: [String: Any] = [
			"data": [
				"type" : "financial_instruments",
				"attributes" : [
					"instrument_type": "card"
				]
		]]

		let multiplexingPath = "/api/v1/financial_instruments"

		/// New sendRequest func
		vgsCollect.sendData(path: multiplexingPath, extraData: extraMultiplexingData) { [weak self](response) in

			self?.consoleStatusLabel.text = "RESPONSE"
			switch response {
			case .success(_, let data, _):
				if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
					// swiftlint:disable force_try
					let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
					self?.consoleLabel.text = "Success: \n\(response)"
					print(response)
					// swiftlint:enable force_try
				}
				return
			case .failure(let code, _, _, let error):
				switch code {
				case 400..<499:
					// Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
					self?.consoleLabel.text = "Error: Wrong Request, code: \(code)"
				case VGSErrorType.inputDataIsNotValid.rawValue:
					if let error = error as? VGSError {
						self?.consoleLabel.text = "Error: Input data is not valid. Details:\n \(error)"
					}
				default:
					self?.consoleLabel.text = "Error: Something went wrong. Code: \(code)"
				}
				print("Submit request error: \(code), \(String(describing: error))")
				return
			}
		}
	}
}

// MARK: - VGSTextFieldDelegate
extension CollectMultiplexingViewController: VGSTextFieldDelegate {
	func vgsTextFieldDidChange(_ textField: VGSTextField) {
		print(textField.state.description)
		textField.borderColor = textField.state.isValid  ? .gray : .red

		/// Update CVC field UI in case if valid cvc digits change, e.g.: input card number brand changed form Visa(3 digints CVC) to Amex(4 digits CVC) )
		if textField == cardNumber, cvcCardNum.state.isDirty {
			cvcCardNum.borderColor =  cvcCardNum.state.isValid  ? .gray : .red
		}

		/// Check Card Number Field State with addition attributes
		if let cardState = textField.state as? CardState, cardState.isValid {
			print("THIS IS: \(cardState.cardBrand.stringValue) - \(cardState.bin.prefix(4)) **** **** \(cardState.last4)")
		}
	}
}
