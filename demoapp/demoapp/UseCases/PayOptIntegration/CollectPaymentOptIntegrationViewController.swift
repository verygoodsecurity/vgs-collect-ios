//
//  CollectPaymentOrchestrationViewController.swift
//  demoapp
//

import Foundation
import UIKit
import VGSCollectSDK

enum RequestResult<T> {
	case success(T)
	case error(String?)
	case isLoading
}

/// A class that demonstrates how to collect data from VGSTextFields and upload it to Payment Orchestration service.
class CollectPayoptIntegrationViewConroller: UIViewController {

	/// Data for cell labels
	struct PaymentCellData {
		let title: String
		let subtitle: String
	}

	/// Init VGSCollect instance with payopt tenanId(vaultId) for AddCard flow
	var vgsCollectNewCardFlow = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
	/// Init VGSCollect instance with payopt tenanId(vaultId) for SavedCard flow
	var vgsCollectSavedCardFlow = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)

	/// Payopt access token
	var payOptAccessToken = ""
	/// Saved cards details
	var savedCards = [SavedCardModel]()
	/// Payment methods datasource: paypal, saved cards, new card
	var paymentMethodsDataSource = [PaymentCellData]()
	/// Selected cell
	var selectedIndexPath = IndexPath(row: 0, section: 0)
	/// Is Add card cell collapsed
	var isAddCardCellSelected: Bool {
		return selectedIndexPath.row == (paymentOptions.count - 1)
	}

	/// Payment options
	var paymentOptions: [PaymentOption] = [.newCard]

	/// Screen state, default is `.initial`.
	var state: ScreenState = ScreenState.initial {
		didSet {
			updateUI()
		}
	}

	/// Defines screen state.
	enum ScreenState {
		case initial
		case fetchingToken(_ requestState: RequestResult<String>)
		case fetchingSavedCards(_ requestState: RequestResult<[SavedCardModel]>)
	}

	let apiClient = CustomBackendAPIClient()

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var textView: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Enable loggs from collect SDK
		VGSCollectLogger.shared.configuration.isExtensiveDebugEnabled = true
		VGSCollectLogger.shared.configuration.isNetworkDebugEnabled = true

		// Setup UI.
		prepareDataSource()
		setupTableView()

		textView.font = UIFont.preferredFont(forTextStyle: .body)

		// Fetch token and cards.
		fetchAccessTokenAndCards()
	}

	/// Fetches access token for payopt.
	private func fetchAccessTokenAndCards() {
		state = .fetchingToken(.isLoading)

		let models = 	[SavedCardModel(id: "1", cardBrand: "visa", last4: "1231", expDate: "12/22", cardHolder: "John Smith"),
				SavedCardModel(id: "2", cardBrand: "maestro", last4: "1488", expDate: "01/23", cardHolder: "John Smith")]

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			self.state = .fetchingSavedCards(.success(models))
		}

		return
		return
		state = .fetchingSavedCards(.success(models))

		apiClient.fetchToken {[weak self] token in
			guard let strongSelf = self else {return}
			strongSelf.state = .fetchingToken(.success(token))
			strongSelf.fetchSavedCards()
		} failure: {[weak self] errorMessage in
			guard let strongSelf = self else {return}
			strongSelf.state = .fetchingToken(.error(errorMessage))
		}
	}

	/// Fetches saved cards.
	private func fetchSavedCards() {
		guard !AppCollectorConfiguration.shared.savedFinancialInstruments.isEmpty else {return}
		state = .fetchingSavedCards(.isLoading)
		apiClient.fetchSavedPaymentMethods(AppCollectorConfiguration.shared.savedFinancialInstruments, accessToken: payOptAccessToken) {[weak self] fetchedCards in
			guard let strongSelf = self else {return}
			strongSelf.state = .fetchingSavedCards(.success(fetchedCards))
		} failure: {[weak self] requestError in
			guard let strongSelf = self else {return}
			strongSelf.state = .fetchingSavedCards(.error(requestError?.localizedDescription ?? "Cannot fetch saved cards."))
		}

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
		tableView.register(VGSPaymentOptionCardTableViewCell.self, forCellReuseIdentifier: VGSPaymentOptionCardTableViewCell.cellIdentifier)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.allowsSelection = true
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
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
				guard let finId = self?.apiClient.financialInstrumentID(from: data) else {
					print("can't parse fin_id from data!")
					return
				}
				/// Save fin instrument in shared config
				AppCollectorConfiguration.shared.savedFinancialInstruments.append(finId)
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
		//		let storyBoard = UIStoryboard(name: "Main", bundle:nil)
		//		let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CompletionViewController")
		//		self.navigationController?.pushViewController(nextViewController, animated: true)
	}

	fileprivate func updateUI() {
		switch state {
		case .initial:
			hideLoader()
		case .fetchingToken(let requestState):
			updateUI(with: requestState)
		case .fetchingSavedCards(let savedCardsRequestState):
			updateSavedCardsUI(with: savedCardsRequestState)
		}
	}

	func updateUI(with fetchingTokenRequestState: RequestResult<String>) {
		switch fetchingTokenRequestState {
		case .success(let accessToken):
			hideLoader()
			payOptAccessToken = accessToken
			textView.text = "Fetched token: \(accessToken)"
		case .error(let errorText):
			hideLoader()
			let error = errorText ?? "Uknown error"
			let errorMessage = "Cannot fetch access token: \(error)"
			print(errorMessage)
			textView.text = errorMessage
		case .isLoading:
			textView.text = "Fetching token.."
			displayLoader()
		}
	}

	func updateSavedCardsUI(with savedCardsRequestState: RequestResult<[SavedCardModel]>) {
		switch savedCardsRequestState {
		case .success(let fetchedCards):
			savedCards = fetchedCards
			paymentOptions = fetchedCards.map({return PaymentOption.savedCard($0)}) + [.newCard]
			prepareDataSource()
			tableView.reloadData()
			hideLoader()
		case .error(let errorText):
			print("Cannot fetch saved cards: \(errorText ?? "Uknown error")")
			hideLoader()
	  case .isLoading:
			displayLoader()
		}
	}
}

