//
//  CollectPaymentOrchestrationViewController.swift
//  demoapp
//

import Foundation
import UIKit
import VGSCollectSDK

/// A class that demonstrates how to collect data from VGSTextFields and upload it to Payment Orchestration service.
class PayOptIntegrationViewController: UIViewController {

	/// Data for cell labels
	struct PaymentCellData {
		let title: String
		let subtitle: String
	}

	/// Init VGSCollect instance with payopt tenanId(vaultId) for AddCard flow
	var vgsCollectNewCardFlow = VGSCollect(id: AppCollectorConfiguration.shared.tenantId, environment: AppCollectorConfiguration.shared.environment)
	/// Init VGSCollect instance with payopt tenanId(vaultId) for SavedCard flow
	var vgsCollectSavedCardFlow = VGSCollect(id: AppCollectorConfiguration.shared.tenantId, environment: AppCollectorConfiguration.shared.environment)

	/// Payopt access token
	var payOptAccessToken = ""
	/// Saved cards details
	var savedCards = [SavedCardModel]()
	/// Payment methods datasource: paypal, saved cards, new card
	var paymentMethodsDataSource = [PaymentCellData]()
	/// Selected cell
	var selectedIndexPath = IndexPath(index: 0)
	/// Is Add card cell collapsed
	var isAddCardCellSelected: Bool {
		return selectedIndexPath.section == (paymentMethodsDataSource.count - 1)
	}

	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Enable loggs from collect SDK
		VGSCollectLogger.shared.configuration.isExtensiveDebugEnabled = true
		VGSCollectLogger.shared.configuration.isNetworkDebugEnabled = true
		// Setup UI
		prepareDataSource()
		setupTableView()
	}

	private func prepareDataSource() {
		paymentMethodsDataSource.append(PaymentCellData(title: "PayPall",
																									subtitle: "You will be sent to PayPall to complete the deposit"))
		for savedCard in savedCards {
			paymentMethodsDataSource.append(PaymentCellData(title: "\(savedCard.cardBrandName.uppercased()) \(savedCard.last4)",
																										subtitle: "Expires \(savedCard.expDate)"))
		}
		paymentMethodsDataSource.append(PaymentCellData(title: "Add credit or debit card",
																										subtitle: ""))
	}

	// MARK: - Init UI
	private func setupTableView() {
		tableView.register(UINib(nibName: "PaymentCardCell", bundle: nil), forCellReuseIdentifier: "PaymentCardCell")
		tableView.register(UINib(nibName: "AddCardCell", bundle: nil), forCellReuseIdentifier: "AddCardCell")
		tableView.dataSource = self
		tableView.delegate = self
		tableView.allowsSelection = true
		tableView.reloadData()
	}

		@objc
		func hideKeyboard() {
				view.endEditing(true)
		}

		// Upload data from TextFields to VGS
		@IBAction func uploadAction(_ sender: Any) {
			// hide kayboard
			hideKeyboard()
			if isAddCardCellSelected {
				// create financial instrument
				createFinId()
			} else if selectedIndexPath.section != 0{
				// collect cvc and pay
				let selectedFinId = savedCards[selectedIndexPath.section - 1]
				depositWithSavedCard(selectedFinId.id, amount: 50)
			} else {
				/// deposit with PayPal
			}
		}

	// MARK: - API methods
	/// Create financial instrument with AddCard fields
	private func createFinId() {
		guard !payOptAccessToken.isEmpty else {
			return
		}
		/// Validate fields
		let notValidFields = vgsCollectNewCardFlow.textFields.filter({ $0.state.isValid == false })
		if notValidFields.count > 0 {
			notValidFields.forEach({
				$0.borderWidth = 1
				print($0.state.validationErrors)
			})
			return
		}

		/// Create fin instrument
		vgsCollectNewCardFlow.customHeaders = ["Authorization": "Bearer \(payOptAccessToken)"]
		/// Send card data to "financial_instruments" path
		vgsCollectNewCardFlow.sendData(path: "/financial_instruments", routeId: AppCollectorConfiguration.shared.paymentOrchestrationDefaultRouteId) { [weak self] response in
			switch response {
			case .success(_, let data, _):
				/// Get fin instriment from response data
				guard let finId = self?.financialInstrumentID(from: data) else {
					print("can't parse fin_id from data!")
					return
				}
				/// Save fin instrument in shared config
				DemoAppConfig.shared.savedFinancialInstruments.append(finId)
				/// Make deposit request
				self?.deposit(50, finId: finId)
			case .failure(let code,  _, _, let error):
				print("\(code) + \(String(describing: error))")
				return
			}
		}
	}

	/// Tokenize CVC for saved card and send data to custom backend for transfer
	func depositWithSavedCard(_ findId: String, amount: Int) {
		/// Validate fields
		let notValidFields = vgsCollectSavedCardFlow.textFields.filter({ $0.state.isValid == false })
		if notValidFields.count > 0 {
			notValidFields.forEach({
				$0.borderWidth = 1
				print($0.state.validationErrors)
			})
			return
		}

		/// Add custom headers if needed
		///    vgsCollectNewCardFlow.customHeaders = ["Authorization": "<custom-backend-token-if-needed>"]

		///  Include all data required for transaction in extradata attribute.
		let extraData: [String : Any] = ["fin_id": findId, "amount": amount]
		///  You should create new route in VGS Dashboard to tokenize CVC.
		let cvcRouteId = "<route-id>"
		///  CVC data will be tokenized and redirected to upstream url(custom backend).
		vgsCollectSavedCardFlow.sendData(path: "/post", routeId: cvcRouteId, extraData: extraData) { response in
			switch response {
			case .success(let code, let data, _):
				print("success: \(code) \(data)")
			case .failure(let code, _, _, let error):
				print("error: \(code) \(error)")
			}
		}
	}

	/// Send deposit request to custom backend
	private func deposit(_ sum: Int, finId: String) {
		// TODO: make API call to custom backend, backend should use fin_id and sum to make transfer via payopt API.
		print("🔼 Send transfer with deposit: \(sum) fin_id: \(finId)")
		/// Navigate to completion VC
		let storyBoard = UIStoryboard(name: "Main", bundle:nil)
		let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CompletionViewController")
		self.navigationController?.pushViewController(nextViewController, animated: true)
	}
}