// MARK: - UITableView
extension CollectPayoptIntegrationViewConroller: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return paymentOptions.count
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}

//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////		if indexPath == selectedIndexPath {
////			return UITableView.automaticDimension
////		}
//		return UITableView.automaticDimension
//	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let paymentOption = paymentOptions[indexPath.row]
		switch paymentOption {
		case .newCard:
			let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardCell", for: indexPath) as! AddCardCell
			cell.title.text = "Add credit or debit card"
//			cell.layer.borderWidth = 1
//			cell.layer.borderColor = UIColor.darkGray.cgColor
			cell.setupVGSTextFieldsConfiguration(with: vgsCollectNewCardFlow)
			cell.setSelected(isAddCardCellSelected)

			return cell
		case .savedCard(let savedCardModel):
			let cell: VGSPaymentOptionCardTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
			cell.configure(with: savedCardModel.paymentOptionCellViewModel, isEditing: false)
			//cell.delegate = self

			return cell
		}


//		if indexPath.section == paymentMethodsDataSource.count - 1,  let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardCell", for: indexPath) as? AddCardCell  {
//			cell.title.text = cellData.title
//			cell.layer.borderWidth = 1
//			cell.layer.borderColor = UIColor.darkGray.cgColor
//			cell.setupVGSTextFieldsConfiguration(with: vgsCollectNewCardFlow)
//			cell.setSelected(isAddCardCellSelected)
//			return cell
//		} else if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCardCell", for: indexPath) as? PaymentCardCell  {
//
//			let cell: VGSPaymentOptionCardTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
//			cell.configure(with: card.paymentOptionCellViewModel, uiTheme: uiTheme, isEditing: screenState.isEditingSavedCard)
//			cell.delegate = self
//
//			return cell

//			cell.title.text = cellData.title
//			cell.subtitle.text = cellData.subtitle
//			cell.layer.borderWidth = 1
//			cell.layer.borderColor = UIColor.black.cgColor
//			let isSelected = (indexPath.section == selectedIndexPath.section)
//			cell.setSelected(isSelected)
//			if isSelected {
//				/// Attach CVC field to VGSCollect instance
//				cell.setupVGSTextFieldConfiguration(vgsCollectSavedCardFlow)
//			}
//			return cell
//		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		/// deatach cvc field attached with previously selected field
		vgsCollectSavedCardFlow.unsubscribeAllTextFields()
		selectedIndexPath = indexPath
		tableView.reloadData()
	}
}