// MARK: - UITableView
extension PayOptIntegrationViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return paymentMethodsDataSource.count
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath == selectedIndexPath {
			return UITableView.automaticDimension
		}
		return 64
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cellData = paymentMethodsDataSource[indexPath.section]

			if indexPath.section == paymentMethodsDataSource.count - 1,  let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardCell", for: indexPath) as? AddCardCell  {
					cell.title.text = cellData.title
					cell.layer.borderWidth = 1
					cell.layer.borderColor = UIColor.darkGray.cgColor
					cell.setupVGSTextFieldsConfiguration(with: vgsCollectNewCardFlow)
					cell.setSelected(isAddCardCellSelected)
					return cell
			} else if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCardCell", for: indexPath) as? PaymentCardCell  {
					cell.title.text = cellData.title
					cell.subtitle.text = cellData.subtitle
					cell.layer.borderWidth = 1
					cell.layer.borderColor = UIColor.black.cgColor
					let isSelected = (indexPath.section == selectedIndexPath.section)
					cell.setSelected(isSelected)
					if isSelected {
						/// Attach CVC field to VGSCollect instance
						cell.setupVGSTextFieldConfiguration(vgsCollectSavedCardFlow)
					}
					return cell
			}
			return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
			/// deatach cvc field attached with previously selected field
			vgsCollectSavedCardFlow.unsubscribeAllTextFields()
			selectedIndexPath = indexPath
			tableView.reloadData()
	}
}

extension PayOptIntegrationViewController {
	/// Financial instrument id from success payment orchestration save card response.
	/// - Parameter data: `Data?` object, response data.
	/// - Returns: `String?` object, financial instrument id or `nil`.
	func financialInstrumentID(from data: Data?) -> String? {
		if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
			if let dataJSON = jsonData["data"] as? [String: Any] {
				if let financialInstumentID = dataJSON["id"] as? String {
					return financialInstumentID
				}
			}
		}
		return nil
	}
}

